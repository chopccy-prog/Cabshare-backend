// File: routes/policies.js
// Backend API routes for managing cancellation policies

const express = require('express');
const router = express.Router();
const { supabase } = require('../supabase');

// Get all active cancellation policies
router.get('/cancellation', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('cancellation_policies')
      .select('*')
      .eq('is_active', true)
      .order('ride_type');

    if (error) throw error;

    res.json({
      success: true,
      policies: data,
      count: data.length
    });
  } catch (error) {
    console.error('Error fetching cancellation policies:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Get policy for specific ride type
router.get('/cancellation/:rideType', async (req, res) => {
  try {
    const { rideType } = req.params;

    const { data, error } = await supabase
      .from('cancellation_policies')
      .select('*')
      .eq('ride_type', rideType)
      .eq('actor', 'both')
      .eq('is_active', true)
      .single();

    if (error && error.code !== 'PGRST116') throw error;

    if (!data) {
      // Return default policy if none found
      return res.json({
        success: true,
        policy: {
          ride_type: rideType,
          actor: 'both',
          penalty_percentage_1: 20,
          penalty_percentage_2: 40,
          penalty_percentage_3: 60,
          hours_threshold_1: 12,
          hours_threshold_2: 6,
          hours_threshold_3: 0
        },
        isDefault: true
      });
    }

    res.json({
      success: true,
      policy: data,
      isDefault: false
    });
  } catch (error) {
    console.error('Error fetching policy for ride type:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Update cancellation policy (admin only)
router.put('/cancellation/:rideType', async (req, res) => {
  try {
    const { rideType } = req.params;
    const {
      penalty_percentage_1,
      penalty_percentage_2,
      penalty_percentage_3,
      hours_threshold_1 = 12,
      hours_threshold_2 = 6,
      hours_threshold_3 = 0
    } = req.body;

    // Validate percentages
    if (
      penalty_percentage_1 < 0 || penalty_percentage_1 > 100 ||
      penalty_percentage_2 < 0 || penalty_percentage_2 > 100 ||
      penalty_percentage_3 < 0 || penalty_percentage_3 > 100
    ) {
      return res.status(400).json({
        success: false,
        error: 'Penalty percentages must be between 0 and 100'
      });
    }

    // Update or insert policy
    const { data, error } = await supabase
      .from('cancellation_policies')
      .upsert({
        ride_type: rideType,
        actor: 'both',
        penalty_percentage_1,
        penalty_percentage_2,
        penalty_percentage_3,
        hours_threshold_1,
        hours_threshold_2,
        hours_threshold_3,
        is_active: true,
        updated_at: new Date().toISOString()
      }, {
        onConflict: 'ride_type,actor'
      })
      .select()
      .single();

    if (error) throw error;

    res.json({
      success: true,
      policy: data,
      message: 'Policy updated successfully'
    });
  } catch (error) {
    console.error('Error updating cancellation policy:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Calculate cancellation penalty for a booking
router.post('/cancellation/calculate', async (req, res) => {
  try {
    const { booking_id, cancelled_by } = req.body;

    if (!booking_id || !cancelled_by) {
      return res.status(400).json({
        success: false,
        error: 'booking_id and cancelled_by are required'
      });
    }

    const { data, error } = await supabase
      .rpc('calculate_cancellation_penalty', {
        p_booking_id: booking_id,
        p_cancelled_by: cancelled_by
      });

    if (error) throw error;

    res.json({
      success: true,
      penalty_calculation: data
    });
  } catch (error) {
    console.error('Error calculating cancellation penalty:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Apply cancellation penalty
router.post('/cancellation/apply', async (req, res) => {
  try {
    const { booking_id, cancelled_by } = req.body;

    if (!booking_id || !cancelled_by) {
      return res.status(400).json({
        success: false,
        error: 'booking_id and cancelled_by are required'
      });
    }

    const { data, error } = await supabase
      .rpc('apply_cancellation_penalty', {
        p_booking_id: booking_id,
        p_cancelled_by: cancelled_by
      });

    if (error) throw error;

    res.json({
      success: true,
      penalty_applied: data,
      message: 'Cancellation penalty applied successfully'
    });
  } catch (error) {
    console.error('Error applying cancellation penalty:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Initialize default policies
router.post('/cancellation/initialize', async (req, res) => {
  try {
    const defaultPolicies = [
      {
        ride_type: 'private',
        actor: 'both',
        penalty_percentage_1: 20,
        penalty_percentage_2: 40,
        penalty_percentage_3: 60,
        hours_threshold_1: 12,
        hours_threshold_2: 6,
        hours_threshold_3: 0,
        is_active: true
      },
      {
        ride_type: 'commercial',
        actor: 'both',
        penalty_percentage_1: 20,
        penalty_percentage_2: 40,
        penalty_percentage_3: 60,
        hours_threshold_1: 12,
        hours_threshold_2: 6,
        hours_threshold_3: 0,
        is_active: true
      },
      {
        ride_type: 'commercial_full',
        actor: 'both',
        penalty_percentage_1: 20,
        penalty_percentage_2: 40,
        penalty_percentage_3: 60,
        hours_threshold_1: 12,
        hours_threshold_2: 6,
        hours_threshold_3: 0,
        is_active: true
      }
    ];

    const { data, error } = await supabase
      .from('cancellation_policies')
      .upsert(defaultPolicies, {
        onConflict: 'ride_type,actor'
      })
      .select();

    if (error) throw error;

    res.json({
      success: true,
      policies: data,
      message: 'Default policies initialized successfully'
    });
  } catch (error) {
    console.error('Error initializing default policies:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

module.exports = router;
