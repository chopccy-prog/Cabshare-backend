// routes/debug.routes.js
const router = require('express').Router();
router.get('/ping', (_req, res) => res.json({ ok: true, now: new Date().toISOString() }));
module.exports = router;
