// routes/admin.routes.js
const router = require('express').Router();
const { supabaseAdmin } = require('../config/supabase');
const { requireAuth } = require('../middleware/auth');
const { adminOnly } = require('../middleware/adminOnly');

// Block whole router if service role is missing
router.use((req, res, next) => {
  if (!supabaseAdmin) {
    return res.status(503).json({ error: 'Admin API disabled: SUPABASE_SERVICE_ROLE not set.' });
  }
  next();
});

// You must be logged in AND email must be in ALLOWED_ADMIN_EMAILS
router.use(requireAuth, adminOnly);

// --- Cities ---
router.get('/cities', async (_req, res) => {
  const { data, error } = await supabaseAdmin.from('cities').select('*').order('name', { ascending: true });
  if (error) return res.status(500).json({ error: error.message });
  res.json({ items: data || [] });
});

router.post('/cities', async (req, res) => {
  const { name } = req.body || {};
  if (!name) return res.status(400).json({ error: 'name is required' });
  const { data, error } = await supabaseAdmin.from('cities')
    .upsert({ name }, { onConflict: 'name' }).select('*').single();
  if (error) return res.status(400).json({ error: error.message });
  res.json({ city: data });
});

// --- Routes ---
router.get('/routes', async (_req, res) => {
  const { data, error } = await supabaseAdmin.from('routes').select('*').order('code', { ascending: true });
  if (error) return res.status(500).json({ error: error.message });
  res.json({ items: data || [] });
});

router.post('/routes', async (req, res) => {
  const { code, from_city_id, to_city_id, distance_km } = req.body || {};
  if (!code || !from_city_id || !to_city_id) return res.status(400).json({ error: 'code, from_city_id, to_city_id required' });
  const { data, error } = await supabaseAdmin.from('routes')
    .insert({ code, from_city_id, to_city_id, distance_km: distance_km ?? 0 })
    .select('*').single();
  if (error) return res.status(400).json({ error: error.message });
  res.json({ route: data });
});

// --- Stops ---
router.get('/stops', async (_req, res) => {
  const { data, error } = await supabaseAdmin.from('stops').select('*').order('name', { ascending: true });
  if (error) return res.status(500).json({ error: error.message });
  res.json({ items: data || [] });
});

router.post('/stops', async (req, res) => {
  const { name, lat, lon, city_id } = req.body || {};
  if (!name || !city_id) return res.status(400).json({ error: 'name, city_id required' });
  const { data, error } = await supabaseAdmin.from('stops')
    .insert({ name, lat, lon, city_id })
    .select('*').single();
  if (error) return res.status(400).json({ error: error.message });
  res.json({ stop: data });
});

router.post('/route-stops', async (req, res) => {
  const { route_id, stop_id, rank } = req.body || {};
  if (!route_id || !stop_id) return res.status(400).json({ error: 'route_id, stop_id required' });
  const { data, error } = await supabaseAdmin.from('route_stops')
    .insert({ route_id, stop_id, rank: rank ?? 1 })
    .select('*').single();
  if (error) return res.status(400).json({ error: error.message });
  res.json({ routeStop: data });
});

// --- Seed helper: upsert Nashik, Pune, Mumbai + 3 routes ---
router.post('/seed-basic', async (_req, res) => {
  try {
    const cities = ['Nashik', 'Pune', 'Mumbai'];

    // Upsert cities
    const { data: upCities, error: cErr } = await supabaseAdmin.from('cities')
      .upsert(cities.map(name => ({ name })), { onConflict: 'name' })
      .select('*');
    if (cErr) throw cErr;

    const byName = {};
    (upCities || []).forEach(c => { byName[c.name] = c; });
    if (!byName.Nashik || !byName.Pune || !byName.Mumbai) {
      return res.status(500).json({ error: 'Failed to ensure cities exist' });
    }

    // Upsert routes
    const routes = [
      { code: 'NSK-PNQ', from_city_id: byName['Nashik'].id, to_city_id: byName['Pune'].id, distance_km: 210 },
      { code: 'PNQ-BOM', from_city_id: byName['Pune'].id,   to_city_id: byName['Mumbai'].id, distance_km: 150 },
      { code: 'BOM-NSK', from_city_id: byName['Mumbai'].id, to_city_id: byName['Nashik'].id, distance_km: 170 },
    ];
    // Avoid duplicate codes
    for (const r of routes) {
      const { error: rErr } = await supabaseAdmin.from('routes')
        .upsert(r, { onConflict: 'code' });
      if (rErr) throw rErr;
    }

    res.json({ ok: true, cities: upCities?.length ?? 0, routes: 3 });
  } catch (e) {
    res.status(500).json({ error: String(e.message || e) });
  }
});

module.exports = router;
