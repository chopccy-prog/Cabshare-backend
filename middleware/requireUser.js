// middleware/requireUser.js
module.exports = function requireUser(req, res, next) {
  const userId =
    req.get('x-user-id') ||
    req.get('X-User-Id') ||
    (req.user && req.user.id);

  if (!userId) {
    return res.status(401).json({
      ok: false,
      error: 'Missing x-user-id header (dev mode).'
    });
  }

  req.userId = userId;
  next();
};
