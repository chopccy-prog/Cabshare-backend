// routes/bookings.routes.js
const express = require('express');
const router = express.Router();
const Bookings = require('../models/bookings.model');
//const { optionalAuth } = require('../middleware/auth');
//router.use(optionalAuth); // 👈 this line

const db = require('../config/db');
const { required: requireAuth, optional: optionalAuth } = require('../middleware/supabaseAuth');

router.get('/__ping', (_req, res) => res.json({ ok: true, where: 'bookings' }));

// === NEW: list my bookings ===
// GET /bookings/mine?as=rider|driver&limit=20&offset=0
// - as=rider  -> bookings where rider_id = me
// - as=driver -> bookings on rides that I (driver) own
router.get('/mine', requireAuth, async (req, res) => {
  try {
    const me = req.user?.id;
    const as = (req.query.as || 'rider').toLowerCase();
    const limit = Math.min(parseInt(req.query.limit || '20', 10), 100);
    const offset = Math.max(parseInt(req.query.offset || '0', 10), 0);

    if (as === 'driver') {
      const { rows } = await db.query(
        `SELECT b.*
           FROM bookings b
           JOIN rides r ON r.id = b.ride_id
          WHERE r.driver_id = $1
          ORDER BY b.created_at DESC
          LIMIT $2 OFFSET $3`,
        [me, limit, offset]
      );
      return res.json({ ok: true, items: rows, as });
    } else {
      const { rows } = await db.query(
        `SELECT *
           FROM bookings
          WHERE rider_id = $1
          ORDER BY created_at DESC
          LIMIT $2 OFFSET $3`,
        [me, limit, offset]
      );
      return res.json({ ok: true, items: rows, as: 'rider' });
    }
  } catch (e) {
    res.status(400).json({ ok: false, error: e.message });
  }
});

// Rider creates booking (auth required)
router.post('/', requireAuth, async (req, res) => {
  try {
    const { rideId, riderId, fromStopId, toStopId, seatsBooked } = req.body;
    const effectiveRiderId = riderId || req.user?.id;
    const booking = await Bookings.createBooking({
      rideId, riderId: effectiveRiderId, fromStopId, toStopId, seatsBooked
    });
    res.status(201).json({ ok: true, booking });
  } catch (e) {
    res.status(400).json({ ok: false, error: e.message });
  }
});

// Driver accepts pending (auth required)
router.post('/:bookingId/accept', requireAuth, async (req, res) => {
  try {
    const { bookingId } = req.params;
    const driverId = req.user?.id;
    const booking = await Bookings.acceptBooking({ bookingId, driverId });
    res.json({ ok: true, booking });
  } catch (e) {
    res.status(400).json({ ok: false, error: e.message });
  }
});

// Driver rejects pending (auth required)
router.post('/:bookingId/reject', requireAuth, async (req, res) => {
  try {
    const { bookingId } = req.params;
    const driverId = req.user?.id;
    const booking = await Bookings.rejectBooking({ bookingId, driverId });
    res.json({ ok: true, booking });
  } catch (e) {
    res.status(400).json({ ok: false, error: e.message });
  }
});

// Cancel (rider or driver) (auth required)
router.post('/:bookingId/cancel', requireAuth, async (req, res) => {
  try {
    const { bookingId } = req.params;
    const { actor } = req.body; // 'rider' | 'driver'
    const result = await Bookings.cancelBooking({ bookingId, actor, actorId: req.user?.id });
    res.json({ ok: true, ...result });
  } catch (e) {
    res.status(400).json({ ok: false, error: e.message });
  }
});

module.exports = router;
