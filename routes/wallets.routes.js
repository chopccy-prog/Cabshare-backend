// routes/wallets.routes.js
const express = require('express');
const router = express.Router();
const Wallets = require('../models/wallets.model');

// If you have middleware/auth.js, this will allow anonymous OR authed calls safely.
// If you don't have it yet, you can comment these two lines.
// eslint-disable-next-line @typescript-eslint/no-var-requires
const { optionalAuth } = require('../middleware/auth') || {};
if (typeof optionalAuth === 'function') {
  router.use(optionalAuth); // does NOT block if token missing; just attaches req.user when present
}

// Lightweight ping
router.get('/__ping', (_req, res) => res.json({ ok: true, where: 'wallets' }));

// POST /wallets/credit  { userId, amount, note }
router.post('/credit', async (req, res) => {
  try {
    const { userId, amount, note } = req.body;
    if (!userId) return res.status(400).json({ ok: false, error: 'userId required' });
    const amt = Number(amount);
    if (!Number.isFinite(amt) || amt <= 0) return res.status(400).json({ ok: false, error: 'amount must be > 0' });

    await Wallets.credit(userId, amt, note);
    const s = await Wallets.summary(userId);
    res.json({ ok: true, summary: s });
  } catch (e) {
    res.status(400).json({ ok: false, error: e.message });
  }
});

// GET /wallets/summary?userId=...
router.get('/summary', async (req, res) => {
  try {
    const { userId } = req.query;
    if (!userId) return res.status(400).json({ ok: false, error: 'userId required' });
    const s = await Wallets.summary(userId);
    res.json({ ok: true, summary: s });
  } catch (e) {
    res.status(400).json({ ok: false, error: e.message });
  }
});

module.exports = router;
