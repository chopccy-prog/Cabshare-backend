

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE TYPE "public"."booking_status" AS ENUM (
    'pending',
    'confirmed',
    'cancelled',
    'completed'
);


ALTER TYPE "public"."booking_status" OWNER TO "postgres";


CREATE TYPE "public"."cancellation_actor" AS ENUM (
    'driver',
    'rider',
    'system'
);


ALTER TYPE "public"."cancellation_actor" OWNER TO "postgres";


CREATE TYPE "public"."deposit_status" AS ENUM (
    'created',
    'paid',
    'failed',
    'refunded',
    'cancelled',
    'expired'
);


ALTER TYPE "public"."deposit_status" OWNER TO "postgres";


CREATE TYPE "public"."payment_status" AS ENUM (
    'created',
    'authorized',
    'captured',
    'refunded',
    'failed'
);


ALTER TYPE "public"."payment_status" OWNER TO "postgres";


CREATE TYPE "public"."ride_status" AS ENUM (
    'published',
    'cancelled',
    'completed'
);


ALTER TYPE "public"."ride_status" OWNER TO "postgres";


CREATE TYPE "public"."settlement_status" AS ENUM (
    'requested',
    'processing',
    'paid',
    'rejected'
);


ALTER TYPE "public"."settlement_status" OWNER TO "postgres";


CREATE TYPE "public"."user_role" AS ENUM (
    'passenger',
    'driver',
    'admin',
    'rider'
);


ALTER TYPE "public"."user_role" OWNER TO "postgres";


CREATE TYPE "public"."wallet_tx_type" AS ENUM (
    'reserve',
    'release',
    'transfer_in',
    'transfer_out',
    'adjustment'
);


ALTER TYPE "public"."wallet_tx_type" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."_combine_ts"("d" "date", "t" time without time zone) RETURNS timestamp with time zone
    LANGUAGE "sql" IMMUTABLE PARALLEL SAFE
    AS $$
  select (d::timestamptz + (t::text)::interval);
$$;


ALTER FUNCTION "public"."_combine_ts"("d" "date", "t" time without time zone) OWNER TO "postgres";


COMMENT ON FUNCTION "public"."_combine_ts"("d" "date", "t" time without time zone) IS 'Combine date + time columns to a timestamptz.';



CREATE OR REPLACE FUNCTION "public"."api_book_ride"("p_ride_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
declare
  v_seats integer;
begin
  update public.rides r
     set seats_available = r.seats_available - 1,
         updated_at      = now()
   where r.id = p_ride_id
     and r.seats_available > 0
  returning r.seats_available into v_seats;

  if not found then
    raise exception 'No seats left or ride not found' using errcode = 'P0001';
  end if;

  return jsonb_build_object('id', p_ride_id::text, 'seats', v_seats);
end;
$$;


ALTER FUNCTION "public"."api_book_ride"("p_ride_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."api_book_ride"("p_ride_id" "uuid") IS 'Atomically decrements seats_available and returns {id, seats}.';



CREATE OR REPLACE FUNCTION "public"."app_book_ride"("p_ride_id" "uuid") RETURNS TABLE("id" "uuid", "from" "text", "to" "text", "when" timestamp without time zone, "seats" integer, "price" integer, "pool" "text", "booked" boolean, "driverName" "text", "driverPhone" "text")
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  cur_avail int;
BEGIN
  SELECT seats_available INTO cur_avail FROM public.rides WHERE id = p_ride_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Ride not found';
  END IF;
  IF cur_avail <= 0 THEN
    RAISE EXCEPTION 'No seats left';
  END IF;

  UPDATE public.rides
     SET seats_available = seats_available - 1,
         updated_at = now()
   WHERE id = p_ride_id;

  RETURN QUERY
  SELECT * FROM public.rides_compat rc WHERE rc.id = p_ride_id;
END;
$$;


ALTER FUNCTION "public"."app_book_ride"("p_ride_id" "uuid") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."rides" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "driver_id" "uuid",
    "route_id" "uuid",
    "depart_date" "date",
    "depart_time" time without time zone NOT NULL,
    "price_per_seat_inr" integer,
    "seats_total" integer,
    "seats_available" integer,
    "car_make" "text",
    "car_model" "text",
    "car_plate" "text",
    "notes" "text",
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "status" "public"."ride_status" DEFAULT 'published'::"public"."ride_status" NOT NULL,
    "allow_auto_confirm" boolean DEFAULT true NOT NULL,
    "created_by" "uuid",
    "from" "text",
    "to" "text",
    "start_time" timestamp with time zone,
    "seats" integer DEFAULT 1,
    "price_inr" integer DEFAULT 0,
    "pool" "text" DEFAULT 'private'::"text",
    "is_commercial" boolean DEFAULT false,
    "allow_auto_book" boolean,
    "ride_type" "text",
    CONSTRAINT "rides_price_per_seat_inr_check" CHECK ((("price_per_seat_inr")::numeric >= (0)::numeric)),
    CONSTRAINT "rides_ride_type_check" CHECK (("ride_type" = ANY (ARRAY['private_pool'::"text", 'commercial_pool'::"text", 'commercial_full'::"text"]))),
    CONSTRAINT "rides_seats_available_check" CHECK (("seats_available" >= 0)),
    CONSTRAINT "rides_seats_total_check" CHECK (("seats_total" > 0))
);


ALTER TABLE "public"."rides" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."app_publish_ride"("p_from" "text", "p_to" "text", "p_when" timestamp with time zone, "p_seats" integer DEFAULT 1, "p_price_inr" integer DEFAULT 0, "p_pool" "text" DEFAULT 'private'::"text", "p_is_commercial" boolean DEFAULT false) RETURNS "public"."rides"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare r public.rides;
begin
  insert into public.rides("from","to",start_time,seats,price_inr,pool,is_commercial)
  values (
    p_from,
    p_to,
    p_when,
    coalesce(p_seats,1),
    coalesce(p_price_inr,0),
    p_pool,
    coalesce(p_is_commercial,false)
  )
  returning * into r;
  return r;
end; $$;


ALTER FUNCTION "public"."app_publish_ride"("p_from" "text", "p_to" "text", "p_when" timestamp with time zone, "p_seats" integer, "p_price_inr" integer, "p_pool" "text", "p_is_commercial" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."app_publish_ride"("p_from" "text", "p_to" "text", "p_when" timestamp with time zone, "p_seats" integer, "p_price" integer, "p_pool" "text" DEFAULT 'private'::"text", "p_driver_id" "uuid" DEFAULT NULL::"uuid") RETURNS TABLE("id" "uuid", "from" "text", "to" "text", "when" timestamp without time zone, "seats" integer, "price" integer, "pool" "text", "booked" boolean, "driverName" "text", "driverPhone" "text")
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  rid uuid;
  driver uuid;
  rrow public.rides;
BEGIN
  IF p_seats <= 0 THEN
    RAISE EXCEPTION 'seats must be > 0';
  END IF;
  IF p_price < 0 THEN
    RAISE EXCEPTION 'price must be >= 0';
  END IF;

  rid := public.get_or_create_route(p_from, p_to);

  IF p_driver_id IS NOT NULL THEN
    driver := p_driver_id;
  ELSE
    SELECT id INTO driver FROM public.users_app WHERE email='driver@example.com' LIMIT 1;
    IF driver IS NULL THEN
      -- create a demo driver row if missing
      INSERT INTO public.users_app(id, full_name, phone, email, role, is_verified)
      VALUES (gen_random_uuid(), 'Demo Driver', '9000000001', 'driver@example.com', 'driver', true)
      RETURNING id INTO driver;
    END IF;
  END IF;

  INSERT INTO public.rides(
    id, driver_id, route_id, depart_date, depart_time,
    price_per_seat_inr, seats_total, seats_available,
    status, allow_auto_confirm
  )
  VALUES(
    gen_random_uuid(),
    driver,
    rid,
    (p_when AT TIME ZONE 'UTC')::date,      -- date portion
    (p_when AT TIME ZONE 'UTC')::time,      -- time portion
    p_price,
    p_seats,
    p_seats,
    'published',
    false
  )
  RETURNING * INTO rrow;

  -- Return in app shape via rides_compat
  RETURN QUERY
  SELECT * FROM public.rides_compat rc WHERE rc.id = rrow.id;
END;
$$;


ALTER FUNCTION "public"."app_publish_ride"("p_from" "text", "p_to" "text", "p_when" timestamp with time zone, "p_seats" integer, "p_price" integer, "p_pool" "text", "p_driver_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."apply_deposit_penalty"("p_booking_id" "uuid", "p_cancelled_by" "text") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  v_booking RECORD;
  v_rider_id uuid;
  v_driver_id uuid;
  v_hours_before numeric;
  v_penalty_pct numeric;
  v_deposit_inr integer;
BEGIN
  SELECT * INTO v_booking FROM bookings WHERE id = p_booking_id;
  v_rider_id := v_booking.rider_id;
  v_driver_id := (SELECT driver_id FROM rides WHERE id = v_booking.ride_id);
  v_hours_before := EXTRACT(EPOCH FROM (SELECT depart_date + depart_time FROM rides WHERE id = v_booking.ride_id) - NOW()) / 3600;
  v_deposit_inr := v_booking.deposit_inr;

  IF p_cancelled_by = 'rider' THEN
    IF v_hours_before > 12 THEN v_penalty_pct := 0;
    ELSIF v_hours_before > 6 THEN v_penalty_pct := 0.3;
    ELSE v_penalty_pct := 0.5; END IF;
  ELSE -- driver cancels
    IF v_hours_before > 12 THEN v_penalty_pct := 0;
    ELSIF v_hours_before > 6 THEN v_penalty_pct := 0.2; -- Adjusted for commercial
    ELSE v_penalty_pct := 0.4; END IF;
  END IF;

  UPDATE wallets
  SET balance_available_inr = balance_available_inr - (v_deposit_inr * v_penalty_pct)::int
  WHERE user_id = (CASE WHEN p_cancelled_by = 'rider' THEN v_rider_id ELSE v_driver_id END);
  UPDATE wallets
  SET balance_available_inr = balance_available_inr + (v_deposit_inr * v_penalty_pct)::int
  WHERE user_id = (CASE WHEN p_cancelled_by = 'rider' THEN v_driver_id ELSE v_rider_id END);

  INSERT INTO wallet_transactions (user_id, tx_type, amount_inr, ref_booking_id, note)
  VALUES ((CASE WHEN p_cancelled_by = 'rider' THEN v_rider_id ELSE v_driver_id END), 'penalty', -(v_deposit_inr * v_penalty_pct)::int, p_booking_id, 'Cancellation penalty'),
         ((CASE WHEN p_cancelled_by = 'rider' THEN v_driver_id ELSE v_rider_id END), 'penalty', (v_deposit_inr * v_penalty_pct)::int, p_booking_id, 'Cancellation compensation');
END;
$$;


ALTER FUNCTION "public"."apply_deposit_penalty"("p_booking_id" "uuid", "p_cancelled_by" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."assert_seats_available"("p_ride" "uuid", "p_seats" integer) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
declare
  avail int;
begin
  select seats_available into avail from rides where id = p_ride for update;
  if avail is null then
    raise exception 'Ride not found';
  end if;

  if p_seats > avail then
    raise exception 'Insufficient seats: requested %, available %', p_seats, avail;
  end if;
end$$;


ALTER FUNCTION "public"."assert_seats_available"("p_ride" "uuid", "p_seats" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."book_ride_simple"("p_ride_id" "uuid") RETURNS TABLE("id" "uuid", "seats_remaining" integer)
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  v_left int;
BEGIN
  UPDATE public.rides
     SET seats_available = seats_available - 1
   WHERE id = p_ride_id
     AND seats_available > 0
  RETURNING seats_available INTO v_left;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No seats left or ride not found';
  END IF;

  RETURN QUERY
  SELECT p_ride_id, v_left;
END $$;


ALTER FUNCTION "public"."book_ride_simple"("p_ride_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bookings_adjust_seats"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if tg_op = 'INSERT' then
    update public.rides
      set seats_available = greatest(0,
        coalesce(seats_available, coalesce(seats_total, seats, 0)) - coalesce(new.seat_count,1))
    where id = new.ride_id;
  elsif tg_op = 'DELETE' then
    update public.rides
      set seats_available = least(coalesce(seats_total, seats, 1),
        coalesce(seats_available,0) + coalesce(old.seat_count,1))
    where id = old.ride_id;
  end if;
  return null;
end $$;


ALTER FUNCTION "public"."bookings_adjust_seats"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."enforce_seats_bounds"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  IF NEW.seats_available > NEW.seats_total THEN
    RAISE EXCEPTION 'seats_available (%) cannot exceed seats_total (%)', NEW.seats_available, NEW.seats_total;
  END IF;
  IF NEW.seats_available < 0 THEN
    RAISE EXCEPTION 'seats_available cannot be negative';
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."enforce_seats_bounds"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."ensure_city"("_name" "text") RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_id uuid;
begin
  select c.id into v_id
  from public.cities c
  where lower(c.name) = lower(_name)
  limit 1;

  if v_id is null then
    insert into public.cities (id, name)
    values (gen_random_uuid(), _name)
    returning id into v_id;
  end if;

  return v_id;
end;
$$;


ALTER FUNCTION "public"."ensure_city"("_name" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."ensure_route"("_from_id" "uuid", "_to_id" "uuid") RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_id uuid;
  v_from text;
  v_to   text;
  v_code text;
begin
  select name into v_from from public.cities where id = _from_id;
  select name into v_to   from public.cities where id = _to_id;

  v_code := upper(left(coalesce(v_from,''),3)) || '-' || upper(left(coalesce(v_to,''),3));

  select r.id into v_id
  from public.routes r
  where r.from_city_id = _from_id and r.to_city_id = _to_id
  limit 1;

  if v_id is null then
    insert into public.routes (id, code, from_city_id, to_city_id)
    values (gen_random_uuid(), v_code, _from_id, _to_id)
    returning id into v_id;
  end if;

  return v_id;
end;
$$;


ALTER FUNCTION "public"."ensure_route"("_from_id" "uuid", "_to_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_or_create_city"("p_name" "text") RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
DECLARE cid uuid;
BEGIN
  SELECT id INTO cid FROM public.cities WHERE lower(name)=lower(p_name) LIMIT 1;
  IF cid IS NULL THEN
    INSERT INTO public.cities(id, name, state)
    VALUES (gen_random_uuid(), p_name, NULL)
    RETURNING id INTO cid;
  END IF;
  RETURN cid;
END;
$$;


ALTER FUNCTION "public"."get_or_create_city"("p_name" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_or_create_route"("p_from_city" "text", "p_to_city" "text") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
declare
  v_from  uuid;
  v_to    uuid;
  v_route uuid;
begin
  -- from city
  select id into v_from from public.cities where lower(name)=lower(p_from_city) limit 1;
  if v_from is null then
    insert into public.cities(id, name) values (gen_random_uuid(), p_from_city) returning id into v_from;
  end if;

  -- to city
  select id into v_to from public.cities where lower(name)=lower(p_to_city) limit 1;
  if v_to is null then
    insert into public.cities(id, name) values (gen_random_uuid(), p_to_city) returning id into v_to;
  end if;

  -- route
  select id into v_route
  from public.routes
  where from_city_id = v_from and to_city_id = v_to
  limit 1;

  if v_route is null then
    insert into public.routes(id, code, from_city_id, to_city_id)
    values (gen_random_uuid(), left(p_from_city,3)||'-'||left(p_to_city,3), v_from, v_to)
    returning id into v_route;
  end if;

  return v_route;
end;
$$;


ALTER FUNCTION "public"."get_or_create_route"("p_from_city" "text", "p_to_city" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_or_create_route"("p_from_city" "text", "p_to_city" "text") IS 'Returns a route id for (from_city,to_city), creating cities/route if missing.';



CREATE OR REPLACE FUNCTION "public"."public_ride_simple"("payload" "jsonb") RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  v_from   text;
  v_to     text;
  v_when   timestamptz;
  v_seats  integer;
  v_price  integer;
  v_notes  text;
BEGIN
  v_from  := NULLIF(payload->>'from','');
  v_to    := NULLIF(payload->>'to','');
  v_when  := (payload->>'when')::timestamptz;
  v_seats := (payload->>'seats')::int;
  v_price := (payload->>'price')::int;
  v_notes := NULLIF(payload->>'notes','');

  IF v_from IS NULL OR v_to IS NULL OR v_when IS NULL OR v_seats IS NULL OR v_price IS NULL THEN
    RAISE EXCEPTION 'Missing required fields in payload (need from, to, when, seats, price)';
  END IF;

  RETURN public.publish_ride_simple(v_from, v_to, v_when, v_seats, v_price, v_notes);
END $$;


ALTER FUNCTION "public"."public_ride_simple"("payload" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."public_ride_simple"("p_from" "text", "p_to" "text", "p_when" timestamp with time zone, "p_seats" integer, "p_price" integer, "p_notes" "text" DEFAULT NULL::"text") RETURNS "uuid"
    LANGUAGE "sql"
    AS $$
  SELECT public.publish_ride_simple(p_from, p_to, p_when, p_seats, p_price, p_notes);
$$;


ALTER FUNCTION "public"."public_ride_simple"("p_from" "text", "p_to" "text", "p_when" timestamp with time zone, "p_seats" integer, "p_price" integer, "p_notes" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."publish_ride_simple"("p_from_city" "text", "p_to_city" "text", "p_depart_at" timestamp with time zone, "p_seats_total" integer, "p_price_per_seat" integer, "p_notes" "text" DEFAULT NULL::"text") RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  v_route   uuid;
  v_driver  uuid;
  v_id      uuid;
BEGIN
  -- Route upsert
  v_route := public.get_or_create_route(p_from_city, p_to_city);

  -- Pick a driver (you already seeded Demo Driver). Replace with auth.uid() mapping later.
  SELECT id INTO v_driver
  FROM public.users_app
  WHERE role = 'driver'
  ORDER BY created_at ASC NULLS LAST
  LIMIT 1;

  IF v_driver IS NULL THEN
    RAISE EXCEPTION 'No driver available in users_app';
  END IF;

  -- Insert with duplicate-safe behavior (unique: driver_id, route_id, depart_date, depart_time)
  INSERT INTO public.rides(
    id, driver_id, route_id, depart_date, depart_time,
    price_per_seat_inr, seats_total, seats_available,
    notes, status, allow_auto_confirm
  )
  VALUES (
    gen_random_uuid(),
    v_driver,
    v_route,
    p_depart_at::date,
    p_depart_at::time,
    p_price_per_seat,
    p_seats_total,
    p_seats_total,
    p_notes,
    'published',
    FALSE
  )
  ON CONFLICT (driver_id, route_id, depart_date, depart_time)
  DO UPDATE SET
    notes = EXCLUDED.notes,
    updated_at = now()
  RETURNING id INTO v_id;

  RETURN v_id;
END $$;


ALTER FUNCTION "public"."publish_ride_simple"("p_from_city" "text", "p_to_city" "text", "p_depart_at" timestamp with time zone, "p_seats_total" integer, "p_price_per_seat" integer, "p_notes" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."publish_ride_slim"("p_from" "text", "p_to" "text", "p_when" timestamp with time zone, "p_seats" integer, "p_price" integer, "p_pool" "text" DEFAULT 'private'::"text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
declare
  v_route  uuid;
  v_driver uuid;
  v_date   date;
  v_time   time;
  v_id     uuid;
begin
  -- input sanity
  if p_from is null or p_to is null or p_when is null or p_seats is null or p_price is null then
    raise exception 'from, to, when, seats, price are required' using errcode = '22023';
  end if;

  -- split ts into date & time
  v_date := p_when::date;
  v_time := p_when::time;

  -- pick/create a demo driver (replace with auth later)
  select id into v_driver from public.users_app where role='driver' limit 1;
  if v_driver is null then
    insert into public.users_app (id, full_name, phone, role, is_verified)
    values (gen_random_uuid(), 'Demo Driver', '9000000001', 'driver', true)
    returning id into v_driver;
  end if;

  -- ensure route exists
  v_route := public.get_or_create_route(p_from, p_to);

  -- insert ride
  insert into public.rides(
    id, driver_id, route_id, depart_date, depart_time,
    price_per_seat_inr, seats_total, seats_available, status, allow_auto_confirm
  )
  values (
    gen_random_uuid(), v_driver, v_route, v_date, v_time,
    p_price, p_seats, p_seats, 'published', true
  )
  returning id into v_id;

  return jsonb_build_object('id', v_id::text);
end;
$$;


ALTER FUNCTION "public"."publish_ride_slim"("p_from" "text", "p_to" "text", "p_when" timestamp with time zone, "p_seats" integer, "p_price" integer, "p_pool" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."publish_ride_slim"("p_from" "text", "p_to" "text", "p_when" timestamp with time zone, "p_seats" integer, "p_price" integer, "p_pool" "text") IS 'Inserts a new ride row and returns {id}.';



CREATE OR REPLACE FUNCTION "public"."rides_normalize_before"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  -- FROM/TO safety
  if new."from" is null then new."from" := 'unknown'; end if;
  if new."to"   is null then new."to"   := 'unknown'; end if;

  -- Datetime trio: compose/decompose
  if new.start_time is null and new.depart_date is not null and new.depart_time is not null then
    new.start_time := (new.depart_date::text || ' ' || new.depart_time::text)::timestamptz;
  end if;
  if new.start_time is not null then
    if new.depart_date is null then new.depart_date := (new.start_time at time zone 'UTC')::date; end if;
    if new.depart_time is null then new.depart_time := (new.start_time at time zone 'UTC')::time; end if;
  end if;
  if new.start_time is null and new.depart_date is null and new.depart_time is null then
    new.start_time  := now();
    new.depart_date := now()::date;
    new.depart_time := now()::time;
  end if;

  -- Seats trio: seats, seats_total, seats_available
  if new.seats is null or new.seats < 1 then new.seats := null; end if;
  if new.seats_total is null or new.seats_total < 1 then new.seats_total := null; end if;

  if new.seats is not null then
    new.seats_total := coalesce(new.seats_total, new.seats, 1);
  elsif new.seats_total is not null then
    new.seats := coalesce(new.seats, new.seats_total, 1);
  else
    new.seats := 1;
    new.seats_total := 1;
  end if;

  -- seats_available default to seats_total (or seats)
  if new.seats_available is null or new.seats_available < 0 then
    new.seats_available := coalesce(new.seats_total, new.seats, 0);
  end if;
  -- clamp to valid range
  if new.seats_available > coalesce(new.seats_total, new.seats, new.seats_available) then
    new.seats_available := coalesce(new.seats_total, new.seats, new.seats_available);
  end if;
  if new.seats < 1 then new.seats := 1; end if;
  if new.seats_total < 1 then new.seats_total := 1; end if;
  if new.seats_available < 0 then new.seats_available := 0; end if;

  -- Price mirror
  if new.price_per_seat_inr is null or new.price_per_seat_inr < 0 then
    new.price_per_seat_inr := coalesce(new.price_inr, 0);
  end if;
  if new.price_inr is null or new.price_inr < 0 then
    new.price_inr := coalesce(new.price_per_seat_inr, 0);
  end if;

  -- Pool / commercial defaults
  if new.pool is null then new.pool := 'private'; end if;
  if new.is_commercial is null then new.is_commercial := false; end if;

  return new;
end $$;


ALTER FUNCTION "public"."rides_normalize_before"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."rides_set_depart_fields"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  -- If start_time missing but date+time present, compose it
  if new.start_time is null
     and new.depart_date is not null
     and new.depart_time is not null then
    new.start_time := (new.depart_date::text || ' ' || new.depart_time::text)::timestamptz;
  end if;

  -- If start_time present, backfill date/time if null
  if new.start_time is not null then
    if new.depart_date is null then
      new.depart_date := (new.start_time at time zone 'UTC')::date;
    end if;
    if new.depart_time is null then
      new.depart_time := (new.start_time at time zone 'UTC')::time;
    end if;
  end if;

  -- Final safety: if everything is still null, set all three to now()
  if new.start_time is null and new.depart_date is null and new.depart_time is null then
    new.start_time  := now();
    new.depart_date := now()::date;
    new.depart_time := now()::time;
  end if;

  return new;
end $$;


ALTER FUNCTION "public"."rides_set_depart_fields"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."rides_set_price_fields"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  -- If caller only sends price_inr, fill price_per_seat_inr automatically
  if new.price_per_seat_inr is null or new.price_per_seat_inr < 0 then
    new.price_per_seat_inr := coalesce(new.price_inr, 0);
  end if;

  -- Safety for seats
  if new.seats is null or new.seats < 1 then
    new.seats := 1;
  end if;

  return new;
end $$;


ALTER FUNCTION "public"."rides_set_price_fields"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."rides_sync_seats"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  -- Normalise values
  if new.seats is null or new.seats < 1 then
    new.seats := null; -- decide from seats_total below
  end if;
  if new.seats_total is null or new.seats_total < 1 then
    new.seats_total := null; -- decide from seats above
  end if;

  -- Prefer explicit seats; else use seats_total; fallback 1
  if new.seats is not null then
    new.seats_total := coalesce(new.seats_total, new.seats, 1);
  elsif new.seats_total is not null then
    new.seats := coalesce(new.seats, new.seats_total, 1);
  else
    new.seats := 1;
    new.seats_total := 1;
  end if;

  -- Final guard
  if new.seats < 1 then new.seats := 1; end if;
  if new.seats_total < 1 then new.seats_total := 1; end if;

  return new;
end $$;


ALTER FUNCTION "public"."rides_sync_seats"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_created_by"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  IF NEW.created_by IS NULL AND auth.uid() IS NOT NULL THEN
    NEW.created_by := auth.uid();
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_created_by"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_driver_id"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if new.driver_id is null then
    new.driver_id := auth.uid();
  end if;
  return new;
end $$;


ALTER FUNCTION "public"."set_driver_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_rides_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_rides_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."sync_price_inr"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  if NEW.price_inr is null then NEW.price_inr := NEW.price_per_seat_inr; end if;
  return NEW;
end $$;


ALTER FUNCTION "public"."sync_price_inr"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."trg_set_driver_id"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if new.driver_id is null then
    -- If the request is authenticated, this will be set; else stays null.
    new.driver_id := auth.uid();
  end if;

  -- Optional safety: if still null, allow insert (column is nullable now)
  return new;
end $$;


ALTER FUNCTION "public"."trg_set_driver_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  new.updated_at = now();
  return new;
end;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."bookings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "ride_id" "uuid" NOT NULL,
    "rider_id" "uuid" NOT NULL,
    "from_stop_id" "uuid" NOT NULL,
    "to_stop_id" "uuid" NOT NULL,
    "seats_booked" integer NOT NULL,
    "fare_total_inr" integer NOT NULL,
    "deposit_inr" integer NOT NULL,
    "status" "public"."booking_status" DEFAULT 'pending'::"public"."booking_status" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "deposit_status" "text" DEFAULT 'pending'::"text",
    "seats_requested" integer,
    "seats" integer,
    CONSTRAINT "bookings_deposit_inr_check" CHECK ((("deposit_inr")::numeric >= (0)::numeric)),
    CONSTRAINT "bookings_deposit_status_check" CHECK (("deposit_status" = ANY (ARRAY['pending'::"text", 'paid'::"text", 'refunded'::"text"]))),
    CONSTRAINT "bookings_fare_total_inr_check" CHECK ((("fare_total_inr")::numeric >= (0)::numeric)),
    CONSTRAINT "bookings_seats_booked_check" CHECK (("seats_booked" > 0)),
    CONSTRAINT "chk_from_to_diff" CHECK (("from_stop_id" <> "to_stop_id"))
);


ALTER TABLE "public"."bookings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."cancellations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "booking_id" "uuid" NOT NULL,
    "cancelled_by" "public"."cancellation_actor" NOT NULL,
    "cancelled_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "hours_before_depart" numeric(6,2),
    "penalty_inr" numeric(10,2) DEFAULT 0 NOT NULL,
    "note" "text"
);


ALTER TABLE "public"."cancellations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."cities" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "state" "text",
    "country" "text" DEFAULT 'India'::"text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "state_code" "text"
);


ALTER TABLE "public"."cities" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."conversations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "title" "text",
    "members" "uuid"[] NOT NULL,
    "last_text" "text",
    "created_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."conversations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."deposit_intents" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "amount_inr" integer NOT NULL,
    "method" "text" DEFAULT 'manual'::"text" NOT NULL,
    "status" "public"."deposit_status" DEFAULT 'created'::"public"."deposit_status" NOT NULL,
    "razorpay_order_id" "text",
    "razorpay_payment_id" "text",
    "razorpay_signature" "text",
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "deposit_intents_amount_inr_check" CHECK (("amount_inr" > 0))
);


ALTER TABLE "public"."deposit_intents" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."messages" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "conversation_id" "uuid",
    "sender_id" "uuid",
    "text" "text" NOT NULL,
    "ts" timestamp with time zone DEFAULT "now"(),
    "ride_id" "uuid",
    "recipient_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."messages" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."messages_compat" AS
 SELECT "id",
    "conversation_id",
    "sender_id",
    "text",
    "ts"
   FROM "public"."messages" "m";


ALTER VIEW "public"."messages_compat" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."payments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "booking_id" "uuid" NOT NULL,
    "provider" "text" DEFAULT 'razorpay'::"text" NOT NULL,
    "order_id" "text",
    "payment_id" "text",
    "amount_inr" numeric(10,2) NOT NULL,
    "status" "public"."payment_status" DEFAULT 'created'::"public"."payment_status" NOT NULL,
    "raw_payload" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "payments_amount_inr_check" CHECK (("amount_inr" >= (0)::numeric))
);


ALTER TABLE "public"."payments" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "email" "text",
    "name" "text",
    "phone" "text",
    "role" "text" DEFAULT 'rider'::"text",
    "created_at" timestamp without time zone DEFAULT "now"(),
    CONSTRAINT "profiles_role_check" CHECK (("role" = ANY (ARRAY['driver'::"text", 'rider'::"text", 'agency'::"text"])))
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."ride_allowed_stops" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "ride_id" "uuid" NOT NULL,
    "stop_id" "uuid" NOT NULL
);


ALTER TABLE "public"."ride_allowed_stops" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."rides_compat" AS
 SELECT ("id")::"text" AS "id",
    "from",
    "to",
    "start_time",
    "seats",
    "price_inr",
    "pool",
    "is_commercial",
    ("driver_id")::"text" AS "driver_id",
    "created_at"
   FROM "public"."rides";


ALTER VIEW "public"."rides_compat" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."rides_search_compat" AS
 SELECT "id",
    "from",
    "to",
    "start_time",
    "seats",
    "price_inr",
    "pool",
    "is_commercial",
    "driver_id",
    "created_at"
   FROM "public"."rides_compat";


ALTER VIEW "public"."rides_search_compat" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."route_stops" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "route_id" "uuid",
    "stop_name" "text" NOT NULL,
    "stop_order" integer NOT NULL
);


ALTER TABLE "public"."route_stops" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."routes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "origin" "text" NOT NULL,
    "destination" "text" NOT NULL
);


ALTER TABLE "public"."routes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."settlements" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "amount_inr" integer NOT NULL,
    "status" "public"."settlement_status" DEFAULT 'requested'::"public"."settlement_status" NOT NULL,
    "cycle_start" "date",
    "cycle_end" "date",
    "requested_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "processed_at" timestamp with time zone
);


ALTER TABLE "public"."settlements" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."stops" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "city_id" "uuid",
    "name" "text" NOT NULL,
    "latitude" numeric(9,6),
    "longitude" numeric(9,6),
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "geom" "public"."geometry"(Point,4326)
);


ALTER TABLE "public"."stops" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."users_app" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "full_name" "text" NOT NULL,
    "phone" "text" NOT NULL,
    "email" "text",
    "role" "public"."user_role" DEFAULT 'passenger'::"public"."user_role" NOT NULL,
    "avatar_url" "text",
    "is_verified" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."users_app" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."verifications" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "id_type" "text",
    "id_number" "text",
    "id_file_url" "text",
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "reviewed_by" "uuid",
    "reviewed_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."verifications" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."wallet_transactions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "tx_type" "public"."wallet_tx_type" NOT NULL,
    "amount_inr" integer NOT NULL,
    "ref_booking_id" "uuid",
    "note" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "wallet_transactions_amount_inr_check" CHECK (("amount_inr" <> 0))
);


ALTER TABLE "public"."wallet_transactions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."wallets" (
    "user_id" "uuid" NOT NULL,
    "balance_available_inr" integer DEFAULT 0 NOT NULL,
    "balance_reserved_inr" integer DEFAULT 0 NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."wallets" OWNER TO "postgres";


ALTER TABLE ONLY "public"."bookings"
    ADD CONSTRAINT "bookings_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."cancellations"
    ADD CONSTRAINT "cancellations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."cities"
    ADD CONSTRAINT "cities_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."cities"
    ADD CONSTRAINT "cities_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."conversations"
    ADD CONSTRAINT "conversations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."deposit_intents"
    ADD CONSTRAINT "deposit_intents_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."payments"
    ADD CONSTRAINT "payments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."ride_allowed_stops"
    ADD CONSTRAINT "ride_allowed_stops_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."ride_allowed_stops"
    ADD CONSTRAINT "ride_allowed_stops_ride_id_stop_id_key" UNIQUE ("ride_id", "stop_id");



ALTER TABLE ONLY "public"."rides"
    ADD CONSTRAINT "rides_driver_id_route_id_depart_date_depart_time_key" UNIQUE ("driver_id", "route_id", "depart_date", "depart_time");



ALTER TABLE ONLY "public"."rides"
    ADD CONSTRAINT "rides_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."route_stops"
    ADD CONSTRAINT "route_stops_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."routes"
    ADD CONSTRAINT "routes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."settlements"
    ADD CONSTRAINT "settlements_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."stops"
    ADD CONSTRAINT "stops_city_id_name_key" UNIQUE ("city_id", "name");



ALTER TABLE ONLY "public"."stops"
    ADD CONSTRAINT "stops_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."users_app"
    ADD CONSTRAINT "users_app_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."users_app"
    ADD CONSTRAINT "users_app_phone_key" UNIQUE ("phone");



ALTER TABLE ONLY "public"."users_app"
    ADD CONSTRAINT "users_app_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."verifications"
    ADD CONSTRAINT "verifications_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."wallet_transactions"
    ADD CONSTRAINT "wallet_transactions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."wallets"
    ADD CONSTRAINT "wallets_pkey" PRIMARY KEY ("user_id");



CREATE INDEX "idx_bookings_ride" ON "public"."bookings" USING "btree" ("ride_id");



CREATE INDEX "idx_bookings_rider" ON "public"."bookings" USING "btree" ("rider_id");



CREATE INDEX "idx_cancellations_booking" ON "public"."cancellations" USING "btree" ("booking_id");



CREATE INDEX "idx_deposit_status" ON "public"."deposit_intents" USING "btree" ("status");



CREATE INDEX "idx_deposit_user" ON "public"."deposit_intents" USING "btree" ("user_id");



CREATE INDEX "idx_messages_conv_ts" ON "public"."messages" USING "btree" ("conversation_id", "ts");



CREATE INDEX "idx_messages_ride" ON "public"."messages" USING "btree" ("ride_id");



CREATE INDEX "idx_messages_sender_recipient_created" ON "public"."messages" USING "btree" ("sender_id", "recipient_id", "created_at");



CREATE INDEX "idx_payments_booking" ON "public"."payments" USING "btree" ("booking_id");



CREATE INDEX "idx_payments_status" ON "public"."payments" USING "btree" ("status");



CREATE INDEX "idx_rides_driver" ON "public"."rides" USING "btree" ("driver_id");



CREATE INDEX "idx_rides_route_date" ON "public"."rides" USING "btree" ("route_id", "depart_date");



CREATE INDEX "idx_rides_route_datetime" ON "public"."rides" USING "btree" ("route_id", "depart_date", "depart_time");



CREATE INDEX "idx_settle_status" ON "public"."settlements" USING "btree" ("status");



CREATE INDEX "idx_settle_user" ON "public"."settlements" USING "btree" ("user_id");



CREATE INDEX "idx_stops_geom" ON "public"."stops" USING "gist" ("geom");



CREATE INDEX "idx_users_phone" ON "public"."users_app" USING "btree" ("phone");



CREATE INDEX "idx_verif_user" ON "public"."verifications" USING "btree" ("user_id");



CREATE OR REPLACE TRIGGER "trg_bookings_adjust_seats_del" AFTER DELETE ON "public"."bookings" FOR EACH ROW EXECUTE FUNCTION "public"."bookings_adjust_seats"();



CREATE OR REPLACE TRIGGER "trg_bookings_adjust_seats_ins" AFTER INSERT ON "public"."bookings" FOR EACH ROW EXECUTE FUNCTION "public"."bookings_adjust_seats"();



CREATE OR REPLACE TRIGGER "trg_rides_normalize_before" BEFORE INSERT OR UPDATE ON "public"."rides" FOR EACH ROW EXECUTE FUNCTION "public"."rides_normalize_before"();



CREATE OR REPLACE TRIGGER "trg_rides_seat_bounds" BEFORE INSERT OR UPDATE ON "public"."rides" FOR EACH ROW EXECUTE FUNCTION "public"."enforce_seats_bounds"();



CREATE OR REPLACE TRIGGER "trg_rides_set_created_by" BEFORE INSERT ON "public"."rides" FOR EACH ROW EXECUTE FUNCTION "public"."set_created_by"();



CREATE OR REPLACE TRIGGER "trg_rides_set_depart_fields" BEFORE INSERT OR UPDATE ON "public"."rides" FOR EACH ROW EXECUTE FUNCTION "public"."rides_set_depart_fields"();



CREATE OR REPLACE TRIGGER "trg_rides_set_price_fields" BEFORE INSERT OR UPDATE ON "public"."rides" FOR EACH ROW EXECUTE FUNCTION "public"."rides_set_price_fields"();



CREATE OR REPLACE TRIGGER "trg_rides_set_updated" BEFORE UPDATE ON "public"."rides" FOR EACH ROW EXECUTE FUNCTION "public"."set_rides_updated_at"();



CREATE OR REPLACE TRIGGER "trg_rides_sync_seats" BEFORE INSERT OR UPDATE ON "public"."rides" FOR EACH ROW EXECUTE FUNCTION "public"."rides_sync_seats"();



CREATE OR REPLACE TRIGGER "trg_set_driver_id" BEFORE INSERT ON "public"."rides" FOR EACH ROW EXECUTE FUNCTION "public"."trg_set_driver_id"();



CREATE OR REPLACE TRIGGER "trg_sync_price_inr" BEFORE INSERT ON "public"."rides" FOR EACH ROW EXECUTE FUNCTION "public"."sync_price_inr"();



CREATE OR REPLACE TRIGGER "update_profile_updated_at" BEFORE UPDATE ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



ALTER TABLE ONLY "public"."bookings"
    ADD CONSTRAINT "bookings_from_stop_id_fkey" FOREIGN KEY ("from_stop_id") REFERENCES "public"."stops"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."bookings"
    ADD CONSTRAINT "bookings_ride_id_fkey" FOREIGN KEY ("ride_id") REFERENCES "public"."rides"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."bookings"
    ADD CONSTRAINT "bookings_rider_id_fkey" FOREIGN KEY ("rider_id") REFERENCES "public"."users_app"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."bookings"
    ADD CONSTRAINT "bookings_to_stop_id_fkey" FOREIGN KEY ("to_stop_id") REFERENCES "public"."stops"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."cancellations"
    ADD CONSTRAINT "cancellations_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "public"."bookings"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."deposit_intents"
    ADD CONSTRAINT "deposit_intents_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users_app"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_conversation_id_fkey" FOREIGN KEY ("conversation_id") REFERENCES "public"."conversations"("id");



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_sender_id_fkey" FOREIGN KEY ("sender_id") REFERENCES "public"."profiles"("id");



ALTER TABLE ONLY "public"."payments"
    ADD CONSTRAINT "payments_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "public"."bookings"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."ride_allowed_stops"
    ADD CONSTRAINT "ride_allowed_stops_ride_id_fkey" FOREIGN KEY ("ride_id") REFERENCES "public"."rides"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."ride_allowed_stops"
    ADD CONSTRAINT "ride_allowed_stops_stop_id_fkey" FOREIGN KEY ("stop_id") REFERENCES "public"."stops"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."rides"
    ADD CONSTRAINT "rides_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."rides"
    ADD CONSTRAINT "rides_driver_id_fkey" FOREIGN KEY ("driver_id") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."route_stops"
    ADD CONSTRAINT "route_stops_route_id_fkey" FOREIGN KEY ("route_id") REFERENCES "public"."routes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."settlements"
    ADD CONSTRAINT "settlements_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users_app"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."stops"
    ADD CONSTRAINT "stops_city_id_fkey" FOREIGN KEY ("city_id") REFERENCES "public"."cities"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."verifications"
    ADD CONSTRAINT "verifications_reviewed_by_fkey" FOREIGN KEY ("reviewed_by") REFERENCES "public"."users_app"("id");



ALTER TABLE ONLY "public"."verifications"
    ADD CONSTRAINT "verifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users_app"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."wallet_transactions"
    ADD CONSTRAINT "wallet_transactions_ref_booking_id_fkey" FOREIGN KEY ("ref_booking_id") REFERENCES "public"."bookings"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."wallet_transactions"
    ADD CONSTRAINT "wallet_transactions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users_app"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."wallets"
    ADD CONSTRAINT "wallets_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users_app"("id") ON DELETE CASCADE;



CREATE POLICY "Individuals can edit their own profile" ON "public"."profiles" USING (("auth"."uid"() = "id"));



CREATE POLICY "Individuals can view their own profile" ON "public"."profiles" FOR SELECT USING (("auth"."uid"() = "id"));



CREATE POLICY "Users can update own wallet" ON "public"."wallets" FOR UPDATE TO "authenticated" USING (("user_id" = "auth"."uid"()));



CREATE POLICY "Users can view own wallet" ON "public"."wallets" FOR SELECT TO "authenticated" USING (("user_id" = "auth"."uid"()));



CREATE POLICY "booking_insert_self" ON "public"."bookings" FOR INSERT WITH CHECK (("rider_id" = "auth"."uid"()));



CREATE POLICY "booking_read_own" ON "public"."bookings" FOR SELECT USING ((("rider_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."rides" "r"
  WHERE (("r"."id" = "bookings"."ride_id") AND ("r"."driver_id" = "auth"."uid"()))))));



CREATE POLICY "booking_update_driver" ON "public"."bookings" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."rides" "r"
  WHERE (("r"."id" = "bookings"."ride_id") AND ("r"."driver_id" = "auth"."uid"())))));



ALTER TABLE "public"."bookings" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "insert_as_authenticated" ON "public"."rides" FOR INSERT WITH CHECK (("auth"."uid"() IS NOT NULL));



ALTER TABLE "public"."messages" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "read_own_messages" ON "public"."messages" FOR SELECT USING ((("sender_id" = "auth"."uid"()) OR ("recipient_id" = "auth"."uid"())));



CREATE POLICY "read_rides_public" ON "public"."rides" FOR SELECT USING (true);



ALTER TABLE "public"."rides" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "rides_insert_own" ON "public"."rides" FOR INSERT WITH CHECK ((("auth"."role"() = 'service_role'::"text") OR ("created_by" = "auth"."uid"())));



CREATE POLICY "rides_read_all" ON "public"."rides" FOR SELECT USING (true);



CREATE POLICY "rides_update_own" ON "public"."rides" FOR UPDATE USING ((("auth"."role"() = 'service_role'::"text") OR ("created_by" = "auth"."uid"())));



CREATE POLICY "send_as_self" ON "public"."messages" FOR INSERT WITH CHECK (("sender_id" = "auth"."uid"()));



ALTER TABLE "public"."wallets" ENABLE ROW LEVEL SECURITY;


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON FUNCTION "public"."_combine_ts"("d" "date", "t" time without time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."_combine_ts"("d" "date", "t" time without time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."_combine_ts"("d" "date", "t" time without time zone) TO "service_role";



REVOKE ALL ON FUNCTION "public"."api_book_ride"("p_ride_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."api_book_ride"("p_ride_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."api_book_ride"("p_ride_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."api_book_ride"("p_ride_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."app_book_ride"("p_ride_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."app_book_ride"("p_ride_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."app_book_ride"("p_ride_id" "uuid") TO "service_role";



GRANT ALL ON TABLE "public"."rides" TO "anon";
GRANT ALL ON TABLE "public"."rides" TO "authenticated";
GRANT ALL ON TABLE "public"."rides" TO "service_role";



GRANT ALL ON FUNCTION "public"."app_publish_ride"("p_from" "text", "p_to" "text", "p_when" timestamp with time zone, "p_seats" integer, "p_price_inr" integer, "p_pool" "text", "p_is_commercial" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."app_publish_ride"("p_from" "text", "p_to" "text", "p_when" timestamp with time zone, "p_seats" integer, "p_price_inr" integer, "p_pool" "text", "p_is_commercial" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."app_publish_ride"("p_from" "text", "p_to" "text", "p_when" timestamp with time zone, "p_seats" integer, "p_price_inr" integer, "p_pool" "text", "p_is_commercial" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."app_publish_ride"("p_from" "text", "p_to" "text", "p_when" timestamp with time zone, "p_seats" integer, "p_price" integer, "p_pool" "text", "p_driver_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."app_publish_ride"("p_from" "text", "p_to" "text", "p_when" timestamp with time zone, "p_seats" integer, "p_price" integer, "p_pool" "text", "p_driver_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."app_publish_ride"("p_from" "text", "p_to" "text", "p_when" timestamp with time zone, "p_seats" integer, "p_price" integer, "p_pool" "text", "p_driver_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."apply_deposit_penalty"("p_booking_id" "uuid", "p_cancelled_by" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."apply_deposit_penalty"("p_booking_id" "uuid", "p_cancelled_by" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."apply_deposit_penalty"("p_booking_id" "uuid", "p_cancelled_by" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."assert_seats_available"("p_ride" "uuid", "p_seats" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."assert_seats_available"("p_ride" "uuid", "p_seats" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."assert_seats_available"("p_ride" "uuid", "p_seats" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."book_ride_simple"("p_ride_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."book_ride_simple"("p_ride_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."book_ride_simple"("p_ride_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bookings_adjust_seats"() TO "anon";
GRANT ALL ON FUNCTION "public"."bookings_adjust_seats"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."bookings_adjust_seats"() TO "service_role";



GRANT ALL ON FUNCTION "public"."enforce_seats_bounds"() TO "anon";
GRANT ALL ON FUNCTION "public"."enforce_seats_bounds"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."enforce_seats_bounds"() TO "service_role";



GRANT ALL ON FUNCTION "public"."ensure_city"("_name" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."ensure_city"("_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."ensure_city"("_name" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."ensure_route"("_from_id" "uuid", "_to_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."ensure_route"("_from_id" "uuid", "_to_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."ensure_route"("_from_id" "uuid", "_to_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_or_create_city"("p_name" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_or_create_city"("p_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_or_create_city"("p_name" "text") TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_or_create_route"("p_from_city" "text", "p_to_city" "text") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_or_create_route"("p_from_city" "text", "p_to_city" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_or_create_route"("p_from_city" "text", "p_to_city" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_or_create_route"("p_from_city" "text", "p_to_city" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."public_ride_simple"("payload" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."public_ride_simple"("payload" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."public_ride_simple"("payload" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."public_ride_simple"("p_from" "text", "p_to" "text", "p_when" timestamp with time zone, "p_seats" integer, "p_price" integer, "p_notes" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."public_ride_simple"("p_from" "text", "p_to" "text", "p_when" timestamp with time zone, "p_seats" integer, "p_price" integer, "p_notes" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."public_ride_simple"("p_from" "text", "p_to" "text", "p_when" timestamp with time zone, "p_seats" integer, "p_price" integer, "p_notes" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."publish_ride_simple"("p_from_city" "text", "p_to_city" "text", "p_depart_at" timestamp with time zone, "p_seats_total" integer, "p_price_per_seat" integer, "p_notes" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."publish_ride_simple"("p_from_city" "text", "p_to_city" "text", "p_depart_at" timestamp with time zone, "p_seats_total" integer, "p_price_per_seat" integer, "p_notes" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."publish_ride_simple"("p_from_city" "text", "p_to_city" "text", "p_depart_at" timestamp with time zone, "p_seats_total" integer, "p_price_per_seat" integer, "p_notes" "text") TO "service_role";



REVOKE ALL ON FUNCTION "public"."publish_ride_slim"("p_from" "text", "p_to" "text", "p_when" timestamp with time zone, "p_seats" integer, "p_price" integer, "p_pool" "text") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."publish_ride_slim"("p_from" "text", "p_to" "text", "p_when" timestamp with time zone, "p_seats" integer, "p_price" integer, "p_pool" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."publish_ride_slim"("p_from" "text", "p_to" "text", "p_when" timestamp with time zone, "p_seats" integer, "p_price" integer, "p_pool" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."publish_ride_slim"("p_from" "text", "p_to" "text", "p_when" timestamp with time zone, "p_seats" integer, "p_price" integer, "p_pool" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."rides_normalize_before"() TO "anon";
GRANT ALL ON FUNCTION "public"."rides_normalize_before"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."rides_normalize_before"() TO "service_role";



GRANT ALL ON FUNCTION "public"."rides_set_depart_fields"() TO "anon";
GRANT ALL ON FUNCTION "public"."rides_set_depart_fields"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."rides_set_depart_fields"() TO "service_role";



GRANT ALL ON FUNCTION "public"."rides_set_price_fields"() TO "anon";
GRANT ALL ON FUNCTION "public"."rides_set_price_fields"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."rides_set_price_fields"() TO "service_role";



GRANT ALL ON FUNCTION "public"."rides_sync_seats"() TO "anon";
GRANT ALL ON FUNCTION "public"."rides_sync_seats"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."rides_sync_seats"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_created_by"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_created_by"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_created_by"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_driver_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_driver_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_driver_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_rides_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_rides_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_rides_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."sync_price_inr"() TO "anon";
GRANT ALL ON FUNCTION "public"."sync_price_inr"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_price_inr"() TO "service_role";



GRANT ALL ON FUNCTION "public"."trg_set_driver_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."trg_set_driver_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."trg_set_driver_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "service_role";



GRANT ALL ON TABLE "public"."bookings" TO "anon";
GRANT ALL ON TABLE "public"."bookings" TO "authenticated";
GRANT ALL ON TABLE "public"."bookings" TO "service_role";



GRANT ALL ON TABLE "public"."cancellations" TO "anon";
GRANT ALL ON TABLE "public"."cancellations" TO "authenticated";
GRANT ALL ON TABLE "public"."cancellations" TO "service_role";



GRANT ALL ON TABLE "public"."cities" TO "anon";
GRANT ALL ON TABLE "public"."cities" TO "authenticated";
GRANT ALL ON TABLE "public"."cities" TO "service_role";



GRANT ALL ON TABLE "public"."conversations" TO "anon";
GRANT ALL ON TABLE "public"."conversations" TO "authenticated";
GRANT ALL ON TABLE "public"."conversations" TO "service_role";



GRANT ALL ON TABLE "public"."deposit_intents" TO "anon";
GRANT ALL ON TABLE "public"."deposit_intents" TO "authenticated";
GRANT ALL ON TABLE "public"."deposit_intents" TO "service_role";



GRANT ALL ON TABLE "public"."messages" TO "anon";
GRANT ALL ON TABLE "public"."messages" TO "authenticated";
GRANT ALL ON TABLE "public"."messages" TO "service_role";



GRANT ALL ON TABLE "public"."messages_compat" TO "anon";
GRANT ALL ON TABLE "public"."messages_compat" TO "authenticated";
GRANT ALL ON TABLE "public"."messages_compat" TO "service_role";



GRANT ALL ON TABLE "public"."payments" TO "anon";
GRANT ALL ON TABLE "public"."payments" TO "authenticated";
GRANT ALL ON TABLE "public"."payments" TO "service_role";



GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";



GRANT ALL ON TABLE "public"."ride_allowed_stops" TO "anon";
GRANT ALL ON TABLE "public"."ride_allowed_stops" TO "authenticated";
GRANT ALL ON TABLE "public"."ride_allowed_stops" TO "service_role";



GRANT ALL ON TABLE "public"."rides_compat" TO "anon";
GRANT ALL ON TABLE "public"."rides_compat" TO "authenticated";
GRANT ALL ON TABLE "public"."rides_compat" TO "service_role";



GRANT ALL ON TABLE "public"."rides_search_compat" TO "anon";
GRANT ALL ON TABLE "public"."rides_search_compat" TO "authenticated";
GRANT ALL ON TABLE "public"."rides_search_compat" TO "service_role";



GRANT ALL ON TABLE "public"."route_stops" TO "anon";
GRANT ALL ON TABLE "public"."route_stops" TO "authenticated";
GRANT ALL ON TABLE "public"."route_stops" TO "service_role";



GRANT ALL ON TABLE "public"."routes" TO "anon";
GRANT ALL ON TABLE "public"."routes" TO "authenticated";
GRANT ALL ON TABLE "public"."routes" TO "service_role";



GRANT ALL ON TABLE "public"."settlements" TO "anon";
GRANT ALL ON TABLE "public"."settlements" TO "authenticated";
GRANT ALL ON TABLE "public"."settlements" TO "service_role";



GRANT ALL ON TABLE "public"."stops" TO "anon";
GRANT ALL ON TABLE "public"."stops" TO "authenticated";
GRANT ALL ON TABLE "public"."stops" TO "service_role";



GRANT ALL ON TABLE "public"."users_app" TO "anon";
GRANT ALL ON TABLE "public"."users_app" TO "authenticated";
GRANT ALL ON TABLE "public"."users_app" TO "service_role";



GRANT ALL ON TABLE "public"."verifications" TO "anon";
GRANT ALL ON TABLE "public"."verifications" TO "authenticated";
GRANT ALL ON TABLE "public"."verifications" TO "service_role";



GRANT ALL ON TABLE "public"."wallet_transactions" TO "anon";
GRANT ALL ON TABLE "public"."wallet_transactions" TO "authenticated";
GRANT ALL ON TABLE "public"."wallet_transactions" TO "service_role";



GRANT ALL ON TABLE "public"."wallets" TO "anon";
GRANT ALL ON TABLE "public"."wallets" TO "authenticated";
GRANT ALL ON TABLE "public"."wallets" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";






RESET ALL;
