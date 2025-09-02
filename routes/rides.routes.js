// routes/rides.routes.js
const express = require('express');
const router = express.Router();
const { supabase } = require('../supabase'); // keep your existing supabase client

// helper: auth
function getUserId(req) {
  const uid = req.user?.id || req.user?.sub || req.auth?.userId || req.auth?.sub;
  return uid || null;
}

// ---------- SEARCH ----------
router.get('/', async (req, res) => {
  try {
    const { from, to, when } = req.query;

    // NOTE: DB columns are from_location / to_location / depart_date
    let q = supabase
      .from('rides')
      .select('id, from_location, to_location, depart_date, depart_time, price_inr, seats_total, seats_available, is_commercial, pool')
      .eq('status', 'published');

    if (from && from.trim()) q = q.ilike('from_location', `%${from.trim()}%`);
    if (to && to.trim())   q = q.ilike('to_location', `%${to.trim()}%`);
    if (when && when.trim()) q = q.eq('depart_date', when.trim()); // YYYY-MM-DD

    const { data, error } = await q.order('depart_date', { ascending: true }).order('depart_time', { ascending: true });
    if (error) throw error;

    // normalize keys for app list tiles
    const items = (data || []).map(r => ({
      id: r.id,
      from: r.from_location,
      to: r.to_location,
      when: r.depart_date,
      start_time: r.depart_time,
      price_inr: r.price_inr,
      seats: r.seats_available ?? r.seats_total ?? 0,
      is_commercial: r.is_commercial,
      pool: r.pool,
    }));

    res.json(items);
  } catch (e) {
    res.status(400).json({ error: e.message || String(e) });
  }
});

// ---------- GET RIDE DETAIL ----------
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const { data: ride, error } = await supabase
      .from('rides')
      .select(`
        id, driver_id, from_location, to_location,
        depart_date, depart_time, price_inr,
        seats_total, seats_available, is_commercial, pool,
        car_make, car_model, car_number, notes,
        created_at, updated_at
      `)
      .eq('id', id)
      .single();

    if (error) throw error;

    // join driver (users table) – do a separate fetch to avoid relationship-cache errors
    let driver = null;
    if (ride?.driver_id) {
      const { data: u, error: ue } = await supabase
        .from('users')
        .select('id, full_name, phone')
        .eq('id', ride.driver_id)
        .single();
      if (!ue) driver = u;
    }

    res.json({
      id: ride.id,
      from: ride.from_location,
      to: ride.to_location,
      depart_date: ride.depart_date,
      depart_time: ride.depart_time,
      price_per_seat_inr: ride.price_inr,
      seats_total: ride.seats_total,
      seats_available: ride.seats_available,
      is_commercial: ride.is_commercial,
      pool: ride.pool,
      car_make: ride.car_make,
      car_model: ride.car_model,
      car_number: ride.car_number,
      notes: ride.notes,
      driver,
    });
  } catch (e) {
    res.status(400).json({ error: e.message || String(e) });
  }
});

// ---------- PUBLISH ----------
router.post('/', async (req, res) => {
  try {
    const userId = getUserId(req);
    if (!userId) return res.status(401).json({ error: 'unauthorized' });

    const body = req.body || {};

    // Accept multiple client keys, map to DB columns
    const from_location = body.from_location ?? body.from ?? body.fromCity ?? '';
    const to_location   = body.to_location   ?? body.to   ?? body.toCity   ?? '';
    const depart_date   = body.depart_date   ?? body.date ?? body.when     ?? null; // expect YYYY-MM-DD
    const depart_time   = body.depart_time   ?? body.time ?? null;                  // HH:MM
    const seats_total   = Number(
      body.seats_total ?? body.seats ?? body.total_seats ?? 0
    );
    const price_inr = Number(
      body.price_inr ?? body.price ?? body.price_per_seat_inr ?? 0
    );
    const is_commercial = !!(body.is_commercial ?? (body.category === 'commercial'));
    // pool: 'shared' (pool ride) or 'private' (full car)
    const pool = body.pool
      ?? (body.category === 'commercial_full_car' ? 'private'
        : body.category === 'commercial_pool' ? 'shared'
        : 'shared');

    if (!from_location || !to_location || !depart_date) {
      return res.status(400).json({ error: 'missing required fields: depart_date' });
    }

    const insertObj = {
      driver_id: userId,
      from_location,
      to_location,
      depart_date,
      depart_time,
      price_inr,
      seats_total,
      seats_available: Number(
        body.seats_available ?? body.available_seats ?? seats_total || 0
      ),
      is_commercial,
      pool,
      status: 'published',
    };

    const { data, error } = await supabase
      .from('rides')
      .insert(insertObj)
      .select('id')
      .single();

    if (error) throw error;

    res.json({ id: data.id });
  } catch (e) {
    res.status(400).json({ error: e.message || String(e) });
  }
});

// ---------- MY RIDES ----------
router.get('/mine/published', async (req, res) => {
  try {
    const userId = getUserId(req);
    if (!userId) return res.status(401).json({ error: 'unauthorized' });

    const { data, error } = await supabase
      .from('rides')
      .select('id, from_location, to_location, depart_date, depart_time, price_inr, seats_total, seats_available, is_commercial, pool, status')
      .eq('driver_id', userId)
      .order('created_at', { ascending: false });

    if (error) throw error;

    const items = (data || []).map(r => ({
      id: r.id,
      from: r.from_location,
      to: r.to_location,
      when: r.depart_date,
      start_time: r.depart_time,
      price_inr: r.price_inr,
      seats_total: r.seats_total,
      seats_available: r.seats_available,
      is_commercial: r.is_commercial,
      pool: r.pool,
      status: r.status,
    }));

    res.json(items);
  } catch (e) {
    res.status(400).json({ error: e.message || String(e) });
  }
});

// ---------- INBOX (placeholder, no 404/401) ----------
router.get('/messages', async (req, res) => {
  try {
    const userId = getUserId(req);
    if (!userId) return res.status(401).json({ error: 'unauthorized' });

    // Return empty list for now so the app doesn’t 404/500
    res.json([]);
  } catch (e) {
    res.status(400).json({ error: e.message || String(e) });
  }
});

// ---------- BOOKING REQUEST (stub – returns 200) ----------
router.post('/:id/book', async (req, res) => {
  try {
    const userId = getUserId(req);
    if (!userId) return res.status(401).json({ error: 'unauthorized' });

    // You can implement actual booking here later
    res.json({ ok: true });
  } catch (e) {
    res.status(400).json({ error: e.message || String(e) });
  }
});

module.exports = router;
