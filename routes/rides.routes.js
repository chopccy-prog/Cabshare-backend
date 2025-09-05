// routes/rides.routes.js
//
// Express router providing CRUD and search endpoints for rides.
//
// This version aligns with the Supabase schema defined in schema.sql.  It
// maps camelCase or legacy keys from the client into the snake_case fields
// used by Postgres.  It also normalizes responses so that both the
// canonical and legacy field names are present, allowing older Flutter
// screens to keep working while new screens can migrate to the canonical
// fields.  The `/mine` endpoint handles both published rides (driver
// role) and booked rides (rider role) and uses `seats_requested` from
// the bookings table for rider bookings.

const express = require('express');
const router = express.Router();
const { supabase } = require('../supabase');

// -----------------------------------------------------------------------------
// Helper: attach legacy aliases to a ride object.  Supabase returns column
// names exactly as they exist in Postgres.  To maintain backward
// compatibility with earlier versions of the Flutter app, we add fields
// like `from_location`, `to_location`, `depart_date`, `depart_time`, etc.
// Consumers can migrate to using the canonical names (`from`, `to`, etc.) at
// their convenience.
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

// -----------------------------------------------------------------------------
// POST /rides
//
// Publish a new ride.  Accepts mixed camelCase and snake_case keys from the
// client and inserts into the `rides` table.  If `depart_at` is provided
// ("YYYY-MM-DD" or "YYYY-MM-DD HH:mm"), it is split into separate
// `depart_date` and `depart_time` columns.  The driver ID is taken from
// `req.user.id` (set by Supabase auth middleware) or from `uid` in the
// query string.
router.post('/', async (req, res) => {
  try {
    const b = req.body || {};

    // Split depart_at if provided
    let departDate = b.depart_date || null;
    let departTime = b.depart_time || null;
    if (!departDate && b.depart_at) {
      const parts = b.depart_at.trim().split(' ');
      departDate = parts[0];
      departTime = parts[1] || null;
    }

    // Determine driver ID: use explicit value, then auth user, then uid query
    const uid = req.user?.id || req.query.uid;

    const insert = {
      from: b.from || b.from_location || b.from_city || null,
      to: b.to || b.to_location || b.to_city || null,
      depart_date: departDate,
      depart_time: departTime,
      price_per_seat_inr: b.price_per_seat_inr || b.price || null,
      seats_total: b.seats_total || b.seats || null,
      seats_available:
        b.seats_available || b.available_seats || b.seats_total || b.seats || null,
      ride_type: b.ride_type || b.rideType || 'private_pool',
      driver_id: b.driver_id || b.user_id || b.uid || uid || null,
      car_model: b.car_model || null,
      car_plate: b.car_plate || b.car_reg_number || null,
      notes: b.notes || null,
    };

    const { data, error } = await supabase
      .from('rides')
      .insert(insert)
      .select('*')
      .single();
    if (error) return res.status(400).json({ error: error.message });
    return res.json(withAliases(data));
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

// -----------------------------------------------------------------------------
// GET /rides/search
//
// Search rides by origin, destination, date and type.  Uses ilike for
// partial matches on `from` and `to`.  `when` filters by `depart_date`.
router.get('/search', async (req, res) => {
  try {
    const { from, to, when, type } = req.query;
    let q = supabase.from('rides').select('*');
    if (from) q = q.ilike('from', `%${from}%`);
    if (to) q = q.ilike('to', `%${to}%`);
    if (when) q = q.eq('depart_date', when);
    if (type) q = q.eq('ride_type', type);
    q = q.order('depart_date', { ascending: true }).order('depart_time', { ascending: true });
    const { data, error } = await q;
    if (error) return res.status(400).json({ error: error.message });
    return res.json((data || []).map(withAliases));
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

// -----------------------------------------------------------------------------
// GET /rides/mine?role=driver|rider
//
// Return rides associated with the current user.  If role=driver (default),
// return rides where driver_id = current user.  If role=rider, return rides
// the user has booked by joining the bookings table.  Rider bookings use the
// `seats_requested` column and map it to `seats` in the response.
router.get('/mine', async (req, res) => {
  try {
    const uid = req.user?.id || req.query.uid;
    const role = (req.query.role || 'driver').toLowerCase();
    if (!uid) return res.status(401).json({ error: 'unauthorized' });

    if (role === 'driver') {
      const { data, error } = await supabase
        .from('rides')
        .select('*')
        .eq('driver_id', uid)
        .order('depart_date', { ascending: false })
        .order('depart_time', { ascending: false });
      if (error) return res.status(400).json({ error: error.message });
      return res.json((data || []).map(withAliases));
    }

    // Rider role: join bookings to rides
    const { data, error } = await supabase
      .from('bookings')
      .select(`id, seats_requested, status, ride:rides(*)`)
      .eq('rider_id', uid)
      .order('created_at', { ascending: false });
    if (error) return res.status(400).json({ error: error.message });
    const normalized = (data || []).map((b) => ({
      booking_id: b.id,
      seats: b.seats_requested,
      status: b.status,
      ...withAliases(b.ride || {}),
    }));
    return res.json(normalized);
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

// -----------------------------------------------------------------------------
// GET /rides/:id
//
// Retrieve a single ride by ID.
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { data, error } = await supabase
      .from('rides')
      .select('*')
      .eq('id', id)
      .single();
    if (error) return res.status(400).json({ error: error.message });
    return res.json(withAliases(data));
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

module.exports = router;