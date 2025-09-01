/**
 * Cabshare Backend (Drop-in)
 * - Express API that forwards Supabase user JWT to DB (RLS enforced)
 * - Minimal, production-ready structure for rides, bookings, inbox, admin
 * ENV:
 *  - PORT=3000
 *  - SUPABASE_URL=...
 *  - SUPABASE_ANON_KEY=...            (client anon key for user-bound ops)
 *  - SUPABASE_SERVICE_ROLE=...        (service role for admin/maintenance only)
 *  - CORS_ORIGIN=http://localhost:5173,http://localhost:3000,http://localhost:8080
 */
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const path = require('path');
const bodyParser = require('body-parser');
const { supabaseUserClient, supabaseAdmin } = require('./config/supabase');
const { requireAuth, attachUser } = require('./middleware/auth');

const app = express();

const allowedOrigins = (process.env.CORS_ORIGIN || '').split(',').map(s => s.trim()).filter(Boolean);
app.use(cors({
  origin: function (origin, cb) {
    if (!origin || allowedOrigins.length === 0 || allowedOrigins.includes(origin)) return cb(null, true);
    return cb(new Error('Not allowed by CORS: ' + origin));
  },
  credentials: true
}));
app.use(bodyParser.json({ limit: '1mb' }));
app.use(morgan('dev'));
app.get('/health', (_req, res) => res.json({ ok: true }));
app.use(express.static(path.join(__dirname, 'public')));
// Optional: convenience redirect
app.get('/admin-ui', (_req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'admin.html'));
});

// Health
app.get('/api', (req, res) => res.json({ ok: true, name: 'Cabshare API', ts: new Date().toISOString() }));

// Mount routes
app.use('/rides', attachUser, require('./routes/rides.routes'));
app.use('/bookings', attachUser, require('./routes/bookings.routes'));
app.use('/inbox', attachUser, require('./routes/inbox.routes'));
app.use('/admin', attachUser, requireAuth, require('./routes/admin.routes')); // admin-like tasks
app.use('/users', attachUser, require('./routes/users.routes'));
app.use('/debug', attachUser, require('./routes/debug.routes'));

// near the bottom where app.listen is called:
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server listening on http://0.0.0.0:${PORT}`);
});