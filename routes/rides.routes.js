// routes/rides.routes.js
const express = require('express');
const router = express.Router();
const { supabase } = require('../supabase'); // keep your client import

function getUserId(req) {
  return (
    req.header('x-user-id') ||
    req.header('x-user') ||
    (req.user && req.user.id) ||
    null
  );
}

// ---------- helpers ----------
function normalizeRidePayload(body = {}, userId) {
  // city names
  const from =
    body.from ?? body.from_city ?? body.source ?? body.origin ?? null;
  const to =
    body.to ?? body.to_city ?? body.destination ?? body.dest ?? null;

  // date/time (accept many aliases)
  const depart_date =
    body.depart_date ?? body.date ?? body.when ?? body.departDate ?? null;
  const depart_time =
    body.depart_time ?? body.time ?? body.departTime ?? null;

  // seats / price
  const seats_total = Number(
    body.seats_total ?? body.seats ?? body.total_seats ?? body.capacity ?? 0
  );

  // ⚠️ IMPORTANT: never mix ?? and || without parentheses
  const rawSeatsAvail =
    body.seats_available ?? body.available_seats ?? seats_total;
  const seats_available = Number((rawSeatsAvail ?? 0));

  const price_inr = Number(
    body.price_inr ?? body.price ?? body.price_per_seat_inr ?? 0
  );

  // category → pool/is_commercial (compat)
  let pool = (body.pool ?? '').toString().toLowerCase();
  let is_commercial =
    body.is_commercial === true ||
    body.is_commercial === 'true' ||
    body.is_commercial === 1;

  const category = (body.category ?? '').toString().toLowerCase();
  if (!pool && category) {
    if (category.includes('full')) {
      pool = 'private';
      is_commercial = true;
    } else if (category.includes('commercial')) {
      pool = 'shared';
      is_commercial = true;
    } else {
      pool = 'shared';
      is_commercial = false;
    }
  }
  if (pool !== 'private') pool = 'shared';

  return {
    driver_id: userId ?? body.driver_id ?? null,
    from,
    to,
    depart_date,       // YYYY-MM-DD
    depart_time,       // HH:mm (optional)
    seats_total,
    seats_available,
    price_inr,
    pool,
    is_commercial: !!is_commercial,
    status: body.status ?? 'published',
  };
}

function toClient(row) {
  const dd = row.depart_date || row.date || row.when || null;
  const dt = row.depart_time || row.time || null;
  const when = dd && dt ? `${dd} ${dt}` : dd ? `${dd}` : dt ? `${dt}` : '';

  return {
    id: row.id,
    from: row.from || row.from_city || row.source || null,
    to: row.to || row.to_city || row.destination || null,
    depart_date: row.depart_date || row.date || row.when || null,
    depart_time: row.depart_time || row.time || null,
    when, // compat for current UI
    seats_total:
      row.seats_total ?? row.total_seats ?? row.capacity ?? row.seats ?? 0,
    seats_available:
      row.seats_available ?? row.available_seats ?? row.seats ?? 0,
    seats:
      row.seats_available ?? row.available_seats ?? row.seats ?? 0, // compat
    price_inr:
      row.price_inr ?? row.price_per_seat_inr ?? row.price ?? 0,
    price:
      row.price_inr ?? row.price_per_seat_inr ?? row.price ?? 0, // compat
    pool: row.pool === 'private' ? 'private' : 'shared',
    is_commercial: !!(row.is_commercial ?? row.commercial ?? false),
    status: row.status ?? 'published',
  };
}

// ---------- routes ----------

// GET /rides/search?from=&to=&when=YYYY-MM-DD
router.get('/search', async (req, res) => {
  try {
    const qFrom = (req.query.from || '').trim();
    const qTo = (req.query.to || '').trim();
    const qWhen = (req.query.when || '').trim();

    let q = supabase.from('rides').select('*').eq('status', 'published');

    if (qFrom) q = q.or(`from.eq.${qFrom},from_city.eq.${qFrom}`);
    if (qTo) q = q.or(`to.eq.${qTo},to_city.eq.${qTo}`);
    if (qWhen) q = q.eq('depart_date', qWhen);

    q = q.order('depart_date', { ascending: true })
         .order('depart_time', { ascending: true });

    const { data, error } = await q;
    if (error) return res.status(400).json({ error: error.message });

    res.json((data || []).map(toClient));
  } catch (e) {
    res.status(500).json({ error: `${e}` });
  }
});

// POST /rides/publish
router.post('/publish', async (req, res) => {
  try {
    const userId = getUserId(req);
    if (!userId) return res.status(401).json({ error: 'unauthorized' });

    const payload = normalizeRidePayload(req.body, userId);

    if (!payload.from || !payload.to || !payload.depart_date) {
      return res.status(400).json({ error: 'missing required fields: depart_date' });
    }

    if (!payload.seats_total || payload.seats_total < 1) payload.seats_total = 1;
    if (payload.seats_available == null || payload.seats_available < 0) {
      payload.seats_available = payload.seats_total;
    }

    const { data, error } = await supabase
      .from('rides')
      .insert(payload)
      .select('*')
      .single();

    if (error) return res.status(400).json({ error: error.message });
    res.json(toClient(data));
  } catch (e) {
    res.status(500).json({ error: `${e}` });
  }
});

// GET /rides/mine?role=driver|rider
router.get('/mine', async (req, res) => {
  try {
    const userId = getUserId(req);
    if (!userId) return res.status(401).json({ error: 'unauthorized' });

    const role = (req.query.role || 'driver').toString();

    if (role === 'driver') {
      const { data, error } = await supabase
        .from('rides')
        .select('*')
        .eq('driver_id', userId)
        .order('depart_date', { ascending: false })
        .order('depart_time', { ascending: false });

      if (error) return res.status(400).json({ error: error.message });
      return res.json((data || []).map(toClient));
    }

    // Rider list: return [] for now unless you wire a bookings table.
    return res.json([]);
  } catch (e) {
    res.status(500).json({ error: `${e}` });
  }
});

// GET /rides/:id
router.get('/:id', async (req, res) => {
  try {
    const rideId = req.params.id;

    const { data: ride, error } = await supabase
      .from('rides')
      .select('*')
      .eq('id', rideId)
      .single();

    if (error) return res.status(400).json({ error: error.message });

    let driver = null;
    if (ride && ride.driver_id) {
      const { data: u } = await supabase
        .from('users')
        .select('id, full_name, phone')
        .eq('id', ride.driver_id)
        .single();
      driver = u || null;
    }

    const resp = toClient(ride);
    resp.driver = driver;

    res.json(resp);
  } catch (e) {
    res.status(500).json({ error: `${e}` });
  }
});

module.exports = router;
