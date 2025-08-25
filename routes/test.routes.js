// routes/test.routes.js
const express = require('express');
const router = express.Router();
const db = require('../config/db');

// Simple DB ping: SELECT NOW()
router.get('/test', async (_req, res) => {
  try {
    const r = await db.query('SELECT NOW() AS server_time');
    return res.json({ ok: true, server_time: r.rows[0].server_time });
  } catch (e) {
    return res.status(500).json({ ok: false, error: e.message });
  }
});

module.exports = router;