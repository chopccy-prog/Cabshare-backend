// server.js
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const Joi = require('joi');

const app = express();
app.use(helmet());
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 5000;
const HOST = process.env.HOST || '0.0.0.0';

// --- In-memory stores (swap to Supabase later) ---
let rides = [];      // {id, from, to, when, seats, price, driverName, driverPhone?, booked, pool}
let conversations = []; // {id, title, members:[...], lastText?}
let messages = [];      // {id, conversationId, from, text, ts}

// --- Schemas ---
const rideCreateSchema = Joi.object({
  from: Joi.string().min(1).required(),
  to: Joi.string().min(1).required(),
  when: Joi.string().isoDate().required(),
  seats: Joi.number().integer().min(1).max(8).required(),
  price: Joi.number().min(0).required(),
  driverName: Joi.string().min(1).required(),
  driverPhone: Joi.string().allow('', null),
  pool: Joi.string().valid('private','commercial','commercial_private').default('private'),
});

const rideSearchSchema = Joi.object({
  from: Joi.string().allow('', null),
  to: Joi.string().allow('', null),
  date: Joi.string().pattern(/^\d{4}-\d{2}-\d{2}$/).allow('', null),
  pool: Joi.string().valid('private','commercial','commercial_private').allow('', null),
  driverName: Joi.string().allow('', null),
});

const bookSchema = Joi.object({
  id: Joi.string().required(),
});

const conversationCreateSchema = Joi.object({
  title: Joi.string().allow('', null),
  members: Joi.array().items(Joi.string()).min(1).required(),
});

const messageCreateSchema = Joi.object({
  conversationId: Joi.string().required(),
  from: Joi.string().required(),
  text: Joi.string().min(1).required(),
});

// --- Helpers ---
const ok = (res, data) => res.json({ ok: true, data });
const fail = (res, status, error) => res.status(status).json({ ok: false, error });

// --- Health ---
app.get('/health', (_req, res) => ok(res, { ok: true }));

// --- Rides ---
app.get('/rides', (req, res) => {
  const { value, error } = rideSearchSchema.validate(req.query);
  if (error) return fail(res, 400, error.message);

  let result = rides.slice();

  if (value.from) {
    const f = value.from.toLowerCase();
    result = result.filter(r => r.from.toLowerCase().includes(f));
  }
  if (value.to) {
    const t = value.to.toLowerCase();
    result = result.filter(r => r.to.toLowerCase().includes(t));
  }
  if (value.date) {
    result = result.filter(r => (new Date(r.when)).toISOString().startsWith(value.date));
  }
  if (value.pool) {
    result = result.filter(r => r.pool === value.pool);
  }
  if (value.driverName) {
    const d = value.driverName.toLowerCase();
    result = result.filter(r => r.driverName.toLowerCase().includes(d));
  }

  ok(res, result);
});

app.post('/rides', (req, res) => {
  const { value, error } = rideCreateSchema.validate(req.body);
  if (error) return fail(res, 400, error.message);

  const id = String(Date.now());
  const ride = {
    id,
    from: value.from,
    to: value.to,
    when: new Date(value.when).toISOString(),
    seats: value.seats,
    price: value.price,
    driverName: value.driverName,
    driverPhone: value.driverPhone || null,
    booked: false,
    pool: value.pool || 'private',
  };
  rides.unshift(ride);

  // Auto-create conversation between driver and a “rider” later (on booking)
  ok(res, ride);
});

app.post('/rides/:id/book', (req, res) => {
  const { value, error } = bookSchema.validate({ id: req.params.id });
  if (error) return fail(res, 400, error.message);

  const r = rides.find(x => x.id === value.id);
  if (!r) return fail(res, 404, 'Ride not found');
  if (r.seats <= 0) return fail(res, 409, 'No seats left');

  r.seats -= 1;
  r.booked = true;

  // If there’s no conversation yet, create one with driver (and placeholder rider)
  let conv = conversations.find(c => c.title === `Ride ${r.id}`);
  if (!conv) {
    conv = {
      id: `c_${r.id}`,
      title: `Ride ${r.from} → ${r.to} (${r.driverName})`,
      members: [r.driverName, 'rider'], // replace with real identities when auth ready
      lastText: 'Booking created',
    };
    conversations.unshift(conv);
  }
  messages.push({
    id: `m_${Date.now()}`,
    conversationId: conv.id,
    from: 'system',
    text: 'Booking confirmed',
    ts: new Date().toISOString(),
  });

  ok(res, { id: r.id, seats: r.seats });
});

app.get('/my-rides', (req, res) => {
  const { value, error } = rideSearchSchema.validate(req.query);
  if (error) return fail(res, 400, error.message);
  let result = rides.slice();
  if (value.driverName) {
    const d = value.driverName.toLowerCase();
    result = result.filter(r => r.driverName.toLowerCase().includes(d));
  }
  ok(res, result);
});

// --- Conversations & Messages ---
app.get('/conversations', (req, res) => {
  const user = (req.query.user || '').toString().toLowerCase();
  let result = conversations;
  if (user) {
    result = result.filter(c => (c.members || []).some(m => m.toLowerCase().includes(user)));
  }
  ok(res, result);
});

app.post('/conversations', (req, res) => {
  const { value, error } = conversationCreateSchema.validate(req.body);
  if (error) return fail(res, 400, error.message);
  const conv = {
    id: `c_${Date.now()}`,
    title: value.title || 'Conversation',
    members: value.members,
    lastText: '',
  };
  conversations.unshift(conv);
  return ok(res, conv);
});

app.get('/messages', (req, res) => {
  const conversationId = (req.query.conversationId || '').toString();
  if (!conversationId) return fail(res, 400, 'conversationId required');
  const ms = messages.filter(m => m.conversationId === conversationId);
  ok(res, ms);
});

app.post('/messages', (req, res) => {
  const { value, error } = messageCreateSchema.validate(req.body);
  if (error) return fail(res, 400, error.message);

  const msg = {
    id: `m_${Date.now()}`,
    conversationId: value.conversationId,
    from: value.from,
    text: value.text,
    ts: new Date().toISOString(),
  };
  messages.push(msg);

  const c = conversations.find(x => x.id === value.conversationId);
  if (c) c.lastText = value.text;

  ok(res, msg);
});

app.listen(PORT, HOST, () => {
  console.log(`API listening at http://${HOST}:${PORT}`);
});
