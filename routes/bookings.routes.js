// routes/bookings.routes.js  (minimal patch)
const express = require('express');
const router = express.Router();
const { supabase } = require('../supabase');

// create booking – accept seats; store seats_requested
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

// inbox list – only alias seats_requested -> seats
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

    // keep payload shape stable but minimal
    const normalized = (data || []).map(b => ({
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
