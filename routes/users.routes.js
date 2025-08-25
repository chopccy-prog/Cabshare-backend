// routes/users.routes.js
const express = require('express');
const router = express.Router();
const db = require('../config/db');
const { optionalAuth, requireAuth } = require('../middleware/auth');

router.get('/__ping', (_req, res) => res.json({ ok:true, where:'users' }));

// Who am I (with bypass)
router.get('/me', optionalAuth, (req, res) => {
  const bypass = req.query.bypass === 'true';
  const headerId = (req.header('x-user-id') || '').trim();

  if (bypass && headerId) {
    return res.json({ ok:true, mode:'bypass', user:{ id: headerId, fake:true } });
  }
  if (!req.user) return res.status(401).json({ ok:false, error:'auth required' });
  res.json({ ok:true, mode:'normal', user:req.user });
});

// My wallet
router.get('/me/wallet', optionalAuth, requireAuth, async (req, res) => {
  try {
    const { rows } = await db.query(
      `SELECT balance_available_inr, balance_reserved_inr, updated_at
         FROM wallets WHERE user_id=$1`,
      [req.user.id]
    );
    res.json({ ok:true, summary: rows[0] || { balance_available_inr:0, balance_reserved_inr:0 } });
  } catch (e) {
    res.status(400).json({ ok:false, error:e.message });
  }
});

// Bookings
router.get('/me/bookings', optionalAuth, requireAuth, async (req, res) => {
  try {
    const { rows } = await db.query(
      `SELECT * FROM bookings WHERE rider_id=$1 ORDER BY created_at DESC LIMIT 200`,
      [req.user.id]
    );
    res.json({ ok:true, items: rows });
  } catch (e) { res.status(400).json({ ok:false, error:e.message }); }
});

// Deposits
router.get('/me/deposits', optionalAuth, requireAuth, async (req, res) => {
  try {
    const { rows } = await db.query(
      `SELECT * FROM deposit_intents WHERE user_id=$1 ORDER BY created_at DESC LIMIT 200`,
      [req.user.id]
    );
    res.json({ ok:true, items: rows });
  } catch (e) { res.status(400).json({ ok:false, error:e.message }); }
});

// Settlements
router.get('/me/settlements', optionalAuth, requireAuth, async (req, res) => {
  try {
    const { rows } = await db.query(
      `SELECT * FROM settlements WHERE user_id=$1 ORDER BY requested_at DESC LIMIT 200`,
      [req.user.id]
    );
    res.json({ ok:true, items: rows });
  } catch (e) { res.status(400).json({ ok:false, error:e.message }); }
});

// Rides (as driver)
router.get('/me/rides', optionalAuth, requireAuth, async (req, res) => {
  try {
    const { rows } = await db.query(
      `SELECT * FROM rides WHERE driver_id=$1 ORDER BY created_at DESC LIMIT 200`,
      [req.user.id]
    );
    res.json({ ok:true, items: rows });
  } catch (e) { res.status(400).json({ ok:false, error:e.message }); }
});

module.exports = router;
