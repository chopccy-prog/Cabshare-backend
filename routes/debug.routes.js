// routes/debug.routes.js
const express = require('express');
const router = express.Router();
const { optionalAuth } = require('../middleware/auth');

router.get('/__ping', (_req, res) => {
  res.json({ ok: true, where: 'debug' });
});

// Echo all headers + user
router.get('/me', optionalAuth, (req, res) => {
  res.json({
    ok: true,
    header_x_user_id: req.header('x-user-id') || null,
    user: req.user || null,
    headers_seen: req.headers,
  });
});

module.exports = router;
