// middleware/auth.js
const db = require('../config/db');

/**
 * optionalAuth
 * - Reads x-user-id header.
 * - If absent → req.user = null.
 * - If present → attaches user from DB (or null if not found).
 */
async function optionalAuth(req, _res, next) {
  const userId = (req.header('x-user-id') || '').trim();
  if (!userId) {
    req.user = null;
    return next();
  }

  try {
    const { rows } = await db.query(
      `SELECT id, full_name, email, role, is_verified
       FROM users_app WHERE id = $1`,
      [userId]
    );
    req.user = rows[0] || null;
    return next();
  } catch (err) {
    return next(err);
  }
}

/**
 * requireAuth
 * - Ensures req.user is set (by optionalAuth).
 * - Returns 401 if not authenticated.
 */
function requireAuth(req, res, next) {
  if (!req.user) {
    return res.status(401).json({
      ok: false,
      error: 'auth required (x-user-id header)'
    });
  }
  return next();
}

module.exports = { optionalAuth, requireAuth };
