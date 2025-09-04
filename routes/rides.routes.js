// routes/rides.routes.js  (minimal patch)
const express = require('express');
const router = express.Router();
const { supabase } = require('../supabase');

// helper: add aliases but KEEP original columns (so old code keeps working)
const withAliases = (r) => ({
  ...r,
  from: r.from ?? r.from_location ?? r.from_city ?? null,
  to: r.to ?? r.to_location ?? r.to_city ?? null,
  when: r.when ?? r.depart_at ?? r.depart_time ?? null,
  price: r.price ?? r.price_per_seat_inr ?? r.price_inr ?? null,
});

// ---------- PUBLISH ----------
router.post('/', async (req, res) => {
  try {
    const b = req.body || {};

    // don’t change your existing payload keys; just normalize minimally
    const insert = {
      from_location: b.from_location ?? b.from ?? b.from_city ?? null,
      to_location:   b.to_location   ?? b.to   ?? b.to_city   ?? null,
      depart_at:     b.depart_at     ?? b.when ?? null,
      price_per_seat_inr: b.price_per_seat_inr ?? b.price ?? null,
      seats_total:   b.seats_total ?? b.seatsTotal ?? b.seats ?? null,
      seats_available: b.seats_available ?? b.available_seats ?? (b.seats_total ?? b.seatsTotal ?? b.seats) ?? null,
      ride_type:     b.ride_type ?? b.rideType ?? 'private',
      driver_id:     b.driver_id ?? b.user_id ?? b.uid ?? null,
      car_reg_number: b.car_reg_number ?? null,
      car_model:      b.car_model ?? null,
    };

    const { data, error } = await supabase
      .from('rides')
      .insert(insert)
      // keep your table columns; we’ll alias in JS
      .select('*')
      .single();

    if (error) return res.status(400).json({ error: error.message });
    return res.json(withAliases(data));
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

// ---------- SEARCH ----------
router.get('/search', async (req, res) => {
  try {
    const { from, to, when, type } = req.query;

    let q = supabase.from('rides').select('*');

    if (from) q = q.ilike('from_location', `%${from}%`);
    if (to)   q = q.ilike('to_location', `%${to}%`);
    if (when) q = q.gte('depart_at', `${when} 00:00:00`).lte('depart_at', `${when} 23:59:59`);
    if (type) q = q.eq('ride_type', type);

    q = q.order('depart_at', { ascending: true });

    const { data, error } = await q;
    if (error) return res.status(400).json({ error: error.message });

    return res.json((data || []).map(withAliases));
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

// ---------- GET ONE ----------
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { data, error } = await supabase
      .from('rides')
      .select('*')
      .eq('id', id)
      .single();

    if (error) return res.status(400).json({ error: error.message });
    return res.json(withAliases(data));
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

// ---------- MINE ----------
router.get('/mine', async (req, res) => {
  try {
    const uid = req.user?.id || req.query.uid;
    const role = (req.query.role || 'driver').toLowerCase();
    if (!uid) return res.status(401).json({ error: 'unauthorized' });

    if (role === 'driver') {
      const { data, error } = await supabase
        .from('rides')
        .select('*')
        .eq('driver_id', uid)
        .order('depart_at', { ascending: false });

      if (error) return res.status(400).json({ error: error.message });
      return res.json((data || []).map(withAliases));
    }

    // rider: select via bookings
    const { data, error } = await supabase
      .from('bookings')
      .select(`
        id,
        seats_requested as seats,
        status,
        ride:rides(*)
      `)
      .eq('rider_id', uid)
      .order('created_at', { ascending: false });

    if (error) return res.status(400).json({ error: error.message });

    const normalized = (data || []).map(b => ({
      booking_id: b.id,
      seats: b.seats,
      status: b.status,
      ...withAliases(b.ride || {}),
    }));

    return res.json(normalized);
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

module.exports = router;
