// routes/users.routes.js
const express = require('express');
const router = express.Router();
const db = require('../config/db');

// ---- SAFE AUTH WRAPPERS (won't crash if middleware/auth exports differ)
let opt = null, reqd = null;
try { 
  const auth = require('../middleware/auth');
  if (auth && typeof auth.optionalAuth === 'function') opt = auth.optionalAuth;
  if (auth && typeof auth.requireAuth === 'function') reqd = auth.requireAuth;
} catch { /* ignore require errors */ }

// no-op optional auth (attaches null user) if not provided
const optionalAuth = opt || (function(req, _res, next) { req.user = req.user || null; next(); });
// strict auth if not provided -> 401
const requireAuth = reqd || (function(req, res, _next) {
  if (!req.user) return res.status(401).json({ ok:false, error:'auth required (x-user-id header)' });
  res.locals.__safeAuth = true; // marker
  return _next();
});

// ---- ROUTES
router.get('/__ping', (_req, res) => res.json({ ok: true, where: 'users' }));

router.get('/me', optionalAuth, requireAuth, (req, res) => {
  res.json({ ok: true, user: req.user });
});

router.get('/me/wallet', optionalAuth, requireAuth, async (req, res) => {
  try {
    const { rows } = await db.query(
      `SELECT balance_available_inr, balance_reserved_inr, updated_at
         FROM wallets WHERE user_id = $1`,
      [req.user.id]
    );
    res.json({
      ok: true,
      summary: rows[0] || { balance_available_inr: 0, balance_reserved_inr: 0, updated_at: null }
    });
  } catch (e) { res.status(400).json({ ok:false, error:e.message }); }
});

router.get('/me/bookings', optionalAuth, requireAuth, async (req, res) => {
  try {
    const { rows } = await db.query(
      `SELECT * FROM bookings WHERE rider_id = $1
       ORDER BY created_at DESC LIMIT 200`,
      [req.user.id]
    );
    res.json({ ok:true, items: rows });
  } catch (e) { res.status(400).json({ ok:false, error:e.message }); }
});

router.get('/me/deposits', optionalAuth, requireAuth, async (req, res) => {
  try {
    const { rows } = await db.query(
      `SELECT * FROM deposit_intents WHERE user_id = $1
       ORDER BY created_at DESC LIMIT 200`,
      [req.user.id]
    );
    res.json({ ok:true, items: rows });
  } catch (e) { res.status(400).json({ ok:false, error:e.message }); }
});

router.get('/me/settlements', optionalAuth, requireAuth, async (req, res) => {
  try {
    const { rows } = await db.query(
      `SELECT * FROM settlements WHERE user_id = $1
       ORDER BY requested_at DESC LIMIT 200`,
      [req.user.id]
    );
    res.json({ ok:true, items: rows });
  } catch (e) { res.status(400).json({ ok:false, error:e.message }); }
});

router.get('/me/rides', optionalAuth, requireAuth, async (req, res) => {
  try {
    const { rows } = await db.query(
      `SELECT * FROM rides WHERE driver_id = $1
       ORDER BY created_at DESC LIMIT 200`,
      [req.user.id]
    );
    res.json({ ok:true, items: rows });
  } catch (e) { res.status(400).json({ ok:false, error:e.message }); }
});

module.exports = router; // <-- must export the router function
