// supabase.js
const { createClient } = require('@supabase/supabase-js');
const url = process.env.SUPABASE_URL;
const key = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;
if (!url || !key) throw new Error('Missing SUPABASE_URL / key');
const supabase = createClient(url, key, { auth: { persistSession: false } });
module.exports = { supabase };
