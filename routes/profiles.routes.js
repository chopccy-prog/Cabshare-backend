// routes/profiles.routes.js
//
// Endpoints for reading and updating user profile information.

const express = require('express');
const router = express.Router();
const { supabase } = require('../supabase');

// GET /profiles/me
router.get('/me', async (req, res) => {
  try {
    const uid = req.user?.id || req.query.uid;
    if (!uid) return res.status(401).json({ error: 'unauthorized' });

    let { data: profile, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', uid)
      .single();

    // If no profile row, create one
    if (error && error.code === 'PGRST116') {
      const { data: created, error: insertErr } = await supabase
        .from('profiles')
        .insert({ id: uid })
        .select('*')
        .single();
      if (insertErr) return res.status(400).json({ error: insertErr.message });
      profile = created;
      error = null;
    }

    if (error) return res.status(400).json({ error: error.message });
    return res.json(profile);
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

// PUT /profiles/me
router.put('/me', async (req, res) => {
  try {
    const uid = req.user?.id || req.query.uid;
    if (!uid) return res.status(401).json({ error: 'unauthorized' });

    const updates = { ...req.body };
    delete updates.id;
    delete updates.is_aadhaar_verified;
    delete updates.is_vehicle_verified;
    delete updates.is_license_verified;
    delete updates.is_doc_verified;

    const { data, error } = await supabase
      .from('profiles')
      .update(updates)
      .eq('id', uid)
      .select('*')
      .single();

    if (error) return res.status(400).json({ error: error.message });
    return res.json(data);
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

module.exports = router;
