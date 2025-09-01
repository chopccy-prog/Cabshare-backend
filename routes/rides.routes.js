const express = require('express');
const router = express.Router();
const { supabase } = require('../config/supabase');

/* ---------- helpers ---------- */

function uidFromAuth(req) {
  const auth = req.headers['authorization'] || '';
  const m = /^Bearer\s+(.+)$/i.exec(auth);
  if (!m) return null;
  try {
    const payload = JSON.parse(Buffer.from(m[1].split('.')[1], 'base64url').toString('utf8'));
    return payload.sub || null;
  } catch { return null; }
}

const nz = (v) => (v ?? '').toString().trim();
const toInt = (v, d = 0) => {
  const n = Number(v);
  return Number.isFinite(n) ? n : d;
};

// Robust date/time extraction
function pickDateAndTime(body) {
  const b = body || {};
  const candidatesDate = [
    b.depart_date, b.departDate, b.date, b.when, b.depart, b.departure, b.departureDate,
    b.departDateTime, b.datetime, b.start_time, b.startTime,
  ].map(nz).filter(Boolean);

  const candidatesTime = [
    b.depart_time, b.departTime, b.time, b.departDateTime, b.datetime, b.start_time, b.startTime,
  ].map(nz).filter(Boolean);

  let d = '';
  let t = '';

  for (const s of candidatesDate) {
    const m = s.match(/\d{4}-\d{2}-\d{2}/);
    if (m) { d = m[0]; break; }
  }
  for (const s of candidatesTime) {
    const m = s.match(/\b(\d{2}:\d{2})\b/);
    if (m) { t = m[1]; break; }
  }

  // If still missing, try to parse a single combined string
  if (!d && candidatesDate.length) {
    const dt = new Date(candidatesDate[0]);
    if (!Number.isNaN(dt.getTime())) {
      d = dt.toISOString().slice(0, 10);
      if (!t) t = dt.toISOString().slice(11, 16);
    }
  }

  return { depart_date: d, depart_time: t };
}

function mapCategory(b) {
  const category = nz(b.category).toLowerCase();
  let pool = nz(b.pool).toLowerCase();
  let is_commercial = !!b.is_commercial;

  if (category === 'private_pool')        { pool = 'shared';  is_commercial = false; }
  if (category === 'commercial_pool')     { pool = 'shared';  is_commercial = true;  }
  if (category === 'commercial_full_car') { pool = 'private'; is_commercial = true;  }
  if (!pool) pool = 'shared';

  return { pool, is_commercial };
}

function extractPublish(body) {
  const b = body || {};
  const from = nz(b.from);
  const to   = nz(b.to);

  const { depart_date, depart_time } = pickDateAndTime(b);

  // price: allow price_inr | price_per_seat_inr | price
  let price_inr = toInt(b.price_inr, NaN);
  if (Number.isNaN(price_inr)) price_inr = toInt(b.price_per_seat_inr, NaN);
  if (Number.isNaN(price_inr)) price_inr = toInt(b.price, NaN);

  // seats: allow seats_total | seats | available_seats
  let seats_total = toInt(b.seats_total, NaN);
  if (Number.isNaN(seats_total)) seats_total = toInt(b.seats, NaN);
  if (Number.isNaN(seats_total)) seats_total = toInt(b.available_seats, NaN);
  if (!Number.isFinite(seats_total) || seats_total <= 0) seats_total = 1;

  const { pool, is_commercial } = mapCategory(b);

  return {
    from,
    to,
    depart_date,
    depart_time,
    price_inr,
    seats_total,
    seats_available: seats_total,
    pool,
    is_commercial,
    vehicle_make: nz(b.vehicle_make) || null,
    vehicle_model: nz(b.vehicle_model) || null,
    vehicle_number: nz(b.vehicle_number) || null,
    notes: nz(b.notes) || null,
    status: 'published',
  };
}

/* ---------- routes ---------- */

// GET /rides/search?from=&to=&when=YYYY-MM-DD
router.get('/search', async (req, res) => {
  try {
    const from = nz(req.query.from);
    const to   = nz(req.query.to);
    const when = nz(req.query.when);

    const q = supabase
      .from('rides')
      .select('id, "from", "to", depart_date, depart_time, price_inr, seats_total, seats_available, pool, is_commercial')
      .order('depart_date', { ascending: true })
      .limit(100);

    if (from) q.ilike('from', from);
    if (to)   q.ilike('to', to);
    if (when) q.gte('depart_date', when);

    const { data, error } = await q;
    if (error) return res.status(400).json({ error: error.message });
    res.json({ items: data || [] });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// POST /rides/publish
router.post('/publish', async (req, res) => {
  try {
    const uid = uidFromAuth(req);
    if (!uid) return res.status(401).json({ error: 'unauthorized' });

    const rec = extractPublish(req.body);
    const missing = [];
    if (!rec.from) missing.push('from');
    if (!rec.to) missing.push('to');
    if (!rec.depart_date) missing.push('depart_date');
    if (!(rec.price_inr || rec.price_inr === 0)) missing.push('price_inr');

    if (missing.length) {
      return res.status(400).json({ error: `missing required fields: ${missing.join(', ')}` });
    }

    const { data, error } = await supabase
      .from('rides')
      .insert([{ ...rec, driver_id: uid }])
      .select('*')
      .single();

    if (error) return res.status(400).json({ error: error.message });
    res.json({ ride: data });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// GET /rides/mine?role=driver|rider
router.get('/mine', async (req, res) => {
  try {
    const uid = uidFromAuth(req);
    if (!uid) return res.status(401).json({ error: 'unauthorized' });

    const role = nz(req.query.role);
    if (role === 'driver') {
      const { data, error } = await supabase
        .from('rides')
        .select('id, "from", "to", depart_date, depart_time, price_inr, seats_total, seats_available, status, pool, is_commercial, created_at')
        .eq('driver_id', uid)
        .order('created_at', { ascending: false })
        .limit(50);
      if (error) return res.status(400).json({ error: error.message });
      return res.json({ items: data || [] });
    }

    // rider bookings -> then fetch rides with IN (...)
    const { data: bookings, error: bErr } = await supabase
      .from('bookings')
      .select('ride_id, seats_booked, created_at')
      .eq('rider_id', uid)
      .order('created_at', { ascending: false })
      .limit(50);
    if (bErr) return res.status(400).json({ error: bErr.message });

    const ids = [...new Set((bookings || []).map(b => b.ride_id))];
    if (!ids.length) return res.json({ items: [] });

    const { data: rides, error: rErr } = await supabase
      .from('rides')
      .select('id, "from", "to", depart_date, depart_time, price_inr, seats_total, seats_available, status, pool, is_commercial, created_at')
      .in('id', ids);
    if (rErr) return res.status(400).json({ error: rErr.message });

    const mapRide = new Map((rides || []).map(r => [r.id, r]));
    const items = (bookings || [])
      .map(b => ({ ...(mapRide.get(b.ride_id) || {}), seats_booked: b.seats_booked, ride_id: b.ride_id }))
      .filter(r => r.id);
    res.json({ items });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// GET /rides/:id   (no join – fetch driver separately)
router.get('/:id', async (req, res) => {
  try {
    const { data: ride, error } = await supabase
      .from('rides')
      .select('id, driver_id, "from", "to", depart_date, depart_time, price_inr, seats_total, seats_available, pool, is_commercial, vehicle_make, vehicle_model, vehicle_number, notes')
      .eq('id', req.params.id)
      .single();
    if (error) return res.status(400).json({ error: error.message });
    if (!ride) return res.status(404).json({ error: 'not_found' });

    // fetch driver info from "users" without requiring a declared FK
    let driver = null;
    if (ride.driver_id) {
      const { data: u, error: uErr } = await supabase
        .from('users')
        .select('id, full_name, phone')
        .eq('id', ride.driver_id)
        .single();
      if (!uErr) driver = u;
    }

    res.json({ ...ride, driver });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// POST /rides/:id/book { seat_count }
router.post('/:id/book', async (req, res) => {
  try {
    const uid = uidFromAuth(req);
    if (!uid) return res.status(401).json({ error: 'unauthorized' });

    const seatCount = toInt((req.body || {}).seat_count || req.body?.seats || 1, 1);

    const { data: ride, error: rErr } = await supabase
      .from('rides')
      .select('id, seats_available')
      .eq('id', req.params.id)
      .single();
    if (rErr) return res.status(400).json({ error: rErr.message });
    if (!ride) return res.status(404).json({ error: 'ride_not_found' });
    if (seatCount < 1 || seatCount > ride.seats_available) {
      return res.status(400).json({ error: 'not_enough_seats' });
    }

    const { error: bErr } = await supabase
      .from('bookings')
      .insert([{ ride_id: req.params.id, rider_id: uid, seats_booked: seatCount }]);
    if (bErr) return res.status(400).json({ error: bErr.message });

    const { error: uErr } = await supabase
      .from('rides')
      .update({ seats_available: ride.seats_available - seatCount })
      .eq('id', req.params.id);
    if (uErr) return res.status(400).json({ error: uErr.message });

    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = router;
