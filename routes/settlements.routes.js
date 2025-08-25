// routes/settlements.routes.js
const express = require('express');
const router = express.Router();
const Settlements = require('../models/settlements.model');
//const { optionalAuth } = require('../middleware/auth');
//router.use(optionalAuth); // 👈 this line

// ping
router.get('/__ping', (_req, res) => res.json({ ok: true, where: 'settlements' }));

/**
 * POST /settlements/request
 * Body: { userId, amountInr, note? }
 */
router.post('/request', async (req, res) => {
  try {
    const { userId, amountInr, note } = req.body;
    const row = await Settlements.requestSettlement({ userId, amountInr, note });
    res.status(201).json({ ok: true, settlement: row });
  } catch (e) {
    res.status(400).json({ ok: false, error: e.message });
  }
});

/**
 * GET /settlements/me?userId=...
 */
router.get('/me', async (req, res) => {
  try {
    const { userId, limit, offset } = req.query;
    const items = await Settlements.listMine({
      userId,
      limit: Number(limit) || 50,
      offset: Number(offset) || 0,
    });
    res.json({ ok: true, items });
  } catch (e) {
    res.status(400).json({ ok: false, error: e.message });
  }
});

/**
 * POST /settlements/:id/cancel
 * Body: { userId }
 */
router.post('/:id/cancel', async (req, res) => {
  try {
    const settlementId = req.params.id;
    const { userId } = req.body;
    const row = await Settlements.cancelSettlement({ settlementId, userId });
    res.json({ ok: true, settlement: row });
  } catch (e) {
    res.status(400).json({ ok: false, error: e.message });
  }
});

/**
 * POST /settlements/:id/mark-paid    (admin action)
 * Body: { adminNote? }
 */
router.post('/:id/mark-paid', async (req, res) => {
  try {
    const settlementId = req.params.id;
    const { adminNote } = req.body || {};
    const row = await Settlements.markPaid({ settlementId, adminNote });
    res.json({ ok: true, settlement: row });
  } catch (e) {
    res.status(400).json({ ok: false, error: e.message });
  }
});

// GET /settlements/mine?userId=...
router.get('/mine', async (req, res) => {
  try {
    const { userId } = req.query;
    if (!userId) return res.status(400).json({ ok: false, error: 'userId required' });
    const { rows } = await require('../config/db').query(
      `SELECT * FROM settlements WHERE user_id=$1 ORDER BY requested_at DESC LIMIT 100`,
      [userId]
    );
    res.json({ ok: true, items: rows });
  } catch (e) {
    res.status(400).json({ ok: false, error: e.message });
  }
});


module.exports = router;
