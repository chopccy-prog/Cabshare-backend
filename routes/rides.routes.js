// routes/rides.routes.js
const router = require('express').Router();
const { supabaseUserClient } = require('../config/supabase');

// GET /rides/search?from=Nashik&to=Mumbai&when=2025-09-01
router.get('/search', async (req, res) => {
  const { from, to, when } = req.query;
  const jwt = req.user?.token;
  const sb = supabaseUserClient(jwt);

  // prefer view "rides_search_view" for richer info; fallback to "rides_search_compat"
  let q = sb.from('rides_search_view').select('*').order('when', { ascending: true }).limit(100);
  if (from) q = q.ilike('from_city', from);
  if (to) q = q.ilike('to_city', to);
  if (when) q = q.gte('date', when).lte('date', when);

  const { data, error } = await q;
  if (error) return res.status(500).json({ error: error.message });
  return res.json({ items: data || [] });
});

// POST /rides/publish
// body: { from, to, whenDate: 'YYYY-MM-DD', whenTime: 'HH:mm', seats, price, pool }
router.post('/publish', async (req, res) => {
  const jwt = req.user?.token;
  const sb = supabaseUserClient(jwt);
  const { from, to, whenDate, whenTime, seats=1, price=0, pool='private', driver_id=null } = req.body;

  const { data, error } = await sb
    .rpc('app_publish_ride', {
      p_from: from, p_to: to,
      p_when: `${whenDate} ${whenTime}`,
      p_seats: seats, p_price_inr: price,
      p_pool: pool, p_driver_id: driver_id
    });

  if (error) return res.status(400).json({ error: error.message });
  res.json({ ride: data?.[0] ?? null });
});

// GET /rides/mine?role=driver|rider
router.get('/mine', async (req, res) => {
  const jwt = req.user?.token;
  const sb = supabaseUserClient(jwt);
  const role = (req.query.role || 'driver').toLowerCase();

  if (role === 'rider') {
    // rides where I have a booking
    const { data, error } = await sb
      .from('bookings')
      .select('*, rides!inner(*, route:routes(*), from_stop:stops(*), to_stop:stops(*))')
      .eq('rider_id', req.user?.id)
      .order('created_at', { ascending: false });

    if (error) return res.status(500).json({ error: error.message });
    return res.json({ items: data || [] });
  } else {
    // rides where I am the driver
    const { data, error } = await sb
      .from('rides')
      .select('*, route:routes(*), allowed:ride_allowed_stops(*), created_by')
      .eq('driver_id', req.user?.id)
      .order('created_at', { ascending: false });

    if (error) return res.status(500).json({ error: error.message });
    return res.json({ items: data || [] });
  }
});

module.exports = router;
