// server.js — stable, single-mount per router
require('dotenv').config();

const express = require('express');
const cors = require('cors');
const db = require('./config/db');

const app = express();
const PORT = process.env.PORT || 5000;

// -------- middleware
app.use(cors());
app.use(express.json());


// -------- health + db ping
app.get('/health', (_req, res) => {
  res.json({ ok: true, env: 'up', time: new Date().toISOString() });
});

app.get('/api/test', async (_req, res) => {
  try {
    const r = await db.query('SELECT NOW() AS server_time');
    res.json({ ok: true, server_time: r.rows[0].server_time });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
});

// -------- safe mounts (no double-mounts)
function safeMount(path, mountAt) {
  try {
    const routes = require(path);
    if (typeof routes === 'function') {
      app.use(mountAt, routes);
      console.log(`✅ mounted ${mountAt} -> ${path}.js`);
    } else {
      console.warn(`⚠️ ${path}.js did not export a router function. Skipping ${mountAt}.`);
    }
  } catch (e) {
    console.warn(`⚠️ failed to load ${path}.js: ${e.message}`);
  }
}

safeMount('./routes/test.routes',        '/api');
safeMount('./routes/rides.routes',       '/rides');
safeMount('./routes/bookings.routes',    '/bookings');
safeMount('./routes/wallets.routes',     '/wallets');
safeMount('./routes/deposits.routes',    '/deposits');
safeMount('./routes/settlements.routes', '/settlements');
safeMount('./routes/debug.routes',       '/debug');
// mounts
// ...
safeMount('./routes/users.routes', '/users');
safeMount('./routes/auth.routes', '/auth');


// auth routes optional later:
// safeMount('./routes/auth.routes', '/auth');

// -------- root
app.get('/', (_req, res) => res.send('Car Share Backend Running 🚗'));

// -------- safety nets
process.on('unhandledRejection', (r) => console.warn('UnhandledRejection:', r));
process.on('uncaughtException', (e) => console.error('UncaughtException:', e));

// -------- start
app.listen(PORT, () => {
  if (process.env.DATABASE_URL) {
    try { console.log('DB host via DATABASE_URL:', new URL(process.env.DATABASE_URL).hostname); } catch {}
  }
  console.log(`Server running on port ${PORT}`);
});
