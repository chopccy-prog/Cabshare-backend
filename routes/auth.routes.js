// routes/auth.routes.js
const express = require('express');
const router = express.Router();
const db = require('../config/db');

// ---- SAFE AUTH WRAPPERS
let opt = null, reqd = null;
try {
  const auth = require('../middleware/auth');
  if (auth && typeof auth.optionalAuth === 'function') opt = auth.optionalAuth;
  if (auth && typeof auth.requireAuth === 'function') reqd = auth.requireAuth;
} catch { /* ignore */ }

const optionalAuth = opt || ((req, _res, next) => { req.user = req.user || null; next(); });
const requireAuth = reqd || ((req, res, next) => {
  if (!req.user) return res.status(401).json({ ok: false, error: 'auth required (x-user-id header)' });
  next();
});

// ---- ROUTES
router.get('/__ping', (_req, res) => res.json({ ok: true, where: 'auth' }));

// Dev login – returns a usable header
router.post('/dev-login', async (req, res) => {
  try {
    const { userId } = req.body || {};
    if (!userId) return res.status(400).json({ ok: false, error: 'userId required' });

    const { rows } = await db.query(
      `SELECT id, full_name, email, role, is_verified
       FROM users_app WHERE id = $1`,
      [userId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ ok: false, error: 'user not found' });
    }

    res.json({
      ok: true,
      hint: 'Send header "x-user-id" with this value on all requests',
      user: rows[0],
      headerExample: { 'x-user-id': rows[0].id }
    });
  } catch (e) {
    res.status(400).json({ ok: false, error: e.message });
  }
});

// Who am I
router.get('/me', optionalAuth, requireAuth, (req, res) => {
  res.json({ ok: true, user: req.user });
});

module.exports = router;
