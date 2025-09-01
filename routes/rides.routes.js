// routes/rides.routes.js
const router = require('express').Router();
const { requireAuth } = require('../middleware/auth');
const { supabaseUserClient } = require('../config/supabase');

// Utility: coerce booleans
function toBool(v) {
  if (v === true || v === false) return v;
  if (typeof v === 'number') return v !== 0;
  if (typeof v === 'string') return v.toLowerCase() === 'true' || v === '1';
  return false;
}

// --------------------------------------------------------------
// GET /rides/search?from=&to=&when=YYYY-MM-DD
// Only uses columns that we guaranteed in SQL: "from","to","start_time"
// --------------------------------------------------------------
router.get('/search', async (req, res) => {
  const jwt = req.headers.authorization?.split(' ')[1] || null;
  const sb = supabaseUserClient(jwt);

  const from = (req.query.from || '').toString().trim();
  const to = (req.query.to || '').toString().trim();
  const when = (req.query.when || '').toString().trim(); // YYYY-MM-DD

  try {
    let q = sb.from('rides_compat').select('*');

    if (from) q = q.ilike('from', `%${from}%`);
    if (to)   q = q.ilike('to',   `%${to}%`);

    if (when) {
      q = q.gte('start_time', `${when} 00:00:00`).lte('start_time', `${when} 23:59:59`);
    }

    const { data, error } = await q.order('start_time', { ascending: false }).limit(200);
    if (error) return res.status(400).json({ error: error.message });

    res.json({ items: data || [] });
  } catch (e) {
    res.status(400).json({ error: e.message || String(e) });
  }
});

// --------------------------------------------------------------
// POST /rides/publish
// body: { from, to, whenDate:"YYYY-MM-DD", whenTime:"HH:mm", seats, price, pool:'private|shared', isCommercial:true|false }
// --------------------------------------------------------------
router.post('/publish', requireAuth, async (req, res) => {
  const sb = supabaseUserClient(req.user.token);
  const b = req.body || {};

  if (!b.from || !b.to || !b.whenDate || !b.whenTime) {
    return res.status(400).json({ error: 'from, to, whenDate, whenTime are required' });
  }
  const when = `${b.whenDate} ${b.whenTime}`;
  const isCommercial = toBool(b.isCommercial);

  try {
    // Use RPC we created in SQL. It returns the inserted row.
    const { data, error } = await sb.rpc('app_publish_ride', {
      p_from: b.from,
      p_to: b.to,
      p_when: when,
      p_seats: Number(b.seats ?? 1),
      p_price_inr: Number(b.price ?? 0),
      p_pool: b.pool || 'private',
      p_is_commercial: isCommercial
    });
    if (error) return res.status(400).json({ error: error.message });

    const ride = Array.isArray(data) ? data[0] : data;
    res.json({ ride });
  } catch (e) {
    res.status(400).json({ error: e.message || String(e) });
  }
});

// --------------------------------------------------------------
// POST /bookings/:rideId   body: { seats }
//  - MVP booking insert
//  - also seeds an Inbox message to driver to start a thread
// --------------------------------------------------------------
router.post('/bookings/:rideId', requireAuth, async (req, res) => {
  const sb = supabaseUserClient(req.user.token);
  const rideId = req.params.rideId;
  const seats = Number(req.body?.seats ?? 1);

  if (!rideId) return res.status(400).json({ error: 'rideId required' });

  try {
    // find ride to know driver
    const { data: ride, error: rerr } = await sb.from('rides').select('id, driver_id').eq('id', rideId).single();
    if (rerr) return res.status(400).json({ error: rerr.message });
    if (!ride) return res.status(404).json({ error: 'Ride not found' });

    // create booking
    const { data: booking, error: berr } = await sb
      .from('bookings')
      .insert({ ride_id: rideId, rider_id: req.user.id, seats })
      .select('*')
      .single();
    if (berr) return res.status(400).json({ error: berr.message });

    // seed first message to start the thread
    try {
      await sb.from('messages').insert({
        ride_id: rideId,
        sender_id: req.user.id,        // rider
        recipient_id: ride.driver_id,  // driver
        text: `New booking request (${seats} seat${seats > 1 ? 's' : ''}).`
      });
    } catch (_ignore) {}

    res.json({ booking });
  } catch (e) {
    res.status(400).json({ error: e.message || String(e) });
  }
});

// --------------------------------------------------------------
// GET /rides/mine?role=driver|rider
// --------------------------------------------------------------
router.get('/mine', requireAuth, async (req, res) => {
  const sb = supabaseUserClient(req.user.token);
  const role = (req.query.role || 'driver').toString();

  try {
    if (role === 'driver') {
      const { data, error } = await sb
        .from('rides_compat')
        .select('*')
        .eq('driver_id', req.user.id)
        .order('start_time', { ascending: false })
        .limit(100);
      if (error) return res.status(400).json({ error: error.message });
      return res.json({ items: data || [] });
    } else {
      const { data, error } = await sb
        .from('bookings')
        .select('*, ride:rides(*)')
        .eq('rider_id', req.user.id)
        .order('created_at', { ascending: false })
        .limit(100);
      if (error) return res.status(400).json({ error: error.message });
      const items = (data || []).map(r => r.ride || r);
      return res.json({ items });
    }
  } catch (e) {
    res.status(400).json({ error: e.message || String(e) });
  }
});

module.exports = router;
