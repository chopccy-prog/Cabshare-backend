// server.js — stable, single-mount per router
require('dotenv').config();

const express = require('express');
const cors = require('cors');
const db = require('./config/db');

const app = express();
const PORT = process.env.PORT || 5000;

// -------- middleware
// Node/Express example

app.use(cors({ origin: '*'})); // tighten later if you want

app.use(express.json());
app.use(express.urlencoded({ extended: true })); // ← allow form-encoded bodies too

// mount rides routes
app.use('/rides', require('./routes/rides')); // adjust path if different

// -------- health + db ping
app.get('/health', (_req, res) => {
  res.json({ ok: true, env: 'up', time: new Date().toISOString() });
});

app.get('/api/test', async (_req, res) => {
  try {
    const r = await db.query('SELECT NOW() AS server_time');
    res.json({ ok: true, server_time: r.rows[0].server_time });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
});

// -------- safe mounts (no double-mounts)
function safeMount(path, mountAt) {
  try {
    const routes = require(path);
    if (typeof routes === 'function') {
      app.use(mountAt, routes);
      console.log(`✅ mounted ${mountAt} -> ${path}.js`);
    } else {
      console.warn(`⚠️ ${path}.js did not export a router function. Skipping ${mountAt}.`);
    }
  } catch (e) {
    console.warn(`⚠️ failed to load ${path}.js: ${e.message}`);
  }
}

safeMount('./routes/test.routes',        '/api');
safeMount('./routes/rides.routes',       '/rides');
safeMount('./routes/bookings.routes',    '/bookings');
safeMount('./routes/wallets.routes',     '/wallets');
safeMount('./routes/deposits.routes',    '/deposits');
safeMount('./routes/settlements.routes', '/settlements');
safeMount('./routes/debug.routes',       '/debug');
// mounts
// ...
safeMount('./routes/users.routes', '/users');
safeMount('./routes/auth.routes', '/auth');



// auth routes optional later:
// safeMount('./routes/auth.routes', '/auth');

// -------- root
app.get('/', (_req, res) => res.send('Car Share Backend Running 🚗'));

// -------- safety nets
process.on('unhandledRejection', (r) => console.warn('UnhandledRejection:', r));
process.on('uncaughtException', (e) => console.error('UncaughtException:', e));

// simple in-memory "DB" while wiring UI
let RIDES = [
  {
    id: 'r1',
    driverName: 'Alex',
    origin: 'Andheri',
    destination: 'BKC',
    departureIso: new Date(Date.now() + 60 * 60 * 1000).toISOString(),
    price: 120,
    seats: 3
  },
  {
    id: 'r2',
    driverName: 'Priya',
    origin: 'Powai',
    destination: 'BKC',
    departureIso: new Date(Date.now() + 2 * 60 * 60 * 1000).toISOString(),
    price: 150,
    seats: 2
  }
];

app.get('/health', (req, res) => res.json({ ok: true }));

// GET /rides?from=..&to=..&date=YYYY-MM-DD
app.get('/rides', (req, res) => {
  const { from = '', to = '', date = '' } = req.query;
  const matches = RIDES.filter(r => {
    const byFrom = from ? r.origin.toLowerCase().includes(from.toLowerCase()) : true;
    const byTo   = to   ? r.destination.toLowerCase().includes(to.toLowerCase()) : true;
    const byDate = date ? r.departureIso.slice(0,10) === date : true;
    return byFrom && byTo && byDate;
  });
  res.json(matches);
});

// POST /rides  (publish a ride)
app.post('/rides', (req, res) => {
  const { origin, destination, departureIso, price, seats, driverName = 'You' } = req.body || {};
  if (!origin || !destination || !departureIso || !seats) {
    return res.status(400).json({ error: 'origin, destination, departureIso, seats required' });
  }
  const ride = { id: 'r' + (RIDES.length + 1), origin, destination, departureIso, price: price ?? 0, seats, driverName };
  RIDES.push(ride);
  res.status(201).json(ride);
});

// POST /rides/:id/request  (request/book)
app.post('/rides/:id/request', (req, res) => {
  const ride = RIDES.find(r => r.id === req.params.id);
  if (!ride) return res.status(404).json({ error: 'ride not found' });
  if (ride.seats <= 0) return res.status(409).json({ error: 'no seats left' });
  ride.seats -= 1;
  res.json({ ok: true, ride });
});
// -------- start
// Node/Express example

app.listen(5000, '0.0.0.0', () => console.log('API on http://0.0.0.0:5000'));

