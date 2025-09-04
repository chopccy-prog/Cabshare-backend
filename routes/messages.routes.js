// routes/messages.routes.js
const express = require('express');
const router = express.Router();
const { supabase } = require('../supabase');

// GET /messages?ride_id=&other_user_id=
router.get('/', async (req, res) => {
  try {
    const uid = req.user?.id || req.query.uid;
    if (!uid) return res.status(401).json({ error: 'unauthorized' });

    const { ride_id, other_user_id } = req.query;
    if (!ride_id || !other_user_id) {
      return res.status(400).json({ error: 'ride_id and other_user_id are required' });
    }

    const { data, error } = await supabase
      .from('messages')
      .select(`
        id, ride_id, sender_id, recipient_id, body, created_at
      `)
      .eq('ride_id', ride_id)
      .or(`and(sender_id.eq.${uid},recipient_id.eq.${other_user_id}),and(sender_id.eq.${other_user_id},recipient_id.eq.${uid})`)
      .order('created_at', { ascending: true });

    if (error) return res.status(400).json({ error: error.message });
    return res.json(data ?? []);
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

// POST /messages  { ride_id, recipient_id, body }
router.post('/', async (req, res) => {
  try {
    const uid = req.user?.id || req.body.sender_id;
    if (!uid) return res.status(401).json({ error: 'unauthorized' });

    const { ride_id, recipient_id, body } = req.body;
    if (!ride_id || !recipient_id || !body) {
      return res.status(400).json({ error: 'ride_id, recipient_id, body are required' });
    }

    const { data, error } = await supabase
      .from('messages')
      .insert({
        ride_id,
        sender_id: uid,
        recipient_id,
        body
      })
      .select(`id, ride_id, sender_id, recipient_id, body, created_at`)
      .single();

    if (error) return res.status(400).json({ error: error.message });
    return res.json(data);
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

module.exports = router;
