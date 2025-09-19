// routes/profile.routes.js - FIXED PROFILE MANAGEMENT SYSTEM (COMPATIBLE WITH EXISTING DB)
const express = require('express');
const router = express.Router();
const { createClient } = require('@supabase/supabase-js');
const { attachUser, requireAuth } = require('../middleware/auth');

// Initialize Supabase client
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

// Apply authentication middleware to all routes
router.use(attachUser);
router.use(requireAuth);

// GET /api/profile/me - Get complete user profile
router.get('/me', async (req, res) => {
  try {
    const userId = req.user.id;
    console.log('Getting profile for user:', userId);

    // Try to get user data from users_app table first (if it exists)
    let userData = null;
    try {
      const { data: userAppData, error: userAppError } = await supabase
        .from('users_app')
        .select('*')
        .eq('id', userId)
        .single();
      
      if (!userAppError) {
        userData = userAppData;
      }
    } catch (e) {
      console.log('users_app table not found or error, trying auth.users');
    }

    // Fallback to auth.users if users_app doesn't exist or user not found
    if (!userData) {
      const { data: authUserData, error: authError } = await supabase.auth.admin.getUserById(userId);
      if (authError) {
        console.error('Error fetching user from auth:', authError);
        return res.status(404).json({ error: 'User not found' });
      }
      
      userData = {
        id: authUserData.user.id,
        email: authUserData.user.email,
        full_name: authUserData.user.user_metadata?.full_name || '',
        phone: authUserData.user.phone || '',
        role: 'rider',
        is_verified: authUserData.user.email_confirmed_at ? true : false,
        email_verified: authUserData.user.email_confirmed_at ? true : false,
        phone_verified: authUserData.user.phone_confirmed_at ? true : false,
        created_at: authUserData.user.created_at,
        updated_at: authUserData.user.updated_at
      };
    }

    // Get additional profile data from profiles table if it exists
    let profileData = {};
    try {
      const { data: profiles, error: profileError } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .maybeSingle();
      
      if (!profileError && profiles) {
        profileData = profiles;
      }
    } catch (e) {
      console.log('profiles table not found or error:', e);
    }

    // Merge user data with profile data
    const combinedProfile = {
      id: userData.id,
      email: userData.email,
      full_name: userData.full_name,
      phone: userData.phone,
      role: userData.role || 'rider',
      is_verified: userData.is_verified || false,
      is_active: userData.is_active !== false,
      email_verified: userData.email_verified || false,
      phone_verified: userData.phone_verified || false,
      auth_provider: userData.auth_provider || 'supabase',
      created_at: userData.created_at,
      updated_at: userData.updated_at,
      
      // Additional profile fields from profiles table
      bio: profileData.bio || null,
      date_of_birth: profileData.date_of_birth || null,
      gender: profileData.gender || null,
      profile_picture_url: profileData.profile_picture_url || null,
      address: profileData.address || null,
      city: profileData.city || null,
      state: profileData.state || null,
      country: profileData.country || 'India',
      
      // Travel preferences
      chat_preference: profileData.chat_preference || 'talkative',
      music_preference: profileData.music_preference || 'depends',
      pets_preference: profileData.pets_preference || 'depends',
      smoking_preference: profileData.smoking_preference || 'no',
      
      // Verification status from profiles table
      is_aadhaar_verified: profileData.is_aadhaar_verified || false,
      is_license_verified: profileData.is_license_verified || false,
      is_vehicle_verified: profileData.is_vehicle_verified || false,
      is_doc_verified: profileData.is_doc_verified || false,
    };

    console.log('Profile fetched successfully:', combinedProfile.id);
    res.json({ user: combinedProfile });

  } catch (error) {
    console.error('Profile fetch error:', error);
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
});

// POST /api/profile/update - Update user profile
router.post('/update', async (req, res) => {
  try {
    const userId = req.user.id;
    const updates = req.body;
    
    console.log('Updating profile for user:', userId, 'with data:', updates);

    // Split updates between different tables
    const userUpdates = {};
    const profileUpdates = {};

    // Fields that go to users_app table (if it exists)
    const userFields = ['full_name', 'phone', 'email'];
    userFields.forEach(field => {
      if (updates[field] !== undefined) {
        userUpdates[field] = updates[field];
      }
    });

    // Fields that go to profiles table
    const profileFields = [
      'bio', 'date_of_birth', 'gender', 'address', 'city', 'state', 'country',
      'chat_preference', 'music_preference', 'pets_preference', 'smoking_preference'
    ];
    profileFields.forEach(field => {
      if (updates[field] !== undefined) {
        profileUpdates[field] = updates[field];
      }
    });

    // Update users_app table if there are user fields to update and table exists
    if (Object.keys(userUpdates).length > 0) {
      try {
        userUpdates.updated_at = new Date().toISOString();
        
        const { error: userUpdateError } = await supabase
          .from('users_app')
          .update(userUpdates)
          .eq('id', userId);

        if (userUpdateError) {
          console.log('users_app update failed, table might not exist:', userUpdateError);
        }
      } catch (e) {
        console.log('users_app table not found, skipping user updates');
      }
    }

    // Update or create profiles table entry if there are profile fields to update
    if (Object.keys(profileUpdates).length > 0) {
      try {
        profileUpdates.updated_at = new Date().toISOString();

        // Try to update first, if no record exists, insert one
        const { data: existingProfile } = await supabase
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

        if (existingProfile) {
          // Update existing profile
          const { error: profileUpdateError } = await supabase
            .from('profiles')
            .update(profileUpdates)
            .eq('id', userId);

          if (profileUpdateError) {
            console.error('Error updating profiles:', profileUpdateError);
            return res.status(400).json({ error: 'Failed to update profile data' });
          }
        } else {
          // Create new profile entry
          const { error: profileInsertError } = await supabase
            .from('profiles')
            .insert({ 
              id: userId,
              ...profileUpdates,
              created_at: new Date().toISOString()
            });

          if (profileInsertError) {
            console.error('Error creating profile:', profileInsertError);
            return res.status(400).json({ error: 'Failed to create profile data' });
          }
        }
      } catch (e) {
        console.log('profiles table not found, skipping profile updates');
      }
    }

    // Fetch updated profile data
    try {
      const updatedProfileResponse = await fetch(`${req.protocol}://${req.get('host')}/api/profile/me`, {
        headers: {
          'Authorization': req.headers.authorization,
          'x-user-id': userId
        }
      });

      if (updatedProfileResponse.ok) {
        const updatedProfile = await updatedProfileResponse.json();
        console.log('Profile updated successfully');
        res.json(updatedProfile);
      } else {
        // Fallback response
        res.json({ success: true, message: 'Profile updated successfully' });
      }
    } catch (e) {
      // Fallback response if fetch fails
      res.json({ success: true, message: 'Profile updated successfully' });
    }

  } catch (error) {
    console.error('Profile update error:', error);
    res.status(500).json({ error: 'Failed to update profile' });
  }
});

// GET /api/profile/vehicles - Get user vehicles
router.get('/vehicles', async (req, res) => {
  try {
    const userId = req.user.id;

    // Try to get vehicles from either vehicles table or vehicles_api_view
    let vehicles = [];
    
    try {
      // First try the vehicles_api_view (standardized view)
      const { data: vehicleViewData, error: viewError } = await supabase
        .from('vehicles_api_view')
        .select('*')
        .eq('owner_id', userId);

      if (!viewError) {
        vehicles = vehicleViewData || [];
      } else {
        // Fallback to direct vehicles table query
        const { data: vehicleData, error: vehicleError } = await supabase
          .from('vehicles')
          .select('*')
          .eq('owner_id', userId)
          .eq('is_active', true);

        if (!vehicleError) {
          vehicles = vehicleData || [];
        }
      }
    } catch (e) {
      console.log('vehicles table not found:', e);
      vehicles = [];
    }

    res.json(vehicles);

  } catch (error) {
    console.error('Vehicles fetch error:', error);
    res.status(500).json({ error: 'Failed to fetch vehicles' });
  }
});

// POST /api/profile/vehicles - Add new vehicle
router.post('/vehicles', async (req, res) => {
  try {
    const userId = req.user.id;
    const { make, model, plate_number, vehicle_type, year, color } = req.body;

    // Check if vehicles table exists by trying to query it
    try {
      const { data: vehicle, error } = await supabase
        .from('vehicles')
        .insert({
          owner_id: userId,
          make,
          model,
          plate_number,
          vehicle_type,
          year,
          color,
          is_verified: false,
          is_active: true,
          created_at: new Date().toISOString()
        })
        .select()
        .single();

      if (error) {
        console.error('Error adding vehicle:', error);
        return res.status(400).json({ error: 'Failed to add vehicle' });
      }

      res.status(201).json(vehicle);
    } catch (e) {
      console.log('vehicles table not found');
      res.status(501).json({ error: 'Vehicle management not available yet' });
    }

  } catch (error) {
    console.error('Vehicle add error:', error);
    res.status(500).json({ error: 'Failed to add vehicle' });
  }
});

// DELETE /api/profile/vehicles/:id - Delete vehicle
router.delete('/vehicles/:id', async (req, res) => {
  try {
    const userId = req.user.id;
    const vehicleId = req.params.id;

    try {
      const { error } = await supabase
        .from('vehicles')
        .update({ is_active: false })
        .eq('id', vehicleId)
        .eq('owner_id', userId);

      if (error) {
        console.error('Error deleting vehicle:', error);
        return res.status(400).json({ error: 'Failed to delete vehicle' });
      }

      res.json({ success: true, message: 'Vehicle deleted successfully' });
    } catch (e) {
      console.log('vehicles table not found');
      res.status(501).json({ error: 'Vehicle management not available yet' });
    }

  } catch (error) {
    console.error('Vehicle delete error:', error);
    res.status(500).json({ error: 'Failed to delete vehicle' });
  }
});

// GET /api/profile/kyc - Get KYC documents
router.get('/kyc', async (req, res) => {
  try {
    const userId = req.user.id;

    try {
      const { data: documents, error } = await supabase
        .from('kyc_documents')
        .select('*')
        .eq('user_id', userId);

      if (error) {
        console.error('Error fetching KYC documents:', error);
        return res.status(400).json({ error: 'Failed to fetch documents' });
      }

      res.json(documents || []);
    } catch (e) {
      console.log('kyc_documents table not found');
      res.json([]);
    }

  } catch (error) {
    console.error('KYC fetch error:', error);
    res.status(500).json({ error: 'Failed to fetch KYC documents' });
  }
});

// POST /api/profile/kyc - Upload KYC document
router.post('/kyc', async (req, res) => {
  try {
    const userId = req.user.id;
    const { doc_type, doc_number, file_url } = req.body;

    try {
      const { data: document, error } = await supabase
        .from('kyc_documents')
        .insert({
          user_id: userId,
          doc_type,
          doc_number,
          file_url,
          verification_status: 'pending',
          uploaded_at: new Date().toISOString()
        })
        .select()
        .single();

      if (error) {
        console.error('Error uploading KYC document:', error);
        return res.status(400).json({ error: 'Failed to upload document' });
      }

      res.status(201).json(document);
    } catch (e) {
      console.log('kyc_documents table not found');
      res.status(501).json({ error: 'Document verification not available yet' });
    }

  } catch (error) {
    console.error('KYC upload error:', error);
    res.status(500).json({ error: 'Failed to upload document' });
  }
});

// GET /api/profile/stats - Get user statistics for profile display
router.get('/stats', async (req, res) => {
  try {
    const userId = req.user.id;

    try {
      const { data: stats, error } = await supabase
        .from('user_profile_stats')
        .select('*')
        .eq('id', userId)
        .single();

      if (error) {
        console.log('user_profile_stats view not found, returning default stats');
        // Return default stats
        return res.json({
          total_rides: 0,
          driver_rides: 0,
          passenger_rides: 0,
          driver_rating: 0,
          passenger_rating: 0,
          total_ratings: 0,
          is_profile_verified: false,
          verification_count: 0
        });
      }

      res.json(stats);
    } catch (e) {
      console.log('Error fetching stats:', e);
      res.json({
        total_rides: 0,
        driver_rides: 0,
        passenger_rides: 0,
        driver_rating: 0,
        passenger_rating: 0,
        total_ratings: 0,
        is_profile_verified: false,
        verification_count: 0
      });
    }

  } catch (error) {
    console.error('Stats fetch error:', error);
    res.status(500).json({ error: 'Failed to fetch user statistics' });
  }
});

module.exports = router;