// middleware/auth.js
const jwt = require('jsonwebtoken');

/** attachUser: decode bearer token and attach { id, email, token } if present */
function attachUser(req, _res, next) {
  const auth = req.headers['authorization'] || '';
  const parts = auth.split(' ');
  if (parts[0] === 'Bearer' && parts[1]) {
    const token = parts[1];
    try {
      const payload = jwt.decode(token) || {};
      req.user = { id: payload.sub, email: payload.email, token };
    } catch (_e) {
      req.user = undefined;
    }
  }
  next();
}

function requireAuth(req, res, next) {
  if (!req.user?.id) return res.status(401).json({ error: 'Unauthorized' });
  next();
}

module.exports = { attachUser, requireAuth };
