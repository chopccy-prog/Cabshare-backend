// routes/admin.js - Enhanced Admin Routes with Frontend Compatibility
const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const { supabase } = require('../supabase');

// Simplified middleware for development - allow all requests
const developmentAuth = (req, res, next) => {
  if (process.env.NODE_ENV === 'development') {
    req.user = { id: 'admin-user', role: 'admin' };
    return next();
  }
  
  // In production, implement proper auth
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.status(401).json({ error: 'Authorization required' });
  }
  
  req.user = { id: 'admin-user', role: 'admin' };
  next();
};

// Apply development-friendly auth
router.use(developmentAuth);

// CITIES ENDPOINTS (Required by frontend)
router.get('/cities', async (req, res) => {
  try {
    const { data: cities, error } = await supabase
      .from('cities')
      .select('id, name, state, country, is_active, display_order, created_at, updated_at')
      .eq('is_active', true)
      .order('display_order', { ascending: true })
      .order('name', { ascending: true });
    
    if (error) {
      console.error('Admin cities error:', error);
      return res.status(500).json({ 
        success: false, 
        error: 'Failed to fetch cities' 
      });
    }
    
    res.json({ 
      success: true, 
      data: cities || [] 
    });
  } catch (e) {
    console.error('Admin cities error:', e);
    res.status(500).json({ 
      success: false, 
      error: 'Internal server error' 
    });
  }
});

router.post('/cities', async (req, res) => {
  try {
    const { name, state, country = 'India', display_order } = req.body;
    
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
        display_order: display_order ? parseInt(display_order) : null,
        is_active: true
      })
      .select()
      .single();
    
    if (error) {
      console.error('City creation error:', error);
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
    console.error('City creation error:', e);
    res.status(500).json({ 
      success: false, 
      error: 'Internal server error' 
    });
  }
});

// ROUTES ENDPOINTS (Required by frontend)
router.get('/routes', async (req, res) => {
  try {
    const { data: routes, error } = await supabase
      .from('routes')
      .select(`
        id, name, origin, destination,
        from_city_id, to_city_id,
        distance_km, estimated_duration_minutes,
        is_active, created_at, updated_at
      `)
      .eq('is_active', true)
      .order('name');
    
    if (error) {
      console.error('Admin routes error:', error);
      return res.status(500).json({ 
        success: false, 
        error: 'Failed to fetch routes' 
      });
    }
    
    res.json({ 
      success: true, 
      data: routes || [] 
    });
  } catch (e) {
    console.error('Admin routes error:', e);
    res.status(500).json({ 
      success: false, 
      error: 'Internal server error' 
    });
  }
});

router.get('/routes/search', async (req, res) => {
  try {
    const { from, to } = req.query;
    
    if (!from || !to) {
      return res.json({ 
        success: true, 
        data: [] 
      });
    }
    
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
      return res.status(500).json({ 
        success: false, 
        error: 'Failed to search routes' 
      });
    }
    
    // Filter more precisely
    const filteredRoutes = (routes || []).filter(route => {
      const originMatch = route.origin?.toLowerCase().includes(from.toLowerCase());
      const destMatch = route.destination?.toLowerCase().includes(to.toLowerCase());
      return originMatch && destMatch;
    });
    
    res.json({ 
      success: true, 
      data: filteredRoutes 
    });
  } catch (e) {
    console.error('Admin routes search error:', e);
    res.status(500).json({ 
      success: false, 
      error: 'Internal server error' 
    });
  }
});

router.get('/routes/:id/stops', async (req, res) => {
  try {
    const { id } = req.params;
    
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
      console.error('Admin route stops error:', error);
      return res.status(500).json({ 
        success: false, 
        error: 'Failed to fetch stops' 
      });
    }
    
    res.json({ 
      success: true, 
      data: stops || [] 
    });
  } catch (e) {
    console.error('Admin route stops error:', e);
    res.status(500).json({ 
      success: false, 
      error: 'Internal server error' 
    });
  }
});

// DASHBOARD STATS (Optional enhancement)
router.get('/dashboard/stats', async (req, res) => {
  try {
    // Get basic stats
    const { data: ridesCount } = await supabase
      .from('rides')
      .select('id', { count: 'exact' })
      .eq('status', 'published');
    
    const { data: usersCount } = await supabase
      .from('users_app')
      .select('id', { count: 'exact' });
    
    const { data: citiesCount } = await supabase
      .from('cities')
      .select('id', { count: 'exact' })
      .eq('is_active', true);
    
    const { data: routesCount } = await supabase
      .from('routes')
      .select('id', { count: 'exact' })
      .eq('is_active', true);
    
    res.json({
      success: true,
      data: {
        active_rides: ridesCount?.length || 0,
        total_users: usersCount?.length || 0,
        total_cities: citiesCount?.length || 0,
        total_routes: routesCount?.length || 0,
        last_updated: new Date().toISOString()
      }
    });
  } catch (e) {
    console.error('Dashboard stats error:', e);
    res.status(500).json({ 
      success: false, 
      error: 'Failed to fetch dashboard stats' 
    });
  }
});

// Use existing controller methods for complex operations
router.post('/routes', adminController.createRoute);
router.delete('/routes/:routeId', adminController.deleteRoute);
router.delete('/cities/:cityId', adminController.deleteCity);

// Stops Management
router.get('/stops', adminController.getStops);
router.post('/stops', adminController.createStop);
router.delete('/stops/:stopId', adminController.deleteStop);

// Users Management
router.get('/users', adminController.getUsers);
router.patch('/users/:userId/verification', adminController.updateUserVerification);

// Financial Management
router.get('/financial/summary', adminController.getFinancialSummary);
router.get('/financial/settlements', adminController.getPendingSettlements);
router.post('/financial/settlements/:settlementId/approve', adminController.approveSettlement);
router.post('/financial/settlements/:settlementId/reject', adminController.rejectSettlement);

// Cancellation Policies
router.get('/policies', adminController.getCancellationPolicies);
router.post('/policies', adminController.updateCancellationPolicy);
router.delete('/policies/:rideType/:actor', adminController.deleteCancellationPolicy);

module.exports = router;