// server.js — Supabase-backed API using RPCs + compat views

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const Joi = require('joi');

const app = express();
app.use(helmet());
app.use(express.json({ limit: '1mb' }));

// CORS
const allow = (process.env.CORS_ORIGIN || '').split(',').map(s => s.trim()).filter(Boolean);
app.use(cors({
  origin: (origin, cb) => {
    if (!origin || allow.length === 0 || allow.includes(origin)) return cb(null, true);
    return cb(new Error('Not allowed by CORS'));
  }
}));

const PORT = process.env.PORT || 5000;
const HOST = process.env.HOST || '0.0.0.0';

const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('[ENV] Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: { persistSession: false },
});



// ---------- helpers ----------
const ok   = (res, data)           => res.json({ ok: true, data });
const fail = (res, status, error)  => res.status(status).json({ ok: false, error });

// ---------- schemas ----------
const rideSearchSchema = Joi.object({
  from: Joi.string().allow('', null),
  to: Joi.string().allow('', null),
  date: Joi.string().pattern(/^\d{4}-\d{2}-\d{2}$/).allow('', null),
  pool: Joi.string().valid('private','commercial','commercial_private').allow('', null), // view currently 'private'
  driverName: Joi.string().allow('', null)
});

const rideCreateSchema = Joi.object({
  from: Joi.string().min(1).required(),
  to: Joi.string().min(1).required(),
  when: Joi.string().isoDate().required(), // app sends ISO string
  seats: Joi.number().integer().min(1).max(8).required(),
  price: Joi.number().integer().min(0).required(),
  pool: Joi.string().valid('private','commercial','commercial_private').default('private')
});

const bookSchema = Joi.object({
  id: Joi.string().uuid().required()
});

const messageCreateSchema = Joi.object({
  conversationId: Joi.string().uuid().required(),
  from: Joi.string().uuid().allow(null), // sender_id (uuid) | keep null for now
  text: Joi.string().min(1).required()
});

// ---------- health ----------
app.get('/health', (_req, res) => ok(res, { ok: true }));

// ---------- rides: search ----------
app.get('/rides', async (req, res) => {
  const { value, error } = rideSearchSchema.validate(req.query);
  if (error) return fail(res, 400, error.message);

  // Base select from compat view
  let q = supabase.from('rides_compat').select('*');

  // Simple client-side style filters: we’ll fetch then filter if needed.
  // (Supabase ilike on views is fine too; we’ll do it server-side to keep it simple)
  const { data, error: err } = await q;
  if (err) return fail(res, 500, err.message);

  let list = data || [];

  if (value.from) {
    const f = value.from.toLowerCase();
    list = list.filter(r => (r.from || '').toLowerCase().includes(f));
  }
  if (value.to) {
    const t = value.to.toLowerCase();
    list = list.filter(r => (r.to || '').toLowerCase().includes(t));
  }
  if (value.date) {
    list = list.filter(r => {
      // r.when is timestamp (string); compare YYYY-MM-DD prefix
      const iso = new Date(r.when).toISOString().slice(0, 10);
      return iso === value.date;
    });
  }
  if (value.pool) {
    // View currently returns 'private' — keep filter for future when pool is real
    list = list.filter(r => (r.pool || 'private') === value.pool);
  }
  if (value.driverName) {
    const d = value.driverName.toLowerCase();
    list = list.filter(r => (r.driverName || '').toLowerCase().includes(d));
  }

  ok(res, list);
});

// ---------- rides: publish (RPC app_publish_ride) ----------
// POST /rides  (publish)
app.post('/rides', async (req, res) => {
  try {
    const { from, to, when, seats, price, pool } = req.body;

    // basic shape check (you already have Joi; keep if you like)
    if (!from || !to || !when || !seats || !price) {
      return fail(res, 400, 'from, to, when, seats, price are required');
    }

    const { data, error } = await supabase.rpc('publish_ride_simple', {
      _from: from,
      _to: to,
      _when: new Date(when).toISOString(),
      _seats: Number(seats),
      _price: Number(price),
      _pool: pool || 'private',
      _driver: null // or pass a real driver UUID if you have auth context
    });

    if (error) {
      console.error('publish_ride_simple error:', error);
      return fail(res, 500, error.message || 'publish failed');
    }

    // publish_ride_simple returns a rowset; we want the single row
    const row = Array.isArray(data) ? data[0] : data;

    // Keep the frontend contract:
    // { ok:true, data:{id, from, to, when, seats, price, pool, booked} }
    return ok(res, row);
  } catch (e) {
    console.error(e);
    return fail(res, 500, 'unexpected error');
  }
});


// ---------- rides: book (RPC app_book_ride) ----------
app.post('/rides/:id/book', async (req, res) => {
  const { value, error } = bookSchema.validate({ id: req.params.id });
  if (error) return fail(res, 400, error.message);

  const { data, error: err } = await supabase.rpc('app_book_ride', { p_ride_id: value.id });
  if (err) {
    // Keep same semantics as earlier (404 if not found, 409 no seats)
    if (err.message && /not found/i.test(err.message)) return fail(res, 404, 'Ride not found');
    if (err.message && /No seats left/i.test(err.message)) return fail(res, 409, 'No seats left');
    return fail(res, 500, err.message);
  }
  const row = Array.isArray(data) ? data[0] : data;
  ok(res, row);
});

// ---------- conversations ----------
app.get('/conversations', async (req, res) => {
  // You have conversations.members uuid[]; for now, return all (filtering by user can be added when auth is in place)
  const { data, error } = await supabase.from('conversations')
    .select('*')
    .order('created_at', { ascending: false });
  if (error) return fail(res, 500, error.message);
  ok(res, data || []);
});

// ---------- messages (read) ----------
app.get('/messages', async (req, res) => {
  const conversationId = (req.query.conversationId || '').toString();
  if (!conversationId) return fail(res, 400, 'conversationId required');

  const { data, error } = await supabase
    .from('messages_compat')
    .select('*')
    .eq('conversation_id', conversationId)
    .order('ts', { ascending: true });

  if (error) return fail(res, 500, error.message);
  ok(res, data || []);
});

// ---------- messages (create) ----------
app.post('/messages', async (req, res) => {
  const { value, error } = messageCreateSchema.validate(req.body);
  if (error) return fail(res, 400, error.message);

  // Insert into real messages table with "conversation_id"
  const insert = {
    conversation_id: value.conversationId,
    sender_id: value.from || null,
    text: value.text
  };

  const { data, error: err } = await supabase
    .from('messages')
    .insert(insert)
    .select('*')
    .single();

  if (err) return fail(res, 500, err.message);

  // Return the compat shape (normalize conversation_id)
  // easiest: re-select from compat view by id
  const { data: compat, error: err2 } = await supabase
    .from('messages_compat')
    .select('*')
    .eq('id', data.id)
    .single();

  if (err2) return fail(res, 500, err2.message);
  ok(res, compat);
});

// ---------- start ----------
app.listen(PORT, HOST, () => {
  console.log(`API listening at http://${HOST}:${PORT}`);
});
