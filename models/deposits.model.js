// models/deposits.model.js
const db = require('../config/db');

/**
 * Create a deposit intent (top-up request).
 * method = 'manual' (now) or 'razorpay' (future)
 * status starts as 'created'
 */
async function createIntent({ userId, amountInr, method = 'manual', notes }) {
  if (!userId) throw new Error('userId is required');
  const amount = Number(amountInr);
  if (!Number.isFinite(amount) || amount <= 0) throw new Error('amountInr must be > 0');

  const { rows } = await db.query(
    `INSERT INTO deposit_intents (user_id, amount_inr, method, status, notes)
     VALUES ($1, $2, $3, 'created', $4)
     RETURNING *`,
    [userId, amount, method, notes || null]
  );
  return rows[0];
}

/**
 * Manually mark a deposit 'paid' (admin/backoffice or sandbox).
 * - Credits user's wallet AVAILABLE balance.
 */
async function markPaid({ intentId, adminNote }) {
  if (!intentId) throw new Error('intentId is required');

  const client = await db.connect();
  try {
    await client.query('BEGIN');

    const q = await client.query(
      `SELECT id, user_id, amount_inr, status
         FROM deposit_intents
        WHERE id = $1
        FOR UPDATE`,
      [intentId]
    );
    if (q.rowCount === 0) throw new Error('Deposit intent not found');

    const d = q.rows[0];
    if (d.status !== 'created') throw new Error('Only "created" intents can be marked paid');

    // Credit wallet
    await client.query(
      `INSERT INTO wallets (user_id) VALUES ($1)
       ON CONFLICT (user_id) DO NOTHING`,
      [d.user_id]
    );

    await client.query(
      `UPDATE wallets
          SET balance_available_inr = balance_available_inr + $2,
              updated_at = now()
        WHERE user_id = $1`,
      [d.user_id, d.amount_inr]
    );

    await client.query(
      `INSERT INTO wallet_transactions (user_id, tx_type, amount_inr, note)
       VALUES ($1, 'transfer_in', $2, $3)`,
      [d.user_id, d.amount_inr, adminNote ? `Deposit paid: ${adminNote}` : 'Deposit paid (manual)']
    );

    const upd = await client.query(
      `UPDATE deposit_intents
          SET status = 'paid', updated_at = now()
        WHERE id = $1
        RETURNING *`,
      [intentId]
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
 * Mark a deposit failed/cancelled (no wallet changes).
 */
async function markStatus({ intentId, status, adminNote }) {
  if (!intentId) throw new Error('intentId is required');
  const allowed = new Set(['failed', 'cancelled', 'expired']);
  if (!allowed.has(status)) throw new Error('status must be failed|cancelled|expired');

  const { rows } = await db.query(
    `UPDATE deposit_intents
        SET status = $2, updated_at = now(), notes = COALESCE(notes,'') || $3
      WHERE id = $1 AND status = 'created'
      RETURNING *`,
    [intentId, status, adminNote ? ` | ${adminNote}` : '']
  );
  if (rows.length === 0) throw new Error('No intent updated (must be in "created")');
  return rows[0];
}

async function listMine({ userId, limit = 50, offset = 0 }) {
  const { rows } = await db.query(
    `SELECT *
       FROM deposit_intents
      WHERE user_id = $1
      ORDER BY created_at DESC
      LIMIT $2 OFFSET $3`,
    [userId, Number(limit) || 50, Number(offset) || 0]
  );
  return rows;
}

module.exports = {
  createIntent,
  markPaid,
  markStatus,
  listMine,
};
