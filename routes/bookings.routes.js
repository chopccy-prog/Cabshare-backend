const express = require('express');
const router = express.Router();
const { supabase } = require('../supabase');

// Helper to add legacy aliases on ride objects (same as in rides.routes.js)
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

// Create a new booking
router.post('/', async (req, res) => {
  try {
    const uid = req.user?.id || req.body.rider_id || req.query.uid;
    if (!uid) return res.status(401).json({ error: 'unauthorized' });

    const { ride_id } = req.body;
    const seats = req.body.seats ?? req.body.seats_requested;
    const pickupStop = req.body.pickup_stop_id;
    const dropStop = req.body.drop_stop_id;
    if (!ride_id || !seats) {
      return res.status(400).json({ error: 'ride_id and seats are required' });
    }

    // Fetch ride to check seats_available and auto-confirm
    const { data: ride, error: rideErr } = await supabase
      .from('rides')
      .select('id, allow_auto_confirm, seats_available, seats_total')
      .eq('id', ride_id)
      .single();
    if (rideErr) return res.status(400).json({ error: rideErr.message });
    if (!ride) return res.status(404).json({ error: 'ride not found' });

    const seatsAvail = ride.seats_available ?? ride.seats_total ?? 0;
    if (seats > seatsAvail) {
      return res.status(400).json({ error: 'not enough seats available' });
    }

    let status = 'requested';
    let newSeatsAvail = seatsAvail;
    if (ride.allow_auto_confirm === true) {
      status = 'confirmed';
      newSeatsAvail = seatsAvail - seats;
    }

    // Insert booking (use seats_requested column)
    const { data: booking, error: bookingErr } = await supabase
      .from('bookings')
      .insert({
        ride_id,
        rider_id: uid,
        seats_requested: seats,
        status,
        pickup_stop_id: pickupStop ?? null,
        drop_stop_id: dropStop ?? null,
      })
      .select('id, ride_id, rider_id, seats_requested, status, pickup_stop_id, drop_stop_id')
      .single();
    if (bookingErr) return res.status(400).json({ error: bookingErr.message });

    // Update ride’s seats_available if auto-confirmed
    if (status === 'confirmed') {
      const { error: updErr } = await supabase
        .from('rides')
        .update({ seats_available: newSeatsAvail })
        .eq('id', ride_id);
      if (updErr) return res.status(400).json({ error: updErr.message });
    }

    return res.json({
      id: booking.id,
      ride_id: booking.ride_id,
      rider_id: booking.rider_id,
      seats: booking.seats_requested, // map for client
      status: booking.status,
      pickup_stop_id: booking.pickup_stop_id,
      drop_stop_id: booking.drop_stop_id,
    });
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

// Get bookings for inbox: combine rider and driver bookings; no user join
router.get('/inbox', async (req, res) => {
  try {
    const uid = req.user?.id || req.query.uid;
    if (!uid) return res.status(401).json({ error: 'unauthorized' });

    // Rider bookings
    const { data: riderBookings, error: riderErr } = await supabase
      .from('bookings')
      .select(
        `id, ride_id, seats_requested, status,
         ride:rides(*)`
      )
      .eq('rider_id', uid);
    if (riderErr) return res.status(400).json({ error: riderErr.message });

    // Rides owned by current user
    const { data: myRides, error: ridesErr } = await supabase
      .from('rides')
      .select('id')
      .eq('driver_id', uid);
    if (ridesErr) return res.status(400).json({ error: ridesErr.message });
    const rideIds = (myRides || []).map((r) => r.id);

    // Driver bookings
    let driverBookings = [];
    if (rideIds.length > 0) {
      const { data: drvData, error: drvErr } = await supabase
        .from('bookings')
        .select(
          `id, ride_id, seats_requested, status,
           ride:rides(*)`
        )
        .in('ride_id', rideIds);
      if (drvErr) return res.status(400).json({ error: drvErr.message });
      driverBookings = drvData || [];
    }

    // Merge lists and remove duplicates
    const all = {};
    const add = (list) => {
      for (const b of list) all[b.id] = b;
    };
    add(riderBookings);
    add(driverBookings);

    const result = Object.values(all).map((b) => ({
      id: b.id,
      ride_id: b.ride_id,
      seats: b.seats_requested,
      status: b.status,
      ride: withAliases(b.ride || {}),
      rider_id: b.rider_id ?? uid,
    }));

    return res.json(result);
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

module.exports = router;
