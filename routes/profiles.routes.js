// routes/profiles.routes.js
//
// Endpoints for reading and updating user profile information.  Profiles
// are stored in the `profiles` table, with the same primary key as
// auth.users (Supabase auth).  A profile is created on demand if it
// doesn’t exist when the user fetches it.

const express = require('express');
const router = express.Router();
const { supabase } = require('../supabase');

// GET /profiles/me
// Return the profile for the current user.  If none exists, create a blank one.
router.get('/me', async (req, res) => {
  try {
    const uid = req.user?.id || req.query.uid;
    if (!uid) return res.status(401).json({ error: 'unauthorized' });

    // Use maybeSingle() so Supabase will return the first row if multiple exist
    let { data: profile, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', uid)
      .maybeSingle();

    // If no profile exists, insert a default row
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
// Update the current user’s profile.  Only supplied fields are changed.
router.put('/me', async (req, res) => {
  try {
    const uid = req.user?.id || req.query.uid;
    if (!uid) return res.status(401).json({ error: 'unauthorized' });

    const updates = { ...req.body };
    // Prevent override of restricted fields
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
