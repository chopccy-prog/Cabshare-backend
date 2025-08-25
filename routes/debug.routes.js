// routes/debug.routes.js
const express = require('express');
const router = express.Router();
const db = require('../config/db');

// quick ping
router.get('/ping', (_req, res) => res.json({ ok: true, where: 'debug' }));

// return handy IDs to use in Postman tests
router.get('/ids', async (_req, res) => {
  try {
    const { rows: drivers } = await db.query(
      `SELECT id, full_name, email, role
         FROM users_app
        WHERE role = 'driver'
        ORDER BY created_at DESC
        LIMIT 5`
    );

    const { rows: riders } = await db.query(
      `SELECT id, full_name, email, role
         FROM users_app
        WHERE role IN ('rider','passenger')  -- handle either enum label
        ORDER BY created_at DESC
        LIMIT 5`
    );

    const { rows: routes } = await db.query(
      `SELECT id, code, from_city_id, to_city_id
         FROM routes
        ORDER BY created_at DESC
        LIMIT 5`
    );

    const { rows: stops } = await db.query(
      `SELECT s.id, s.name, c.name AS city
         FROM stops s
         JOIN cities c ON c.id = s.city_id
        ORDER BY city, s.name
        LIMIT 20`
    );

    const { rows: rides } = await db.query(
      `SELECT id, driver_id, route_id, depart_date, depart_time,
              seats_total, seats_available, allow_auto_confirm
         FROM rides
        ORDER BY created_at DESC
        LIMIT 5`
    );

    res.json({ ok: true, drivers, riders, routes, stops, rides });
  } catch (e) {
    res.status(500).json({ ok: false, error: e.message });
  }
});

module.exports = router;
