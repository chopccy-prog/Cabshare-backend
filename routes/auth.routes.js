// middleware/auth.js
const db = require('../config/db');

async function optionalAuth(req, _res, next) {
  const userId = req.header('x-user-id');
  if (!userId) { req.user = null; return next(); }
  try {
    const { rows } = await db.query(
      `SELECT id, full_name, email, role, is_verified FROM users_app WHERE id = $1`,
      [userId]
    );
    req.user = rows[0] || null;
    next();
  } catch (e) { next(e); }
}

function requireAuth(req, res, next) {
  if (!req.user) return res.status(401).json({ ok:false, error:'auth required (x-user-id header)' });
  next();
}

module.exports = { optionalAuth, requireAuth };
