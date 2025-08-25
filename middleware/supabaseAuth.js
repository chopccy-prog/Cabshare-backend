// middleware/supabaseAuth.js
// Minimal auth: prefer x-user-id, optionally read sub from Bearer token.
// No network calls, no jsonwebtoken dependency.

function decodeJwtSubMaybe(authHeader) {
  try {
    if (!authHeader || !authHeader.startsWith('Bearer ')) return null;
    const token = authHeader.slice('Bearer '.length);
    const parts = token.split('.');
    if (parts.length < 2) return null;
    const json = Buffer.from(parts[1], 'base64').toString('utf8');
    const payload = JSON.parse(json);
    return payload.sub || null;
  } catch {
    return null;
  }
}

function optional(req, _res, next) {
  const h = req.headers;
  const uid =
    h['x-user-id'] ||
    h['X-User-Id'] ||
    decodeJwtSubMaybe(h.authorization);

  req.auth = { userId: uid || null }; // not required
  next();
}

function required(req, res, next) {
  const h = req.headers;
  const uid =
    h['x-user-id'] ||
    h['X-User-Id'] ||
    decodeJwtSubMaybe(h.authorization);

  if (!uid) {
    return res.status(401).json({ ok: false, error: 'auth required (send x-user-id)' });
  }
  req.auth = { userId: uid };
  next();
}

module.exports = { optional, required };
