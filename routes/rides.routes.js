// routes/rides.routes.js
const router = require('express').Router();
const { requireAuth } = require('../middleware/auth');
const { supabaseUserClient } = require('../config/supabase');

// ---- Helpers ----
async function selectRidesFlexible(sb, queryBuilder) {
  // Try rides_compat first; fall back to rides if the view doesn't exist.
  // queryBuilder(table) returns a Supabase query with filters.
  let q = queryBuilder('rides_compat');
  let { data, error } = await q;
  if (error && (error.code === '42P01' || /relation .* does not exist/i.test(error.message))) {
    // table/view missing, try raw 'rides'
    q = queryBuilder('rides');
    ({ data, error } = await q);
  }
  if (error) throw error;
  return data || [];
}

function normalizeBool(v) {
  if (v === true || v === false) return v;
  if (typeof v === 'number') return v !== 0;
  if (typeof v === 'string') return v.toLowerCase() === 'true' || v === '1';
  return false;
}

// --------------------------------------------------------------
// GET /rides/search?from=&to=&when=YYYY-MM-DD
// --------------------------------------------------------------
router.get('/search', async (req, res) => {
  const jwt = req.headers.authorization?.split(' ')[1] || null;
  const sb = supabaseUserClient(jwt);
  const from = (req.query.from || '').toString().trim();
  const to = (req.query.to || '').toString().trim();
  const when = (req.query.when || '').toString().trim(); // YYYY-MM-DD

  try {
    const items = await selectRidesFlexible(sb, (table) => {
      let q = sb.from(table).select('*');

      // support both "from/to" and "from_city/to_city" columns via OR logic when needed
      if (from) {
        q = q.or(`from.ilike.${from},from_city.ilike.${from}`);
      }
      if (to) {
        q = q.or(`to.ilike.${to},to_city.ilike.${to}`);
      }
      if (when) {
        // Try to filter on start_time if present; else ignore (still return results)
        q = q.gte('start_time', `${when} 00:00:00`).lte('start_time', `${when} 23:59:59`);
      }

      // Return most recent first
      return q.order('start_time', { ascending: false }).limit(200);
    });

    res.json({ items });
  } catch (e) {
    res.status(400).json({ error: e.message || String(e) });
  }
});

// --------------------------------------------------------------
// POST /rides/publish
// body: { from, to, whenDate:"YYYY-MM-DD", whenTime:"HH:mm", seats, price, pool, driver_id?, isCommercial? }
// --------------------------------------------------------------
router.post('/publish', requireAuth, async (req, res) => {
  const jwt = req.user?.token;
  const sb = supabaseUserClient(jwt);

  const {
    from, to,
    whenDate, whenTime,
    seats = 1, price = 0,
    pool = 'private',
    driver_id = null,
    isCommercial = false
  } = req.body || {};

  if (!from || !to || !whenDate || !whenTime) {
    return res.status(400).json({ error: 'from, to, whenDate, whenTime are required' });
  }

  try {
    // Publish via RPC (keeps your existing server-side logic)
    const when = `${whenDate} ${whenTime}`;
    const { data, error } = await sb.rpc('app_publish_ride', {
      p_from: from,
      p_to: to,
      p_when: when,
      p_seats: seats,
      p_price_inr: price,
      p_pool: pool,
      p_driver_id: driver_id
    });
    if (error) throw error;

    const ride = Array.isArray(data) ? data[0] : data;

    // best-effort: persist commercial flag if the column exists; ignore errors
    if (ride?.id) {
      try {
        await sb.from('rides').update({ is_commercial: normalizeBool(isCommercial) }).eq('id', ride.id);
      } catch (_ignored) {}
    }

    res.json({ ride });
  } catch (e) {
    res.status(400).json({ error: e.message || String(e) });
  }
});

// --------------------------------------------------------------
// POST /bookings/:rideId   body: { seats }
// --------------------------------------------------------------
router.post('/bookings/:rideId', requireAuth, async (req, res) => {
  const jwt = req.user?.token;
  const sb = supabaseUserClient(jwt);
  const rideId = req.params.rideId;
  const seats = Number(req.body?.seats ?? 1);

  if (!rideId) return res.status(400).json({ error: 'rideId required' });

  try {
    const { data, error } = await sb.rpc('api_book_ride', {
      p_ride_id: rideId,
      p_seats: seats,
    });
    if (error) throw error;
    const booking = Array.isArray(data) ? data[0] : data;
    res.json({ booking });
  } catch (e) {
    res.status(400).json({ error: e.message || String(e) });
  }
});

// --------------------------------------------------------------
// GET /rides/mine?role=driver|rider
// --------------------------------------------------------------
router.get('/mine', requireAuth, async (req, res) => {
  const jwt = req.user?.token;
  const sb = supabaseUserClient(jwt);
  const role = (req.query.role || 'driver').toString();

  try {
    if (role === 'driver') {
      // rides you published
      const items = await selectRidesFlexible(sb, (table) =>
        sb.from(table).select('*').eq('driver_id', req.user.id).order('start_time', { ascending: false }).limit(100)
      );
      return res.json({ items });
    } else {
      // rides you booked (flatten booking->ride)
      const { data, error } = await sb
        .from('bookings')
        .select('*, ride:rides(*)')
        .eq('rider_id', req.user.id)
        .order('created_at', { ascending: false })
        .limit(100);
      if (error) throw error;
      const items = (data || []).map(r => r.ride || r);
      return res.json({ items });
    }
  } catch (e) {
    res.status(400).json({ error: e.message || String(e) });
  }
});

module.exports = router;
