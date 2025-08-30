// server.js  — Supabase-backed API keeping the existing JSON shape
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const Joi = require('joi');
const { createClient } = require('@supabase/supabase-js');

const app = express();
app.use(helmet());
app.use(cors({ origin: process.env.CORS_ORIGIN?.split(',') ?? true }));
app.use(express.json());

const PORT = process.env.PORT || 5000;
const HOST = process.env.HOST || '0.0.0.0';

const supabase = createClient(
  process.env.SUPABASE_URL,
  // Use SERVICE_ROLE for server-side writes (keep it secret!)
  process.env.SUPABASE_SERVICE_ROLE,
  { auth: { persistSession: false } }
);

// ---------- Validation ----------
const rideCreateSchema = Joi.object({
  from: Joi.string().min(1).required(),
  to: Joi.string().min(1).required(),
  when: Joi.string().isoDate().required(), // ISO string
  seats: Joi.number().integer().min(1).max(8).required(),
  price: Joi.number().min(0).required(),
  pool: Joi.string().valid('private','commercial','fullcar').default('private'),
  // Linked via profile later; allow but not required to keep older clients harmless
  driverName: Joi.string().allow('', null),
  driverPhone: Joi.string().allow('', null),
}).unknown(false);

const rideSearchSchema = Joi.object({
  from: Joi.string().allow('', null),
  to: Joi.string().allow('', null),
  date: Joi.string().pattern(/^\d{4}-\d{2}-\d{2}$/).allow('', null),
  pool: Joi.string().valid('private','commercial','fullcar').allow('', null),
  driverName: Joi.string().allow('', null),
}).unknown(true);

const messageCreateSchema = Joi.object({
  conversationId: Joi.string().required(),
  from: Joi.string().min(1).required(),
  text: Joi.string().min(1).required(),
}).unknown(false);

// ---------- Helpers ----------
const ok = (res, data) => res.json({ ok: true, data });
const fail = (res, status, error) => res.status(status).json({ ok: false, error });

const mapRideRow = (r) => ({
  id: r.id,
  from: r.from_place,
  to: r.to_place,
  when: r.when_at,              // ISO string from Supabase
  seats: r.seats,
  price: typeof r.price === 'string' ? Number(r.price) : r.price,
  driverName: r.driver_name ?? null,
  driverPhone: r.driver_phone ?? null,
  booked: r.booked,
  pool: r.pool,
});
const mapConversationRow = (c) => ({
  id: c.id,
  title: c.title,
  members: c.members ?? [],
  lastText: c.last_text ?? '',
});
const mapMessageRow = (m) => ({
  id: m.id,
  conversationId: m.conversation_id,
  from: m.sender,
  text: m.text,
  ts: m.ts,
});

// ---------- Health ----------
app.get('/health', (_req, res) => ok(res, { ok: true }));

// ---------- Rides ----------
app.get('/rides', async (req, res) => {
  const { value, error } = rideSearchSchema.validate(req.query);
  if (error) return fail(res, 400, error.message);

  let q = supabase.from('rides')
    .select('*')
    .order('when_at', { ascending: false });

  if (value.from) q = q.ilike('from_place', `%${value.from}%`);
  if (value.to) q = q.ilike('to_place', `%${value.to}%`);
  if (value.pool) q = q.eq('pool', value.pool);
  if (value.date) q = q.gte('when_at', `${value.date}T00:00:00.000Z`).lte('when_at', `${value.date}T23:59:59.999Z`);
  if (value.driverName) q = q.ilike('driver_name', `%${value.driverName}%`);

  const { data, error: err } = await q;
  if (err) return fail(res, 500, err.message);

  ok(res, (data ?? []).map(mapRideRow));
});

app.post('/rides', async (req, res) => {
  const { value, error } = rideCreateSchema.validate(req.body);
  if (error) return fail(res, 400, error.message);

  const row = {
    from_place: value.from,
    to_place: value.to,
    when_at: new Date(value.when).toISOString(),
    seats: value.seats,
    price: value.price,
    driver_name: value.driverName || null,
    driver_phone: value.driverPhone || null,
    booked: false,
    pool: value.pool || 'private',
  };

  const { data, error: err } = await supabase.from('rides').insert(row).select().single();
  if (err) return fail(res, 500, err.message);

  ok(res, mapRideRow(data));
});

// NOTE: For production, make this atomic via SQL function (included in SQL below).
app.post('/rides/:id/book', async (req, res) => {
  const rideId = req.params.id;

  // 1) Fetch
  const { data: r, error: e1 } = await supabase.from('rides').select('*').eq('id', rideId).single();
  if (e1) return fail(res, 404, 'Ride not found');
  if (!r || r.seats <= 0) return fail(res, 409, 'No seats left');

  // 2) Update with seats-1
  const { data: updated, error: e2 } = await supabase
    .from('rides')
    .update({ seats: r.seats - 1, booked: r.seats - 1 <= 0 })
    .eq('id', rideId)
    .select()
    .single();
  if (e2) return fail(res, 500, e2.message);

  // 3) Ensure conversation exists for this ride
  let convId;
  {
    const { data: conv } = await supabase
      .from('conversations')
      .select('*')
      .eq('ride_id', rideId)
      .maybeSingle();

    if (conv) {
      convId = conv.id;
    } else {
      const title = `Ride ${r.from_place} → ${r.to_place} (${r.driver_name ?? 'driver'})`;
      const members = [r.driver_name ?? 'driver', 'rider']; // Replace with real user IDs after Auth
      const { data: created, error: e3 } = await supabase
        .from('conversations')
        .insert({ ride_id: rideId, title, members, last_text: 'Booking created' })
        .select()
        .single();
      if (e3) return fail(res, 500, e3.message);
      convId = created.id;
    }
  }

  // 4) System message
  await supabase.from('messages').insert({
    conversation_id: convId,
    sender: 'system',
    text: 'Booking confirmed',
  });

  ok(res, { id: updated.id, seats: updated.seats });
});

app.get('/my-rides', async (req, res) => {
  const { value, error } = rideSearchSchema.validate(req.query);
  if (error) return fail(res, 400, error.message);

  let q = supabase.from('rides').select('*').order('when_at', { ascending: false });
  if (value.driverName) q = q.ilike('driver_name', `%${value.driverName}%`);

  const { data, error: err } = await q;
  if (err) return fail(res, 500, err.message);
  ok(res, (data ?? []).map(mapRideRow));
});

// ---------- Conversations & Messages ----------
app.get('/conversations', async (req, res) => {
  const user = (req.query.user || '').toString().trim();
  let q = supabase.from('conversations').select('*').order('created_at', { ascending: false });

  if (user) {
    // exact member match: members array contains user string
    q = q.contains('members', [user]);
  }

  const { data, error } = await q;
  if (error) return fail(res, 500, error.message);
  ok(res, (data ?? []).map(mapConversationRow));
});

app.post('/conversations', async (req, res) => {
  const schema = Joi.object({
    title: Joi.string().allow('', null),
    members: Joi.array().items(Joi.string()).min(1).required(),
    rideId: Joi.string().allow('', null),
  });
  const { value, error } = schema.validate(req.body);
  if (error) return fail(res, 400, error.message);

  const { data, error: err } = await supabase
    .from('conversations')
    .insert({
      title: value.title || 'Conversation',
      members: value.members,
      ride_id: value.rideId || null,
    })
    .select()
    .single();

  if (err) return fail(res, 500, err.message);
  ok(res, mapConversationRow(data));
});

app.get('/messages', async (req, res) => {
  const conversationId = (req.query.conversationId || '').toString();
  if (!conversationId) return fail(res, 400, 'conversationId required');

  const { data, error } = await supabase
    .from('messages')
    .select('*')
    .eq('conversation_id', conversationId)
    .order('ts', { ascending: true });

  if (error) return fail(res, 500, error.message);
  ok(res, (data ?? []).map(mapMessageRow));
});

app.post('/messages', async (req, res) => {
  const { value, error } = messageCreateSchema.validate(req.body);
  if (error) return fail(res, 400, error.message);

  const { data, error: err } = await supabase
    .from('messages')
    .insert({ conversation_id: value.conversationId, sender: value.from, text: value.text })
    .select()
    .single();
  if (err) return fail(res, 500, err.message);

  // update lastText on conversation
  await supabase.from('conversations').update({ last_text: value.text }).eq('id', value.conversationId);

  ok(res, mapMessageRow(data));
});

app.listen(PORT, HOST, () => {
  console.log(`API listening at http://${HOST}:${PORT}`);
});
