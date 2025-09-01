const router = require('express').Router();
const { requireAuth } = require('../middleware/auth');
const { supabaseUserClient } = require('../config/supabase');

router.use(requireAuth);

// list latest threads (group by ride + other user)
router.get('/', async (req, res) => {
  const sb = supabaseUserClient(req.user.token);

  const { data, error } = await sb
    .from('messages')
    .select('*')
    .or(`sender_id.eq.${req.user.id},recipient_id.eq.${req.user.id}`)
    .order('created_at', { ascending: false })
    .limit(200);
  if (error) return res.status(400).json({ error: error.message });

  const threads = [];
  const seen = new Set();
  for (const m of data || []) {
    const other = m.sender_id === req.user.id ? m.recipient_id : m.sender_id;
    const key = `${m.ride_id || 'none'}:${other}`;
    if (seen.has(key)) continue;
    seen.add(key);
    threads.push({
      ride_id: m.ride_id,
      other_user_id: other,
      last_text: m.text,
      last_at: m.created_at,
    });
  }
  res.json({ items: threads });
});

// list messages with a user for a ride
router.get('/:rideId/messages', async (req, res) => {
  const sb = supabaseUserClient(req.user.token);
  const rideId = req.params.rideId;
  const other = (req.query.with || '').toString();
  if (!rideId || !other) return res.status(400).json({ error: 'rideId and ?with=<userId> required' });

  const { data, error } = await sb
    .from('messages')
    .select('*')
    .eq('ride_id', rideId)
    .or(`and(sender_id.eq.${req.user.id},recipient_id.eq.${other}),and(sender_id.eq.${other},recipient_id.eq.${req.user.id})`)
    .order('created_at', { ascending: true });
  if (error) return res.status(400).json({ error: error.message });

  res.json({ items: data || [] });
});

// send message
router.post('/:rideId/messages', async (req, res) => {
  const sb = supabaseUserClient(req.user.token);
  const rideId = req.params.rideId;
  const { to, text } = req.body || {};
  if (!to || !text) return res.status(400).json({ error: 'to, text required' });

  const { data, error } = await sb
    .from('messages')
    .insert({ ride_id: rideId || null, sender_id: req.user.id, recipient_id: to, text })
    .select('*')
    .single();
  if (error) return res.status(400).json({ error: error.message });

  res.json({ message: data });
});

module.exports = router;
