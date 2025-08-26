// server.js
// Minimal Express API for Cabshare — rides publish/search/book.
// Works locally and from phone on same Wi-Fi.

const express = require('express');
const cors = require('cors');
const { v4: uuid } = require('uuid');
const dayjs = require('dayjs');

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors({ origin: true }));
app.use(express.json());

app.get('/health', (_req, res) => res.json({ ok: true }));

// In-memory store for now — swap to DB/Supabase later.
let rides = [];

/**
 * Publish a ride
 * body: { from, to, date: 'YYYY-MM-DD', time: 'HH:mm', seats, price, driverName?, vehicle?, notes? }
 */
app.post('/rides', (req, res) => {
  const { from, to, date, time, seats, price, driverName, vehicle, notes } = req.body || {};
  if (!from || !to || !date || !time || !seats) {
    return res.status(400).json({ error: 'from, to, date, time, seats are required' });
  }
  const dateTime = dayjs(`${date} ${time}`).toISOString();
  const ride = {
    id: uuid(),
    from,
    to,
    dateTime,
    seatsAvailable: Number(seats),
    price: Number(price || 0),
    driverName: driverName || 'Host',
    vehicle: vehicle || '',
    notes: notes || '',
    cashbackOnCancelPercent: 25,
    createdAt: new Date().toISOString(),
  };
  rides.push(ride);
  res.status(201).json(ride);
});

/**
 * Search rides
 * body: { from?, to?, date?: 'YYYY-MM-DD' }
 */
app.post('/rides/search', (req, res) => {
  const { from, to, date } = req.body || {};
  const qFrom = (from || '').trim().toLowerCase();
  const qTo = (to || '').trim().toLowerCase();
  const day = date ? dayjs(date) : null;

  const items = rides.filter((r) =>
    (!qFrom || r.from.toLowerCase().includes(qFrom)) &&
    (!qTo || r.to.toLowerCase().includes(qTo)) &&
    (!day || dayjs(r.dateTime).isSame(day, 'day'))
  );

  res.json({ items });
});

/**
 * Book seats
 * body: { seats: number, userName?: string }
 */
app.post('/rides/:id/book', (req, res) => {
  const { id } = req.params;
  const { seats = 1, userName = 'Guest' } = req.body || {};
  const ride = rides.find((r) => r.id === id);
  if (!ride) return res.status(404).json({ error: 'Ride not found' });

  const n = Number(seats);
  if (ride.seatsAvailable < n) return res.status(400).json({ error: 'Not enough seats' });

  ride.seatsAvailable -= n;
  res.json({ ok: true, ride, booked: { seats: n, userName } });
});

app.get('/rides/:id', (req, res) => {
  const ride = rides.find((r) => r.id === req.params.id);
  if (!ride) return res.status(404).json({ error: 'Ride not found' });
  res.json(ride);
});

app.get('/rides', (_req, res) => res.json({ items: rides }));

app.listen(PORT, '0.0.0.0', () => {
  console.log(`API listening at http://0.0.0.0:${PORT}`);
});
