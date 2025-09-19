// controllers/bookingController.js - UPDATED FOR DATABASE CLEANUP
// Uses consolidated column names after database cleanup
const { supabase } = require('../supabase');

// Helper function to format ride data with backward compatibility
const formatRideData = (r) => ({
  ...r,
  // New consolidated fields (primary)
  from_city_id: r.from_city_id,
  to_city_id: r.to_city_id,
  depart_date: r.depart_date,
  depart_time: r.depart_time,
  seats_total: r.seats_total,
  seats_available: r.seats_available,
  price_per_seat_inr: r.price_per_seat_inr,
  ride_type: r.ride_type,
  allow_auto_confirm: r.allow_auto_confirm,
  
  // Backward compatibility (deprecated)
  from: r.from_city_name || r.origin || 'Unknown',
  to: r.to_city_name || r.destination || 'Unknown',
  seats: r.seats_total,
  price: r.price_per_seat_inr,
  pool: r.ride_type,
  auto_approve: r.allow_auto_confirm,
});

/**
 * Create a new booking with auto-approval logic and proper wallet integration
 */
async function createBooking(req, res) {
  try {
    const uid = req.auth?.userId || req.user?.id || req.body.rider_id || req.query.uid;
    console.log('Booking request - uid:', uid);
    
    if (!uid) {
      return res.status(401).json({ 
        error: 'Authentication required',
        message: 'Please sign in to book a ride'
      });
    }

    const { ride_id } = req.body;
    const seats = req.body.seats_booked || req.body.seats || 1;
    
    if (!ride_id || !seats) {
      return res.status(400).json({ 
        error: 'Missing required fields',
        message: 'ride_id and seats_booked are required',
        received: { ride_id, seats }
      });
    }

    // Try the stored procedure approach first
    try {
      const { data: transactionResult, error: transactionError } = await supabase.rpc(
        'create_booking_with_deposit',
        {
          p_ride_id: ride_id,
          p_rider_id: uid,
          p_seats_requested: seats,
          p_from_stop_id: req.body.from_stop_id || null,
          p_to_stop_id: req.body.to_stop_id || null
        }
      );

      if (!transactionError) {
        return res.json({
          success: true,
          ...transactionResult,
          message: transactionResult.status === 'confirmed' 
            ? 'Booking confirmed automatically!' 
            : 'Booking request sent to driver'
        });
      }
    } catch (procError) {
      console.log('Stored procedure failed, using fallback:', procError.message);
    }

    // Fallback method - manual booking creation
    return await createBookingFallback(req, res);

  } catch (e) {
    console.error('Booking error:', e);
    return res.status(500).json({ 
      error: 'Internal server error',
      message: e.message
    });
  }
}

/**
 * Fallback create booking function using cleaned schema
 */
async function createBookingFallback(req, res) {
  try {
    const uid = req.auth?.userId || req.user?.id || req.body.rider_id;
    const { ride_id } = req.body;
    const seats = req.body.seats_booked || req.body.seats || 1;
    
    // UPDATED: Fetch ride details using cleaned schema
    const { data: ride, error: rideErr } = await supabase
      .from('rides')
      .select(`
        id, driver_id, route_id, seats_available, seats_total, 
        price_per_seat_inr, status, ride_type, allow_auto_confirm,
        depart_date, depart_time, from_city_id, to_city_id,
        cities_from:from_city_id(name),
        cities_to:to_city_id(name)
      `)
      .eq('id', ride_id)
      .single();
      
    if (rideErr || !ride) {
      console.error('Ride fetch error:', rideErr);
      return res.status(404).json({ 
        error: 'Ride not found',
        message: rideErr?.message || 'The requested ride does not exist'
      });
    }

    // Validate ride availability
    if (ride.status !== 'published') {
      return res.status(400).json({
        error: 'Ride not available',
        message: 'This ride is no longer available for booking'
      });
    }

    if (ride.driver_id === uid) {
      return res.status(400).json({
        error: 'Cannot book own ride',
        message: 'You cannot book your own ride'
      });
    }

    const seatsAvail = ride.seats_available || ride.seats_total || 0;
    if (seats > seatsAvail) {
      return res.status(400).json({ 
        error: 'Insufficient seats',
        message: `Only ${seatsAvail} seats available, you requested ${seats}` 
      });
    }

    // Calculate pricing and deposit
    const pricePerSeat = ride.price_per_seat_inr || 0;
    const totalFare = pricePerSeat * seats;

    // Calculate deposit based on ride type
    let depositAmount = 0;
    if (ride.ride_type === 'commercial_pool' || ride.ride_type === 'commercial_full') {
      depositAmount = Math.floor(totalFare * 0.3); // 30% for commercial
    } else {
      depositAmount = Math.floor(totalFare * 0.1); // 10% for private
    }

    // Check wallet balance
    const { data: wallet, error: walletErr } = await supabase
      .from('wallets')
      .select('balance_available_inr')
      .eq('user_id', uid)
      .single();

    if (walletErr || wallet.balance_available_inr < depositAmount) {
      return res.status(400).json({
        error: 'Insufficient wallet balance',
        message: `Deposit required: ₹${depositAmount}, Available: ₹${wallet?.balance_available_inr || 0}`
      });
    }

    // Determine booking status based on auto-approval
    const autoConfirm = ride.allow_auto_confirm || false;
    const status = autoConfirm ? 'confirmed' : 'pending';
    let newSeatsAvail = seatsAvail;
    
    if (status === 'confirmed') {
      newSeatsAvail = seatsAvail - seats;
    }

    // Get stop IDs if not provided
    let fromStopId = req.body.from_stop_id;
    let toStopId = req.body.to_stop_id;

    if (!fromStopId || !toStopId) {
      if (ride.route_id) {
        const { data: routeStops } = await supabase
          .from('route_stops')
          .select('id, stop_id, stop_order')
          .eq('route_id', ride.route_id)
          .order('stop_order', { ascending: true });

        if (routeStops && routeStops.length >= 2) {
          fromStopId = fromStopId || routeStops[0].stop_id || routeStops[0].id;
          toStopId = toStopId || routeStops[routeStops.length - 1].stop_id || routeStops[routeStops.length - 1].id;
        }
      }
    }

    // UPDATED: Create booking with cleaned field names
    const bookingData = {
      ride_id,
      rider_id: uid,
      seats_booked: seats,                    // Using consolidated field
      fare_total_inr: totalFare,
      rider_deposit_inr: depositAmount,       // Using consolidated field
      status,
      ...(fromStopId && { from_stop_id: fromStopId }),
      ...(toStopId && { to_stop_id: toStopId })
    };

    console.log('Creating booking with cleaned schema:', bookingData);

    const { data: booking, error: bookingErr } = await supabase
      .from('bookings')
      .insert(bookingData)
      .select()
      .single();
      
    if (bookingErr) {
      console.error('Booking creation error:', bookingErr);
      return res.status(400).json({ 
        error: 'Failed to create booking',
        message: bookingErr.message
      });
    }

    // Reserve deposit from wallet
    try {
      await supabase
        .from('wallets')
        .update({
          balance_available_inr: wallet.balance_available_inr - depositAmount,
          balance_reserved_inr: depositAmount,
          updated_at: new Date().toISOString()
        })
        .eq('user_id', uid);

      // Record transaction
      await supabase
        .from('wallet_transactions')
        .insert({
          user_id: uid,
          tx_type: 'reserve',
          amount_inr: depositAmount,
          note: `Deposit for booking ${booking.id}`,
          ref_booking_id: booking.id,
          created_at: new Date().toISOString()
        });
    } catch (walletError) {
      // If wallet operations fail, cancel the booking
      await supabase.from('bookings').delete().eq('id', booking.id);
      return res.status(400).json({
        error: 'Failed to reserve deposit',
        message: walletError.message
      });
    }

    // Update seat availability if confirmed
    if (status === 'confirmed') {
      await supabase
        .from('rides')
        .update({ seats_available: newSeatsAvail })
        .eq('id', ride_id);
    }

    return res.json({
      success: true,
      id: booking.id,
      ride_id: booking.ride_id,
      rider_id: booking.rider_id,
      seats: booking.seats_booked,
      status: booking.status,
      fare_total_inr: booking.fare_total_inr,
      deposit_inr: booking.rider_deposit_inr,
      auto_approved: status === 'confirmed',
      message: status === 'confirmed' 
        ? 'Booking confirmed automatically!' 
        : 'Booking request sent to driver.'
    });

  } catch (e) {
    console.error('Booking fallback error:', e);
    return res.status(500).json({ 
      error: 'Internal server error',
      message: e.message
    });
  }
}

/**
 * Get user's bookings using cleaned schema
 */
async function getUserBookings(req, res) {
  try {
    const uid = req.auth?.userId || req.user?.id || req.query.uid;
    if (!uid) {
      return res.status(401).json({ 
        error: 'Authentication required',
        message: 'Please sign in to view your bookings' 
      });
    }

    // UPDATED: Use cleaned field names
    const { data: bookings, error } = await supabase
      .from('bookings')
      .select(`
        id, ride_id, rider_id, seats_booked, status, 
        fare_total_inr, rider_deposit_inr, created_at
      `)
      .eq('rider_id', uid)
      .order('created_at', { ascending: false });
      
    if (error) {
      console.error('Bookings fetch error:', error);
      return res.status(400).json({ 
        error: 'Failed to fetch bookings',
        message: error.message 
      });
    }

    // Get ride details for each booking separately
    const result = [];
    for (const booking of bookings || []) {
      const { data: ride } = await supabase
        .from('rides')
        .select(`
          id, driver_id, depart_date, depart_time, seats_total,
          price_per_seat_inr, ride_type, car_make, car_model,
          from_city_id, to_city_id,
          cities_from:from_city_id(name),
          cities_to:to_city_id(name)
        `)
        .eq('id', booking.ride_id)
        .single();

      const enrichedRide = ride ? {
        ...ride,
        from_city_name: ride.cities_from?.name,
        to_city_name: ride.cities_to?.name,
      } : {};

      result.push({
        id: booking.id,
        ride_id: booking.ride_id,
        seats: booking.seats_booked,
        status: booking.status,
        fare_total_inr: booking.fare_total_inr,
        deposit_inr: booking.rider_deposit_inr,
        created_at: booking.created_at,
        ride: formatRideData(enrichedRide),
      });
    }

    return res.json(result);
  } catch (e) {
    console.error('Get user bookings error:', e);
    return res.status(500).json({ 
      error: 'Internal server error',
      message: e.message 
    });
  }
}

/**
 * Update booking status (approve/reject)
 */
async function updateBookingStatus(req, res) {
  try {
    const uid = req.auth?.userId || req.user?.id;
    const { bookingId } = req.params;
    const { status, action } = req.body;

    if (!uid) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    const newStatus = status || (action === 'approve' ? 'confirmed' : 'rejected');

    if (!['confirmed', 'rejected'].includes(newStatus)) {
      return res.status(400).json({ 
        error: 'Invalid status',
        message: 'Status must be "confirmed" or "rejected"'
      });
    }

    // Get booking details
    const { data: booking, error: bookingError } = await supabase
      .from('bookings')
      .select('id, ride_id, rider_id, seats_booked, status, rider_deposit_inr')
      .eq('id', bookingId)
      .single();

    if (bookingError || !booking) {
      return res.status(404).json({ error: 'Booking not found' });
    }

    // Get ride details to verify driver
    const { data: ride, error: rideError } = await supabase
      .from('rides')
      .select('id, driver_id, seats_available')
      .eq('id', booking.ride_id)
      .single();

    if (rideError || !ride || ride.driver_id !== uid) {
      return res.status(403).json({ error: 'Only the driver can approve/reject bookings' });
    }

    if (booking.status !== 'pending') {
      return res.status(400).json({ 
        error: 'Booking already processed',
        message: `Booking status is already ${booking.status}`
      });
    }

    // Update booking status
    await supabase
      .from('bookings')
      .update({ 
        status: newStatus,
        updated_at: new Date().toISOString()
      })
      .eq('id', bookingId);

    // If confirmed, update seat availability
    if (newStatus === 'confirmed') {
      const newSeatsAvail = (ride.seats_available || 0) - booking.seats_booked;
      await supabase
        .from('rides')
        .update({ seats_available: Math.max(0, newSeatsAvail) })
        .eq('id', booking.ride_id);
    }

    // If rejected, release deposit
    if (newStatus === 'rejected') {
      const { data: wallet } = await supabase
        .from('wallets')
        .select('balance_available_inr, balance_reserved_inr')
        .eq('user_id', booking.rider_id)
        .single();

      if (wallet) {
        await supabase
          .from('wallets')
          .update({
            balance_available_inr: (wallet.balance_available_inr || 0) + booking.rider_deposit_inr,
            balance_reserved_inr: Math.max(0, (wallet.balance_reserved_inr || 0) - booking.rider_deposit_inr)
          })
          .eq('user_id', booking.rider_id);

        await supabase
          .from('wallet_transactions')
          .insert({
            user_id: booking.rider_id,
            tx_type: 'refund',
            amount_inr: booking.rider_deposit_inr,
            note: `Refund for rejected booking ${booking.id}`,
            ref_booking_id: booking.id
          });
      }
    }

    return res.json({
      success: true,
      booking_id: bookingId,
      status: newStatus,
      message: newStatus === 'confirmed' 
        ? 'Booking approved successfully!' 
        : 'Booking rejected. Deposit refunded.'
    });

  } catch (e) {
    console.error('Update booking status error:', e);
    return res.status(500).json({ error: e.message });
  }
}

/**
 * Cancel booking
 */
async function cancelBooking(req, res) {
  try {
    const uid = req.auth?.userId || req.user?.id;
    const { bookingId } = req.params;

    if (!uid) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    const { data: booking, error: fetchErr } = await supabase
      .from('bookings')
      .select('*')
      .eq('id', bookingId)
      .single();

    if (fetchErr || !booking || booking.rider_id !== uid) {
      return res.status(403).json({ error: 'Access denied' });
    }

    // Update booking status to cancelled
    await supabase
      .from('bookings')
      .update({ status: 'cancelled' })
      .eq('id', bookingId);

    return res.json({ 
      success: true, 
      message: 'Booking cancelled successfully'
    });
  } catch (e) {
    console.error('Cancel booking error:', e);
    return res.status(500).json({ error: e.message });
  }
}

module.exports = {
  createBooking,
  createBookingFallback,
  getUserBookings,
  updateBookingStatus,
  cancelBooking
};
