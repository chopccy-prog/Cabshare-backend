// config/auth.js
function getUserIdFromAuth(req) {
  // Prefer Supabase JWT in Authorization header (Bearer <jwt>)
  const auth = req.headers['authorization'] || '';
  const m = /^Bearer\s+(.+)$/i.exec(auth);
  if (!m) return null;

  try {
    // Supabase JWT is base64url. The middle part payload has "sub" = user id
    const payloadB64 = m[1].split('.')[1];
    const payloadJson = Buffer.from(payloadB64, 'base64url').toString('utf8');
    const payload = JSON.parse(payloadJson);
    return payload.sub || null;
  } catch (_) {
    return null;
  }
}

module.exports = { getUserIdFromAuth };
