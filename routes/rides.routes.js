// routes/rides.routes.js - ENHANCED WITH UNIFIED AUTH (PRESERVING ALL EXISTING FUNCTIONALITY)
const express = require('express');
const router = express.Router();
const { supabase } = require('../supabase');
// ADD: Import unified authentication middleware
const { unifiedAuthMiddleware, optionalAuth } = require('../middleware/unifiedAuth');

// ADD: Apply unified auth to routes that need authentication
// Use optionalAuth for search (public) and unifiedAuthMiddleware for user-specific operations

// POST /rides - Publish a new ride using current schema + unified auth
router.post('/', unifiedAuthMiddleware, async (req, res) => {
  try {
    const b = req.body;
    // ENHANCED: Get user ID from unified auth system
    const uid = req.user?.id || req.auth?.userId || b.driver_id || b.uid;
    
    if (!uid) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    console.log('Publish request body:', JSON.stringify(b, null, 2));
    console.log('Authenticated user:', req.user?.id, 'Provider:', req.authProvider);

    // Handle route creation/lookup with better error handling
    let routeId = null;
    if (b.from && b.to) {
      try {
        // First check for existing route
        const { data: existingRoute } = await supabase
          .from('routes')
          .select('id')
          .ilike('origin', b.from)
          .ilike('destination', b.to)
          .limit(1)
          .maybeSingle();

        if (existingRoute) {
          routeId = existingRoute.id;
          console.log('Using existing route:', routeId);
        } else {
          // Create new route with unique name including timestamp
          const routeName = `${b.from} to ${b.to}`;
          const { data: newRoute, error: routeError } = await supabase
            .from('routes')
            .insert({
              name: routeName,
              origin: b.from,
              destination: b.to,
              is_active: true,
              created_at: new Date().toISOString()
            })
            .select('id')
            .single();
          
          if (routeError) {
            console.error('Route creation error:', routeError);
            return res.status(400).json({ 
              error: 'Failed to create route: ' + routeError.message,
              details: routeError
            });
          }
          
          routeId = newRoute.id;
          console.log('Created new route:', routeId);
        }
      } catch (routeErr) {
        console.error('Route handling error:', routeErr);
        return res.status(400).json({ 
          error: 'Route processing failed: ' + routeErr.message 
        });
      }
    }

    // Handle datetime properly - support multiple input formats
    let departDate, departTime;
    try {
      if (b.when) {
        const departDateTime = new Date(b.when);
        if (isNaN(departDateTime.getTime())) {
          throw new Error('Invalid datetime format');
        }
        departDate = departDateTime.toISOString().split('T')[0];
        departTime = departDateTime.toTimeString().split(' ')[0];
      } else if (b.depart_date && b.depart_time) {
        departDate = b.depart_date;
        departTime = b.depart_time;
      } else {
        // Default to tomorrow at 9 AM
        const tomorrow = new Date();
        tomorrow.setDate(tomorrow.getDate() + 1);
        tomorrow.setHours(9, 0, 0, 0);
        departDate = tomorrow.toISOString().split('T')[0];
        departTime = '09:00:00';
      }
    } catch (dateErr) {
      console.error('Date parsing error:', dateErr);
      return res.status(400).json({ 
        error: 'Invalid date/time format. Use ISO format or provide depart_date/depart_time' 
      });
    }

    // Prepare ride data using current schema
    const rideData = {
      driver_id: uid, // ENHANCED: Use unified user ID
      route_id: routeId,
      depart_date: departDate,
      depart_time: departTime,
      seats_total: parseInt(b.seats) || parseInt(b.seats_total) || 1,
      seats_available: parseInt(b.seats) || parseInt(b.seats_total) || 1,
      price_per_seat_inr: parseInt(b.price) || parseInt(b.price_per_seat_inr) || parseInt(b.price_inr) || 0,
      ride_type: b.pool || b.ride_type || 'private_pool',
      allow_auto_confirm: b.auto_approve !== false && b.allow_auto_confirm !== false,
      car_make: b.car_make || null,
      car_model: b.car_model || null,
      car_plate: b.car_plate || null,
      notes: b.notes || null,
      status: 'published',
      is_active: true,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    console.log('Creating ride with data:', JSON.stringify(rideData, null, 2));

    // Insert the ride
    const { data: rideResult, error: rideError } = await supabase
      .from('rides')
      .insert(rideData)
      .select(`
        *,
        routes(id, name, origin, destination)
      `)
      .single();
      
    if (rideError) {
      console.error('Ride creation error:', rideError);
      return res.status(400).json({ 
        error: 'Failed to create ride: ' + rideError.message,
        details: rideError
      });
    }
    
    console.log('Ride created successfully:', rideResult);
    
    // Return in legacy format for app compatibility
    const response = {
      id: rideResult.id,
      from: rideResult.routes?.origin || b.from || 'Unknown',
      to: rideResult.routes?.destination || b.to || 'Unknown',
      when: `${rideResult.depart_date} ${rideResult.depart_time}`,
      seats: rideResult.seats_total,
      seats_available: rideResult.seats_available,
      price: rideResult.price_per_seat_inr,
      pool: rideResult.ride_type,
      driver_id: rideResult.driver_id,
      status: rideResult.status,
      notes: rideResult.notes,
      auto_approve: rideResult.allow_auto_confirm,
      created_at: rideResult.created_at,
      // ENHANCED: Add auth provider info for debugging
      auth_provider: req.authProvider
    };

    res.json(response);
  } catch (e) {
    console.error('Publish ride error:', e);
    res.status(500).json({ 
      error: 'Internal server error: ' + e.message,
      stack: process.env.NODE_ENV === 'development' ? e.stack : undefined
    });
  }
});

// GET /rides/search - Search rides using current schema (public access with optional auth)
router.get('/search', optionalAuth, async (req, res) => {
  try {
    const { 
      from, to, when, type, driver_id, limit = 50
    } = req.query;
    
    console.log('Search params:', { from, to, when, type, driver_id, limit });
    // ENHANCED: Log if user is authenticated
    if (req.user) {
      console.log('Search by authenticated user:', req.user.id, 'Provider:', req.authProvider);
    }
    
    // Build the main query
    let query = supabase
      .from('rides')
      .select(`
        id, depart_date, depart_time, 
        price_per_seat_inr, seats_total, seats_available, 
        ride_type, allow_auto_confirm, driver_id, notes, status,
        created_at, updated_at,
        routes(id, name, origin, destination)
      `);
    
    // Apply filters
    if (from || to) {
      // First get matching route IDs
      let routeQuery = supabase.from('routes').select('id');
      
      if (from) {
        routeQuery = routeQuery.ilike('origin', `%${from}%`);
      }
      if (to) {
        routeQuery = routeQuery.ilike('destination', `%${to}%`);
      }
      
      const { data: routes, error: routeError } = await routeQuery;
      
      if (routeError) {
        console.error('Route search error:', routeError);
        return res.status(400).json({ error: 'Route search failed: ' + routeError.message });
      }
      
      if (routes && routes.length > 0) {
        const routeIds = routes.map(r => r.id);
        query = query.in('route_id', routeIds);
      } else {
        // No matching routes found
        console.log('No matching routes found for from:', from, 'to:', to);
        return res.json([]);
      }
    }
    
    // Date search
    if (when) {
      try {
        const searchDate = when.includes('T') ? when.split('T')[0] : when;
        query = query.eq('depart_date', searchDate);
      } catch (e) {
        console.error('Date parsing error:', e);
        return res.status(400).json({ error: 'Invalid date format. Use YYYY-MM-DD' });
      }
    }
    
    // Ride type filter
    if (type && type !== 'all') {
      query = query.eq('ride_type', type);
    }
    
    // Driver filter (for "my rides") - ENHANCED: Support unified auth
    if (driver_id) {
      query = query.eq('driver_id', driver_id);
    } else if (req.query.my_rides === 'true' && req.user?.id) {
      // ENHANCED: Support "my rides" with unified auth
      query = query.eq('driver_id', req.user.id);
    }
    
    // Apply final filters and sorting
    query = query
      .eq('status', 'published')
      .eq('is_active', true)
      .gt('seats_available', 0)
      .order('depart_date', { ascending: true })
      .order('depart_time', { ascending: true })
      .limit(parseInt(limit));

    const { data, error } = await query;
    
    if (error) {
      console.error('Search rides error:', error);
      return res.status(400).json({ 
        error: 'Search failed: ' + error.message,
        details: error
      });
    }
    
    console.log('Found rides:', data?.length || 0);
    
    // Format for legacy compatibility
    const formatted = (data || []).map(ride => ({
      id: ride.id,
      from: ride.routes?.origin || 'Unknown',
      to: ride.routes?.destination || 'Unknown',
      fromCity: ride.routes?.origin || 'Unknown',
      toCity: ride.routes?.destination || 'Unknown',
      when: `${ride.depart_date} ${ride.depart_time}`,
      seats: ride.seats_total,
      seats_available: ride.seats_available,
      price: ride.price_per_seat_inr,
      price_per_seat_inr: ride.price_per_seat_inr,
      pool: ride.ride_type,
      ride_type: ride.ride_type,
      driver_id: ride.driver_id,
      status: ride.status,
      notes: ride.notes,
      auto_approve: ride.allow_auto_confirm,
      allow_auto_confirm: ride.allow_auto_confirm,
      booked: false, // Legacy field
      created_at: ride.created_at,
      // Additional fields for better display
      depart_date: ride.depart_date,
      depart_time: ride.depart_time,
      route: ride.routes
    }));
    
    res.json(formatted);
  } catch (e) {
    console.error('Search rides error:', e);
    res.status(500).json({ 
      error: 'Internal server error: ' + e.message,
      stack: process.env.NODE_ENV === 'development' ? e.stack : undefined
    });
  }
});

// GET /rides/:id - Get single ride (public access)
router.get('/:id', optionalAuth, async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('rides')
      .select(`
        *, 
        routes(id, name, origin, destination),
        users_app!driver_id(full_name, phone, email)
      `)
      .eq('id', req.params.id)
      .single();
      
    if (error) {
      console.error('Get ride error:', error);
      return res.status(400).json({ 
        error: 'Ride not found: ' + error.message 
      });
    }
    
    // Format for legacy compatibility
    const formatted = {
      id: data.id,
      from: data.routes?.origin || 'Unknown',
      to: data.routes?.destination || 'Unknown',
      fromCity: data.routes?.origin || 'Unknown',
      toCity: data.routes?.destination || 'Unknown',
      when: `${data.depart_date} ${data.depart_time}`,
      seats: data.seats_total,
      seats_available: data.seats_available,
      price: data.price_per_seat_inr,
      price_per_seat_inr: data.price_per_seat_inr,
      pool: data.ride_type,
      ride_type: data.ride_type,
      driver_id: data.driver_id,
      driver_name: data.users_app?.full_name,
      driver_phone: data.users_app?.phone,
      driver_email: data.users_app?.email,
      status: data.status,
      notes: data.notes,
      auto_approve: data.allow_auto_confirm,
      allow_auto_confirm: data.allow_auto_confirm,
      booked: false, // Legacy field
      created_at: data.created_at,
      updated_at: data.updated_at,
      // Additional fields
      depart_date: data.depart_date,
      depart_time: data.depart_time,
      car_make: data.car_make,
      car_model: data.car_model,
      car_plate: data.car_plate,
      route: data.routes,
      // ENHANCED: Show if current user is viewing their own ride
      is_owner: req.user?.id === data.driver_id
    };
    
    res.json(formatted);
  } catch (e) {
    console.error('Get ride error:', e);
    res.status(500).json({ 
      error: 'Internal server error: ' + e.message 
    });
  }
});

// PUT /rides/:id - Update ride (requires authentication)
router.put('/:id', unifiedAuthMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;
    // ENHANCED: Use unified auth user ID
    const uid = req.user?.id || req.auth?.userId;

    // Get existing ride to check ownership
    const { data: existingRide, error: fetchError } = await supabase
      .from('rides')
      .select('driver_id')
      .eq('id', id)
      .single();

    if (fetchError) {
      return res.status(404).json({ error: 'Ride not found' });
    }

    if (existingRide.driver_id !== uid) {
      return res.status(403).json({ error: 'Not authorized to update this ride' });
    }

    // Prepare update data
    const updateData = {
      updated_at: new Date().toISOString()
    };

    // Handle allowed updates
    if (updates.seats !== undefined) {
      updateData.seats_total = parseInt(updates.seats);
      updateData.seats_available = parseInt(updates.seats);
    }
    if (updates.price !== undefined) {
      updateData.price_per_seat_inr = parseInt(updates.price);
    }
    if (updates.notes !== undefined) {
      updateData.notes = updates.notes;
    }
    if (updates.status !== undefined) {
      updateData.status = updates.status;
    }
    if (updates.allow_auto_confirm !== undefined) {
      updateData.allow_auto_confirm = updates.allow_auto_confirm;
    }

    const { data, error } = await supabase
      .from('rides')
      .update(updateData)
      .eq('id', id)
      .select(`
        *,
        routes(origin, destination)
      `)
      .single();

    if (error) {
      return res.status(400).json({ error: 'Update failed: ' + error.message });
    }

    // Return formatted response
    const response = {
      id: data.id,
      from: data.routes?.origin || 'Unknown',
      to: data.routes?.destination || 'Unknown',
      when: `${data.depart_date} ${data.depart_time}`,
      seats: data.seats_total,
      seats_available: data.seats_available,
      price: data.price_per_seat_inr,
      pool: data.ride_type,
      driver_id: data.driver_id,
      status: data.status,
      notes: data.notes,
      updated_at: data.updated_at,
      // ENHANCED: Add auth info
      auth_provider: req.authProvider
    };

    res.json(response);
  } catch (e) {
    console.error('Update ride error:', e);
    res.status(500).json({ error: 'Internal server error: ' + e.message });
  }
});

// DELETE /rides/:id - Cancel/delete ride (requires authentication)
router.delete('/:id', unifiedAuthMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    // ENHANCED: Use unified auth user ID
    const uid = req.user?.id || req.auth?.userId;

    // Get existing ride to check ownership
    const { data: existingRide, error: fetchError } = await supabase
      .from('rides')
      .select('driver_id, status')
      .eq('id', id)
      .single();

    if (fetchError) {
      return res.status(404).json({ error: 'Ride not found' });
    }

    if (existingRide.driver_id !== uid) {
      return res.status(403).json({ error: 'Not authorized to cancel this ride' });
    }

    // Update status to cancelled instead of deleting
    const { data, error } = await supabase
      .from('rides')
      .update({ 
        status: 'cancelled',
        is_active: false,
        updated_at: new Date().toISOString()
      })
      .eq('id', id)
      .select()
      .single();

    if (error) {
      return res.status(400).json({ error: 'Cancellation failed: ' + error.message });
    }

    res.json({ 
      success: true, 
      message: 'Ride cancelled successfully',
      ride_id: id,
      // ENHANCED: Add auth info
      auth_provider: req.authProvider
    });
  } catch (e) {
    console.error('Delete ride error:', e);
    res.status(500).json({ error: 'Internal server error: ' + e.message });
  }
});

// GET /rides - Legacy compatibility endpoint
router.get('/', optionalAuth, async (req, res) => {
  // Redirect to search with same params
  try {
    req.url = '/search' + (req.url.includes('?') ? req.url.substring(req.url.indexOf('?')) : '');
    req.originalUrl = req.url;
    return router.handle(req, res);
  } catch (e) {
    console.error('Legacy route error:', e);
    res.json([]);
  }
});

module.exports = router;
