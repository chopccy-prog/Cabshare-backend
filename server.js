// server.js
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const Joi = require('joi');

const app = express();
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

const PORT = process.env.PORT || 5000;
const HOST = process.env.HOST || '0.0.0.0';

// ---------------- In-memory data (swap to DB/Supabase later) ----------------
let rides = [];          // {id, from, to, when(ISO), seats, price, notes?, pool}
let conversations = [];  // {id, title, members:[string], lastText?}
let messages = [];       // {id, conversationId, from, text, ts}

// ---------------- Helpers ----------------
const ok = (res, payload) => res.json({ ok: true, ...payload });
const fail = (res, status, error) => res.status(status).json({ ok: false, error });

const makeId = (p = '') => p + Math.random().toString(36).slice(2, 10) + Date.now().toString(36);

// ---------------- Joi Schemas ----------------

// Create ride: we no longer accept phone/driverName here.
// Either send a single ISO `when`, or a `date` (YYYY-MM-DD) + `time` (HH:mm)
const rideCreateSchema = Joi.object({
  from: Joi.string().trim().min(2).required(),
  to: Joi.string().trim().min(2).required(),
  when: Joi.date().optional(),
  date: Joi.string().pattern(/^\d{4}-\d{2}-\d{2}$/).optional(),
  time: Joi.string().pattern(/^\d{2}:\d{2}$/).optional(),
  seats: Joi.number().integer().min(1).max(8).required(),
  price: Joi.number().min(0).required(),
  notes: Joi.string().max(200).allow('', null),
  pool: Joi.string().valid('private', 'commercial', 'fullcar').default('private'),
}).oxor('when', 'date')
  .with('date', 'time')
  .unknown(false);

const rideSearchSchema = Joi.object({
  from: Joi.string().allow('', null),
  to: Joi.string().allow('', null),
  date: Joi.string().pattern(/^\d{4}-\d{2}-\d{2}$/).allow('', null),
  pool: Joi.string().valid('private', 'commercial', 'fullcar').allow('', null),
  driverName: Joi.string().allow('', null), // future filter (no data yet)
}).unknown(false);

const bookParamSchema = Joi.object({
  id: Joi.string().required(),
});

const conversationCreateSchema = Joi.object({
  title: Joi.string().allow('', null),
  members: Joi.array().items(Joi.string()).min(1).required(),
}).unknown(false);

const messageCreateSchema = Joi.object({
  conversationId: Joi.string().required(),
  from: Joi.string().required(),
  text: Joi.string().min(1).required(),
}).unknown(false);

// ---------------- Health ----------------
app.get('/health', (_req, res) => ok(res, { health: 'ok' }));

// ---------------- Rides (search/list) ----------------

// This is what your Flutter client calls.
// Returns { ok: true, rides: [...] }
app.get('/search', (req, res) => {
  const { value, error } = rideSearchSchema.validate(req.query);
  if (error) return fail(res, 400, error.message);

  let result = rides.slice();

  if (value.from) {
    const f = String(value.from).toLowerCase();
    result = result.filter(r => r.from.toLowerCase().includes(f));
  }
  if (value.to) {
    const t = String(value.to).toLowerCase();
    result = result.filter(r => r.to.toLowerCase().includes(t));
  }
  if (value.date) {
    result = result.filter(r => new Date(r.when).toISOString().startsWith(value.date));
  }
  if (value.pool) {
    result = result.filter(r => r.pool === value.pool);
  }
  // driverName filter placeholder (no driverName on ride yet)
  if (value.driverName) {
    // keep for future when profile enriches rides
  }

  ok(res, { rides: result });
});

// Mirrors /search so older code that calls /rides still works
app.get('/rides', (req, res) => {
  const { value, error } = rideSearchSchema.validate(req.query);
  if (error) return fail(res, 400, error.message);

  let result = rides.slice();

  if (value.from) {
    const f = String(value.from).toLowerCase();
    result = result.filter(r => r.from.toLowerCase().includes(f));
  }
  if (value.to) {
    const t = String(value.to).toLowerCase();
    result = result.filter(r => r.to.toLowerCase().includes(t));
  }
  if (value.date) {
    result = result.filter(r => new Date(r.when).toISOString().startsWith(value.date));
  }
  if (value.pool) {
    result = result.filter(r => r.pool === value.pool);
  }
  ok(res, { rides: result });
});

// Create/publish a ride (NO phone/driverName here).
app.post('/rides', (req, res) => {
  const { value, error } = rideCreateSchema.validate(req.body);
  if (error) return fail(res, 400, error.message);

  let when = value.when ? new Date(value.when) : null;
  if (!when && value.date && value.time) {
    when = new Date(`${value.date}T${value.time}:00`);
  }
  if (!when || isNaN(when.getTime())) {
    return fail(res, 400, 'Invalid datetime');
  }

  const ride = {
    id: makeId('r_'),
    from: value.from.trim(),
    to: value.to.trim(),
    when: when.toISOString(),
    seats: value.seats,
    price: Number(value.price),
    notes: value.notes || '',
    pool: value.pool || 'private',
    createdAt: new Date().toISOString(),
    // future: ownerId/driverId/carId from auth session
  };

  rides.unshift(ride);
  ok(res, { ride });
});

// Book endpoints (support both shapes):
app.post('/book/:id', (req, res) => bookRideHandler(req, res));
app.post('/rides/:id/book', (req, res) => bookRideHandler(req, res));

function bookRideHandler(req, res) {
  const { value, error } = bookParamSchema.validate({ id: req.params.id });
  if (error) return fail(res, 400, error.message);

  const r = rides.find(x => x.id === value.id);
  if (!r) return fail(res, 404, 'Ride not found');
  if (r.seats <= 0) return fail(res, 409, 'No seats left');

  r.seats -= 1;

  // Create/find a conversation for this ride between "driver" and "rider"
  // (placeholders until auth is wired)
  let conv = conversations.find(c => c.id === `c_${r.id}`);
  if (!conv) {
    conv = {
      id: `c_${r.id}`,
      title: `Ride ${r.from} → ${r.to}`,
      members: ['driver', 'rider'], // replace with real identities later
      lastText: 'Booking created',
    };
    conversations.unshift(conv);
  }
  const msg = {
    id: makeId('m_'),
    conversationId: conv.id,
    from: 'system',
    text: 'Booking confirmed',
    ts: new Date().toISOString(),
  };
  messages.push(msg);

  ok(res, { id: r.id, seats: r.seats });
}

// ---------------- Conversations & Messages ----------------
app.get('/conversations', (req, res) => {
  const user = (req.query.user || '').toString().toLowerCase();
  let result = conversations;
  if (user) {
    result = result.filter(c =>
      (c.members || []).some(m => m.toLowerCase().includes(user))
    );
  }
  ok(res, { conversations: result });
});

app.post('/conversations', (req, res) => {
  const { value, error } = conversationCreateSchema.validate(req.body);
  if (error) return fail(res, 400, error.message);
  const conv = {
    id: makeId('c_'),
    title: value.title || 'Conversation',
    members: value.members,
    lastText: '',
  };
  conversations.unshift(conv);
  ok(res, { conversation: conv });
});

app.get('/messages', (req, res) => {
  const conversationId = (req.query.conversationId || '').toString();
  if (!conversationId) return fail(res, 400, 'conversationId required');
  const ms = messages.filter(m => m.conversationId === conversationId);
  ok(res, { messages: ms });
});

app.post('/messages', (req, res) => {
  const { value, error } = messageCreateSchema.validate(req.body);
  if (error) return fail(res, 400, error.message);

  const msg = {
    id: makeId('m_'),
    conversationId: value.conversationId,
    from: value.from,
    text: value.text,
    ts: new Date().toISOString(),
  };
  messages.push(msg);

  const c = conversations.find(x => x.id === value.conversationId);
  if (c) c.lastText = value.text;

  ok(res, { message: msg });
});

// ---------------- Start ----------------
app.listen(PORT, HOST, () => {
  console.log(`API listening at http://${HOST}:${PORT}`);
});
