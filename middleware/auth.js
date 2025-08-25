// middleware/auth.js
const db = require('../config/db');

// Optional: attach user if x-user-id header exists
async function optionalAuth(req, _res, next) {
  const userId = (req.header('x-user-id') || '').trim();
  if (!userId) { req.user = null; return next(); }

  try {
    const { rows } = await db.query(
      `SELECT id, full_name, email, role, is_verified
         FROM users_app WHERE id = $1`,
      [userId]
    );
    req.user = rows[0] || null;
    next();
  } catch (err) {
    next(err);
  }
}

// Require user
function requireAuth(req, res, next) {
  if (!req.user) {
    return res.status(401).json({
      ok: false,
      error: 'auth required (x-user-id header)'
    });
  }
  next();
}

module.exports = { optionalAuth, requireAuth };
