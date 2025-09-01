// config/supabase.js
const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;
const SUPABASE_SERVICE_ROLE = process.env.SUPABASE_SERVICE_ROLE;

if (!SUPABASE_URL) throw new Error('Missing SUPABASE_URL in .env');
if (!SUPABASE_ANON_KEY) {
  // Fail fast with a crisp message instead of opaque stack traces
  throw new Error('Missing SUPABASE_ANON_KEY in .env (required for all user-bound DB calls)');
}

// User-scoped client: forwards Authorization so RLS runs as the user
function supabaseUserClient(jwt) {
  return createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: { headers: jwt ? { Authorization: `Bearer ${jwt}` } : {} },
    auth: { persistSession: false, autoRefreshToken: false },
  });
}

// Admin client is optional; export null if not configured
const supabaseAdmin = SUPABASE_SERVICE_ROLE
  ? createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE, { auth: { persistSession: false } })
  : null;

module.exports = { supabaseUserClient, supabaseAdmin };
