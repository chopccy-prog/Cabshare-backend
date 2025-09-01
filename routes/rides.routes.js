// routes/rides.routes.js
const express = require('express');
const router = express.Router();
const { supabase } = require('../config/supabase');
const { getUserIdFromAuth } = require('../config/auth');

// Helpers to upper/lower normalize city strings a bit
function normCity(s) {
  return (s || '').toString().trim();
}

// GET /rides/search?from=&to=&when=YYYY-MM-DD
router.get('/search', async (req, res) => {
  try {
    const from = normCity(req.query.from);
    const to   = normCity(req.query.to);
    const when = (req.query.when || '').toString();

    // We read from the view your app expects: rides_search_compat or rides_compat
    // Try rides_search_compat first, fallback to rides_compat with simple filters.
    let data, error;

    // If you have a view "rides_search_compat" use it:
    ({ data, error } = await supabase
      .from('rides_search_compat')
      .select('*')
      .ilike('from', from ? from : '%')
      .ilike('to', to ? to : '%')
      .gte('depart_date', when || '1900-01-01')
      .order('depart_date', { ascending: true })
      .limit(100));

    // Fallback: if the view isn't there, query base "rides"
    if (error && error.message && /relation .* does not exist/i.test(error.message)) {
      ({ data, error } = await supabase
        .from('rides')
        .select('id, from, to, depart_date, depart_time, price_inr, seats_total, seats_available, pool, is_commercial')
        .ilike('from', from ? from : '%')
        .ilike('to', to ? to : '%')
        .gte('depart_date', when || '1900-01-01')
        .order('depart_date', { ascending: true })
        .limit(100));
    }

    if (error) return res.status(400).json({ error: error.message });
    return res.json({ items: data || [] });
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

// POST /rides/publish
// body: { from, to, depart_date, depart_time, price_inr, seats_total, pool, is_commercial, vehicle_make, vehicle_model, vehicle_number, notes }
router.post('/publish', async (req, res) => {
  try {
    const uid = getUserIdFromAuth(req);
    if (!uid) return res.status(401).json({ error: 'unauthorized' });

    const b = req.body || {};
    const record = {
      driver_id: uid,
      from: normCity(b.from),
      to: normCity(b.to),
      depart_date: b.depart_date,
      depart_time: b.depart_time,
      price_inr: Number(b.price_inr ?? 0),
      seats_total: Number(b.seats_total ?? 1),
      seats_available: Number(b.seats_total ?? 1),
      pool: (b.pool || 'shared').toString().toLowerCase(), // 'shared' or 'private'
      is_commercial: !!b.is_commercial,
      vehicle_make: b.vehicle_make || null,
      vehicle_model: b.vehicle_model || null,
      vehicle_number: b.vehicle_number || null,
      notes: b.notes || null,
      status: 'published',
    };

    // Basic required checks to avoid NOT NULL violations
    const missing = [];
    ['from','to','depart_date','price_inr','seats_total','pool'].forEach(k => {
      if (!record[k]) missing.push(k);
    });
    if (missing.length) {
      return res.status(400).json({ error: `missing required fields: ${missing.join(', ')}` });
    }

    // Ensure seats_available <= seats_total
    if (record.seats_available > record.seats_total) {
      record.seats_available = record.seats_total;
    }

    const { data, error } = await supabase
      .from('rides')
      .insert([record])
      .select('*')
      .single();

    if (error) return res.status(400).json({ error: error.message });
    return res.json({ ride: data });
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

// GET /rides/mine?role=driver|rider
router.get('/mine', async (req, res) => {
  try {
    const uid = getUserIdFromAuth(req);
    if (!uid) return res.status(401).json({ error: 'unauthorized' });

    const role = (req.query.role || '').toString();
    let data, error;

    if (role === 'driver') {
      ({ data, error } = await supabase
        .from('rides')
        .select('*')
        .eq('driver_id', uid)
        .order('created_at', { ascending: false })
        .limit(50));
    } else {
      // rider: find bookings joined to rides
      ({ data, error } = await supabase
        .from('bookings')
        .select('ride_id, seats_booked, rides(*)')
        .eq('rider_id', uid)
        .order('created_at', { ascending: false })
        .limit(50));
      data = (data || []).map(x => ({ ...(x.rides || {}), seats_booked: x.seats_booked, ride_id: x.ride_id }));
    }

    if (error) return res.status(400).json({ error: error.message });
    return res.json({ items: data || [] });
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

// GET /rides/:id
router.get('/:id', async (req, res) => {
  try {
    const id = req.params.id;
    let { data, error } = await supabase
      .from('rides')
      .select('*, driver:users!rides_driver_id_fkey(id, full_name, phone)')
      .eq('id', id)
      .single();

    if (error) return res.status(400).json({ error: error.message });
    if (!data) return res.status(404).json({ error: 'not found' });
    return res.json(data);
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

// POST /rides/:id/book  { seat_count }
router.post('/:id/book', async (req, res) => {
  try {
    const uid = getUserIdFromAuth(req);
    if (!uid) return res.status(401).json({ error: 'unauthorized' });

    const id = req.params.id;
    const seatCount = Number((req.body || {}).seat_count || 1);

    // 1) check seats
    let { data: ride, error } = await supabase
      .from('rides')
      .select('id, seats_available, seats_total')
      .eq('id', id)
      .single();
    if (error) return res.status(400).json({ error: error.message });
    if (!ride) return res.status(404).json({ error: 'ride not found' });
    if (seatCount < 1) return res.status(400).json({ error: 'seat_count must be >= 1' });
    if (seatCount > ride.seats_available) return res.status(400).json({ error: 'not enough seats' });

    // 2) insert booking
    const { error: bErr } = await supabase
      .from('bookings')
      .insert([{ ride_id: id, rider_id: uid, seats_booked: seatCount }]);
    if (bErr) return res.status(400).json({ error: bErr.message });

    // 3) decrement seats_available
    const { error: uErr } = await supabase
      .from('rides')
      .update({ seats_available: ride.seats_available - seatCount })
      .eq('id', id);
    if (uErr) return res.status(400).json({ error: uErr.message });

    return res.json({ ok: true });
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

module.exports = router;
