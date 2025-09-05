// routes/bookings.routes.js
//
// Updated implementation for Work Setu‑Cab Share backend.
//
// Key changes:
//  - Adds a `withAliases` helper (mirroring rides.routes.js) to attach
//    legacy field names such as `from_location` and `to_location` to
//    nested ride objects returned in the inbox payload.
//  - Leaves the booking creation API unchanged but improves error
//    messages and input validation.

const express = require('express');
const router = express.Router();
const { supabase } = require('../supabase');

// -------------------------------------------------------------
// Helper to normalize ride objects in booking responses.  This is a
// duplicate of the helper defined in rides.routes.js to avoid a
// circular dependency.  It attaches camelCase keys (from_location,
// to_location, depart_date, depart_time, etc.) back onto the ride
// object so existing clients can continue to access those fields.
const withAliases = (r) => ({
  ...r,
  from_location: r.from ?? r.from_location ?? null,
  to_location: r.to ?? r.to_location ?? null,
  depart_date: r.depart_date ?? null,
  depart_time: r.depart_time ?? null,
  seats_total: r.seats_total ?? r.seats ?? null,
  seats_available: r.seats_available ?? null,
  price_per_seat_inr: r.price_per_seat_inr ?? r.price ?? null,
  ride_type: r.ride_type ?? r.pool ?? null,
});

// -------------------------------------------------------------
// POST /bookings
//
// Creates a new booking for a ride.  Accepts { ride_id, seats } in
// the request body.  The current user is determined by Supabase
// authentication middleware (`req.user.id`) or by passing `rider_id`
// explicitly.  Seats are stored in the `seats_requested` column.
router.post('/', async (req, res) => {
  try {
    const uid = req.user?.id || req.body.rider_id;
    if (!uid) return res.status(401).json({ error: 'unauthorized' });

    const { ride_id } = req.body;
    const seats = req.body.seats ?? req.body.seats_requested;
    if (!ride_id || !seats) {
      return res.status(400).json({ error: 'ride_id and seats are required' });
    }

    const { data, error } = await supabase
      .from('bookings')
      .insert({
        ride_id,
        rider_id: uid,
        seats_requested: seats,
        status: 'requested',
      })
      .select(`
        id, ride_id, rider_id, seats_requested as seats, status, created_at
      `)
      .single();

    if (error) return res.status(400).json({ error: error.message });
    return res.json(data);
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

// -------------------------------------------------------------
// GET /bookings/inbox
//
// Returns a list of bookings where the current user is either the
// rider or the driver.  Each item includes the associated ride (with
// legacy field aliases) and the rider’s basic profile.
router.get('/inbox', async (req, res) => {
  try {
    const uid = req.user?.id || req.query.uid;
    if (!uid) return res.status(401).json({ error: 'unauthorized' });

    const { data, error } = await supabase
      .from('bookings')
      .select(`
        id,
        ride_id,
        seats_requested as seats,
        status,
        ride:rides(*),
        rider:users!bookings_rider_id_fkey ( id, full_name, avatar_url )
      `)
      .or(`rider_id.eq.${uid},ride.driver_id.eq.${uid}`)
      .order('created_at', { ascending: false });

    if (error) return res.status(400).json({ error: error.message });

    const normalized = (data || []).map((b) => ({
      id: b.id,
      ride_id: b.ride_id,
      seats: b.seats,
      status: b.status,
      rider: b.rider,
      ride: withAliases(b.ride || {}),
    }));

    return res.json(normalized);
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

module.exports = router;