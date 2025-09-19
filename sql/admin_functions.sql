-- Admin panel SQL functions

-- Function to get financial summary for admin dashboard
CREATE OR REPLACE FUNCTION get_financial_summary()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_total_balance numeric := 0;
  v_total_reserved numeric := 0;
  v_pending_settlements numeric := 0;
  v_monthly_revenue numeric := 0;
  v_current_month_start timestamptz;
BEGIN
  -- Calculate current month start
  v_current_month_start := date_trunc('month', now());

  -- Get total wallet balances
  SELECT 
    COALESCE(SUM(balance_available_inr), 0),
    COALESCE(SUM(balance_reserved_inr), 0)
  INTO v_total_balance, v_total_reserved
  FROM wallets;

  -- Get pending settlements amount
  SELECT COALESCE(SUM(amount_inr), 0) INTO v_pending_settlements
  FROM settlements
  WHERE status = 'requested';

  -- Get current month revenue (deposits and top-ups)
  SELECT COALESCE(SUM(amount_inr), 0) INTO v_monthly_revenue
  FROM wallet_transactions
  WHERE tx_type = 'transfer_in'
    AND created_at >= v_current_month_start;

  RETURN jsonb_build_object(
    'total_balance', v_total_balance,
    'total_reserved', v_total_reserved,
    'pending_settlements', v_pending_settlements,
    'monthly_revenue', v_monthly_revenue,
    'generated_at', now()
  );
END;
$$;

-- Function to get admin statistics
CREATE OR REPLACE FUNCTION get_admin_statistics()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_total_users integer := 0;
  v_total_rides integer := 0;
  v_total_bookings integer := 0;
  v_total_routes integer := 0;
  v_total_cities integer := 0;
  v_verified_users integer := 0;
  v_active_rides integer := 0;
  v_completed_bookings integer := 0;
BEGIN
  -- Count users
  SELECT COUNT(*) INTO v_total_users FROM profiles;
  SELECT COUNT(*) INTO v_verified_users FROM profiles WHERE is_verified = true;

  -- Count rides
  SELECT COUNT(*) INTO v_total_rides FROM rides;
  SELECT COUNT(*) INTO v_active_rides FROM rides WHERE status = 'published';

  -- Count bookings
  SELECT COUNT(*) INTO v_total_bookings FROM bookings;
  SELECT COUNT(*) INTO v_completed_bookings FROM bookings WHERE status = 'completed';

  -- Count routes and cities
  SELECT COUNT(*) INTO v_total_routes FROM routes;
  SELECT COUNT(*) INTO v_total_cities FROM cities;

  RETURN jsonb_build_object(
    'users', jsonb_build_object(
      'total', v_total_users,
      'verified', v_verified_users,
      'verification_rate', CASE WHEN v_total_users > 0 THEN ROUND((v_verified_users::numeric / v_total_users) * 100, 2) ELSE 0 END
    ),
    'rides', jsonb_build_object(
      'total', v_total_rides,
      'active', v_active_rides
    ),
    'bookings', jsonb_build_object(
      'total', v_total_bookings,
      'completed', v_completed_bookings,
      'completion_rate', CASE WHEN v_total_bookings > 0 THEN ROUND((v_completed_bookings::numeric / v_total_bookings) * 100, 2) ELSE 0 END
    ),
    'infrastructure', jsonb_build_object(
      'routes', v_total_routes,
      'cities', v_total_cities
    ),
    'generated_at', now()
  );
END;
$$;

-- Function to bulk update user verification status
CREATE OR REPLACE FUNCTION bulk_update_user_verification(
  p_user_ids uuid[],
  p_verified boolean
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_updated_count integer := 0;
BEGIN
  UPDATE profiles
  SET 
    is_verified = p_verified,
    updated_at = now()
  WHERE user_id = ANY(p_user_ids);

  GET DIAGNOSTICS v_updated_count = ROW_COUNT;

  RETURN jsonb_build_object(
    'success', true,
    'updated_count', v_updated_count,
    'verified', p_verified
  );
END;
$$;

-- Function to get ride analytics
CREATE OR REPLACE FUNCTION get_ride_analytics(
  p_start_date date DEFAULT (now() - interval '30 days')::date,
  p_end_date date DEFAULT now()::date
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_rides_published integer := 0;
  v_rides_completed integer := 0;
  v_rides_cancelled integer := 0;
  v_avg_occupancy numeric := 0;
  v_top_routes jsonb;
BEGIN
  -- Count rides by status in date range
  SELECT 
    COUNT(*) FILTER (WHERE status = 'published') AS published,
    COUNT(*) FILTER (WHERE status = 'completed') AS completed,
    COUNT(*) FILTER (WHERE status = 'cancelled') AS cancelled
  INTO v_rides_published, v_rides_completed, v_rides_cancelled
  FROM rides
  WHERE depart_date BETWEEN p_start_date AND p_end_date;

  -- Calculate average occupancy
  SELECT COALESCE(AVG((seats_total - seats_available)::numeric / NULLIF(seats_total, 0)) * 100, 0)
  INTO v_avg_occupancy
  FROM rides
  WHERE depart_date BETWEEN p_start_date AND p_end_date
    AND seats_total > 0;

  -- Get top routes by booking count
  SELECT jsonb_agg(
    jsonb_build_object(
      'route', route_name,
      'bookings', booking_count
    )
  )
  INTO v_top_routes
  FROM (
    SELECT 
      COALESCE(r.name, r.origin || ' → ' || r.destination) as route_name,
      COUNT(b.id) as booking_count
    FROM rides ri
    LEFT JOIN routes r ON r.id = ri.route_id
    LEFT JOIN bookings b ON b.ride_id = ri.id
    WHERE ri.depart_date BETWEEN p_start_date AND p_end_date
    GROUP BY r.id, r.name, r.origin, r.destination
    ORDER BY booking_count DESC
    LIMIT 10
  ) top_routes;

  RETURN jsonb_build_object(
    'period', jsonb_build_object(
      'start_date', p_start_date,
      'end_date', p_end_date
    ),
    'rides', jsonb_build_object(
      'published', v_rides_published,
      'completed', v_rides_completed,
      'cancelled', v_rides_cancelled,
      'total', v_rides_published + v_rides_completed + v_rides_cancelled
    ),
    'metrics', jsonb_build_object(
      'average_occupancy', ROUND(v_avg_occupancy, 2)
    ),
    'top_routes', COALESCE(v_top_routes, '[]'::jsonb),
    'generated_at', now()
  );
END;
$$;

-- Function to get cancellation analytics
CREATE OR REPLACE FUNCTION get_cancellation_analytics(
  p_start_date date DEFAULT (now() - interval '30 days')::date,
  p_end_date date DEFAULT now()::date
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_total_cancellations integer := 0;
  v_rider_cancellations integer := 0;
  v_driver_cancellations integer := 0;
  v_avg_penalty numeric := 0;
  v_cancellation_by_time jsonb;
BEGIN
  -- Count cancellations by actor
  SELECT 
    COUNT(*) as total,
    COUNT(*) FILTER (WHERE cancelled_by = 'rider') as rider,
    COUNT(*) FILTER (WHERE cancelled_by = 'driver') as driver,
    COALESCE(AVG(penalty_inr), 0) as avg_penalty
  INTO v_total_cancellations, v_rider_cancellations, v_driver_cancellations, v_avg_penalty
  FROM cancellations
  WHERE cancelled_at::date BETWEEN p_start_date AND p_end_date;

  -- Get cancellation distribution by hours before departure
  SELECT jsonb_agg(
    jsonb_build_object(
      'time_range', time_range,
      'count', cancellation_count,
      'percentage', ROUND((cancellation_count::numeric / NULLIF(v_total_cancellations, 0)) * 100, 2)
    )
  )
  INTO v_cancellation_by_time
  FROM (
    SELECT 
      CASE 
        WHEN hours_before_depart >= 24 THEN '24+ hours'
        WHEN hours_before_depart >= 12 THEN '12-24 hours'
        WHEN hours_before_depart >= 6 THEN '6-12 hours'
        WHEN hours_before_depart >= 1 THEN '1-6 hours'
        ELSE '< 1 hour'
      END as time_range,
      COUNT(*) as cancellation_count
    FROM cancellations
    WHERE cancelled_at::date BETWEEN p_start_date AND p_end_date
    GROUP BY 1
    ORDER BY 
      CASE 
        WHEN hours_before_depart >= 24 THEN 1
        WHEN hours_before_depart >= 12 THEN 2
        WHEN hours_before_depart >= 6 THEN 3
        WHEN hours_before_depart >= 1 THEN 4
        ELSE 5
      END
  ) time_breakdown;

  RETURN jsonb_build_object(
    'period', jsonb_build_object(
      'start_date', p_start_date,
      'end_date', p_end_date
    ),
    'summary', jsonb_build_object(
      'total_cancellations', v_total_cancellations,
      'rider_cancellations', v_rider_cancellations,
      'driver_cancellations', v_driver_cancellations,
      'average_penalty', ROUND(v_avg_penalty, 2)
    ),
    'distribution_by_time', COALESCE(v_cancellation_by_time, '[]'::jsonb),
    'generated_at', now()
  );
END;
$$;

-- Function to cleanup old data (for maintenance)
CREATE OR REPLACE FUNCTION cleanup_old_data(
  p_days_to_keep integer DEFAULT 365
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_cutoff_date timestamptz;
  v_deleted_count integer := 0;
  v_total_deleted integer := 0;
BEGIN
  v_cutoff_date := now() - (p_days_to_keep || ' days')::interval;

  -- Delete old wallet transactions (keep essential ones)
  DELETE FROM wallet_transactions
  WHERE created_at < v_cutoff_date
    AND tx_type NOT IN ('transfer_in', 'transfer_out'); -- Keep deposits and withdrawals
  
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
  v_total_deleted := v_total_deleted + v_deleted_count;

  -- Delete old notifications
  DELETE FROM notifications
  WHERE created_at < v_cutoff_date
    AND read = true;
  
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
  v_total_deleted := v_total_deleted + v_deleted_count;

  -- Delete old inbox messages (keep threads)
  DELETE FROM inbox_messages
  WHERE created_at < v_cutoff_date;
  
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
  v_total_deleted := v_total_deleted + v_deleted_count;

  RETURN jsonb_build_object(
    'success', true,
    'cutoff_date', v_cutoff_date,
    'total_deleted', v_total_deleted,
    'cleanup_date', now()
  );
END;
$$;

-- Create indexes for better admin panel performance
CREATE INDEX IF NOT EXISTS idx_wallet_transactions_created_at ON wallet_transactions(created_at);
CREATE INDEX IF NOT EXISTS idx_wallet_transactions_tx_type ON wallet_transactions(tx_type);
CREATE INDEX IF NOT EXISTS idx_bookings_created_at ON bookings(created_at);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);
CREATE INDEX IF NOT EXISTS idx_rides_depart_date ON rides(depart_date);
CREATE INDEX IF NOT EXISTS idx_rides_status ON rides(status);
CREATE INDEX IF NOT EXISTS idx_cancellations_cancelled_at ON cancellations(cancelled_at);
CREATE INDEX IF NOT EXISTS idx_settlements_status ON settlements(status);
