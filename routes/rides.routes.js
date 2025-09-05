// routes/rides.routes.js
//
// Updated implementation for Work Setu‑Cab Share backend.
//
// Key changes:
//  - The "/mine" route is defined before the dynamic "/:id" route to avoid the
//    Express routing bug that treated "mine" as a ride ID.
//  - Insert statements map incoming payload keys to the actual Postgres columns
//    defined in the `rides` table (see schema.sql).  We split `depart_at` into
//    separate `depart_date` and `depart_time` columns if provided.
//  - Search filters now operate on the existing `from`, `to`, and
//    `depart_date` columns instead of non‑existent `*_location` columns.
//  - A helper function `withAliases` attaches camelCase keys back onto the
//    returned object so the Flutter app can continue to access
//    `from_location`, `to_location`, etc. without breaking.

const express = require('express');
const router = express.Router();
const { supabase } = require('../supabase');

// -------------------------------------------------------------
// Helper to normalize and alias ride fields in API responses.
// This ensures both the legacy camelCase names (from_location,
// to_location, depart_date, depart_time, etc.) and the actual
// database column names are present on the returned JSON.  Downstream
// clients may continue referencing the camelCase versions while new
// code can switch to the canonical names.
const withAliases = (r) => ({
  ...r,
  // Provide legacy aliases for backwards compatibility.
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
// PUBLISH: POST /rides
//
// Accepts a payload with a mixture of legacy keys (e.g. from_location)
// and canonical keys (from, to, depart_date, depart_time, etc.), then
// inserts a new ride into the database using the correct column names.
router.post('/', async (req, res) => {
  try {
    const b = req.body || {};

    // Split `depart_at` into separate date and time fields if provided.
    let departDate = b.depart_date || null;
    let departTime = b.depart_time || null;
    if (!departDate && b.depart_at) {
      const parts = b.depart_at.trim().split(' ');
      departDate = parts[0];
      departTime = parts[1] || null;
    }

    // Map request properties into database columns.  We favour the
    // canonical snake_case names but fall back to legacy/camelCase keys.
    // Determine the driver ID from the authenticated user or an explicit uid
    const uid = req.user?.id || req.query.uid;

    const insert = {
      from: b.from || b.from_location || b.from_city || null,
      to: b.to || b.to_location || b.to_city || null,
      depart_date: departDate,
      depart_time: departTime,
      price_per_seat_inr: b.price_per_seat_inr || b.price || null,
      seats_total: b.seats_total || b.seats || null,
      seats_available:
        b.seats_available ||
        b.available_seats ||
        b.seats_total ||
        b.seats ||
        null,
      // Use provided ride_type if present; otherwise default to "private_pool" which is
      // a valid enum value according to the schema.  Accept camelCase `rideType` as well.
      ride_type: b.ride_type || b.rideType || 'private_pool',
      // Prioritise any explicit driver_id sent by the client, then the authenticated
      // user ID or uid query parameter.  Without this, driver_id would be null,
      // causing rides not to appear under "Published" in the app.
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

// -------------------------------------------------------------
// SEARCH: GET /rides/search
//
// Query rides by from/to/date/type using the existing `rides` table
// columns.  `when` is treated as the departure date (YYYY‑MM‑DD).  The
// results are ordered by departure date and time ascending.
router.get('/search', async (req, res) => {
  try {
    const { from, to, when, type } = req.query;

    let q = supabase.from('rides').select('*');
    if (from) q = q.ilike('from', `%${from}%`);
    if (to) q = q.ilike('to', `%${to}%`);
    if (when) q = q.eq('depart_date', when);
    if (type) q = q.eq('ride_type', type);

    q = q
      .order('depart_date', { ascending: true })
      .order('depart_time', { ascending: true });

    const { data, error } = await q;
    if (error) return res.status(400).json({ error: error.message });
    return res.json((data || []).map(withAliases));
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

// -------------------------------------------------------------
// MINE: GET /rides/mine?role=driver|rider
//
// Returns the rides published by the current user (driver) or rides the
// user has booked (rider).  This route must be defined before the
// dynamic "/:id" route so that Express does not interpret "mine" as an
// `id` parameter.  The current user is determined from `req.user?.id`
// (decoded by Supabase middleware) or via the `uid` query parameter.
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

    // rider: join bookings to rides
    const { data, error } = await supabase
      .from('bookings')
      .select(
        `id, seats, status, ride:rides(*)`
      )
      .eq('rider_id', uid)
      .order('created_at', { ascending: false });
    if (error) return res.status(400).json({ error: error.message });
    const normalized = (data || []).map((b) => ({
      booking_id: b.id,
      seats: b.seats ?? b.seats_requested,
      status: b.status,
      ...withAliases(b.ride || {}),
    }));
    return res.json(normalized);
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

// -------------------------------------------------------------
// GET ONE: GET /rides/:id
//
// Returns a single ride by its UUID.  This dynamic route must appear
// after the more specific routes above (e.g. /mine) to avoid
// collisions.
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