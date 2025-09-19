// routes/bookings.js - UPDATED VERSION
const express = require('express');
const router = express.Router();
const bookingController = require('../controllers/bookingController');
const supabaseAuth = require('../middleware/supabaseAuth');
const { supabase } = require('../supabase');

// Apply authentication middleware to all routes
router.use(supabaseAuth.optional);

// Create new booking with deposit (with fallback)
router.post('/', async (req, res) => {
  try {
    // Try the stored procedure approach first
    await bookingController.createBooking(req, res);
  } catch (error) {
    console.log('Stored procedure failed, using fallback:', error.message);
    // If stored procedure doesn't exist, use fallback
    if (error.message.includes('function') || error.message.includes('does not exist')) {
      await bookingController.createBookingFallback(req, res);
    } else {
      throw error;
    }
  }
});

// Get booking details
router.get('/:bookingId', bookingController.getBookingDetails);

// Cancel booking
router.delete('/:bookingId', bookingController.cancelBooking);

// Get user's bookings
router.get('/user/my-bookings', bookingController.getUserBookings);

// Check wallet balance before booking
router.get('/user/wallet-check', bookingController.checkWalletBalance);

// Driver routes - approve/reject bookings
router.patch('/:bookingId/status', bookingController.updateBookingStatus);

// Get driver's booking requests
router.get('/driver/requests', bookingController.getDriverBookings);

// Get cancellation policy for ride type
router.get('/policy/:rideType', bookingController.getCancellationPolicy);

// Get cancellation penalty preview
router.get('/:bookingId/cancellation-preview', async (req, res) => {
  try {
    const { bookingId } = req.params;
    const { cancelledBy = 'rider' } = req.query;

    // Try using stored procedure first
    const { data, error } = await supabase
      .rpc('calculate_cancellation_penalty_preview', {
        p_booking_id: bookingId,
        p_cancelled_by: cancelledBy
      });

    if (error) {
      // Fallback to manual calculation
      return await calculatePenaltyFallback(bookingId, cancelledBy, res);
    }

    res.json({
      success: true,
      preview: data
    });

  } catch (error) {
    console.error('Cancellation preview error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

// Manual ride completion (for testing)
router.post('/:rideId/complete', async (req, res) => {
  try {
    const { rideId } = req.params;
    const uid = req.auth?.userId || req.user?.id;
    
    if (!uid) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    // Verify user is the driver
    const { data: ride, error: rideErr } = await supabase
      .from('rides')
      .select('driver_id')
      .eq('id', rideId)
      .single();

    if (rideErr || !ride) {
      return res.status(404).json({ error: 'Ride not found' });
    }

    if (ride.driver_id !== uid) {
      return res.status(403).json({ error: 'Only the driver can complete this ride' });
    }

    // Try stored procedure first
    const { data, error } = await supabase
      .rpc('process_ride_completion', { p_ride_id: rideId });

    if (error) {
      return res.status(400).json({
        success: false,
        message: error.message
      });
    }

    res.json({
      success: true,
      ...data
    });

  } catch (error) {
    console.error('Ride completion error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

// Fallback function for penalty calculation
async function calculatePenaltyFallback(bookingId, cancelledBy, res) {
  try {
    // Get booking and ride details
    const { data: booking, error: bookingErr } = await supabase
      .from('bookings')
      .select(`
        id, deposit_inr, status,
        rides!inner(depart_date, depart_time, ride_type)
      `)
      .eq('id', bookingId)
      .single();

    if (bookingErr || !booking) {
      return res.status(404).json({
        success: false,
        message: 'Booking not found'
      });
    }

    // Calculate hours until departure
    const departureDateTime = new Date(`${booking.rides.depart_date}T${booking.rides.depart_time}`);
    const now = new Date();
    const hoursUntilDeparture = (departureDateTime - now) / (1000 * 60 * 60);

    // Determine penalty rate
    let penaltyRate = 0;
    if (hoursUntilDeparture >= 12) {
      penaltyRate = 0;
    } else if (hoursUntilDeparture >= 6) {
      penaltyRate = 30;
    } else {
      penaltyRate = 50;
    }

    // Calculate amounts
    let penaltyAmount = 0;
    let refundAmount = booking.deposit_inr;

    if (cancelledBy === 'rider') {
      penaltyAmount = Math.floor(booking.deposit_inr * penaltyRate / 100);
      refundAmount = booking.deposit_inr - penaltyAmount;
    }

    return res.json({
      success: true,
      preview: {
        booking_id: bookingId,
        hours_until_departure: Math.round(hoursUntilDeparture * 100) / 100,
        penalty_rate: penaltyRate,
        deposit_amount: booking.deposit_inr,
        penalty_amount: penaltyAmount,
        refund_amount: refundAmount,
        cancelled_by: cancelledBy
      }
    });

  } catch (error) {
    console.error('Fallback penalty calculation error:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to calculate penalty'
    });
  }
}

// Test endpoint to check deposit system status
router.get('/system/deposit-status', async (req, res) => {
  try {
    const uid = req.auth?.userId || req.user?.id;
    
    if (!uid) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    // Check wallet
    const { data: wallet, error: walletErr } = await supabase
      .from('wallets')
      .select('*')
      .eq('user_id', uid)
      .single();

    // Check recent transactions
    const { data: transactions, error: txErr } = await supabase
      .from('wallet_transactions')
      .select('*')
      .eq('user_id', uid)
      .order('created_at', { ascending: false })
      .limit(5);

    // Check booking deposits
    const { data: deposits, error: depositErr } = await supabase
      .from('booking_deposits')
      .select('*')
      .eq('user_id', uid)
      .order('created_at', { ascending: false })
      .limit(3);

    res.json({
      success: true,
      wallet: wallet || null,
      wallet_error: walletErr?.message || null,
      recent_transactions: transactions || [],
      transactions_error: txErr?.message || null,
      booking_deposits: deposits || [],
      deposits_error: depositErr?.message || null
    });

  } catch (error) {
    console.error('Deposit status check error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

module.exports = router;