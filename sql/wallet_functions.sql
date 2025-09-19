-- Additional wallet functions for enhanced financial system

-- Function to add wallet balance (for deposits)
CREATE OR REPLACE FUNCTION add_wallet_balance(
  p_user_id uuid,
  p_amount integer,
  p_note text DEFAULT 'Wallet credit'
) RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Ensure wallet exists
  INSERT INTO wallets (user_id, balance_available_inr, balance_reserved_inr)
  VALUES (p_user_id, 0, 0)
  ON CONFLICT (user_id) DO NOTHING;

  -- Add to available balance
  UPDATE wallets
  SET 
    balance_available_inr = balance_available_inr + p_amount,
    updated_at = now()
  WHERE user_id = p_user_id;

  -- Record transaction
  INSERT INTO wallet_transactions (
    user_id,
    tx_type,
    amount_inr,
    note,
    created_at
  ) VALUES (
    p_user_id,
    'transfer_in'::wallet_tx_type,
    p_amount,
    p_note,
    now()
  );
END;
$$;

-- Function to reserve wallet balance (for settlements)
CREATE OR REPLACE FUNCTION reserve_wallet_balance(
  p_user_id uuid,
  p_amount integer,
  p_note text DEFAULT 'Balance reserved'
) RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_available integer;
BEGIN
  -- Check available balance
  SELECT balance_available_inr INTO v_available
  FROM wallets
  WHERE user_id = p_user_id;

  IF v_available IS NULL THEN
    RAISE EXCEPTION 'Wallet not found for user';
  END IF;

  IF v_available < p_amount THEN
    RAISE EXCEPTION 'Insufficient available balance';
  END IF;

  -- Move from available to reserved
  UPDATE wallets
  SET 
    balance_available_inr = balance_available_inr - p_amount,
    balance_reserved_inr = balance_reserved_inr + p_amount,
    updated_at = now()
  WHERE user_id = p_user_id;

  -- Record transaction
  INSERT INTO wallet_transactions (
    user_id,
    tx_type,
    amount_inr,
    note,
    created_at
  ) VALUES (
    p_user_id,
    'reserve'::wallet_tx_type,
    p_amount,
    p_note,
    now()
  );
END;
$$;

-- Function to release reserved balance
CREATE OR REPLACE FUNCTION release_wallet_balance(
  p_user_id uuid,
  p_amount integer,
  p_note text DEFAULT 'Balance released'
) RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_reserved integer;
BEGIN
  -- Check reserved balance
  SELECT balance_reserved_inr INTO v_reserved
  FROM wallets
  WHERE user_id = p_user_id;

  IF v_reserved IS NULL THEN
    RAISE EXCEPTION 'Wallet not found for user';
  END IF;

  IF v_reserved < p_amount THEN
    RAISE EXCEPTION 'Insufficient reserved balance';
  END IF;

  -- Move from reserved to available
  UPDATE wallets
  SET 
    balance_available_inr = balance_available_inr + p_amount,
    balance_reserved_inr = balance_reserved_inr - p_amount,
    updated_at = now()
  WHERE user_id = p_user_id;

  -- Record transaction
  INSERT INTO wallet_transactions (
    user_id,
    tx_type,
    amount_inr,
    note,
    created_at
  ) VALUES (
    p_user_id,
    'release'::wallet_tx_type,
    p_amount,
    p_note,
    now()
  );
END;
$$;

-- Function to process settlement payout
CREATE OR REPLACE FUNCTION process_settlement_payout(
  p_settlement_id uuid,
  p_processed_by uuid DEFAULT NULL
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_settlement record;
BEGIN
  -- Get settlement details
  SELECT * INTO v_settlement
  FROM settlements
  WHERE id = p_settlement_id
    AND status = 'requested'
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Settlement not found or already processed';
  END IF;

  -- Remove from reserved balance (payout completed)
  UPDATE wallets
  SET 
    balance_reserved_inr = balance_reserved_inr - v_settlement.amount_inr,
    updated_at = now()
  WHERE user_id = v_settlement.user_id;

  -- Update settlement status
  UPDATE settlements
  SET 
    status = 'paid'::settlement_status,
    processed_at = now()
  WHERE id = p_settlement_id;

  -- Record transaction
  INSERT INTO wallet_transactions (
    user_id,
    tx_type,
    amount_inr,
    note,
    created_at
  ) VALUES (
    v_settlement.user_id,
    'transfer_out'::wallet_tx_type,
    -v_settlement.amount_inr,
    'Settlement payout processed',
    now()
  );

  RETURN jsonb_build_object(
    'success', true,
    'settlement_id', p_settlement_id,
    'amount', v_settlement.amount_inr,
    'user_id', v_settlement.user_id
  );
END;
$$;

-- Function to reject settlement request
CREATE OR REPLACE FUNCTION reject_settlement_request(
  p_settlement_id uuid,
  p_reason text DEFAULT 'Settlement rejected'
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_settlement record;
BEGIN
  -- Get settlement details
  SELECT * INTO v_settlement
  FROM settlements
  WHERE id = p_settlement_id
    AND status = 'requested'
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Settlement not found or already processed';
  END IF;

  -- Release reserved balance back to available
  UPDATE wallets
  SET 
    balance_available_inr = balance_available_inr + v_settlement.amount_inr,
    balance_reserved_inr = balance_reserved_inr - v_settlement.amount_inr,
    updated_at = now()
  WHERE user_id = v_settlement.user_id;

  -- Update settlement status
  UPDATE settlements
  SET 
    status = 'rejected'::settlement_status,
    processed_at = now()
  WHERE id = p_settlement_id;

  -- Record transaction
  INSERT INTO wallet_transactions (
    user_id,
    tx_type,
    amount_inr,
    note,
    created_at
  ) VALUES (
    v_settlement.user_id,
    'release'::wallet_tx_type,
    v_settlement.amount_inr,
    format('Settlement rejected: %s', p_reason),
    now()
  );

  RETURN jsonb_build_object(
    'success', true,
    'settlement_id', p_settlement_id,
    'amount', v_settlement.amount_inr,
    'reason', p_reason
  );
END;
$$;

-- Function to get wallet summary
CREATE OR REPLACE FUNCTION get_wallet_summary(
  p_user_id uuid
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_wallet record;
  v_pending_settlements integer;
  v_total_earned integer;
  v_total_spent integer;
BEGIN
  -- Get wallet details
  SELECT * INTO v_wallet
  FROM wallets
  WHERE user_id = p_user_id;

  IF NOT FOUND THEN
    -- Return default wallet if not found
    RETURN jsonb_build_object(
      'user_id', p_user_id,
      'balance_available_inr', 0,
      'balance_reserved_inr', 0,
      'total_balance', 0,
      'pending_settlements', 0,
      'total_earned', 0,
      'total_spent', 0
    );
  END IF;

  -- Get pending settlements amount
  SELECT COALESCE(SUM(amount_inr), 0) INTO v_pending_settlements
  FROM settlements
  WHERE user_id = p_user_id AND status = 'requested';

  -- Get total earned (credits)
  SELECT COALESCE(SUM(amount_inr), 0) INTO v_total_earned
  FROM wallet_transactions
  WHERE user_id = p_user_id 
    AND tx_type IN ('transfer_in', 'release')
    AND amount_inr > 0;

  -- Get total spent (debits)
  SELECT COALESCE(SUM(ABS(amount_inr)), 0) INTO v_total_spent
  FROM wallet_transactions
  WHERE user_id = p_user_id 
    AND tx_type IN ('transfer_out', 'reserve')
    AND amount_inr < 0;

  RETURN jsonb_build_object(
    'user_id', p_user_id,
    'balance_available_inr', v_wallet.balance_available_inr,
    'balance_reserved_inr', v_wallet.balance_reserved_inr,
    'total_balance', v_wallet.balance_available_inr + v_wallet.balance_reserved_inr,
    'pending_settlements', v_pending_settlements,
    'total_earned', v_total_earned,
    'total_spent', v_total_spent,
    'updated_at', v_wallet.updated_at
  );
END;
$$;
