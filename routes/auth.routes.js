// routes/auth.routes.js
const express = require('express');
const router = express.Router();
const db = require('../config/db');
const { optionalAuth, requireAuth } = require('../middleware/auth');

router.get('/__ping', (_req, res) => res.json({ ok: true, where: 'auth' }));

/**
 * POST /auth/dev-login
 * Accepts ANY of:
 *  - JSON: { "userId": "..."} OR { "user_id": "..."} OR { "id": "..." } OR { "email": "..." }
 *  - Query: ?userId=... or ?email=...
 *  - Header: x-user-id: ...
 * Returns a hint and the header to use during dev.
 */
router.post('/dev-login', async (req, res) => {
  try {
    const body = req.body || {};
    const fromHeader = (req.header('x-user-id') || '').trim();
    const fromQuery  = (req.query.userId || req.query.id || req.query.user_id || req.query.email || '').toString().trim();
    const fromBodyId = (body.userId || body.user_id || body.id || '').toString().trim();
    const fromBodyEmail = (body.email || '').toString().trim();

    const candidate = fromBodyId || fromHeader || fromQuery || '';
    const candidateEmail = fromBodyEmail || (req.query.email ? String(req.query.email).trim() : '');

    if (!candidate && !candidateEmail) {
      return res.status(400).json({
        ok: false,
        error: 'userId (or email) required',
        howToFix: [
          'Send JSON with Content-Type: application/json',
          'Body examples:',
          '{ "userId": "<uuid>" }  OR  { "user_id": "<uuid>" }  OR  { "id": "<uuid>" }  OR  { "email": "driver@example.com" }',
        ],
        whatServerSaw: {
          headersContentType: req.headers['content-type'] || null,
          header_x_user_id: fromHeader || null,
          body: body,
          query: req.query
        }
      });
    }

    let row;
    if (candidate) {
      const { rows } = await db.query(
        `SELECT id, full_name, email, role, is_verified
           FROM users_app
          WHERE id = $1
          LIMIT 1`,
        [candidate]
      );
      row = rows[0];
    } else if (candidateEmail) {
      const { rows } = await db.query(
        `SELECT id, full_name, email, role, is_verified
           FROM users_app
          WHERE email = $1
          LIMIT 1`,
        [candidateEmail]
      );
      row = rows[0];
    }

    if (!row) {
      return res.status(404).json({
        ok: false,
        error: 'user not found',
        tried: { id: candidate || null, email: candidateEmail || null }
      });
    }

    return res.json({
      ok: true,
      hint: 'Use header "x-user-id" for dev auth on all requests.',
      user: row,
      headerExample: { 'x-user-id': row.id }
    });
  } catch (e) {
    res.status(400).json({ ok: false, error: e.message });
  }
});

/**
 * GET /auth/me
 * - Normal mode: optionalAuth + requireAuth (DB lookup)
 * - Bypass mode: /auth/me?bypass=true + header x-user-id
 */
router.get('/me', optionalAuth, (req, res) => {
  const bypass = req.query.bypass === 'true';
  const headerId = (req.header('x-user-id') || '').trim();

  if (bypass && headerId) {
    return res.json({ ok: true, mode: 'bypass', user: { id: headerId, fake: true } });
  }
  if (!req.user) return res.status(401).json({ ok: false, error: 'auth required' });
  res.json({ ok: true, mode: 'normal', user: req.user });
});

module.exports = router;
