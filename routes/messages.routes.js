// routes/messages.routes.js
const express = require('express');
const router = express.Router();
const { supabase } = require('../supabase');

function getUserId(req) {
  return (
    req.header('x-user-id') ||
    req.header('x-user') ||
    (req.user && req.user.id) ||
    null
  );
}

// GET /messages  → last 100 messages involving me
router.get('/', async (req, res) => {
  try {
    const me = getUserId(req);
    if (!me) return res.status(401).json({ error: 'unauthorized' });

    const { data, error } = await supabase
      .from('messages')
      .select('*')
      .or(`sender_id.eq.${me},recipient_id.eq.${me}`)
      .order('created_at', { ascending: false })
      .limit(100);

    if (error) return res.status(400).json({ error: error.message });
    return res.json(data || []);
  } catch (e) {
    return res.status(500).json({ error: `${e}` });
  }
});

// GET /messages/thread?ride_id=&other_user_id=
router.get('/thread', async (req, res) => {
  try {
    const me = getUserId(req);
    if (!me) return res.status(401).json({ error: 'unauthorized' });

    const rideId = req.query.ride_id;
    const other = req.query.other_user_id;

    let q = supabase.from('messages').select('*');
    if (rideId) q = q.eq('ride_id', rideId);

    q = q.or(
      `and(sender_id.eq.${me},recipient_id.eq.${other}),and(sender_id.eq.${other},recipient_id.eq.${me})`
    );
    q = q.order('created_at', { ascending: true });

    const { data, error } = await q;
    if (error) return res.status(400).json({ error: error.message });
    return res.json(data || []);
  } catch (e) {
    return res.status(500).json({ error: `${e}` });
  }
});

// POST /messages  { ride_id, recipient_id, text }
router.post('/', async (req, res) => {
  try {
    const me = getUserId(req);
    if (!me) return res.status(401).json({ error: 'unauthorized' });

    const { ride_id, recipient_id, text } = req.body || {};
    if (!recipient_id || !text)
      return res
        .status(400)
        .json({ error: 'recipient_id and text are required' });

    const { data, error } = await supabase
      .from('messages')
      .insert({
        ride_id: ride_id ?? null,
        sender_id: me,
        recipient_id,
        text,
      })
      .select('*')
      .single();

    if (error) return res.status(400).json({ error: error.message });
    return res.json(data);
  } catch (e) {
    return res.status(500).json({ error: `${e}` });
  }
});

module.exports = router;
