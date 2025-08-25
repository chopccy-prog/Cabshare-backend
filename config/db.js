// config/db.js
require('dotenv').config();
const { Pool } = require('pg');

function buildPoolConfig() {
  const url = (process.env.DATABASE_URL || '').trim();
  if (url) {
    return {
      connectionString: url,
      ssl: { rejectUnauthorized: false },
      // Pool tuning (works well with PgBouncer transaction pooler)
      max: Number(process.env.PG_POOL_MAX || 10),
      idleTimeoutMillis: Number(process.env.PG_IDLE_MS || 10000),        // 10s
      connectionTimeoutMillis: Number(process.env.PG_CONN_TIMEOUT || 10000),
      keepAlive: true,
      allowExitOnIdle: false,
    };
  }

  const host = (process.env.DB_HOST || '').trim();
  const port = Number(process.env.DB_PORT || 5432);
  const database = (process.env.DB_NAME || 'postgres').trim();
  const user = (process.env.DB_USER || 'postgres').trim();
  const password = process.env.DB_PASS;

  if (!host || !database || !user) {
    throw new Error('DB env missing: DB_HOST/DB_PORT/DB_NAME/DB_USER/DB_PASS or DATABASE_URL');
  }

  return {
    host,
    port,
    database,
    user,
    password,
    ssl: { rejectUnauthorized: false },
    max: Number(process.env.PG_POOL_MAX || 10),
    idleTimeoutMillis: Number(process.env.PG_IDLE_MS || 10000),
    connectionTimeoutMillis: Number(process.env.PG_CONN_TIMEOUT || 10000),
    keepAlive: true,
    allowExitOnIdle: false,
  };
}

const poolConfig = buildPoolConfig();
console.log('🔌 DB host in use ->', poolConfig.connectionString ? '(via DATABASE_URL)' : poolConfig.host);

const pool = new Pool(poolConfig);

// IMPORTANT: swallow unexpected idle/pgbouncer errors so app doesn't crash
pool.on('error', (err) => {
  console.warn('⚠️  PG pool error (non-fatal):', err && err.message ? err.message : err);
});

// ⛔️ Remove the persistent startup connect() that can be killed by pooler.
// If you still want a startup ping, do it but ignore failure:
(async () => {
  try {
    const r = await pool.query('select 1');
    console.log('✅ DB ping ok');
  } catch (e) {
    console.warn('⚠️  Startup DB ping failed (continuing):', e.message);
  }
})();

module.exports = pool;
