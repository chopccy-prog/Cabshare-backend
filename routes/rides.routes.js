// routes/rides.routes.js
const express = require('express');
const router = express.Router();
const { supabase } = require('../supabase');

// helper: pull user id from header (added by ApiClient.defaultHeaders)
function getUserId(req) {
  return (req.headers['x-user-id'] || '').trim();
}

// ---- SEARCH (put before :id routes) ----
router.get('/search', async (req, res) => {
  try {
    const { from, to, date } = req.query;

    let q = supabase
      .from('rides')
      .select(
        `
        id, from_location, to_location, depart_date, depart_time,
        seats_total, seats_available, price_inr, is_commercial, pool, status,
        driver_id,
        driver:users!rides_driver_id_fkey(id, full_name, phone)
      `
      )
      .eq('status', 'published')
      .order('depart_date', { ascending: true })
      .order('depart_time', { ascending: true });

    if (from) q = q.ilike('from_location', from);
    if (to) q = q.ilike('to_location', to);
    if (date) q = q.eq('depart_date', date);

    const { data, error } = await q;
    if (error) return res.status(400).json({ error: error.message });

    // Map to the keys the app expects in the list
    const items = (data || []).map((r) => ({
      id: r.id,
      from: r.from_location,
      to: r.to_location,
      when: r.depart_date,
      start_time: r.depart_time,
      seats: r.seats_available,
      price_inr: r.price_inr,
      is_commercial: r.is_commercial,
      pool: r.pool,
    }));
    res.json(items);
  } catch (e) {
    res.status(500).json({ error: String(e) });
  }
});

// ---- MINE (must be before '/:id') ----
router.get('/mine', async (req, res) => {
  try {
    const uid = getUserId(req);
    if (!uid) return res.status(401).json({ error: 'unauthorized' });

    const role = (req.query.role || 'driver').toString(); // 'driver' | 'rider'
    if (role === 'driver') {
      const { data, error } = await supabase
        .from('rides')
        .select('id, from_location, to_location, depart_date, depart_time, seats_total, seats_available, price_inr, status, pool, is_commercial')
        .eq('driver_id', uid)
        .neq('status', 'deleted')
        .order('created_at', { ascending: false });
      if (error) return res.status(400).json({ error: error.message });
      return res.json(
        (data || []).map((r) => ({
          id: r.id,
          from: r.from_location,
          to: r.to_location,
          when: r.depart_date,
          start_time: r.depart_time,
          seats: r.seats_available,
          price_inr: r.price_inr,
          status: r.status,
          pool: r.pool,
          is_commercial: r.is_commercial,
        }))
      );
    }

    // rider side (bookings) – return empty if table not present
    const { data, error } = await supabase
      .from('bookings')
      .select(
        `
        id, seats,
        ride:rides(id, from_location, to_location, depart_date, depart_time, price_inr)
      `
      )
      .eq('rider_id', uid)
      .order('created_at', { ascending: false });

    if (error && error.code !== '42P01') {
      // 42P01 = relation does not exist (bookings table missing) -> return []
      return res.status(400).json({ error: error.message });
    }
    res.json(
      (data || []).map((b) => ({
        id: b.ride?.id,
        from: b.ride?.from_location,
        to: b.ride?.to_location,
        when: b.ride?.depart_date,
        start_time: b.ride?.depart_time,
        price_inr: b.ride?.price_inr,
        seats: b.seats,
      }))
    );
  } catch (e) {
    res.status(500).json({ error: String(e) });
  }
});

// ---- CREATE ----
router.post('/', async (req, res) => {
  try {
    const uid = getUserId(req);
    if (!uid) return res.status(401).json({ error: 'unauthorized' });

    const b = req.body || {};

    // Accept legacy synonyms from the app and normalize.
    const from_location = (b.from_location ?? b.fromCity ?? b.from ?? '').toString().trim();
    const to_location = (b.to_location ?? b.toCity ?? b.to ?? '').toString().trim();
    const depart_date = (b.depart_date ?? b.date ?? '').toString().trim();
    const depart_time = (b.depart_time ?? b.time ?? '').toString().trim();
    const seats_total = Number(b.seats_total ?? b.seats ?? 0);
    const seats_available = Number(
      b.seats_available ?? b.available_seats ?? seats_total
    );
    const price_inr = Number(b.price_inr ?? b.price ?? b.price_per_seat_inr ?? 0);
    const is_commercial = Boolean(
      b.is_commercial ??
        (b.rideType && String(b.rideType).startsWith('commercial'))
    );
    const pool =
      b.pool ??
      (b.rideType === 'commercial_full_car' ? 'private' : 'shared');

    if (!from_location || !to_location || !depart_date) {
      return res
        .status(400)
        .json({ error: 'missing required fields: depart_date/from_location/to_location' });
    }

    const insert = {
      driver_id: uid,
      from_location,
      to_location,
      depart_date,
      ...(depart_time ? { depart_time } : {}),
      seats_total,
      seats_available,
      price_inr,
      is_commercial,
      pool,
      status: 'published',
      notes: b.notes ?? null,
      car_make: b.car_make ?? null,
      car_model: b.car_model ?? null,
      car_reg_number: b.car_reg_number ?? null,
    };

    const { data, error } = await supabase.from('rides').insert(insert).select().single();
    if (error) return res.status(400).json({ error: error.message });
    res.json(data);
  } catch (e) {
    res.status(500).json({ error: String(e) });
  }
});

// ---- DETAIL (keep AFTER /search and /mine to avoid '/mine' being treated as :id) ----
router.get('/:id', async (req, res) => {
  try {
    const id = req.params.id;
    const { data, error } = await supabase
      .from('rides')
      .select(
        `
        id, from_location, to_location, depart_date, depart_time,
        seats_total, seats_available, price_inr, is_commercial, pool, status,
        driver:users!rides_driver_id_fkey(id, full_name, phone)
      `
      )
      .eq('id', id)
      .single();
    if (error) return res.status(400).json({ error: error.message });
    // Return keys that TabSearch bottom sheet expects
    res.json({
      id: data.id,
      from: data.from_location,
      to: data.to_location,
      depart_date: data.depart_date,
      depart_time: data.depart_time,
      seats_total: data.seats_total,
      seats_available: data.seats_available,
      price_per_seat_inr: data.price_inr,
      is_commercial: data.is_commercial,
      pool: data.pool,
      status: data.status,
      driver: data.driver,
    });
  } catch (e) {
    res.status(500).json({ error: String(e) });
  }
});

// ---- BOOK ----
router.post('/:id/book', async (req, res) => {
  try {
    const uid = getUserId(req);
    if (!uid) return res.status(401).json({ error: 'unauthorized' });

    const id = req.params.id;
    const seats = Number(req.body?.seats ?? 1);

    // fetch current seats
    const { data: ride, error: e1 } = await supabase
      .from('rides')
      .select('id, seats_available')
      .eq('id', id)
      .single();
    if (e1) return res.status(400).json({ error: e1.message });

    if ((ride?.seats_available ?? 0) < seats) {
      return res.status(400).json({ error: 'not_enough_seats' });
    }

    const { error: e2 } = await supabase
      .from('rides')
      .update({ seats_available: ride.seats_available - seats })
      .eq('id', id);
    if (e2) return res.status(400).json({ error: e2.message });

    // optional bookings table – ignore if missing
    await supabase
      .from('bookings')
      .insert({ ride_id: id, rider_id: uid, seats })
      .then(({ error }) => {
        if (error && error.code !== '42P01') {
          // only surface non-existence errors
          throw error;
        }
      });

    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: String(e) });
  }
});

// ---- Inbox/messages (non-breaking stubs) ----
router.get('/../inbox', (_req, res) => res.json([])); // path mounted in server.js as '/inbox'
router.get('/../messages', (_req, res) => res.json([]));
router.post('/../messages', (_req, res) => res.json({ ok: true }));

module.exports = router;
