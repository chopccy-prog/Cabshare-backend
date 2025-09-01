// middleware/adminOnly.js
const ALLOWED_ADMIN_EMAILS = (process.env.ALLOWED_ADMIN_EMAILS || '')
  .split(',')
  .map(s => s.trim().toLowerCase())
  .filter(Boolean);

function adminOnly(req, res, next) {
  if (!req.user?.email) {
    return res.status(403).json({ error: 'Forbidden: no user email in token' });
  }
  const ok = ALLOWED_ADMIN_EMAILS.length === 0
    ? false
    : ALLOWED_ADMIN_EMAILS.includes(req.user.email.toLowerCase());
  if (!ok) return res.status(403).json({ error: 'Forbidden: not an allowed admin' });
  next();
}

module.exports = { adminOnly };
