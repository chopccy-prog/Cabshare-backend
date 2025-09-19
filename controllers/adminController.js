const { supabase } = require('../supabase');

class AdminController {
  
  // Dashboard statistics
  async getDashboardStats(req, res) {
    try {
      const [ridesCount, bookingsCount, usersCount, revenue] = await Promise.all([
        supabase.from('rides').select('*', { count: 'exact', head: true }),
        supabase.from('bookings').select('*', { count: 'exact', head: true }),
        supabase.from('profiles').select('*', { count: 'exact', head: true }),
        supabase.from('wallet_transactions')
          .select('amount_inr')
          .gte('created_at', new Date(new Date().getFullYear(), new Date().getMonth(), 1).toISOString())
          .eq('tx_type', 'transfer_in')
      ]);

      const totalRevenue = revenue.data?.reduce((sum, tx) => sum + (tx.amount_inr || 0), 0) || 0;

      res.json({
        success: true,
        stats: {
          totalRides: ridesCount.count || 0,
          totalBookings: bookingsCount.count || 0,
          totalUsers: usersCount.count || 0,
          totalRevenue: totalRevenue
        }
      });

    } catch (error) {
      console.error('Dashboard stats error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Cancellation Policies Management
  async getCancellationPolicies(req, res) {
    try {
      const { data, error } = await supabase
        .from('cancellation_policies')
        .select('*')
        .order('ride_type', { ascending: true });

      if (error) throw error;

      res.json({
        success: true,
        policies: data || []
      });

    } catch (error) {
      console.error('Get policies error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  async updateCancellationPolicy(req, res) {
    try {
      const {
        rideType,
        actor,
        tier1Hours,
        tier1Penalty,
        tier2Hours,
        tier2Penalty,
        tier3Penalty
      } = req.body;

      const { data, error } = await supabase
        .rpc('update_cancellation_policy', {
          p_ride_type: rideType,
          p_actor: actor,
          p_tier_1_hours: tier1Hours,
          p_tier_1_penalty_pct: tier1Penalty,
          p_tier_2_hours: tier2Hours,
          p_tier_2_penalty_pct: tier2Penalty,
          p_tier_3_hours: 0,
          p_tier_3_penalty_pct: tier3Penalty
        });

      if (error) throw error;

      res.json({
        success: true,
        message: 'Policy updated successfully'
      });

    } catch (error) {
      console.error('Update policy error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  async deleteCancellationPolicy(req, res) {
    try {
      const { rideType, actor } = req.params;

      const { error } = await supabase
        .from('cancellation_policies')
        .delete()
        .eq('ride_type', rideType)
        .eq('actor', actor);

      if (error) throw error;

      res.json({
        success: true,
        message: 'Policy deleted successfully'
      });

    } catch (error) {
      console.error('Delete policy error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Cities Management
  async getCities(req, res) {
    try {
      const { data, error } = await supabase
        .from('cities')
        .select('*')
        .order('name', { ascending: true });

      if (error) throw error;

      res.json({
        success: true,
        cities: data || []
      });

    } catch (error) {
      console.error('Get cities error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  async createCity(req, res) {
    try {
      const { name, state, country = 'India' } = req.body;

      if (!name) {
        return res.status(400).json({
          success: false,
          message: 'City name is required'
        });
      }

      const { data, error } = await supabase
        .from('cities')
        .insert({
          name: name.trim(),
          state: state?.trim(),
          country: country.trim()
        })
        .select()
        .single();

      if (error) throw error;

      res.json({
        success: true,
        city: data,
        message: 'City created successfully'
      });

    } catch (error) {
      console.error('Create city error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  async deleteCity(req, res) {
    try {
      const { cityId } = req.params;

      const { error } = await supabase
        .from('cities')
        .delete()
        .eq('id', cityId);

      if (error) throw error;

      res.json({
        success: true,
        message: 'City deleted successfully'
      });

    } catch (error) {
      console.error('Delete city error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Routes Management
  async getRoutes(req, res) {
    try {
      const { data, error } = await supabase
        .from('routes')
        .select(`
          *,
          from_city:from_city_id(id, name, state),
          to_city:to_city_id(id, name, state)
        `)
        .order('name', { ascending: true });

      if (error) throw error;

      res.json({
        success: true,
        routes: data || []
      });

    } catch (error) {
      console.error('Get routes error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  async createRoute(req, res) {
    try {
      const { fromCityId, toCityId, name } = req.body;

      if (!fromCityId || !toCityId || !name) {
        return res.status(400).json({
          success: false,
          message: 'From city, to city, and name are required'
        });
      }

      // Get city names for origin/destination
      const { data: cities, error: citiesError } = await supabase
        .from('cities')
        .select('id, name')
        .in('id', [fromCityId, toCityId]);

      if (citiesError) throw citiesError;

      const fromCity = cities.find(c => c.id === fromCityId);
      const toCity = cities.find(c => c.id === toCityId);

      const { data, error } = await supabase
        .from('routes')
        .insert({
          from_city_id: fromCityId,
          to_city_id: toCityId,
          name: name.trim(),
          origin: fromCity?.name,
          destination: toCity?.name,
          code: name.substring(0, 10).toUpperCase()
        })
        .select()
        .single();

      if (error) throw error;

      res.json({
        success: true,
        route: data,
        message: 'Route created successfully'
      });

    } catch (error) {
      console.error('Create route error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  async deleteRoute(req, res) {
    try {
      const { routeId } = req.params;

      // Delete route stops first
      await supabase
        .from('route_stops')
        .delete()
        .eq('route_id', routeId);

      // Delete route
      const { error } = await supabase
        .from('routes')
        .delete()
        .eq('id', routeId);

      if (error) throw error;

      res.json({
        success: true,
        message: 'Route deleted successfully'
      });

    } catch (error) {
      console.error('Delete route error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Stops Management
  async getStops(req, res) {
    try {
      const { data, error } = await supabase
        .from('route_stops')
        .select(`
          *,
          routes(id, name, origin, destination)
        `)
        .order('route_id', { ascending: true })
        .order('stop_order', { ascending: true });

      if (error) throw error;

      res.json({
        success: true,
        stops: data || []
      });

    } catch (error) {
      console.error('Get stops error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  async createStop(req, res) {
    try {
      const { routeId, stopName, stopOrder } = req.body;

      if (!routeId || !stopName || !stopOrder) {
        return res.status(400).json({
          success: false,
          message: 'Route ID, stop name, and stop order are required'
        });
      }

      const { data, error } = await supabase
        .from('route_stops')
        .insert({
          route_id: routeId,
          stop_name: stopName.trim(),
          stop_order: parseInt(stopOrder),
          seq: parseInt(stopOrder)
        })
        .select()
        .single();

      if (error) throw error;

      res.json({
        success: true,
        stop: data,
        message: 'Stop created successfully'
      });

    } catch (error) {
      console.error('Create stop error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  async deleteStop(req, res) {
    try {
      const { stopId } = req.params;

      const { error } = await supabase
        .from('route_stops')
        .delete()
        .eq('id', stopId);

      if (error) throw error;

      res.json({
        success: true,
        message: 'Stop deleted successfully'
      });

    } catch (error) {
      console.error('Delete stop error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Users Management
  async getUsers(req, res) {
    try {
      const { page = 1, limit = 100 } = req.query;
      const offset = (page - 1) * limit;

      const { data, error, count } = await supabase
        .from('profiles')
        .select('*', { count: 'exact' })
        .order('created_at', { ascending: false })
        .range(offset, offset + limit - 1);

      if (error) throw error;

      res.json({
        success: true,
        users: data || [],
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: count
        }
      });

    } catch (error) {
      console.error('Get users error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  async updateUserVerification(req, res) {
    try {
      const { userId } = req.params;
      const { verified } = req.body;

      const { error } = await supabase
        .from('profiles')
        .update({ is_verified: verified })
        .eq('user_id', userId);

      if (error) throw error;

      res.json({
        success: true,
        message: `User ${verified ? 'verified' : 'unverified'} successfully`
      });

    } catch (error) {
      console.error('Update user verification error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Financial Management
  async getFinancialSummary(req, res) {
    try {
      const { data, error } = await supabase.rpc('get_financial_summary');

      if (error) throw error;

      res.json({
        success: true,
        summary: data
      });

    } catch (error) {
      console.error('Get financial summary error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  async getPendingSettlements(req, res) {
    try {
      const { data, error } = await supabase
        .from('settlements')
        .select(`
          *,
          profiles:user_id(full_name, phone)
        `)
        .eq('status', 'requested')
        .order('requested_at', { ascending: true });

      if (error) throw error;

      res.json({
        success: true,
        settlements: data || []
      });

    } catch (error) {
      console.error('Get pending settlements error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  async approveSettlement(req, res) {
    try {
      const { settlementId } = req.params;

      const { data, error } = await supabase.rpc('process_settlement_payout', {
        p_settlement_id: settlementId
      });

      if (error) throw error;

      res.json({
        success: true,
        message: 'Settlement approved successfully',
        data
      });

    } catch (error) {
      console.error('Approve settlement error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  async rejectSettlement(req, res) {
    try {
      const { settlementId } = req.params;
      const { reason } = req.body;

      const { data, error } = await supabase.rpc('reject_settlement_request', {
        p_settlement_id: settlementId,
        p_reason: reason || 'Rejected by admin'
      });

      if (error) throw error;

      res.json({
        success: true,
        message: 'Settlement rejected successfully',
        data
      });

    } catch (error) {
      console.error('Reject settlement error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Recent Activity
  async getRecentActivity(req, res) {
    try {
      const { limit = 50 } = req.query;

      const { data, error } = await supabase
        .from('bookings')
        .select(`
          *,
          rides:ride_id(from, to),
          profiles:rider_id(full_name)
        `)
        .order('created_at', { ascending: false })
        .limit(parseInt(limit));

      if (error) throw error;

      res.json({
        success: true,
        activity: data || []
      });

    } catch (error) {
      console.error('Get recent activity error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }
}

module.exports = new AdminController();
