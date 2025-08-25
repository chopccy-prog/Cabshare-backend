// models/settlements.model.js
const db = require('../config/db');

/**
 * Request a settlement (payout) for any user.
 * - Moves <amount> from available -> reserved to lock funds
 * - Creates a settlements row with status 'requested'
 */
async function requestSettlement({ userId, amountInr, note }) {
  if (!userId) throw new Error('userId is required');
  const amount = Number(amountInr);
  if (!Number.isFinite(amount) || amount <= 0) throw new Error('amountInr must be > 0');

  const client = await db.connect();
  try {
    await client.query('BEGIN');

    // Lock wallet row
    const w = await client.query(
      `SELECT user_id, balance_available_inr, balance_reserved_inr
         FROM wallets WHERE user_id = $1 FOR UPDATE`,
      [userId]
    );
    if (w.rowCount === 0) throw new Error('Wallet not found');
    if (Number(w.rows[0].balance_available_inr) < amount) {
      throw new Error('Insufficient available balance');
    }

    // Move available -> reserved to hold for payout
    await client.query(
      `UPDATE wallets
          SET balance_available_inr = balance_available_inr - $2,
              balance_reserved_inr  = balance_reserved_inr  + $2,
              updated_at = now()
        WHERE user_id = $1`,
      [userId, amount]
    );

    // Ledger entry
    await client.query(
      `INSERT INTO wallet_transactions
         (user_id, tx_type, amount_inr, note)
       VALUES ($1, 'reserve', $2 * -1, $3)`,
      [userId, amount, 'Settlement reserve' + (note ? `: ${note}` : '')]
    );

    // Create settlement row
    const ins = await client.query(
      `INSERT INTO settlements (user_id, amount_inr, status, requested_at, cycle_start, cycle_end)
       VALUES ($1, $2, 'requested', now(), NULL, NULL)
       RETURNING *`,
      [userId, amount]
    );

    await client.query('COMMIT');
    return ins.rows[0];
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }
}

/**
 * Cancel a settlement (by the same user) while it's still 'requested'.
 * - Moves reserved -> available
 * - Marks settlement 'rejected'
 */
async function cancelSettlement({ settlementId, userId }) {
  if (!settlementId) throw new Error('settlementId is required');
  if (!userId) throw new Error('userId is required');

  const client = await db.connect();
  try {
    await client.query('BEGIN');

    const s = await client.query(
      `SELECT id, user_id, amount_inr, status
         FROM settlements
        WHERE id = $1 FOR UPDATE`,
      [settlementId]
    );
    if (s.rowCount === 0) throw new Error('Settlement not found');
    const row = s.rows[0];
    if (row.user_id !== userId) throw new Error('Not your settlement');
    if (row.status !== 'requested') throw new Error('Only requested settlements can be cancelled');

    // Move reserved back -> available
    await client.query(
      `UPDATE wallets
          SET balance_reserved_inr  = balance_reserved_inr  - $2,
              balance_available_inr = balance_available_inr + $2,
              updated_at = now()
        WHERE user_id = $1`,
      [userId, row.amount_inr]
    );

    await client.query(
      `INSERT INTO wallet_transactions
         (user_id, tx_type, amount_inr, note)
       VALUES ($1, 'release', $2, 'Settlement cancelled: release reserve')`,
      [userId, row.amount_inr]
    );

    const upd = await client.query(
      `UPDATE settlements
          SET status = 'rejected', processed_at = now()
        WHERE id = $1
        RETURNING *`,
      [settlementId]
    );

    await client.query('COMMIT');
    return upd.rows[0];
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }
}

/**
 * Mark a settlement paid (admin/backoffice action).
 * - Deducts from reserved (funds leave the platform)
 * - Marks settlement 'paid'
 */
async function markPaid({ settlementId, adminNote }) {
  if (!settlementId) throw new Error('settlementId is required');

  const client = await db.connect();
  try {
    await client.query('BEGIN');

    const s = await client.query(
      `SELECT id, user_id, amount_inr, status
         FROM settlements
        WHERE id = $1 FOR UPDATE`,
      [settlementId]
    );
    if (s.rowCount === 0) throw new Error('Settlement not found');
    const row = s.rows[0];
    if (row.status !== 'requested') throw new Error('Only requested settlements can be paid');

    // Reduce reserved (money leaves system)
    const up = await client.query(
      `UPDATE wallets
          SET balance_reserved_inr = balance_reserved_inr - $2,
              updated_at = now()
        WHERE user_id = $1
          AND balance_reserved_inr >= $2`,
      [row.user_id, row.amount_inr]
    );
    if (up.rowCount === 0) throw new Error('Reserved funds missing');

    await client.query(
      `INSERT INTO wallet_transactions
         (user_id, tx_type, amount_inr, note)
       VALUES ($1, 'transfer_out', $2 * -1, $3)`,
      [row.user_id, row.amount_inr, adminNote ? `Settlement paid: ${adminNote}` : 'Settlement paid']
    );

    const upd = await client.query(
      `UPDATE settlements
          SET status = 'paid', processed_at = now()
        WHERE id = $1
        RETURNING *`,
      [settlementId]
    );

    await client.query('COMMIT');
    return upd.rows[0];
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }
}

async function listMine({ userId, limit = 50, offset = 0 }) {
  const { rows } = await db.query(
    `SELECT *
       FROM settlements
      WHERE user_id = $1
      ORDER BY requested_at DESC
      LIMIT $2 OFFSET $3`,
    [userId, limit, offset]
  );
  return rows;
}

module.exports = {
  requestSettlement,
  cancelSettlement,
  markPaid,
  listMine,
};
