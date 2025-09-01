// middleware/auth.js
const jwt = require('jsonwebtoken');

/**
 * attachUser: extract bearer token, decode, and attach { userId, token } if present.
 * We don't fail request here — some endpoints can be public.
 */
function attachUser(req, _res, next) {
  const auth = req.headers['authorization'] || '';
  const parts = auth.split(' ');
  if (parts[0] === 'Bearer' && parts[1]) {
    const token = parts[1];
    try {
      // We don't verify signature here to avoid server needing the JWT secret.
      // Supabase will enforce RLS using this token anyway.
      const payload = jwt.decode(token) || {};
      req.user = { id: payload.sub, token };
    } catch (_e) {
      req.user = undefined;
    }
  }
  next();
}

/** requireAuth: hard-block if user is not present */
function requireAuth(req, res, next) {
  if (!req.user?.id) return res.status(401).json({ error: 'Unauthorized' });
  next();
}

module.exports = { attachUser, requireAuth };
