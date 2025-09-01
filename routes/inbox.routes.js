// routes/inbox.routes.js
const router = require('express').Router();
const { supabaseUserClient } = require('../config/supabase');
const { requireAuth } = require('../middleware/auth');

// GET /inbox
router.get('/', requireAuth, async (req, res) => {
  const jwt = req.user?.token;
  const sb = supabaseUserClient(jwt);

  // conversations where current user is a member (uuid in array column)
  const { data, error } = await sb
    .from('conversations')
    .select('*')
    .contains('members', [req.user.id])
    .order('created_at', { ascending: false });

  if (error) return res.status(500).json({ error: error.message });
  res.json({ items: data || [] });
});

// GET /inbox/:conversation_id/messages
router.get('/:cid/messages', requireAuth, async (req, res) => {
  const jwt = req.user?.token;
  const sb = supabaseUserClient(jwt);
  const cid = req.params.cid;

  const { data, error } = await sb
    .from('messages_compat')
    .select('*')
    .eq('conversation_id', cid)
    .order('ts', { ascending: true });

  if (error) return res.status(500).json({ error: error.message });
  res.json({ items: data || [] });
});

// POST /inbox/:conversation_id/messages
router.post('/:cid/messages', requireAuth, async (req, res) => {
  const jwt = req.user?.token;
  const sb = supabaseUserClient(jwt);
  const cid = req.params.cid;
  const text = (req.body?.text || '').toString().slice(0, 2000);

  const { data, error } = await sb
    .from('messages')
    .insert({ conversation_id: cid, sender_id: req.user.id, text })
    .select('*')
    .single();

  if (error) return res.status(400).json({ error: error.message });
  res.json({ message: data });
});

module.exports = router;
