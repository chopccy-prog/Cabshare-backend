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
// --- Rides (search) ---
app.get('/rides', async (req, res) => {
  try {
    const { from, to, date, pool, driverName } = req.query;

    let q = supabase.from('rides_compat').select('*');

    if (from) q = q.ilike('from', `%${from}%`);
    if (to) q = q.ilike('to', `%${to}%`);
    if (date) q = q.gte('when', `${date}T00:00:00`).lt('when', `${date}T23:59:59`);
    // pool is currently fixed to 'private' in view; keep for later mapping
    if (driverName) q = q.ilike('driverName', `%${driverName}%`);

    const { data, error } = await q.order('when', { ascending: true });

    if (error) return fail(res, 500, error.message);
    return ok(res, data || []);
  } catch (e) {
    return fail(res, 500, e.message);
  }
});


// ---------- rides: publish (RPC app_publish_ride) ----------
// POST /rides  (publish)
// POST /rides  -> publish via RPC
app.post('/rides', async (req, res) => {
  try {
    const { from, to, when, seats, price, pool } = req.body;

    if (!from || !to || !when || !seats || price == null) {
      return fail(res, 400, 'from, to, when, seats, price are required');
    }

    const { data, error } = await supabase.rpc('publish_ride_slim', {
      p_from: from, p_to: to,
      p_when: new Date(when).toISOString(),
      p_seats: Number(seats),
      p_price: Number(price),
      p_pool: pool || 'private'
    });

    if (error) return fail(res, 500, error.message);
    return ok(res, { id: data.id }); // { id: '...' }
  } catch (e) {
    return fail(res, 500, e.message);
  }
});
// ---------- rides: book (RPC app_book_ride) ----------
app.post('/rides/:id/book', async (req, res) => {
  try {
    const rideId = req.params.id;
    const { data, error } = await supabase.rpc('api_book_ride', { p_ride_id: rideId });

    if (error) return fail(res, 500, error.message);
    return ok(res, data); // { id, seats }
  } catch (e) {
    return fail(res, 500, e.message);
  }
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

app.get('/my-rides', async (req, res) => {
  try {
    const { driverName } = req.query;
    let q = supabase.from('rides_compat').select('*');

    if (driverName) q = q.ilike('driverName', `%${driverName}%`);

    const { data, error } = await q.order('when', { ascending: false });
    if (error) return fail(res, 500, error.message);

    return ok(res, data || []);
  } catch (e) {
    return fail(res, 500, e.message);
  }
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
