// routes/bookings.routes.js
const router = require('express').Router();
const { supabaseUserClient } = require('../config/supabase');
const { requireAuth } = require('../middleware/auth');

// POST /bookings/:ride_id
// body: { seats }
router.post('/:ride_id', requireAuth, async (req, res) => {
  const jwt = req.user?.token;
  const sb = supabaseUserClient(jwt);
  const ride_id = req.params.ride_id;
  const seats = Number(req.body?.seats || 1);

  // Use server-side RPC to enforce seats bound & lock logic
  const { data, error } = await sb.rpc('app_book_ride', { p_ride_id: ride_id, p_seats: seats });
  if (error) return res.status(400).json({ error: error.message });
  return res.json({ booking: data?.[0] ?? null });
});

module.exports = router;
