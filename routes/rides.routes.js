// routes/rides.routes.js
const express = require('express');
const router = express.Router();

// Use a single supabase client all across backend
// Create this file if missing: project-root/supabase.js
// module.exports = { supabase: createClient(process.env.SUPABASE_URL, SERVICE_OR_ANON_KEY) }
const { supabase } = require('../supabase');

// -------- helpers -------------------------------------------------------------

async function currentUserId(req) {
  // Prefer Bearer token (Supabase session), fallback to dev header
  try {
    const auth = req.headers.authorization || '';
    const token = auth.startsWith('Bearer ') ? auth.slice(7) : null;
    if (token) {
      const { data, error } = await supabase.auth.getUser(token);
      if (!error && data?.user?.id) return data.user.id;
    }
  } catch (_) {}
  return req.header('x-user-id') || null; // dev-only fallback
}

function mapRow(r) {
  return {
    id: r.id,
    from: r.from_location,
    to: r.to_location,
    depart_date: r.depart_date,              // YYYY-MM-DD
    depart_time: r.depart_time,              // HH:MM[:SS] or null
    price_per_seat_inr: r.price_inr ?? 0,
    seats_total: r.seats_total ?? 0,
    seats_available: r.seats_available ?? 0,
    is_commercial: !!r.is_commercial,
    pool: r.pool || 'shared',
    driver_id: r.driver_id,
  };
}

// -------- routes -------------------------------------------------------------

// GET /rides?from=&to=&date=YYYY-MM-DD   (PUBLIC)
router.get('/', async (req, res) => {
  try {
    const from = (req.query.from || '').trim();
    const to   = (req.query.to || '').trim();
    const date = (req.query.date || '').trim();

    let q = supabase.from('rides')
      .select('id, from_location, to_location, depart_date, depart_time, price_inr, seats_total, seats_available, is_commercial, pool, driver_id, status')
      .eq('status', 'published');

    if (from) q = q.ilike('from_location', from);
    if (to)   q = q.ilike('to_location', to);
    if (date) q = q.eq('depart_date', date);

    const { data, error } = await q
      .order('depart_date', { ascending: true })
      .order('depart_time', { ascending: true });

    if (error) return res.status(400).json({ error: error.message });
    return res.json((data || []).map(mapRow));
  } catch (e) {
    return res.status(500).json({ error: String(e.message || e) });
  }
});

// GET /rides/:id  (PUBLIC)  — includes basic driver info
router.get('/:id', async (req, res) => {
  try {
    const id = req.params.id;

    const { data: ride, error } = await supabase
      .from('rides')
      .select('*')
      .eq('id', id)
      .maybeSingle();

    if (error)   return res.status(400).json({ error: error.message });
    if (!ride)   return res.status(404).json({ error: 'not_found' });

    let driver = null;
    if (ride.driver_id) {
      const { data: u } = await supabase
        .from('users')
        .select('id, full_name, phone')
        .eq('id', ride.driver_id)
        .maybeSingle();
      driver = u || null;
    }

    const out = mapRow(ride);
    out.driver = driver;
    return res.json(out);
  } catch (e) {
    return res.status(500).json({ error: String(e.message || e) });
  }
});

// POST /rides  (AUTH) — publish a ride
router.post('/', async (req, res) => {
  try {
    const userId = await currentUserId(req);
    if (!userId) return res.status(401).json({ error: 'unauthorized' });

    const b = req.body || {};

    // Accept older keys too but store canonical column names
    const from_location = (b.from_location ?? b.from ?? '').toString().trim();
    const to_location   = (b.to_location   ?? b.to   ?? '').toString().trim();
    const depart_date   = (b.depart_date   ?? b.date ?? b.when ?? '').toString().trim();
    const depart_time   = (b.depart_time   ?? b.time ?? null) || null;

    const seats_total = Number(b.seats_total ?? b.seats ?? 0) || 0;
    const price_inr   = Number(b.price_inr ?? b.price_per_seat_inr ?? b.price ?? 0) || 0;

    let seats_available = b.seats_available ?? b.available_seats ?? seats_total;
    seats_available = Number(seats_available) || 0;

    const is_commercial = !!(b.is_commercial ?? (b.category && b.category.toString().toLowerCase().includes('commercial')));
    const pool = (b.pool ?? (b.category === 'commercial_full_car' ? 'private' : 'shared')).toString();

    const missing = [];
    if (!from_location) missing.push('from');
    if (!to_location)   missing.push('to');
    if (!depart_date)   missing.push('depart_date');
    if (!seats_total)   missing.push('seats_total');
    if (!price_inr)     missing.push('price_inr');
    if (missing.length) return res.status(400).json({ error: `missing required fields: ${missing.join(', ')}` });

    const row = {
      driver_id: userId,
      from_location,
      to_location,
      depart_date,
      depart_time,
      seats_total,
      seats_available,
      price_inr,
      is_commercial,
      pool,           // 'shared' for pool, 'private' for full-car
      status: 'published',
    };

    const { data, error } = await supabase.from('rides').insert(row).select('*').single();
    if (error) return res.status(400).json({ error: error.message });

    return res.status(201).json(mapRow(data));
  } catch (e) {
    return res.status(500).json({ error: String(e.message || e) });
  }
});

// POST /rides/:id/book  (AUTH-lite) — decrements seats; bookings table optional
router.post('/:id/book', async (req, res) => {
  try {
    const userId = await currentUserId(req);
    if (!userId) return res.status(401).json({ error: 'unauthorized' });

    const id = req.params.id;
    const seats = Number(req.body?.seats ?? 1) || 1;

    const { data: ride, error: rErr } = await supabase.from('rides').select('*').eq('id', id).maybeSingle();
    if (rErr)   return res.status(400).json({ error: rErr.message });
    if (!ride)  return res.status(404).json({ error: 'not_found' });

    const avail = Number(ride.seats_available ?? 0);
    if (avail < seats) return res.status(400).json({ error: 'not_enough_seats' });

    const { error: uErr } = await supabase
      .from('rides')
      .update({ seats_available: avail - seats })
      .eq('id', id);
    if (uErr) return res.status(400).json({ error: uErr.message });

    // OPTIONAL: if you have bookings table, insert there too (commented for safety)
    // await supabase.from('bookings').insert({ ride_id: id, rider_id: userId, seats, status: 'pending' });

    return res.json({ ok: true });
  } catch (e) {
    return res.status(500).json({ error: String(e.message || e) });
  }
});

// GET /rides/mine?role=driver|rider  (AUTH)
router.get('/mine', async (req, res) => {
  try {
    const userId = await currentUserId(req);
    if (!userId) return res.status(401).json({ error: 'unauthorized' });

    const role = (req.query.role || 'driver').toString();

    if (role === 'driver') {
      const { data, error } = await supabase
        .from('rides')
        .select('id, from_location, to_location, depart_date, depart_time, price_inr, seats_total, seats_available, is_commercial, pool, status')
        .eq('driver_id', userId)
        .order('created_at', { ascending: false });

      if (error) return res.status(400).json({ error: error.message });
      return res.json((data || []).map(mapRow));
    }

    // Rider side requires a bookings table; return empty list for now
    return res.json([]);
  } catch (e) {
    return res.status(500).json({ error: String(e.message || e) });
  }
});

module.exports = router;
