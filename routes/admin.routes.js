// routes/admin.routes.js
const router = require('express').Router();
const { supabaseAdmin } = require('../config/supabase');
const { requireAuth } = require('../middleware/auth');

// If service role isn't configured, short-circuit admin endpoints with a friendly error
router.use((req, res, next) => {
  if (!supabaseAdmin) {
    return res.status(503).json({
      error: 'Admin API disabled: SUPABASE_SERVICE_ROLE not set on the server.',
    });
  }
  next();
});

// List cities
router.get('/cities', requireAuth, async (_req, res) => {
  const { data, error } = await supabaseAdmin.from('cities').select('*').order('name', { ascending: true });
  if (error) return res.status(500).json({ error: error.message });
  res.json({ items: data || [] });
});

// Create/Upsert city
router.post('/cities', requireAuth, async (req, res) => {
  const { name } = req.body || {};
  const { data, error } = await supabaseAdmin.from('cities').upsert({ name }).select('*').single();
  if (error) return res.status(400).json({ error: error.message });
  res.json({ city: data });
});

// Routes
router.get('/routes', requireAuth, async (_req, res) => {
  const { data, error } = await supabaseAdmin.from('routes').select('*').order('code', { ascending: true });
  if (error) return res.status(500).json({ error: error.message });
  res.json({ items: data || [] });
});

router.post('/routes', requireAuth, async (req, res) => {
  const { code, from_city_id, to_city_id, distance_km } = req.body || {};
  const { data, error } = await supabaseAdmin.from('routes')
    .insert({ code, from_city_id, to_city_id, distance_km })
    .select('*')
    .single();
  if (error) return res.status(400).json({ error: error.message });
  res.json({ route: data });
});

// Stops + mapping
router.get('/stops', requireAuth, async (_req, res) => {
  const { data, error } = await supabaseAdmin.from('stops').select('*').order('name', { ascending: true });
  if (error) return res.status(500).json({ error: error.message });
  res.json({ items: data || [] });
});

router.post('/stops', requireAuth, async (req, res) => {
  const { name, lat, lon, city_id } = req.body || {};
  const { data, error } = await supabaseAdmin.from('stops')
    .insert({ name, lat, lon, city_id })
    .select('*').single();
  if (error) return res.status(400).json({ error: error.message });
  res.json({ stop: data });
});

router.post('/route-stops', requireAuth, async (req, res) => {
  const { route_id, stop_id, rank } = req.body || {};
  const { data, error } = await supabaseAdmin.from('route_stops')
    .insert({ route_id, stop_id, rank })
    .select('*').single();
  if (error) return res.status(400).json({ error: error.message });
  res.json({ routeStop: data });
});

module.exports = router;
