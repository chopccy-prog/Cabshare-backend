// routes/messages.routes.js
const express = require('express');
const router = express.Router();
const { supabase } = require('../config/supabase');
const { getUserIdFromAuth } = require('../config/auth');

// GET /messages
// - If ride_id & other_user_id given -> return that conversation thread
// - Else -> return inbox (latest messages where user is sender/recipient)
router.get('/', async (req, res) => {
  try {
    const uid = getUserIdFromAuth(req);
    if (!uid) return res.status(401).json({ error: 'unauthorized' });

    const { ride_id, other_user_id } = req.query;

    if (ride_id && other_user_id) {
      // Conversation thread
      const { data, error } = await supabase
        .from('messages')
        .select('id, ride_id, sender_id, recipient_id, text, created_at')
        .eq('ride_id', ride_id)
        .or(`and(sender_id.eq.${uid},recipient_id.eq.${other_user_id}),and(sender_id.eq.${other_user_id},recipient_id.eq.${uid})`)
        .order('created_at', { ascending: true });

      if (error) return res.status(400).json({ error: error.message });
      return res.json({ items: data || [] });
    }

    // Inbox list (last 50 messages involving me)
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

// POST /messages  { ride_id, recipient_id, text }
router.post('/', async (req, res) => {
  try {
    const uid = getUserIdFromAuth(req);
    if (!uid) return res.status(401).json({ error: 'unauthorized' });

    const { ride_id, recipient_id, text } = req.body || {};
    if (!recipient_id || !text) {
      return res.status(400).json({ error: 'recipient_id and text are required' });
    }

    const { data, error } = await supabase
      .from('messages')
      .insert([{ ride_id: ride_id || null, sender_id: uid, recipient_id, text }])
      .select('id')
      .single();

    if (error) return res.status(400).json({ error: error.message });
    return res.json({ ok: true, id: data?.id || null });
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

module.exports = router;
