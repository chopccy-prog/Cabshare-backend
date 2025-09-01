// config/supabase.js
const { createClient } = require('@supabase/supabase-js');

// Use service role if you have it (admin UI needs this). For app APIs, anon is fine.
const SUPABASE_URL = process.env.SUPABASE_URL;
const SERVICE_ROLE  = process.env.SUPABASE_SERVICE_ROLE || '';
const ANON_KEY      = process.env.SUPABASE_ANON_KEY || '';

if (!SUPABASE_URL) {
  console.warn('⚠️ SUPABASE_URL not set');
}
if (!SERVICE_ROLE && !ANON_KEY) {
  console.warn('⚠️ SUPABASE keys not set');
}

// Prefer service role when present (admin endpoints), otherwise anon.
// (Your RLS-secured public app routes work fine with anon.)
const supabase = createClient(
  SUPABASE_URL,
  SERVICE_ROLE || ANON_KEY,
  { auth: { persistSession: false } }
);

module.exports = { supabase };
