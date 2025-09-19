// routes/cities.routes.js - FIXED VERSION
const express = require('express');
const router = express.Router();
const { supabase } = require('../supabase');

// GET /cities - Simple cities list with proper response format
router.get('/', async (req, res) => {
  try {
    console.log('📍 Loading cities...');
    
    // Try to get from database first
    const { data: dbCities, error } = await supabase
      .from('cities')
      .select('id, name, state, country, is_active')
      .eq('is_active', true)
      .order('name')
      .limit(100);
      
    if (!error && dbCities && dbCities.length > 0) {
      console.log(`✅ Loaded ${dbCities.length} cities from database`);
      return res.json({
        success: true,
        data: dbCities
      });
    }

    console.log('⚠️ No cities in database, returning fallback cities');
    
    // Fallback cities for immediate functionality
    const fallbackCities = [
      { id: '1', name: 'Mumbai', state: 'Maharashtra', country: 'India', is_active: true },
      { id: '2', name: 'Pune', state: 'Maharashtra', country: 'India', is_active: true },
      { id: '3', name: 'Nashik', state: 'Maharashtra', country: 'India', is_active: true },
      { id: '4', name: 'Delhi', state: 'Delhi', country: 'India', is_active: true },
      { id: '5', name: 'Bangalore', state: 'Karnataka', country: 'India', is_active: true },
      { id: '6', name: 'Chennai', state: 'Tamil Nadu', country: 'India', is_active: true },
      { id: '7', name: 'Hyderabad', state: 'Telangana', country: 'India', is_active: true },
      { id: '8', name: 'Kolkata', state: 'West Bengal', country: 'India', is_active: true },
      { id: '9', name: 'Ahmedabad', state: 'Gujarat', country: 'India', is_active: true },
      { id: '10', name: 'Jaipur', state: 'Rajasthan', country: 'India', is_active: true },
      { id: '11', name: 'Thane', state: 'Maharashtra', country: 'India', is_active: true },
      { id: '12', name: 'Navi Mumbai', state: 'Maharashtra', country: 'India', is_active: true },
      { id: '13', name: 'Aurangabad', state: 'Maharashtra', country: 'India', is_active: true },
      { id: '14', name: 'Surat', state: 'Gujarat', country: 'India', is_active: true },
      { id: '15', name: 'Gurgaon', state: 'Haryana', country: 'India', is_active: true },
    ];

    // Try to seed the database with fallback cities
    try {
      const { error: insertError } = await supabase
        .from('cities')
        .upsert(fallbackCities, { 
          onConflict: 'name',
          ignoreDuplicates: true 
        });
        
      if (!insertError) {
        console.log('✅ Seeded fallback cities to database');
      }
    } catch (seedError) {
      console.log('⚠️ Could not seed cities to database:', seedError.message);
    }

    res.json({
      success: true,
      data: fallbackCities
    });
    
  } catch (e) {
    console.error('❌ Cities endpoint error:', e);
    res.status(500).json({ 
      success: false,
      error: 'Failed to load cities',
      data: []
    });
  }
});

// POST /cities - Add new city (admin function)
router.post('/', async (req, res) => {
  try {
    const { name, state, country = 'India' } = req.body;
    
    if (!name) {
      return res.status(400).json({ 
        success: false,
        error: 'City name is required' 
      });
    }
    
    const { data, error } = await supabase
      .from('cities')
      .insert({
        name: name.trim(),
        state: state?.trim(),
        country: country.trim(),
        is_active: true
      })
      .select()
      .single();
    
    if (error) {
      if (error.code === '23505') {
        return res.status(409).json({ 
          success: false,
          error: 'City already exists' 
        });
      }
      console.error('City insert error:', error);
      return res.status(400).json({ 
        success: false,
        error: error.message 
      });
    }
    
    res.status(201).json({
      success: true,
      data: data
    });
  } catch (e) {
    console.error('Cities POST error:', e);
    res.status(500).json({ 
      success: false,
      error: 'Failed to create city' 
    });
  }
});

module.exports = router;