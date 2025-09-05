// routes/routes.routes.js
const express = require('express');
const router = express.Router();
const { supabase } = require('../supabase');

// GET /routes?from=city&to=city
router.get('/', async (req, res) => {
  try {
    const { from, to } = req.query;
    let q = supabase.from('routes').select('*');
    if (from) q = q.eq('from', from);
    if (to) q = q.eq('to', to);
    const { data, error } = await q;
    if (error) return res.status(400).json({ error: error.message });
    res.json(data || []);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// GET /routes/:id/stops
router.get('/:id/stops', async (req, res) => {
  try {
    const { id } = req.params;
    const { data, error } = await supabase
      .from('route_stops')
      .select('id, stop_name, stop_order')
      .eq('route_id', id)
      .order('stop_order', { ascending: true });
    if (error) return res.status(400).json({ error: error.message });
    res.json(data || []);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = router;
