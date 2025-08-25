// routes/debug.routes.js
const express = require('express');
const router = express.Router();
const db = require('../config/db');
const { optionalAuth } = require('../middleware/auth');

router.get('/__ping', (_req, res) => res.json({ ok:true, where:'debug' }));

router.get('/db', async (_req, res) => {
  try {
    const { rows } = await db.query('SELECT NOW() as now');
    res.json({ ok:true, db_time: rows[0].now });
  } catch (e) { res.status(500).json({ ok:false, error:e.message }); }
});

router.get('/me', optionalAuth, (req, res) => {
  const bypass = req.query.bypass === 'true';
  const headerId = req.header('x-user-id') || null;

  if (bypass && headerId) {
    return res.json({ ok:true, mode:'bypass', user:{ id: headerId, fake:true } });
  }
  res.json({ ok:true, mode:'normal', user:req.user||null, headerId });
});

// Quick list of demo users
router.get('/ids', async (_req, res) => {
  try {
    const { rows } = await db.query(
      `SELECT id, full_name, email, role FROM users_app ORDER BY created_at DESC LIMIT 10`
    );
    res.json({ ok:true, users: rows });
  } catch (e) { res.status(500).json({ ok:false, error:e.message }); }
});

module.exports = router;
