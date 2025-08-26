// routes/rides.routes.js
const express = require('express');
const router = express.Router();
const Rides = require('../models/rides.model');
//const { optionalAuth } = require('../middleware/auth');
//router.use(optionalAuth); // 👈 this line

// lightweight ping
router.get('/__ping', (_req, res) => res.json({ ok: true, where: 'rides' }));

// ---- DIAG: prove DB responds from this router ----
router.get('/search/__diag', async (_req, res) => {
  try {
    const info = await Rides.diag();
    res.json({ ok: true, ...info });
  } catch (e) {
    res.status(500).json({ ok: false, error: e.message });
  }
});

// ---- SEARCH: fast & safe ----
// GET /rides/search?routeId=<uuid>&date=YYYY-MM-DD
router.get('/search', async (req, res) => {
  const { routeId, date } = req.query;

  // simple input sanity
  if (routeId && !/^[0-9a-f-]{36}$/i.test(routeId)) {
    return res.status(400).json({ ok: false, error: 'routeId must be a UUID' });
  }
  if (date && !/^\d{4}-\d{2}-\d{2}$/.test(date)) {
    return res.status(400).json({ ok: false, error: 'date must be YYYY-MM-DD' });
  }

  const label = `RIDES_SEARCH ${routeId || '-'} ${date || '-'}`;
  console.time(label);
  try {
    const items = await Rides.search({ routeId, date });
    console.timeEnd(label);
    res.json({ ok: true, items });
  } catch (e) {
    console.timeEnd(label);
    res.status(400).json({ ok: false, error: e.message });
  }
});

// ---- CREATE (unchanged) ----
router.post('/', async (req, res) => {
  try {
    const ride = await Rides.createRide(req.body);
    res.status(201).json({ ok: true, ride });
  } catch (e) {
    res.status(400).json({ ok: false, error: e.message });
  }
});

// ---- GET BY ID ----
router.get('/:id', async (req, res) => {
  try {
    const ride = await Rides.getById(req.params.id);
    if (!ride) return res.status(404).json({ ok: false, error: 'Ride not found' });
    res.json({ ok: true, ride });
  } catch (e) {
    res.status(400).json({ ok: false, error: e.message });
  }
});

// ---- UPDATE ----
router.put('/:id', async (req, res) => {
  try {
    const ride = await Rides.updateRide(req.params.id, req.body);
    if (!ride) return res.status(404).json({ ok: false, error: 'Ride not found' });
    res.json({ ok: true, ride });
  } catch (e) {
    res.status(400).json({ ok: false, error: e.message });
  }
});

* GET /rides/search?from=...&to=...&date=YYYY-MM-DD
 * Returns { rides: [ ... ] }
 */
router.get('/search', async (req, res) => {
  const { from = '', to = '', date } = req.query;

  // TODO: replace with DB search (Supabase / Postgres etc.)
  // For now return mock results filtered by "from"/"to" contains.
  const all = [
    {
      id: 'r1',
      from: 'Delhi',
      to: 'Gurgaon',
      departure: `${date ?? new Date().toISOString().slice(0,10)}T18:30:00.000Z`,
      seats: 3,
      price: 120.0,
      driver: 'Amit',
    },
    {
      id: 'r2',
      from: 'Delhi',
      to: 'Noida',
      departure: `${date ?? new Date().toISOString().slice(0,10)}T19:15:00.000Z`,
      seats: 2,
      price: 100.0,
      driver: 'Riya',
    },
  ];

  const term = (s) => s.toString().trim().toLowerCase();
  const resList = all.filter(r =>
    (from ? term(r.from).contains(term(from)) : true) &&
    (to ? term(r.to).contains(term(to)) : true)
  );

  res.json({ rides: resList });
});


module.exports = router;
