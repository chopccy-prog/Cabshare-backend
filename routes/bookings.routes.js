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
    const uid = req.user?.id || req.body.rider_id || req.query.uid;
    if (!uid) return res.status(401).json({ error: 'unauthorized' });

    const { ride_id } = req.body;
    const seats = req.body.seats ?? req.body.seats_requested;
    if (!ride_id || !seats) {
      return res.status(400).json({ error: 'ride_id and seats are required' });
    }

    // Fetch the ride to determine seats_available and auto-confirm setting
    const { data: ride, error: rideErr } = await supabase
      .from('rides')
      .select('id, allow_auto_confirm, seats_available, seats_total')
      .eq('id', ride_id)
      .single();
    if (rideErr) return res.status(400).json({ error: rideErr.message });
    if (!ride) return res.status(404).json({ error: 'ride not found' });
    // Determine remaining seats; fall back to seats_total if seats_available is null
    const seatsAvail = ride.seats_available ?? ride.seats_total ?? 0;
    if (seats > seatsAvail) {
      return res.status(400).json({ error: 'not enough seats available' });
    }
    // Auto-confirm booking if the ride allows it
    let status = 'requested';
    let newSeatsAvail = seatsAvail;
    if (ride.allow_auto_confirm === true) {
      status = 'confirmed';
      newSeatsAvail = seatsAvail - seats;
    }
    // Insert the booking
    const { data: booking, error: bookingErr } = await supabase
      .from('bookings')
      .insert({
        ride_id,
        rider_id: uid,
        seats: seats,
        status,
      })
      .select('id, ride_id, rider_id, seats, status')
      .single();
    if (bookingErr) return res.status(400).json({ error: bookingErr.message });
    // If auto-confirmed, update seats_available on the ride
    if (status === 'confirmed') {
      const { error: updErr } = await supabase
        .from('rides')
        .update({ seats_available: newSeatsAvail })
        .eq('id', ride_id);
      if (updErr) return res.status(400).json({ error: updErr.message });
    }
    // Return normalized booking record
    const result = {
      id: booking.id,
      ride_id: booking.ride_id,
      rider_id: booking.rider_id,
      seats: booking.seats,
      status: booking.status,
    };
    return res.json(result);
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

    // Fetch bookings where the current user is the rider
    const { data: riderBookings, error: riderErr } = await supabase
      .from('bookings')
      .select(
        `id, ride_id, seats, status,
         ride:rides(*),
         rider:users!bookings_rider_id_fkey ( id, full_name, avatar_url )`
      )
      .eq('rider_id', uid);
    if (riderErr) return res.status(400).json({ error: riderErr.message });

    // Fetch rides owned by the current user
    const { data: myRides, error: ridesErr } = await supabase
      .from('rides')
      .select('id')
      .eq('driver_id', uid);
    if (ridesErr) return res.status(400).json({ error: ridesErr.message });
    const rideIds = (myRides || []).map((r) => r.id);

    // Fetch bookings on those rides
    let driverBookings = [];
    if (rideIds.length > 0) {
      const { data: drvData, error: drvErr } = await supabase
        .from('bookings')
        .select(
          `id, ride_id, seats, status,
           ride:rides(*),
           rider:users!bookings_rider_id_fkey ( id, full_name, avatar_url )`
        )
        .in('ride_id', rideIds);
      if (drvErr) return res.status(400).json({ error: drvErr.message });
      driverBookings = drvData || [];
    }

    // Combine rider and driver bookings, de-duplicating by booking ID
    const finalBookings = {};
    const addToMap = (list) => {
      for (const b of list) {
        finalBookings[b.id] = b;
      }
    };
    addToMap(riderBookings);
    addToMap(driverBookings);
    const combined = Object.values(finalBookings);

    const normalized = combined.map((b) => ({
      id: b.id,
      ride_id: b.ride_id,
      seats: b.seats ?? b.seats_requested,
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