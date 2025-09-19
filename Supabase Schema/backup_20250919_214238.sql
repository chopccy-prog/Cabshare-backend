--
-- PostgreSQL database dump
--

\restrict Y1CwXzZRaGKrzH8jz2h6snFjJAU9H2w2nBvM4CnHOit54pnTGabsNX2LXQfDKPh

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA auth;


--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA extensions;


--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql;


--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql_public;


--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pgbouncer;


--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA realtime;


--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA storage;


--
-- Name: supabase_migrations; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA supabase_migrations;


--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA vault;


--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_graphql WITH SCHEMA graphql;


--
-- Name: EXTENSION pg_graphql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_graphql IS 'pg_graphql: GraphQL support';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


--
-- Name: oauth_registration_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_registration_type AS ENUM (
    'dynamic',
    'manual'
);


--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


--
-- Name: booking_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.booking_status AS ENUM (
    'pending',
    'confirmed',
    'cancelled',
    'completed'
);


--
-- Name: cancellation_actor; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.cancellation_actor AS ENUM (
    'driver',
    'rider',
    'system'
);


--
-- Name: deposit_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.deposit_status AS ENUM (
    'created',
    'paid',
    'failed',
    'refunded',
    'cancelled',
    'expired'
);


--
-- Name: payment_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.payment_status AS ENUM (
    'created',
    'authorized',
    'captured',
    'refunded',
    'failed'
);


--
-- Name: ride_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.ride_status AS ENUM (
    'published',
    'cancelled',
    'completed'
);


--
-- Name: settlement_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.settlement_status AS ENUM (
    'requested',
    'processing',
    'paid',
    'rejected'
);


--
-- Name: user_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_role AS ENUM (
    'passenger',
    'driver',
    'admin',
    'rider'
);


--
-- Name: wallet_tx_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.wallet_tx_type AS ENUM (
    'reserve',
    'release',
    'transfer_in',
    'transfer_out',
    'adjustment'
);


--
-- Name: action; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


--
-- Name: buckettype; Type: TYPE; Schema: storage; Owner: -
--

CREATE TYPE storage.buckettype AS ENUM (
    'STANDARD',
    'ANALYTICS'
);


--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$_$;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    IF EXISTS (
      SELECT FROM pg_extension
      WHERE extname = 'pg_net'
      -- all versions in use on existing projects as of 2025-02-20
      -- version 0.12.0 onwards don't need these applied
      AND extversion IN ('0.2', '0.6', '0.7', '0.7.1', '0.8', '0.10.0', '0.11.0')
    ) THEN
      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

      REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
      REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

      GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
      GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    END IF;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: -
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $_$
begin
    raise debug 'PgBouncer auth request: %', p_usename;

    return query
    select 
        rolname::text, 
        case when rolvaliduntil < now() 
            then null 
            else rolpassword::text 
        end 
    from pg_authid 
    where rolname=$1 and rolcanlogin;
end;
$_$;


--
-- Name: _combine_ts(date, time without time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._combine_ts(d date, t time without time zone) RETURNS timestamp with time zone
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $$
  select (d::timestamptz + (t::text)::interval);
$$;


--
-- Name: FUNCTION _combine_ts(d date, t time without time zone); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public._combine_ts(d date, t time without time zone) IS 'Combine date + time columns to a timestamptz.';


--
-- Name: add_route_new(text, uuid, uuid, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.add_route_new(p_name text, p_from_city_id uuid, p_to_city_id uuid, p_distance_km integer DEFAULT NULL::integer, p_estimated_duration_minutes integer DEFAULT NULL::integer) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
DECLARE
    new_route_id UUID;
    from_city_name TEXT;
    to_city_name TEXT;
BEGIN
    SELECT name INTO from_city_name FROM cities WHERE id = p_from_city_id;
    SELECT name INTO to_city_name FROM cities WHERE id = p_to_city_id;
    
    INSERT INTO routes (
        name, origin, destination, 
        from_city_id, to_city_id,
        distance_km, estimated_duration_minutes,
        is_active
    )
    VALUES (
        p_name, from_city_name, to_city_name,
        p_from_city_id, p_to_city_id,
        p_distance_km, p_estimated_duration_minutes,
        true
    )
    RETURNING id INTO new_route_id;
    
    RETURN new_route_id;
END;
$$;


--
-- Name: add_stop_new(uuid, text, integer, text, text, boolean, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.add_stop_new(p_route_id uuid, p_name text, p_stop_order integer, p_address text DEFAULT NULL::text, p_city_name text DEFAULT NULL::text, p_is_pickup boolean DEFAULT true, p_is_drop boolean DEFAULT true) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
DECLARE
    new_stop_id UUID;
BEGIN
    INSERT INTO stops (
        route_id, name, address, city_name,
        stop_order, is_pickup, is_drop, is_active
    )
    VALUES (
        p_route_id, p_name, p_address, p_city_name,
        p_stop_order, p_is_pickup, p_is_drop, true
    )
    RETURNING id INTO new_stop_id;
    
    RETURN new_stop_id;
END;
$$;


--
-- Name: add_wallet_balance(uuid, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.add_wallet_balance(p_user_id uuid, p_amount integer, p_note text DEFAULT 'Wallet deposit'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- Insert or update wallet
  INSERT INTO wallets (user_id, balance_available_inr, balance_reserved_inr)
  VALUES (p_user_id, p_amount, 0)
  ON CONFLICT (user_id) 
  DO UPDATE SET 
    balance_available_inr = wallets.balance_available_inr + p_amount,
    updated_at = NOW();

  -- Record transaction
  INSERT INTO wallet_transactions (
    user_id, type, amount_inr, description, created_at
  ) VALUES (
    p_user_id, 'deposit', p_amount, p_note, NOW()
  );
END;
$$;


--
-- Name: api_book_ride(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.api_book_ride(p_ride_id uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
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


--
-- Name: FUNCTION api_book_ride(p_ride_id uuid); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.api_book_ride(p_ride_id uuid) IS 'Atomically decrements seats_available and returns {id, seats}.';


--
-- Name: app_book_ride(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.app_book_ride(p_ride_id uuid) RETURNS TABLE(id uuid, "from" text, "to" text, "when" timestamp without time zone, seats integer, price integer, pool text, booked boolean, "driverName" text, "driverPhone" text)
    LANGUAGE plpgsql
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


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: rides; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rides (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    driver_id uuid,
    route_id uuid,
    depart_date date,
    depart_time time without time zone NOT NULL,
    price_per_seat_inr integer,
    seats_total integer,
    seats_available integer,
    car_make text,
    car_model text,
    car_plate text,
    notes text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    status public.ride_status DEFAULT 'published'::public.ride_status NOT NULL,
    allow_auto_confirm boolean DEFAULT true NOT NULL,
    created_by uuid,
    is_commercial boolean DEFAULT false,
    allow_auto_book boolean,
    ride_type text,
    from_city_id uuid,
    to_city_id uuid,
    selected_pickup_stops uuid[] DEFAULT '{}'::uuid[],
    selected_drop_stops uuid[] DEFAULT '{}'::uuid[],
    "from" text,
    "to" text,
    pickup_stop_id uuid,
    drop_stop_id uuid,
    vehicle_type character varying(20) DEFAULT 'private'::character varying,
    vehicle_make character varying(100),
    vehicle_model character varying(100),
    vehicle_plate character varying(20),
    additional_notes text,
    requires_deposit boolean DEFAULT false,
    deposit_amount numeric(10,2) DEFAULT 0,
    auto_approve_bookings boolean DEFAULT false,
    auto_approve boolean DEFAULT true,
    CONSTRAINT rides_price_per_seat_inr_check CHECK (((price_per_seat_inr)::numeric >= (0)::numeric)),
    CONSTRAINT rides_ride_type_check CHECK ((ride_type = ANY (ARRAY['private_pool'::text, 'commercial_pool'::text, 'commercial_full'::text]))),
    CONSTRAINT rides_seats_available_check CHECK ((seats_available >= 0)),
    CONSTRAINT rides_seats_total_check CHECK ((seats_total > 0))
);


--
-- Name: app_publish_ride(text, text, timestamp with time zone, integer, integer, text, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.app_publish_ride(p_from text, p_to text, p_when timestamp with time zone, p_seats integer DEFAULT 1, p_price_inr integer DEFAULT 0, p_pool text DEFAULT 'private'::text, p_is_commercial boolean DEFAULT false) RETURNS public.rides
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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


--
-- Name: app_publish_ride(text, text, timestamp with time zone, integer, integer, text, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.app_publish_ride(p_from text, p_to text, p_when timestamp with time zone, p_seats integer, p_price integer, p_pool text DEFAULT 'private'::text, p_driver_id uuid DEFAULT NULL::uuid) RETURNS TABLE(id uuid, "from" text, "to" text, "when" timestamp without time zone, seats integer, price integer, pool text, booked boolean, "driverName" text, "driverPhone" text)
    LANGUAGE plpgsql
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


--
-- Name: apply_cancellation_penalty(uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.apply_cancellation_penalty(p_booking_id uuid, p_cancelled_by text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_penalty_calc jsonb;
    v_booking RECORD;
    v_ride RECORD;
    v_penalty_amount numeric;
    v_from_user_id uuid;
    v_to_user_id uuid;
BEGIN
    -- Calculate penalty details
    v_penalty_calc := public.calculate_cancellation_penalty(p_booking_id, p_cancelled_by);
    v_penalty_amount := (v_penalty_calc->>'penalty_amount')::numeric;
    
    IF v_penalty_amount <= 0 THEN
        RETURN v_penalty_calc;
    END IF;
    
    -- Get booking and ride details
    SELECT * INTO v_booking FROM bookings WHERE id = p_booking_id;
    SELECT * INTO v_ride FROM rides WHERE id = v_booking.ride_id;
    
    -- Determine who pays and who receives the penalty
    IF p_cancelled_by = 'rider' THEN
        v_from_user_id := v_booking.rider_id;
        v_to_user_id := v_ride.driver_id;
    ELSE -- driver cancels
        v_from_user_id := v_ride.driver_id;
        v_to_user_id := v_booking.rider_id;
    END IF;
    
    -- Apply penalty: deduct from canceller, add to other party (if wallets table exists)
    BEGIN
        UPDATE wallets
        SET balance_available_inr = balance_available_inr - v_penalty_amount::integer,
            updated_at = now()
        WHERE user_id = v_from_user_id;
        
        UPDATE wallets
        SET balance_available_inr = balance_available_inr + v_penalty_amount::integer,
            updated_at = now()
        WHERE user_id = v_to_user_id;
        
        -- Log transactions (if wallet_transactions table exists)
        INSERT INTO wallet_transactions (user_id, tx_type, amount_inr, ref_booking_id, note)
        VALUES 
            (v_from_user_id, 'transfer_out', -v_penalty_amount::integer, p_booking_id, 
             'Cancellation penalty - ' || p_cancelled_by || ' cancelled'),
            (v_to_user_id, 'transfer_in', v_penalty_amount::integer, p_booking_id,
             'Cancellation compensation - other party cancelled');
    EXCEPTION
        WHEN undefined_table THEN
            -- Wallets table doesn't exist, just log the penalty calculation
            NULL;
    END;
    
    -- Record the cancellation (if cancellations table exists)
    BEGIN
        INSERT INTO cancellations (booking_id, cancelled_by, hours_before_depart, penalty_inr, note)
        VALUES (
            p_booking_id,
            p_cancelled_by::cancellation_actor,
            (v_penalty_calc->>'hours_before_departure')::numeric,
            v_penalty_amount,
            'Applied ' || (v_penalty_calc->>'penalty_percentage') || '% penalty'
        );
    EXCEPTION
        WHEN undefined_table OR invalid_text_representation THEN
            -- Cancellations table doesn't exist or enum type issue, skip
            NULL;
    END;
    
    RETURN v_penalty_calc;
END;
$$;


--
-- Name: apply_deposit_penalty(uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.apply_deposit_penalty(p_booking_id uuid, p_cancelled_by text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Use the new penalty system
    PERFORM public.apply_cancellation_penalty(p_booking_id, p_cancelled_by);
END;
$$;


--
-- Name: assert_seats_available(uuid, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.assert_seats_available(p_ride uuid, p_seats integer) RETURNS void
    LANGUAGE plpgsql
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


--
-- Name: book_ride_simple(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.book_ride_simple(p_ride_id uuid) RETURNS TABLE(id uuid, seats_remaining integer)
    LANGUAGE plpgsql
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


--
-- Name: book_seat(uuid, uuid, integer, uuid, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.book_seat(p_ride_id uuid, p_rider_id uuid, p_seats integer, p_from_stop_id uuid, p_to_stop_id uuid) RETURNS json
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
declare
  _auto boolean;
  _avail int;
  _driver uuid;
  _booking uuid;
  _thread uuid;
  _status booking_status; -- << enum, not text
begin
  if p_from_stop_id is null or p_to_stop_id is null then
    raise exception 'from_stop_id and to_stop_id are required';
  end if;

  -- Optional: enforce forward direction on the route (pickup before drop)
  -- If you don't store seq on stops at booking time, skip this guard.

  select r.auto_approve, r.seats_available, r.driver_id
  into _auto, _avail, _driver
  from public.rides r
  where r.id = p_ride_id
  for update;

  if _avail is null or _avail < p_seats then
    raise exception 'Not enough seats available';
  end if;

  _status := case when _auto then 'confirmed'::booking_status else 'pending'::booking_status end;

  insert into public.bookings(ride_id, rider_id, seats, status, from_stop_id, to_stop_id)
  values (p_ride_id, p_rider_id, p_seats, _status, p_from_stop_id, p_to_stop_id)
  returning id into _booking;

  if (_auto) then
    update public.rides set seats_available = seats_available - p_seats where id = p_ride_id;

    insert into public.inbox_threads(ride_id, rider_id, driver_id)
    values (p_ride_id, p_rider_id, _driver) returning id into _thread;

    insert into public.inbox_messages(thread_id, sender_id, body, meta)
    values (_thread, _driver, 'Booking confirmed',
            jsonb_build_object('booking_id', _booking, 'ride_id', p_ride_id));
  else
    insert into public.notifications(user_id, title, body, data)
    values (_driver, 'Booking request', 'Approve/Reject the booking from a rider',
            jsonb_build_object('booking_id', _booking, 'ride_id', p_ride_id));
  end if;

  return json_build_object('booking_id', _booking, 'status', _status, 'thread_id', _thread);
end;
$$;


--
-- Name: calculate_cancellation_penalty(uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calculate_cancellation_penalty(p_booking_id uuid, p_cancelled_by text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_booking RECORD;
    v_ride RECORD;
    v_hours_before numeric;
    v_penalty_pct numeric;
    v_policy RECORD;
    v_deposit_amount numeric;
    v_penalty_amount numeric;
BEGIN
    -- Get booking details
    SELECT * INTO v_booking 
    FROM bookings 
    WHERE id = p_booking_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Booking not found';
    END IF;
    
    -- Get ride details
    SELECT r.*, 
           CASE 
               WHEN r.is_commercial = true AND r.pool = 'commercial_full' THEN 'commercial_full'
               WHEN r.is_commercial = true THEN 'commercial'
               ELSE 'private'
           END as determined_ride_type
    INTO v_ride
    FROM rides r
    WHERE r.id = v_booking.ride_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Ride not found';
    END IF;
    
    -- Calculate hours before departure
    v_hours_before := EXTRACT(EPOCH FROM 
        (v_ride.depart_date + v_ride.depart_time) - NOW()
    ) / 3600;
    
    -- Get the applicable policy (try unified 'both' policy first)
    SELECT * INTO v_policy
    FROM cancellation_policies
    WHERE ride_type = v_ride.determined_ride_type
      AND actor = 'both'
      AND is_active = true
    LIMIT 1;
    
    IF NOT FOUND THEN
        -- Fallback to old separate policies if 'both' doesn't exist
        SELECT * INTO v_policy
        FROM cancellation_policies
        WHERE ride_type = v_ride.determined_ride_type
          AND actor = p_cancelled_by
          AND is_active = true
        LIMIT 1;
    END IF;
    
    IF NOT FOUND THEN
        -- Default fallback policy
        v_policy.penalty_percentage_1 := 20;
        v_policy.penalty_percentage_2 := 40; 
        v_policy.penalty_percentage_3 := 60;
        v_policy.hours_threshold_1 := 12;
        v_policy.hours_threshold_2 := 6;
        v_policy.hours_threshold_3 := 0;
    END IF;
    
    -- Determine penalty percentage based on time before departure
    IF v_hours_before >= v_policy.hours_threshold_1 THEN
        v_penalty_pct := v_policy.penalty_percentage_1;
    ELSIF v_hours_before >= v_policy.hours_threshold_2 THEN
        v_penalty_pct := v_policy.penalty_percentage_2;
    ELSE
        v_penalty_pct := v_policy.penalty_percentage_3;
    END IF;
    
    -- Calculate penalty amount
    v_deposit_amount := COALESCE(v_booking.deposit_inr, 0);
    v_penalty_amount := ROUND((v_deposit_amount * v_penalty_pct / 100.0)::numeric, 2);
    
    RETURN jsonb_build_object(
        'booking_id', p_booking_id,
        'ride_type', v_ride.determined_ride_type,
        'cancelled_by', p_cancelled_by,
        'hours_before_departure', ROUND(v_hours_before, 2),
        'penalty_percentage', v_penalty_pct,
        'deposit_amount', v_deposit_amount,
        'penalty_amount', v_penalty_amount,
        'policy_applied', row_to_json(v_policy)
    );
END;
$$;


--
-- Name: calculate_cancellation_penalty(uuid, text, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calculate_cancellation_penalty(p_booking_id uuid, p_cancelled_by text, p_cancelled_at timestamp with time zone DEFAULT now()) RETURNS TABLE(penalty_amount_inr integer, penalty_percentage numeric, hours_before_departure numeric, policy_applied uuid, penalty_recipient_id uuid)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_ride_record RECORD;
    v_booking_record RECORD;
    v_policy_record RECORD;
    v_departure_time TIMESTAMPTZ;
    v_hours_before DECIMAL(10,2);
    v_penalty_pct DECIMAL(5,2) := 0.00;
    v_deposit_amount INTEGER := 0;
    v_recipient_id UUID;
BEGIN
    -- Get booking and ride details
    SELECT b.*, r.ride_type, r.depart_date, r.depart_time, r.driver_id
    INTO v_booking_record
    FROM bookings b
    JOIN rides r ON b.ride_id = r.id
    WHERE b.id = p_booking_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Booking not found: %', p_booking_id;
    END IF;
    
    -- Calculate departure time
    v_departure_time := (v_booking_record.depart_date || ' ' || v_booking_record.depart_time)::TIMESTAMPTZ;
    
    -- Calculate hours before departure
    v_hours_before := EXTRACT(EPOCH FROM (v_departure_time - p_cancelled_at)) / 3600;
    
    -- Get applicable cancellation policy
    SELECT * INTO v_policy_record
    FROM cancellation_policies
    WHERE ride_type = v_booking_record.ride_type
      AND actor = p_cancelled_by
      AND is_active = true;
    
    IF NOT FOUND THEN
        -- Default to 0% penalty if no policy found
        v_penalty_pct := 0.00;
    ELSE
        -- Apply tiered penalty based on hours before departure
        IF v_hours_before >= v_policy_record.hours_threshold_1 THEN
            v_penalty_pct := v_policy_record.penalty_percentage_1;
        ELSIF v_hours_before >= v_policy_record.hours_threshold_2 THEN
            v_penalty_pct := v_policy_record.penalty_percentage_2;
        ELSE
            v_penalty_pct := v_policy_record.penalty_percentage_3;
        END IF;
    END IF;
    
    -- Get deposit amount (from booking_deposits or booking record)
    SELECT COALESCE(bd.deposit_amount_inr, b.rider_deposit_inr, 0)
    INTO v_deposit_amount
    FROM bookings b
    LEFT JOIN booking_deposits bd ON b.id = bd.booking_id
    WHERE b.id = p_booking_id;
    
    -- Determine penalty recipient
    IF p_cancelled_by = 'driver' THEN
        v_recipient_id := v_booking_record.rider_id;
    ELSIF p_cancelled_by = 'rider' THEN
        v_recipient_id := v_booking_record.driver_id;
    ELSE
        v_recipient_id := NULL; -- System cancellation
    END IF;
    
    -- Return calculated values
    RETURN QUERY SELECT 
        (v_deposit_amount * v_penalty_pct / 100)::INTEGER as penalty_amount_inr,
        v_penalty_pct as penalty_percentage,
        v_hours_before as hours_before_departure,
        v_policy_record.id as policy_applied,
        v_recipient_id as penalty_recipient_id;
END;
$$;


--
-- Name: calculate_cancellation_penalty_preview(uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calculate_cancellation_penalty_preview(p_booking_id uuid, p_cancelled_by text DEFAULT 'rider'::text) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_booking record;
  v_ride_depart_date date;
  v_ride_depart_time time;
  v_ride_type text;
  v_hours_until_departure numeric;
  v_penalty_rate integer := 0;
  v_penalty_amount integer := 0;
  v_refund_amount integer := 0;
BEGIN
  -- Get booking details
  SELECT * INTO v_booking
  FROM bookings 
  WHERE id = p_booking_id;

  IF v_booking.id IS NULL THEN
    RAISE EXCEPTION 'Booking not found';
  END IF;

  -- Get ride details separately
  SELECT depart_date, depart_time, ride_type
  INTO v_ride_depart_date, v_ride_depart_time, v_ride_type
  FROM rides 
  WHERE id = v_booking.ride_id;

  -- Calculate hours until departure
  v_hours_until_departure := EXTRACT(EPOCH FROM 
    (v_ride_depart_date + v_ride_depart_time - NOW())
  ) / 3600;

  -- Get penalty rate from policy or use default
  SELECT CASE 
    WHEN v_hours_until_departure >= 12 THEN COALESCE(hours_12_plus, 0)
    WHEN v_hours_until_departure >= 6 THEN COALESCE(hours_6_to_12, 30)
    ELSE COALESCE(hours_0_to_6, 50)
  END INTO v_penalty_rate
  FROM cancellation_policies 
  WHERE ride_type = v_ride_type
  LIMIT 1;

  -- Use default rates if no policy found
  IF v_penalty_rate IS NULL THEN
    IF v_hours_until_departure >= 12 THEN
      v_penalty_rate := 0;
    ELSIF v_hours_until_departure >= 6 THEN
      v_penalty_rate := 30;
    ELSE
      v_penalty_rate := 50;
    END IF;
  END IF;

  -- Calculate amounts
  IF p_cancelled_by = 'rider' THEN
    v_penalty_amount := FLOOR(v_booking.deposit_inr * v_penalty_rate / 100);
    v_refund_amount := v_booking.deposit_inr - v_penalty_amount;
  ELSE
    -- Driver cancellation - no penalty for rider
    v_penalty_amount := 0;
    v_refund_amount := v_booking.deposit_inr;
  END IF;

  RETURN json_build_object(
    'booking_id', p_booking_id,
    'hours_until_departure', ROUND(v_hours_until_departure, 2),
    'penalty_rate', v_penalty_rate,
    'deposit_amount', v_booking.deposit_inr,
    'penalty_amount', v_penalty_amount,
    'refund_amount', v_refund_amount,
    'cancelled_by', p_cancelled_by
  );
END;
$$;


--
-- Name: cancel_booking_with_penalty(uuid, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cancel_booking_with_penalty(p_booking_id uuid, p_cancelled_by_user_id uuid) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_booking record;
  v_ride_driver_id uuid;
  v_ride_depart_date date;
  v_ride_depart_time time;
  v_ride_type text;
  v_penalty_rate integer := 0;
  v_penalty_amount integer := 0;
  v_refund_amount integer := 0;
  v_hours_until_departure numeric;
  v_is_rider boolean := false;
  v_is_driver boolean := false;
  v_result json;
BEGIN
  -- Get booking details (FIXED: Separate queries to avoid multiple record INTO)
  SELECT * INTO v_booking
  FROM bookings 
  WHERE id = p_booking_id;

  -- Validate booking exists
  IF v_booking.id IS NULL THEN
    RAISE EXCEPTION 'Booking not found';
  END IF;

  -- Get ride details separately
  SELECT driver_id, depart_date, depart_time, ride_type
  INTO v_ride_driver_id, v_ride_depart_date, v_ride_depart_time, v_ride_type
  FROM rides 
  WHERE id = v_booking.ride_id;

  -- Check if booking can be cancelled
  IF v_booking.status IN ('cancelled', 'completed') THEN
    RAISE EXCEPTION 'Booking cannot be cancelled (status: %)', v_booking.status;
  END IF;

  -- Check user authorization
  v_is_rider := (v_booking.rider_id = p_cancelled_by_user_id);
  v_is_driver := (v_ride_driver_id = p_cancelled_by_user_id);

  IF NOT (v_is_rider OR v_is_driver) THEN
    RAISE EXCEPTION 'Unauthorized to cancel this booking';
  END IF;

  -- Calculate hours until departure
  v_hours_until_departure := EXTRACT(EPOCH FROM 
    (v_ride_depart_date + v_ride_depart_time - NOW())
  ) / 3600;

  -- Calculate penalty rate based on cancellation policy
  IF v_hours_until_departure >= 12 THEN
    v_penalty_rate := 0;
  ELSIF v_hours_until_departure >= 6 THEN
    v_penalty_rate := 30;
  ELSE
    v_penalty_rate := 50;
  END IF;

  -- Calculate penalty amount (only for rider cancellations)
  IF v_is_rider THEN
    v_penalty_amount := FLOOR(v_booking.deposit_inr * v_penalty_rate / 100);
    v_refund_amount := v_booking.deposit_inr - v_penalty_amount;
  ELSE
    -- Driver cancellation - full refund to rider
    v_penalty_amount := 0;
    v_refund_amount := v_booking.deposit_inr;
  END IF;

  -- Update booking status
  UPDATE bookings 
  SET status = 'cancelled', updated_at = NOW()
  WHERE id = p_booking_id;

  -- Handle deposit and penalties
  IF v_penalty_amount > 0 AND v_is_rider THEN
    -- Transfer penalty to driver
    UPDATE wallets 
    SET balance_available_inr = balance_available_inr + v_penalty_amount
    WHERE user_id = v_ride_driver_id;

    -- Record penalty transaction for driver
    INSERT INTO wallet_transactions (
      user_id, type, amount_inr, description, reference_id, created_at
    ) VALUES (
      v_ride_driver_id, 'penalty_received', v_penalty_amount,
      'Cancellation penalty from booking ' || p_booking_id,
      p_booking_id, NOW()
    );
  END IF;

  -- Refund remaining amount to rider
  IF v_refund_amount > 0 THEN
    UPDATE wallets 
    SET 
      balance_available_inr = balance_available_inr + v_refund_amount,
      balance_reserved_inr = balance_reserved_inr - v_booking.deposit_inr
    WHERE user_id = v_booking.rider_id;

    -- Record refund transaction
    INSERT INTO wallet_transactions (
      user_id, type, amount_inr, description, reference_id, created_at
    ) VALUES (
      v_booking.rider_id, 'refund', v_refund_amount,
      'Booking cancellation refund for ' || p_booking_id,
      p_booking_id, NOW()
    );
  ELSE
    -- Just remove from reserved balance
    UPDATE wallets 
    SET balance_reserved_inr = balance_reserved_inr - v_booking.deposit_inr
    WHERE user_id = v_booking.rider_id;
  END IF;

  -- Restore seats if booking was confirmed
  IF v_booking.status = 'confirmed' THEN
    UPDATE rides 
    SET seats_available = seats_available + v_booking.seats_booked
    WHERE id = v_booking.ride_id;
  END IF;

  -- Update booking deposit status
  UPDATE booking_deposits 
  SET 
    deposit_status = 'processed',
    deposit_released_at = NOW()
  WHERE booking_id = p_booking_id;

  -- Build result
  v_result := json_build_object(
    'success', true,
    'booking_id', p_booking_id,
    'cancelled_by', CASE WHEN v_is_rider THEN 'rider' ELSE 'driver' END,
    'penalty_rate', v_penalty_rate,
    'penalty_amount', v_penalty_amount,
    'refund_amount', v_refund_amount,
    'hours_until_departure', v_hours_until_departure
  );

  RETURN v_result;
END;
$$;


--
-- Name: bookings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ride_id uuid NOT NULL,
    rider_id uuid NOT NULL,
    from_stop_id uuid NOT NULL,
    to_stop_id uuid NOT NULL,
    seats_booked integer DEFAULT 1 NOT NULL,
    fare_total_inr integer DEFAULT 0 NOT NULL,
    status public.booking_status DEFAULT 'pending'::public.booking_status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deposit_status text DEFAULT 'pending'::text,
    requires_deposit boolean DEFAULT false,
    rider_deposit_inr integer DEFAULT 0,
    pickup_stop_id uuid,
    drop_stop_id uuid,
    total_fare_inr numeric(10,2) DEFAULT 0,
    rejection_reason text,
    deposit_inr integer DEFAULT 0,
    CONSTRAINT bookings_deposit_status_check CHECK ((deposit_status = ANY (ARRAY['pending'::text, 'paid'::text, 'refunded'::text]))),
    CONSTRAINT bookings_fare_total_inr_check CHECK (((fare_total_inr)::numeric >= (0)::numeric)),
    CONSTRAINT bookings_seats_booked_check CHECK ((seats_booked > 0)),
    CONSTRAINT chk_from_to_diff CHECK ((from_stop_id <> to_stop_id))
);


--
-- Name: create_booking_v1(uuid, uuid, uuid, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_booking_v1(_ride_id uuid, _from_stop uuid, _to_stop uuid, _seats integer) RETURNS public.bookings
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  _rider uuid := auth.uid();
  _auto  boolean := false;
  _b     public.bookings;
begin
  -- fetch auto_approve if such column exists; ignore if not
  begin
    select coalesce(auto_approve,false) into _auto from public.rides where id=_ride_id;
  exception when undefined_column then
    _auto := false;
  end;

  insert into public.bookings(ride_id, rider_id, from_stop_id, to_stop_id, seats_booked, status)
  values(
    _ride_id, _rider, _from_stop, _to_stop, _seats,
    case when _auto then 'confirmed'::booking_status else 'pending'::booking_status end
  )
  returning * into _b;

  -- reduce available seats immediately if auto-approved
  if _auto then
    update public.rides
      set seats_available = greatest(coalesce(seats_available,0) - _seats, 0)
    where id = _ride_id;
  end if;

  return _b;
end
$$;


--
-- Name: create_booking_v2(uuid, uuid, uuid, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_booking_v2(_ride_id uuid, _from_stop uuid, _to_stop uuid, _seats integer) RETURNS public.bookings
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  _rider uuid := auth.uid();
  _auto  boolean := false;
  _price numeric := 0;
  _fare  numeric := 0;
  _deposit numeric := 0;
  _b     public.bookings;
begin
  -- read flags/price defensively
  begin select coalesce(auto_approve,false) into _auto  from public.rides where id=_ride_id; exception when others then _auto := false; end;
  begin select coalesce(price_per_seat,0) into _price    from public.rides where id=_ride_id; exception when others then _price := 0; end;

  _fare    := coalesce(_price,0) * greatest(coalesce(_seats,1),1);
  -- simple initial policy: 20% deposit (you can change later or drive by route/ride_type)
  _deposit := round(_fare * 0.20);

  -- try inserting with both fare_total_inr and deposit_inr; fall back if columns not present
  begin
    insert into public.bookings(
      ride_id, rider_id, from_stop_id, to_stop_id, seats_booked, status,
      fare_total_inr, deposit_inr
    )
    values(
      _ride_id, _rider, _from_stop, _to_stop, _seats,
      case when _auto then 'confirmed'::booking_status else 'pending'::booking_status end,
      _fare, _deposit
    )
    returning * into _b;
  exception
    when undefined_column then
      -- Insert only what exists
      insert into public.bookings(
        ride_id, rider_id, from_stop_id, to_stop_id, seats_booked, status
      )
      values(
        _ride_id, _rider, _from_stop, _to_stop, _seats,
        case when _auto then 'confirmed'::booking_status else 'pending'::booking_status end
      )
      returning * into _b;
  end;

  if _auto then
    begin
      update public.rides
        set seats_available = greatest(coalesce(seats_available,0) - coalesce(_seats,0), 0)
      where id = _ride_id;
    exception when undefined_column then null;
    end;
  end if;

  return _b;
end
$$;


--
-- Name: create_booking_with_deposit(uuid, uuid, integer, uuid, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_booking_with_deposit(p_ride_id uuid, p_rider_id uuid, p_seats_requested integer, p_from_stop_id uuid DEFAULT NULL::uuid, p_to_stop_id uuid DEFAULT NULL::uuid) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_ride_record record;
  v_wallet_balance integer;
  v_total_fare integer;
  v_deposit_amount integer;
  v_booking_id uuid;
  v_booking_status text;
  v_auto_confirm boolean;
  v_new_seats_available integer;
  v_result json;
BEGIN
  -- Get ride details (FIXED: Correct column references)
  SELECT 
    id, driver_id, seats_available, seats_total, price_per_seat_inr, 
    status, ride_type, allow_auto_confirm, allow_auto_book, auto_approve,
    "from", "to", depart_date, depart_time
  INTO v_ride_record
  FROM rides 
  WHERE id = p_ride_id AND status = 'published';

  -- Validate ride exists and is available
  IF v_ride_record.id IS NULL THEN
    RAISE EXCEPTION 'Ride not found or not available for booking';
  END IF;

  -- Check if user is trying to book their own ride
  IF v_ride_record.driver_id = p_rider_id THEN
    RAISE EXCEPTION 'Cannot book your own ride';
  END IF;

  -- Check seat availability
  IF p_seats_requested > COALESCE(v_ride_record.seats_available, v_ride_record.seats_total, 0) THEN
    RAISE EXCEPTION 'Insufficient seats available. Requested: %, Available: %', 
      p_seats_requested, COALESCE(v_ride_record.seats_available, 0);
  END IF;

  -- Calculate total fare and deposit
  v_total_fare := COALESCE(v_ride_record.price_per_seat_inr, 0) * p_seats_requested;
  
  -- Calculate deposit based on ride type
  IF v_ride_record.ride_type IN ('commercial_pool', 'commercial_full') THEN
    v_deposit_amount := FLOOR(v_total_fare * 0.3); -- 30% for commercial
  ELSE
    v_deposit_amount := FLOOR(v_total_fare * 0.1); -- 10% for private
  END IF;

  -- Check wallet balance
  SELECT balance_available_inr INTO v_wallet_balance
  FROM wallets
  WHERE user_id = p_rider_id;

  IF v_wallet_balance IS NULL THEN
    RAISE EXCEPTION 'Wallet not found. Please set up your wallet first.';
  END IF;

  IF v_wallet_balance < v_deposit_amount THEN
    RAISE EXCEPTION 'Insufficient wallet balance. Required: ₹%, Available: ₹%', 
      v_deposit_amount, v_wallet_balance;
  END IF;

  -- Determine auto-confirmation
  v_auto_confirm := COALESCE(v_ride_record.allow_auto_confirm, v_ride_record.allow_auto_book, v_ride_record.auto_approve, false);
  v_booking_status := CASE WHEN v_auto_confirm THEN 'confirmed' ELSE 'pending' END;

  -- Calculate new seat availability
  v_new_seats_available := CASE 
    WHEN v_booking_status = 'confirmed' 
    THEN COALESCE(v_ride_record.seats_available, v_ride_record.seats_total, 0) - p_seats_requested
    ELSE COALESCE(v_ride_record.seats_available, v_ride_record.seats_total, 0)
  END;

  -- Create the booking
  INSERT INTO bookings (
    ride_id, rider_id, seats_booked, fare_total_inr, deposit_inr, status,
    from_stop_id, to_stop_id
  ) VALUES (
    p_ride_id, p_rider_id, p_seats_requested, v_total_fare, v_deposit_amount, v_booking_status,
    p_from_stop_id, p_to_stop_id
  ) RETURNING id INTO v_booking_id;

  -- Reserve deposit in wallet
  UPDATE wallets 
  SET 
    balance_available_inr = balance_available_inr - v_deposit_amount,
    balance_reserved_inr = balance_reserved_inr + v_deposit_amount,
    updated_at = NOW()
  WHERE user_id = p_rider_id;

  -- Record wallet transaction
  INSERT INTO wallet_transactions (
    user_id, type, amount_inr, description, reference_id, created_at
  ) VALUES (
    p_rider_id, 'reserve', v_deposit_amount, 
    'Deposit reserved for booking ' || v_booking_id, 
    v_booking_id, NOW()
  );

  -- Create booking deposit record
  INSERT INTO booking_deposits (
    booking_id, user_id, deposit_amount_inr, deposit_status
  ) VALUES (
    v_booking_id, p_rider_id, v_deposit_amount, 'held'
  );

  -- Update ride seats if auto-confirmed
  IF v_booking_status = 'confirmed' THEN
    UPDATE rides 
    SET seats_available = v_new_seats_available
    WHERE id = p_ride_id;
  END IF;

  -- Build result
  v_result := json_build_object(
    'success', true,
    'id', v_booking_id,
    'ride_id', p_ride_id,
    'rider_id', p_rider_id,
    'seats', p_seats_requested,
    'status', v_booking_status,
    'fare_total_inr', v_total_fare,
    'deposit_inr', v_deposit_amount,
    'auto_confirmed', v_auto_confirm
  );

  RETURN v_result;
END;
$$;


--
-- Name: delete_city(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_city(p_id uuid) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE cities 
    SET is_active = false, updated_at = now()
    WHERE id = p_id;
    
    RETURN FOUND;
END;
$$;


--
-- Name: delete_route(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_route(p_id uuid) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE routes 
    SET is_active = false, updated_at = now()
    WHERE id = p_id;
    
    RETURN FOUND;
END;
$$;


--
-- Name: delete_stop(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_stop(p_id uuid) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE stops 
    SET is_active = false
    WHERE id = p_id;
    
    RETURN FOUND;
END;
$$;


--
-- Name: ensure_city(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.ensure_city(_name text) RETURNS uuid
    LANGUAGE plpgsql
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


--
-- Name: ensure_default_route_stops(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.ensure_default_route_stops(p_route_id uuid) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
declare
  _cnt int;
  _origin text;
  _destination text;
  _stop1 uuid;
  _stop2 uuid;
begin
  select count(*) into _cnt from public.route_stops where route_id = p_route_id;
  if _cnt > 0 then
    return _cnt;
  end if;

  select origin, destination into _origin, _destination
  from public.routes where id = p_route_id;
  if _origin is null or _destination is null then
    return 0;
  end if;

  -- Upsert City/Name stops minimally
  insert into public.stops(city, name)
  values (_origin, _origin||' Origin')
  on conflict (city, name) do nothing
  returning id into _stop1;

  if _stop1 is null then
    select id into _stop1 from public.stops where city=_origin and name=_origin||' Origin' limit 1;
  end if;

  insert into public.stops(city, name)
  values (_destination, _destination||' Destination')
  on conflict (city, name) do nothing
  returning id into _stop2;

  if _stop2 is null then
    select id into _stop2 from public.stops where city=_destination and name=_destination||' Destination' limit 1;
  end if;

  -- Map in order
  insert into public.route_stops(route_id, stop_id, stop_name, stop_order, seq)
  values
    (p_route_id, _stop1, _origin||' Origin', 1, 1),
    (p_route_id, _stop2, _destination||' Destination', 2, 2)
  on conflict do nothing;

  select count(*) into _cnt from public.route_stops where route_id = p_route_id;
  return _cnt;
end;
$$;


--
-- Name: ensure_route(uuid, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.ensure_route(_from_id uuid, _to_id uuid) RETURNS uuid
    LANGUAGE plpgsql
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


--
-- Name: get_all_cities(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_all_cities() RETURNS TABLE(id uuid, name text, state text, country text, is_active boolean, display_order integer, created_at timestamp with time zone, updated_at timestamp with time zone)
    LANGUAGE sql
    AS $$
    SELECT id, name, state, country, is_active, display_order, created_at, updated_at
    FROM cities 
    WHERE is_active = true
    ORDER BY display_order ASC, name ASC;
$$;


--
-- Name: get_financial_summary(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_financial_summary() RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  v_total_balance numeric := 0;
  v_total_reserved numeric := 0;
  v_pending_settlements numeric := 0;
  v_monthly_revenue numeric := 0;
  v_current_month_start timestamptz;
BEGIN
  -- Calculate current month start
  v_current_month_start := date_trunc('month', now());

  -- Get total wallet balances
  SELECT 
    COALESCE(SUM(balance_available_inr), 0),
    COALESCE(SUM(balance_reserved_inr), 0)
  INTO v_total_balance, v_total_reserved
  FROM wallets;

  -- Get pending settlements amount
  SELECT COALESCE(SUM(amount_inr), 0) INTO v_pending_settlements
  FROM settlements
  WHERE status = 'requested';

  -- Get current month revenue (deposits and top-ups)
  SELECT COALESCE(SUM(amount_inr), 0) INTO v_monthly_revenue
  FROM wallet_transactions
  WHERE tx_type = 'transfer_in'
    AND created_at >= v_current_month_start;

  RETURN jsonb_build_object(
    'total_balance', v_total_balance,
    'total_reserved', v_total_reserved,
    'pending_settlements', v_pending_settlements,
    'monthly_revenue', v_monthly_revenue,
    'generated_at', now()
  );
END;
$$;


--
-- Name: get_or_create_city(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_or_create_city(p_name text) RETURNS uuid
    LANGUAGE plpgsql
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


--
-- Name: get_or_create_route(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_or_create_route(p_from_city text, p_to_city text) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
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


--
-- Name: FUNCTION get_or_create_route(p_from_city text, p_to_city text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.get_or_create_route(p_from_city text, p_to_city text) IS 'Returns a route id for (from_city,to_city), creating cities/route if missing.';


--
-- Name: get_route_stop_count_new(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_route_stop_count_new(p_route_id uuid) RETURNS integer
    LANGUAGE sql
    AS $$
    SELECT COUNT(*)::INTEGER
    FROM stops 
    WHERE route_id = p_route_id 
    AND is_active = true;
$$;


--
-- Name: get_route_stops(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_route_stops(route_uuid uuid) RETURNS TABLE(stop_id uuid, stop_name text, address text, city_name text, stop_order integer, is_pickup boolean, is_drop boolean)
    LANGUAGE sql
    AS $$
  SELECT 
    s.id,
    s.name,
    s.address,
    s.city_name,
    s.stop_order,
    s.is_pickup,
    s.is_drop
  FROM stops s
  WHERE s.route_id = route_uuid
    AND COALESCE(s.is_active, true) = true
  ORDER BY s.stop_order;
$$;


--
-- Name: get_route_stops_new(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_route_stops_new(p_route_id uuid) RETURNS TABLE(id uuid, route_id uuid, name text, address text, city_name text, stop_order integer, is_pickup boolean, is_drop boolean, is_active boolean, latitude numeric, longitude numeric, created_at timestamp with time zone)
    LANGUAGE sql
    AS $$
    SELECT 
        id, route_id, name, address, city_name,
        stop_order, is_pickup, is_drop, is_active,
        latitude, longitude, created_at
    FROM stops 
    WHERE route_id = p_route_id 
    AND is_active = true
    ORDER BY stop_order ASC;
$$;


--
-- Name: get_routes_between_cities(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_routes_between_cities(from_city_name text, to_city_name text) RETURNS TABLE(route_id uuid, route_name text, route_code text, distance_km integer, estimated_duration_minutes integer)
    LANGUAGE sql
    AS $$
  SELECT 
    r.id,
    r.name,
    r.code,
    r.distance_km,
    r.estimated_duration_minutes
  FROM routes r
  LEFT JOIN cities fc ON r.from_city_id = fc.id
  LEFT JOIN cities tc ON r.to_city_id = tc.id
  WHERE (LOWER(fc.name) = LOWER(from_city_name) OR LOWER(r.from_city) = LOWER(from_city_name) OR LOWER(r.origin) = LOWER(from_city_name))
    AND (LOWER(tc.name) = LOWER(to_city_name) OR LOWER(r.to_city) = LOWER(to_city_name) OR LOWER(r.destination) = LOWER(to_city_name))
    AND COALESCE(r.is_active, true) = true
  ORDER BY r.name;
$$;


--
-- Name: get_routes_between_cities(uuid, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_routes_between_cities(p_from_city_id uuid, p_to_city_id uuid) RETURNS TABLE(id uuid, name text, origin text, destination text, from_city_id uuid, to_city_id uuid, distance_km integer, estimated_duration_minutes integer, is_active boolean, updated_at timestamp with time zone)
    LANGUAGE sql
    AS $$
    SELECT 
        r.id, r.name, r.origin, r.destination, 
        r.from_city_id, r.to_city_id,
        r.distance_km, r.estimated_duration_minutes,
        r.is_active, r.updated_at
    FROM routes r
    WHERE r.from_city_id = p_from_city_id 
    AND r.to_city_id = p_to_city_id
    AND r.is_active = true
    ORDER BY r.name ASC;
$$;


--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
begin
  insert into public.profiles (user_id, full_name, phone, address)
  values (new.id,
          coalesce(new.raw_user_meta_data->>'full_name',''),
          coalesce(new.phone,''),
          coalesce(new.raw_user_meta_data->>'address',''))
  on conflict (user_id) do nothing;
  return new;
end; $$;


--
-- Name: is_admin(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_admin() RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
    select exists (select 1 from public.admins a where a.user_id = auth.uid());
$$;


--
-- Name: process_booking_deposit(uuid, uuid, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.process_booking_deposit(p_booking_id uuid, p_user_id uuid, p_deposit_amount integer) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_deposit_id UUID;
    v_wallet_balance INTEGER;
    v_tx_id UUID;
BEGIN
    -- Check if user has sufficient balance
    SELECT balance_available_inr INTO v_wallet_balance
    FROM wallets 
    WHERE user_id = p_user_id;
    
    IF v_wallet_balance < p_deposit_amount THEN
        RAISE EXCEPTION 'Insufficient wallet balance. Required: %, Available: %', p_deposit_amount, v_wallet_balance;
    END IF;
    
    -- Reserve the deposit amount in wallet
    UPDATE wallets 
    SET balance_available_inr = balance_available_inr - p_deposit_amount,
        balance_reserved_inr = balance_reserved_inr + p_deposit_amount,
        updated_at = now()
    WHERE user_id = p_user_id;
    
    -- Create wallet transaction record
    INSERT INTO wallet_transactions (user_id, tx_type, amount_inr, ref_booking_id, note)
    VALUES (p_user_id, 'reserve', -p_deposit_amount, p_booking_id, 'Deposit reserved for booking')
    RETURNING id INTO v_tx_id;
    
    -- Create or update booking deposit record
    INSERT INTO booking_deposits (booking_id, user_id, deposit_amount_inr, deposit_status, deposit_paid_at, wallet_reserve_tx_id)
    VALUES (p_booking_id, p_user_id, p_deposit_amount, 'paid', now(), v_tx_id)
    RETURNING id INTO v_deposit_id;
    
    -- Update booking status
    UPDATE bookings 
    SET deposit_status = 'paid',
        rider_deposit_inr = p_deposit_amount
    WHERE id = p_booking_id;
    
    RETURN v_deposit_id;
END;
$$;


--
-- Name: process_ride_cancellation(uuid, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.process_ride_cancellation(p_booking_id uuid, p_cancelled_by text, p_cancellation_note text DEFAULT NULL::text) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_cancellation_id UUID;
    v_penalty_calc RECORD;
    v_penalty_tx_id UUID;
    v_refund_tx_id UUID;
    v_booking_record RECORD;
BEGIN
    -- Get booking details
    SELECT * INTO v_booking_record FROM bookings WHERE id = p_booking_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Booking not found: %', p_booking_id;
    END IF;
    
    -- Calculate penalty
    SELECT * INTO v_penalty_calc 
    FROM calculate_cancellation_penalty(p_booking_id, p_cancelled_by);
    
    -- Create cancellation record
    INSERT INTO cancellations (
        booking_id, 
        cancelled_by, 
        hours_before_depart, 
        penalty_inr, 
        penalty_percentage,
        penalty_recipient_id,
        policy_id,
        note
    ) VALUES (
        p_booking_id,
        p_cancelled_by::cancellation_actor,
        v_penalty_calc.hours_before_departure,
        v_penalty_calc.penalty_amount_inr,
        v_penalty_calc.penalty_percentage,
        v_penalty_calc.penalty_recipient_id,
        v_penalty_calc.policy_applied,
        p_cancellation_note
    ) RETURNING id INTO v_cancellation_id;
    
    -- Process financial transactions if there's a penalty
    IF v_penalty_calc.penalty_amount_inr > 0 AND v_penalty_calc.penalty_recipient_id IS NOT NULL THEN
        -- Transfer penalty amount to recipient
        INSERT INTO wallet_transactions (user_id, tx_type, amount_inr, ref_booking_id, note)
        VALUES (
            v_penalty_calc.penalty_recipient_id, 
            'transfer_in', 
            v_penalty_calc.penalty_amount_inr, 
            p_booking_id, 
            'Cancellation penalty received'
        ) RETURNING id INTO v_penalty_tx_id;
        
        -- Update recipient's wallet
        UPDATE wallets 
        SET balance_available_inr = balance_available_inr + v_penalty_calc.penalty_amount_inr,
            updated_at = now()
        WHERE user_id = v_penalty_calc.penalty_recipient_id;
    END IF;
    
    -- Release remaining deposit (if any)
    PERFORM release_booking_deposits(p_booking_id, v_penalty_calc.penalty_amount_inr);
    
    -- Update booking status
    UPDATE bookings 
    SET status = 'cancelled'::booking_status,
        updated_at = now()
    WHERE id = p_booking_id;
    
    -- Update cancellation with transaction references
    UPDATE cancellations 
    SET penalty_tx_id = v_penalty_tx_id,
        processed = true
    WHERE id = v_cancellation_id;
    
    RETURN v_cancellation_id;
END;
$$;


--
-- Name: process_ride_completion(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.process_ride_completion(p_ride_id uuid) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_ride record;
  v_booking record;
  v_total_processed integer := 0;
  v_driver_earnings integer := 0;
BEGIN
  -- Get ride details
  SELECT * INTO v_ride FROM rides WHERE id = p_ride_id;
  
  IF v_ride.id IS NULL THEN
    RAISE EXCEPTION 'Ride not found';
  END IF;

  -- Process all confirmed bookings for this ride
  FOR v_booking IN 
    SELECT * FROM bookings 
    WHERE ride_id = p_ride_id AND status = 'confirmed'
  LOOP
    -- Transfer fare to driver
    UPDATE wallets 
    SET balance_available_inr = balance_available_inr + v_booking.fare_total_inr
    WHERE user_id = v_ride.driver_id;

    -- Release deposit from rider's reserved balance
    UPDATE wallets 
    SET balance_reserved_inr = balance_reserved_inr - v_booking.deposit_inr
    WHERE user_id = v_booking.rider_id;

    -- Record driver payment
    INSERT INTO wallet_transactions (
      user_id, type, amount_inr, description, reference_id, created_at
    ) VALUES (
      v_ride.driver_id, 'ride_payment', v_booking.fare_total_inr,
      'Payment for ride ' || p_ride_id || ' (Booking: ' || v_booking.id || ')',
      v_booking.id, NOW()
    );

    -- Update booking status
    UPDATE bookings 
    SET status = 'completed', updated_at = NOW()
    WHERE id = v_booking.id;

    -- Update deposit record
    UPDATE booking_deposits 
    SET 
      deposit_status = 'completed',
      deposit_released_at = NOW()
    WHERE booking_id = v_booking.id;

    v_total_processed := v_total_processed + 1;
    v_driver_earnings := v_driver_earnings + v_booking.fare_total_inr;
  END LOOP;

  -- Update ride status
  UPDATE rides 
  SET status = 'completed', updated_at = NOW()
  WHERE id = p_ride_id;

  RETURN json_build_object(
    'success', true,
    'ride_id', p_ride_id,
    'bookings_processed', v_total_processed,
    'driver_earnings', v_driver_earnings
  );
END;
$$;


--
-- Name: public_ride_simple(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.public_ride_simple(payload jsonb) RETURNS uuid
    LANGUAGE plpgsql
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


--
-- Name: public_ride_simple(text, text, timestamp with time zone, integer, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.public_ride_simple(p_from text, p_to text, p_when timestamp with time zone, p_seats integer, p_price integer, p_notes text DEFAULT NULL::text) RETURNS uuid
    LANGUAGE sql
    AS $$
  SELECT public.publish_ride_simple(p_from, p_to, p_when, p_seats, p_price, p_notes);
$$;


--
-- Name: publish_ride_simple(text, text, timestamp with time zone, integer, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.publish_ride_simple(p_from_city text, p_to_city text, p_depart_at timestamp with time zone, p_seats_total integer, p_price_per_seat integer, p_notes text DEFAULT NULL::text) RETURNS uuid
    LANGUAGE plpgsql
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


--
-- Name: publish_ride_slim(text, text, timestamp with time zone, integer, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.publish_ride_slim(p_from text, p_to text, p_when timestamp with time zone, p_seats integer, p_price integer, p_pool text DEFAULT 'private'::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
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


--
-- Name: FUNCTION publish_ride_slim(p_from text, p_to text, p_when timestamp with time zone, p_seats integer, p_price integer, p_pool text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.publish_ride_slim(p_from text, p_to text, p_when timestamp with time zone, p_seats integer, p_price integer, p_pool text) IS 'Inserts a new ride row and returns {id}.';


--
-- Name: release_booking_deposit(uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.release_booking_deposit(p_booking_id uuid, p_reason text DEFAULT 'Deposit released'::text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_booking record;
BEGIN
  -- Get booking details
  SELECT * INTO v_booking
  FROM bookings
  WHERE id = p_booking_id;

  IF v_booking.id IS NULL THEN
    RAISE EXCEPTION 'Booking not found';
  END IF;

  -- Release reserved amount back to available balance
  UPDATE wallets 
  SET 
    balance_available_inr = balance_available_inr + v_booking.deposit_inr,
    balance_reserved_inr = balance_reserved_inr - v_booking.deposit_inr,
    updated_at = NOW()
  WHERE user_id = v_booking.rider_id;

  -- Record transaction
  INSERT INTO wallet_transactions (
    user_id, type, amount_inr, description, reference_id, created_at
  ) VALUES (
    v_booking.rider_id, 'deposit_released', v_booking.deposit_inr,
    p_reason || ' - ' || p_booking_id,
    p_booking_id, NOW()
  );

  -- Update booking deposit record
  UPDATE booking_deposits 
  SET 
    deposit_status = 'released',
    deposit_released_at = NOW()
  WHERE booking_id = p_booking_id;

  RETURN true;
END;
$$;


--
-- Name: release_booking_deposits(uuid, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.release_booking_deposits(p_booking_id uuid, p_penalty_amount integer DEFAULT 0) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_deposit RECORD;
    v_refund_amount INTEGER;
    v_tx_id UUID;
BEGIN
    -- Process all deposits for this booking
    FOR v_deposit IN 
        SELECT * FROM booking_deposits 
        WHERE booking_id = p_booking_id 
          AND deposit_status = 'paid'
    LOOP
        -- Calculate refund amount (deposit minus any penalty)
        v_refund_amount := v_deposit.deposit_amount_inr - p_penalty_amount;
        
        IF v_refund_amount > 0 THEN
            -- Release funds back to available balance
            UPDATE wallets 
            SET balance_available_inr = balance_available_inr + v_refund_amount,
                balance_reserved_inr = balance_reserved_inr - v_deposit.deposit_amount_inr,
                updated_at = now()
            WHERE user_id = v_deposit.user_id;
            
            -- Create refund transaction
            INSERT INTO wallet_transactions (user_id, tx_type, amount_inr, ref_booking_id, note)
            VALUES (
                v_deposit.user_id, 
                'release', 
                v_refund_amount, 
                p_booking_id, 
                'Deposit refund after cancellation'
            ) RETURNING id INTO v_tx_id;
            
            -- Update deposit record
            UPDATE booking_deposits 
            SET deposit_status = CASE 
                    WHEN v_refund_amount = v_deposit.deposit_amount_inr THEN 'refunded'
                    ELSE 'partially_refunded'
                END,
                deposit_released_at = now(),
                wallet_release_tx_id = v_tx_id
            WHERE id = v_deposit.id;
        ELSE
            -- Full deposit forfeited as penalty
            UPDATE wallets 
            SET balance_reserved_inr = balance_reserved_inr - v_deposit.deposit_amount_inr,
                updated_at = now()
            WHERE user_id = v_deposit.user_id;
            
            UPDATE booking_deposits 
            SET deposit_status = 'forfeited',
                deposit_released_at = now()
            WHERE id = v_deposit.id;
        END IF;
    END LOOP;
END;
$$;


--
-- Name: reserve_wallet_balance(uuid, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reserve_wallet_balance(p_user_id uuid, p_amount integer, p_note text DEFAULT 'Balance reserved'::text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  current_available integer;
BEGIN
  -- Get current available balance
  SELECT balance_available_inr INTO current_available
  FROM wallets WHERE user_id = p_user_id;

  -- Check if sufficient balance
  IF current_available < p_amount THEN
    RETURN false;
  END IF;

  -- Move from available to reserved
  UPDATE wallets 
  SET 
    balance_available_inr = balance_available_inr - p_amount,
    balance_reserved_inr = balance_reserved_inr + p_amount,
    updated_at = NOW()
  WHERE user_id = p_user_id;

  -- Record transaction
  INSERT INTO wallet_transactions (
    user_id, type, amount_inr, description, created_at
  ) VALUES (
    p_user_id, 'reserve', p_amount, p_note, NOW()
  );

  RETURN true;
END;
$$;


--
-- Name: update_bookings_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_bookings_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: update_cancellation_policy(text, text, integer, numeric, integer, numeric, integer, numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_cancellation_policy(p_ride_type text, p_actor text, p_hours_threshold_1 integer, p_penalty_percentage_1 numeric, p_hours_threshold_2 integer, p_penalty_percentage_2 numeric, p_hours_threshold_3 integer, p_penalty_percentage_3 numeric) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_policy_id UUID;
BEGIN
    INSERT INTO cancellation_policies (
        ride_type, actor, 
        hours_threshold_1, penalty_percentage_1,
        hours_threshold_2, penalty_percentage_2,
        hours_threshold_3, penalty_percentage_3,
        updated_at
    ) VALUES (
        p_ride_type, p_actor,
        p_hours_threshold_1, p_penalty_percentage_1,
        p_hours_threshold_2, p_penalty_percentage_2,
        p_hours_threshold_3, p_penalty_percentage_3,
        now()
    )
    ON CONFLICT (ride_type, actor) 
    DO UPDATE SET
        hours_threshold_1 = EXCLUDED.hours_threshold_1,
        penalty_percentage_1 = EXCLUDED.penalty_percentage_1,
        hours_threshold_2 = EXCLUDED.hours_threshold_2,
        penalty_percentage_2 = EXCLUDED.penalty_percentage_2,
        hours_threshold_3 = EXCLUDED.hours_threshold_3,
        penalty_percentage_3 = EXCLUDED.penalty_percentage_3,
        updated_at = now()
    RETURNING id INTO v_policy_id;
    
    RETURN v_policy_id;
END;
$$;


--
-- Name: update_rides_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_rides_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
-- Regclass of the table e.g. public.notes
entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

-- I, U, D, T: insert, update ...
action realtime.action = (
    case wal ->> 'action'
        when 'I' then 'INSERT'
        when 'U' then 'UPDATE'
        when 'D' then 'DELETE'
        else 'ERROR'
    end
);

-- Is row level security enabled for the table
is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

subscriptions realtime.subscription[] = array_agg(subs)
    from
        realtime.subscription subs
    where
        subs.entity = entity_;

-- Subscription vars
roles regrole[] = array_agg(distinct us.claims_role::text)
    from
        unnest(subscriptions) us;

working_role regrole;
claimed_role regrole;
claims jsonb;

subscription_id uuid;
subscription_has_access bool;
visible_to_subscription_ids uuid[] = '{}';

-- structured info for wal's columns
columns realtime.wal_column[];
-- previous identity values for update/delete
old_columns realtime.wal_column[];

error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

-- Primary jsonb output for record
output jsonb;

begin
perform set_config('role', null, true);

columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'columns') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

old_columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'identity') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

for working_role in select * from unnest(roles) loop

    -- Update `is_selectable` for columns and old_columns
    columns =
        array_agg(
            (
                c.name,
                c.type_name,
                c.type_oid,
                c.value,
                c.is_pkey,
                pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
            )::realtime.wal_column
        )
        from
            unnest(columns) c;

    old_columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(old_columns) c;

    if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            -- subscriptions is already filtered by entity
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 400: Bad Request, no primary key']
        )::realtime.wal_rls;

    -- The claims role does not have SELECT permission to the primary key of entity
    elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 401: Unauthorized']
        )::realtime.wal_rls;

    else
        output = jsonb_build_object(
            'schema', wal ->> 'schema',
            'table', wal ->> 'table',
            'type', action,
            'commit_timestamp', to_char(
                ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
            ),
            'columns', (
                select
                    jsonb_agg(
                        jsonb_build_object(
                            'name', pa.attname,
                            'type', pt.typname
                        )
                        order by pa.attnum asc
                    )
                from
                    pg_attribute pa
                    join pg_type pt
                        on pa.atttypid = pt.oid
                where
                    attrelid = entity_
                    and attnum > 0
                    and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
            )
        )
        -- Add "record" key for insert and update
        || case
            when action in ('INSERT', 'UPDATE') then
                jsonb_build_object(
                    'record',
                    (
                        select
                            jsonb_object_agg(
                                -- if unchanged toast, get column name and value from old record
                                coalesce((c).name, (oc).name),
                                case
                                    when (c).name is null then (oc).value
                                    else (c).value
                                end
                            )
                        from
                            unnest(columns) c
                            full outer join unnest(old_columns) oc
                                on (c).name = (oc).name
                        where
                            coalesce((c).is_selectable, (oc).is_selectable)
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                    )
                )
            else '{}'::jsonb
        end
        -- Add "old_record" key for update and delete
        || case
            when action = 'UPDATE' then
                jsonb_build_object(
                        'old_record',
                        (
                            select jsonb_object_agg((c).name, (c).value)
                            from unnest(old_columns) c
                            where
                                (c).is_selectable
                                and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                        )
                    )
            when action = 'DELETE' then
                jsonb_build_object(
                    'old_record',
                    (
                        select jsonb_object_agg((c).name, (c).value)
                        from unnest(old_columns) c
                        where
                            (c).is_selectable
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                    )
                )
            else '{}'::jsonb
        end;

        -- Create the prepared statement
        if is_rls_enabled and action <> 'DELETE' then
            if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                deallocate walrus_rls_stmt;
            end if;
            execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
        end if;

        visible_to_subscription_ids = '{}';

        for subscription_id, claims in (
                select
                    subs.subscription_id,
                    subs.claims
                from
                    unnest(subscriptions) subs
                where
                    subs.entity = entity_
                    and subs.claims_role = working_role
                    and (
                        realtime.is_visible_through_filters(columns, subs.filters)
                        or (
                          action = 'DELETE'
                          and realtime.is_visible_through_filters(old_columns, subs.filters)
                        )
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
                    set_config('request.jwt.claims', claims::text, true);

                execute 'execute walrus_rls_stmt' into subscription_has_access;

                if subscription_has_access then
                    visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                end if;
            end if;
        end loop;

        perform set_config('role', null, true);

        return next (
            output,
            is_rls_enabled,
            visible_to_subscription_ids,
            case
                when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                else '{}'
            end
        )::realtime.wal_rls;

    end if;
end loop;

perform set_config('role', null, true);
end;
$$;


--
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    declare
      res jsonb;
    begin
      execute format('select to_jsonb(%L::'|| type_::text || ')', val)  into res;
      return res;
    end
    $$;


--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS SETOF realtime.wal_rls
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
      with pub as (
        select
          concat_ws(
            ',',
            case when bool_or(pubinsert) then 'insert' else null end,
            case when bool_or(pubupdate) then 'update' else null end,
            case when bool_or(pubdelete) then 'delete' else null end
          ) as w2j_actions,
          coalesce(
            string_agg(
              realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
              ','
            ) filter (where ppt.tablename is not null and ppt.tablename not like '% %'),
            ''
          ) w2j_add_tables
        from
          pg_publication pp
          left join pg_publication_tables ppt
            on pp.pubname = ppt.pubname
        where
          pp.pubname = publication
        group by
          pp.pubname
        limit 1
      ),
      w2j as (
        select
          x.*, pub.w2j_add_tables
        from
          pub,
          pg_logical_slot_get_changes(
            slot_name, null, max_changes,
            'include-pk', 'true',
            'include-transaction', 'false',
            'include-timestamp', 'true',
            'include-type-oids', 'true',
            'format-version', '2',
            'actions', pub.w2j_actions,
            'add-tables', pub.w2j_add_tables
          ) x
      )
      select
        xyz.wal,
        xyz.is_rls_enabled,
        xyz.subscription_ids,
        xyz.errors
      from
        w2j,
        realtime.apply_rls(
          wal := w2j.data::jsonb,
          max_record_bytes := max_record_bytes
        ) xyz(wal, is_rls_enabled, subscription_ids, errors)
      where
        w2j.w2j_add_tables <> ''
        and xyz.subscription_ids[1] is not null
    $$;


--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


--
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  BEGIN
    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    -- Attempt to insert the message
    INSERT INTO realtime.messages (payload, event, topic, private, extension)
    VALUES (payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      -- Capture and notify the error
      RAISE WARNING 'ErrorSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can't be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $$;


--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


--
-- Name: add_prefixes(text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.add_prefixes(_bucket_id text, _name text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    prefixes text[];
BEGIN
    prefixes := "storage"."get_prefixes"("_name");

    IF array_length(prefixes, 1) > 0 THEN
        INSERT INTO storage.prefixes (name, bucket_id)
        SELECT UNNEST(prefixes) as name, "_bucket_id" ON CONFLICT DO NOTHING;
    END IF;
END;
$$;


--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


--
-- Name: delete_prefix(text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.delete_prefix(_bucket_id text, _name text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    -- Check if we can delete the prefix
    IF EXISTS(
        SELECT FROM "storage"."prefixes"
        WHERE "prefixes"."bucket_id" = "_bucket_id"
          AND level = "storage"."get_level"("_name") + 1
          AND "prefixes"."name" COLLATE "C" LIKE "_name" || '/%'
        LIMIT 1
    )
    OR EXISTS(
        SELECT FROM "storage"."objects"
        WHERE "objects"."bucket_id" = "_bucket_id"
          AND "storage"."get_level"("objects"."name") = "storage"."get_level"("_name") + 1
          AND "objects"."name" COLLATE "C" LIKE "_name" || '/%'
        LIMIT 1
    ) THEN
    -- There are sub-objects, skip deletion
    RETURN false;
    ELSE
        DELETE FROM "storage"."prefixes"
        WHERE "prefixes"."bucket_id" = "_bucket_id"
          AND level = "storage"."get_level"("_name")
          AND "prefixes"."name" = "_name";
        RETURN true;
    END IF;
END;
$$;


--
-- Name: delete_prefix_hierarchy_trigger(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.delete_prefix_hierarchy_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    prefix text;
BEGIN
    prefix := "storage"."get_prefix"(OLD."name");

    IF coalesce(prefix, '') != '' THEN
        PERFORM "storage"."delete_prefix"(OLD."bucket_id", prefix);
    END IF;

    RETURN OLD;
END;
$$;


--
-- Name: enforce_bucket_name_length(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.enforce_bucket_name_length() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$$;


--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
    _filename text;
BEGIN
    SELECT string_to_array(name, '/') INTO _parts;
    SELECT _parts[array_length(_parts,1)] INTO _filename;
    RETURN reverse(split_part(reverse(_filename), '.', 1));
END
$$;


--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Return everything except the last segment
    RETURN _parts[1 : array_length(_parts,1) - 1];
END
$$;


--
-- Name: get_level(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_level(name text) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
SELECT array_length(string_to_array("name", '/'), 1);
$$;


--
-- Name: get_prefix(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_prefix(name text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
SELECT
    CASE WHEN strpos("name", '/') > 0 THEN
             regexp_replace("name", '[\/]{1}[^\/]+\/?$', '')
         ELSE
             ''
        END;
$_$;


--
-- Name: get_prefixes(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_prefixes(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
DECLARE
    parts text[];
    prefixes text[];
    prefix text;
BEGIN
    -- Split the name into parts by '/'
    parts := string_to_array("name", '/');
    prefixes := '{}';

    -- Construct the prefixes, stopping one level below the last part
    FOR i IN 1..array_length(parts, 1) - 1 LOOP
            prefix := array_to_string(parts[1:i], '/');
            prefixes := array_append(prefixes, prefix);
    END LOOP;

    RETURN prefixes;
END;
$$;


--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::bigint) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(name COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                        substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1)))
                    ELSE
                        name
                END AS name, id, metadata, updated_at
            FROM
                storage.objects
            WHERE
                bucket_id = $5 AND
                name ILIKE $1 || ''%'' AND
                CASE
                    WHEN $6 != '''' THEN
                    name COLLATE "C" > $6
                ELSE true END
                AND CASE
                    WHEN $4 != '''' THEN
                        CASE
                            WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                                substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                name COLLATE "C" > $4
                            END
                    ELSE
                        true
                END
            ORDER BY
                name COLLATE "C" ASC) as e order by name COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_token, bucket_id, start_after;
END;
$_$;


--
-- Name: objects_insert_prefix_trigger(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.objects_insert_prefix_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    NEW.level := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


--
-- Name: objects_update_prefix_trigger(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.objects_update_prefix_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    old_prefixes TEXT[];
BEGIN
    -- Ensure this is an update operation and the name has changed
    IF TG_OP = 'UPDATE' AND (NEW."name" <> OLD."name" OR NEW."bucket_id" <> OLD."bucket_id") THEN
        -- Retrieve old prefixes
        old_prefixes := "storage"."get_prefixes"(OLD."name");

        -- Remove old prefixes that are only used by this object
        WITH all_prefixes as (
            SELECT unnest(old_prefixes) as prefix
        ),
        can_delete_prefixes as (
             SELECT prefix
             FROM all_prefixes
             WHERE NOT EXISTS (
                 SELECT 1 FROM "storage"."objects"
                 WHERE "bucket_id" = OLD."bucket_id"
                   AND "name" <> OLD."name"
                   AND "name" LIKE (prefix || '%')
             )
         )
        DELETE FROM "storage"."prefixes" WHERE name IN (SELECT prefix FROM can_delete_prefixes);

        -- Add new prefixes
        PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    END IF;
    -- Set the new level
    NEW."level" := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


--
-- Name: prefixes_insert_trigger(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.prefixes_insert_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    RETURN NEW;
END;
$$;


--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql
    AS $$
declare
    can_bypass_rls BOOLEAN;
begin
    SELECT rolbypassrls
    INTO can_bypass_rls
    FROM pg_roles
    WHERE rolname = coalesce(nullif(current_setting('role', true), 'none'), current_user);

    IF can_bypass_rls THEN
        RETURN QUERY SELECT * FROM storage.search_v1_optimised(prefix, bucketname, limits, levels, offsets, search, sortcolumn, sortorder);
    ELSE
        RETURN QUERY SELECT * FROM storage.search_legacy_v1(prefix, bucketname, limits, levels, offsets, search, sortcolumn, sortorder);
    END IF;
end;
$$;


--
-- Name: search_legacy_v1(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_legacy_v1(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select path_tokens[$1] as folder
           from storage.objects
             where objects.name ilike $2 || $3 || ''%''
               and bucket_id = $4
               and array_length(objects.path_tokens, 1) <> $1
           group by folder
           order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(objects.path_tokens, 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


--
-- Name: search_v1_optimised(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_v1_optimised(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select (string_to_array(name, ''/''))[level] as name
           from storage.prefixes
             where lower(prefixes.name) like lower($2 || $3) || ''%''
               and bucket_id = $4
               and level = $1
           order by name ' || v_sort_order || '
     )
     (select name,
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[level] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where lower(objects.name) like lower($2 || $3) || ''%''
       and bucket_id = $4
       and level = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


--
-- Name: search_v2(text, text, integer, integer, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer DEFAULT 100, levels integer DEFAULT 1, start_after text DEFAULT ''::text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
BEGIN
    RETURN query EXECUTE
        $sql$
        SELECT * FROM (
            (
                SELECT
                    split_part(name, '/', $4) AS key,
                    name || '/' AS name,
                    NULL::uuid AS id,
                    NULL::timestamptz AS updated_at,
                    NULL::timestamptz AS created_at,
                    NULL::jsonb AS metadata
                FROM storage.prefixes
                WHERE name COLLATE "C" LIKE $1 || '%'
                AND bucket_id = $2
                AND level = $4
                AND name COLLATE "C" > $5
                ORDER BY prefixes.name COLLATE "C" LIMIT $3
            )
            UNION ALL
            (SELECT split_part(name, '/', $4) AS key,
                name,
                id,
                updated_at,
                created_at,
                metadata
            FROM storage.objects
            WHERE name COLLATE "C" LIKE $1 || '%'
                AND bucket_id = $2
                AND level = $4
                AND name COLLATE "C" > $5
            ORDER BY name COLLATE "C" LIMIT $3)
        ) obj
        ORDER BY name COLLATE "C" LIMIT $3;
        $sql$
        USING prefix, bucket_name, limits, levels, start_after;
END;
$_$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text NOT NULL,
    code_challenge_method auth.code_challenge_method NOT NULL,
    code_challenge text NOT NULL,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone
);


--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.flow_state IS 'stores metadata for pkce logins';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid
);


--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: oauth_clients; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_clients (
    id uuid NOT NULL,
    client_id text NOT NULL,
    client_secret_hash text NOT NULL,
    registration_type auth.oauth_registration_type NOT NULL,
    redirect_uris text NOT NULL,
    grant_types text NOT NULL,
    client_name text,
    client_uri text,
    logo_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT oauth_clients_client_name_length CHECK ((char_length(client_name) <= 1024)),
    CONSTRAINT oauth_clients_client_uri_length CHECK ((char_length(client_uri) <= 2048)),
    CONSTRAINT oauth_clients_logo_uri_length CHECK ((char_length(logo_uri) <= 2048))
);


--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: -
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: -
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text
);


--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    disabled boolean,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: admins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admins (
    user_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: booking_deposits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.booking_deposits (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    booking_id uuid NOT NULL,
    user_id uuid NOT NULL,
    deposit_amount_inr integer NOT NULL,
    deposit_status text DEFAULT 'required'::text NOT NULL,
    deposit_paid_at timestamp with time zone,
    deposit_released_at timestamp with time zone,
    wallet_reserve_tx_id uuid,
    wallet_release_tx_id uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: cancellation_policies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cancellation_policies (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ride_type text NOT NULL,
    actor text NOT NULL,
    hours_threshold_1 integer DEFAULT 12 NOT NULL,
    penalty_percentage_1 numeric(5,2) DEFAULT 0.00 NOT NULL,
    hours_threshold_2 integer DEFAULT 6 NOT NULL,
    penalty_percentage_2 numeric(5,2) DEFAULT 30.00 NOT NULL,
    hours_threshold_3 integer DEFAULT 0 NOT NULL,
    penalty_percentage_3 numeric(5,2) DEFAULT 50.00 NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT cancellation_policies_actor_check CHECK ((actor = ANY (ARRAY['both'::text, 'rider'::text, 'driver'::text]))),
    CONSTRAINT cancellation_policies_hours_order_check CHECK (((hours_threshold_1 > hours_threshold_2) AND (hours_threshold_2 >= hours_threshold_3))),
    CONSTRAINT cancellation_policies_penalty_1_check CHECK (((penalty_percentage_1 >= (0)::numeric) AND (penalty_percentage_1 <= (100)::numeric))),
    CONSTRAINT cancellation_policies_penalty_2_check CHECK (((penalty_percentage_2 >= (0)::numeric) AND (penalty_percentage_2 <= (100)::numeric))),
    CONSTRAINT cancellation_policies_penalty_3_check CHECK (((penalty_percentage_3 >= (0)::numeric) AND (penalty_percentage_3 <= (100)::numeric))),
    CONSTRAINT cancellation_policies_ride_type_check CHECK ((ride_type = ANY (ARRAY['private'::text, 'commercial'::text, 'commercial_full'::text])))
);


--
-- Name: cancellations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cancellations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    booking_id uuid NOT NULL,
    cancelled_by public.cancellation_actor NOT NULL,
    cancelled_at timestamp with time zone DEFAULT now() NOT NULL,
    hours_before_depart numeric(6,2),
    penalty_inr numeric(10,2) DEFAULT 0 NOT NULL,
    note text,
    policy_id uuid,
    penalty_percentage numeric(5,2) DEFAULT 0.00,
    penalty_recipient_id uuid,
    processed boolean DEFAULT false,
    penalty_tx_id uuid,
    refund_tx_id uuid
);


--
-- Name: cities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    state text,
    country text DEFAULT 'India'::text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    state_code text,
    is_active boolean DEFAULT true,
    display_order integer DEFAULT 0,
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: deposit_intents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deposit_intents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    amount_inr integer NOT NULL,
    method text DEFAULT 'manual'::text NOT NULL,
    status public.deposit_status DEFAULT 'created'::public.deposit_status NOT NULL,
    razorpay_order_id text,
    razorpay_payment_id text,
    razorpay_signature text,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT deposit_intents_amount_inr_check CHECK ((amount_inr > 0))
);


--
-- Name: inbox_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inbox_messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    thread_id uuid,
    sender_id uuid,
    body text NOT NULL,
    meta jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: inbox_threads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inbox_threads (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ride_id uuid,
    rider_id uuid,
    driver_id uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: kyc_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kyc_documents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    doc_type text NOT NULL,
    doc_number text,
    file_url text NOT NULL,
    verification_status text DEFAULT 'pending'::text,
    verified_at timestamp with time zone,
    verified_by uuid,
    rejection_reason text,
    uploaded_at timestamp with time zone DEFAULT now(),
    CONSTRAINT kyc_documents_doc_type_check CHECK ((doc_type = ANY (ARRAY['aadhaar'::text, 'license'::text, 'passport'::text, 'voter_id'::text, 'pan_card'::text, 'government_id'::text]))),
    CONSTRAINT kyc_documents_verification_status_check CHECK ((verification_status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text])))
);


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    title text NOT NULL,
    body text NOT NULL,
    data jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now(),
    read boolean DEFAULT false
);


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    booking_id uuid NOT NULL,
    provider text DEFAULT 'razorpay'::text NOT NULL,
    order_id text,
    payment_id text,
    amount_inr numeric(10,2) NOT NULL,
    status public.payment_status DEFAULT 'created'::public.payment_status NOT NULL,
    raw_payload jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT payments_amount_inr_check CHECK ((amount_inr >= (0)::numeric))
);


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profiles (
    id uuid NOT NULL,
    bio text,
    date_of_birth date,
    gender text,
    profile_picture_url text,
    address text,
    city text,
    state text,
    country text DEFAULT 'India'::text,
    is_aadhaar_verified boolean DEFAULT false,
    is_license_verified boolean DEFAULT false,
    is_vehicle_verified boolean DEFAULT false,
    is_doc_verified boolean DEFAULT false,
    profile_completion_percentage integer DEFAULT 0,
    chat_preference text DEFAULT 'talkative'::text,
    music_preference text DEFAULT 'depends'::text,
    pets_preference text DEFAULT 'depends'::text,
    smoking_preference text DEFAULT 'no'::text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT profiles_chat_preference_check CHECK ((chat_preference = ANY (ARRAY['quiet'::text, 'talkative'::text, 'depends'::text]))),
    CONSTRAINT profiles_gender_check CHECK ((gender = ANY (ARRAY['male'::text, 'female'::text, 'other'::text, 'prefer_not_to_say'::text]))),
    CONSTRAINT profiles_music_preference_check CHECK ((music_preference = ANY (ARRAY['yes'::text, 'no'::text, 'depends'::text]))),
    CONSTRAINT profiles_pets_preference_check CHECK ((pets_preference = ANY (ARRAY['yes'::text, 'no'::text, 'depends'::text]))),
    CONSTRAINT profiles_smoking_preference_check CHECK ((smoking_preference = ANY (ARRAY['yes'::text, 'no'::text])))
);


--
-- Name: ride_allowed_stops; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ride_allowed_stops (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ride_id uuid NOT NULL,
    stop_id uuid NOT NULL
);


--
-- Name: ride_deposit_requirements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ride_deposit_requirements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ride_id uuid NOT NULL,
    rider_deposit_inr integer DEFAULT 0,
    driver_deposit_inr integer DEFAULT 0,
    auto_refund_hours integer DEFAULT 2,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: route_stops; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.route_stops (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    route_id uuid,
    stop_name text NOT NULL,
    stop_order integer NOT NULL,
    stop_id uuid,
    seq integer
);


--
-- Name: routes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.routes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    origin text NOT NULL,
    destination text NOT NULL,
    from_city text,
    to_city text,
    title text,
    code text,
    from_city_id uuid,
    to_city_id uuid,
    distance_km integer,
    estimated_duration_minutes integer,
    is_active boolean DEFAULT true,
    updated_at timestamp with time zone DEFAULT now(),
    description text DEFAULT ''::text
);


--
-- Name: settlements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.settlements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    amount_inr integer NOT NULL,
    status public.settlement_status DEFAULT 'requested'::public.settlement_status NOT NULL,
    cycle_start date,
    cycle_end date,
    requested_at timestamp with time zone DEFAULT now() NOT NULL,
    processed_at timestamp with time zone
);


--
-- Name: stops; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stops (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    city_id uuid,
    name text NOT NULL,
    latitude numeric(9,6),
    longitude numeric(9,6),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    geom public.geometry(Point,4326),
    address text,
    city_name text,
    stop_order integer,
    is_pickup boolean DEFAULT true,
    is_drop boolean DEFAULT true,
    is_active boolean DEFAULT true,
    route_id uuid
);


--
-- Name: user_profile_stats; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.user_profile_stats AS
 SELECT u.id,
    u.email,
    u.created_at AS member_since,
    COALESCE((u.raw_user_meta_data ->> 'full_name'::text), (u.email)::text) AS full_name,
    u.phone,
    0 AS total_rides,
    0 AS driver_rides,
    0 AS passenger_rides,
    0.0 AS driver_rating,
    0.0 AS passenger_rating,
    0 AS total_ratings,
    COALESCE(p.is_doc_verified, false) AS is_profile_verified,
        CASE
            WHEN (p.is_aadhaar_verified OR p.is_license_verified) THEN 1
            ELSE 0
        END AS verification_count
   FROM (auth.users u
     LEFT JOIN public.profiles p ON ((u.id = p.id)));


--
-- Name: user_ratings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_ratings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    rated_user_id uuid NOT NULL,
    rater_user_id uuid NOT NULL,
    ride_id uuid,
    overall_rating integer NOT NULL,
    punctuality_rating integer,
    friendliness_rating integer,
    cleanliness_rating integer,
    role_when_rated text NOT NULL,
    comment text,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT user_ratings_cleanliness_rating_check CHECK (((cleanliness_rating >= 1) AND (cleanliness_rating <= 5))),
    CONSTRAINT user_ratings_friendliness_rating_check CHECK (((friendliness_rating >= 1) AND (friendliness_rating <= 5))),
    CONSTRAINT user_ratings_overall_rating_check CHECK (((overall_rating >= 1) AND (overall_rating <= 5))),
    CONSTRAINT user_ratings_punctuality_rating_check CHECK (((punctuality_rating >= 1) AND (punctuality_rating <= 5))),
    CONSTRAINT user_ratings_role_when_rated_check CHECK ((role_when_rated = ANY (ARRAY['driver'::text, 'passenger'::text])))
);


--
-- Name: users_app; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_app (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    full_name text NOT NULL,
    phone text NOT NULL,
    email text,
    role public.user_role DEFAULT 'passenger'::public.user_role NOT NULL,
    avatar_url text,
    is_verified boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    auth_provider text DEFAULT 'supabase'::text,
    firebase_uid text,
    supabase_uid text,
    photo_url text,
    last_login timestamp with time zone,
    firebase_synced boolean DEFAULT false,
    supabase_synced boolean DEFAULT false,
    is_active boolean DEFAULT true,
    password_hash text,
    email_verified boolean DEFAULT false,
    phone_verified boolean DEFAULT false
);


--
-- Name: COLUMN users_app.last_login; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users_app.last_login IS 'Timestamp of last successful login';


--
-- Name: COLUMN users_app.password_hash; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users_app.password_hash IS 'Bcrypt hash of user password for local authentication';


--
-- Name: COLUMN users_app.email_verified; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users_app.email_verified IS 'Whether user has verified their email address';


--
-- Name: COLUMN users_app.phone_verified; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users_app.phone_verified IS 'Whether user has verified their phone number';


--
-- Name: v_admin_cancellation_policies; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_admin_cancellation_policies AS
 SELECT id,
    ride_type,
    actor,
    hours_threshold_1,
    penalty_percentage_1,
    hours_threshold_2,
    penalty_percentage_2,
    hours_threshold_3,
    penalty_percentage_3,
    is_active,
    created_at,
    updated_at,
        CASE
            WHEN (ride_type = 'private_pool'::text) THEN 'Private Pool'::text
            WHEN (ride_type = 'commercial_pool'::text) THEN 'Commercial Pool'::text
            WHEN (ride_type = 'commercial_full_car'::text) THEN 'Commercial Full Car'::text
            ELSE ride_type
        END AS ride_type_display,
        CASE
            WHEN (actor = 'driver'::text) THEN 'Driver'::text
            WHEN (actor = 'rider'::text) THEN 'Rider'::text
            ELSE actor
        END AS actor_display
   FROM public.cancellation_policies cp
  ORDER BY ride_type, actor;


--
-- Name: vehicle_verifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehicle_verifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    vehicle_id uuid NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    verified_at timestamp with time zone,
    verified_by uuid,
    note text
);


--
-- Name: vehicles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehicles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    owner_id uuid NOT NULL,
    make text,
    model text,
    color text,
    plate text,
    verified boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    is_verified boolean DEFAULT false,
    is_active boolean DEFAULT true,
    year integer,
    vehicle_type text DEFAULT 'private'::text,
    plate_number text,
    CONSTRAINT vehicles_vehicle_type_check CHECK ((vehicle_type = ANY (ARRAY['private'::text, 'commercial'::text])))
);


--
-- Name: v_profile_vehicles; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_profile_vehicles AS
 SELECT v.id,
    v.owner_id,
    v.make,
    v.model,
    v.color,
    v.plate,
    v.verified,
    v.created_at,
    COALESCE(vf.is_verified, false) AS is_verified
   FROM (public.vehicles v
     LEFT JOIN LATERAL ( SELECT vehicle_verifications.is_verified
           FROM public.vehicle_verifications
          WHERE (vehicle_verifications.vehicle_id = v.id)
          ORDER BY vehicle_verifications.verified_at DESC NULLS LAST
         LIMIT 1) vf ON (true));


--
-- Name: vehicles_api_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vehicles_api_view AS
 SELECT id,
    owner_id,
    make,
    model,
    year,
    color,
    plate_number,
    vehicle_type,
    is_verified,
    is_active,
    created_at,
    now() AS updated_at
   FROM public.vehicles;


--
-- Name: verifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.verifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    id_type text,
    id_number text,
    id_file_url text,
    status text DEFAULT 'pending'::text NOT NULL,
    reviewed_by uuid,
    reviewed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: wallet_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wallet_transactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    tx_type text NOT NULL,
    amount_inr integer NOT NULL,
    description text,
    reference_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT wallet_transactions_tx_type_check CHECK ((tx_type = ANY (ARRAY['deposit'::text, 'withdraw'::text, 'reserve'::text, 'release'::text, 'transfer_in'::text, 'transfer_out'::text, 'penalty_received'::text, 'refund'::text, 'ride_payment'::text])))
);


--
-- Name: TABLE wallet_transactions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.wallet_transactions IS 'Transaction history for user wallets';


--
-- Name: COLUMN wallet_transactions.reference_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.wallet_transactions.reference_id IS 'Optional reference to related booking, ride, or other entity';


--
-- Name: wallets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wallets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    balance_available_inr integer DEFAULT 0 NOT NULL,
    balance_reserved_inr integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT wallets_balance_available_check CHECK ((balance_available_inr >= 0)),
    CONSTRAINT wallets_balance_reserved_check CHECK ((balance_reserved_inr >= 0))
);


--
-- Name: TABLE wallets; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.wallets IS 'User wallet balances for the CabShare platform';


--
-- Name: COLUMN wallets.balance_available_inr; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.wallets.balance_available_inr IS 'Available balance in Indian Rupees (paise)';


--
-- Name: COLUMN wallets.balance_reserved_inr; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.wallets.balance_reserved_inr IS 'Reserved balance in Indian Rupees (paise)';


--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
)
PARTITION BY RANGE (inserted_at);


--
-- Name: messages_2025_09_13; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2025_09_13 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: messages_2025_09_14; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2025_09_14 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: messages_2025_09_15; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2025_09_15 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: messages_2025_09_16; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2025_09_16 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: messages_2025_09_17; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2025_09_17 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: messages_2025_09_18; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2025_09_18 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: -
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text,
    type storage.buckettype DEFAULT 'STANDARD'::storage.buckettype NOT NULL
);


--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: buckets_analytics; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets_analytics (
    id text NOT NULL,
    type storage.buckettype DEFAULT 'ANALYTICS'::storage.buckettype NOT NULL,
    format text DEFAULT 'ICEBERG'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: objects; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb,
    level integer
);


--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: prefixes; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.prefixes (
    bucket_id text NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    level integer GENERATED ALWAYS AS (storage.get_level(name)) STORED NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb
);


--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: supabase_migrations; Owner: -
--

CREATE TABLE supabase_migrations.schema_migrations (
    version text NOT NULL,
    statements text[],
    name text
);


--
-- Name: seed_files; Type: TABLE; Schema: supabase_migrations; Owner: -
--

CREATE TABLE supabase_migrations.seed_files (
    path text NOT NULL,
    hash text NOT NULL
);


--
-- Name: messages_2025_09_13; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_09_13 FOR VALUES FROM ('2025-09-13 00:00:00') TO ('2025-09-14 00:00:00');


--
-- Name: messages_2025_09_14; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_09_14 FOR VALUES FROM ('2025-09-14 00:00:00') TO ('2025-09-15 00:00:00');


--
-- Name: messages_2025_09_15; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_09_15 FOR VALUES FROM ('2025-09-15 00:00:00') TO ('2025-09-16 00:00:00');


--
-- Name: messages_2025_09_16; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_09_16 FOR VALUES FROM ('2025-09-16 00:00:00') TO ('2025-09-17 00:00:00');


--
-- Name: messages_2025_09_17; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_09_17 FOR VALUES FROM ('2025-09-17 00:00:00') TO ('2025-09-18 00:00:00');


--
-- Name: messages_2025_09_18; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_09_18 FOR VALUES FROM ('2025-09-18 00:00:00') TO ('2025-09-19 00:00:00');


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
00000000-0000-0000-0000-000000000000	e4924bd0-6eae-40c7-b14d-e4978f8fa297	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"driver@test.com","user_id":"e4dbcfe6-396d-4507-88b1-3c325b466b2a","user_phone":""}}	2025-09-01 08:52:47.827107+00	
00000000-0000-0000-0000-000000000000	92ebc0dd-8b46-4158-af82-55b40990bbcb	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"piyushachopda@gmail.com","user_id":"99343775-d354-4032-9938-838e382d7392","user_phone":""}}	2025-09-01 08:53:29.108438+00	
00000000-0000-0000-0000-000000000000	095826fd-de0d-4347-984c-810ea1a94d8f	{"action":"user_invited","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"chopccy@gmail.com","user_id":"1cd0d596-1c26-4112-83a5-f1275c15c351"}}	2025-09-01 08:53:56.442318+00	
00000000-0000-0000-0000-000000000000	1ce034b1-88d2-4145-937a-477f88a2327f	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"rider@test.com","user_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","user_phone":""}}	2025-09-01 08:54:33.200413+00	
00000000-0000-0000-0000-000000000000	6435df81-ef95-4fc4-96db-de6fbc2880f6	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-01 08:55:21.530996+00	
00000000-0000-0000-0000-000000000000	bfc33e79-7d09-4a6e-90e6-42a8553467c2	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-01 11:06:57.060717+00	
00000000-0000-0000-0000-000000000000	061e232e-77f7-4278-8916-5d4863061fe1	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-01 11:06:57.072369+00	
00000000-0000-0000-0000-000000000000	0fd79c9a-3850-448c-aad4-e2715622eb8c	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-01 12:06:25.737509+00	
00000000-0000-0000-0000-000000000000	8f6dd032-b12f-4bd0-b665-25ab627eef4b	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-01 12:06:25.756436+00	
00000000-0000-0000-0000-000000000000	a31748dd-4bdc-4e96-b23a-5ec10897bc63	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-01 13:05:45.607006+00	
00000000-0000-0000-0000-000000000000	9cf68b78-99be-4da6-8a88-bc9925c5462a	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-01 13:05:45.62452+00	
00000000-0000-0000-0000-000000000000	6603304a-94bd-4d5a-9e93-9b1fa6c21294	{"action":"login","actor_id":"99343775-d354-4032-9938-838e382d7392","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-01 13:47:00.956083+00	
00000000-0000-0000-0000-000000000000	231275a7-99d1-4a44-8eb3-fad0fed210b6	{"action":"login","actor_id":"99343775-d354-4032-9938-838e382d7392","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-01 14:08:12.643026+00	
00000000-0000-0000-0000-000000000000	7ce95e23-648a-4574-baad-4a7c02a51597	{"action":"login","actor_id":"99343775-d354-4032-9938-838e382d7392","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-01 14:08:22.287042+00	
00000000-0000-0000-0000-000000000000	ca826da8-38fa-4345-91f2-153c342bc13e	{"action":"token_refreshed","actor_id":"99343775-d354-4032-9938-838e382d7392","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-01 15:33:43.592614+00	
00000000-0000-0000-0000-000000000000	1c2900bb-2c9c-4a5b-aa8d-33f042b024a8	{"action":"token_revoked","actor_id":"99343775-d354-4032-9938-838e382d7392","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-01 15:33:43.613925+00	
00000000-0000-0000-0000-000000000000	a54b21c9-5e2d-4ab6-8523-9a85ecfb30cf	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-01 16:23:37.947427+00	
00000000-0000-0000-0000-000000000000	4e72fe3e-637a-4afe-ba3d-f86e4543b4fc	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-01 16:23:37.956998+00	
00000000-0000-0000-0000-000000000000	b26ef0af-37ad-4b80-afa3-14aea0cbe1f0	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-01 17:55:28.102878+00	
00000000-0000-0000-0000-000000000000	73ec4e78-9fca-4727-be55-6a290b6e5a47	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-01 17:55:28.120135+00	
00000000-0000-0000-0000-000000000000	9ad293e3-b392-40e3-9ff9-36ce7ee06a4a	{"action":"logout","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account"}	2025-09-01 18:07:59.567105+00	
00000000-0000-0000-0000-000000000000	a60f5d36-4306-4d82-9d97-e044a0413293	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-01 18:09:22.320642+00	
00000000-0000-0000-0000-000000000000	ed08cbe8-a7f7-4bb9-8909-fa545c3d1982	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-01 19:08:59.30101+00	
00000000-0000-0000-0000-000000000000	8b0a0dfe-c3da-4ab6-963c-94590db6d5a7	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-01 19:08:59.308275+00	
00000000-0000-0000-0000-000000000000	1ce4350c-cfbd-458f-b546-d6ea21f421a7	{"action":"logout","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account"}	2025-09-01 19:12:08.956146+00	
00000000-0000-0000-0000-000000000000	91bda1e9-130f-4e5a-9d5c-535ae5b7e921	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-01 19:16:04.145327+00	
00000000-0000-0000-0000-000000000000	528a1b5a-9867-4ef9-ab7a-9e39ffeabc3e	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-01 20:15:31.620535+00	
00000000-0000-0000-0000-000000000000	dbf2e68c-1a65-43a9-a9f9-3a91151bbe7b	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-01 20:15:31.642122+00	
00000000-0000-0000-0000-000000000000	02548020-d3f0-45f2-9a0e-27b9f6e29ca0	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-01 21:27:09.032722+00	
00000000-0000-0000-0000-000000000000	4ee1ac88-7f5d-458d-9f94-65d7e0e6d013	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-01 21:27:09.052282+00	
00000000-0000-0000-0000-000000000000	d386efd9-86b2-420a-b95a-148ab7bef477	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-02 05:35:13.877399+00	
00000000-0000-0000-0000-000000000000	d02095c2-3314-4039-bce2-808c096deccd	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-02 05:35:13.906377+00	
00000000-0000-0000-0000-000000000000	c9cae7fc-a36d-4644-babc-28317dad08f6	{"action":"logout","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account"}	2025-09-02 05:41:06.160423+00	
00000000-0000-0000-0000-000000000000	6da802b3-e999-411d-9aac-e66973fe0de5	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-02 05:42:22.69854+00	
00000000-0000-0000-0000-000000000000	14726213-0f6d-4828-89bb-45b69cc57718	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-02 06:42:35.981207+00	
00000000-0000-0000-0000-000000000000	ba34c454-095e-462f-bc5d-c0a971eb1a33	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-02 06:42:35.994245+00	
00000000-0000-0000-0000-000000000000	052dda82-95e8-4963-89e1-68138b269637	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-02 07:48:30.667189+00	
00000000-0000-0000-0000-000000000000	bd4c5de2-9321-43c8-a642-a406d1755c77	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-02 07:48:30.672868+00	
00000000-0000-0000-0000-000000000000	443fc711-4962-4b43-9a54-8864c413ec15	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-02 09:08:21.016215+00	
00000000-0000-0000-0000-000000000000	91d75150-7c6a-49c0-94e3-9d1aa444affa	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-02 09:08:21.031317+00	
00000000-0000-0000-0000-000000000000	1bf4c72f-abca-4eef-b317-58da432a23ed	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-02 12:23:52.603163+00	
00000000-0000-0000-0000-000000000000	b8ceffb4-d252-43ef-9700-f92de0066050	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-02 12:23:52.616001+00	
00000000-0000-0000-0000-000000000000	aa101a1f-1032-4255-87de-41857f7d9325	{"action":"logout","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account"}	2025-09-02 12:25:51.871109+00	
00000000-0000-0000-0000-000000000000	0b0b4e09-8d46-4466-a49e-f5cb77fca9dd	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-02 12:26:41.649316+00	
00000000-0000-0000-0000-000000000000	b98ab031-2ef7-4105-8f90-bd1b2be1988c	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-02 14:42:12.277521+00	
00000000-0000-0000-0000-000000000000	b1282033-ff67-4f21-8bf3-d1ef4f4f1923	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-02 14:42:12.306965+00	
00000000-0000-0000-0000-000000000000	c8942bf3-f919-4a5b-95dc-13aea9fc7205	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-02 16:16:52.487591+00	
00000000-0000-0000-0000-000000000000	d99879d9-8735-4320-8fb0-7b59ab8e3d0c	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-02 16:16:52.498735+00	
00000000-0000-0000-0000-000000000000	7c023121-8183-45d8-8970-fc96fada1707	{"action":"token_refreshed","actor_id":"99343775-d354-4032-9938-838e382d7392","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-02 16:39:35.639168+00	
00000000-0000-0000-0000-000000000000	07cbda7c-f872-4858-a234-7075d9818a15	{"action":"token_revoked","actor_id":"99343775-d354-4032-9938-838e382d7392","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-02 16:39:35.646913+00	
00000000-0000-0000-0000-000000000000	4ed6edb6-323b-4505-baca-02b8c2f515e4	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-02 18:00:39.873648+00	
00000000-0000-0000-0000-000000000000	294b1426-6a1b-4018-98ea-4f631a661e1e	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-02 18:00:39.896919+00	
00000000-0000-0000-0000-000000000000	22c0e6f1-5c1e-422e-9443-58c175fd4ea0	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-03 05:40:22.187815+00	
00000000-0000-0000-0000-000000000000	f713247f-9acb-45a2-b00a-38b92d10043e	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-03 05:40:22.219256+00	
00000000-0000-0000-0000-000000000000	53305ba9-cfb5-44cf-b8e0-0678830206a5	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-04 14:17:45.572776+00	
00000000-0000-0000-0000-000000000000	8761a412-c674-4c1c-8535-9702ea42d447	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-04 14:17:45.593688+00	
00000000-0000-0000-0000-000000000000	dd5c930a-a505-482a-a9ba-de69fc6a1b61	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-04 15:39:11.022287+00	
00000000-0000-0000-0000-000000000000	e9d3c91e-f256-463d-b02a-c6d98c01d9cb	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-04 15:39:11.032299+00	
00000000-0000-0000-0000-000000000000	6c9aa930-6214-4c71-9c59-1eb839bf29f0	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-04 18:58:16.143035+00	
00000000-0000-0000-0000-000000000000	9d6e5327-b2b2-4bbc-aa6c-f4e6af747a67	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-04 18:58:16.154474+00	
00000000-0000-0000-0000-000000000000	5e87c7d2-d86d-4b04-93ee-bf8835ae9da6	{"action":"logout","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account"}	2025-09-04 19:22:20.800407+00	
00000000-0000-0000-0000-000000000000	fec3cf39-cff1-4c7b-ba94-a66d4aded72f	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-04 19:33:00.780012+00	
00000000-0000-0000-0000-000000000000	099c6911-fc87-4757-931e-aca51d3cc331	{"action":"logout","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account"}	2025-09-04 20:08:41.957865+00	
00000000-0000-0000-0000-000000000000	9b4c379b-4e99-4b2a-bfc7-74949ac9b0e3	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-04 20:50:37.415011+00	
00000000-0000-0000-0000-000000000000	1139d087-2f25-48b3-8695-def2fb3aa6b3	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-04 20:50:44.527896+00	
00000000-0000-0000-0000-000000000000	fa0dbcb7-7cc0-4564-8603-06eb96c0e10a	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-04 20:50:59.508779+00	
00000000-0000-0000-0000-000000000000	fb05bd86-eb6f-4565-9789-66fe56575aeb	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-04 20:50:59.822998+00	
00000000-0000-0000-0000-000000000000	1b9cbd91-00c4-48ee-88f2-640a2f3791eb	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-04 20:50:59.840187+00	
00000000-0000-0000-0000-000000000000	af3e8fa4-6532-4add-acd0-36373f0354f9	{"action":"logout","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account"}	2025-09-04 21:03:16.258797+00	
00000000-0000-0000-0000-000000000000	d44c979c-47ba-4ed9-891d-1292b9de1a3d	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-04 21:04:31.14682+00	
00000000-0000-0000-0000-000000000000	747f6cfc-7353-4d81-a4dc-59514a32cb01	{"action":"logout","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account"}	2025-09-04 21:04:36.228825+00	
00000000-0000-0000-0000-000000000000	ed7826b3-022c-49cf-b936-3a793c4b2227	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-04 21:07:56.215761+00	
00000000-0000-0000-0000-000000000000	a416fe64-70f7-4bfa-8e4f-365380636f60	{"action":"logout","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account"}	2025-09-04 21:16:35.187368+00	
00000000-0000-0000-0000-000000000000	af577e91-9119-403a-aca8-aa84ee0a506b	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-04 21:32:08.115752+00	
00000000-0000-0000-0000-000000000000	6e7f209b-d781-43a0-9d1c-b6eee3499855	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-04 21:32:11.880567+00	
00000000-0000-0000-0000-000000000000	ede66002-ec33-4216-b7f5-89353f3f1827	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-04 21:32:22.291446+00	
00000000-0000-0000-0000-000000000000	d2e9a938-77e9-4396-9a83-c4f938acb107	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-05 13:25:31.096237+00	
00000000-0000-0000-0000-000000000000	a4e5d7fd-d2bd-4071-84f3-eef547600a3a	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-05 13:25:31.125885+00	
00000000-0000-0000-0000-000000000000	504dd120-3cb8-4626-81e5-1f4064ab2c19	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-05 19:31:06.522759+00	
00000000-0000-0000-0000-000000000000	7edbbb37-c851-43c6-bb4e-22d720a6176e	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-05 19:31:06.540372+00	
00000000-0000-0000-0000-000000000000	8e9dc9f4-0143-491a-84df-42c33c0f94ef	{"action":"logout","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account"}	2025-09-05 19:31:36.378491+00	
00000000-0000-0000-0000-000000000000	1b047691-a0ae-4265-8072-c535a90b5427	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-05 19:31:46.591791+00	
00000000-0000-0000-0000-000000000000	4d4cea42-b9f6-4e0d-bf9b-0a6875b55bd0	{"action":"logout","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account"}	2025-09-05 20:30:08.521515+00	
00000000-0000-0000-0000-000000000000	a69b7969-64bc-4437-8551-2b82aa3767e4	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-05 20:30:16.500737+00	
00000000-0000-0000-0000-000000000000	8aca397c-5cad-410f-942e-b6c22987dce1	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-05 22:16:08.750742+00	
00000000-0000-0000-0000-000000000000	04ba276a-cebe-4134-91ad-22e62fd1db61	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-05 22:16:08.762778+00	
00000000-0000-0000-0000-000000000000	cf8a7e13-356b-4659-85e2-5e9ea0fa4f85	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-05 23:21:33.542076+00	
00000000-0000-0000-0000-000000000000	90c064b4-2074-40a9-b035-c9968282b396	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-05 23:21:33.562301+00	
00000000-0000-0000-0000-000000000000	83bd7be5-d974-4378-b088-e23a0b8a84df	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"ramesh@gmail.com","user_id":"a0ec38f2-7679-444e-82a7-70ffb28f4e50","user_phone":""}}	2025-09-05 23:49:57.297436+00	
00000000-0000-0000-0000-000000000000	c42520cf-8f63-4f8b-a63b-fe652f35f3b7	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-06 04:51:20.831559+00	
00000000-0000-0000-0000-000000000000	0948d6f3-1cd7-44e2-9e00-d8592b8f6a65	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-06 04:51:20.845695+00	
00000000-0000-0000-0000-000000000000	2c9df6ed-2c20-40c0-a74d-eaf03cce5b27	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-06 09:46:38.91592+00	
00000000-0000-0000-0000-000000000000	7e1ce1c8-bc86-4e59-a1c5-c65f2bcdcc7b	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-06 09:46:38.92408+00	
00000000-0000-0000-0000-000000000000	685863c6-1b8a-4f98-9768-8d284665bf18	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-06 11:04:03.921233+00	
00000000-0000-0000-0000-000000000000	14a15935-bff6-4b4d-b981-16d9d3b3c808	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-06 11:04:03.932276+00	
00000000-0000-0000-0000-000000000000	297da3d4-0b6c-418b-8983-34b1a2842535	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-06 12:13:52.90687+00	
00000000-0000-0000-0000-000000000000	49574dc2-b466-4b06-89c4-9cd98a91a035	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-06 12:13:52.925088+00	
00000000-0000-0000-0000-000000000000	f77e7937-fb19-44c3-a830-7876b1f15c62	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-06 13:13:21.260168+00	
00000000-0000-0000-0000-000000000000	9554a560-53fd-4b41-8cbc-8a83f8a7435f	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-06 13:13:21.271641+00	
00000000-0000-0000-0000-000000000000	25fb6d03-dee8-491d-b644-15e17e8f74ed	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-06 14:13:00.029165+00	
00000000-0000-0000-0000-000000000000	dc1cfcf8-4468-483c-96c1-e919121a5ac6	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-06 14:13:00.054435+00	
00000000-0000-0000-0000-000000000000	210db50a-e04d-4075-a45a-7f814be8bf6e	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-06 15:12:21.351959+00	
00000000-0000-0000-0000-000000000000	b5822b39-f768-48ac-af84-ff8ae97b25f4	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-06 15:12:21.359687+00	
00000000-0000-0000-0000-000000000000	93195e39-28c8-4931-94a2-45fb2731e8cb	{"action":"logout","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account"}	2025-09-06 15:30:55.366961+00	
00000000-0000-0000-0000-000000000000	4f90b866-2bd4-41ef-a468-41742097db2f	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-06 15:31:08.875337+00	
00000000-0000-0000-0000-000000000000	c97d68e2-016c-4359-9c02-bc8beaa9d9d0	{"action":"logout","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account"}	2025-09-06 15:31:22.790741+00	
00000000-0000-0000-0000-000000000000	df2b0d50-ec3e-4621-b547-1f37d6422cf5	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"piyushachopda@gmail.com","user_id":"99343775-d354-4032-9938-838e382d7392","user_phone":""}}	2025-09-06 15:32:15.887097+00	
00000000-0000-0000-0000-000000000000	29e1afec-b243-440f-b8a5-1c527f4ca47e	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"piyushachopda@gmail.com","user_id":"704edb97-e111-47ad-8bd4-6e418733d871","user_phone":""}}	2025-09-06 15:32:34.921662+00	
00000000-0000-0000-0000-000000000000	ed629bd6-6540-4b7e-87e3-eced3fb35c40	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"ramesh1@gmail.com","user_id":"47f47d86-cee3-4d06-88ce-bf12bf64ed83","user_phone":""}}	2025-09-06 15:33:05.158445+00	
00000000-0000-0000-0000-000000000000	67748060-a5dd-4b28-9256-74e9dcb70347	{"action":"login","actor_id":"a0ec38f2-7679-444e-82a7-70ffb28f4e50","actor_username":"ramesh@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-06 15:33:33.809177+00	
00000000-0000-0000-0000-000000000000	086ececb-b600-4e83-9ec5-6aeeefc22543	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"piyushachopda@gmail.com","user_id":"704edb97-e111-47ad-8bd4-6e418733d871","user_phone":""}}	2025-09-06 17:46:11.319197+00	
00000000-0000-0000-0000-000000000000	63a0f496-8aff-41a2-8aee-245ab1c856bf	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"piyushachopda@gmail.com","user_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","user_phone":""}}	2025-09-06 17:46:44.534199+00	
00000000-0000-0000-0000-000000000000	3f4f344d-9485-4ed2-9923-80dc00de1938	{"action":"login","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-06 18:47:14.178625+00	
00000000-0000-0000-0000-000000000000	74b421ad-9c38-47c3-ae81-91a3d3da49f6	{"action":"token_refreshed","actor_id":"a0ec38f2-7679-444e-82a7-70ffb28f4e50","actor_username":"ramesh@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-06 19:39:12.456242+00	
00000000-0000-0000-0000-000000000000	d650a1c2-9ac0-4d03-96c9-e568ba18eeca	{"action":"token_revoked","actor_id":"a0ec38f2-7679-444e-82a7-70ffb28f4e50","actor_username":"ramesh@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-06 19:39:12.478778+00	
00000000-0000-0000-0000-000000000000	abb73817-e2b4-4eff-97ac-d77d00cc1b43	{"action":"logout","actor_id":"a0ec38f2-7679-444e-82a7-70ffb28f4e50","actor_username":"ramesh@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-09-06 19:39:39.542442+00	
00000000-0000-0000-0000-000000000000	c9f21c71-867f-4f00-8b75-03e1b5f72d62	{"action":"login","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-06 19:40:32.782215+00	
00000000-0000-0000-0000-000000000000	8ce3020a-e6e3-4d5c-8360-342a4e785421	{"action":"logout","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-09-06 19:49:14.622367+00	
00000000-0000-0000-0000-000000000000	a0588f0b-4b4d-43fa-96c9-f77cad06f323	{"action":"token_refreshed","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-06 20:05:59.358993+00	
00000000-0000-0000-0000-000000000000	11ed0278-ba25-4750-a461-2f5950d6e3dd	{"action":"token_revoked","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-06 20:05:59.374871+00	
00000000-0000-0000-0000-000000000000	58a2c391-ee70-4440-b7df-44081dfb0b60	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-06 20:36:07.347959+00	
00000000-0000-0000-0000-000000000000	72b397cb-6923-4a8b-92c3-c75560fad430	{"action":"logout","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account"}	2025-09-06 20:52:22.082947+00	
00000000-0000-0000-0000-000000000000	65470a59-07ba-4b6a-8a68-e9f166b6d687	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-06 20:53:20.317085+00	
00000000-0000-0000-0000-000000000000	226d1064-8033-471a-9556-f1fcdfa42259	{"action":"token_refreshed","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-07 05:02:00.376781+00	
00000000-0000-0000-0000-000000000000	5c117b41-2a99-414a-bd4b-6cb075def30b	{"action":"login","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-07 05:02:00.40325+00	
00000000-0000-0000-0000-000000000000	a6c1b08c-b37d-4bc2-b0a7-408936bc57c2	{"action":"token_revoked","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-07 05:02:00.405355+00	
00000000-0000-0000-0000-000000000000	95ea2b15-1fa8-4e48-b9c2-4581fd688c23	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-07 05:05:36.834936+00	
00000000-0000-0000-0000-000000000000	6bc3ed71-e40c-49c0-a122-6594abf1b09b	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-07 05:05:36.837589+00	
00000000-0000-0000-0000-000000000000	81a2eac6-46f6-4bd1-9756-69606553b794	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-10 21:34:48.377417+00	
00000000-0000-0000-0000-000000000000	c7288326-ed96-4146-9d32-76bbcf7b6948	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"ramesh2@gmail.com","user_id":"64d66009-940a-4390-934c-7addbbf0ea4c","user_phone":""}}	2025-09-07 05:14:50.857097+00	
00000000-0000-0000-0000-000000000000	5e5c52d7-8380-4dbe-9cd2-75239dfef96f	{"action":"logout","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account"}	2025-09-07 05:15:16.294578+00	
00000000-0000-0000-0000-000000000000	7661b1c3-d8c7-4842-a996-138cf2660faa	{"action":"login","actor_id":"64d66009-940a-4390-934c-7addbbf0ea4c","actor_username":"ramesh2@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-07 05:15:25.608238+00	
00000000-0000-0000-0000-000000000000	50e62acf-1bf1-4c61-82b9-9e112651f0aa	{"action":"token_refreshed","actor_id":"64d66009-940a-4390-934c-7addbbf0ea4c","actor_username":"ramesh2@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-07 06:14:52.717639+00	
00000000-0000-0000-0000-000000000000	0374ab46-427a-4dbf-be2c-265ac5c39431	{"action":"token_revoked","actor_id":"64d66009-940a-4390-934c-7addbbf0ea4c","actor_username":"ramesh2@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-07 06:14:52.740044+00	
00000000-0000-0000-0000-000000000000	594c46fd-a972-4d84-9074-246f1eedab22	{"action":"token_refreshed","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-07 06:19:45.418634+00	
00000000-0000-0000-0000-000000000000	3ca5d8ab-b37a-4fa1-8e21-0dc2f5cf29f1	{"action":"token_revoked","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-07 06:19:45.421754+00	
00000000-0000-0000-0000-000000000000	939159f4-9cf4-4840-ad59-8c2f0e6062b7	{"action":"token_refreshed","actor_id":"64d66009-940a-4390-934c-7addbbf0ea4c","actor_username":"ramesh2@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-07 07:14:25.489692+00	
00000000-0000-0000-0000-000000000000	15636b65-d627-4fea-82fb-f9282ac296d6	{"action":"token_revoked","actor_id":"64d66009-940a-4390-934c-7addbbf0ea4c","actor_username":"ramesh2@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-07 07:14:25.518324+00	
00000000-0000-0000-0000-000000000000	bbb3a98e-15b9-4526-9cd7-c1854829e543	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"ramesh3@gmail.com","user_id":"56736673-15b9-4b01-83cb-4a0c1356df2e","user_phone":""}}	2025-09-07 08:13:00.703001+00	
00000000-0000-0000-0000-000000000000	5ec62563-3ba1-493a-81b3-69e1553ca5c2	{"action":"token_refreshed","actor_id":"64d66009-940a-4390-934c-7addbbf0ea4c","actor_username":"ramesh2@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-07 08:13:51.082224+00	
00000000-0000-0000-0000-000000000000	cf55c46c-b460-4cc7-9bf3-ae21cb29b6f7	{"action":"token_revoked","actor_id":"64d66009-940a-4390-934c-7addbbf0ea4c","actor_username":"ramesh2@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-07 08:13:51.084756+00	
00000000-0000-0000-0000-000000000000	02ae28f1-8e04-48c6-85c9-24aa572177f0	{"action":"token_refreshed","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-07 08:16:43.627994+00	
00000000-0000-0000-0000-000000000000	a79f41ac-60cb-44f0-83ae-a7cf72494028	{"action":"token_revoked","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-07 08:16:43.629347+00	
00000000-0000-0000-0000-000000000000	ebc19758-7f27-47fb-9edf-a87f7fffc912	{"action":"user_updated_password","actor_id":"64d66009-940a-4390-934c-7addbbf0ea4c","actor_username":"ramesh2@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-09-07 09:11:31.751315+00	
00000000-0000-0000-0000-000000000000	e00ef212-8924-4354-81ff-596f931bcaed	{"action":"user_modified","actor_id":"64d66009-940a-4390-934c-7addbbf0ea4c","actor_username":"ramesh2@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-09-07 09:11:31.76626+00	
00000000-0000-0000-0000-000000000000	05b78962-6fbf-4a23-a04a-d74709420e62	{"action":"token_refreshed","actor_id":"64d66009-940a-4390-934c-7addbbf0ea4c","actor_username":"ramesh2@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-07 09:15:30.335869+00	
00000000-0000-0000-0000-000000000000	a78221b9-9cf9-4675-822e-2a47553ad314	{"action":"token_revoked","actor_id":"64d66009-940a-4390-934c-7addbbf0ea4c","actor_username":"ramesh2@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-07 09:15:30.342064+00	
00000000-0000-0000-0000-000000000000	d3bf30c4-fa85-4d17-8c7d-dd21aa5bdf4f	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-10 12:50:31.899782+00	
00000000-0000-0000-0000-000000000000	d53a1bb6-c24c-49fe-be2a-1a1f6b703e08	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-10 13:50:02.469386+00	
00000000-0000-0000-0000-000000000000	733923f1-d8fd-43c9-ab3d-c564e5c5e8b0	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-10 13:50:02.485149+00	
00000000-0000-0000-0000-000000000000	864dde0b-34fc-4025-8c95-ab2070b62f0b	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-10 14:49:32.30098+00	
00000000-0000-0000-0000-000000000000	bcb4ec67-8db3-4ff4-ba9b-a876d1afdea4	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-10 14:49:32.318006+00	
00000000-0000-0000-0000-000000000000	f981b8c0-cef4-45a0-b4a6-bd55339a6785	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-10 15:49:00.953744+00	
00000000-0000-0000-0000-000000000000	31c3805a-e648-4161-a670-75be564723c5	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-10 15:49:00.968601+00	
00000000-0000-0000-0000-000000000000	922ea72a-6212-4f9b-8db9-8ecae0c576aa	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-10 16:48:30.999365+00	
00000000-0000-0000-0000-000000000000	81b9d854-6bf0-42ab-89cc-3304b2ae675b	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-10 16:48:31.014519+00	
00000000-0000-0000-0000-000000000000	103a815f-ad32-444f-9aad-88048efb5c35	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-10 18:36:26.325172+00	
00000000-0000-0000-0000-000000000000	658ac917-c2d7-44b5-933c-3ffa38da7585	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-10 18:36:26.340538+00	
00000000-0000-0000-0000-000000000000	f64114b4-ae8a-4e2c-a25c-fa0995d7da38	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-10 19:35:49.932891+00	
00000000-0000-0000-0000-000000000000	328cdb2c-82a4-4def-9df8-be614df0855e	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-10 19:35:49.953744+00	
00000000-0000-0000-0000-000000000000	f60ddd86-9a43-484f-9e78-e8d566ee0486	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-10 20:35:20.115384+00	
00000000-0000-0000-0000-000000000000	31c0281a-2187-4ff3-ba00-aef00b958250	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-10 20:35:20.13286+00	
00000000-0000-0000-0000-000000000000	ddb3c9ad-d179-4f10-b506-56ba65758760	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-10 21:34:48.399714+00	
00000000-0000-0000-0000-000000000000	80378661-4082-4171-a7b9-f3d21f04fd2e	{"action":"token_refreshed","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-10 21:54:15.795802+00	
00000000-0000-0000-0000-000000000000	3904fd2b-073d-4022-bc6c-3770c2fc3ee0	{"action":"token_revoked","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-10 21:54:15.813408+00	
00000000-0000-0000-0000-000000000000	fa404c74-14b3-4e02-a73f-1eb6752d6521	{"action":"login","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-10 21:54:15.851077+00	
00000000-0000-0000-0000-000000000000	452b66fb-be01-407c-9eb5-46d27aecae94	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-10 22:33:50.593018+00	
00000000-0000-0000-0000-000000000000	868e3fee-8a89-491f-8107-7338da6c1b28	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-11 13:00:56.154879+00	
00000000-0000-0000-0000-000000000000	21878346-3424-418a-a0da-e7b954780370	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-11 13:00:56.183408+00	
00000000-0000-0000-0000-000000000000	1f0d421d-b54c-4841-9f3f-cd7822fcd050	{"action":"logout","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account"}	2025-09-11 13:10:32.488171+00	
00000000-0000-0000-0000-000000000000	a90f7f8f-3994-4ba1-b823-09f6c3388b60	{"action":"login","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-11 13:10:48.047103+00	
00000000-0000-0000-0000-000000000000	a31c8a83-3bcf-4cd6-9d15-912c51505e8e	{"action":"token_refreshed","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-11 13:21:48.449419+00	
00000000-0000-0000-0000-000000000000	b5a75d42-7653-4864-8cce-ea1158592ab6	{"action":"token_revoked","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-11 13:21:48.455585+00	
00000000-0000-0000-0000-000000000000	82bf9505-d826-42f6-9501-a92420dd73ec	{"action":"login","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-11 13:22:28.317711+00	
00000000-0000-0000-0000-000000000000	46e55968-0143-496b-9ffe-047cbb4085db	{"action":"token_refreshed","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-11 14:21:47.745558+00	
00000000-0000-0000-0000-000000000000	63ae0386-04f9-47c9-a360-e38d1081f555	{"action":"token_revoked","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-11 14:21:47.765762+00	
00000000-0000-0000-0000-000000000000	973b2cba-62f0-4b56-b140-5afe170a1479	{"action":"token_refreshed","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-11 14:22:20.840382+00	
00000000-0000-0000-0000-000000000000	3d41cbf7-8c91-43d3-99ca-13bffda5a710	{"action":"token_revoked","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-11 14:22:20.841738+00	
00000000-0000-0000-0000-000000000000	bef445f3-8fa1-4ef0-98ce-cd0d79390922	{"action":"token_refreshed","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-11 15:21:09.185691+00	
00000000-0000-0000-0000-000000000000	f9f929cf-0ec2-4917-bf8a-6c48372f7e10	{"action":"token_revoked","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-11 15:21:09.199933+00	
00000000-0000-0000-0000-000000000000	48c182dd-0602-4ee1-bf00-691b235f6ca9	{"action":"token_refreshed","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-11 15:44:33.526249+00	
00000000-0000-0000-0000-000000000000	faaddfa9-2342-4ac3-baee-b06d4c5aeb09	{"action":"token_revoked","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-11 15:44:33.536515+00	
00000000-0000-0000-0000-000000000000	c805359b-aba7-4384-9077-93d04a049803	{"action":"token_refreshed","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-11 16:20:44.038838+00	
00000000-0000-0000-0000-000000000000	d97113f8-2902-4e8a-9c48-799582949595	{"action":"token_revoked","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-11 16:20:44.057002+00	
00000000-0000-0000-0000-000000000000	688f2ee3-dfe5-498b-814d-4ec33c7708bc	{"action":"token_refreshed","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-11 16:44:37.894175+00	
00000000-0000-0000-0000-000000000000	7726d1f2-b2b0-4ea4-8f2d-0df6e769d365	{"action":"token_revoked","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-11 16:44:37.902018+00	
00000000-0000-0000-0000-000000000000	dce373fb-89ac-40af-a367-bfe60654b53c	{"action":"token_refreshed","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-11 17:20:09.325361+00	
00000000-0000-0000-0000-000000000000	6a151d4b-cc03-49a2-b999-08436626eaf5	{"action":"token_revoked","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-11 17:20:09.335184+00	
00000000-0000-0000-0000-000000000000	807d0d74-e781-4134-8489-04e2ce501906	{"action":"token_refreshed","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-11 18:19:31.931027+00	
00000000-0000-0000-0000-000000000000	dc888c9e-24b3-4c73-aad2-770f7a674d11	{"action":"token_revoked","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-11 18:19:31.943243+00	
00000000-0000-0000-0000-000000000000	f1d2d1fb-5322-4fcd-8adf-701afba519ee	{"action":"token_refreshed","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-11 19:19:01.752798+00	
00000000-0000-0000-0000-000000000000	3432b778-e0a6-42be-ab1f-f7f50a107a86	{"action":"token_revoked","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-11 19:19:01.769542+00	
00000000-0000-0000-0000-000000000000	4b79bcc2-083a-45d7-a669-6d97bf2b6273	{"action":"token_refreshed","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-11 19:53:06.388216+00	
00000000-0000-0000-0000-000000000000	75a34591-a9a2-46d8-a081-9f27d131f335	{"action":"token_revoked","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-11 19:53:06.401349+00	
00000000-0000-0000-0000-000000000000	c73a9075-7303-43ba-8343-323feb0e52d8	{"action":"login","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-11 19:53:06.450455+00	
00000000-0000-0000-0000-000000000000	c12b117f-7583-43d0-84b2-7cdc15a8b9e2	{"action":"token_refreshed","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-11 21:22:00.804636+00	
00000000-0000-0000-0000-000000000000	f1943728-3440-40da-acdc-3407bd98fcf4	{"action":"token_revoked","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-11 21:22:00.836749+00	
00000000-0000-0000-0000-000000000000	bc44432d-76d1-434c-8c55-f71e8dc428d0	{"action":"token_refreshed","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-11 21:46:44.637491+00	
00000000-0000-0000-0000-000000000000	0c5d47ae-7559-4360-80aa-5c8686f90b25	{"action":"token_revoked","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-11 21:46:44.642702+00	
00000000-0000-0000-0000-000000000000	afe68974-5694-43f7-b22b-f19ef1355b8b	{"action":"logout","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-09-11 21:48:43.393809+00	
00000000-0000-0000-0000-000000000000	03a3c314-3bce-4e39-9c26-90113bc720ab	{"action":"login","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-11 21:49:10.915829+00	
00000000-0000-0000-0000-000000000000	bdb8e5c5-a4d3-468c-8446-082fe347887c	{"action":"token_refreshed","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-12 05:22:28.772299+00	
00000000-0000-0000-0000-000000000000	0d27b8ca-0122-41a1-904b-50e5946f032d	{"action":"token_revoked","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-12 05:22:28.798128+00	
00000000-0000-0000-0000-000000000000	39be8a04-5023-4cb8-bafa-e318b3a9b6e8	{"action":"token_refreshed","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-12 11:55:52.789701+00	
00000000-0000-0000-0000-000000000000	46aba2bd-2e74-4ae3-9b0d-9df227ae4347	{"action":"token_revoked","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-12 11:55:52.818906+00	
00000000-0000-0000-0000-000000000000	f692b521-a428-43ec-b1af-63384226eecf	{"action":"token_refreshed","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-12 19:32:35.831781+00	
00000000-0000-0000-0000-000000000000	7e91cdb2-5d67-432b-99b0-fd797800b2bd	{"action":"token_revoked","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-12 19:32:35.855369+00	
00000000-0000-0000-0000-000000000000	6095d66b-78a2-47f1-96f7-f660a5d35aee	{"action":"token_refreshed","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-12 20:35:14.608199+00	
00000000-0000-0000-0000-000000000000	db9a9419-dc0e-4dbf-a047-2fdbd891d307	{"action":"token_revoked","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-12 20:35:14.623581+00	
00000000-0000-0000-0000-000000000000	897428fc-d5ff-4ed0-8fd7-5cce0af09a2c	{"action":"logout","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-09-12 20:48:04.978981+00	
00000000-0000-0000-0000-000000000000	06becc6f-0c5b-4ed0-a06b-6f2837ffeeb5	{"action":"login","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 20:48:15.746815+00	
00000000-0000-0000-0000-000000000000	f9d1549e-53c7-429f-83bc-9d3b70ffb4fd	{"action":"login","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 21:08:48.20669+00	
00000000-0000-0000-0000-000000000000	373d4324-5832-486a-94ad-706dec296c0a	{"action":"login","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 21:09:30.306765+00	
00000000-0000-0000-0000-000000000000	4dfb6655-7313-4c23-83d9-2a00ae07f6ce	{"action":"login","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 21:10:30.622151+00	
00000000-0000-0000-0000-000000000000	2edff6cc-d69d-4d56-a8cf-33434e624672	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 21:41:22.104008+00	
00000000-0000-0000-0000-000000000000	dd21684c-cff7-41e9-a96a-42e7546bed01	{"action":"login","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 21:48:47.852738+00	
00000000-0000-0000-0000-000000000000	e879257e-8821-485d-9cd2-5c276db9cb4b	{"action":"login","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 22:11:10.817028+00	
00000000-0000-0000-0000-000000000000	8ae891f3-34e2-4250-b302-988e93255f90	{"action":"token_refreshed","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-13 04:08:26.558373+00	
00000000-0000-0000-0000-000000000000	8aa06dc0-b8d5-4567-90d8-bedc47f90fef	{"action":"token_revoked","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-13 04:08:26.583371+00	
00000000-0000-0000-0000-000000000000	d2a78fc9-b28e-4feb-9ad0-173bdb0c2715	{"action":"login","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-13 04:24:07.938123+00	
00000000-0000-0000-0000-000000000000	ffc8199f-76be-407b-8737-38762f93344b	{"action":"login","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-13 04:26:06.054721+00	
00000000-0000-0000-0000-000000000000	0f0f94c5-9da3-4f15-99fd-c114155929f8	{"action":"token_refreshed","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-13 08:16:30.732132+00	
00000000-0000-0000-0000-000000000000	567f2901-3027-46bb-ad77-e16073bfe999	{"action":"token_revoked","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-13 08:16:30.758462+00	
00000000-0000-0000-0000-000000000000	28b4f758-4007-4963-8df4-2f14bc1f4a1c	{"action":"login","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-13 08:17:45.941668+00	
00000000-0000-0000-0000-000000000000	311797d8-2020-4135-95e1-5f84833dd15a	{"action":"login","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-13 08:31:32.650732+00	
00000000-0000-0000-0000-000000000000	dd5fa09c-105f-4fac-b1e7-4fa22d11e9f8	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-13 18:25:54.768997+00	
00000000-0000-0000-0000-000000000000	e9859437-5e87-48a0-8f99-e7bd2df12f8a	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-13 18:25:54.779253+00	
00000000-0000-0000-0000-000000000000	c4a64b23-cacc-48d6-aaf1-f8d405d406b1	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-13 19:25:18.804971+00	
00000000-0000-0000-0000-000000000000	68538d09-1de8-493d-9010-f3a595b7b092	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-13 19:25:18.81777+00	
00000000-0000-0000-0000-000000000000	43f3d774-8882-49df-bc62-12583253fc52	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 03:53:51.975936+00	
00000000-0000-0000-0000-000000000000	e8067387-720a-4423-81c2-0b4ae3cb902d	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 03:53:51.99591+00	
00000000-0000-0000-0000-000000000000	50113773-ba32-4095-a63c-385cc2986ba4	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 04:53:18.374658+00	
00000000-0000-0000-0000-000000000000	b74f5a7c-6e58-4698-9299-e4ba031ca8ec	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 04:53:18.393524+00	
00000000-0000-0000-0000-000000000000	e862c69d-601a-4941-93e5-a0c441a0c14d	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 08:25:16.878368+00	
00000000-0000-0000-0000-000000000000	acf603ff-60db-4e20-b964-6d9ca8383d36	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 08:25:16.907078+00	
00000000-0000-0000-0000-000000000000	e59bbb7c-8b10-4122-bb3c-3ef87d4f9681	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 09:24:40.197133+00	
00000000-0000-0000-0000-000000000000	693872e9-0d74-4ba2-9ebc-b3fa78370c26	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 09:24:40.208183+00	
00000000-0000-0000-0000-000000000000	a844715d-087f-4bb1-9404-18c8b3c808bd	{"action":"logout","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account"}	2025-09-14 10:06:17.877715+00	
00000000-0000-0000-0000-000000000000	4b197ae3-14b0-4d21-9633-f79a030f0f5a	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"rider2@test.com","user_id":"11d3bfc3-51e8-43fc-b41a-24b2a0e0caff","user_phone":""}}	2025-09-14 10:07:52.531204+00	
00000000-0000-0000-0000-000000000000	64d94229-9ee5-417e-9d22-2017a63f50a7	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-14 10:16:45.43044+00	
00000000-0000-0000-0000-000000000000	aad85ca3-a6c9-4205-9d78-87d30c93ebcd	{"action":"logout","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account"}	2025-09-14 10:17:41.014938+00	
00000000-0000-0000-0000-000000000000	640d0f71-55ce-40ad-9b1c-64aed3234833	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-14 10:19:38.571973+00	
00000000-0000-0000-0000-000000000000	949e1a5b-f4f0-4888-b136-87d868ddd543	{"action":"logout","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account"}	2025-09-14 10:19:50.696816+00	
00000000-0000-0000-0000-000000000000	a4840d95-0425-4953-a7b5-2a9ec55d166a	{"action":"login","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-14 10:20:50.782404+00	
00000000-0000-0000-0000-000000000000	56418cee-9ae5-4e59-afa3-a9c7eb8a608c	{"action":"token_refreshed","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 11:20:18.850769+00	
00000000-0000-0000-0000-000000000000	498cb3d7-cb53-4907-a5c1-ab5f11e68a5e	{"action":"token_revoked","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 11:20:18.876207+00	
00000000-0000-0000-0000-000000000000	299c526e-b277-4bb7-8537-c4d440b23c1d	{"action":"token_refreshed","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 12:19:48.600073+00	
00000000-0000-0000-0000-000000000000	f6c6c19d-01a6-4831-a7ad-19b74478c180	{"action":"token_revoked","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 12:19:48.61299+00	
00000000-0000-0000-0000-000000000000	769b862f-0e97-4c37-9753-a6da143d1810	{"action":"token_refreshed","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 13:28:01.343378+00	
00000000-0000-0000-0000-000000000000	04928534-eeb2-4cbd-9752-70339b99bd69	{"action":"token_revoked","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 13:28:01.352303+00	
00000000-0000-0000-0000-000000000000	4b80e8f4-f3f1-4f62-afd3-ddedce5a1dec	{"action":"logout","actor_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","actor_username":"piyushachopda@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-09-14 13:50:36.517378+00	
00000000-0000-0000-0000-000000000000	69e77b32-7462-4707-bed4-8a031d826187	{"action":"login","actor_id":"11d3bfc3-51e8-43fc-b41a-24b2a0e0caff","actor_username":"rider2@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-14 13:52:00.916924+00	
00000000-0000-0000-0000-000000000000	f66c1d1d-dbc4-497c-9e2d-79e81448b04e	{"action":"token_refreshed","actor_id":"11d3bfc3-51e8-43fc-b41a-24b2a0e0caff","actor_username":"rider2@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 14:51:21.354253+00	
00000000-0000-0000-0000-000000000000	ce796e2e-73d3-44b8-a02a-603d12133779	{"action":"token_revoked","actor_id":"11d3bfc3-51e8-43fc-b41a-24b2a0e0caff","actor_username":"rider2@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 14:51:21.364113+00	
00000000-0000-0000-0000-000000000000	5673571b-c666-42c1-88f8-9949793d77c0	{"action":"token_refreshed","actor_id":"11d3bfc3-51e8-43fc-b41a-24b2a0e0caff","actor_username":"rider2@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 15:50:43.431208+00	
00000000-0000-0000-0000-000000000000	17856c6c-4e50-491f-986c-f4b40f4ffece	{"action":"token_revoked","actor_id":"11d3bfc3-51e8-43fc-b41a-24b2a0e0caff","actor_username":"rider2@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 15:50:43.456541+00	
00000000-0000-0000-0000-000000000000	97d815ad-0249-4d6b-8f71-386cf0f280af	{"action":"token_refreshed","actor_id":"11d3bfc3-51e8-43fc-b41a-24b2a0e0caff","actor_username":"rider2@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 16:50:13.303352+00	
00000000-0000-0000-0000-000000000000	8fd92633-a598-45ce-ab21-2f05d8d72a08	{"action":"token_revoked","actor_id":"11d3bfc3-51e8-43fc-b41a-24b2a0e0caff","actor_username":"rider2@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 16:50:13.323591+00	
00000000-0000-0000-0000-000000000000	46c089bc-4c4b-43a1-9c63-c4bd5383d69f	{"action":"token_refreshed","actor_id":"11d3bfc3-51e8-43fc-b41a-24b2a0e0caff","actor_username":"rider2@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 17:49:43.52114+00	
00000000-0000-0000-0000-000000000000	23acf0bb-b603-4055-a3c2-8a8095b01559	{"action":"token_revoked","actor_id":"11d3bfc3-51e8-43fc-b41a-24b2a0e0caff","actor_username":"rider2@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 17:49:43.535115+00	
00000000-0000-0000-0000-000000000000	0df40a72-29ab-4568-a724-70373f5e12c1	{"action":"token_refreshed","actor_id":"11d3bfc3-51e8-43fc-b41a-24b2a0e0caff","actor_username":"rider2@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 18:49:13.371448+00	
00000000-0000-0000-0000-000000000000	7390f316-2add-41a1-91c7-cfb815313b3e	{"action":"token_revoked","actor_id":"11d3bfc3-51e8-43fc-b41a-24b2a0e0caff","actor_username":"rider2@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 18:49:13.406504+00	
00000000-0000-0000-0000-000000000000	8877d515-c6a8-4f9a-9c94-1ce8f974b0d0	{"action":"token_refreshed","actor_id":"11d3bfc3-51e8-43fc-b41a-24b2a0e0caff","actor_username":"rider2@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 20:05:30.528165+00	
00000000-0000-0000-0000-000000000000	1100edcf-9aa8-4f6b-b5de-4bd0551fda90	{"action":"token_revoked","actor_id":"11d3bfc3-51e8-43fc-b41a-24b2a0e0caff","actor_username":"rider2@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 20:05:30.556151+00	
00000000-0000-0000-0000-000000000000	015e98b5-4290-4220-99b8-52b3fb788f70	{"action":"token_refreshed","actor_id":"11d3bfc3-51e8-43fc-b41a-24b2a0e0caff","actor_username":"rider2@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 21:04:58.764511+00	
00000000-0000-0000-0000-000000000000	9c32fd3d-e606-4c13-9b29-5fc8751374e0	{"action":"token_revoked","actor_id":"11d3bfc3-51e8-43fc-b41a-24b2a0e0caff","actor_username":"rider2@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 21:04:58.78783+00	
00000000-0000-0000-0000-000000000000	18caf4d8-722b-46f9-a470-d9ffbb09ba18	{"action":"logout","actor_id":"11d3bfc3-51e8-43fc-b41a-24b2a0e0caff","actor_username":"rider2@test.com","actor_via_sso":false,"log_type":"account"}	2025-09-14 21:26:59.800619+00	
00000000-0000-0000-0000-000000000000	6b39c202-c8bf-4f39-8a98-fdd57a67a0ba	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"ramesh@gmail.com","user_id":"a0ec38f2-7679-444e-82a7-70ffb28f4e50","user_phone":""}}	2025-09-14 21:29:31.434397+00	
00000000-0000-0000-0000-000000000000	6e125e07-2432-44d9-ac07-e5b7e41d075a	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"ramesh1@gmail.com","user_id":"47f47d86-cee3-4d06-88ce-bf12bf64ed83","user_phone":""}}	2025-09-14 21:29:31.462232+00	
00000000-0000-0000-0000-000000000000	5850f903-6722-4972-bba0-3ddb8a2eec4a	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"piyushachopda@gmail.com","user_id":"69fbe8a2-4de6-4391-94de-8e033fe88367","user_phone":""}}	2025-09-14 21:29:31.4707+00	
00000000-0000-0000-0000-000000000000	b6dfed6c-8e25-4d67-abb2-ca6222249859	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"ramesh3@gmail.com","user_id":"56736673-15b9-4b01-83cb-4a0c1356df2e","user_phone":""}}	2025-09-14 21:29:31.474165+00	
00000000-0000-0000-0000-000000000000	0c25f051-32ab-4d4b-b852-b70df46db7c3	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"ramesh2@gmail.com","user_id":"64d66009-940a-4390-934c-7addbbf0ea4c","user_phone":""}}	2025-09-14 21:29:31.482991+00	
00000000-0000-0000-0000-000000000000	cd2b7605-19aa-420a-9fcf-d32e603ea297	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"piyushachopda@gmail.com","user_id":"61ee72f3-86fb-479e-85b8-bf11e8a2afc1","user_phone":""}}	2025-09-14 21:30:12.7089+00	
00000000-0000-0000-0000-000000000000	c4ae1f92-29cd-4368-9f3b-7c35c10c6ad8	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"rider3@test.com","user_id":"4dae6d8d-62ca-46d4-add9-bd130f378c13","user_phone":""}}	2025-09-14 21:31:40.405761+00	
00000000-0000-0000-0000-000000000000	759792da-c389-410f-817a-3afb55cc35bd	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"rider4@test.com","user_id":"d83b750d-91a5-4ece-bf37-7011cb22b799","user_phone":""}}	2025-09-14 21:32:04.311996+00	
00000000-0000-0000-0000-000000000000	e10c30f7-18fd-4461-a839-cc80485a0809	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"driver2@test.com","user_id":"28155795-4f28-4bee-8d8b-0942374f686c","user_phone":""}}	2025-09-14 21:32:25.501165+00	
00000000-0000-0000-0000-000000000000	6e87b1b6-aab7-47cf-aa9f-214bd15a309c	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"driver4@test.com","user_id":"363951ed-96c5-4f83-bfb2-96ac79185810","user_phone":""}}	2025-09-14 21:33:01.807967+00	
00000000-0000-0000-0000-000000000000	7111cc6e-6418-4eef-be87-16be5b15d48a	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"driver1@test.com","user_id":"e7ee6464-8c67-4289-a3ee-07cfa171cf09","user_phone":""}}	2025-09-14 21:33:27.239067+00	
00000000-0000-0000-0000-000000000000	e333fa97-9808-4ded-9c8b-32d7d529d4da	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"driver3@test.com","user_id":"42ed6b22-71c9-4ab1-b241-8ae1c9774bfb","user_phone":""}}	2025-09-14 21:33:51.630236+00	
00000000-0000-0000-0000-000000000000	52cb3242-0a04-4107-ba56-a4ea04e29f70	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"rider5@test.com","user_id":"bc4dd838-f609-41de-8784-c5661a206112","user_phone":""}}	2025-09-14 21:34:27.340985+00	
00000000-0000-0000-0000-000000000000	6d556c93-d438-4193-ad68-320d68617365	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"rider1@test.com","user_id":"122fe3ff-6708-49c2-bed2-58bd3acb4702","user_phone":""}}	2025-09-14 21:34:53.130332+00	
00000000-0000-0000-0000-000000000000	7e21d119-3637-4389-bdf9-597bf7214f34	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-15 07:34:08.569213+00	
00000000-0000-0000-0000-000000000000	ee21278c-b6fc-4aee-9dfc-6dd7d02b5f01	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-15 13:23:15.70477+00	
00000000-0000-0000-0000-000000000000	bb52bfe6-ce3e-41ff-9481-5eded6b4e243	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-15 13:23:15.732604+00	
00000000-0000-0000-0000-000000000000	c33b514e-5711-4b8c-aea8-5962dcf2f98b	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-15 14:22:43.568607+00	
00000000-0000-0000-0000-000000000000	219ee881-9986-45c9-af74-6edfaf39e5a4	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-15 14:22:43.583646+00	
00000000-0000-0000-0000-000000000000	73c3c42e-1835-4eb4-bdd0-1061fd0da5db	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"rider2@test.com","user_id":"11d3bfc3-51e8-43fc-b41a-24b2a0e0caff","user_phone":""}}	2025-09-15 18:51:37.974973+00	
00000000-0000-0000-0000-000000000000	95b253f3-dc25-4c67-a227-6569d7e04421	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"driver3@test.com","user_id":"42ed6b22-71c9-4ab1-b241-8ae1c9774bfb","user_phone":""}}	2025-09-15 18:51:37.97457+00	
00000000-0000-0000-0000-000000000000	253c08fe-6fdf-4cb8-99fe-34b3b99f7fd1	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"driver2@test.com","user_id":"28155795-4f28-4bee-8d8b-0942374f686c","user_phone":""}}	2025-09-15 18:51:37.974695+00	
00000000-0000-0000-0000-000000000000	da3c6ca4-f566-417f-87d6-fd62d6545bfa	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"rider1@test.com","user_id":"122fe3ff-6708-49c2-bed2-58bd3acb4702","user_phone":""}}	2025-09-15 18:51:37.970619+00	
00000000-0000-0000-0000-000000000000	f1cbdcef-56f7-42f3-aca6-836e32ae7b5a	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"driver4@test.com","user_id":"363951ed-96c5-4f83-bfb2-96ac79185810","user_phone":""}}	2025-09-15 18:51:37.974427+00	
00000000-0000-0000-0000-000000000000	a03c2ac6-3300-4f4e-b874-65c3043fba03	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"rider5@test.com","user_id":"bc4dd838-f609-41de-8784-c5661a206112","user_phone":""}}	2025-09-15 18:51:37.977108+00	
00000000-0000-0000-0000-000000000000	89d1db69-fd2a-4f84-915a-53bd104f45c6	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"rider4@test.com","user_id":"d83b750d-91a5-4ece-bf37-7011cb22b799","user_phone":""}}	2025-09-15 18:51:38.040989+00	
00000000-0000-0000-0000-000000000000	163c0a09-2af1-4be7-b2cc-003e42dfc1d3	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"driver1@test.com","user_id":"e7ee6464-8c67-4289-a3ee-07cfa171cf09","user_phone":""}}	2025-09-15 18:51:37.972002+00	
00000000-0000-0000-0000-000000000000	6502018d-c447-4519-9ec1-1eebe6a10e25	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"rider3@test.com","user_id":"4dae6d8d-62ca-46d4-add9-bd130f378c13","user_phone":""}}	2025-09-15 18:51:37.974796+00	
00000000-0000-0000-0000-000000000000	69a55dfb-0a4a-42d3-8be6-0372410dfb1e	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"driver@test.com","user_id":"e4dbcfe6-396d-4507-88b1-3c325b466b2a","user_phone":""}}	2025-09-15 18:51:37.970583+00	
00000000-0000-0000-0000-000000000000	f216da3a-b353-4c12-92bc-252a7473c3dc	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"piyushachopda@gmail.com","user_id":"61ee72f3-86fb-479e-85b8-bf11e8a2afc1","user_phone":""}}	2025-09-15 19:12:43.101566+00	
00000000-0000-0000-0000-000000000000	69b668e1-44bd-4bb3-b209-ae93d2da2f06	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"chopccy@gmail.com","user_id":"1cd0d596-1c26-4112-83a5-f1275c15c351","user_phone":""}}	2025-09-15 19:12:43.230869+00	
00000000-0000-0000-0000-000000000000	c726cd0b-207a-4d60-a715-e322df938143	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-16 04:59:53.715956+00	
00000000-0000-0000-0000-000000000000	4eda374b-caf5-4d66-99e2-258ceadb57bf	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-16 04:59:53.742159+00	
00000000-0000-0000-0000-000000000000	64c440ab-112b-482e-9f86-fe0eb0370d49	{"action":"logout","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account"}	2025-09-16 05:13:34.740941+00	
00000000-0000-0000-0000-000000000000	6a2f19dd-f404-48d5-8eab-227c066d6be7	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-16 05:14:15.472185+00	
00000000-0000-0000-0000-000000000000	51cf1161-4175-418a-9947-e5c836ad3223	{"action":"logout","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account"}	2025-09-16 05:14:29.890231+00	
00000000-0000-0000-0000-000000000000	f8d8a0f7-9c0c-4de5-9ebe-2afb7a1eb478	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-16 06:45:47.974084+00	
00000000-0000-0000-0000-000000000000	dd6e4d8c-8514-482b-9ac3-ac0a7c4459b9	{"action":"token_refreshed","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-16 07:45:11.045814+00	
00000000-0000-0000-0000-000000000000	727990e1-c1ec-40eb-b12e-7a66fb9022ef	{"action":"token_revoked","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"token"}	2025-09-16 07:45:11.072218+00	
00000000-0000-0000-0000-000000000000	e0210fe2-c88c-4378-9357-98b4c4e5a7ea	{"action":"logout","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account"}	2025-09-16 08:33:30.991156+00	
00000000-0000-0000-0000-000000000000	43450aab-6026-4d43-90bf-11fc467cbeb8	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-16 18:57:49.100453+00	
00000000-0000-0000-0000-000000000000	49dd7527-9be8-4e64-b29b-81a5509a9e23	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-16 19:24:35.856871+00	
00000000-0000-0000-0000-000000000000	4b93cd79-f8af-4c94-b519-5cc96e2da137	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-16 19:29:29.772575+00	
00000000-0000-0000-0000-000000000000	f0724620-a326-4176-9aa7-5c818b5285fb	{"action":"login","actor_id":"29f33f6a-fa33-4db2-ae95-c856677e5c05","actor_username":"rider@test.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-16 19:39:34.437282+00	
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at) FROM stdin;
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
29f33f6a-fa33-4db2-ae95-c856677e5c05	29f33f6a-fa33-4db2-ae95-c856677e5c05	{"sub": "29f33f6a-fa33-4db2-ae95-c856677e5c05", "email": "rider@test.com", "email_verified": false, "phone_verified": false}	email	2025-09-01 08:54:33.199507+00	2025-09-01 08:54:33.19956+00	2025-09-01 08:54:33.19956+00	eb148b22-fb2e-46cd-9a7d-c663a61da5e2
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
6702d3a1-e94e-4e62-b2d7-0513af2f45c4	2025-09-04 20:50:37.463011+00	2025-09-04 20:50:37.463011+00	password	46dde4e2-bb44-4a2f-b1f4-0773640bca22
467df310-84a1-406a-876b-7ac5120e9554	2025-09-04 20:50:44.533151+00	2025-09-04 20:50:44.533151+00	password	39ceb89e-e195-4564-a5d8-6a4114639d0d
9f18bd77-31a7-4042-a6ae-aa0e4c18dc92	2025-09-04 20:50:59.518003+00	2025-09-04 20:50:59.518003+00	password	4d808c7b-d571-4eae-82c1-1f54da15731b
4a0f7f57-ecd3-454b-b5b6-55dfc803bf3f	2025-09-04 20:50:59.825785+00	2025-09-04 20:50:59.825785+00	password	d0fbce64-d932-4bb0-85d1-49250eed787d
d7041543-6d6f-4af8-be28-385b222edb35	2025-09-04 21:32:08.150758+00	2025-09-04 21:32:08.150758+00	password	4c184433-48b1-47bb-83fc-1b3d389b079f
03002399-85db-4c13-80d6-bfa00e70c413	2025-09-04 21:32:11.887155+00	2025-09-04 21:32:11.887155+00	password	b35c3df3-d5e0-4047-82cc-0935b69dda73
4cfcf719-546b-4256-a31d-7fdda266a9e9	2025-09-10 12:50:32.016089+00	2025-09-10 12:50:32.016089+00	password	b0a476bb-5c90-4f53-933f-d5c3b031cada
cb98823f-23bb-4715-a5e0-4f5caea06a3b	2025-09-16 18:57:49.17531+00	2025-09-16 18:57:49.17531+00	password	2abd4bb0-2f3f-40e4-ac03-5e717285bfd3
c8793515-b3d2-4c61-ad0d-4b65f66ce328	2025-09-16 19:24:35.955696+00	2025-09-16 19:24:35.955696+00	password	f3aed492-ee62-4ead-9739-aaf91a90081c
7762619e-c791-46ab-98eb-ec2914ed52aa	2025-09-16 19:29:29.783683+00	2025-09-16 19:29:29.783683+00	password	431ca0b3-d669-4793-9817-47aa6aaa0030
51356590-d789-4185-a195-1f2408224493	2025-09-16 19:39:34.469815+00	2025-09-16 19:39:34.469815+00	password	0819b851-be1b-4a3e-843c-b5e0c8fda02f
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code, web_authn_session_data) FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at, web_authn_credential, web_authn_aaguid) FROM stdin;
\.


--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_clients (id, client_id, client_secret_hash, registration_type, redirect_uris, grant_types, client_name, client_uri, logo_uri, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
00000000-0000-0000-0000-000000000000	39	t6sh2o3pw5s5	29f33f6a-fa33-4db2-ae95-c856677e5c05	f	2025-09-04 21:32:08.137028+00	2025-09-04 21:32:08.137028+00	\N	d7041543-6d6f-4af8-be28-385b222edb35
00000000-0000-0000-0000-000000000000	40	wsqxud5jjhlg	29f33f6a-fa33-4db2-ae95-c856677e5c05	f	2025-09-04 21:32:11.884654+00	2025-09-04 21:32:11.884654+00	\N	03002399-85db-4c13-80d6-bfa00e70c413
00000000-0000-0000-0000-000000000000	79	vvjrpmttqwte	29f33f6a-fa33-4db2-ae95-c856677e5c05	t	2025-09-10 19:35:49.972844+00	2025-09-10 20:35:20.133575+00	sz7bu7kqx2ga	4cfcf719-546b-4256-a31d-7fdda266a9e9
00000000-0000-0000-0000-000000000000	80	q5fgirzezux4	29f33f6a-fa33-4db2-ae95-c856677e5c05	t	2025-09-10 20:35:20.148111+00	2025-09-10 21:34:48.405226+00	vvjrpmttqwte	4cfcf719-546b-4256-a31d-7fdda266a9e9
00000000-0000-0000-0000-000000000000	81	z2lqlcmqpwjw	29f33f6a-fa33-4db2-ae95-c856677e5c05	f	2025-09-10 21:34:48.42507+00	2025-09-10 21:34:48.42507+00	q5fgirzezux4	4cfcf719-546b-4256-a31d-7fdda266a9e9
00000000-0000-0000-0000-000000000000	147	6v5p4uq3n2bx	29f33f6a-fa33-4db2-ae95-c856677e5c05	f	2025-09-16 18:57:49.137772+00	2025-09-16 18:57:49.137772+00	\N	cb98823f-23bb-4715-a5e0-4f5caea06a3b
00000000-0000-0000-0000-000000000000	148	hizzphtvmsax	29f33f6a-fa33-4db2-ae95-c856677e5c05	f	2025-09-16 19:24:35.902945+00	2025-09-16 19:24:35.902945+00	\N	c8793515-b3d2-4c61-ad0d-4b65f66ce328
00000000-0000-0000-0000-000000000000	149	sldhq67ambgs	29f33f6a-fa33-4db2-ae95-c856677e5c05	f	2025-09-16 19:29:29.778051+00	2025-09-16 19:29:29.778051+00	\N	7762619e-c791-46ab-98eb-ec2914ed52aa
00000000-0000-0000-0000-000000000000	150	d7wgokd5twwm	29f33f6a-fa33-4db2-ae95-c856677e5c05	f	2025-09-16 19:39:34.448767+00	2025-09-16 19:39:34.448767+00	\N	51356590-d789-4185-a195-1f2408224493
00000000-0000-0000-0000-000000000000	32	yeodu6rpzaer	29f33f6a-fa33-4db2-ae95-c856677e5c05	f	2025-09-04 20:50:37.443228+00	2025-09-04 20:50:37.443228+00	\N	6702d3a1-e94e-4e62-b2d7-0513af2f45c4
00000000-0000-0000-0000-000000000000	33	7lbvk5mksb4o	29f33f6a-fa33-4db2-ae95-c856677e5c05	f	2025-09-04 20:50:44.530096+00	2025-09-04 20:50:44.530096+00	\N	467df310-84a1-406a-876b-7ac5120e9554
00000000-0000-0000-0000-000000000000	34	7rvtnegal6ee	29f33f6a-fa33-4db2-ae95-c856677e5c05	f	2025-09-04 20:50:59.516076+00	2025-09-04 20:50:59.516076+00	\N	9f18bd77-31a7-4042-a6ae-aa0e4c18dc92
00000000-0000-0000-0000-000000000000	35	wmpintfyd67q	29f33f6a-fa33-4db2-ae95-c856677e5c05	f	2025-09-04 20:50:59.824684+00	2025-09-04 20:50:59.824684+00	\N	4a0f7f57-ecd3-454b-b5b6-55dfc803bf3f
00000000-0000-0000-0000-000000000000	73	7lxwxrd7fphg	29f33f6a-fa33-4db2-ae95-c856677e5c05	t	2025-09-10 12:50:31.959135+00	2025-09-10 13:50:02.486937+00	\N	4cfcf719-546b-4256-a31d-7fdda266a9e9
00000000-0000-0000-0000-000000000000	74	b3enajcst5nb	29f33f6a-fa33-4db2-ae95-c856677e5c05	t	2025-09-10 13:50:02.507021+00	2025-09-10 14:49:32.319315+00	7lxwxrd7fphg	4cfcf719-546b-4256-a31d-7fdda266a9e9
00000000-0000-0000-0000-000000000000	75	pyuedreqaais	29f33f6a-fa33-4db2-ae95-c856677e5c05	t	2025-09-10 14:49:32.32841+00	2025-09-10 15:49:00.969283+00	b3enajcst5nb	4cfcf719-546b-4256-a31d-7fdda266a9e9
00000000-0000-0000-0000-000000000000	76	rrfaagj4mz2v	29f33f6a-fa33-4db2-ae95-c856677e5c05	t	2025-09-10 15:49:00.986685+00	2025-09-10 16:48:31.015198+00	pyuedreqaais	4cfcf719-546b-4256-a31d-7fdda266a9e9
00000000-0000-0000-0000-000000000000	77	j7pkupmczvyy	29f33f6a-fa33-4db2-ae95-c856677e5c05	t	2025-09-10 16:48:31.026237+00	2025-09-10 18:36:26.341252+00	rrfaagj4mz2v	4cfcf719-546b-4256-a31d-7fdda266a9e9
00000000-0000-0000-0000-000000000000	78	sz7bu7kqx2ga	29f33f6a-fa33-4db2-ae95-c856677e5c05	t	2025-09-10 18:36:26.354041+00	2025-09-10 19:35:49.955757+00	j7pkupmczvyy	4cfcf719-546b-4256-a31d-7fdda266a9e9
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format) FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.schema_migrations (version) FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221125140132
20221208132122
20221215195500
20221215195800
20221215195900
20230116124310
20230116124412
20230131181311
20230322519590
20230402418590
20230411005111
20230508135423
20230523124323
20230818113222
20230914180801
20231027141322
20231114161723
20231117164230
20240115144230
20240214120130
20240306115329
20240314092811
20240427152123
20240612123726
20240729123726
20240802193726
20240806073726
20241009103726
20250717082212
20250731150234
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag) FROM stdin;
cb98823f-23bb-4715-a5e0-4f5caea06a3b	29f33f6a-fa33-4db2-ae95-c856677e5c05	2025-09-16 18:57:49.114941+00	2025-09-16 18:57:49.114941+00	\N	aal1	\N	\N	node	117.217.60.29	\N
c8793515-b3d2-4c61-ad0d-4b65f66ce328	29f33f6a-fa33-4db2-ae95-c856677e5c05	2025-09-16 19:24:35.884426+00	2025-09-16 19:24:35.884426+00	\N	aal1	\N	\N	node	117.217.60.29	\N
7762619e-c791-46ab-98eb-ec2914ed52aa	29f33f6a-fa33-4db2-ae95-c856677e5c05	2025-09-16 19:29:29.776831+00	2025-09-16 19:29:29.776831+00	\N	aal1	\N	\N	node	117.217.60.29	\N
51356590-d789-4185-a195-1f2408224493	29f33f6a-fa33-4db2-ae95-c856677e5c05	2025-09-16 19:39:34.441879+00	2025-09-16 19:39:34.441879+00	\N	aal1	\N	\N	node	117.217.60.29	\N
6702d3a1-e94e-4e62-b2d7-0513af2f45c4	29f33f6a-fa33-4db2-ae95-c856677e5c05	2025-09-04 20:50:37.433573+00	2025-09-04 20:50:37.433573+00	\N	aal1	\N	\N	Dart/3.9 (dart:io)	110.226.181.219	\N
467df310-84a1-406a-876b-7ac5120e9554	29f33f6a-fa33-4db2-ae95-c856677e5c05	2025-09-04 20:50:44.529263+00	2025-09-04 20:50:44.529263+00	\N	aal1	\N	\N	Dart/3.9 (dart:io)	110.226.181.219	\N
9f18bd77-31a7-4042-a6ae-aa0e4c18dc92	29f33f6a-fa33-4db2-ae95-c856677e5c05	2025-09-04 20:50:59.513569+00	2025-09-04 20:50:59.513569+00	\N	aal1	\N	\N	Dart/3.9 (dart:io)	110.226.181.219	\N
4a0f7f57-ecd3-454b-b5b6-55dfc803bf3f	29f33f6a-fa33-4db2-ae95-c856677e5c05	2025-09-04 20:50:59.824002+00	2025-09-04 20:50:59.824002+00	\N	aal1	\N	\N	Dart/3.9 (dart:io)	110.226.181.219	\N
d7041543-6d6f-4af8-be28-385b222edb35	29f33f6a-fa33-4db2-ae95-c856677e5c05	2025-09-04 21:32:08.127787+00	2025-09-04 21:32:08.127787+00	\N	aal1	\N	\N	Dart/3.9 (dart:io)	110.226.181.219	\N
03002399-85db-4c13-80d6-bfa00e70c413	29f33f6a-fa33-4db2-ae95-c856677e5c05	2025-09-04 21:32:11.881442+00	2025-09-04 21:32:11.881442+00	\N	aal1	\N	\N	Dart/3.9 (dart:io)	110.226.181.219	\N
4cfcf719-546b-4256-a31d-7fdda266a9e9	29f33f6a-fa33-4db2-ae95-c856677e5c05	2025-09-10 12:50:31.928873+00	2025-09-10 21:34:48.446365+00	\N	aal1	\N	2025-09-10 21:34:48.445677	Dart/3.3 (dart:io)	110.226.183.236	\N
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at, disabled) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) FROM stdin;
00000000-0000-0000-0000-000000000000	29f33f6a-fa33-4db2-ae95-c856677e5c05	authenticated	authenticated	rider@test.com	$2a$10$VELk09q7B6QQVdcyc5PK5e3/s9aPEqZVIU5NFCbvU0o.xuunch95K	2025-09-01 08:54:33.202181+00	\N		\N		\N			\N	2025-09-16 19:39:34.441149+00	{"provider": "email", "providers": ["email"]}	{"email_verified": true}	\N	2025-09-01 08:54:33.198412+00	2025-09-16 19:39:34.467682+00	\N	\N			\N		0	\N		\N	f	\N	f
\.


--
-- Data for Name: admins; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.admins (user_id, created_at) FROM stdin;
\.


--
-- Data for Name: booking_deposits; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.booking_deposits (id, booking_id, user_id, deposit_amount_inr, deposit_status, deposit_paid_at, deposit_released_at, wallet_reserve_tx_id, wallet_release_tx_id, created_at, updated_at) FROM stdin;
d95ceab9-ce6d-40bb-862e-20ef91c25d69	564fa265-2d61-460c-bca4-c2d1cfe3a843	11d3bfc3-51e8-43fc-b41a-24b2a0e0caff	225	held	\N	\N	\N	\N	2025-09-14 20:05:49.761051+00	2025-09-14 20:05:49.761051+00
\.


--
-- Data for Name: bookings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.bookings (id, ride_id, rider_id, from_stop_id, to_stop_id, seats_booked, fare_total_inr, status, created_at, updated_at, deposit_status, requires_deposit, rider_deposit_inr, pickup_stop_id, drop_stop_id, total_fare_inr, rejection_reason, deposit_inr) FROM stdin;
447c3df5-38cb-4f3c-be06-8155094c183f	56ca39cd-93b4-4a10-b147-890794a38390	b878f371-ebe5-45fc-9e9a-5a84d7a36c15	a878c6fc-23de-459d-9296-84080608ac41	2508c4db-fc44-4ffc-84c5-f89995b88a7a	1	600	pending	2025-08-21 11:34:55.706018+00	2025-09-19 02:10:26.196951+00	pending	f	0	a878c6fc-23de-459d-9296-84080608ac41	2508c4db-fc44-4ffc-84c5-f89995b88a7a	0.00	\N	0
d0f8083f-b10d-4c1b-aa98-423b08dc8c53	56ca39cd-93b4-4a10-b147-890794a38390	b878f371-ebe5-45fc-9e9a-5a84d7a36c15	a878c6fc-23de-459d-9296-84080608ac41	2508c4db-fc44-4ffc-84c5-f89995b88a7a	1	600	completed	2025-08-21 11:49:47.687607+00	2025-09-19 02:10:26.196951+00	pending	f	0	a878c6fc-23de-459d-9296-84080608ac41	2508c4db-fc44-4ffc-84c5-f89995b88a7a	0.00	\N	0
a4c09c8b-5aaf-46b8-b49d-825495f0e9ae	84170402-ce72-4725-9a79-703e7a34902d	11d3bfc3-51e8-43fc-b41a-24b2a0e0caff	a878c6fc-23de-459d-9296-84080608ac41	dd33f1a0-3bc8-4bd5-8c2d-58b13a88d0a0	1	450	confirmed	2025-09-14 15:08:03.424531+00	2025-09-19 02:10:26.196951+00	pending	f	0	a878c6fc-23de-459d-9296-84080608ac41	dd33f1a0-3bc8-4bd5-8c2d-58b13a88d0a0	0.00	\N	0
564fa265-2d61-460c-bca4-c2d1cfe3a843	84170402-ce72-4725-9a79-703e7a34902d	11d3bfc3-51e8-43fc-b41a-24b2a0e0caff	a878c6fc-23de-459d-9296-84080608ac41	dd33f1a0-3bc8-4bd5-8c2d-58b13a88d0a0	1	450	cancelled	2025-09-14 20:05:49.088611+00	2025-09-19 02:10:26.196951+00	pending	f	0	a878c6fc-23de-459d-9296-84080608ac41	dd33f1a0-3bc8-4bd5-8c2d-58b13a88d0a0	0.00	\N	0
f389bdea-682a-49b4-b55a-7db767478b91	7822046a-7f09-4f60-bdfd-f3b88913ecd7	2d7a0d90-276b-4aa7-a8d5-2ff4a59659c1	a878c6fc-23de-459d-9296-84080608ac41	dd33f1a0-3bc8-4bd5-8c2d-58b13a88d0a0	1	500	confirmed	2025-09-19 17:12:38.324106+00	2025-09-19 17:12:38.324106+00	pending	f	0	\N	\N	0.00	\N	100
7b5aa08d-82f8-49f6-8cb8-24e626449675	7822046a-7f09-4f60-bdfd-f3b88913ecd7	2d7a0d90-276b-4aa7-a8d5-2ff4a59659c1	a878c6fc-23de-459d-9296-84080608ac41	dd33f1a0-3bc8-4bd5-8c2d-58b13a88d0a0	1	500	confirmed	2025-09-19 17:17:12.606612+00	2025-09-19 17:17:12.606612+00	pending	f	0	\N	\N	0.00	\N	100
76a1cc44-9ba8-40a0-81ad-1bb6fad2392b	7822046a-7f09-4f60-bdfd-f3b88913ecd7	2d7a0d90-276b-4aa7-a8d5-2ff4a59659c1	a878c6fc-23de-459d-9296-84080608ac41	dd33f1a0-3bc8-4bd5-8c2d-58b13a88d0a0	1	500	confirmed	2025-09-19 17:22:58.414921+00	2025-09-19 17:22:58.414921+00	pending	f	0	\N	\N	0.00	\N	100
14997cb2-1596-4461-9fe5-60fb5846d637	84170402-ce72-4725-9a79-703e7a34902d	2d7a0d90-276b-4aa7-a8d5-2ff4a59659c1	a878c6fc-23de-459d-9296-84080608ac41	dd33f1a0-3bc8-4bd5-8c2d-58b13a88d0a0	1	450	confirmed	2025-09-19 17:28:37.094031+00	2025-09-19 17:28:37.094031+00	pending	f	0	\N	\N	0.00	\N	90
1448ff5b-9f17-4a19-b729-9eb8aca4e7cc	7822046a-7f09-4f60-bdfd-f3b88913ecd7	2d7a0d90-276b-4aa7-a8d5-2ff4a59659c1	a878c6fc-23de-459d-9296-84080608ac41	dd33f1a0-3bc8-4bd5-8c2d-58b13a88d0a0	1	500	confirmed	2025-09-19 17:52:31.731902+00	2025-09-19 17:52:31.731902+00	pending	f	0	\N	\N	0.00	\N	100
04962ad9-78d6-42a0-a896-1110242e5e09	479532a2-d738-455f-965f-74c74749bf84	2d7a0d90-276b-4aa7-a8d5-2ff4a59659c1	a878c6fc-23de-459d-9296-84080608ac41	dd33f1a0-3bc8-4bd5-8c2d-58b13a88d0a0	1	0	confirmed	2025-09-19 19:08:50.606403+00	2025-09-19 19:08:50.606403+00	pending	f	0	\N	\N	0.00	\N	50
49614588-7413-4a9f-8fa4-8a18e45b26ab	b9cd8990-1b59-479e-83f1-40880d71752e	2d7a0d90-276b-4aa7-a8d5-2ff4a59659c1	a878c6fc-23de-459d-9296-84080608ac41	dd33f1a0-3bc8-4bd5-8c2d-58b13a88d0a0	1	500	confirmed	2025-09-19 21:32:51.619312+00	2025-09-19 21:32:51.619312+00	pending	f	0	\N	\N	0.00	\N	100
\.


--
-- Data for Name: cancellation_policies; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cancellation_policies (id, ride_type, actor, hours_threshold_1, penalty_percentage_1, hours_threshold_2, penalty_percentage_2, hours_threshold_3, penalty_percentage_3, is_active, created_at, updated_at) FROM stdin;
ebdb2b5b-1002-45fd-878f-251c75da3725	private	both	12	20.00	6	40.00	0	60.00	t	2025-09-12 06:13:34.992689+00	2025-09-12 10:55:55.973779+00
b77dd6cf-bdbc-4cea-9034-aa683c84b155	commercial_full	both	12	30.00	6	40.00	0	60.00	t	2025-09-12 06:13:35.590017+00	2025-09-12 11:56:19.383966+00
65a865df-5fb9-40e8-97df-7082e1668d93	commercial	both	12	30.00	6	40.00	0	60.00	t	2025-09-12 06:13:35.312724+00	2025-09-12 19:35:32.372616+00
\.


--
-- Data for Name: cancellations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cancellations (id, booking_id, cancelled_by, cancelled_at, hours_before_depart, penalty_inr, note, policy_id, penalty_percentage, penalty_recipient_id, processed, penalty_tx_id, refund_tx_id) FROM stdin;
\.


--
-- Data for Name: cities; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cities (id, name, state, country, created_at, state_code, is_active, display_order, updated_at) FROM stdin;
627545c8-f3f5-4474-94b5-122f1a50cb2d	Mumbai	Maharashtra	India	2025-08-19 13:19:34.564934+00	MH	t	1	2025-09-13 18:44:21.912053+00
026cbc1c-79bc-4cec-b143-7f1e2bac31b7	Pune	Maharashtra	India	2025-08-19 13:19:34.564934+00	MH	t	2	2025-09-13 18:44:21.912053+00
50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	Nashik	Maharashtra	India	2025-08-31 05:26:34.500498+00	MH	t	3	2025-09-13 18:44:21.912053+00
3b5e7c03-ab0a-4563-a3cd-d8406e46768f	Aurangabad	Maharashtra	India	2025-09-11 19:23:48.989268+00	MH	t	5	2025-09-13 18:44:21.912053+00
51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	Nagpur	Maharashtra	India	2025-09-11 19:23:48.989268+00	MH	t	6	2025-09-13 18:44:21.912053+00
03c170b0-a315-459a-81a3-00db16bdc9d9	Thane	Maharashtra	India	2025-09-11 19:23:48.989268+00	MH	t	4	2025-09-13 18:44:21.912053+00
4253134e-580d-4cce-a083-99c73399705f	Navi Mumbai	Maharashtra	India	2025-09-13 17:53:22.555806+00	MH	t	0	2025-09-13 18:44:21.912053+00
51ea939c-9cdd-45b7-9c79-7b1aa4b5fe5f	Kolhapur	Maharashtra	India	2025-09-11 19:23:48.989268+00	MH	t	7	2025-09-13 18:44:21.912053+00
c68159e6-24da-4d92-a460-35ed1aea3814	Solapur	Maharashtra	India	2025-09-13 17:53:22.555806+00	MH	t	0	2025-09-13 18:44:21.912053+00
fc194277-addd-49f2-bb6d-350f0719b08d	Amravati	Maharashtra	India	2025-09-13 17:53:22.555806+00	MH	t	0	2025-09-13 18:44:21.912053+00
2a849b4b-374f-4ef0-b208-4ba5b9c30067	Jalgaon	Maharashtra	India	2025-09-13 04:10:39.664001+00	MH	t	0	2025-09-13 18:44:21.912053+00
cd9d3803-6cec-4d13-a2cf-fd434a37076e	Sangli	Maharashtra	India	2025-09-13 17:53:22.555806+00	MH	t	0	2025-09-13 18:44:21.912053+00
268987e8-7182-45a9-9a36-c30c9ecaf462	Akola	Maharashtra	India	2025-09-13 17:53:22.555806+00	MH	t	0	2025-09-13 18:44:21.912053+00
5de202fc-f0bb-4eb0-a2f6-97ba45c5ecac	Ratnagiri	Maharashtra	India	2025-09-13 17:53:22.555806+00	MH	t	0	2025-09-13 18:44:21.912053+00
63e57908-1733-4897-984b-7de1b32ee609	Satara	Maharashtra	India	2025-09-13 17:53:22.555806+00	MH	t	0	2025-09-13 18:44:21.912053+00
e2523f1f-b9a9-4191-a275-63b4d04822bf	Nanded	Maharashtra	India	2025-09-13 17:53:22.555806+00	MH	t	0	2025-09-13 18:44:21.912053+00
54a58b5c-1608-466e-b77f-ecbc3a0a4298	Latur	Maharashtra	India	2025-09-13 17:53:22.555806+00	MH	t	0	2025-09-13 18:44:21.912053+00
42c2b1de-2c19-41ce-a4ad-2ae38987324c	Ahmednagar	Maharashtra	India	2025-09-13 17:53:22.555806+00	MH	t	0	2025-09-13 18:44:21.912053+00
048ef14e-7d86-4e79-9f70-549c4aa5a49b	Chandrapur	Maharashtra	India	2025-09-13 17:53:22.555806+00	MH	t	0	2025-09-13 18:44:21.912053+00
c0045a1e-e024-437f-a8df-9bbbe37f85fe	Parbhani	Maharashtra	India	2025-09-13 17:53:22.555806+00	MH	t	0	2025-09-13 18:44:21.912053+00
d36d2cb6-1066-4b83-8f35-c829d1922e72	Jalna	Maharashtra	India	2025-09-13 17:53:22.555806+00	MH	t	0	2025-09-13 18:44:21.912053+00
5851f794-bd3f-4e10-a87c-78cf0cf73cc8	Beed	Maharashtra	India	2025-09-13 17:53:22.555806+00	MH	t	0	2025-09-13 18:44:21.912053+00
334a0c23-66de-44da-a535-9336fd035c76	Wardha	Maharashtra	India	2025-09-13 17:53:22.555806+00	MH	t	0	2025-09-13 18:44:21.912053+00
1bd5def6-8b5c-493b-acab-e146bbc593a0	Delhi	Delhi	India	2025-09-15 08:10:45.797266+00	\N	t	0	2025-09-15 08:10:45.797266+00
67b30625-6d0b-4366-bdbe-5a45580ecf1d	Bangalore	Karnataka	India	2025-09-15 08:10:45.797266+00	\N	t	0	2025-09-15 08:10:45.797266+00
31ca99b8-ea6f-4565-b7d8-956a30bc4d19	Dhule	\N	India	2025-09-01 14:08:48.168218+00	\N	t	999	2025-09-11 19:23:48.989268+00
0ac5edcc-de13-42f6-87c1-5d41e4bc0a33	Washim	Maharashtra	India	2025-09-13 17:53:22.555806+00	MH	t	0	2025-09-13 17:53:22.555806+00
cc7b1d9c-789f-44d8-932e-ee19595a8bdf	Osmanabad	Maharashtra	India	2025-09-13 17:53:22.555806+00	MH	t	0	2025-09-13 17:53:22.555806+00
4b845014-36ce-4921-ac76-25ba98a9e6f8	Buldhana	Maharashtra	India	2025-09-13 17:53:22.555806+00	MH	t	0	2025-09-13 17:53:22.555806+00
31213c7f-4eb6-4800-9494-0a3bc5224869	Yavatmal	Maharashtra	India	2025-09-13 17:53:22.555806+00	MH	t	0	2025-09-13 17:53:22.555806+00
a2518ea5-883d-4e13-97ff-b70d4ff0f3be	Gadchiroli	Maharashtra	India	2025-09-13 17:53:22.555806+00	MH	t	0	2025-09-13 17:53:22.555806+00
be73a573-959b-4150-9795-0ec7388fdd32	Bhandara	Maharashtra	India	2025-09-13 17:53:22.555806+00	MH	t	0	2025-09-13 17:53:22.555806+00
a1f85b26-30f0-42ea-a05e-643c72d92018	Gondia	Maharashtra	India	2025-09-13 17:53:22.555806+00	MH	t	0	2025-09-13 17:53:22.555806+00
fbbfa31f-ce16-4a78-8f91-c382e3b02c55	Hingoli	Maharashtra	India	2025-09-13 17:53:22.555806+00	MH	t	0	2025-09-13 17:53:22.555806+00
ccf6efca-3140-4f9f-9401-d39cd904d89c	Sindhudurg	Maharashtra	India	2025-09-13 17:53:22.555806+00	MH	t	0	2025-09-13 17:53:22.555806+00
\.


--
-- Data for Name: deposit_intents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.deposit_intents (id, user_id, amount_inr, method, status, razorpay_order_id, razorpay_payment_id, razorpay_signature, notes, created_at, updated_at) FROM stdin;
d476f3d1-8d41-419f-b547-80295f825327	29f33f6a-fa33-4db2-ae95-c856677e5c05	200	razorpay	paid	order_1757999548525	pay_1757999550143	signature_1757999550143	\N	2025-09-16 05:12:28.864503+00	2025-09-16 05:12:30.826+00
473504df-cc8b-4cd5-a003-4158bee7d7d5	29f33f6a-fa33-4db2-ae95-c856677e5c05	200	razorpay	paid	order_1757999581722	pay_1757999583309	signature_1757999583309	\N	2025-09-16 05:13:02.06482+00	2025-09-16 05:13:03.951+00
cb635ac6-960d-4597-b9b7-ad6ed052e546	91e928d8-36e0-4805-83e7-da36d3dd4fdc	10000	razorpay	paid	order_1758087707481	pay_1758087708794	signature_1758087708794	\N	2025-09-17 05:41:47.396178+00	2025-09-17 05:41:50.348+00
deb8527c-0298-408d-bab8-254fb7f6dbd9	2d7a0d90-276b-4aa7-a8d5-2ff4a59659c1	1000	razorpay	paid	order_1758301738138	pay_1758301739467	signature_1758301739467	\N	2025-09-19 17:08:58.383491+00	2025-09-19 17:09:00.892+00
\.


--
-- Data for Name: inbox_messages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.inbox_messages (id, thread_id, sender_id, body, meta, created_at) FROM stdin;
\.


--
-- Data for Name: inbox_threads; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.inbox_threads (id, ride_id, rider_id, driver_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: kyc_documents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.kyc_documents (id, user_id, doc_type, doc_number, file_url, verification_status, verified_at, verified_by, rejection_reason, uploaded_at) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notifications (id, user_id, title, body, data, created_at, read) FROM stdin;
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payments (id, booking_id, provider, order_id, payment_id, amount_inr, status, raw_payload, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.profiles (id, bio, date_of_birth, gender, profile_picture_url, address, city, state, country, is_aadhaar_verified, is_license_verified, is_vehicle_verified, is_doc_verified, profile_completion_percentage, chat_preference, music_preference, pets_preference, smoking_preference, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: ride_allowed_stops; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ride_allowed_stops (id, ride_id, stop_id) FROM stdin;
\.


--
-- Data for Name: ride_deposit_requirements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ride_deposit_requirements (id, ride_id, rider_deposit_inr, driver_deposit_inr, auto_refund_hours, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: rides; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.rides (id, driver_id, route_id, depart_date, depart_time, price_per_seat_inr, seats_total, seats_available, car_make, car_model, car_plate, notes, is_active, created_at, updated_at, status, allow_auto_confirm, created_by, is_commercial, allow_auto_book, ride_type, from_city_id, to_city_id, selected_pickup_stops, selected_drop_stops, "from", "to", pickup_stop_id, drop_stop_id, vehicle_type, vehicle_make, vehicle_model, vehicle_plate, additional_notes, requires_deposit, deposit_amount, auto_approve_bookings, auto_approve) FROM stdin;
7822046a-7f09-4f60-bdfd-f3b88913ecd7	6245df15-d1be-41a7-a773-4f6230839326	58ee9f29-af5f-4de6-ac97-16aa5b172e4b	2025-09-24	18:00:00	500	4	0	\N	\N	\N	\N	t	2025-09-19 16:52:10.058+00	2025-09-19 17:52:32.234561+00	published	t	\N	f	\N	private_pool	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
a758438f-d885-4f6f-9e91-a00df56cec0b	2d7a0d90-276b-4aa7-a8d5-2ff4a59659c1	58ee9f29-af5f-4de6-ac97-16aa5b172e4b	2025-09-29	04:00:00	600	4	4	\N	\N	\N	\N	t	2025-09-19 17:51:04.37+00	2025-09-19 17:51:04.37+00	published	t	\N	f	\N	private_pool	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
015daf07-c946-4da6-8912-c3cc17194189	29f33f6a-fa33-4db2-ae95-c856677e5c05	\N	2025-09-02	23:31:00	600	1	1	\N	\N	\N	\N	t	2025-09-02 18:01:15.741876+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
f47c9a5c-4c6d-4c60-93e6-250212bb3657	\N	\N	2025-09-06	02:29:00	600	1	1	\N	\N	\N	\N	t	2025-09-05 20:59:54.933173+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	private_pool	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
34a45e85-1d45-43a5-a72c-1a9e86747667	29f33f6a-fa33-4db2-ae95-c856677e5c05	\N	2025-09-02	05:32:00	200	3	3	\N	\N	\N	\N	t	2025-09-01 20:02:42.027162+00	2025-09-19 02:10:26.196951+00	published	t	29f33f6a-fa33-4db2-ae95-c856677e5c05	f	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
f62b0bb9-03c1-4eba-b246-cc3ee5c89784	29f33f6a-fa33-4db2-ae95-c856677e5c05	\N	2025-09-02	05:32:00	200	3	3	\N	\N	\N	\N	t	2025-09-01 20:02:42.36477+00	2025-09-19 02:10:26.196951+00	published	t	29f33f6a-fa33-4db2-ae95-c856677e5c05	f	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
a0c61e31-6cd7-4c2a-83dd-770d3eba6326	29f33f6a-fa33-4db2-ae95-c856677e5c05	\N	2025-09-02	05:32:00	200	3	3	\N	\N	\N	\N	t	2025-09-01 20:03:26.414572+00	2025-09-19 02:10:26.196951+00	published	t	29f33f6a-fa33-4db2-ae95-c856677e5c05	t	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	commercial_pool	\N	\N	\N	\N	f	0.00	f	t
179a76e6-9bfe-4837-85af-5d9c9b097aaf	\N	\N	2025-09-07	01:12:00	600	1	1	\N	\N	\N	\N	t	2025-09-06 19:42:40.353495+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	private_pool	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
01cbe81c-0a77-4ea5-bcc7-183d615cd1c0	\N	\N	2025-09-07	13:18:00	600	1	1	\N	\N	\N	\N	t	2025-09-07 07:48:24.355831+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	private_pool	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
3fdece78-270b-4d63-971d-31087050b20f	\N	\N	2025-09-06	01:33:00	600	1	1	\N	\N	\N	\N	t	2025-09-05 20:03:56.065279+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	private_pool	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
e5baa875-ead8-45f2-a122-2691ca5d3d3c	\N	\N	2025-09-06	01:34:00	600	1	1	\N	\N	\N	\N	t	2025-09-05 20:04:31.214732+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	private_pool	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
4e9bcb8a-fd72-4f50-943c-08897de6f8e5	\N	\N	2025-09-06	01:34:00	600	1	1	\N	\N	\N	\N	t	2025-09-05 20:04:57.498538+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	private_pool	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
cb9fa9a3-921f-47fd-b730-f25154d9421e	\N	\N	2025-09-06	03:47:00	500	1	1	\N	\N	\N	\N	t	2025-09-05 22:17:19.021871+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	private_pool	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
4d3eefbc-e346-46e8-93fd-30eeb04e5dda	1cd0d596-1c26-4112-83a5-f1275c15c351	b1c1b3e1-8515-41f1-b12c-91997ce1ad3c	2025-09-06	13:07:32.411452	0	1	1	\N	\N	\N	\N	t	2025-09-06 08:00:00+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
ecfbd0f5-85e2-49df-8759-6cd283a3699d	29f33f6a-fa33-4db2-ae95-c856677e5c05	b3c7a68b-2dfc-4832-9f41-e1bcdb95c930	2025-09-06	13:07:32.411452	0	1	1	\N	\N	\N	\N	t	2025-09-06 08:00:00+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
3941a758-40d5-4ef1-903e-54a2005ce426	99343775-d354-4032-9938-838e382d7392	569edd65-5480-4cc3-b776-9ad8abd6ccfd	2025-09-06	13:07:32.411452	0	1	1	\N	\N	\N	\N	t	2025-09-06 08:00:00+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
986fc1bf-d68d-4f7f-9be2-c89db35c5597	a0ec38f2-7679-444e-82a7-70ffb28f4e50	708fdefd-7184-4adb-b046-1a97c32bb4e3	2025-09-06	13:07:32.411452	0	1	1	\N	\N	\N	\N	t	2025-09-06 08:00:00+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
c5be349e-e42c-4f94-969e-866daf3ce79f	b878f371-ebe5-45fc-9e9a-5a84d7a36c15	b1c1b3e1-8515-41f1-b12c-91997ce1ad3c	2025-09-06	13:07:32.411452	0	1	1	\N	\N	\N	\N	t	2025-09-07 08:00:00+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
1e27ec68-4990-4be6-b71b-956677f2178a	e4dbcfe6-396d-4507-88b1-3c325b466b2a	b3c7a68b-2dfc-4832-9f41-e1bcdb95c930	2025-09-06	13:07:32.411452	0	1	1	\N	\N	\N	\N	t	2025-09-07 08:00:00+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
e54cf37c-2326-47ad-b5e0-891ef2557302	1cd0d596-1c26-4112-83a5-f1275c15c351	569edd65-5480-4cc3-b776-9ad8abd6ccfd	2025-09-06	13:07:32.411452	0	1	1	\N	\N	\N	\N	t	2025-09-07 08:00:00+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
841d9a41-92fb-4703-8637-e68180990a81	99343775-d354-4032-9938-838e382d7392	b1c1b3e1-8515-41f1-b12c-91997ce1ad3c	2025-09-06	13:07:32.411452	0	1	1	\N	\N	\N	\N	t	2025-09-08 08:00:00+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
16a9fdcd-ddfe-4e80-a2a3-a3e11c237849	a0ec38f2-7679-444e-82a7-70ffb28f4e50	b3c7a68b-2dfc-4832-9f41-e1bcdb95c930	2025-09-06	13:07:32.411452	0	1	1	\N	\N	\N	\N	t	2025-09-08 08:00:00+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
ba3ee332-e675-497b-bc2c-43f6a0e937cd	\N	10fc64e2-bac0-4287-98fd-e2671d78a5c6	2025-08-22	09:30:00	600	4	4	Maruti	Baleno	MH-12-XY-1234	No smoking	t	2025-08-19 19:14:14.025299+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	Maruti	Baleno	MH-12-XY-1234	No smoking	f	0.00	f	t
51d7f8fd-d1e1-4e37-82c2-02faff851f47	\N	10fc64e2-bac0-4287-98fd-e2671d78a5c6	2025-08-22	09:30:00	600	4	4	Maruti	Baleno	MH-12-XY-1234	No smoking	t	2025-08-21 06:54:54.571445+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	Maruti	Baleno	MH-12-XY-1234	No smoking	f	0.00	f	t
bd5b6ad2-fa59-499f-b168-b6f09e63c5ca	\N	10fc64e2-bac0-4287-98fd-e2671d78a5c6	2025-08-20	09:00:00	500	4	4	Maruti	Baleno	MH-12-AB-1234	\N	t	2025-08-19 13:19:34.564934+00	2025-09-19 02:10:26.196951+00	published	f	\N	f	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	Maruti	Baleno	MH-12-AB-1234	\N	f	0.00	f	t
fd791207-8317-4809-a25b-8510e040bc98	b878f371-ebe5-45fc-9e9a-5a84d7a36c15	569edd65-5480-4cc3-b776-9ad8abd6ccfd	2025-09-06	13:07:32.411452	0	1	1	\N	\N	\N	\N	t	2025-09-08 08:00:00+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
fae5d9f8-dea4-4d9c-b625-d7e5052ddd8f	e4dbcfe6-396d-4507-88b1-3c325b466b2a	708fdefd-7184-4adb-b046-1a97c32bb4e3	2025-09-06	13:07:32.411452	0	1	1	\N	\N	\N	\N	t	2025-09-08 08:00:00+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
8031ff8c-c2c8-4bf6-b4b7-6a2ee16abe7b	\N	\N	2025-09-07	02:07:00	600	1	1	\N	\N	\N	\N	t	2025-09-06 20:37:05.489096+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	private_pool	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
f021d283-4356-4230-ae40-b4543ac4f2d7	\N	10fc64e2-bac0-4287-98fd-e2671d78a5c6	2025-08-25	09:30:00	600	4	4	Maruti	Baleno	MH-12-XY-1234	No smoking	t	2025-08-21 11:33:12.301356+00	2025-09-19 02:10:26.196951+00	published	f	\N	f	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	Maruti	Baleno	MH-12-XY-1234	No smoking	f	0.00	f	t
56ca39cd-93b4-4a10-b147-890794a38390	\N	10fc64e2-bac0-4287-98fd-e2671d78a5c6	2025-08-25	09:30:00	600	4	3	Maruti	Baleno	MH-12-XY-1234	No smoking	t	2025-08-21 10:29:44.205565+00	2025-09-19 02:10:26.196951+00	published	f	\N	f	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	Maruti	Baleno	MH-12-XY-1234	No smoking	f	0.00	f	t
7938de8f-a5b0-4fd2-a614-b505aa2af3e8	\N	10fc64e2-bac0-4287-98fd-e2671d78a5c6	2025-08-24	09:30:00	600	4	4	Maruti	Baleno	MH-12-XY-1234	No smoking	t	2025-08-23 18:02:45.182031+00	2025-09-19 02:10:26.196951+00	published	f	\N	f	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	Maruti	Baleno	MH-12-XY-1234	No smoking	f	0.00	f	t
5a9b15a6-dbb0-48ae-bb83-dd9036d98396	\N	10fc64e2-bac0-4287-98fd-e2671d78a5c6	2025-08-27	09:30:00	600	4	4	Maruti	Baleno	MH-12-XY-1234	AC available	t	2025-08-23 18:48:04.814677+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	Maruti	Baleno	MH-12-XY-1234	AC available	f	0.00	f	t
44f30b04-a29c-430a-834f-ca6dfe7b69b4	\N	9f8a4b21-383b-4f73-a387-db44782fa961	2025-09-01	00:30:00	600	3	3	\N	\N	\N	\N	t	2025-08-31 05:26:34.500498+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
b25f9814-3d3f-4a5b-b5f6-9fe12e91eded	\N	b727b972-b4c8-4fe6-82bb-bd66969b1886	2025-08-31	23:30:00	600	3	3	\N	\N	\N	\N	t	2025-08-31 05:27:34.744824+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
6ba04d79-a269-48ba-b3a3-eb585ddb2499	\N	0d42e499-6c64-4ee0-8211-e380a0a75256	2025-08-31	23:30:00	600	3	3	\N	\N	\N	\N	t	2025-08-31 05:28:38.887401+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
7c39eb9b-b3ca-4da9-adc4-6f36f3ab0027	\N	10fc64e2-bac0-4287-98fd-e2671d78a5c6	2025-09-01	05:29:13.036	600	3	3	\N	\N	\N	\N	t	2025-08-31 05:29:10.311901+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
6743da32-9df3-4af5-922a-85c20ba2d17c	\N	10fc64e2-bac0-4287-98fd-e2671d78a5c6	2025-09-01	05:33:32.927	600	3	3	\N	\N	\N	\N	t	2025-08-31 05:33:30.749247+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
52a3bebd-4eb0-451f-a5b2-e96730b2e6b0	\N	\N	2025-09-06	02:00:00	350	1	1	\N	\N	\N	\N	t	2025-09-05 20:30:47.528912+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	private_pool	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
10258a0f-cdd9-438e-8c57-2b2e78742c9d	\N	\N	2025-09-06	16:34:00	600	1	1	\N	\N	\N	\N	t	2025-09-06 11:04:50.789153+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	private_pool	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
96522d2f-fe33-4d3e-bda0-f92b517e6e13	\N	\N	2025-09-08	01:11:00	0	1	1	\N	\N	\N	\N	t	2025-09-06 19:41:38.275348+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	private_pool	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
7ae3c093-73ca-42a4-b140-fd877e7b78ce	\N	\N	2025-09-07	16:17:00	600	1	1	\N	\N	\N	\N	t	2025-09-07 07:47:41.225905+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	private_pool	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
ea3e53c8-bb4c-4f3a-ab60-7bb610e45182	\N	10fc64e2-bac0-4287-98fd-e2671d78a5c6	2025-09-01	07:42:48.181	600	3	3	\N	\N	\N	\N	t	2025-08-31 07:42:45.75687+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
36738222-1750-4d6f-99c7-d8a83fcbc2fb	\N	b727b972-b4c8-4fe6-82bb-bd66969b1886	2025-09-01	03:30:00	600	3	3	\N	\N	\N	\N	t	2025-08-31 07:51:32.173398+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
52a4def7-3225-49e8-a15e-df3d72d7c61e	\N	10fc64e2-bac0-4287-98fd-e2671d78a5c6	2025-09-01	08:22:09.315108	600	3	3	\N	\N	\N	\N	t	2025-08-31 08:22:09.315108+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
fa8562a2-b8c1-4760-bdda-129ab0a6a6f9	\N	10fc64e2-bac0-4287-98fd-e2671d78a5c6	2025-09-01	08:22:34.400134	600	3	3	\N	\N	\N	\N	t	2025-08-31 08:22:34.400134+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
ba441a3f-53e8-42c3-bad2-4ce78e4b6dd3	\N	10fc64e2-bac0-4287-98fd-e2671d78a5c6	2025-09-02	08:22:58.805493	500	2	2	\N	\N	\N	\N	t	2025-08-31 08:22:58.805493+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
f3fe38b4-0484-49af-b6fc-8cc4530d9b23	\N	10fc64e2-bac0-4287-98fd-e2671d78a5c6	2025-09-01	12:42:31.250458	600	4	4	\N	\N	\N	No smoking	t	2025-08-31 12:42:31.250458+00	2025-09-19 02:10:26.196951+00	published	f	\N	f	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	No smoking	f	0.00	f	t
45f84143-1d64-4523-ae77-0d1ccd0d1563	\N	10fc64e2-bac0-4287-98fd-e2671d78a5c6	2025-09-05	09:30:00	600	4	4	\N	\N	\N	test	t	2025-08-31 12:45:02.679587+00	2025-09-19 02:10:26.196951+00	published	f	\N	f	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	test	f	0.00	f	t
f053a180-a9ba-454f-8959-e8fe511eaf7d	\N	10fc64e2-bac0-4287-98fd-e2671d78a5c6	2025-09-01	12:51:21.507	600	3	3	\N	\N	\N	\N	t	2025-08-31 12:51:19.499632+00	2025-09-19 02:10:26.196951+00	published	f	\N	f	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
35869a93-93cb-4ab8-bd44-3480a45f09e8	\N	b727b972-b4c8-4fe6-82bb-bd66969b1886	2025-09-01	09:00:00	600	3	3	\N	\N	\N	hi	t	2025-08-31 12:51:57.097924+00	2025-09-19 02:10:26.196951+00	published	f	\N	f	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	hi	f	0.00	f	t
7efae0a0-4afc-4517-a708-1668d4b0cccb	\N	0d42e499-6c64-4ee0-8211-e380a0a75256	2025-08-31	09:30:00	100	1	1	\N	\N	\N	\N	t	2025-08-31 16:37:24.402486+00	2025-09-19 02:10:26.196951+00	published	f	\N	f	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
463d101e-4f78-423c-9a59-1872504e3cb2	\N	0d42e499-6c64-4ee0-8211-e380a0a75256	2025-09-01	04:00:00	100	1	1	\N	\N	\N	\N	t	2025-08-31 19:11:21.85052+00	2025-09-19 02:10:26.196951+00	published	f	\N	f	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
b4c9c4da-b7be-4340-9932-48ae20d8e1e4	\N	10fc64e2-bac0-4287-98fd-e2671d78a5c6	2025-09-01	08:22:58.805493	600	3	2	\N	\N	\N	\N	t	2025-08-31 08:22:58.805493+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
1eeea9a8-c894-414d-82f8-f81cc1eba515	\N	10fc64e2-bac0-4287-98fd-e2671d78a5c6	2025-09-02	08:22:34.400134	500	2	1	\N	\N	\N	\N	t	2025-08-31 08:22:34.400134+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
f010e81d-9091-4eb4-ab40-ac2d97fa5c7b	\N	10fc64e2-bac0-4287-98fd-e2671d78a5c6	2025-09-01	16:36:34.255	600	3	2	\N	\N	\N	\N	t	2025-08-31 16:36:32.970816+00	2025-09-19 02:10:26.196951+00	published	f	\N	f	t	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
1a4cd725-ce2b-4d47-9d8b-567d83904073	\N	\N	2025-09-10	21:07:00	600	1	1	\N	\N	\N	\N	t	2025-09-10 15:37:27.928944+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	private_pool	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
b5156d3f-d7e2-48c7-b9be-f1b0b36b6013	\N	\N	2025-09-18	04:49:00	150	3	3	\N	\N	\N	\N	t	2025-09-11 18:19:12.611109+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	private_pool	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
c8e16536-aff9-4c8b-a6da-9bb75a94a640	\N	\N	2025-09-11	23:49:00	309	3	3	\N	\N	\N	\N	t	2025-09-11 18:19:38.479878+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	private_pool	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
e1376526-1821-4164-be60-0b3aa1807e7f	\N	\N	2025-09-12	00:01:00	150	3	3	\N	\N	\N	\N	t	2025-09-11 18:31:36.063876+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	private_pool	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
6c3bbfd4-7275-43be-8fd0-ae9478b1f1a5	\N	8ed57b85-3575-47f2-940e-4e2df6cc4e79	2025-09-12	04:57:00	600	3	3	\N	\N	\N	\N	t	2025-09-11 19:27:35.099459+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	private_pool	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	627545c8-f3f5-4474-94b5-122f1a50cb2d	{7ac1789a-cd54-4cf8-a225-a8048f32a3f9,15cdf321-9daf-44d2-9be7-206159b4a19b,d88cc113-e1c4-4344-8b55-77de4d01c26b}	{15cdf321-9daf-44d2-9be7-206159b4a19b,d88cc113-e1c4-4344-8b55-77de4d01c26b,eb2b4bae-14d8-4aa6-a68e-005da14aa409,fb9b8599-8ce8-4249-8d53-bd4e9a33da07,e1be8692-d511-484e-9c15-a773fe552f63}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
092ba2bc-1d30-4529-b1f5-100f2f92f0e3	\N	ce1e8396-e73b-4990-b025-14e27c36e3f1	2025-09-12	02:52:00	150	3	3	\N	\N	\N	\N	t	2025-09-11 21:22:38.745229+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	private_pool	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	627545c8-f3f5-4474-94b5-122f1a50cb2d	{d3cfabdd-ade8-4b11-a025-9158bf489bf6,27cf85c1-2118-4800-bb8e-61a6d04f4cc5,98630322-bc36-455f-bb09-b47d8ad22a84,e5b4c5fc-d11e-4d41-90e2-3382855b14c5}	{27cf85c1-2118-4800-bb8e-61a6d04f4cc5,98630322-bc36-455f-bb09-b47d8ad22a84,e5b4c5fc-d11e-4d41-90e2-3382855b14c5,92540a29-96d6-48d7-95d9-dda76427c94f}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
f327b26f-9da0-493d-a81c-fd59cb62e552	\N	03e62367-f1d4-4367-bffb-96179f883233	2025-09-18	03:12:00	150	3	3	\N	\N	\N	\N	t	2025-09-12 21:42:31.83995+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	private_pool	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	627545c8-f3f5-4474-94b5-122f1a50cb2d	{ed28f4ac-7676-474b-8777-4e827361f808}	{b82fbfca-b47f-4b08-9e7e-221e0a539529}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
96497d39-173c-4b26-80d8-c8498459c2ae	\N	76a7ef0c-420c-4a44-8afa-c84be5cb0c9f	2025-09-19	04:54:00	150	3	3	\N	\N	\N	\N	t	2025-09-13 19:25:15.15142+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	private_pool	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	627545c8-f3f5-4474-94b5-122f1a50cb2d	{021e631d-c46e-4305-9e9f-17fbcc43390b,32509f9b-9730-45f5-a5a0-32574b245f19}	{021e631d-c46e-4305-9e9f-17fbcc43390b,32509f9b-9730-45f5-a5a0-32574b245f19}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
5b842750-5e7e-48f7-b18f-8595d8554472	\N	03e62367-f1d4-4367-bffb-96179f883233	2025-09-14	04:24:00	150	3	3	\N	\N	\N	\N	t	2025-09-14 03:54:27.087217+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	private_pool	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	627545c8-f3f5-4474-94b5-122f1a50cb2d	{cf61de0f-b26b-4fcd-b812-28469a27f1ca,153b14f6-e605-44ff-84e0-57fb9f214273}	{cf61de0f-b26b-4fcd-b812-28469a27f1ca,153b14f6-e605-44ff-84e0-57fb9f214273}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
954cd7a1-6dac-45d1-84c8-6729f0ad3b8a	29f33f6a-fa33-4db2-ae95-c856677e5c05	58ee9f29-af5f-4de6-ac97-16aa5b172e4b	2025-09-17	04:00:00	500	4	4	\N	\N	\N	\N	t	2025-09-15 14:43:39.405+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	private_pool	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
d1dd0fce-680b-4db9-a069-2586c4a93688	11d3bfc3-51e8-43fc-b41a-24b2a0e0caff	\N	2025-09-24	04:37:00	550	3	3	\N	\N	\N	\N	t	2025-09-14 20:07:32.872636+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	private_pool	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
10c86895-360c-4958-98e9-d206de55cd9d	11d3bfc3-51e8-43fc-b41a-24b2a0e0caff	\N	2025-09-22	02:55:00	450	3	3	\N	\N	\N	\N	t	2025-09-14 21:25:25.488243+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	private_pool	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	627545c8-f3f5-4474-94b5-122f1a50cb2d	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
a288169e-dc65-45d3-97a4-d73f1afc5479	68735964-5d72-4d7c-8152-89c64cefb95f	46bd5490-6dc2-4516-9f81-4c951f5bd2da	2025-09-16	14:45:16	200	3	3	\N	\N	\N	Test ride from API script	t	2025-09-15 09:15:16.187545+00	2025-09-19 02:10:26.196951+00	published	t	\N	f	\N	private_pool	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	Test ride from API script	f	0.00	f	t
84170402-ce72-4725-9a79-703e7a34902d	\N	ce1e8396-e73b-4990-b025-14e27c36e3f1	2025-09-18	18:53:00	450	3	0	\N	\N	\N	\N	t	2025-09-14 04:23:24.150397+00	2025-09-19 17:28:37.300205+00	published	t	\N	f	\N	private_pool	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	627545c8-f3f5-4474-94b5-122f1a50cb2d	{cf61de0f-b26b-4fcd-b812-28469a27f1ca,77801aed-097f-419d-8392-49c694f215e7}	{17ed1461-afb1-48a0-aab5-e5c8970d5d8d,32509f9b-9730-45f5-a5a0-32574b245f19}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
479532a2-d738-455f-965f-74c74749bf84	29f33f6a-fa33-4db2-ae95-c856677e5c05	708fdefd-7184-4adb-b046-1a97c32bb4e3	2025-09-06	13:07:32.411452	0	1	0	\N	\N	\N	\N	t	2025-09-07 08:00:00+00	2025-09-19 19:08:50.768441+00	published	t	\N	f	\N	\N	\N	\N	{}	{}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
b9cd8990-1b59-479e-83f1-40880d71752e	\N	2d73d341-42b9-4202-9e06-94c890086b33	2025-09-18	03:55:00	500	3	2	\N	\N	\N	\N	t	2025-09-13 19:25:46.128472+00	2025-09-19 21:32:51.757147+00	published	t	\N	f	\N	private_pool	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	627545c8-f3f5-4474-94b5-122f1a50cb2d	{5fc547db-ddd4-4b37-93c4-c6a6cb2eb024,2c5a4fd1-d611-43cb-a347-d7eb7be2a04c,f623bc0f-47b8-40f5-b49d-647b05781d73}	{5fc547db-ddd4-4b37-93c4-c6a6cb2eb024,f623bc0f-47b8-40f5-b49d-647b05781d73,2c5a4fd1-d611-43cb-a347-d7eb7be2a04c}	\N	\N	\N	\N	private	\N	\N	\N	\N	f	0.00	f	t
\.


--
-- Data for Name: route_stops; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.route_stops (id, route_id, stop_name, stop_order, stop_id, seq) FROM stdin;
153b14f6-e605-44ff-84e0-57fb9f214273	03e62367-f1d4-4367-bffb-96179f883233	Igatpuri	2	\N	\N
17ed1461-afb1-48a0-aab5-e5c8970d5d8d	ce1e8396-e73b-4990-b025-14e27c36e3f1	Mumbai CST	3	\N	\N
173146e4-b9f0-4358-8f1f-80c1fd86c4c8	569edd65-5480-4cc3-b776-9ad8abd6ccfd	Lonavala	2	80d8cb0a-73a0-4273-963d-4c9923ab88bb	2
09b3c642-1071-491e-959c-a58a0fe3eabb	b3c7a68b-2dfc-4832-9f41-e1bcdb95c930	Ghoti	2	a2226960-3676-4497-b298-7119278ebe3d	2
03f22a46-d32b-4586-a1a4-97271ea2d29f	b1c1b3e1-8515-41f1-b12c-91997ce1ad3c	Sinnar	2	2c5a4fd1-d611-43cb-a347-d7eb7be2a04c	2
a542b9b2-9522-45c7-a3af-8d7cedfeb2c4	b1c1b3e1-8515-41f1-b12c-91997ce1ad3c	Wakad	5	5993172c-ae87-445f-b0cf-04c402113a4d	5
d9354b5f-5718-4e1d-b483-b753a62c68c1	b1c1b3e1-8515-41f1-b12c-91997ce1ad3c	Chakan	4	86ad11a6-87b0-4843-9906-23257dbc3a82	4
66a7c2bf-a2a3-46a3-a293-69fd07b994c6	b1c1b3e1-8515-41f1-b12c-91997ce1ad3c	CBS	1	db45d0f8-6598-4fb6-a818-a0a1792b61de	1
69b00547-5f3f-42e9-8901-d1db50575ae4	b3c7a68b-2dfc-4832-9f41-e1bcdb95c930	Lonavala	3	80d8cb0a-73a0-4273-963d-4c9923ab88bb	3
2b0a58f8-a9fe-404a-9210-79e72d0af546	569edd65-5480-4cc3-b776-9ad8abd6ccfd	Vashi	3	5b44f8fe-7210-42e7-8ff0-bc79a2b6c943	3
85754f50-ed8e-46fc-afef-b22f8d57e3d6	b3c7a68b-2dfc-4832-9f41-e1bcdb95c930	CBS	1	db45d0f8-6598-4fb6-a818-a0a1792b61de	1
6287c441-29c4-46dd-90ee-d798b131d586	b1c1b3e1-8515-41f1-b12c-91997ce1ad3c	Sangamner	3	7db53349-29f6-4052-8b15-adf62c21dbff	3
616adedd-8ef4-4572-b113-2e4dbfc3fe46	569edd65-5480-4cc3-b776-9ad8abd6ccfd	Shivajinagar	1	c35601f1-2885-4f9f-b3c6-07cc8e40a791	1
6c6390d7-72fb-4fea-8719-8efd5599898c	569edd65-5480-4cc3-b776-9ad8abd6ccfd	Sion	4	b95d4eab-9ea5-4572-8fff-671709799d4c	4
afd3050b-14d1-42ac-a0e7-ce9b18df3f93	b3c7a68b-2dfc-4832-9f41-e1bcdb95c930	Shivajinagar	4	c35601f1-2885-4f9f-b3c6-07cc8e40a791	4
25fa482e-13f6-42fa-8f1c-653d8390cc05	c1b50f82-ccae-48ef-8c2d-e71868863eaa	Chakan	1	86ad11a6-87b0-4843-9906-23257dbc3a82	1
8bf36e2a-33a4-4861-ac78-b0a533259d2f	56fa2dcf-4de8-4f70-bf74-69c48a53767f	Nashik City	1	5fc547db-ddd4-4b37-93c4-c6a6cb2eb024	1
4238f51e-1bc3-4dcd-b7fe-9da8980e37b1	56fa2dcf-4de8-4f70-bf74-69c48a53767f	Sinnar	2	2c5a4fd1-d611-43cb-a347-d7eb7be2a04c	2
045c20d3-5b2b-4e9c-bbe4-725af71780ed	56fa2dcf-4de8-4f70-bf74-69c48a53767f	Mumbai Central	3	f623bc0f-47b8-40f5-b49d-647b05781d73	3
9172fc35-b06d-4504-9a2d-ebeed8c3876a	56fa2dcf-4de8-4f70-bf74-69c48a53767f	Mumbai- Thane	4	0edd6f26-7929-4914-9d4c-af996bc321f2	4
e355ec89-a437-4362-8b00-6090cc9427e1	708fdefd-7184-4adb-b046-1a97c32bb4e3	Nashik City	1	5fc547db-ddd4-4b37-93c4-c6a6cb2eb024	1
ff04db46-2ca8-4a5f-b54c-00df564af1d4	708fdefd-7184-4adb-b046-1a97c32bb4e3	Sinnar	2	2c5a4fd1-d611-43cb-a347-d7eb7be2a04c	2
d4f84eb3-6a16-4121-9ad4-94a124a1c9c5	708fdefd-7184-4adb-b046-1a97c32bb4e3	Mumbai Central	3	f623bc0f-47b8-40f5-b49d-647b05781d73	3
c9d3721b-b27a-4106-91a9-2fb36913e0c3	708fdefd-7184-4adb-b046-1a97c32bb4e3	Mumbai- Thane	4	0edd6f26-7929-4914-9d4c-af996bc321f2	4
21130351-4821-4d71-87c4-83f62ad76587	8ed57b85-3575-47f2-940e-4e2df6cc4e79	Nashik City	1	5fc547db-ddd4-4b37-93c4-c6a6cb2eb024	1
71115d01-d746-4513-aade-48b31eeb6119	8ed57b85-3575-47f2-940e-4e2df6cc4e79	Sinnar	2	2c5a4fd1-d611-43cb-a347-d7eb7be2a04c	2
82e47e19-52bf-4347-8eea-6387a673c368	8ed57b85-3575-47f2-940e-4e2df6cc4e79	Mumbai Central	3	f623bc0f-47b8-40f5-b49d-647b05781d73	3
20f26ce9-55f5-47e9-a600-54a1a2a241af	8ed57b85-3575-47f2-940e-4e2df6cc4e79	Mumbai- Thane	4	0edd6f26-7929-4914-9d4c-af996bc321f2	4
36e743ae-d823-484f-8715-ebb860e9497c	2d73d341-42b9-4202-9e06-94c890086b33	Nashik City	1	5fc547db-ddd4-4b37-93c4-c6a6cb2eb024	1
4002cbb3-9039-4baf-b51c-f461f687b1ea	2d73d341-42b9-4202-9e06-94c890086b33	Sinnar	2	2c5a4fd1-d611-43cb-a347-d7eb7be2a04c	2
6a49c1a4-cc5e-49b5-a094-71b852feafbc	2d73d341-42b9-4202-9e06-94c890086b33	Mumbai Central	3	f623bc0f-47b8-40f5-b49d-647b05781d73	3
1d7e81a0-234d-42b1-bc23-b54d42933018	2d73d341-42b9-4202-9e06-94c890086b33	Mumbai- Thane	4	0edd6f26-7929-4914-9d4c-af996bc321f2	4
86816526-c408-4528-8ec2-20fab924866c	46bd5490-6dc2-4516-9f81-4c951f5bd2da	Dadar	1	acf1d194-4ed6-4d46-984e-12b8c64a5fb2	\N
8710cf69-667f-4a84-85d3-4b327c092700	46bd5490-6dc2-4516-9f81-4c951f5bd2da	Kurla	2	b9d62f65-9e29-43ad-a5f3-de2c6825bbef	\N
a1a72341-bc96-4aba-8210-60b56ef8767b	46bd5490-6dc2-4516-9f81-4c951f5bd2da	Thane Station	3	4766881d-11f2-426b-ab49-d4ba579a48d0	\N
fb6ad58c-aa22-429c-9c87-dc66a5266c8d	46bd5490-6dc2-4516-9f81-4c951f5bd2da	Talegaon	4	5dbbf3c2-6a07-46c0-a306-d21ce33b232d	\N
95d9c4d8-9adc-4ffa-a2c8-e629e544553a	46bd5490-6dc2-4516-9f81-4c951f5bd2da	Swargate	5	906818de-6978-4b07-a162-f5709008bc20	\N
765c3475-cbb4-42c7-bdb0-4dde679d7ec0	58ee9f29-af5f-4de6-ac97-16aa5b172e4b	Nashik Road	1	7907c6f6-7f60-4d24-bd78-19a47642c9f0	\N
bf06c68e-db2e-4113-8ce6-651133288557	58ee9f29-af5f-4de6-ac97-16aa5b172e4b	Igatpuri	2	e34c4b30-65ca-46f2-89f2-d6fe570af13f	\N
76c09276-acda-4c3d-9b8e-9b93f89693cd	58ee9f29-af5f-4de6-ac97-16aa5b172e4b	Borivali	3	f7e0ce8a-5b2f-48b3-9c54-f2f8738617c0	\N
b9be94e0-dac4-446b-b253-b7daa80c6ec1	58ee9f29-af5f-4de6-ac97-16aa5b172e4b	Dadar	4	acf1d194-4ed6-4d46-984e-12b8c64a5fb2	\N
81f0cd00-0e67-43b8-ba04-5d10554e4139	082b9586-2481-4db2-aa7c-046e1f9aaadd	Thane Bus Stand	1	92664f9b-2cf2-4959-b297-8ddf0f4a54b8	\N
172b4569-5b22-4433-857c-e144feeef807	6af7cbd4-ce5f-4592-a9a4-5541475e2f5a	Solapur Bus Stand	1	5c979e1c-8a3a-468f-9e35-9910a7bb2a2a	\N
a65211cc-f0bf-4306-b2a2-59e7fb85a74f	4f17a1b3-f123-4d50-971c-5c6ae735bac8	Amravati Bus Stand	1	42a7332a-982f-48a8-8c3d-c38d41939492	\N
9e53d849-771d-4e22-b037-eedec5fe8120	d2f3d130-e57a-4885-820f-d4ea0665ca7a	Jalgaon Bus Stand	1	41d4527d-30b0-4dbe-a2ab-ee2e4f4bdb0b	\N
513b16b2-7d09-4281-98b5-48b6f6b759b2	8f8a2f75-e3d3-4f99-8096-bcd7694cb246	Akola Bus Stand	1	d6e2c8c9-4218-4f75-bd23-a18ff86ca36a	\N
b7046520-9c39-4a90-8b8d-6e4a81496e4e	83a55f1c-c28b-414c-b84d-a4bdfb9e1103	Satara Bus Stand	1	21203e13-04af-42a5-89fe-5a6995d36161	\N
f750cba1-29d0-4bb2-b77f-3d40cb8d9b5b	bb7d0feb-9a99-4be6-957b-7f5a0d34616d	Satara Bus Stand	1	21203e13-04af-42a5-89fe-5a6995d36161	\N
ceae6bc4-d377-4f57-89e5-d1bfa46e1a99	674865f4-4624-4931-84cc-faaa167b00fe	Nanded Bus Stand	1	2e7d96f4-b0b4-46a2-bcfa-7ef1867053f5	\N
597e1c6b-59a2-4730-ba03-1d949058e3cb	8f7208c0-307c-49bf-b1f6-f481e1ae1549	Latur Bus Stand	1	05194bb5-bf27-44a7-a95c-90465af41f2d	\N
8e75bdb5-370d-4a49-9863-97afa3715a81	aba6557b-8f6c-46df-812b-9e9f754a72a9	Ahmednagar Bus Stand	1	f2e6f33f-48e3-483d-b6fe-0e049247cb40	\N
44d7ae17-7acd-4d79-9e41-cf788be98c6a	ebef5590-93b9-4d1a-9dd2-77f2a34c2941	Chandrapur Bus Stand	1	c28d867c-ac8e-41cf-9c4d-28929cc90c88	\N
eb14beca-159c-4756-ba37-d822b536b5df	8afdbc8b-cb06-44c6-9706-9cf5b2485560	Jalna Bus Stand	1	7ea58384-aefa-4bb4-b388-e16c81a7c921	\N
8dc313bd-111e-4944-b3a7-2121d97f6fd9	7c71e32d-a751-433d-ad93-b68eb8b69ed5	Pune Bus Stand	1	021e631d-c46e-4305-9e9f-17fbcc43390b	\N
cf4ef032-ed6f-4636-b757-df99944b5b31	d2c96ec6-6f9b-4aa8-8d57-a452e27d4d8d	Pune Bus Stand	1	021e631d-c46e-4305-9e9f-17fbcc43390b	\N
b603981a-b228-4473-b155-94ff4aa588d0	3843f62b-dee6-4a86-b984-0ac2cbda7dbc	Pune Bus Stand	1	021e631d-c46e-4305-9e9f-17fbcc43390b	\N
f41f4a9e-9ed9-485f-8ee6-333d5ecb572b	2d1f0d05-df07-47e1-9a42-e0456fcbbe9b	Pune Bus Stand	1	021e631d-c46e-4305-9e9f-17fbcc43390b	\N
49a4db48-424f-49cc-9174-3bdadd0a7101	c6f604fd-58a9-47cb-a7ac-a193dcf8a8c0	Pune Bus Stand	1	021e631d-c46e-4305-9e9f-17fbcc43390b	\N
d9e4c98f-5189-4b20-98c6-aba685d9b58e	35272a9c-c28c-4f3a-a01f-077f7330c693	Pune Bus Stand	1	021e631d-c46e-4305-9e9f-17fbcc43390b	\N
483fa5f9-eaca-45dc-81a2-d07ed9353ac1	7c6e06cd-1661-4810-8994-c83d085c24a3	Pune Bus Stand	1	021e631d-c46e-4305-9e9f-17fbcc43390b	\N
abf841d9-a9a0-4b15-a8ec-0163968b4d9d	76a7ef0c-420c-4a44-8afa-c84be5cb0c9f	Pune Bus Stand	1	021e631d-c46e-4305-9e9f-17fbcc43390b	\N
e64d52a2-a712-472a-b2d0-50f3b6240809	5abee3d1-362d-4b73-b6cf-291823e5bfbd	Aurangabad Bus Stand	1	2ccff871-189a-469d-9ee7-0cdc472bfe1a	\N
85ca2b7e-280b-4e44-a208-cceed4bb2968	04691799-c20e-45ac-b6e8-949549e4907d	Aurangabad Bus Stand	1	2ccff871-189a-469d-9ee7-0cdc472bfe1a	\N
05ecf9b0-7f17-417a-8f3c-cb4c2343ab8e	5ff93f8f-79f7-4637-962a-05bffd09f321	Aurangabad Bus Stand	1	2ccff871-189a-469d-9ee7-0cdc472bfe1a	\N
b07b568f-f145-45aa-bf48-0f8f87ff0cfe	57594440-9eca-44e5-83e9-cf59bc438cf9	Aurangabad Bus Stand	1	2ccff871-189a-469d-9ee7-0cdc472bfe1a	\N
691273ae-9202-4a60-9bd5-79570db24670	6f5ab71d-1463-453d-b07d-fdbca885967e	Aurangabad Bus Stand	1	2ccff871-189a-469d-9ee7-0cdc472bfe1a	\N
5870a226-14bf-44da-aafd-34ee17d8d3d9	a9253d58-9032-4912-92e6-1804880e1853	Aurangabad Bus Stand	1	2ccff871-189a-469d-9ee7-0cdc472bfe1a	\N
e2ee021d-d675-4d24-af67-82319aa889ec	6fb27a13-cf9e-4ef5-9e41-dd70bfa5046b	Aurangabad Bus Stand	1	2ccff871-189a-469d-9ee7-0cdc472bfe1a	\N
a3ea91e5-6db3-497b-bd33-9631e99387f6	d57046fb-68e1-4ad3-a462-a4217741404f	Nashik Bus Stand	1	2b412604-decf-4664-97dd-f2272ee2e0f6	\N
98c9cf4b-1bbc-417a-b566-ddec5101af45	90cde7c8-9d0b-4291-9338-69c96ef37aad	Nashik Bus Stand	1	2b412604-decf-4664-97dd-f2272ee2e0f6	\N
73635def-dd47-4dbe-9c1e-88c665ec3d39	952da8f8-b7b8-49e8-8fed-3b57e51d4dd0	Nashik Bus Stand	1	2b412604-decf-4664-97dd-f2272ee2e0f6	\N
3001b524-5dbb-401a-8e88-fc832ca6a55a	ce47a01c-54fd-4bc4-941c-5916b652c6a9	Nashik Bus Stand	1	2b412604-decf-4664-97dd-f2272ee2e0f6	\N
26debc06-5002-4cc2-b157-e87deacf4fa0	c2d0ac0c-fa4c-4243-8f7c-0e74889468d2	Nashik Bus Stand	1	2b412604-decf-4664-97dd-f2272ee2e0f6	\N
48634ad9-7bbd-4964-89bd-789ce49bced7	357a59eb-6e71-4c44-ad9a-bcb039908518	Nashik Bus Stand	1	2b412604-decf-4664-97dd-f2272ee2e0f6	\N
432b7b58-f5c4-4457-bad3-a4a6f6881301	6e349c5f-01ba-4a99-8fd5-edf882d4ed03	Kolhapur Bus Stand	1	2860428a-ccf4-4f39-8164-6791909effb5	\N
db8c4a0e-ca51-47c9-abaf-0b8ea88c7203	1ab1cdb2-e817-4947-a76a-39e46e540b2e	Kolhapur Bus Stand	1	2860428a-ccf4-4f39-8164-6791909effb5	\N
680ba404-8495-412e-b3b3-303fcc891e4f	205767dc-42b0-47a7-a0f6-e4b9131c8b03	Nagpur Bus Stand	1	9fbd3bf1-91f8-410c-a556-e9ebfad81494	\N
3ed07e44-f23c-4d31-aef7-69c4c6c85646	42f698f2-c93e-470a-96ec-b35152a3a726	Nagpur Bus Stand	1	9fbd3bf1-91f8-410c-a556-e9ebfad81494	\N
56e16c97-7155-4afa-a61a-9821200bc182	2ee02a20-45b2-4a64-8fa7-4a558b611487	Nagpur Bus Stand	1	9fbd3bf1-91f8-410c-a556-e9ebfad81494	\N
0b90adf8-50aa-4f95-90d8-32c759060406	e6852d2d-0aba-4263-96f1-e867aadac19a	Nagpur Bus Stand	1	9fbd3bf1-91f8-410c-a556-e9ebfad81494	\N
52618526-6b56-44a0-8377-5de59dd749f5	bb580b17-4506-4834-ae95-fe413e318045	Nagpur Bus Stand	1	9fbd3bf1-91f8-410c-a556-e9ebfad81494	\N
fe537411-2dbe-49aa-8189-a04f683f41f6	c8474d27-7b14-47a9-b283-f96e4d524739	Nagpur Bus Stand	1	9fbd3bf1-91f8-410c-a556-e9ebfad81494	\N
dc9aaf1d-2cdb-4beb-a0aa-11e52a06f7c4	54080c71-6e51-47e1-8413-4c35e57416c9	Mumbai Bus Stand	1	32509f9b-9730-45f5-a5a0-32574b245f19	\N
6a087a46-3c9f-44f7-b623-997320371f0e	04ec8116-f0a1-43cb-9f56-35a3f569ad22	Mumbai Bus Stand	1	32509f9b-9730-45f5-a5a0-32574b245f19	\N
d6bee4b2-012c-4d1a-9d04-aca4e1af6f33	bf770759-b190-4d6d-9fcd-268be6fffcb5	Mumbai Bus Stand	1	32509f9b-9730-45f5-a5a0-32574b245f19	\N
ccbc8f00-5a2e-4c50-99c6-e036d45e82b8	81fb131a-f618-4108-b712-116db5ab5fcc	Mumbai Bus Stand	1	32509f9b-9730-45f5-a5a0-32574b245f19	\N
ce17c618-9e30-49b4-95bd-d5b6a32749cd	5cd9e616-4fce-4ae3-ae07-2ee6a79fbf37	Mumbai Bus Stand	1	32509f9b-9730-45f5-a5a0-32574b245f19	\N
27afa9ca-4d4f-44ea-8f9e-2fa21109d5be	275724a4-19b2-49a8-86f7-1fe28e4491ac	Mumbai Bus Stand	1	32509f9b-9730-45f5-a5a0-32574b245f19	\N
3726aa97-2fa6-4fe0-b55a-785bc08d48bb	ad0a19ca-677e-43f8-a98f-6c4568191a67	Mumbai Bus Stand	1	32509f9b-9730-45f5-a5a0-32574b245f19	\N
dcb56257-6242-48c7-88ef-aff8e50a5754	3d05219f-72ef-46af-a926-79bcfc125867	Mumbai Bus Stand	1	32509f9b-9730-45f5-a5a0-32574b245f19	\N
79a16f8d-1418-4a4d-be1c-62b72964508f	04ec8116-f0a1-43cb-9f56-35a3f569ad22	Thane Bus Stand	2	92664f9b-2cf2-4959-b297-8ddf0f4a54b8	\N
848f8134-4b02-4022-906c-652b167fb38e	2d1f0d05-df07-47e1-9a42-e0456fcbbe9b	Solapur Bus Stand	2	5c979e1c-8a3a-468f-9e35-9910a7bb2a2a	\N
c5343fcf-2f56-4190-be6a-3d034c59bd4f	2ee02a20-45b2-4a64-8fa7-4a558b611487	Amravati Bus Stand	2	42a7332a-982f-48a8-8c3d-c38d41939492	\N
32640d6a-cd1d-44cb-a741-91eab9457871	d57046fb-68e1-4ad3-a462-a4217741404f	Jalgaon Bus Stand	2	41d4527d-30b0-4dbe-a2ab-ee2e4f4bdb0b	\N
20192486-1c28-4580-84d3-8f65c7a96593	42f698f2-c93e-470a-96ec-b35152a3a726	Akola Bus Stand	2	d6e2c8c9-4218-4f75-bd23-a18ff86ca36a	\N
3985231b-4513-4330-8c33-6d32ccf99f5f	3843f62b-dee6-4a86-b984-0ac2cbda7dbc	Satara Bus Stand	2	21203e13-04af-42a5-89fe-5a6995d36161	\N
ff1b5412-4528-497c-b289-9bd91bb4b5ad	54080c71-6e51-47e1-8413-4c35e57416c9	Satara Bus Stand	2	21203e13-04af-42a5-89fe-5a6995d36161	\N
047f7cc5-81c9-4434-b69f-2260f037b3a5	5ff93f8f-79f7-4637-962a-05bffd09f321	Nanded Bus Stand	2	2e7d96f4-b0b4-46a2-bcfa-7ef1867053f5	\N
30012c12-eb65-4f24-a29b-86ee8ea28258	5abee3d1-362d-4b73-b6cf-291823e5bfbd	Latur Bus Stand	2	05194bb5-bf27-44a7-a95c-90465af41f2d	\N
15172ded-6ddc-4845-b7b8-1e3c0a6c6fee	d2c96ec6-6f9b-4aa8-8d57-a452e27d4d8d	Ahmednagar Bus Stand	2	f2e6f33f-48e3-483d-b6fe-0e049247cb40	\N
32de9649-6ebb-4e15-ac29-ad98a360d2a4	205767dc-42b0-47a7-a0f6-e4b9131c8b03	Chandrapur Bus Stand	2	c28d867c-ac8e-41cf-9c4d-28929cc90c88	\N
ca464208-8dd1-499c-9ad0-6d5755a66b78	04691799-c20e-45ac-b6e8-949549e4907d	Jalna Bus Stand	2	7ea58384-aefa-4bb4-b388-e16c81a7c921	\N
72e1cdb6-674d-4f9a-a6b7-09c219e94ef8	bb580b17-4506-4834-ae95-fe413e318045	Pune Bus Stand	2	021e631d-c46e-4305-9e9f-17fbcc43390b	\N
360df2aa-c159-4015-b634-456e2f3ca607	aba6557b-8f6c-46df-812b-9e9f754a72a9	Pune Bus Stand	2	021e631d-c46e-4305-9e9f-17fbcc43390b	\N
3e159ce4-8d96-4f37-bfee-09d5e3d672c6	83a55f1c-c28b-414c-b84d-a4bdfb9e1103	Pune Bus Stand	2	021e631d-c46e-4305-9e9f-17fbcc43390b	\N
6284f2a8-bcae-4a17-927e-2c08d1bbf78b	6af7cbd4-ce5f-4592-a9a4-5541475e2f5a	Pune Bus Stand	2	021e631d-c46e-4305-9e9f-17fbcc43390b	\N
3aa154bb-d07f-42c5-9bd4-54926e7d6bbe	6e349c5f-01ba-4a99-8fd5-edf882d4ed03	Pune Bus Stand	2	021e631d-c46e-4305-9e9f-17fbcc43390b	\N
717352fd-74ba-48b3-8374-ef432aa9d01d	a9253d58-9032-4912-92e6-1804880e1853	Pune Bus Stand	2	021e631d-c46e-4305-9e9f-17fbcc43390b	\N
1672f5d4-ffab-4d31-b0f1-13e4c7f8751e	ce47a01c-54fd-4bc4-941c-5916b652c6a9	Pune Bus Stand	2	021e631d-c46e-4305-9e9f-17fbcc43390b	\N
72fc5a2e-9bc8-4730-b6f8-f671c4cc1b4e	81fb131a-f618-4108-b712-116db5ab5fcc	Pune Bus Stand	2	021e631d-c46e-4305-9e9f-17fbcc43390b	\N
fb61c4f7-9f2c-465f-9d3a-89370a8a1a81	357a59eb-6e71-4c44-ad9a-bcb039908518	Pune Bus Stand	2	021e631d-c46e-4305-9e9f-17fbcc43390b	\N
0e9f29a4-43bf-4d07-ad78-460e1a9e5f37	b3c7a68b-2dfc-4832-9f41-e1bcdb95c930	Pune Bus Stand	5	021e631d-c46e-4305-9e9f-17fbcc43390b	\N
1bd540d7-4a0b-4190-a87c-c40ad1ec2340	b1c1b3e1-8515-41f1-b12c-91997ce1ad3c	Pune Bus Stand	6	021e631d-c46e-4305-9e9f-17fbcc43390b	\N
97550f8e-924c-4a44-94d8-3c0fc9d44fe4	c1b50f82-ccae-48ef-8c2d-e71868863eaa	Pune Bus Stand	2	021e631d-c46e-4305-9e9f-17fbcc43390b	\N
ce3de7c1-e999-49bd-a69f-c40a8dbd4b14	8f7208c0-307c-49bf-b1f6-f481e1ae1549	Aurangabad Bus Stand	2	2ccff871-189a-469d-9ee7-0cdc472bfe1a	\N
2dcb8bbf-939b-46c6-b2f0-65ae65f8926f	8afdbc8b-cb06-44c6-9706-9cf5b2485560	Aurangabad Bus Stand	2	2ccff871-189a-469d-9ee7-0cdc472bfe1a	\N
645544d6-fafb-4bce-a1cf-feeab8faf99d	674865f4-4624-4931-84cc-faaa167b00fe	Aurangabad Bus Stand	2	2ccff871-189a-469d-9ee7-0cdc472bfe1a	\N
4a50a63b-cd3d-40e4-b833-c1e5c06985ed	e6852d2d-0aba-4263-96f1-e867aadac19a	Aurangabad Bus Stand	2	2ccff871-189a-469d-9ee7-0cdc472bfe1a	\N
1290fe1d-e162-4f07-92b9-4944b8018a52	952da8f8-b7b8-49e8-8fed-3b57e51d4dd0	Aurangabad Bus Stand	2	2ccff871-189a-469d-9ee7-0cdc472bfe1a	\N
fc30d38a-7e6d-4590-966b-f78d888dc020	35272a9c-c28c-4f3a-a01f-077f7330c693	Aurangabad Bus Stand	2	2ccff871-189a-469d-9ee7-0cdc472bfe1a	\N
972f9656-dd41-40ac-9daf-5d7f2d2ac4f5	ad0a19ca-677e-43f8-a98f-6c4568191a67	Aurangabad Bus Stand	2	2ccff871-189a-469d-9ee7-0cdc472bfe1a	\N
c244db34-6e10-4c93-9053-576563f9a627	d2f3d130-e57a-4885-820f-d4ea0665ca7a	Nashik Bus Stand	2	2b412604-decf-4664-97dd-f2272ee2e0f6	\N
f47ebf0c-8b93-44f7-96e1-76436144ca20	095afb34-5479-478a-b56d-d139a52d9e59	Nashik Bus Stand	2	2b412604-decf-4664-97dd-f2272ee2e0f6	\N
c3f46a68-185e-43f9-8e43-2fc27eb8b82e	6f5ab71d-1463-453d-b07d-fdbca885967e	Nashik Bus Stand	2	2b412604-decf-4664-97dd-f2272ee2e0f6	\N
fd021f58-66e9-4a54-8001-578514245e68	7c6e06cd-1661-4810-8994-c83d085c24a3	Nashik Bus Stand	2	2b412604-decf-4664-97dd-f2272ee2e0f6	\N
694b0c85-c0b4-4345-a508-e9752fc83ba8	bf770759-b190-4d6d-9fcd-268be6fffcb5	Nashik Bus Stand	2	2b412604-decf-4664-97dd-f2272ee2e0f6	\N
b3280fbe-e068-4937-a2de-6d4784cce354	3d05219f-72ef-46af-a926-79bcfc125867	Nashik Bus Stand	2	2b412604-decf-4664-97dd-f2272ee2e0f6	\N
ba3d57b5-9f69-40e3-94e5-82546dad8a66	c6f604fd-58a9-47cb-a7ac-a193dcf8a8c0	Kolhapur Bus Stand	2	2860428a-ccf4-4f39-8164-6791909effb5	\N
71eed3c2-3c64-4ca8-9843-255ba5e14e44	5cd9e616-4fce-4ae3-ae07-2ee6a79fbf37	Kolhapur Bus Stand	2	2860428a-ccf4-4f39-8164-6791909effb5	\N
d4d36f19-5a0c-457c-b8d9-8fa3fe5ca952	ebef5590-93b9-4d1a-9dd2-77f2a34c2941	Nagpur Bus Stand	2	9fbd3bf1-91f8-410c-a556-e9ebfad81494	\N
8836d925-91c8-42c9-acba-c1b32d35370b	8f8a2f75-e3d3-4f99-8096-bcd7694cb246	Nagpur Bus Stand	2	9fbd3bf1-91f8-410c-a556-e9ebfad81494	\N
bd019792-ac08-42d2-b6a9-5cf60b147f7d	4f17a1b3-f123-4d50-971c-5c6ae735bac8	Nagpur Bus Stand	2	9fbd3bf1-91f8-410c-a556-e9ebfad81494	\N
82665664-b521-4a2a-af57-286807db9bdf	57594440-9eca-44e5-83e9-cf59bc438cf9	Nagpur Bus Stand	2	9fbd3bf1-91f8-410c-a556-e9ebfad81494	\N
f895b1a9-f50d-4d5e-99e6-6a03bf35b214	7c71e32d-a751-433d-ad93-b68eb8b69ed5	Nagpur Bus Stand	2	9fbd3bf1-91f8-410c-a556-e9ebfad81494	\N
807cb91b-ff01-4faf-8b2a-4bc5486fefaf	275724a4-19b2-49a8-86f7-1fe28e4491ac	Nagpur Bus Stand	2	9fbd3bf1-91f8-410c-a556-e9ebfad81494	\N
e9f470b8-3bca-44a6-bc44-d7b947d54cd6	bb7d0feb-9a99-4be6-957b-7f5a0d34616d	Mumbai Bus Stand	2	32509f9b-9730-45f5-a5a0-32574b245f19	\N
28f017ea-710d-475a-8815-d01d74cab080	082b9586-2481-4db2-aa7c-046e1f9aaadd	Mumbai Bus Stand	2	32509f9b-9730-45f5-a5a0-32574b245f19	\N
78a8a11f-1079-4d02-b6a8-d0a0d28b8699	c2d0ac0c-fa4c-4243-8f7c-0e74889468d2	Mumbai Bus Stand	2	32509f9b-9730-45f5-a5a0-32574b245f19	\N
a3c8a5fb-1b46-4891-8ed4-b49c7023cf14	708fdefd-7184-4adb-b046-1a97c32bb4e3	Mumbai Bus Stand	5	32509f9b-9730-45f5-a5a0-32574b245f19	\N
bef009a7-0128-480e-a0c6-0bfa66869e5a	569edd65-5480-4cc3-b776-9ad8abd6ccfd	Mumbai Bus Stand	5	32509f9b-9730-45f5-a5a0-32574b245f19	\N
e8796c5a-50c1-4d2f-9c5e-16b2bedb7ba5	2d73d341-42b9-4202-9e06-94c890086b33	Mumbai Bus Stand	5	32509f9b-9730-45f5-a5a0-32574b245f19	\N
e564ebf1-f92f-4556-9593-23d0ff463426	ce1e8396-e73b-4990-b025-14e27c36e3f1	Mumbai Bus Stand	4	32509f9b-9730-45f5-a5a0-32574b245f19	\N
c5469ae2-1894-4e0e-bc94-7d511a7eed09	8ed57b85-3575-47f2-940e-4e2df6cc4e79	Mumbai Bus Stand	5	32509f9b-9730-45f5-a5a0-32574b245f19	\N
2078cb9b-15a3-4b82-af39-c940800052b4	03e62367-f1d4-4367-bffb-96179f883233	Mumbai Bus Stand	3	32509f9b-9730-45f5-a5a0-32574b245f19	\N
1166d866-2a0a-43ac-8c61-b8542db71117	1ab1cdb2-e817-4947-a76a-39e46e540b2e	Mumbai Bus Stand	2	32509f9b-9730-45f5-a5a0-32574b245f19	\N
c16f697d-1d3b-4d8f-8a10-0932515bd7bb	c8474d27-7b14-47a9-b283-f96e4d524739	Mumbai Bus Stand	2	32509f9b-9730-45f5-a5a0-32574b245f19	\N
60b8585e-bc1b-4401-be43-7b2a7ad1a86c	6fb27a13-cf9e-4ef5-9e41-dd70bfa5046b	Mumbai Bus Stand	2	32509f9b-9730-45f5-a5a0-32574b245f19	\N
a12ee9c8-818d-4a35-8202-91fcd8c849d1	76a7ef0c-420c-4a44-8afa-c84be5cb0c9f	Mumbai Bus Stand	2	32509f9b-9730-45f5-a5a0-32574b245f19	\N
534d98bd-3f0d-4735-a25e-18fc96dbdd41	2924657d-2185-4eb3-8ccc-3c6704f97e09	Nashik Road	1	7907c6f6-7f60-4d24-bd78-19a47642c9f0	\N
833f456f-3dc0-4079-a2e2-dd81b2c7f082	2924657d-2185-4eb3-8ccc-3c6704f97e09	Navi Mumbai Central	2	89a4d273-c02d-4cb1-a5d5-c2a051456de1	\N
7bd7cd60-7f09-4115-8197-d807039571ae	03e62367-f1d4-4367-bffb-96179f883233	Nashik Terminal	1	cf61de0f-b26b-4fcd-b812-28469a27f1ca	\N
8da54163-bc3c-4f3e-a2d2-8ec951f99c41	ce1e8396-e73b-4990-b025-14e27c36e3f1	Nashik Terminal	1	cf61de0f-b26b-4fcd-b812-28469a27f1ca	\N
a02c0f82-38f7-4adc-8d1d-259ae9d8b5f3	0d42e499-6c64-4ee0-8211-e380a0a75256	Unknown Terminal	1	\N	\N
68dda422-7b82-4b61-8c03-12377616cd61	10fc64e2-bac0-4287-98fd-e2671d78a5c6	Unknown Terminal	1	\N	\N
99d60f3f-94ec-469a-bab1-0105f2091698	9f8a4b21-383b-4f73-a387-db44782fa961	Unknown Terminal	1	\N	\N
0f43dc6e-45b9-4cce-b2d8-dcb63f54b2ea	b727b972-b4c8-4fe6-82bb-bd66969b1886	Unknown Terminal	1	\N	\N
890e4662-b7bc-4332-8670-52f50886b19a	ce1e8396-e73b-4990-b025-14e27c36e3f1	Mumbai Terminal	2	77801aed-097f-419d-8392-49c694f215e7	\N
fc5a16f8-3a11-459e-898e-6321c6f0e64e	0d42e499-6c64-4ee0-8211-e380a0a75256	Unknown Terminal	2	\N	\N
71975878-2f70-45e4-9ecc-2dfeb75e0ade	10fc64e2-bac0-4287-98fd-e2671d78a5c6	Unknown Terminal	2	\N	\N
56b41c5d-ea54-4b98-bbe8-663258036f07	9f8a4b21-383b-4f73-a387-db44782fa961	Unknown Terminal	2	\N	\N
81f14635-f4ff-476a-854a-ba561cffca96	b727b972-b4c8-4fe6-82bb-bd66969b1886	Unknown Terminal	2	\N	\N
16d5675a-13b7-4f53-bc6e-ce6f3561c8a6	21b10bc7-271d-4c57-ba86-3c1de68fb5ba	Mumbai Central Terminal	1	acf1d194-4ed6-4d46-984e-12b8c64a5fb2	\N
6632c515-6b37-4bee-a0ec-681085fcbbd2	21b10bc7-271d-4c57-ba86-3c1de68fb5ba	Navi Mumbai Terminal	2	e34be0dd-f98d-410d-b558-a3572d68b254	\N
5ed8bc42-4c32-4f08-84ee-dd811812b233	93fd8914-3277-49cd-981b-55d598c71e1f	Nagpur Central Terminal	1	0e26e5e6-2507-44ee-8ec2-1295d22687e0	\N
532cfbde-fb38-480d-8be9-fe494d67f322	93fd8914-3277-49cd-981b-55d598c71e1f	Wardha Terminal	2	051d92d3-b7f0-44ac-8e2d-b494d9ffb975	\N
\.


--
-- Data for Name: routes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.routes (id, name, origin, destination, from_city, to_city, title, code, from_city_id, to_city_id, distance_km, estimated_duration_minutes, is_active, updated_at, description) FROM stdin;
46bd5490-6dc2-4516-9f81-4c951f5bd2da	Mumbai → Pune Express	Mumbai	Pune	\N	\N	\N	\N	627545c8-f3f5-4474-94b5-122f1a50cb2d	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	148	180	t	2025-09-13 17:53:22.555806+00	
76a7ef0c-420c-4a44-8afa-c84be5cb0c9f	Pune → Mumbai Express	Pune	Mumbai	\N	\N	\N	\N	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	627545c8-f3f5-4474-94b5-122f1a50cb2d	148	180	t	2025-09-13 17:53:22.555806+00	
3d05219f-72ef-46af-a926-79bcfc125867	Mumbai → Nashik Highway	Mumbai	Nashik	\N	\N	\N	\N	627545c8-f3f5-4474-94b5-122f1a50cb2d	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	165	210	t	2025-09-13 17:53:22.555806+00	
58ee9f29-af5f-4de6-ac97-16aa5b172e4b	Nashik → Mumbai Highway	Nashik	Mumbai	\N	\N	\N	\N	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	627545c8-f3f5-4474-94b5-122f1a50cb2d	165	210	t	2025-09-13 17:53:22.555806+00	
ad0a19ca-677e-43f8-a98f-6c4568191a67	Mumbai → Aurangabad Express	Mumbai	Aurangabad	\N	\N	\N	\N	627545c8-f3f5-4474-94b5-122f1a50cb2d	3b5e7c03-ab0a-4563-a3cd-d8406e46768f	335	420	t	2025-09-13 17:53:22.555806+00	
6fb27a13-cf9e-4ef5-9e41-dd70bfa5046b	Aurangabad → Mumbai Express	Aurangabad	Mumbai	\N	\N	\N	\N	3b5e7c03-ab0a-4563-a3cd-d8406e46768f	627545c8-f3f5-4474-94b5-122f1a50cb2d	335	420	t	2025-09-13 17:53:22.555806+00	
275724a4-19b2-49a8-86f7-1fe28e4491ac	Mumbai → Nagpur Express	Mumbai	Nagpur	\N	\N	\N	\N	627545c8-f3f5-4474-94b5-122f1a50cb2d	51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	840	900	t	2025-09-13 17:53:22.555806+00	
c8474d27-7b14-47a9-b283-f96e4d524739	Nagpur → Mumbai Express	Nagpur	Mumbai	\N	\N	\N	\N	51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	627545c8-f3f5-4474-94b5-122f1a50cb2d	840	900	t	2025-09-13 17:53:22.555806+00	
5cd9e616-4fce-4ae3-ae07-2ee6a79fbf37	Mumbai → Kolhapur Express	Mumbai	Kolhapur	\N	\N	\N	\N	627545c8-f3f5-4474-94b5-122f1a50cb2d	51ea939c-9cdd-45b7-9c79-7b1aa4b5fe5f	385	480	t	2025-09-13 17:53:22.555806+00	
1ab1cdb2-e817-4947-a76a-39e46e540b2e	Kolhapur → Mumbai Express	Kolhapur	Mumbai	\N	\N	\N	\N	51ea939c-9cdd-45b7-9c79-7b1aa4b5fe5f	627545c8-f3f5-4474-94b5-122f1a50cb2d	385	480	t	2025-09-13 17:53:22.555806+00	
03e62367-f1d4-4367-bffb-96179f883233	Nashik → Mumbai Airport	Nashik	Mumbai	\N	\N	Nashik → Mumbai Airport	NSK-MUM-01	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	627545c8-f3f5-4474-94b5-122f1a50cb2d	170	200	t	2025-09-11 19:23:48.989268+00	
8ed57b85-3575-47f2-940e-4e2df6cc4e79	Nashik → Navi Mumbai	Nashik	Mumbai	\N	\N	Nashik → Navi Mumbai	NSK-MUM-02	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	627545c8-f3f5-4474-94b5-122f1a50cb2d	185	210	t	2025-09-11 19:23:48.989268+00	
ce1e8396-e73b-4990-b025-14e27c36e3f1	Nashik → Mumbai CST	Nashik	Mumbai	\N	\N	Nashik → Mumbai CST	NSK-MUM-03	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	627545c8-f3f5-4474-94b5-122f1a50cb2d	167	180	t	2025-09-11 19:23:48.989268+00	
2d73d341-42b9-4202-9e06-94c890086b33	Nashik → Andheri	Nashik	Mumbai	\N	\N	Nashik → Andheri	ROUTE-2d73d341	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	627545c8-f3f5-4474-94b5-122f1a50cb2d	220	130	t	2025-09-11 19:23:48.989268+00	
c1b50f82-ccae-48ef-8c2d-e71868863eaa	Mumbai → Pune via Expressway	Mumbai	Pune	\N	\N	Mumbai → Pune via Expressway	ROUTE-c1b50f82	627545c8-f3f5-4474-94b5-122f1a50cb2d	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	234	126	t	2025-09-11 19:23:48.989268+00	
b1c1b3e1-8515-41f1-b12c-91997ce1ad3c	Nashik–Sinnar–Sangamner–Chakan–Pune	Nashik	Pune	Nashik	Pune	Nashik–Sinnar–Sangamner–Chakan–Pune	ROUTE-b1c1b3e1	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	183	143	t	2025-09-11 19:23:48.989268+00	
b3c7a68b-2dfc-4832-9f41-e1bcdb95c930	Nashik–Ghoti–Lonavala–Shivajinagar	Nashik	Pune	Nashik	Pune	Nashik–Ghoti–Lonavala–Shivajinagar	ROUTE-b3c7a68b	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	216	150	t	2025-09-11 19:23:48.989268+00	
569edd65-5480-4cc3-b776-9ad8abd6ccfd	Pune–Lonavala–Vashi–Sion	Pune	Mumbai	Pune	Mumbai	Pune–Lonavala–Vashi–Sion	ROUTE-569edd65	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	627545c8-f3f5-4474-94b5-122f1a50cb2d	188	127	t	2025-09-11 19:23:48.989268+00	
708fdefd-7184-4adb-b046-1a97c32bb4e3	Nashik–Ghoti–Thane–Sion	Nashik	Mumbai	Nashik	Mumbai	Nashik–Ghoti–Thane–Sion	ROUTE-708fdefd	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	627545c8-f3f5-4474-94b5-122f1a50cb2d	180	170	t	2025-09-11 19:23:48.989268+00	
357a59eb-6e71-4c44-ad9a-bcb039908518	Nashik to Pune Express	Nashik	Pune	Nashik	Pune	\N	NSK-PUN-01	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	210	240	t	2025-09-11 19:23:48.989268+00	
81fb131a-f618-4108-b712-116db5ab5fcc	Mumbai to Pune Highway	Mumbai	Pune	Mumbai	Pune	\N	MUM-PUN-01	627545c8-f3f5-4474-94b5-122f1a50cb2d	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	148	180	t	2025-09-11 19:23:48.989268+00	
c2d0ac0c-fa4c-4243-8f7c-0e74889468d2	Nashik → Mumbai	Nashik	Mumbai	\N	\N	\N	\N	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	627545c8-f3f5-4474-94b5-122f1a50cb2d	\N	\N	t	2025-09-13 08:18:08.695726+00	
bf770759-b190-4d6d-9fcd-268be6fffcb5	Mumbai → Nashik	Mumbai	Nashik	\N	\N	\N	\N	627545c8-f3f5-4474-94b5-122f1a50cb2d	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	\N	\N	t	2025-09-13 08:18:08.887093+00	
04ec8116-f0a1-43cb-9f56-35a3f569ad22	Mumbai → Thane Local	Mumbai	Thane	\N	\N	\N	\N	627545c8-f3f5-4474-94b5-122f1a50cb2d	03c170b0-a315-459a-81a3-00db16bdc9d9	35	60	t	2025-09-13 17:53:22.555806+00	
082b9586-2481-4db2-aa7c-046e1f9aaadd	Thane → Mumbai Local	Thane	Mumbai	\N	\N	\N	\N	03c170b0-a315-459a-81a3-00db16bdc9d9	627545c8-f3f5-4474-94b5-122f1a50cb2d	35	60	t	2025-09-13 17:53:22.555806+00	
54080c71-6e51-47e1-8413-4c35e57416c9	Mumbai → Satara	Mumbai	Satara	\N	\N	\N	\N	627545c8-f3f5-4474-94b5-122f1a50cb2d	63e57908-1733-4897-984b-7de1b32ee609	270	360	t	2025-09-13 17:53:22.555806+00	
bb7d0feb-9a99-4be6-957b-7f5a0d34616d	Satara → Mumbai	Satara	Mumbai	\N	\N	\N	\N	63e57908-1733-4897-984b-7de1b32ee609	627545c8-f3f5-4474-94b5-122f1a50cb2d	270	360	t	2025-09-13 17:53:22.555806+00	
7c6e06cd-1661-4810-8994-c83d085c24a3	Pune → Nashik Express	Pune	Nashik	\N	\N	\N	\N	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	210	270	t	2025-09-13 17:53:22.555806+00	
ce47a01c-54fd-4bc4-941c-5916b652c6a9	Nashik → Pune Express	Nashik	Pune	\N	\N	\N	\N	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	210	270	t	2025-09-13 17:53:22.555806+00	
35272a9c-c28c-4f3a-a01f-077f7330c693	Pune → Aurangabad Express	Pune	Aurangabad	\N	\N	\N	\N	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	3b5e7c03-ab0a-4563-a3cd-d8406e46768f	235	300	t	2025-09-13 17:53:22.555806+00	
a9253d58-9032-4912-92e6-1804880e1853	Aurangabad → Pune Express	Aurangabad	Pune	\N	\N	\N	\N	3b5e7c03-ab0a-4563-a3cd-d8406e46768f	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	235	300	t	2025-09-13 17:53:22.555806+00	
c6f604fd-58a9-47cb-a7ac-a193dcf8a8c0	Pune → Kolhapur Express	Pune	Kolhapur	\N	\N	\N	\N	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	51ea939c-9cdd-45b7-9c79-7b1aa4b5fe5f	230	300	t	2025-09-13 17:53:22.555806+00	
6e349c5f-01ba-4a99-8fd5-edf882d4ed03	Kolhapur → Pune Express	Kolhapur	Pune	\N	\N	\N	\N	51ea939c-9cdd-45b7-9c79-7b1aa4b5fe5f	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	230	300	t	2025-09-13 17:53:22.555806+00	
2d1f0d05-df07-47e1-9a42-e0456fcbbe9b	Pune → Solapur Express	Pune	Solapur	\N	\N	\N	\N	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	c68159e6-24da-4d92-a460-35ed1aea3814	250	330	t	2025-09-13 17:53:22.555806+00	
6af7cbd4-ce5f-4592-a9a4-5541475e2f5a	Solapur → Pune Express	Solapur	Pune	\N	\N	\N	\N	c68159e6-24da-4d92-a460-35ed1aea3814	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	250	330	t	2025-09-13 17:53:22.555806+00	
3843f62b-dee6-4a86-b984-0ac2cbda7dbc	Pune → Satara Express	Pune	Satara	\N	\N	\N	\N	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	63e57908-1733-4897-984b-7de1b32ee609	110	150	t	2025-09-13 17:53:22.555806+00	
83a55f1c-c28b-414c-b84d-a4bdfb9e1103	Satara → Pune Express	Satara	Pune	\N	\N	\N	\N	63e57908-1733-4897-984b-7de1b32ee609	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	110	150	t	2025-09-13 17:53:22.555806+00	
d2c96ec6-6f9b-4aa8-8d57-a452e27d4d8d	Pune → Ahmednagar Express	Pune	Ahmednagar	\N	\N	\N	\N	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	42c2b1de-2c19-41ce-a4ad-2ae38987324c	120	180	t	2025-09-13 17:53:22.555806+00	
aba6557b-8f6c-46df-812b-9e9f754a72a9	Ahmednagar → Pune Express	Ahmednagar	Pune	\N	\N	\N	\N	42c2b1de-2c19-41ce-a4ad-2ae38987324c	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	120	180	t	2025-09-13 17:53:22.555806+00	
7c71e32d-a751-433d-ad93-b68eb8b69ed5	Pune → Nagpur Express	Pune	Nagpur	\N	\N	\N	\N	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	700	780	t	2025-09-13 17:53:22.555806+00	
bb580b17-4506-4834-ae95-fe413e318045	Nagpur → Pune Express	Nagpur	Pune	\N	\N	\N	\N	51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	700	780	t	2025-09-13 17:53:22.555806+00	
952da8f8-b7b8-49e8-8fed-3b57e51d4dd0	Nashik → Aurangabad Express	Nashik	Aurangabad	\N	\N	\N	\N	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	3b5e7c03-ab0a-4563-a3cd-d8406e46768f	180	240	t	2025-09-13 17:53:22.555806+00	
6f5ab71d-1463-453d-b07d-fdbca885967e	Aurangabad → Nashik Express	Aurangabad	Nashik	\N	\N	\N	\N	3b5e7c03-ab0a-4563-a3cd-d8406e46768f	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	180	240	t	2025-09-13 17:53:22.555806+00	
90cde7c8-9d0b-4291-9338-69c96ef37aad	Nashik → Dhule Express	Nashik	Dhule	\N	\N	\N	\N	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	8f1807cd-2fa9-4233-8d84-e7e006bdcd0f	140	180	t	2025-09-13 17:53:22.555806+00	
095afb34-5479-478a-b56d-d139a52d9e59	Dhule → Nashik Express	Dhule	Nashik	\N	\N	\N	\N	8f1807cd-2fa9-4233-8d84-e7e006bdcd0f	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	140	180	t	2025-09-13 17:53:22.555806+00	
d57046fb-68e1-4ad3-a462-a4217741404f	Nashik → Jalgaon Express	Nashik	Jalgaon	\N	\N	\N	\N	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	2a849b4b-374f-4ef0-b208-4ba5b9c30067	200	270	t	2025-09-13 17:53:22.555806+00	
d2f3d130-e57a-4885-820f-d4ea0665ca7a	Jalgaon → Nashik Express	Jalgaon	Nashik	\N	\N	\N	\N	2a849b4b-374f-4ef0-b208-4ba5b9c30067	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	200	270	t	2025-09-13 17:53:22.555806+00	
57594440-9eca-44e5-83e9-cf59bc438cf9	Aurangabad → Nagpur Express	Aurangabad	Nagpur	\N	\N	\N	\N	3b5e7c03-ab0a-4563-a3cd-d8406e46768f	51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	430	540	t	2025-09-13 17:53:22.555806+00	
e6852d2d-0aba-4263-96f1-e867aadac19a	Nagpur → Aurangabad Express	Nagpur	Aurangabad	\N	\N	\N	\N	51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	3b5e7c03-ab0a-4563-a3cd-d8406e46768f	430	540	t	2025-09-13 17:53:22.555806+00	
5ff93f8f-79f7-4637-962a-05bffd09f321	Aurangabad → Nanded Express	Aurangabad	Nanded	\N	\N	\N	\N	3b5e7c03-ab0a-4563-a3cd-d8406e46768f	e2523f1f-b9a9-4191-a275-63b4d04822bf	270	360	t	2025-09-13 17:53:22.555806+00	
674865f4-4624-4931-84cc-faaa167b00fe	Nanded → Aurangabad Express	Nanded	Aurangabad	\N	\N	\N	\N	e2523f1f-b9a9-4191-a275-63b4d04822bf	3b5e7c03-ab0a-4563-a3cd-d8406e46768f	270	360	t	2025-09-13 17:53:22.555806+00	
04691799-c20e-45ac-b6e8-949549e4907d	Aurangabad → Jalna Express	Aurangabad	Jalna	\N	\N	\N	\N	3b5e7c03-ab0a-4563-a3cd-d8406e46768f	d36d2cb6-1066-4b83-8f35-c829d1922e72	60	90	t	2025-09-13 17:53:22.555806+00	
8afdbc8b-cb06-44c6-9706-9cf5b2485560	Jalna → Aurangabad Express	Jalna	Aurangabad	\N	\N	\N	\N	d36d2cb6-1066-4b83-8f35-c829d1922e72	3b5e7c03-ab0a-4563-a3cd-d8406e46768f	60	90	t	2025-09-13 17:53:22.555806+00	
5abee3d1-362d-4b73-b6cf-291823e5bfbd	Aurangabad → Latur Express	Aurangabad	Latur	\N	\N	\N	\N	3b5e7c03-ab0a-4563-a3cd-d8406e46768f	54a58b5c-1608-466e-b77f-ecbc3a0a4298	145	210	t	2025-09-13 17:53:22.555806+00	
8f7208c0-307c-49bf-b1f6-f481e1ae1549	Latur → Aurangabad Express	Latur	Aurangabad	\N	\N	\N	\N	54a58b5c-1608-466e-b77f-ecbc3a0a4298	3b5e7c03-ab0a-4563-a3cd-d8406e46768f	145	210	t	2025-09-13 17:53:22.555806+00	
2ee02a20-45b2-4a64-8fa7-4a558b611487	Nagpur → Amravati Express	Nagpur	Amravati	\N	\N	\N	\N	51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	fc194277-addd-49f2-bb6d-350f0719b08d	155	210	t	2025-09-13 17:53:22.555806+00	
4f17a1b3-f123-4d50-971c-5c6ae735bac8	Amravati → Nagpur Express	Amravati	Nagpur	\N	\N	\N	\N	fc194277-addd-49f2-bb6d-350f0719b08d	51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	155	210	t	2025-09-13 17:53:22.555806+00	
42f698f2-c93e-470a-96ec-b35152a3a726	Nagpur → Akola Express	Nagpur	Akola	\N	\N	\N	\N	51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	268987e8-7182-45a9-9a36-c30c9ecaf462	250	330	t	2025-09-13 17:53:22.555806+00	
8f8a2f75-e3d3-4f99-8096-bcd7694cb246	Akola → Nagpur Express	Akola	Nagpur	\N	\N	\N	\N	268987e8-7182-45a9-9a36-c30c9ecaf462	51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	250	330	t	2025-09-13 17:53:22.555806+00	
205767dc-42b0-47a7-a0f6-e4b9131c8b03	Nagpur → Chandrapur Express	Nagpur	Chandrapur	\N	\N	\N	\N	51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	048ef14e-7d86-4e79-9f70-549c4aa5a49b	165	220	t	2025-09-13 17:53:22.555806+00	
ebef5590-93b9-4d1a-9dd2-77f2a34c2941	Chandrapur → Nagpur Express	Chandrapur	Nagpur	\N	\N	\N	\N	048ef14e-7d86-4e79-9f70-549c4aa5a49b	51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	165	220	t	2025-09-13 17:53:22.555806+00	
2924657d-2185-4eb3-8ccc-3c6704f97e09	Nashik → Navi Mumbai Express	Nashik	Navi Mumbai	\N	\N	\N	\N	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	4253134e-580d-4cce-a083-99c73399705f	180	220	t	2025-09-13 19:03:19.531509+00	
21b10bc7-271d-4c57-ba86-3c1de68fb5ba	Mumbai → Navi Mumbai Express	Mumbai	Navi Mumbai	\N	\N	\N	\N	627545c8-f3f5-4474-94b5-122f1a50cb2d	4253134e-580d-4cce-a083-99c73399705f	25	45	t	2025-09-13 19:22:32.176117+00	
93fd8914-3277-49cd-981b-55d598c71e1f	Nagpur → Wardha Express	Nagpur	Wardha	\N	\N	\N	\N	51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	334a0c23-66de-44da-a535-9336fd035c76	200	240	t	2025-09-13 19:22:32.176117+00	
0d42e499-6c64-4ee0-8211-e380a0a75256	_migrated_0d42e499	Unknown	Unknown	Unknown	Unknown	_migrated_placeholder	ROUTE-0d42e499	\N	\N	169	126	t	2025-09-11 19:23:48.989268+00	
10fc64e2-bac0-4287-98fd-e2671d78a5c6	_migrated_10fc64e2	Unknown	Unknown	Unknown	Unknown	_migrated_placeholder	ROUTE-10fc64e2	\N	\N	181	176	t	2025-09-11 19:23:48.989268+00	
9f8a4b21-383b-4f73-a387-db44782fa961	_migrated_9f8a4b21	Unknown	Unknown	Unknown	Unknown	_migrated_placeholder	ROUTE-9f8a4b21	\N	\N	220	143	t	2025-09-11 19:23:48.989268+00	
b727b972-b4c8-4fe6-82bb-bd66969b1886	_migrated_b727b972	Unknown	Unknown	Unknown	Unknown	_migrated_placeholder	ROUTE-b727b972	\N	\N	243	178	t	2025-09-11 19:23:48.989268+00	
56fa2dcf-4de8-4f70-bf74-69c48a53767f	NSK-MUM	NASHIK	MUMBAI	\N	\N	NSK-MUM	ROUTE-56fa2dcf	\N	\N	178	157	t	2025-09-11 19:23:48.989268+00	
624b476a-4097-4677-9eff-d9df603b7cd7	Mumbai to Pune	Mumbai	Pune	\N	\N	\N	\N	\N	\N	\N	\N	t	2025-09-15 08:51:48.573827+00	
19f83c14-de61-4473-8a89-575e0a00d453	Mumbai-Pune Express	Mumbai	Pune	Mumbai	Pune	\N	\N	\N	\N	148	180	t	2025-09-19 02:10:26.196951+00	Express route via Mumbai-Pune Expressway
0e88a926-3a4b-4210-9ed7-d4292555f4a1	Nashik-Mumbai Highway	Nashik	Mumbai	Nashik	Mumbai	\N	\N	\N	\N	165	210	t	2025-09-19 02:10:26.196951+00	Route via NH-3 highway
17cc5d9c-eb5a-4870-bffd-540ec602d288	Pune-Nashik Direct	Pune	Nashik	Pune	Nashik	\N	\N	\N	\N	210	240	t	2025-09-19 02:10:26.196951+00	Direct route connecting Pune and Nashik
\.


--
-- Data for Name: settlements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.settlements (id, user_id, amount_inr, status, cycle_start, cycle_end, requested_at, processed_at) FROM stdin;
\.


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- Data for Name: stops; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.stops (id, city_id, name, latitude, longitude, created_at, geom, address, city_name, stop_order, is_pickup, is_drop, is_active, route_id) FROM stdin;
a878c6fc-23de-459d-9296-84080608ac41	627545c8-f3f5-4474-94b5-122f1a50cb2d	Andheri East Metro	\N	\N	2025-08-19 13:19:34.564934+00	\N	\N	\N	\N	t	t	t	\N
dd33f1a0-3bc8-4bd5-8c2d-58b13a88d0a0	627545c8-f3f5-4474-94b5-122f1a50cb2d	Bandra Station	\N	\N	2025-08-19 13:19:34.564934+00	\N	\N	\N	\N	t	t	t	\N
2508c4db-fc44-4ffc-84c5-f89995b88a7a	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	Shivajinagar	\N	\N	2025-08-19 13:19:34.564934+00	\N	\N	\N	\N	t	t	t	\N
09215d3b-2024-446e-992a-c66d1cd124d9	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	Kothrud Depot	\N	\N	2025-08-19 13:19:34.564934+00	\N	\N	\N	\N	t	t	t	\N
acf1d194-4ed6-4d46-984e-12b8c64a5fb2	627545c8-f3f5-4474-94b5-122f1a50cb2d	Dadar	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
6ac8d1e7-e1c9-4bbb-8bfe-628de2e23212	627545c8-f3f5-4474-94b5-122f1a50cb2d	CST	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
05851feb-4ca9-4955-8de1-d53e626ad5b8	627545c8-f3f5-4474-94b5-122f1a50cb2d	Mumbai Central	\N	\N	2025-08-21 06:54:54.571445+00	\N	\N	\N	\N	t	t	t	\N
33fdb41a-ef4f-4ee4-84d6-0ca6f8f1d3ee	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	Pune Station	\N	\N	2025-08-21 06:54:54.571445+00	\N	\N	\N	\N	t	t	t	\N
db45d0f8-6598-4fb6-a818-a0a1792b61de	\N	CBS	\N	\N	2025-09-06 12:47:45.210274+00	\N	\N	\N	\N	t	t	t	\N
2c5a4fd1-d611-43cb-a347-d7eb7be2a04c	\N	Sinnar	\N	\N	2025-09-06 12:47:45.210274+00	\N	\N	\N	\N	t	t	t	\N
a2226960-3676-4497-b298-7119278ebe3d	\N	Ghoti	\N	\N	2025-09-06 12:47:45.210274+00	\N	\N	\N	\N	t	t	t	\N
5993172c-ae87-445f-b0cf-04c402113a4d	\N	Wakad	\N	\N	2025-09-06 12:47:45.210274+00	\N	\N	\N	\N	t	t	t	\N
c35601f1-2885-4f9f-b3c6-07cc8e40a791	\N	Shivajinagar	\N	\N	2025-09-06 12:47:45.210274+00	\N	\N	\N	\N	t	t	t	\N
fdb1af71-9fd3-4731-b828-34d09d23bc23	\N	Hadapsar	\N	\N	2025-09-06 12:47:45.210274+00	\N	\N	\N	\N	t	t	t	\N
182ac9ca-03f9-4294-a670-ef5bb04bb311	\N	Thane	\N	\N	2025-09-06 12:47:45.210274+00	\N	\N	\N	\N	t	t	t	\N
5b44f8fe-7210-42e7-8ff0-bc79a2b6c943	\N	Vashi	\N	\N	2025-09-06 12:47:45.210274+00	\N	\N	\N	\N	t	t	t	\N
b95d4eab-9ea5-4572-8fff-671709799d4c	\N	Sion	\N	\N	2025-09-06 12:47:45.210274+00	\N	\N	\N	\N	t	t	t	\N
80d8cb0a-73a0-4273-963d-4c9923ab88bb	\N	Lonavala	\N	\N	2025-09-06 12:47:45.210274+00	\N	\N	\N	\N	t	t	t	\N
7db53349-29f6-4052-8b15-adf62c21dbff	\N	Sangamner	\N	\N	2025-09-06 12:47:45.210274+00	\N	\N	\N	\N	t	t	t	\N
86ad11a6-87b0-4843-9906-23257dbc3a82	\N	Chakan	\N	\N	2025-09-06 12:47:45.210274+00	\N	\N	\N	\N	t	t	t	\N
5fc547db-ddd4-4b37-93c4-c6a6cb2eb024	\N	Nashik City	\N	\N	2025-09-06 18:53:58.497898+00	\N	\N	\N	\N	t	t	t	\N
f623bc0f-47b8-40f5-b49d-647b05781d73	\N	Mumbai Central	\N	\N	2025-09-06 19:01:35.266676+00	\N	\N	\N	\N	t	t	t	\N
0edd6f26-7929-4914-9d4c-af996bc321f2	\N	Mumbai- Thane	\N	\N	2025-09-06 19:02:21.842994+00	\N	\N	\N	\N	t	t	t	\N
ed28f4ac-7676-474b-8777-4e827361f808	\N	Nashik Central Bus Stand	\N	\N	2025-09-11 19:23:48.989268+00	\N	CBS Road, Nashik	Nashik	1	t	f	t	\N
da9ecdaa-60e2-43e1-b4eb-cab9313aacfe	\N	Nashik Road Railway Station	\N	\N	2025-09-11 19:23:48.989268+00	\N	Station Road, Nashik	Nashik	2	t	f	t	\N
e1376aca-0c73-406c-8a5b-f1286a788b9f	\N	Kalyan Junction	\N	\N	2025-09-11 19:23:48.989268+00	\N	Kalyan East, Thane	Kalyan	3	t	t	t	\N
c953b96d-764b-4ac3-9732-b232568f493f	\N	Thane Railway Station	\N	\N	2025-09-11 19:23:48.989268+00	\N	Station Road, Thane	Thane	4	f	t	t	\N
26627a7b-2e32-4916-9e30-bdf13e7b00a0	\N	Mumbai Airport Terminal 1	\N	\N	2025-09-11 19:23:48.989268+00	\N	Andheri East, Mumbai	Mumbai	5	f	t	t	\N
b82fbfca-b47f-4b08-9e7e-221e0a539529	\N	Mumbai Airport Terminal 2	\N	\N	2025-09-11 19:23:48.989268+00	\N	Andheri East, Mumbai	Mumbai	6	f	t	t	\N
7ac1789a-cd54-4cf8-a225-a8048f32a3f9	\N	Nashik CBS	\N	\N	2025-09-11 19:23:48.989268+00	\N	CBS Road, Nashik	Nashik	1	t	f	t	\N
15cdf321-9daf-44d2-9be7-206159b4a19b	\N	Sinnar Toll Plaza	\N	\N	2025-09-11 19:23:48.989268+00	\N	NH-3, Sinnar	Sinnar	2	t	t	t	\N
d88cc113-e1c4-4344-8b55-77de4d01c26b	\N	Kalyan West	\N	\N	2025-09-11 19:23:48.989268+00	\N	Kalyan West, Thane	Kalyan	3	t	t	t	\N
eb2b4bae-14d8-4aa6-a68e-005da14aa409	\N	Panvel Junction	\N	\N	2025-09-11 19:23:48.989268+00	\N	Panvel, Navi Mumbai	Panvel	4	f	t	t	\N
fb9b8599-8ce8-4249-8d53-bd4e9a33da07	\N	Vashi Railway Station	\N	\N	2025-09-11 19:23:48.989268+00	\N	Vashi, Navi Mumbai	Vashi	5	f	t	t	\N
e1be8692-d511-484e-9c15-a773fe552f63	\N	Belapur CBD	\N	\N	2025-09-11 19:23:48.989268+00	\N	CBD Belapur, Navi Mumbai	Belapur	6	f	t	t	\N
d3cfabdd-ade8-4b11-a025-9158bf489bf6	\N	Nashik Central	\N	\N	2025-09-11 19:23:48.989268+00	\N	CBS Road, Nashik	Nashik	1	t	f	t	\N
27cf85c1-2118-4800-bb8e-61a6d04f4cc5	\N	Ghoti Toll Plaza	\N	\N	2025-09-11 19:23:48.989268+00	\N	NH-3, Ghoti	Ghoti	2	t	t	t	\N
98630322-bc36-455f-bb09-b47d8ad22a84	\N	Kasara Railway Station	\N	\N	2025-09-11 19:23:48.989268+00	\N	Kasara, Thane	Kasara	3	t	t	t	\N
e5b4c5fc-d11e-4d41-90e2-3382855b14c5	\N	Kalyan Junction	\N	\N	2025-09-11 19:23:48.989268+00	\N	Kalyan East, Thane	Kalyan	4	t	t	t	\N
92540a29-96d6-48d7-95d9-dda76427c94f	\N	Dadar Railway Station	\N	\N	2025-09-11 19:23:48.989268+00	\N	Dadar West, Mumbai	Mumbai	5	f	t	t	\N
2812bf93-4687-44a4-9f99-c772a924e7fe	\N	Mumbai CST	\N	\N	2025-09-11 19:23:48.989268+00	\N	Fort, Mumbai	Mumbai	6	f	t	t	\N
35823877-42c3-4f31-ad8d-904aee56d13b	\N	Nashik CBS	\N	\N	2025-09-11 19:23:48.989268+00	\N	CBS Road, Nashik	Nashik	1	t	f	t	\N
ac18318d-2ebc-43e0-ae37-f59e6eda913f	\N	Shirdi	\N	\N	2025-09-11 19:23:48.989268+00	\N	Shirdi Town, Ahmednagar	Shirdi	2	t	t	t	\N
d75060fd-381c-47fc-92bb-982696a1d235	\N	Ahmednagar	\N	\N	2025-09-11 19:23:48.989268+00	\N	Ahmednagar Bus Stand	Ahmednagar	3	t	t	t	\N
a20e7c1b-d3a7-4584-b5b8-292712b1c6db	\N	Pune Station	\N	\N	2025-09-11 19:23:48.989268+00	\N	Railway Station, Pune	Pune	4	f	t	t	\N
ca19c28b-2e51-4a1c-ad38-ec57824fe9e1	\N	Shivajinagar	\N	\N	2025-09-11 19:23:48.989268+00	\N	Shivajinagar, Pune	Pune	5	f	t	t	\N
1031c04a-9195-4136-bd42-1b45286b6a1f	\N	Vashi	\N	\N	2025-09-12 21:54:22.704872+00	\N	\N	\N	\N	t	t	t	\N
29d321c9-b1e9-4045-8f83-94baef62865b	\N	Vashi	\N	\N	2025-09-12 21:54:30.974884+00	\N	\N	\N	\N	t	t	t	\N
b9d62f65-9e29-43ad-a5f3-de2c6825bbef	627545c8-f3f5-4474-94b5-122f1a50cb2d	Kurla	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
7d2f878f-e9ba-4e04-b09a-a49eaa14d013	627545c8-f3f5-4474-94b5-122f1a50cb2d	Andheri	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
f7e0ce8a-5b2f-48b3-9c54-f2f8738617c0	627545c8-f3f5-4474-94b5-122f1a50cb2d	Borivali	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
4766881d-11f2-426b-ab49-d4ba579a48d0	627545c8-f3f5-4474-94b5-122f1a50cb2d	Thane Station	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
eb87e0a6-9c38-4ac2-9595-a92652bd4cb1	627545c8-f3f5-4474-94b5-122f1a50cb2d	Bandra	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
0441ee41-79d9-45f3-9fd8-8d24b4f48fcf	627545c8-f3f5-4474-94b5-122f1a50cb2d	Vile Parle	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
c0dc090f-2d38-4090-8c33-e9b4e5d2f9ff	627545c8-f3f5-4474-94b5-122f1a50cb2d	Goregaon	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
b8133094-99a6-4018-adb3-741cadc988d5	627545c8-f3f5-4474-94b5-122f1a50cb2d	Malad	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
38f2b83e-1596-4ac3-9d9b-728ea4780784	627545c8-f3f5-4474-94b5-122f1a50cb2d	Kandivali	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
492356e9-c5d9-4999-9805-7978044c6517	627545c8-f3f5-4474-94b5-122f1a50cb2d	Mulund	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
06126a26-bfe6-45bc-9bd5-f4b789e8f066	627545c8-f3f5-4474-94b5-122f1a50cb2d	Ghatkopar	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
f3f0d219-090c-4b3b-a272-671f709edecd	627545c8-f3f5-4474-94b5-122f1a50cb2d	Chembur	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
81867aee-6c46-40d2-b799-cb7f9a339b12	627545c8-f3f5-4474-94b5-122f1a50cb2d	Vikhroli	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
62b7de1c-084c-4098-9acc-3a242d653d25	627545c8-f3f5-4474-94b5-122f1a50cb2d	Panvel	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
906818de-6978-4b07-a162-f5709008bc20	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	Swargate	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
fe03f6a7-87dc-470a-a845-4f0d1aa25b46	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	Shivaji Nagar	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
86c28b14-2afe-4a55-95c8-7128f02ca245	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	Katraj	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
752743fb-f1c3-4e1d-ace7-e98b8f472563	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	Aundh	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
dd9fdef1-0e5e-4c9f-ac28-8ed51b5ef60d	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	Kothrud	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
ddacc227-3c2d-463d-8a3c-8128733af49a	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	Deccan	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
13b1cd20-74e3-4158-a6c4-b89e8a8087e5	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	Camp	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
1e964122-c475-4ed7-a56f-a19a4a07659f	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	Hadapsar	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
8b3f9dc3-b119-4436-9f30-094e2f7d28e6	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	Wakad	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
d9594c5d-0f42-456b-9f8b-f01142f3cefd	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	Chinchwad	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
498ffb2d-6c65-47bb-b9f2-165020ce7f3e	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	Pimpri	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
a76a1692-26dd-4bfd-b41c-d151e61491bd	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	Nigdi	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
aa5d6619-2348-44c1-bb2f-4da5d2f3c655	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	Dehu Road	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
5dbbf3c2-6a07-46c0-a306-d21ce33b232d	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	Talegaon	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
7907c6f6-7f60-4d24-bd78-19a47642c9f0	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	Nashik Road	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
833eb036-2ea5-4fb6-9b67-4d634b3be920	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	College Road	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
8d1612fc-f9ef-451d-a6a1-41bafb3effe3	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	Pathardi Phata	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
205c5cee-846f-40f8-a745-4692a5c6316d	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	CBS	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
d657d04a-aca4-4fd5-a549-01513e67a715	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	Gangapur Road	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
0acbd2df-b9a3-425d-8510-723518909fa2	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	Adgaon	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
abe00f19-8ac5-4c0b-aae7-4d4c2426481b	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	Sinnar	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
e34c4b30-65ca-46f2-89f2-d6fe570af13f	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	Igatpuri	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
ff87eb11-cb9b-48d0-b3bc-5b20352144b0	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	Ghoti	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
b8fad356-0a27-48bf-9f9a-b067a1d2482a	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	Trimbak Road	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
05ddb313-9fe7-4541-9df4-5b78a723b3f9	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	Cidco	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
7e687469-0fab-444c-b3e2-a03e750f137b	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	Medical College	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
e1f5c88c-fdd7-415e-88c6-fb1b0f426ca1	3b5e7c03-ab0a-4563-a3cd-d8406e46768f	Aurangabad Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
efbaaacd-b7a9-4b47-b3a3-463e44cee561	3b5e7c03-ab0a-4563-a3cd-d8406e46768f	Kranti Chowk	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
8166c403-030f-4346-b1ae-85f28716795d	3b5e7c03-ab0a-4563-a3cd-d8406e46768f	Cidco	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
4436d4c8-ec0c-430c-8cab-1b4f40c20ce9	3b5e7c03-ab0a-4563-a3cd-d8406e46768f	Town Hall	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
6ca9ec6d-10aa-4e09-9651-ccad5f8ed30c	3b5e7c03-ab0a-4563-a3cd-d8406e46768f	Railway Station	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
d119649e-b98d-44b4-9ce4-e97c5f3ce0e9	3b5e7c03-ab0a-4563-a3cd-d8406e46768f	Medical College	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
7a3b19ec-fe13-41f9-a6db-3284572d7035	3b5e7c03-ab0a-4563-a3cd-d8406e46768f	MIDC	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
07d78c27-e4bb-4492-8109-a0ce26672f98	3b5e7c03-ab0a-4563-a3cd-d8406e46768f	Jalna Road	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
d8861528-e280-4fe4-83e2-22d006bc4f4f	3b5e7c03-ab0a-4563-a3cd-d8406e46768f	Airport Road	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
55eeb658-307f-40a4-b895-1adb35d2cada	3b5e7c03-ab0a-4563-a3cd-d8406e46768f	Paithan Road	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
873db1fc-5270-4558-bd24-d11257bef535	51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	Nagpur Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
de7188cf-c2d1-4134-9784-86bac3d20adc	51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	Itwari	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
9d889196-3be4-4936-bcc5-6fe572678546	51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	Sitabuldi	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
8d219559-05c0-4bc4-b9d3-bcc81ae6c98c	51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	Medical Square	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
c12da490-40bd-442e-b677-74dd476a8d9a	51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	Dharampeth	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
775aa6ab-900f-4d62-8d3c-3e663be10ef8	51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	Civil Lines	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
98198342-dd30-4fd5-a62c-2dfe67a1ba02	51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	Sadar	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
0cac8c74-264f-437a-9090-db39d839eea8	51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	Seminary Hills	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
c5f054a7-c52b-4176-b8df-0282cadb0986	51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	Wardha Road	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
ec694cab-1b84-487d-a886-f0f19203e90b	51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	Amravati Road	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
4193a754-d783-47a6-9bdd-aac6bdb1fd24	51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	Kamptee Road	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
c6a732fb-116d-44b5-ac5a-71d8e380a0b4	51ea939c-9cdd-45b7-9c79-7b1aa4b5fe5f	Kolhapur Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
c52cdbd9-d2ec-4081-9e77-2716ef5209ee	51ea939c-9cdd-45b7-9c79-7b1aa4b5fe5f	Mahadwar Road	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
90e1908b-3f72-4563-85cb-055ee78758e8	51ea939c-9cdd-45b7-9c79-7b1aa4b5fe5f	Station Road	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
447297c1-1cb3-4b70-92b0-bb14cd6919ff	51ea939c-9cdd-45b7-9c79-7b1aa4b5fe5f	Rankala	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
2a109a99-7b0d-4b32-adc9-89dfa7421b87	51ea939c-9cdd-45b7-9c79-7b1aa4b5fe5f	Tarabai Park	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
09499529-5386-44fa-a424-18a8d0403902	51ea939c-9cdd-45b7-9c79-7b1aa4b5fe5f	Udyamnagar	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
b83aad63-4a50-459f-bee5-16c8c375c4dd	51ea939c-9cdd-45b7-9c79-7b1aa4b5fe5f	Kawala Naka	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
34d45d3d-abb2-479f-8351-a458bc0e8413	03c170b0-a315-459a-81a3-00db16bdc9d9	Thane Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
d552919e-4902-4684-94cc-c3f93a0f25bf	03c170b0-a315-459a-81a3-00db16bdc9d9	Thane Railway Station	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
92664f9b-2cf2-4959-b297-8ddf0f4a54b8	03c170b0-a315-459a-81a3-00db16bdc9d9	Thane Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
dbd558b7-d06e-4ec9-b38e-60fcdb3e51aa	03c170b0-a315-459a-81a3-00db16bdc9d9	Thane MIDC	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
7a67bb62-4ef4-4b59-8010-bccdbdf468ec	03c170b0-a315-459a-81a3-00db16bdc9d9	Thane Medical College	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
89a4d273-c02d-4cb1-a5d5-c2a051456de1	4253134e-580d-4cce-a083-99c73399705f	Navi Mumbai Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
b5c84dec-4c97-439d-9cda-fe44cbfddd9a	4253134e-580d-4cce-a083-99c73399705f	Navi Mumbai Railway Station	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
9446c351-472a-4818-a57a-0ba27fb359ff	4253134e-580d-4cce-a083-99c73399705f	Navi Mumbai Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
2b6085d6-0d50-450b-86dc-cab8699c3498	4253134e-580d-4cce-a083-99c73399705f	Navi Mumbai MIDC	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
7cb0fa61-84c5-4a17-8c95-3abadc841aa1	4253134e-580d-4cce-a083-99c73399705f	Navi Mumbai Medical College	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
f74ab992-178d-49a2-b2c7-c5b4eaf83bac	c68159e6-24da-4d92-a460-35ed1aea3814	Solapur Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
94d5c4af-ea90-4748-aac6-adb2076c27a9	c68159e6-24da-4d92-a460-35ed1aea3814	Solapur Railway Station	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
5c979e1c-8a3a-468f-9e35-9910a7bb2a2a	c68159e6-24da-4d92-a460-35ed1aea3814	Solapur Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
fb3ee762-e8f8-467d-b2be-8e8733658a61	c68159e6-24da-4d92-a460-35ed1aea3814	Solapur MIDC	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
c8d4dfb5-14f7-469b-a9d4-046d3990a528	c68159e6-24da-4d92-a460-35ed1aea3814	Solapur Medical College	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
1c7da519-0bf1-4c7c-b628-50ab0d6d8fc5	fc194277-addd-49f2-bb6d-350f0719b08d	Amravati Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
258b089b-007f-46de-b6df-34524255b4fe	fc194277-addd-49f2-bb6d-350f0719b08d	Amravati Railway Station	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
42a7332a-982f-48a8-8c3d-c38d41939492	fc194277-addd-49f2-bb6d-350f0719b08d	Amravati Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
f09e0e63-5e48-4e53-9954-7fa4aae849d5	fc194277-addd-49f2-bb6d-350f0719b08d	Amravati MIDC	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
6147e972-55ef-42db-9495-41012597ea14	fc194277-addd-49f2-bb6d-350f0719b08d	Amravati Medical College	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
c0a1c944-d063-4bcb-afc1-d96a2daf3c56	2a849b4b-374f-4ef0-b208-4ba5b9c30067	Jalgaon Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
df71a8ca-1f94-4cf7-aef1-aec6bbc1662f	2a849b4b-374f-4ef0-b208-4ba5b9c30067	Jalgaon Railway Station	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
41d4527d-30b0-4dbe-a2ab-ee2e4f4bdb0b	2a849b4b-374f-4ef0-b208-4ba5b9c30067	Jalgaon Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
837ecf7a-7fb8-4325-a202-3bd6b3b4bad0	2a849b4b-374f-4ef0-b208-4ba5b9c30067	Jalgaon MIDC	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
fb2f5bc1-69eb-4942-9947-ade5be4ba7ca	2a849b4b-374f-4ef0-b208-4ba5b9c30067	Jalgaon Medical College	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
17283998-a1f5-49c3-9b17-b1d3b0e11f61	cd9d3803-6cec-4d13-a2cf-fd434a37076e	Sangli Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
f7a5b483-82ce-44fb-9a44-d64344e98870	cd9d3803-6cec-4d13-a2cf-fd434a37076e	Sangli Railway Station	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
cdfd26ca-2d57-46f5-b9f6-8a25445bd9a8	cd9d3803-6cec-4d13-a2cf-fd434a37076e	Sangli Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
03453155-7beb-4118-a613-bb90f89be516	cd9d3803-6cec-4d13-a2cf-fd434a37076e	Sangli MIDC	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
59eed621-b47c-4eb8-9f71-a87334bde160	cd9d3803-6cec-4d13-a2cf-fd434a37076e	Sangli Medical College	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
f54e3835-76b6-4719-91d3-b0eaca7d7e75	268987e8-7182-45a9-9a36-c30c9ecaf462	Akola Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
26320d90-8895-4aaf-83a4-ac9385e1e162	268987e8-7182-45a9-9a36-c30c9ecaf462	Akola Railway Station	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
d6e2c8c9-4218-4f75-bd23-a18ff86ca36a	268987e8-7182-45a9-9a36-c30c9ecaf462	Akola Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
871004f6-00dc-4cc9-9b6f-c2b4dcb7e533	268987e8-7182-45a9-9a36-c30c9ecaf462	Akola MIDC	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
e1f4f6d1-ae0b-4f92-96d7-9452cc85a37d	268987e8-7182-45a9-9a36-c30c9ecaf462	Akola Medical College	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
9dee51ea-0684-40b7-8917-da58f3ea14de	5de202fc-f0bb-4eb0-a2f6-97ba45c5ecac	Ratnagiri Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
60925b76-2c0d-477b-80b7-f1bf390251c3	5de202fc-f0bb-4eb0-a2f6-97ba45c5ecac	Ratnagiri Railway Station	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
6a088a02-d538-4912-bfbe-1e9798151bce	5de202fc-f0bb-4eb0-a2f6-97ba45c5ecac	Ratnagiri Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
b41d54ec-1758-4b95-b6a3-ab0f83bd419b	5de202fc-f0bb-4eb0-a2f6-97ba45c5ecac	Ratnagiri MIDC	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
00798552-239b-4ad7-ae0c-55312d07fcdf	5de202fc-f0bb-4eb0-a2f6-97ba45c5ecac	Ratnagiri Medical College	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
25a41004-0079-4cc9-9d36-b08c8fe55075	63e57908-1733-4897-984b-7de1b32ee609	Satara Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
d2a6d9b2-ca43-46cb-a994-b85199d36c9d	63e57908-1733-4897-984b-7de1b32ee609	Satara Railway Station	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
21203e13-04af-42a5-89fe-5a6995d36161	63e57908-1733-4897-984b-7de1b32ee609	Satara Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
b9efb081-8cc1-4e06-9558-2d689f61f4fc	63e57908-1733-4897-984b-7de1b32ee609	Satara MIDC	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
e686bc41-cbab-4ec7-a66e-1c5f40f2b32e	63e57908-1733-4897-984b-7de1b32ee609	Satara Medical College	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
0b0c02e0-23bc-4e85-9839-dbd14b155426	e2523f1f-b9a9-4191-a275-63b4d04822bf	Nanded Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
696883ed-709f-4455-b59f-8e8b33b62979	e2523f1f-b9a9-4191-a275-63b4d04822bf	Nanded Railway Station	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
2e7d96f4-b0b4-46a2-bcfa-7ef1867053f5	e2523f1f-b9a9-4191-a275-63b4d04822bf	Nanded Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
fbe8a1ed-22b7-486e-b4c9-9f579112177d	e2523f1f-b9a9-4191-a275-63b4d04822bf	Nanded MIDC	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
62c79b77-eb23-41ee-81da-db13e98c9c06	e2523f1f-b9a9-4191-a275-63b4d04822bf	Nanded Medical College	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
90348676-5041-4e4d-8852-fc10a832299d	54a58b5c-1608-466e-b77f-ecbc3a0a4298	Latur Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
d61a71d1-f062-4aa6-bac2-0e72edc1eff1	54a58b5c-1608-466e-b77f-ecbc3a0a4298	Latur Railway Station	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
05194bb5-bf27-44a7-a95c-90465af41f2d	54a58b5c-1608-466e-b77f-ecbc3a0a4298	Latur Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
b92e7277-f035-4a9b-bd48-e6623483ed48	54a58b5c-1608-466e-b77f-ecbc3a0a4298	Latur MIDC	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
3f6d9f31-600f-43c1-8c54-bd0d1accead8	54a58b5c-1608-466e-b77f-ecbc3a0a4298	Latur Medical College	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
7d0ba20c-3991-472a-be5c-33b8ef3d4908	42c2b1de-2c19-41ce-a4ad-2ae38987324c	Ahmednagar Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
ff5280b8-b2fc-408d-b38c-f99520b6c33a	42c2b1de-2c19-41ce-a4ad-2ae38987324c	Ahmednagar Railway Station	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
f2e6f33f-48e3-483d-b6fe-0e049247cb40	42c2b1de-2c19-41ce-a4ad-2ae38987324c	Ahmednagar Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
ed23a9fa-e70e-46c9-88fb-44e2024c770f	42c2b1de-2c19-41ce-a4ad-2ae38987324c	Ahmednagar MIDC	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
4b8450a0-5d24-4420-b92f-03e98d3a8f66	42c2b1de-2c19-41ce-a4ad-2ae38987324c	Ahmednagar Medical College	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
d3ea9ee5-42a8-423b-8131-04a705f9793a	048ef14e-7d86-4e79-9f70-549c4aa5a49b	Chandrapur Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
5536ac56-d15c-4f7a-aa8a-26ace02eb3c8	048ef14e-7d86-4e79-9f70-549c4aa5a49b	Chandrapur Railway Station	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
c28d867c-ac8e-41cf-9c4d-28929cc90c88	048ef14e-7d86-4e79-9f70-549c4aa5a49b	Chandrapur Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
cdfbacdd-5da1-4e9a-88f8-c8b5dfb55a8f	048ef14e-7d86-4e79-9f70-549c4aa5a49b	Chandrapur MIDC	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
ba05a20b-aa0d-4527-8c90-7de8fe6da4c9	048ef14e-7d86-4e79-9f70-549c4aa5a49b	Chandrapur Medical College	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
e5a01433-8b0c-4928-af9c-b9c7188b1fba	c0045a1e-e024-437f-a8df-9bbbe37f85fe	Parbhani Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
96a703b9-5a02-418f-9a48-4d6974a480b6	c0045a1e-e024-437f-a8df-9bbbe37f85fe	Parbhani Railway Station	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
5f28e27a-076b-458a-97cb-56412604dc59	c0045a1e-e024-437f-a8df-9bbbe37f85fe	Parbhani Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
8b53175b-aec9-43ca-b5d9-dba56d3a2e2b	c0045a1e-e024-437f-a8df-9bbbe37f85fe	Parbhani MIDC	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
e96c2813-d76c-4025-ac4e-080c36e5a3f0	c0045a1e-e024-437f-a8df-9bbbe37f85fe	Parbhani Medical College	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
841d1b4d-27a5-4801-a481-80214537fbe3	d36d2cb6-1066-4b83-8f35-c829d1922e72	Jalna Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
3209a102-657d-4ee7-9b1a-122ed6ca1e7d	d36d2cb6-1066-4b83-8f35-c829d1922e72	Jalna Railway Station	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
7ea58384-aefa-4bb4-b388-e16c81a7c921	d36d2cb6-1066-4b83-8f35-c829d1922e72	Jalna Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
0ac54453-631e-491f-8597-6b6c8376b13a	d36d2cb6-1066-4b83-8f35-c829d1922e72	Jalna MIDC	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
2cd129f9-9482-4280-ad1b-c2d1bbf17365	d36d2cb6-1066-4b83-8f35-c829d1922e72	Jalna Medical College	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
a2218cb8-01ed-49a2-b963-11b06c00d886	5851f794-bd3f-4e10-a87c-78cf0cf73cc8	Beed Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
a497caa4-7a73-4b4f-8a4a-91281cdd6c98	5851f794-bd3f-4e10-a87c-78cf0cf73cc8	Beed Railway Station	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
8655106b-b7c5-42a6-bdf8-600a1057e934	5851f794-bd3f-4e10-a87c-78cf0cf73cc8	Beed Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
705e0c40-9852-4799-a08c-bc25df6e4a11	5851f794-bd3f-4e10-a87c-78cf0cf73cc8	Beed MIDC	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
83fc8ae2-4ae1-4f2d-a5ea-722104030aed	5851f794-bd3f-4e10-a87c-78cf0cf73cc8	Beed Medical College	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
5f34cbc9-85b7-4ccd-8497-2e96887238ca	0ac5edcc-de13-42f6-87c1-5d41e4bc0a33	Washim Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
342a9187-b65b-4cbb-927b-cdf48430ac3d	0ac5edcc-de13-42f6-87c1-5d41e4bc0a33	Washim Railway Station	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
5c572415-45fe-4f96-b8c8-45e7f18aa13e	0ac5edcc-de13-42f6-87c1-5d41e4bc0a33	Washim Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
1663ceee-5cc6-4f3f-bde7-67b087b6dd09	0ac5edcc-de13-42f6-87c1-5d41e4bc0a33	Washim MIDC	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
342f36d7-a993-4146-83ac-0631d1775e06	0ac5edcc-de13-42f6-87c1-5d41e4bc0a33	Washim Medical College	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
c47ba7d2-0e7d-4b9f-8f18-2cfc9e3a2b7e	cc7b1d9c-789f-44d8-932e-ee19595a8bdf	Osmanabad Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
ea51228b-69e1-4b1d-ab35-b9b48f06cfee	cc7b1d9c-789f-44d8-932e-ee19595a8bdf	Osmanabad Railway Station	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
14e390ad-ea5e-481c-89a9-333cb30ffc2b	cc7b1d9c-789f-44d8-932e-ee19595a8bdf	Osmanabad Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
ef912279-27ca-43e7-8f52-24b5a38eef76	cc7b1d9c-789f-44d8-932e-ee19595a8bdf	Osmanabad MIDC	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
fd70c3d8-45af-4fba-81ac-ae5d3e67f6e0	cc7b1d9c-789f-44d8-932e-ee19595a8bdf	Osmanabad Medical College	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
0a109cfa-c7f2-44e4-8652-90578ddec5b7	4b845014-36ce-4921-ac76-25ba98a9e6f8	Buldhana Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
dcbb7323-3c2b-4e0d-873b-bfa9525e1de8	4b845014-36ce-4921-ac76-25ba98a9e6f8	Buldhana Railway Station	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
2e3e6852-6d07-4e45-bc08-781e7f38b208	4b845014-36ce-4921-ac76-25ba98a9e6f8	Buldhana Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
8f3c973d-d11e-4002-b85b-e1d782f48795	4b845014-36ce-4921-ac76-25ba98a9e6f8	Buldhana MIDC	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
7bcae3c7-0027-4ff5-b4d4-28e4f2fb96cb	4b845014-36ce-4921-ac76-25ba98a9e6f8	Buldhana Medical College	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
e0f36710-24b4-42e8-bd83-d59ce4de2933	334a0c23-66de-44da-a535-9336fd035c76	Wardha Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
f4e9e8ba-5202-4d7c-9e22-fae111eddd71	334a0c23-66de-44da-a535-9336fd035c76	Wardha Railway Station	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
5225176c-613f-47da-815d-037fe6778c93	334a0c23-66de-44da-a535-9336fd035c76	Wardha Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
ab1023ee-16b7-4be1-981d-17d621ac7245	334a0c23-66de-44da-a535-9336fd035c76	Wardha MIDC	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
05848f75-c6e4-4b0e-96ad-cc8533cc7185	334a0c23-66de-44da-a535-9336fd035c76	Wardha Medical College	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
086ed11a-3213-4981-84d9-cb513c3c425d	31213c7f-4eb6-4800-9494-0a3bc5224869	Yavatmal Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
aa3ef9a4-41cf-4397-b369-d08eb88fbb05	31213c7f-4eb6-4800-9494-0a3bc5224869	Yavatmal Railway Station	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
3c193401-2040-4a74-b150-399f6fad0e57	31213c7f-4eb6-4800-9494-0a3bc5224869	Yavatmal Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
fac4a5dd-6f0b-4a71-8cc5-f3f7f05849cc	31213c7f-4eb6-4800-9494-0a3bc5224869	Yavatmal MIDC	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
24b941d9-3c02-4473-b750-a9c0314a238f	31213c7f-4eb6-4800-9494-0a3bc5224869	Yavatmal Medical College	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
6a861d65-b75b-42f3-9df5-918330385f1f	a2518ea5-883d-4e13-97ff-b70d4ff0f3be	Gadchiroli Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
64f5ffd1-840c-4db7-a273-474656069dee	a2518ea5-883d-4e13-97ff-b70d4ff0f3be	Gadchiroli Railway Station	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
48415ba4-fd60-4f03-9682-1ffe853c7b03	a2518ea5-883d-4e13-97ff-b70d4ff0f3be	Gadchiroli Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
51296f12-10ee-4d88-b9c9-ebc2bfc95d27	a2518ea5-883d-4e13-97ff-b70d4ff0f3be	Gadchiroli MIDC	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
420276e1-3b02-4526-a52d-4ed816657b09	a2518ea5-883d-4e13-97ff-b70d4ff0f3be	Gadchiroli Medical College	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
3dae7f1e-1baa-427c-bb5c-1067a165b71a	be73a573-959b-4150-9795-0ec7388fdd32	Bhandara Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
5b83a935-b616-4d40-be61-d63f33d52a12	be73a573-959b-4150-9795-0ec7388fdd32	Bhandara Railway Station	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
0f91b47f-0b25-4c7a-89c0-d722f3fa464b	be73a573-959b-4150-9795-0ec7388fdd32	Bhandara Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
9ff971a0-960d-453a-a7b6-a18c290db818	be73a573-959b-4150-9795-0ec7388fdd32	Bhandara MIDC	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
94a76f9d-09a5-48b6-9f79-bc65f43dcbbf	be73a573-959b-4150-9795-0ec7388fdd32	Bhandara Medical College	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
756357a9-0ee1-4426-bf34-c82dfbaae967	a1f85b26-30f0-42ea-a05e-643c72d92018	Gondia Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
d39f6917-ba95-4820-a34e-f7ebff5bf874	a1f85b26-30f0-42ea-a05e-643c72d92018	Gondia Railway Station	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
3a82a3e2-4b17-48d3-98b2-981ade3f6168	a1f85b26-30f0-42ea-a05e-643c72d92018	Gondia Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
f74febf5-3a8e-4844-b03d-104b79c6e4bc	a1f85b26-30f0-42ea-a05e-643c72d92018	Gondia MIDC	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
a98b3fba-c931-487d-8083-548def9d119c	a1f85b26-30f0-42ea-a05e-643c72d92018	Gondia Medical College	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
4ac1929c-7c1e-4b4d-877c-476ec002f356	fbbfa31f-ce16-4a78-8f91-c382e3b02c55	Hingoli Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
9a6a3f72-5bac-44c9-b453-a65d34b18208	fbbfa31f-ce16-4a78-8f91-c382e3b02c55	Hingoli Railway Station	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
d5cabd52-4047-4231-83e3-82bbb2424314	fbbfa31f-ce16-4a78-8f91-c382e3b02c55	Hingoli Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
04a23e1a-b7fc-4f98-8d70-aca7bef6b66d	fbbfa31f-ce16-4a78-8f91-c382e3b02c55	Hingoli MIDC	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
f293f99d-09bf-4c95-9e7c-d0994dde743a	fbbfa31f-ce16-4a78-8f91-c382e3b02c55	Hingoli Medical College	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
cb961b91-5117-434a-9a72-6c93db99dac5	ccf6efca-3140-4f9f-9401-d39cd904d89c	Sindhudurg Central	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
dcb19ff9-e7f9-4e92-8e70-2ee20e8446c6	ccf6efca-3140-4f9f-9401-d39cd904d89c	Sindhudurg Railway Station	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
23537244-b177-476a-9538-d6d1feaad7b1	ccf6efca-3140-4f9f-9401-d39cd904d89c	Sindhudurg Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
66d283fd-66ae-42e2-9bf4-62e00fcedd3a	ccf6efca-3140-4f9f-9401-d39cd904d89c	Sindhudurg MIDC	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
1ea774d5-0cc6-4a68-a79a-138ff1f64dfb	ccf6efca-3140-4f9f-9401-d39cd904d89c	Sindhudurg Medical College	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
021e631d-c46e-4305-9e9f-17fbcc43390b	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	Pune Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
2ccff871-189a-469d-9ee7-0cdc472bfe1a	3b5e7c03-ab0a-4563-a3cd-d8406e46768f	Aurangabad Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
2b412604-decf-4664-97dd-f2272ee2e0f6	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	Nashik Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
2860428a-ccf4-4f39-8164-6791909effb5	51ea939c-9cdd-45b7-9c79-7b1aa4b5fe5f	Kolhapur Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
9fbd3bf1-91f8-410c-a556-e9ebfad81494	51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	Nagpur Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
32509f9b-9730-45f5-a5a0-32574b245f19	627545c8-f3f5-4474-94b5-122f1a50cb2d	Mumbai Bus Stand	\N	\N	2025-09-13 17:53:22.555806+00	\N	\N	\N	\N	t	t	t	\N
0374056a-ce4c-4876-9b16-bf0fcc7c45c0	03c170b0-a315-459a-81a3-00db16bdc9d9	Thane Station	\N	\N	2025-09-13 18:15:47.331978+00	\N	\N	\N	\N	t	t	t	\N
b7c6d00f-6307-4e01-9266-817d4142b31f	03c170b0-a315-459a-81a3-00db16bdc9d9	Thane Bus Depot	\N	\N	2025-09-13 18:15:47.331978+00	\N	\N	\N	\N	t	t	t	\N
77801aed-097f-419d-8392-49c694f215e7	627545c8-f3f5-4474-94b5-122f1a50cb2d	Mumbai Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
eee150aa-9b34-482b-b469-81af5f5bfcc1	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	Pune Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
cf61de0f-b26b-4fcd-b812-28469a27f1ca	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	Nashik Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
706ee55b-34df-4a87-a069-e0ad6d16de41	3b5e7c03-ab0a-4563-a3cd-d8406e46768f	Aurangabad Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
0e26e5e6-2507-44ee-8ec2-1295d22687e0	51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	Nagpur Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
dc2113b2-ca22-4089-9387-94e41a5cb52c	03c170b0-a315-459a-81a3-00db16bdc9d9	Thane Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
e34be0dd-f98d-410d-b558-a3572d68b254	4253134e-580d-4cce-a083-99c73399705f	Navi Mumbai Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
f4b068ad-5090-4022-a64b-c792c9e78540	51ea939c-9cdd-45b7-9c79-7b1aa4b5fe5f	Kolhapur Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
08310791-a821-429d-a8c4-a4f3a5e1b61c	c68159e6-24da-4d92-a460-35ed1aea3814	Solapur Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
b1264ee2-44df-451f-87e7-6250dd3230c5	fc194277-addd-49f2-bb6d-350f0719b08d	Amravati Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
731ab2f0-de38-430c-83df-b858c03b1302	2a849b4b-374f-4ef0-b208-4ba5b9c30067	Jalgaon Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
764032a1-7883-47cc-aff3-5193db6633dd	cd9d3803-6cec-4d13-a2cf-fd434a37076e	Sangli Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
35d43a7c-8464-4680-b3a4-6eddb82f5b00	268987e8-7182-45a9-9a36-c30c9ecaf462	Akola Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
4d933f42-7e69-4816-8000-6084a6ecb8f5	5de202fc-f0bb-4eb0-a2f6-97ba45c5ecac	Ratnagiri Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
aac43755-cab5-4dd3-8721-82ff5539c87e	63e57908-1733-4897-984b-7de1b32ee609	Satara Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
008c42de-5592-4927-92a9-5879dafbcab7	e2523f1f-b9a9-4191-a275-63b4d04822bf	Nanded Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
7b418d2e-e256-4f7c-bd7a-bbd5c4f350f6	54a58b5c-1608-466e-b77f-ecbc3a0a4298	Latur Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
2c3d7b92-ed83-40e9-a3c8-7c51fdc36974	42c2b1de-2c19-41ce-a4ad-2ae38987324c	Ahmednagar Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
ce3b71ab-59a2-453e-a53d-e8e83d273a21	048ef14e-7d86-4e79-9f70-549c4aa5a49b	Chandrapur Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
99d3bf4d-7467-497f-8afd-bff60431754e	c0045a1e-e024-437f-a8df-9bbbe37f85fe	Parbhani Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
9ac4053b-675d-4dc1-8cde-031357b5c997	d36d2cb6-1066-4b83-8f35-c829d1922e72	Jalna Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
d2f2e719-5146-4d4d-8ce8-8899b3e55858	5851f794-bd3f-4e10-a87c-78cf0cf73cc8	Beed Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
051d92d3-b7f0-44ac-8e2d-b494d9ffb975	334a0c23-66de-44da-a535-9336fd035c76	Wardha Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
dc8b90b6-a3bc-43fe-a640-dbf4971539ef	31ca99b8-ea6f-4565-b7d8-956a30bc4d19	Dhule Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
92d5c446-963e-4124-b9f5-83a295900aea	0ac5edcc-de13-42f6-87c1-5d41e4bc0a33	Washim Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
e6587e33-6402-4699-aa3f-46d626382623	cc7b1d9c-789f-44d8-932e-ee19595a8bdf	Osmanabad Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
bca6c487-3623-4828-8389-0aea1224ac06	4b845014-36ce-4921-ac76-25ba98a9e6f8	Buldhana Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
9c5f4354-41ea-41e6-a216-808304e616ee	31213c7f-4eb6-4800-9494-0a3bc5224869	Yavatmal Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
68cc1cab-fe22-4f0d-8e7a-bf3f233b4946	a2518ea5-883d-4e13-97ff-b70d4ff0f3be	Gadchiroli Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
a10a4a32-06ae-46f2-93c6-e29d34fcb173	be73a573-959b-4150-9795-0ec7388fdd32	Bhandara Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
8c08572d-64ac-4c3c-a76a-1a23759f6357	a1f85b26-30f0-42ea-a05e-643c72d92018	Gondia Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
00a77582-2853-442b-b757-d5977d0753d6	fbbfa31f-ce16-4a78-8f91-c382e3b02c55	Hingoli Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
908bd150-ebe5-460b-954a-a55e192353c1	ccf6efca-3140-4f9f-9401-d39cd904d89c	Sindhudurg Central Bus Stand	\N	\N	2025-09-13 19:20:51.188695+00	\N	\N	\N	\N	t	t	t	\N
a4fe8500-e5e9-44dd-9dee-ed7c3af9c34a	627545c8-f3f5-4474-94b5-122f1a50cb2d	Mumbai Railway Station	\N	\N	2025-09-13 19:21:46.264956+00	\N	\N	\N	\N	t	t	t	\N
bc096528-5c68-4a13-8e81-7fa71a4bcdcc	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	Pune Railway Station	\N	\N	2025-09-13 19:21:46.264956+00	\N	\N	\N	\N	t	t	t	\N
10dfbeaf-c12b-4230-8a2b-9340887ccf70	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	Nashik Railway Station	\N	\N	2025-09-13 19:21:46.264956+00	\N	\N	\N	\N	t	t	t	\N
3f6622d9-3d8a-426f-821c-d6a1c7b1e9bf	3b5e7c03-ab0a-4563-a3cd-d8406e46768f	Aurangabad Railway Station	\N	\N	2025-09-13 19:21:46.264956+00	\N	\N	\N	\N	t	t	t	\N
58bcfb81-49d8-4f8a-aab2-2060befcb8f9	51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	Nagpur Railway Station	\N	\N	2025-09-13 19:21:46.264956+00	\N	\N	\N	\N	t	t	t	\N
022ca986-a5ae-418c-8d02-17b9b5a72332	51ea939c-9cdd-45b7-9c79-7b1aa4b5fe5f	Kolhapur Railway Station	\N	\N	2025-09-13 19:21:46.264956+00	\N	\N	\N	\N	t	t	t	\N
bb36be20-dff8-421f-b4e1-048ec93a9587	31ca99b8-ea6f-4565-b7d8-956a30bc4d19	Dhule Railway Station	\N	\N	2025-09-13 19:21:46.264956+00	\N	\N	\N	\N	t	t	t	\N
6747859a-ca84-4e52-bbca-48b5eb61b670	627545c8-f3f5-4474-94b5-122f1a50cb2d	Mumbai Airport	\N	\N	2025-09-13 19:21:46.264956+00	\N	\N	\N	\N	t	t	t	\N
cd5b5e0c-49e0-42cf-be0c-1326d4133082	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	Pune Airport	\N	\N	2025-09-13 19:21:46.264956+00	\N	\N	\N	\N	t	t	t	\N
556d0bbf-fc47-4519-86f3-b60584e70ca9	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	Nashik Airport	\N	\N	2025-09-13 19:21:46.264956+00	\N	\N	\N	\N	t	t	t	\N
0e942f3a-069d-41a8-9533-3252eb3e37b2	3b5e7c03-ab0a-4563-a3cd-d8406e46768f	Aurangabad Airport	\N	\N	2025-09-13 19:21:46.264956+00	\N	\N	\N	\N	t	t	t	\N
cd4f8ac7-65b8-421f-b80c-8f09c13f8dee	51efa69f-a268-4a3d-b0e4-d17f2a8ca8af	Nagpur Airport	\N	\N	2025-09-13 19:21:46.264956+00	\N	\N	\N	\N	t	t	t	\N
35d3f4fc-85c9-4f0d-99dd-8777e3124a59	627545c8-f3f5-4474-94b5-122f1a50cb2d	Santa Cruz	\N	\N	2025-09-13 19:21:46.264956+00	\N	\N	\N	\N	t	t	t	\N
1aba6c67-09cc-4ee1-8e8a-fac23aa4bbd9	026cbc1c-79bc-4cec-b143-7f1e2bac31b7	Hinjewadi	\N	\N	2025-09-13 19:21:46.264956+00	\N	\N	\N	\N	t	t	t	\N
38860508-8564-4508-a70c-fe497a5fa2a9	50cb75de-4ff0-4e8f-b3fb-c17e40a0aede	CIDCO	\N	\N	2025-09-13 19:21:46.264956+00	\N	\N	\N	\N	t	t	t	\N
360092df-6807-45d9-a318-ac79dcaa1504	\N	Dadar Station	\N	\N	2025-09-19 02:10:26.196951+00	\N	Dadar Railway Station	Mumbai	1	t	t	t	19f83c14-de61-4473-8a89-575e0a00d453
79fa845b-fab2-4ad1-bd63-7b6d66c28f36	\N	Bandra Kurla Complex	\N	\N	2025-09-19 02:10:26.196951+00	\N	BKC Metro Station	Mumbai	2	t	t	t	19f83c14-de61-4473-8a89-575e0a00d453
81d7939e-c1cd-4495-a78d-ea00f986370d	\N	Pune Station	\N	\N	2025-09-19 02:10:26.196951+00	\N	Pune Railway Station	Pune	5	t	t	t	19f83c14-de61-4473-8a89-575e0a00d453
2be2709a-b1a8-4447-b4d4-e57afdde1c6b	\N	Hinjewadi IT Park	\N	\N	2025-09-19 02:10:26.196951+00	\N	Phase 1 Gate	Pune	6	t	t	t	19f83c14-de61-4473-8a89-575e0a00d453
c6fc0508-77f0-4f8f-9ea7-7a7ad54baba4	\N	Nashik Central	\N	\N	2025-09-19 02:10:26.196951+00	\N	Nashik Bus Stand	Nashik	1	t	t	t	0e88a926-3a4b-4210-9ed7-d4292555f4a1
26c04cbf-115f-4838-b3c5-f82f71d44b43	\N	Mumbai Central	\N	\N	2025-09-19 02:10:26.196951+00	\N	Mumbai Central Station	Mumbai	5	t	t	t	0e88a926-3a4b-4210-9ed7-d4292555f4a1
\.


--
-- Data for Name: user_ratings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_ratings (id, rated_user_id, rater_user_id, ride_id, overall_rating, punctuality_rating, friendliness_rating, cleanliness_rating, role_when_rated, comment, created_at) FROM stdin;
\.


--
-- Data for Name: users_app; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users_app (id, full_name, phone, email, role, avatar_url, is_verified, created_at, updated_at, auth_provider, firebase_uid, supabase_uid, photo_url, last_login, firebase_synced, supabase_synced, is_active, password_hash, email_verified, phone_verified) FROM stdin;
4ac7ffea-cacc-4a2b-b1ec-125ef1bc5d7b	Rakesh driver	+918685588898	driver6@test.com	rider	\N	f	2025-09-16 20:18:40.775+00	2025-09-16 20:18:40.777+00	local	\N	\N	\N	\N	f	f	t	$2b$12$pBG4CQXsaFyhF5ijgxFnwOx6rKP9jfHYfHgweebVBH.kkvCXI42vG	f	f
8b152ece-5fed-45c4-a569-982036030914	Ramesh	+918655588885	rider3@test.com	rider	\N	f	2025-09-17 08:54:24.785+00	2025-09-17 08:54:24.785+00	local	\N	\N	\N	\N	f	f	t	$2b$12$UKnNbJXZ6QAnWkZhSfjoJOseVxDd/WsKwwTwWaKYxziEgXIGlQsjC	f	f
110be43d-811f-4734-922a-79e3b906f8ff	Ramesh	+919653825358	rider2@test.com	rider	\N	f	2025-09-18 13:20:05.914+00	2025-09-18 13:20:05.917+00	local	\N	\N	\N	\N	f	f	t	$2b$12$0jaYd5c5hTxL6vdrim/arukPU8pIu1nYk2xp9j2lRHDRWwGYQX0dG	f	f
6245df15-d1be-41a7-a773-4f6230839326	Rakesh jjbh	+919966555556	rider4@test.com	rider	\N	f	2025-09-19 13:24:21.449+00	2025-09-19 13:24:21.449+00	local	\N	\N	\N	\N	f	f	t	$2b$12$wcIgQwgK2UStk439D2jBFe2G2zu/.F7.uO89t0Tm23Kx64796gdZK	f	f
29f33f6a-fa33-4db2-ae95-c856677e5c05	rider		rider@test.com	passenger	\N	f	2025-09-15 07:34:18.101074+00	2025-09-16 19:39:35.545+00	supabase	\N	29f33f6a-fa33-4db2-ae95-c856677e5c05	\N	2025-09-16 19:39:35.544+00	f	t	t	\N	f	f
91e928d8-36e0-4805-83e7-da36d3dd4fdc	Rakesh	+918998569999	rider7@test.com	rider	\N	f	2025-09-17 05:40:28.262+00	2025-09-17 05:40:28.262+00	local	\N	\N	\N	\N	f	f	t	$2b$12$x4d/1OxHM9ukCVeH8EIC4uNKJ3W74BrpD8nCkOslpFtTUl2vJ.4Li	f	f
d853b350-94b3-464f-8c9a-efe9a07dfff7	Driver Rakesh	+918869886599	driver1@gmail.com	rider	\N	f	2025-09-17 14:43:31.349+00	2025-09-17 14:43:31.349+00	local	\N	\N	\N	\N	f	f	t	$2b$12$.zgLMtDKKkntfiEyNgEY2ed9XPpBZa3MYobaw7kWSuzG2pl7ZpaCS	f	f
804c9ae7-49ee-4dff-b634-ec4461dff24b	BB	+919866553855	driver3@test.com	rider	\N	f	2025-09-18 18:21:57.26+00	2025-09-18 18:21:57.26+00	local	\N	\N	\N	\N	f	f	t	$2b$12$fUe4I1N2r7yNbFRgHWI5tuT1h0OKfAlSO6.Lh993IR17WJ3t/S8Da	f	f
2d7a0d90-276b-4aa7-a8d5-2ff4a59659c1	Ramesh Rider	+918989989999	rider8@test.com	rider	\N	f	2025-09-19 17:00:45.941+00	2025-09-19 17:00:45.941+00	local	\N	\N	\N	\N	f	f	t	$2b$12$MxptWodpMONsQ1cQESMLy.ytx/EOuXqvlc.WSc8XnXy0zheIQesPu	f	f
\.


--
-- Data for Name: vehicle_verifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.vehicle_verifications (id, vehicle_id, is_verified, verified_at, verified_by, note) FROM stdin;
\.


--
-- Data for Name: vehicles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.vehicles (id, owner_id, make, model, color, plate, verified, created_at, is_verified, is_active, year, vehicle_type, plate_number) FROM stdin;
b4386e6d-e532-43d5-89d3-ea71f26540ed	29f33f6a-fa33-4db2-ae95-c856677e5c05	\N		\N	mh05ng7373	f	2025-09-11 13:07:04.670551+00	f	t	\N	private	\N
\.


--
-- Data for Name: verifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.verifications (id, user_id, id_type, id_number, id_file_url, status, reviewed_by, reviewed_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: wallet_transactions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.wallet_transactions (id, user_id, tx_type, amount_inr, description, reference_id, created_at) FROM stdin;
\.


--
-- Data for Name: wallets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.wallets (id, user_id, balance_available_inr, balance_reserved_inr, created_at, updated_at) FROM stdin;
7d1fb84f-11e6-4326-91cc-bda60d271609	4ac7ffea-cacc-4a2b-b1ec-125ef1bc5d7b	0	0	2025-09-16 20:18:40.929+00	2025-09-16 20:18:40.929+00
86c40266-fb29-4086-afad-2ca257f1c1b7	91e928d8-36e0-4805-83e7-da36d3dd4fdc	0	0	2025-09-17 05:40:28.43+00	2025-09-17 05:40:28.43+00
1cbc39b1-899d-4d30-aa36-d81cb347a8fe	8b152ece-5fed-45c4-a569-982036030914	0	0	2025-09-17 08:54:25.01+00	2025-09-17 08:54:25.01+00
cd0c7098-179d-4dc0-a207-42b5e7ac3810	d853b350-94b3-464f-8c9a-efe9a07dfff7	0	0	2025-09-17 14:43:31.536+00	2025-09-17 14:43:31.536+00
e0859591-5d17-4572-8762-b6f15cc4aa27	110be43d-811f-4734-922a-79e3b906f8ff	0	0	2025-09-18 13:20:25.933+00	2025-09-18 13:20:25.933+00
1d151423-88da-4a06-a355-f289ad39263b	804c9ae7-49ee-4dff-b634-ec4461dff24b	0	0	2025-09-18 18:21:57.459+00	2025-09-18 18:21:57.459+00
1c3ba047-38d1-459e-b87a-defeddcc1ac2	6245df15-d1be-41a7-a773-4f6230839326	0	0	2025-09-19 13:24:21.645+00	2025-09-19 13:24:21.645+00
5b72a8b5-a701-4f5c-9d46-2c4b4d339df8	2d7a0d90-276b-4aa7-a8d5-2ff4a59659c1	9360	640	2025-09-19 17:00:46.089+00	2025-09-19 17:00:46.089+00
\.


--
-- Data for Name: messages_2025_09_13; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.messages_2025_09_13 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: messages_2025_09_14; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.messages_2025_09_14 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: messages_2025_09_15; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.messages_2025_09_15 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: messages_2025_09_16; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.messages_2025_09_16 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: messages_2025_09_17; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.messages_2025_09_17 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: messages_2025_09_18; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.messages_2025_09_18 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.schema_migrations (version, inserted_at) FROM stdin;
20211116024918	2025-08-13 18:39:52
20211116045059	2025-08-13 18:39:52
20211116050929	2025-08-13 18:39:53
20211116051442	2025-08-13 18:39:54
20211116212300	2025-08-13 18:39:55
20211116213355	2025-08-13 18:39:55
20211116213934	2025-08-13 18:39:56
20211116214523	2025-08-13 18:39:57
20211122062447	2025-08-13 18:39:57
20211124070109	2025-08-13 18:39:58
20211202204204	2025-08-13 18:39:59
20211202204605	2025-08-13 18:39:59
20211210212804	2025-08-13 18:40:01
20211228014915	2025-08-13 18:40:02
20220107221237	2025-08-13 18:40:02
20220228202821	2025-08-13 18:40:03
20220312004840	2025-08-13 18:40:04
20220603231003	2025-08-13 18:40:05
20220603232444	2025-08-13 18:40:05
20220615214548	2025-08-13 18:40:06
20220712093339	2025-08-13 18:40:07
20220908172859	2025-08-13 18:40:07
20220916233421	2025-08-13 18:40:08
20230119133233	2025-08-13 18:40:09
20230128025114	2025-08-13 18:40:09
20230128025212	2025-08-13 18:40:10
20230227211149	2025-08-13 18:40:11
20230228184745	2025-08-13 18:40:11
20230308225145	2025-08-13 18:40:12
20230328144023	2025-08-13 18:40:13
20231018144023	2025-08-13 18:40:13
20231204144023	2025-08-13 18:40:14
20231204144024	2025-08-13 18:40:15
20231204144025	2025-08-13 18:40:15
20240108234812	2025-08-13 18:40:16
20240109165339	2025-08-13 18:40:17
20240227174441	2025-08-13 18:40:18
20240311171622	2025-08-13 18:40:19
20240321100241	2025-08-13 18:40:20
20240401105812	2025-08-13 18:40:22
20240418121054	2025-08-13 18:40:23
20240523004032	2025-08-13 18:40:25
20240618124746	2025-08-13 18:40:26
20240801235015	2025-08-13 18:40:26
20240805133720	2025-08-13 18:40:27
20240827160934	2025-08-13 18:40:27
20240919163303	2025-08-13 18:40:28
20240919163305	2025-08-13 18:40:29
20241019105805	2025-08-13 18:40:30
20241030150047	2025-08-13 18:40:32
20241108114728	2025-08-13 18:40:33
20241121104152	2025-08-13 18:40:34
20241130184212	2025-08-13 18:40:35
20241220035512	2025-08-13 18:40:35
20241220123912	2025-08-13 18:40:36
20241224161212	2025-08-13 18:40:36
20250107150512	2025-08-13 18:40:37
20250110162412	2025-08-13 18:40:38
20250123174212	2025-08-13 18:40:38
20250128220012	2025-08-13 18:40:39
20250506224012	2025-08-13 18:40:39
20250523164012	2025-08-13 18:40:40
20250714121412	2025-08-13 18:40:41
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.subscription (id, subscription_id, entity, filters, claims, created_at) FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types, owner_id, type) FROM stdin;
\.


--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets_analytics (id, type, format, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.migrations (id, name, hash, executed_at) FROM stdin;
0	create-migrations-table	e18db593bcde2aca2a408c4d1100f6abba2195df	2025-08-13 18:39:10.679061
1	initialmigration	6ab16121fbaa08bbd11b712d05f358f9b555d777	2025-08-13 18:39:10.714713
2	storage-schema	5c7968fd083fcea04050c1b7f6253c9771b99011	2025-08-13 18:39:10.725311
3	pathtoken-column	2cb1b0004b817b29d5b0a971af16bafeede4b70d	2025-08-13 18:39:10.804293
4	add-migrations-rls	427c5b63fe1c5937495d9c635c263ee7a5905058	2025-08-13 18:39:10.975278
5	add-size-functions	79e081a1455b63666c1294a440f8ad4b1e6a7f84	2025-08-13 18:39:10.979821
6	change-column-name-in-get-size	f93f62afdf6613ee5e7e815b30d02dc990201044	2025-08-13 18:39:10.986806
7	add-rls-to-buckets	e7e7f86adbc51049f341dfe8d30256c1abca17aa	2025-08-13 18:39:10.992003
8	add-public-to-buckets	fd670db39ed65f9d08b01db09d6202503ca2bab3	2025-08-13 18:39:10.996197
9	fix-search-function	3a0af29f42e35a4d101c259ed955b67e1bee6825	2025-08-13 18:39:11.000666
10	search-files-search-function	68dc14822daad0ffac3746a502234f486182ef6e	2025-08-13 18:39:11.005357
11	add-trigger-to-auto-update-updated_at-column	7425bdb14366d1739fa8a18c83100636d74dcaa2	2025-08-13 18:39:11.01027
12	add-automatic-avif-detection-flag	8e92e1266eb29518b6a4c5313ab8f29dd0d08df9	2025-08-13 18:39:11.028486
13	add-bucket-custom-limits	cce962054138135cd9a8c4bcd531598684b25e7d	2025-08-13 18:39:11.033628
14	use-bytes-for-max-size	941c41b346f9802b411f06f30e972ad4744dad27	2025-08-13 18:39:11.038499
15	add-can-insert-object-function	934146bc38ead475f4ef4b555c524ee5d66799e5	2025-08-13 18:39:11.12007
16	add-version	76debf38d3fd07dcfc747ca49096457d95b1221b	2025-08-13 18:39:11.125991
17	drop-owner-foreign-key	f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101	2025-08-13 18:39:11.130454
18	add_owner_id_column_deprecate_owner	e7a511b379110b08e2f214be852c35414749fe66	2025-08-13 18:39:11.142455
19	alter-default-value-objects-id	02e5e22a78626187e00d173dc45f58fa66a4f043	2025-08-13 18:39:11.156197
20	list-objects-with-delimiter	cd694ae708e51ba82bf012bba00caf4f3b6393b7	2025-08-13 18:39:11.16161
21	s3-multipart-uploads	8c804d4a566c40cd1e4cc5b3725a664a9303657f	2025-08-13 18:39:11.172008
22	s3-multipart-uploads-big-ints	9737dc258d2397953c9953d9b86920b8be0cdb73	2025-08-13 18:39:11.192948
23	optimize-search-function	9d7e604cddc4b56a5422dc68c9313f4a1b6f132c	2025-08-13 18:39:11.207083
24	operation-function	8312e37c2bf9e76bbe841aa5fda889206d2bf8aa	2025-08-13 18:39:11.211804
25	custom-metadata	d974c6057c3db1c1f847afa0e291e6165693b990	2025-08-13 18:39:11.216503
26	objects-prefixes	ef3f7871121cdc47a65308e6702519e853422ae2	2025-08-31 07:01:54.175733
27	search-v2	33b8f2a7ae53105f028e13e9fcda9dc4f356b4a2	2025-08-31 07:01:54.569559
28	object-bucket-name-sorting	ba85ec41b62c6a30a3f136788227ee47f311c436	2025-08-31 07:01:54.666417
29	create-prefixes	a7b1a22c0dc3ab630e3055bfec7ce7d2045c5b7b	2025-08-31 07:01:54.686101
30	update-object-levels	6c6f6cc9430d570f26284a24cf7b210599032db7	2025-08-31 07:01:54.764238
31	objects-level-index	33f1fef7ec7fea08bb892222f4f0f5d79bab5eb8	2025-08-31 07:01:55.1681
32	backward-compatible-index-on-objects	2d51eeb437a96868b36fcdfb1ddefdf13bef1647	2025-08-31 07:01:55.177315
33	backward-compatible-index-on-prefixes	fe473390e1b8c407434c0e470655945b110507bf	2025-08-31 07:01:55.273074
34	optimize-search-function-v1	82b0e469a00e8ebce495e29bfa70a0797f7ebd2c	2025-08-31 07:01:55.276221
35	add-insert-trigger-prefixes	63bb9fd05deb3dc5e9fa66c83e82b152f0caf589	2025-08-31 07:01:55.287782
36	optimise-existing-functions	81cf92eb0c36612865a18016a38496c530443899	2025-08-31 07:01:55.376886
37	add-bucket-name-length-trigger	3944135b4e3e8b22d6d4cbb568fe3b0b51df15c1	2025-08-31 07:01:55.466175
38	iceberg-catalog-flag-on-buckets	19a8bd89d5dfa69af7f222a46c726b7c41e462c5	2025-08-31 07:01:55.482541
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata, level) FROM stdin;
\.


--
-- Data for Name: prefixes; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.prefixes (bucket_id, name, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads (id, in_progress_size, upload_signature, bucket_id, key, version, owner_id, created_at, user_metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads_parts (id, upload_id, size, part_number, bucket_id, key, etag, owner_id, version, created_at) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: supabase_migrations; Owner: -
--

COPY supabase_migrations.schema_migrations (version, statements, name) FROM stdin;
20250905232938	{"﻿-- Placeholder migration created to align local history with remote.\n-- Timestamp: 20250905232938\n-- This file intentionally contains no SQL."}	placeholder
\.


--
-- Data for Name: seed_files; Type: TABLE DATA; Schema: supabase_migrations; Owner: -
--

COPY supabase_migrations.seed_files (path, hash) FROM stdin;
\.


--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: -
--

COPY vault.secrets (id, name, description, secret, key_id, nonce, created_at, updated_at) FROM stdin;
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: -
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 150, true);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: -
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 1, false);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: oauth_clients oauth_clients_client_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_client_id_key UNIQUE (client_id);


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: admins admins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (user_id);


--
-- Name: booking_deposits booking_deposits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_deposits
    ADD CONSTRAINT booking_deposits_pkey PRIMARY KEY (id);


--
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (id);


--
-- Name: cancellation_policies cancellation_policies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cancellation_policies
    ADD CONSTRAINT cancellation_policies_pkey PRIMARY KEY (id);


--
-- Name: cancellation_policies cancellation_policies_ride_type_actor_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cancellation_policies
    ADD CONSTRAINT cancellation_policies_ride_type_actor_key UNIQUE (ride_type, actor);


--
-- Name: cancellation_policies cancellation_policies_ride_type_actor_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cancellation_policies
    ADD CONSTRAINT cancellation_policies_ride_type_actor_unique UNIQUE (ride_type, actor);


--
-- Name: cancellations cancellations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cancellations
    ADD CONSTRAINT cancellations_pkey PRIMARY KEY (id);


--
-- Name: cities cities_name_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_name_unique UNIQUE (name);


--
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);


--
-- Name: deposit_intents deposit_intents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deposit_intents
    ADD CONSTRAINT deposit_intents_pkey PRIMARY KEY (id);


--
-- Name: inbox_messages inbox_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inbox_messages
    ADD CONSTRAINT inbox_messages_pkey PRIMARY KEY (id);


--
-- Name: inbox_threads inbox_threads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inbox_threads
    ADD CONSTRAINT inbox_threads_pkey PRIMARY KEY (id);


--
-- Name: kyc_documents kyc_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kyc_documents
    ADD CONSTRAINT kyc_documents_pkey PRIMARY KEY (id);


--
-- Name: kyc_documents kyc_documents_user_id_doc_type_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kyc_documents
    ADD CONSTRAINT kyc_documents_user_id_doc_type_key UNIQUE (user_id, doc_type);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: ride_allowed_stops ride_allowed_stops_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ride_allowed_stops
    ADD CONSTRAINT ride_allowed_stops_pkey PRIMARY KEY (id);


--
-- Name: ride_allowed_stops ride_allowed_stops_ride_id_stop_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ride_allowed_stops
    ADD CONSTRAINT ride_allowed_stops_ride_id_stop_id_key UNIQUE (ride_id, stop_id);


--
-- Name: ride_deposit_requirements ride_deposit_requirements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ride_deposit_requirements
    ADD CONSTRAINT ride_deposit_requirements_pkey PRIMARY KEY (id);


--
-- Name: ride_deposit_requirements ride_deposit_requirements_ride_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ride_deposit_requirements
    ADD CONSTRAINT ride_deposit_requirements_ride_id_key UNIQUE (ride_id);


--
-- Name: rides rides_driver_id_route_id_depart_date_depart_time_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_driver_id_route_id_depart_date_depart_time_key UNIQUE (driver_id, route_id, depart_date, depart_time);


--
-- Name: rides rides_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_pkey PRIMARY KEY (id);


--
-- Name: route_stops route_stops_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.route_stops
    ADD CONSTRAINT route_stops_pkey PRIMARY KEY (id);


--
-- Name: routes routes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_pkey PRIMARY KEY (id);


--
-- Name: settlements settlements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settlements
    ADD CONSTRAINT settlements_pkey PRIMARY KEY (id);


--
-- Name: stops stops_city_id_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stops
    ADD CONSTRAINT stops_city_id_name_key UNIQUE (city_id, name);


--
-- Name: stops stops_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stops
    ADD CONSTRAINT stops_pkey PRIMARY KEY (id);


--
-- Name: users_app unique_email; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_app
    ADD CONSTRAINT unique_email UNIQUE (email);


--
-- Name: inbox_threads unique_thread; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inbox_threads
    ADD CONSTRAINT unique_thread UNIQUE (ride_id, rider_id, driver_id);


--
-- Name: user_ratings user_ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_ratings
    ADD CONSTRAINT user_ratings_pkey PRIMARY KEY (id);


--
-- Name: user_ratings user_ratings_rated_user_id_rater_user_id_ride_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_ratings
    ADD CONSTRAINT user_ratings_rated_user_id_rater_user_id_ride_id_key UNIQUE (rated_user_id, rater_user_id, ride_id);


--
-- Name: users_app users_app_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_app
    ADD CONSTRAINT users_app_email_key UNIQUE (email);


--
-- Name: users_app users_app_phone_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_app
    ADD CONSTRAINT users_app_phone_key UNIQUE (phone);


--
-- Name: users_app users_app_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_app
    ADD CONSTRAINT users_app_pkey PRIMARY KEY (id);


--
-- Name: cities ux_cities_name_state; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT ux_cities_name_state UNIQUE (name, state);


--
-- Name: vehicle_verifications vehicle_verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_verifications
    ADD CONSTRAINT vehicle_verifications_pkey PRIMARY KEY (id);


--
-- Name: vehicles vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (id);


--
-- Name: vehicles vehicles_plate_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_plate_key UNIQUE (plate);


--
-- Name: verifications verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.verifications
    ADD CONSTRAINT verifications_pkey PRIMARY KEY (id);


--
-- Name: wallet_transactions wallet_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallet_transactions
    ADD CONSTRAINT wallet_transactions_pkey PRIMARY KEY (id);


--
-- Name: wallets wallets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallets
    ADD CONSTRAINT wallets_pkey PRIMARY KEY (id);


--
-- Name: wallets wallets_user_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallets
    ADD CONSTRAINT wallets_user_id_unique UNIQUE (user_id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_09_13 messages_2025_09_13_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2025_09_13
    ADD CONSTRAINT messages_2025_09_13_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_09_14 messages_2025_09_14_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2025_09_14
    ADD CONSTRAINT messages_2025_09_14_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_09_15 messages_2025_09_15_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2025_09_15
    ADD CONSTRAINT messages_2025_09_15_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_09_16 messages_2025_09_16_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2025_09_16
    ADD CONSTRAINT messages_2025_09_16_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_09_17 messages_2025_09_17_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2025_09_17
    ADD CONSTRAINT messages_2025_09_17_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_09_18 messages_2025_09_18_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2025_09_18
    ADD CONSTRAINT messages_2025_09_18_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets_analytics buckets_analytics_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets_analytics
    ADD CONSTRAINT buckets_analytics_pkey PRIMARY KEY (id);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: prefixes prefixes_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.prefixes
    ADD CONSTRAINT prefixes_pkey PRIMARY KEY (bucket_id, level, name);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: supabase_migrations; Owner: -
--

ALTER TABLE ONLY supabase_migrations.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: seed_files seed_files_pkey; Type: CONSTRAINT; Schema: supabase_migrations; Owner: -
--

ALTER TABLE ONLY supabase_migrations.seed_files
    ADD CONSTRAINT seed_files_pkey PRIMARY KEY (path);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: oauth_clients_client_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_clients_client_id_idx ON auth.oauth_clients USING btree (client_id);


--
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: idx_booking_deposits_booking_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_booking_deposits_booking_id ON public.booking_deposits USING btree (booking_id);


--
-- Name: idx_booking_deposits_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_booking_deposits_user_id ON public.booking_deposits USING btree (user_id);


--
-- Name: idx_bookings_ride; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bookings_ride ON public.bookings USING btree (ride_id);


--
-- Name: idx_bookings_rider; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bookings_rider ON public.bookings USING btree (rider_id);


--
-- Name: idx_cancellation_policies_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cancellation_policies_active ON public.cancellation_policies USING btree (is_active);


--
-- Name: idx_cancellation_policies_ride_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cancellation_policies_ride_type ON public.cancellation_policies USING btree (ride_type, actor);


--
-- Name: idx_cancellations_booking; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cancellations_booking ON public.cancellations USING btree (booking_id);


--
-- Name: idx_cancellations_booking_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cancellations_booking_id ON public.cancellations USING btree (booking_id);


--
-- Name: idx_cancellations_processed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cancellations_processed ON public.cancellations USING btree (processed);


--
-- Name: idx_cities_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cities_active ON public.cities USING btree (is_active);


--
-- Name: idx_cities_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cities_name ON public.cities USING btree (name);


--
-- Name: idx_cities_name_lower; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cities_name_lower ON public.cities USING btree (lower(name));


--
-- Name: idx_cities_name_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cities_name_state ON public.cities USING btree (name, state);


--
-- Name: idx_deposit_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_deposit_status ON public.deposit_intents USING btree (status);


--
-- Name: idx_deposit_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_deposit_user ON public.deposit_intents USING btree (user_id);


--
-- Name: idx_inbox_messages_sender; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inbox_messages_sender ON public.inbox_messages USING btree (sender_id);


--
-- Name: idx_inbox_messages_thread; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inbox_messages_thread ON public.inbox_messages USING btree (thread_id);


--
-- Name: idx_inbox_threads_driver; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inbox_threads_driver ON public.inbox_threads USING btree (driver_id);


--
-- Name: idx_inbox_threads_ride; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inbox_threads_ride ON public.inbox_threads USING btree (ride_id);


--
-- Name: idx_inbox_threads_rider; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inbox_threads_rider ON public.inbox_threads USING btree (rider_id);


--
-- Name: idx_kyc_documents_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_kyc_documents_type ON public.kyc_documents USING btree (user_id, doc_type);


--
-- Name: idx_kyc_documents_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_kyc_documents_user_id ON public.kyc_documents USING btree (user_id);


--
-- Name: idx_payments_booking; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payments_booking ON public.payments USING btree (booking_id);


--
-- Name: idx_payments_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payments_status ON public.payments USING btree (status);


--
-- Name: idx_profiles_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_profiles_user_id ON public.profiles USING btree (id);


--
-- Name: idx_ride_deposit_requirements_ride_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ride_deposit_requirements_ride_id ON public.ride_deposit_requirements USING btree (ride_id);


--
-- Name: idx_rides_driver; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rides_driver ON public.rides USING btree (driver_id);


--
-- Name: idx_rides_from_city_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rides_from_city_id ON public.rides USING btree (from_city_id);


--
-- Name: idx_rides_route; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rides_route ON public.rides USING btree (route_id);


--
-- Name: idx_rides_route_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rides_route_date ON public.rides USING btree (route_id, depart_date);


--
-- Name: idx_rides_route_datetime; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rides_route_datetime ON public.rides USING btree (route_id, depart_date, depart_time);


--
-- Name: idx_rides_to_city_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rides_to_city_id ON public.rides USING btree (to_city_id);


--
-- Name: idx_rides_vehicle_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rides_vehicle_type ON public.rides USING btree (vehicle_type);


--
-- Name: idx_route_stops_route_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_route_stops_route_order ON public.route_stops USING btree (route_id, stop_order);


--
-- Name: idx_routes_cities; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_routes_cities ON public.routes USING btree (from_city_id, to_city_id);


--
-- Name: idx_routes_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_routes_code ON public.routes USING btree (code);


--
-- Name: idx_routes_from_city; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_routes_from_city ON public.routes USING btree (from_city_id);


--
-- Name: idx_routes_from_to_cities; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_routes_from_to_cities ON public.routes USING btree (from_city_id, to_city_id);


--
-- Name: idx_routes_to_city; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_routes_to_city ON public.routes USING btree (to_city_id);


--
-- Name: idx_settle_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_settle_status ON public.settlements USING btree (status);


--
-- Name: idx_settle_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_settle_user ON public.settlements USING btree (user_id);


--
-- Name: idx_stops_city_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_stops_city_name ON public.stops USING btree (city_id, name);


--
-- Name: idx_stops_geom; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_stops_geom ON public.stops USING gist (geom);


--
-- Name: idx_stops_route_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_stops_route_id ON public.stops USING btree (route_id);


--
-- Name: idx_user_ratings_rated_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_ratings_rated_user ON public.user_ratings USING btree (rated_user_id);


--
-- Name: idx_user_ratings_rater_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_ratings_rater_user ON public.user_ratings USING btree (rater_user_id);


--
-- Name: idx_users_app_auth_provider; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_app_auth_provider ON public.users_app USING btree (auth_provider);


--
-- Name: idx_users_app_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_app_email ON public.users_app USING btree (email);


--
-- Name: idx_users_app_firebase_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_app_firebase_uid ON public.users_app USING btree (firebase_uid);


--
-- Name: idx_users_app_phone; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_app_phone ON public.users_app USING btree (phone);


--
-- Name: idx_users_app_supabase_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_app_supabase_uid ON public.users_app USING btree (supabase_uid);


--
-- Name: idx_users_phone; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_phone ON public.users_app USING btree (phone);


--
-- Name: idx_vehicles_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vehicles_owner_id ON public.vehicles USING btree (owner_id);


--
-- Name: idx_vehicles_plate_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vehicles_plate_number ON public.vehicles USING btree (plate_number);


--
-- Name: idx_verif_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_verif_user ON public.verifications USING btree (user_id);


--
-- Name: idx_wallet_transactions_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_wallet_transactions_created_at ON public.wallet_transactions USING btree (created_at);


--
-- Name: idx_wallet_transactions_reference_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_wallet_transactions_reference_id ON public.wallet_transactions USING btree (reference_id) WHERE (reference_id IS NOT NULL);


--
-- Name: idx_wallet_transactions_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_wallet_transactions_user_id ON public.wallet_transactions USING btree (user_id);


--
-- Name: idx_wallets_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_wallets_updated_at ON public.wallets USING btree (updated_at);


--
-- Name: idx_wallets_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_wallets_user_id ON public.wallets USING btree (user_id);


--
-- Name: route_stops_route_order_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX route_stops_route_order_unique ON public.route_stops USING btree (route_id, stop_order);


--
-- Name: ux_route_stops_route_stop; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_route_stops_route_stop ON public.route_stops USING btree (route_id, stop_id);


--
-- Name: ux_routes_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_routes_name ON public.routes USING btree (name);


--
-- Name: ux_stops_city_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_stops_city_name ON public.stops USING btree (city_id, name);


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: subscription_subscription_id_entity_filters_key; Type: INDEX; Schema: realtime; Owner: -
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_key ON realtime.subscription USING btree (subscription_id, entity, filters);


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_name_bucket_level_unique; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX idx_name_bucket_level_unique ON storage.objects USING btree (name COLLATE "C", bucket_id, level);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: idx_objects_lower_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_lower_name ON storage.objects USING btree ((path_tokens[level]), lower(name) text_pattern_ops, bucket_id, level);


--
-- Name: idx_prefixes_lower_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_prefixes_lower_name ON storage.prefixes USING btree (bucket_id, level, ((string_to_array(name, '/'::text))[level]), lower(name) text_pattern_ops);


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: objects_bucket_id_level_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX objects_bucket_id_level_idx ON storage.objects USING btree (bucket_id, level, name COLLATE "C");


--
-- Name: messages_2025_09_13_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_09_13_pkey;


--
-- Name: messages_2025_09_14_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_09_14_pkey;


--
-- Name: messages_2025_09_15_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_09_15_pkey;


--
-- Name: messages_2025_09_16_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_09_16_pkey;


--
-- Name: messages_2025_09_17_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_09_17_pkey;


--
-- Name: messages_2025_09_18_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_09_18_pkey;


--
-- Name: users on_auth_user_created; Type: TRIGGER; Schema: auth; Owner: -
--

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


--
-- Name: cancellation_policies trg_cancellation_policies_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_cancellation_policies_updated_at BEFORE UPDATE ON public.cancellation_policies FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: bookings update_bookings_updated_at_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_bookings_updated_at_trigger BEFORE UPDATE ON public.bookings FOR EACH ROW EXECUTE FUNCTION public.update_bookings_updated_at();


--
-- Name: inbox_threads update_inbox_threads_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_inbox_threads_updated_at BEFORE UPDATE ON public.inbox_threads FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: profiles update_profiles_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: rides update_rides_updated_at_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_rides_updated_at_trigger BEFORE UPDATE ON public.rides FOR EACH ROW EXECUTE FUNCTION public.update_rides_updated_at();


--
-- Name: vehicles update_vehicles_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_vehicles_updated_at BEFORE UPDATE ON public.vehicles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: -
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: buckets enforce_bucket_name_length_trigger; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER enforce_bucket_name_length_trigger BEFORE INSERT OR UPDATE OF name ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_name_length();


--
-- Name: objects objects_delete_delete_prefix; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER objects_delete_delete_prefix AFTER DELETE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.delete_prefix_hierarchy_trigger();


--
-- Name: objects objects_insert_create_prefix; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER objects_insert_create_prefix BEFORE INSERT ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.objects_insert_prefix_trigger();


--
-- Name: objects objects_update_create_prefix; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER objects_update_create_prefix BEFORE UPDATE ON storage.objects FOR EACH ROW WHEN (((new.name <> old.name) OR (new.bucket_id <> old.bucket_id))) EXECUTE FUNCTION storage.objects_update_prefix_trigger();


--
-- Name: prefixes prefixes_create_hierarchy; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER prefixes_create_hierarchy BEFORE INSERT ON storage.prefixes FOR EACH ROW WHEN ((pg_trigger_depth() < 1)) EXECUTE FUNCTION storage.prefixes_insert_trigger();


--
-- Name: prefixes prefixes_delete_hierarchy; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER prefixes_delete_hierarchy AFTER DELETE ON storage.prefixes FOR EACH ROW EXECUTE FUNCTION storage.delete_prefix_hierarchy_trigger();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: admins admins_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: booking_deposits booking_deposits_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_deposits
    ADD CONSTRAINT booking_deposits_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE CASCADE;


--
-- Name: bookings bookings_drop_stop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_drop_stop_id_fkey FOREIGN KEY (drop_stop_id) REFERENCES public.stops(id);


--
-- Name: bookings bookings_from_stop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_from_stop_id_fkey FOREIGN KEY (from_stop_id) REFERENCES public.stops(id) ON DELETE RESTRICT;


--
-- Name: bookings bookings_pickup_stop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_pickup_stop_id_fkey FOREIGN KEY (pickup_stop_id) REFERENCES public.stops(id);


--
-- Name: bookings bookings_ride_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE RESTRICT;


--
-- Name: bookings bookings_to_stop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_to_stop_id_fkey FOREIGN KEY (to_stop_id) REFERENCES public.stops(id) ON DELETE RESTRICT;


--
-- Name: cancellations cancellations_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cancellations
    ADD CONSTRAINT cancellations_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE CASCADE;


--
-- Name: cancellations cancellations_policy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cancellations
    ADD CONSTRAINT cancellations_policy_id_fkey FOREIGN KEY (policy_id) REFERENCES public.cancellation_policies(id);


--
-- Name: deposit_intents deposit_intents_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deposit_intents
    ADD CONSTRAINT deposit_intents_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users_app(id) ON DELETE CASCADE;


--
-- Name: inbox_messages inbox_messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inbox_messages
    ADD CONSTRAINT inbox_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users_app(id) ON DELETE CASCADE;


--
-- Name: inbox_messages inbox_messages_thread_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inbox_messages
    ADD CONSTRAINT inbox_messages_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES public.inbox_threads(id) ON DELETE CASCADE;


--
-- Name: inbox_threads inbox_threads_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inbox_threads
    ADD CONSTRAINT inbox_threads_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.users_app(id) ON DELETE CASCADE;


--
-- Name: inbox_threads inbox_threads_ride_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inbox_threads
    ADD CONSTRAINT inbox_threads_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- Name: inbox_threads inbox_threads_rider_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inbox_threads
    ADD CONSTRAINT inbox_threads_rider_id_fkey FOREIGN KEY (rider_id) REFERENCES public.users_app(id) ON DELETE CASCADE;


--
-- Name: kyc_documents kyc_documents_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kyc_documents
    ADD CONSTRAINT kyc_documents_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: kyc_documents kyc_documents_verified_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kyc_documents
    ADD CONSTRAINT kyc_documents_verified_by_fkey FOREIGN KEY (verified_by) REFERENCES auth.users(id);


--
-- Name: payments payments_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE CASCADE;


--
-- Name: profiles profiles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: ride_allowed_stops ride_allowed_stops_ride_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ride_allowed_stops
    ADD CONSTRAINT ride_allowed_stops_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- Name: ride_allowed_stops ride_allowed_stops_stop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ride_allowed_stops
    ADD CONSTRAINT ride_allowed_stops_stop_id_fkey FOREIGN KEY (stop_id) REFERENCES public.stops(id) ON DELETE RESTRICT;


--
-- Name: ride_deposit_requirements ride_deposit_requirements_ride_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ride_deposit_requirements
    ADD CONSTRAINT ride_deposit_requirements_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- Name: rides rides_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id);


--
-- Name: rides rides_drop_stop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_drop_stop_id_fkey FOREIGN KEY (drop_stop_id) REFERENCES public.stops(id);


--
-- Name: rides rides_from_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_from_city_id_fkey FOREIGN KEY (from_city_id) REFERENCES public.cities(id) ON DELETE SET NULL;


--
-- Name: rides rides_pickup_stop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_pickup_stop_id_fkey FOREIGN KEY (pickup_stop_id) REFERENCES public.stops(id);


--
-- Name: rides rides_route_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_route_fk FOREIGN KEY (route_id) REFERENCES public.routes(id);


--
-- Name: rides rides_to_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_to_city_id_fkey FOREIGN KEY (to_city_id) REFERENCES public.cities(id) ON DELETE SET NULL;


--
-- Name: route_stops route_stops_route_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.route_stops
    ADD CONSTRAINT route_stops_route_id_fkey FOREIGN KEY (route_id) REFERENCES public.routes(id) ON DELETE CASCADE;


--
-- Name: route_stops route_stops_stop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.route_stops
    ADD CONSTRAINT route_stops_stop_id_fkey FOREIGN KEY (stop_id) REFERENCES public.stops(id) ON DELETE CASCADE;


--
-- Name: settlements settlements_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settlements
    ADD CONSTRAINT settlements_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users_app(id) ON DELETE CASCADE;


--
-- Name: stops stops_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stops
    ADD CONSTRAINT stops_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.cities(id) ON DELETE CASCADE;


--
-- Name: stops stops_route_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stops
    ADD CONSTRAINT stops_route_id_fkey FOREIGN KEY (route_id) REFERENCES public.routes(id);


--
-- Name: user_ratings user_ratings_rated_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_ratings
    ADD CONSTRAINT user_ratings_rated_user_id_fkey FOREIGN KEY (rated_user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: user_ratings user_ratings_rater_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_ratings
    ADD CONSTRAINT user_ratings_rater_user_id_fkey FOREIGN KEY (rater_user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: vehicle_verifications vehicle_verifications_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_verifications
    ADD CONSTRAINT vehicle_verifications_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id) ON DELETE CASCADE;


--
-- Name: verifications verifications_reviewed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.verifications
    ADD CONSTRAINT verifications_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES public.users_app(id);


--
-- Name: verifications verifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.verifications
    ADD CONSTRAINT verifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users_app(id) ON DELETE CASCADE;


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: prefixes prefixes_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.prefixes
    ADD CONSTRAINT "prefixes_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: kyc_documents Users can insert own kyc documents; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can insert own kyc documents" ON public.kyc_documents FOR INSERT WITH CHECK ((user_id = auth.uid()));


--
-- Name: profiles Users can insert own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT WITH CHECK ((id = auth.uid()));


--
-- Name: vehicles Users can insert own vehicles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can insert own vehicles" ON public.vehicles FOR INSERT WITH CHECK ((owner_id = auth.uid()));


--
-- Name: user_ratings Users can rate others; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can rate others" ON public.user_ratings FOR INSERT WITH CHECK ((rater_user_id = auth.uid()));


--
-- Name: profiles Users can update own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING ((id = auth.uid()));


--
-- Name: vehicles Users can update own vehicles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update own vehicles" ON public.vehicles FOR UPDATE USING ((owner_id = auth.uid()));


--
-- Name: user_ratings Users can view all ratings; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view all ratings" ON public.user_ratings FOR SELECT USING (true);


--
-- Name: kyc_documents Users can view own kyc documents; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view own kyc documents" ON public.kyc_documents FOR SELECT USING ((user_id = auth.uid()));


--
-- Name: profiles Users can view own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING ((id = auth.uid()));


--
-- Name: vehicles Users can view own vehicles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view own vehicles" ON public.vehicles FOR SELECT USING ((owner_id = auth.uid()));


--
-- Name: admins; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.admins ENABLE ROW LEVEL SECURITY;

--
-- Name: admins admins_self_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admins_self_read ON public.admins FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: bookings booking_insert_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY booking_insert_self ON public.bookings FOR INSERT WITH CHECK ((rider_id = auth.uid()));


--
-- Name: bookings booking_read_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY booking_read_own ON public.bookings FOR SELECT USING (((rider_id = auth.uid()) OR (EXISTS ( SELECT 1
   FROM public.rides r
  WHERE ((r.id = bookings.ride_id) AND (r.driver_id = auth.uid()))))));


--
-- Name: bookings booking_update_driver; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY booking_update_driver ON public.bookings FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM public.rides r
  WHERE ((r.id = bookings.ride_id) AND (r.driver_id = auth.uid())))));


--
-- Name: bookings; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

--
-- Name: bookings bookings_insert_any; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY bookings_insert_any ON public.bookings FOR INSERT WITH CHECK (true);


--
-- Name: bookings bookings_insert_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY bookings_insert_self ON public.bookings FOR INSERT TO authenticated WITH CHECK ((auth.uid() = rider_id));


--
-- Name: bookings bookings_owner_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY bookings_owner_read ON public.bookings FOR SELECT USING ((auth.uid() = rider_id));


--
-- Name: bookings bookings_select_mine_or_my_rides; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY bookings_select_mine_or_my_rides ON public.bookings FOR SELECT TO authenticated USING (((rider_id = auth.uid()) OR (EXISTS ( SELECT 1
   FROM public.rides r
  WHERE ((r.id = bookings.ride_id) AND (r.driver_id = auth.uid()))))));


--
-- Name: vehicles insert own vehicles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "insert own vehicles" ON public.vehicles FOR INSERT WITH CHECK ((auth.uid() = owner_id));


--
-- Name: rides insert_as_authenticated; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY insert_as_authenticated ON public.rides FOR INSERT WITH CHECK ((auth.uid() IS NOT NULL));


--
-- Name: kyc_documents; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.kyc_documents ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

--
-- Name: vehicles read own or public vehicles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "read own or public vehicles" ON public.vehicles FOR SELECT USING ((auth.uid() = owner_id));


--
-- Name: rides read_rides_public; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY read_rides_public ON public.rides FOR SELECT USING (true);


--
-- Name: rides; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.rides ENABLE ROW LEVEL SECURITY;

--
-- Name: rides rides_insert_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY rides_insert_own ON public.rides FOR INSERT WITH CHECK (((auth.role() = 'service_role'::text) OR (created_by = auth.uid())));


--
-- Name: rides rides_read_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY rides_read_all ON public.rides FOR SELECT USING (true);


--
-- Name: rides rides_update_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY rides_update_own ON public.rides FOR UPDATE USING (((auth.role() = 'service_role'::text) OR (created_by = auth.uid())));


--
-- Name: route_stops; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.route_stops ENABLE ROW LEVEL SECURITY;

--
-- Name: route_stops route_stops_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY route_stops_read ON public.route_stops FOR SELECT USING (true);


--
-- Name: route_stops route_stops_write_admin; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY route_stops_write_admin ON public.route_stops USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- Name: routes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.routes ENABLE ROW LEVEL SECURITY;

--
-- Name: routes routes_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY routes_read ON public.routes FOR SELECT USING (true);


--
-- Name: routes routes_write_admin; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY routes_write_admin ON public.routes USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- Name: stops; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.stops ENABLE ROW LEVEL SECURITY;

--
-- Name: stops stops_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY stops_read ON public.stops FOR SELECT USING (true);


--
-- Name: stops stops_write_admin; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY stops_write_admin ON public.stops USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- Name: vehicles update own vehicles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "update own vehicles" ON public.vehicles FOR UPDATE USING ((auth.uid() = owner_id)) WITH CHECK ((auth.uid() = owner_id));


--
-- Name: user_ratings; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_ratings ENABLE ROW LEVEL SECURITY;

--
-- Name: vehicles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.vehicles ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: -
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_analytics; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets_analytics ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: prefixes; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.prefixes ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: -
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


--
-- Name: supabase_realtime_messages_publication; Type: PUBLICATION; Schema: -; Owner: -
--

CREATE PUBLICATION supabase_realtime_messages_publication WITH (publish = 'insert, update, delete, truncate');


--
-- Name: supabase_realtime_messages_publication messages; Type: PUBLICATION TABLE; Schema: realtime; Owner: -
--

ALTER PUBLICATION supabase_realtime_messages_publication ADD TABLE ONLY realtime.messages;


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


--
-- PostgreSQL database dump complete
--

\unrestrict Y1CwXzZRaGKrzH8jz2h6snFjJAU9H2w2nBvM4CnHOit54pnTGabsNX2LXQfDKPh

