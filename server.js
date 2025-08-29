// server.js
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors({ origin: true, credentials: true }));
app.use(express.json());


const rides = [];   // in-memory
const bookings = []; // optional bookings

app.get('/health', (_req, res) => res.json({ ok: true }));

// GET /rides?from=&to=&date=&driverName=
app.get('/rides', (req, res) => {
  const { from, to, date, driverName } = req.query;
  let out = [...rides];
  if (from) out = out.filter(r => r.from.toLowerCase().includes(String(from).toLowerCase()));
  if (to) out = out.filter(r => r.to.toLowerCase().includes(String(to).toLowerCase()));
  if (driverName) out = out.filter(r => r.driverName.toLowerCase() === String(driverName).toLowerCase());
  if (date) {
    const day = new Date(date);
    out = out.filter(r => {
      const d = new Date(r.when);
      return d.toDateString() === day.toDateString();
    });
  }
  res.json(out);
});

// POST /rides
app.post('/rides', (req, res) => {
  const { driverName, from, to, when, price, seats, car } = req.body || {};
  if (!from || !to) return res.status(400).json({ error: 'from and to are required' });
  if (!driverName) return res.status(400).json({ error: 'driverName is required' });
  if (!when) return res.status(400).json({ error: 'when is required (ISO date string)' });

  const id = String(Date.now());
  const ride = {
    id,
    driverName,
    from,
    to,
    when: new Date(when).toISOString(),
    price: Number(price ?? 0),
    seats: Number(seats ?? 1),
    ...(car ? { car: String(car) } : {}),
  };
  rides.push(ride);
  res.status(201).json(ride);
});

// GET /rides/:id
app.get('/rides/:id', (req, res) => {
  const r = rides.find(x => x.id === req.params.id);
  if (!r) return res.status(404).json({ error: 'not found' });
  res.json(r);
});

// POST /rides/:id/book
app.post('/rides/:id/book', (req, res) => {
  const r = rides.find(x => x.id === req.params.id);
  if (!r) return res.status(404).json({ error: 'not found' });
  bookings.push({ rideId: r.id, at: new Date().toISOString() });
  res.json({ ok: true, rideId: r.id });
});

// listen on all interfaces so your phone can reach it
const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`API listening on http://0.0.0.0:${PORT}`);
});
