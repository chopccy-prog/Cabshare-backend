// routes/users.routes.js
// Fix for "argument handler must be a function": export a function(router) OR a router object.
// Here we export a router object.
const router = require('express').Router();
const { supabaseUserClient } = require('../config/supabase');

router.get('/me', async (req, res) => {
  const jwt = req.user?.token;
  const sb = supabaseUserClient(jwt);
  if (!jwt) return res.status(401).json({ error: 'Unauthorized' });
  // read profile by auth uid
  const { data: profile, error } = await sb.from('profiles').select('*').eq('id', req.user.id).single();
  if (error) return res.status(500).json({ error: error.message });
  res.json({ profile });
});

module.exports = router;
