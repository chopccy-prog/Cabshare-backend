// routes/admin.routes.js - FIXED VERSION WITH PROPER RESPONSE FORMATS
const router = require('express').Router();
const { supabase } = require('../supabase');

// GET /admin/cities - Returns cities in the format expected by frontend
router.get('/cities', async (req, res) => {
  try {
    console.log('📍 Admin: Loading cities...');
    
    const { data, error } = await supabase
      .from('cities')
      .select('*')
      .eq('is_active', true)
      .order('name', { ascending: true });
    
    if (error) {
      console.error('Admin cities error:', error);
      
      // Return fallback cities on error
      const fallbackCities = [
        { id: '1', name: 'Mumbai', state: 'Maharashtra', country: 'India' },
        { id: '2', name: 'Pune', state: 'Maharashtra', country: 'India' },
        { id: '3', name: 'Nashik', state: 'Maharashtra', country: 'India' },
        { id: '4', name: 'Delhi', state: 'Delhi', country: 'India' },
        { id: '5', name: 'Bangalore', state: 'Karnataka', country: 'India' },
        { id: '6', name: 'Chennai', state: 'Tamil Nadu', country: 'India' },
        { id: '7', name: 'Hyderabad', state: 'Telangana', country: 'India' },
        { id: '8', name: 'Kolkata', state: 'West Bengal', country: 'India' },
        { id: '9', name: 'Ahmedabad', state: 'Gujarat', country: 'India' },
        { id: '10', name: 'Jaipur', state: 'Rajasthan', country: 'India' },
      ];
      
      return res.json({ 
        success: true,
        data: fallbackCities,
        source: 'fallback'
      });
    }
    
    console.log(`✅ Admin: Loaded ${data?.length || 0} cities`);
    res.json({ 
      success: true,
      data: data || [],
      source: 'database'
    });
    
  } catch (e) {
    console.error('Admin cities error:', e);
    res.status(500).json({ 
      success: false,
      error: 'Failed to load cities',
      data: []
    });
  }
});

// GET /admin/routes/search - Search routes (same as public endpoint)
router.get('/routes/search', async (req, res) => {
  try {
    const { from, to } = req.query;
    
    if (!from || !to) {
      return res.status(400).json({ 
        success: false,
        error: 'Both from and to cities are required',
        data: []
      });
    }
    
    console.log(`🛣️ Admin: Searching routes for: ${from} → ${to}`);
    
    // Search for routes using flexible matching
    const { data: routes, error } = await supabase
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
    
    if (error) {
      console.error('Admin routes search error:', error);
      
      // Return fallback route on error
      const fallbackRoute = {
        id: `${from.toLowerCase().replace(/\s+/g, '-')}-${to.toLowerCase().replace(/\s+/g, '-')}`,
        name: `${from} to ${to} Direct`,
        origin: from,
        destination: to,
        distance_km: null,
        estimated_duration_minutes: null,
        is_active: true
      };
      
      return res.json({ 
        success: true,
        data: [fallbackRoute],
        source: 'fallback'
      });
    }
    
    // Filter routes more precisely
    const filteredRoutes = (routes || []).filter(route => {
      const originMatch = route.origin?.toLowerCase().includes(from.toLowerCase());
      const destMatch = route.destination?.toLowerCase().includes(to.toLowerCase());
      return originMatch && destMatch;
    });
    
    console.log(`✅ Admin: Found ${filteredRoutes.length} matching routes`);
    
    // If no routes found, return fallback
    if (filteredRoutes.length === 0) {
      const fallbackRoute = {
        id: `${from.toLowerCase().replace(/\s+/g, '-')}-${to.toLowerCase().replace(/\s+/g, '-')}`,
        name: `${from} to ${to} Direct`,
        origin: from,
        destination: to,
        distance_km: null,
        estimated_duration_minutes: null,
        is_active: true
      };
      
      return res.json({ 
        success: true,
        data: [fallbackRoute],
        source: 'fallback'
      });
    }
    
    res.json({ 
      success: true,
      data: filteredRoutes,
      source: 'database'
    });
    
  } catch (e) {
    console.error('Admin routes search error:', e);
    res.status(500).json({ 
      success: false,
      error: 'Internal server error',
      data: []
    });
  }
});

// GET /admin/routes/:id/stops - Get stops for a route
router.get('/routes/:id/stops', async (req, res) => {
  try {
    const { id } = req.params;
    
    console.log(`🚏 Admin: Getting stops for route: ${id}`);
    
    // Get stops from database
    const { data: stops, error } = await supabase
      .from('stops')
      .select(`
        id, route_id, name, address, city_name,
        stop_order, is_pickup, is_drop, is_active,
        latitude, longitude, created_at
      `)
      .eq('route_id', id)
      .eq('is_active', true)
      .order('stop_order');
    
    if (error) {
      console.error('Admin stops fetch error:', error);
      
      // Return fallback stops on error
      const fallbackStops = [
        {
          id: `${id}_start`,
          route_id: id,
          name: 'Starting Point',
          stop_order: 1,
          is_pickup: true,
          is_drop: false,
          is_active: true
        },
        {
          id: `${id}_mid`,
          route_id: id,
          name: 'Mid Point',
          stop_order: 2,
          is_pickup: true,
          is_drop: true,
          is_active: true
        },
        {
          id: `${id}_end`,
          route_id: id,
          name: 'End Point',
          stop_order: 3,
          is_pickup: false,
          is_drop: true,
          is_active: true
        }
      ];
      
      return res.json({ 
        success: true,
        data: fallbackStops,
        source: 'fallback'
      });
    }
    
    console.log(`✅ Admin: Found ${stops?.length || 0} stops for route ${id}`);
    
    // If no stops found, return fallback stops
    if (!stops || stops.length === 0) {
      const fallbackStops = [
        {
          id: `${id}_start`,
          route_id: id,
          name: 'Starting Point',
          stop_order: 1,
          is_pickup: true,
          is_drop: false,
          is_active: true
        },
        {
          id: `${id}_mid`,
          route_id: id,
          name: 'Mid Point',
          stop_order: 2,
          is_pickup: true,
          is_drop: true,
          is_active: true
        },
        {
          id: `${id}_end`,
          route_id: id,
          name: 'End Point',
          stop_order: 3,
          is_pickup: false,
          is_drop: true,
          is_active: true
        }
      ];
      
      return res.json({ 
        success: true,
        data: fallbackStops,
        source: 'fallback'
      });
    }
    
    res.json({ 
      success: true,
      data: stops,
      source: 'database'
    });
    
  } catch (e) {
    console.error('Admin route stops error:', e);
    res.status(500).json({ 
      success: false,
      error: 'Internal server error',
      data: []
    });
  }
});

module.exports = router;