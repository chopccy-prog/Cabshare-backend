// routes/messages.routes.js
const express = require('express');
const router = express.Router();
const { supabase } = require('../config/supabase');

function uidFromAuth(req) {
  const auth = req.headers['authorization'] || '';
  const m = /^Bearer\s+(.+)$/i.exec(auth);
  if (!m) return null;
  try {
    const payload = JSON.parse(Buffer.from(m[1].split('.')[1], 'base64url').toString('utf8'));
    return payload.sub || null;
  } catch { return null; }
}

// GET /messages
// - inbox if no params
// - thread if ride_id & other_user_id
router.get('/', async (req, res) => {
  try {
    const uid = uidFromAuth(req);
    if (!uid) return res.status(401).json({ error: 'unauthorized' });

    const { ride_id, other_user_id } = req.query;

    if (ride_id && other_user_id) {
      const { data, error } = await supabase
        .from('messages')
        .select('id, ride_id, sender_id, recipient_id, text, created_at')
        .eq('ride_id', ride_id)
        .or(`and(sender_id.eq.${uid},recipient_id.eq.${other_user_id}),and(sender_id.eq.${other_user_id},recipient_id.eq.${uid})`)
        .order('created_at', { ascending: true });

      if (error) return res.status(400).json({ error: error.message });
      return res.json({ items: data || [] });
    }

    const { data, error } = await supabase
      .from('messages')
      .select('id, ride_id, sender_id, recipient_id, text, created_at')
      .or(`sender_id.eq.${uid},recipient_id.eq.${uid}`)
      .order('created_at', { ascending: false })
      .limit(50);

    if (error) return res.status(400).json({ error: error.message });
    return res.json({ items: data || [] });
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

// POST /messages  { ride_id?, recipient_id, text }
router.post('/', async (req, res) => {
  try {
    const uid = uidFromAuth(req);
    if (!uid) return res.status(401).json({ error: 'unauthorized' });

    const b = req.body || {};
    if (!b.recipient_id || !b.text) {
      return res.status(400).json({ error: 'recipient_id and text are required' });
    }

    const { data, error } = await supabase
      .from('messages')
      .insert([{ ride_id: b.ride_id || null, sender_id: uid, recipient_id: b.recipient_id, text: b.text }])
      .select('id')
      .single();

    if (error) return res.status(400).json({ error: error.message });
    return res.json({ ok: true, id: data?.id || null });
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

module.exports = router;
