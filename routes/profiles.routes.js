// routes/profiles.routes.js
//
// Endpoints for reading and updating user profile information.  Profiles
// are stored in the `profiles` table, with the same primary key as
// `auth.users` (Supabase auth).  A profile is created on demand if it
// doesn’t exist when the user fetches it.  Verification fields are
// intended to be updated by an admin portal.

const express = require('express');
const router = express.Router();
const { supabase } = require('../supabase');

// GET /profiles/me
//
// Return the profile for the current user.  If no profile exists, a
// default row is created with null values.  The user ID is taken
// from `req.user.id` (decoded by Supabase middleware) or from the
// `uid` query parameter.  If neither is present, returns 401.
router.get('/me', async (req, res) => {
  try {
    const uid = req.user?.id || req.query.uid;
    if (!uid) return res.status(401).json({ error: 'unauthorized' });
    // Try to fetch existing profile
    let { data: profile, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', uid)
      .single();
    // If no profile exists, insert a default row
    if (error && error.code === 'PGRST116') {
      // Supabase error code for "No rows found"
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
//
// Update the current user’s profile.  Accepts JSON fields such as
// `full_name`, `phone`, `address`, etc.  Only provided fields are
// updated.  Verification fields (e.g. `is_aadhaar_verified`) are
// intended to be modified by an admin and should not be set by the
// client.
router.put('/me', async (req, res) => {
  try {
    const uid = req.user?.id || req.query.uid;
    if (!uid) return res.status(401).json({ error: 'unauthorized' });
    const updates = { ...req.body };
    // Remove any disallowed keys (to prevent overriding verification statuses)
    delete updates.id;
    delete updates.is_aadhaar_verified;
    delete updates.is_vehicle_verified;
    delete updates.is_license_verified;
    delete updates.is_doc_verified;
    // Perform the update
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