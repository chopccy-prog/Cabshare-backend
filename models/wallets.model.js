// models/wallets.model.js
const db = require('../config/db');

// Ensure a wallet row exists for a user
async function ensureWallet(userId) {
  await db.query(
    `INSERT INTO wallets(user_id) VALUES ($1)
     ON CONFLICT (user_id) DO NOTHING`,
    [userId]
  );
}

// Add to available balance
async function credit(userId, amount, note) {
  if (!Number.isInteger(amount) || amount <= 0) throw new Error('credit amount must be > 0');
  await ensureWallet(userId);

  await db.query('BEGIN');
  try {
    await db.query(
      `UPDATE wallets
         SET balance_available_inr = balance_available_inr + $2,
             updated_at = now()
       WHERE user_id = $1`,
      [userId, amount]
    );
    await db.query(
      `INSERT INTO wallet_transactions(user_id, tx_type, amount_inr, note)
       VALUES ($1, 'transfer_in', $2, $3)`,
      [userId, amount, note || 'credit']
    );
    await db.query('COMMIT');
  } catch (e) {
    await db.query('ROLLBACK');
    throw e;
  }
}

// Reserve (available -> reserved)
async function reserve(userId, amount, refBookingId, note) {
  if (!Number.isInteger(amount) || amount <= 0) throw new Error('reserve amount must be > 0');
  await ensureWallet(userId);

  await db.query('BEGIN');
  try {
    const { rowCount } = await db.query(
      `UPDATE wallets
         SET balance_available_inr = balance_available_inr - $2,
             balance_reserved_inr  = balance_reserved_inr  + $2,
             updated_at = now()
       WHERE user_id = $1
         AND balance_available_inr >= $2`,
      [userId, amount]
    );
    if (rowCount === 0) throw new Error('Insufficient wallet balance to reserve');

    await db.query(
      `INSERT INTO wallet_transactions(user_id, tx_type, amount_inr, ref_booking_id, note)
       VALUES ($1, 'reserve', $2, $3, $4)`,
      [userId, amount, refBookingId || null, note || 'reserve']
    );
    await db.query('COMMIT');
  } catch (e) {
    await db.query('ROLLBACK');
    throw e;
  }
}

// Release (reserved -> available)
async function release(userId, amount, refBookingId, note) {
  if (!Number.isInteger(amount) || amount <= 0) throw new Error('release amount must be > 0');
  await ensureWallet(userId);

  await db.query('BEGIN');
  try {
    const { rowCount } = await db.query(
      `UPDATE wallets
         SET balance_reserved_inr  = balance_reserved_inr  - $2,
             balance_available_inr = balance_available_inr + $2,
             updated_at = now()
       WHERE user_id = $1
         AND balance_reserved_inr >= $2`,
      [userId, amount]
    );
    if (rowCount === 0) throw new Error('Insufficient reserved balance to release');

    await db.query(
      `INSERT INTO wallet_transactions(user_id, tx_type, amount_inr, ref_booking_id, note)
       VALUES ($1, 'release', $2, $3, $4)`,
      [userId, amount, refBookingId || null, note || 'release']
    );
    await db.query('COMMIT');
  } catch (e) {
    await db.query('ROLLBACK');
    throw e;
  }
}

// Pay out reserved from rider -> driver
async function payReservedToCounterparty({ fromUserId, toUserId, amount, refBookingId, note }) {
  if (!Number.isInteger(amount) || amount <= 0) throw new Error('transfer amount must be > 0');
  await ensureWallet(fromUserId);
  await ensureWallet(toUserId);

  await db.query('BEGIN');
  try {
    const out = await db.query(
      `UPDATE wallets
         SET balance_reserved_inr = balance_reserved_inr - $2,
             updated_at = now()
       WHERE user_id = $1 AND balance_reserved_inr >= $2`,
      [fromUserId, amount]
    );
    if (out.rowCount === 0) throw new Error('Insufficient reserved to transfer');

    await db.query(
      `UPDATE wallets
         SET balance_available_inr = balance_available_inr + $2,
             updated_at = now()
       WHERE user_id = $1`,
      [toUserId, amount]
    );

    await db.query(
      `INSERT INTO wallet_transactions(user_id, tx_type, amount_inr, ref_booking_id, note)
       VALUES ($1, 'transfer_out', -$2, $3, $4)`,
      [fromUserId, amount, refBookingId || null, note || 'escrow payout']
    );
    await db.query(
      `INSERT INTO wallet_transactions(user_id, tx_type, amount_inr, ref_booking_id, note)
       VALUES ($1, 'transfer_in',  $2, $3, $4)`,
      [toUserId, amount, refBookingId || null, note || 'escrow payout']
    );

    await db.query('COMMIT');
  } catch (e) {
    await db.query('ROLLBACK');
    throw e;
  }
}

// Driver penalty: move driver->rider (or record due)
async function driverPenaltyTransfer({ driverId, riderId, amount, refBookingId }) {
  if (!Number.isInteger(amount) || amount <= 0) throw new Error('penalty amount must be > 0');
  await ensureWallet(driverId);
  await ensureWallet(riderId);

  await db.query('BEGIN');
  try {
    const up = await db.query(
      `UPDATE wallets
         SET balance_available_inr = balance_available_inr - $2,
             updated_at = now()
       WHERE user_id = $1 AND balance_available_inr >= $2`,
      [driverId, amount]
    );

    if (up.rowCount === 0) {
      await db.query(
        `INSERT INTO wallet_transactions(user_id, tx_type, amount_inr, ref_booking_id, note)
         VALUES ($1, 'adjustment', -$2, $3, 'driver penalty due')`,
        [driverId, amount, refBookingId || null]
      );
    } else {
      await db.query(
        `INSERT INTO wallet_transactions(user_id, tx_type, amount_inr, ref_booking_id, note)
         VALUES ($1, 'transfer_out', -$2, $3, 'driver penalty')`,
        [driverId, amount, refBookingId || null]
      );
    }

    await db.query(
      `UPDATE wallets
         SET balance_available_inr = balance_available_inr + $2,
             updated_at = now()
       WHERE user_id = $1`,
      [riderId, amount]
    );
    await db.query(
      `INSERT INTO wallet_transactions(user_id, tx_type, amount_inr, ref_booking_id, note)
       VALUES ($1, 'transfer_in', $2, $3, 'driver penalty received')`,
      [riderId, amount, refBookingId || null]
    );

    await db.query('COMMIT');
  } catch (e) {
    await db.query('ROLLBACK');
    throw e;
  }
}

// Read-only summary
async function summary(userId) {
  const { rows } = await db.query(
    `SELECT balance_available_inr, balance_reserved_inr
       FROM wallets WHERE user_id = $1`,
    [userId]
  );
  return rows[0] || { balance_available_inr: 0, balance_reserved_inr: 0 };
}

module.exports = {
  ensureWallet,
  credit,
  reserve,
  release,
  payReservedToCounterparty,
  driverPenaltyTransfer,
  summary,
};
