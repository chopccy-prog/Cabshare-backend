// routes/deposits.routes.js
const express = require('express');
const router = express.Router();
const Deposits = require('../models/deposits.model');
//const { optionalAuth } = require('../middleware/auth');
//router.use(optionalAuth); // 👈 this line

console.log('Deposits exports:', Object.keys(Deposits || {}));

// Ping
router.get('/__ping', (_req, res) => res.json({ ok: true, where: 'deposits' }));

// Create deposit intent
router.post('/create', async (req, res) => {
  try {
    const { userId, amountInr, method, notes } = req.body;
    const row = await Deposits.createIntent({ userId, amountInr, method, notes });
    res.status(201).json({ ok: true, deposit: row });
  } catch (e) {
    res.status(400).json({ ok: false, error: e.message });
  }
});

// Helper to complete a deposit (manual)
async function completeManualHandler(req, res) {
  try {
    const { id } = req.params;
    const { note } = req.body || {};

    const row = typeof Deposits.completeManual === 'function'
      ? await Deposits.completeManual({ depositId: id, note })
      : await Deposits.markPaid({ intentId: id, adminNote: note || 'manual complete' });

    res.json({ ok: true, deposit: row });
  } catch (e) {
    res.status(400).json({ ok: false, error: e.message });
  }
}

// === Aliases (any of these will work) ===
router.post('/:id/complete-manual', completeManualHandler);  // you tried this
router.post('/:id/complete',        completeManualHandler);  // simple alias
router.post('/:id/manual-complete', completeManualHandler);  // swapped order
router.post('/:id/mark-paid',       async (req, res) => {    // existing endpoint
  try {
    const { id } = req.params;
    const { adminNote } = req.body || {};
    const row = await Deposits.markPaid({ intentId: id, adminNote });
    res.json({ ok: true, deposit: row });
  } catch (e) {
    res.status(400).json({ ok: false, error: e.message });
  }
});

// Update status (failed/cancelled/expired)
router.post('/:id/status', async (req, res) => {
  try {
    const { id } = req.params;
    const { status, adminNote } = req.body || {};
    const row = await Deposits.markStatus({ intentId: id, status, adminNote });
    res.json({ ok: true, deposit: row });
  } catch (e) {
    res.status(400).json({ ok: false, error: e.message });
  }
});

// List mine
router.get('/me', async (req, res) => {
  try {
    const { userId, limit, offset } = req.query;
    const items = await Deposits.listMine({ userId, limit, offset });
    res.json({ ok: true, items });
  } catch (e) {
    res.status(400).json({ ok: false, error: e.message });
  }
});

module.exports = router;
