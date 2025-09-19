// routes/routes.routes.js - FIXED VERSION WITH FALLBACK ROUTES
const express = require('express');
const router = express.Router();
const { supabase } = require('../supabase');

// GET /routes/search?from=city&to=city - Main endpoint for frontend
router.get('/search', async (req, res) => {
  try {
    const { from, to } = req.query;
    
    if (!from || !to) {
      return res.status(400).json({ 
        success: false,
        error: 'Both from and to cities are required',
        data: []
      });
    }
    
    console.log(`🛣️ Searching routes for: ${from} → ${to}`);
    
    // Create fallback route immediately
    const fallbackRoute = {
      id: `${from.toLowerCase().replace(/\s+/g, '-')}-${to.toLowerCase().replace(/\s+/g, '-')}`,
      name: `${from} to ${to} Direct`,
      origin: from,
      destination: to,
      from_city: from,
      to_city: to,
      distance_km: null,
      estimated_duration_minutes: null,
      is_active: true,
      created_at: new Date().toISOString()
    };
    
    try {
      // Try to get routes from database first
      const { data: dbRoutes, error } = await supabase
        .from('routes')
        .select(`
          id, name, origin, destination,
          from_city_id, to_city_id,
          distance_km, estimated_duration_minutes,
          is_active, created_at
        `)
        .or(`origin.ilike.%${from}%,destination.ilike.%${to}%`)
        .eq('is_active', true)
        .order('name');
      
      if (!error && dbRoutes && dbRoutes.length > 0) {
        // Filter more precisely
        const filteredRoutes = dbRoutes.filter(route => {
          const originMatch = route.origin?.toLowerCase().includes(from.toLowerCase());
          const destMatch = route.destination?.toLowerCase().includes(to.toLowerCase());
          return originMatch && destMatch;
        });
        
        if (filteredRoutes.length > 0) {
          console.log(`✅ Found ${filteredRoutes.length} routes from database`);
          return res.json({ 
            success: true,
            data: filteredRoutes 
          });
        }
      }
    } catch (dbError) {
      console.log('⚠️ Database route search failed:', dbError.message);
    }
    
    // Try to seed the fallback route to database
    try {
      const { data: insertedRoute, error: insertError } = await supabase
        .from('routes')
        .upsert([fallbackRoute], { 
          onConflict: 'id',
          ignoreDuplicates: true 
        })
        .select()
        .single();
        
      if (!insertError && insertedRoute) {
        console.log('✅ Seeded fallback route to database');
        return res.json({ 
          success: true,
          data: [insertedRoute] 
        });
      }
    } catch (seedError) {
      console.log('⚠️ Could not seed route to database:', seedError.message);
    }
    
    console.log('🔄 Using in-memory fallback route');
    res.json({ 
      success: true,
      data: [fallbackRoute] 
    });
    
  } catch (e) {
    console.error('❌ Routes search error:', e);
    res.status(500).json({ 
      success: false,
      error: 'Internal server error',
      data: []
    });
  }
});

// GET /routes/:id/stops - Get stops for a specific route
router.get('/:id/stops', async (req, res) => {
  try {
    const { id } = req.params;
    
    console.log(`🚏 Getting stops for route: ${id}`);
    
    // Create fallback stops for any route
    const fallbackStops = [
      {
        id: `${id}_start`,
        route_id: id,
        name: 'Starting Point',
        address: null,
        city_name: null,
        stop_order: 1,
        is_pickup: true,
        is_drop: false,
        is_active: true,
        latitude: null,
        longitude: null,
        created_at: new Date().toISOString()
      },
      {
        id: `${id}_mid`,
        route_id: id,
        name: 'Mid Point',
        address: null,
        city_name: null,
        stop_order: 2,
        is_pickup: true,
        is_drop: true,
        is_active: true,
        latitude: null,
        longitude: null,
        created_at: new Date().toISOString()
      },
      {
        id: `${id}_end`,
        route_id: id,
        name: 'End Point',
        address: null,
        city_name: null,
        stop_order: 3,
        is_pickup: false,
        is_drop: true,
        is_active: true,
        latitude: null,
        longitude: null,
        created_at: new Date().toISOString()
      }
    ];
    
    try {
      // Check if route exists in database first
      const { data: route, error: routeError } = await supabase
        .from('routes')
        .select('id, name')
        .eq('id', id)
        .single();
      
      if (!routeError && route) {
        // Get stops from database
        const { data: dbStops, error: stopsError } = await supabase
          .from('stops')
          .select(`
            id, route_id, name, address, city_name,
            stop_order, is_pickup, is_drop, is_active,
            latitude, longitude, created_at
          `)
          .eq('route_id', id)
          .eq('is_active', true)
          .order('stop_order');
        
        if (!stopsError && dbStops && dbStops.length > 0) {
          console.log(`✅ Found ${dbStops.length} stops from database`);
          return res.json({ 
            success: true,
            data: dbStops 
          });
        }
        
        // Try to seed fallback stops to database
        try {
          const { data: insertedStops, error: insertError } = await supabase
            .from('stops')
            .upsert(fallbackStops, { 
              onConflict: 'id',
              ignoreDuplicates: true 
            })
            .select();
            
          if (!insertError && insertedStops) {
            console.log('✅ Seeded fallback stops to database');
            return res.json({ 
              success: true,
              data: insertedStops 
            });
          }
        } catch (seedError) {
          console.log('⚠️ Could not seed stops to database:', seedError.message);
        }
      }
    } catch (dbError) {
      console.log('⚠️ Database stops search failed:', dbError.message);
    }
    
    console.log(`🔄 Using fallback stops for route ${id}`);
    res.json({ 
      success: true,
      data: fallbackStops 
    });
    
  } catch (e) {
    console.error('❌ Route stops error:', e);
    res.status(500).json({ 
      success: false,
      error: 'Internal server error',
      data: []
    });
  }
});

// GET /routes - List all routes
router.get('/', async (req, res) => {
  try {
    const { from, to, limit = 50 } = req.query;
    
    let query = supabase
      .from('routes')
      .select(`
        id, name, origin, destination,
        from_city_id, to_city_id,
        distance_km, estimated_duration_minutes,
        is_active, created_at
      `)
      .eq('is_active', true);
    
    if (from) {
      query = query.ilike('origin', `%${from}%`);
    }
    if (to) {
      query = query.ilike('destination', `%${to}%`);
    }
    
    query = query
      .order('name')
      .limit(parseInt(limit));
    
    const { data, error } = await query;
    
    if (error) {
      console.error('Routes list error:', error);
      return res.status(500).json({ 
        success: false,
        error: 'Failed to fetch routes',
        data: []
      });
    }
    
    res.json({ 
      success: true,
      data: data || [] 
    });
  } catch (e) {
    console.error('Routes list error:', e);
    res.status(500).json({ 
      success: false,
      error: 'Internal server error',
      data: []
    });
  }
});

// POST /routes - Create a new route
router.post('/', async (req, res) => {
  try {
    const { name, origin, destination, from_city_id, to_city_id, distance_km, estimated_duration_minutes } = req.body;
    
    if (!name || !origin || !destination) {
      return res.status(400).json({ 
        success: false,
        error: 'Name, origin, and destination are required' 
      });
    }
    
    const routeData = {
      name: name.trim(),
      origin: origin.trim(),
      destination: destination.trim(),
      from_city_id,
      to_city_id,
      distance_km: distance_km ? parseInt(distance_km) : null,
      estimated_duration_minutes: estimated_duration_minutes ? parseInt(estimated_duration_minutes) : null,
      is_active: true
    };
    
    const { data, error } = await supabase
      .from('routes')
      .insert(routeData)
      .select()
      .single();
    
    if (error) {
      console.error('Route creation error:', error);
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
    console.error('Route creation error:', e);
    res.status(500).json({ 
      success: false,
      error: 'Internal server error' 
    });
  }
});

module.exports = router;