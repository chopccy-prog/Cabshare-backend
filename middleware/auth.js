// middleware/auth.js
const jwt = require('jsonwebtoken');

/**
 * Modes:
 *  - AUTH_MODE=dev:   read x-user-id (UUID) header
 *  - AUTH_MODE=jwt:   read Authorization: Bearer <JWT>
 *        - If SUPABASE_JWT_SECRET is set -> verify HS256
 *        - Else, decode without verify (NOT for production)
 */
function authMiddleware(req, res, next) {
  const mode = (process.env.AUTH_MODE || 'dev').toLowerCase();

  if (mode === 'dev') {
    const id = req.header('x-user-id');
    if (!id) return res.status(401).json({ ok: false, error: 'Missing x-user-id in dev mode' });
    req.user = { id };
    return next();
  }

  // jwt mode
  const h = req.header('authorization') || '';
  const m = h.match(/^Bearer\s+(.+)$/i);
  if (!m) return res.status(401).json({ ok: false, error: 'Missing Bearer token' });

  const token = m[1];

  try {
    if (process.env.SUPABASE_JWT_SECRET) {
      const decoded = jwt.verify(token, process.env.SUPABASE_JWT_SECRET);
      req.user = { id: decoded.sub || decoded.user_id || decoded.uid || decoded.id };
      if (!req.user.id) throw new Error('JWT missing sub');
    } else {
      // fallback (not secure): decode without verifying so you can keep moving
      const decoded = jwt.decode(token) || {};
      req.user = { id: decoded.sub || decoded.user_id || decoded.uid || decoded.id };
      if (!req.user.id) throw new Error('Unverified JWT missing sub');
    }
    return next();
  } catch (e) {
    return res.status(401).json({ ok: false, error: `Auth failed: ${e.message}` });
  }
}

module.exports = authMiddleware;
