// server.js (drop-in replacement)
// Works with Node 16+
// Run: npm i express cors
// Start: node server.js

const express = require('express');
const cors = require('cors');
const crypto = require('crypto');

const app = express();
app.use(cors());                 // allow phone <-> PC requests on LAN
app.use(express.json());         // parse JSON bodies

// ---------- CONFIG ----------
const PORT = process.env.PORT ? Number(process.env.PORT) : 5000;
const HOST = process.env.HOST || '0.0.0.0';

// If/when you move to Supabase, set these and use its client in the TODO sections below:
const SUPABASE_URL = process.env.SUPABASE_URL || '';
const SUPABASE_KEY = process.env.SUPABASE_KEY || '';

// ---------- IN-MEMORY STORE (replace with Supabase later) ----------
/** @type {Array<any>} */
let rides = [];

// Optional: start with a couple of seed rides so the app can search immediately
(function seed() {
  const now = new Date();
  const today = now.toISOString().slice(0, 10); // YYYY-MM-DD
  rides.push(
    {
      id: crypto.randomUUID(),
      from: 'Delhi',
      to: 'Gurgaon',
      when: `${today}T14:00:00Z`,
      seats: 3,
      price: 120,
      driver_name: 'Amit',
      driver_phone: '9999999999',
      car: 'WagonR'
    },
    {
      id: crypto.randomUUID(),
      from: 'Noida',
      to: 'Delhi',
      when: `${today}T18:30:00Z`,
      seats: 2,
      price: 90,
      driver_name: 'Neha',
      driver_phone: '8888888888',
      car: 'i20'
    }
  );
})();

// ---------- HELPERS ----------
function normalizeRideIn(body) {
  const b = body || {};

  // id / _id
  const id = (b.id || b._id || crypto.randomUUID()).toString();

  // from/to or origin/destination
  const from = (b.from || b.origin || '').toString();
  const to = (b.to || b.destination || '').toString();

  // when OR (date + time)
  let when;
  if (b.when) {
    when = new Date(b.when);
  } else if (b.date || b.time) {
    const date = (b.date || new Date().toISOString().slice(0, 10)).toString(); // YYYY-MM-DD
    const time = (b.time || '00:00').toString();                                 // HH:mm
    when = new Date(`${date}T${time}:00Z`);
  } else {
    when = new Date();
  }

  // seats / available_seats
  let seats = 0;
  if (typeof b.seats !== 'undefined') seats = Number(b.seats) || 0;
  else if (typeof b.available_seats !== 'undefined') seats = Number(b.available_seats) || 0;

  // price / amount
  let price = 0;
  if (typeof b.price !== 'undefined') price = Number(b.price) || 0;
  else if (typeof b.amount !== 'undefined') price = Number(b.amount) || 0;

  // driver info (accepts flat or nested)
  const driverName =
    (b.driver_name || b.driverName || (b.driver && b.driver.name) || '').toString();
  const driverPhone =
    (b.driver_phone || b.driverPhone || (b.driver && b.driver.phone) || '').toString();
  const car =
    (b.car || (b.driver && b.driver.car) || '').toString();

  return {
    id,
    from,
    to,
    when: when.toISOString(),
    seats,
    price,
    driver_name: driverName,
    driver_phone: driverPhone,
    car
  };
}

function filterRides(list, { from, to, date }) {
  let out = list;
  if (from) out = out.filter(r => r.from.toLowerCase().includes(from.toLowerCase()));
  if (to) out = out.filter(r => r.to.toLowerCase().includes(to.toLowerCase()));
  if (date) out = out.filter(r => (r.when || '').startsWith(date)); // compare YYYY-MM-DD prefix
  return out;
}

// ---------- ROUTES ----------
app.get('/health', (_req, res) => {
  res.json({ ok: true });
});

// Example: GET /rides?from=delhi&to=gurgaon&date=2025-08-27
app.get('/rides', (req, res) => {
  const q = {
    from: (req.query.from || req.query.origin || '').toString(),
    to: (req.query.to || req.query.destination || '').toString(),
    date: (req.query.date || '').toString(), // YYYY-MM-DD
  };

  // TODO (Supabase): select * from rides with filters
  // const { data, error } = await supabase.from('rides').select('*').match(...)

  const list = filterRides(rides, q);
  res.json({ rides: list });
});

// Example: POST /rides/search  body: { from, to, date }
app.post('/rides/search', (req, res) => {
  const q = {
    from: (req.body?.from || req.body?.origin || '').toString(),
    to: (req.body?.to || req.body?.destination || '').toString(),
    date: (req.body?.date || '').toString(),
  };

  // TODO (Supabase): same as above
  const list = filterRides(rides, q);
  res.json({ rides: list });
});

// Example: POST /rides  body: { from, to, when OR date+time, seats, price, ... }
app.post('/rides', (req, res) => {
  try {
    const normalized = normalizeRideIn(req.body || {});
    // Minimal validation
    if (!normalized.from || !normalized.to) {
      return res.status(400).json({ error: 'from and to are required' });
    }
    rides.push(normalized);

    // TODO (Supabase): insert into rides table and return saved row
    // const { data, error } = await supabase.from('rides').insert([normalized]).select().single()

    return res.status(201).json({ ride: normalized });
  } catch (e) {
    console.error('POST /rides error:', e);
    return res.status(500).json({ error: 'failed_to_create_ride' });
  }
});

// For now, return all. Later, scope by authenticated user.
app.get('/rides/mine', (_req, res) => {
  // TODO (Supabase): filter by user_id when auth is added
  res.json({ rides });
});

// ---------- START ----------
app.listen(PORT, HOST, () => {
  console.log(`Cabshare API listening at http://${HOST}:${PORT}`);
  console.log(`Health: http://${HOST}:${PORT}/health`);
});
