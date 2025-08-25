// models/bookings.model.js — driver approval + wallet-aware deposits
const db = require('../config/db');

function combineDateTime(dateStr, timeStr) {
  return new Date(`${dateStr}T${timeStr}Z`);
}

// ---- helpers to make numbers safe (handles "150,00", " 150 ", etc.) ----
function toIntSafe(v, label = 'amount') {
  if (v === null || v === undefined) throw new Error(`${label} is required`);
  if (typeof v === 'string') {
    // treat comma as decimal separator or thousands separator
    const s = v.trim().replace(/,/g, '.');
    const n = Number(s);
    if (!Number.isFinite(n)) throw new Error(`${label} invalid`);
    return Math.round(n);
  }
  const n = Number(v);
  if (!Number.isFinite(n)) throw new Error(`${label} invalid`);
  return Math.round(n);
}

// ---- wallet ops kept here to avoid cross-file changes ----
async function reserveDepositForRider(client, riderId, depositInr, refBookingId) {
  const deposit = toIntSafe(depositInr, 'deposit');

  const { rows } = await client.query(
    `SELECT user_id, balance_available_inr, balance_reserved_inr
       FROM wallets WHERE user_id = $1 FOR UPDATE`,
    [riderId]
  );
  if (rows.length === 0) throw new Error('Wallet not found for rider');
  const w = rows[0];
  if (toIntSafe(w.balance_available_inr, 'wallet.available') < deposit) {
    throw new Error('Insufficient wallet balance. Please add a deposit/top-up.');
  }

  await client.query(
    `UPDATE wallets
        SET balance_available_inr = balance_available_inr - $2,
            balance_reserved_inr  = balance_reserved_inr  + $2,
            updated_at = now()
      WHERE user_id = $1`,
    [riderId, deposit]
  );

  await client.query(
    `INSERT INTO wallet_transactions
       (user_id, tx_type, amount_inr, ref_booking_id, note)
     VALUES ($1, 'reserve', $2 * -1, $3, 'Reserve 25% deposit')`,
    [riderId, deposit, refBookingId]
  );
}

async function releaseDepositToRider(client, riderId, depositInr, refBookingId, note = 'Release deposit') {
  const deposit = toIntSafe(depositInr, 'deposit');
  await client.query(`SELECT 1 FROM wallets WHERE user_id = $1 FOR UPDATE`, [riderId]);

  await client.query(
    `UPDATE wallets
        SET balance_reserved_inr  = balance_reserved_inr  - $2,
            balance_available_inr = balance_available_inr + $2,
            updated_at = now()
      WHERE user_id = $1`,
    [riderId, deposit]
  );

  await client.query(
    `INSERT INTO wallet_transactions
       (user_id, tx_type, amount_inr, ref_booking_id, note)
     VALUES ($1, 'release', $2, $3, $4)`,
    [riderId, deposit, refBookingId, note]
  );
}

async function transferDepositRiderToDriver(client, riderId, driverId, depositInr, refBookingId) {
  const deposit = toIntSafe(depositInr, 'deposit');

  // lock wallets in deterministic order to avoid deadlocks
  const [first, second] = riderId < driverId ? [riderId, driverId] : [driverId, riderId];
  await client.query(`SELECT 1 FROM wallets WHERE user_id = $1 FOR UPDATE`, [first]);
  await client.query(`SELECT 1 FROM wallets WHERE user_id = $1 FOR UPDATE`, [second]);

  await client.query(
    `UPDATE wallets
        SET balance_reserved_inr = balance_reserved_inr - $2,
            updated_at = now()
      WHERE user_id = $1`,
    [riderId, deposit]
  );

  await client.query(
    `UPDATE wallets
        SET balance_available_inr = balance_available_inr + $2,
            updated_at = now()
      WHERE user_id = $1`,
    [driverId, deposit]
  );

  await client.query(
    `INSERT INTO wallet_transactions
       (user_id, tx_type, amount_inr, ref_booking_id, note)
     VALUES ($1, 'transfer_out', $2 * -1, $3, 'Penalty: deposit forfeited to driver')`,
    [riderId, deposit, refBookingId]
  );

  await client.query(
    `INSERT INTO wallet_transactions
       (user_id, tx_type, amount_inr, ref_booking_id, note)
     VALUES ($1, 'transfer_in', $2, $3, 'Penalty: received rider deposit')`,
    [driverId, deposit, refBookingId]
  );
}

/**
 * Create a booking request.
 * - If ride.allow_auto_confirm = TRUE -> immediately confirm (reserve deposit + decrement seats).
 * - If FALSE -> create with status 'pending' (no deposit, no seats change yet).
 */
async function createBooking({ rideId, riderId, fromStopId, toStopId, seatsBooked }) {
  if (!rideId || !riderId || !fromStopId || !toStopId) throw new Error('Missing required fields');
  const seats = toIntSafe(seatsBooked, 'seatsBooked');
  if (seats <= 0) throw new Error('seatsBooked must be a positive integer');

  const client = await db.connect();
  try {
    await client.query('BEGIN');

    const { rows: rideRows } = await client.query(
      `SELECT id, driver_id, price_per_seat_inr, seats_available,
              depart_date, depart_time, allow_auto_confirm
         FROM rides
        WHERE id = $1
        FOR UPDATE`,
      [rideId]
    );
    if (!rideRows.length) throw new Error('Ride not found');
    const ride = rideRows[0];

    const pricePerSeat = toIntSafe(ride.price_per_seat_inr, 'price_per_seat_inr');
    const fare = toIntSafe(pricePerSeat * seats, 'fare_total_inr');
    const deposit = toIntSafe(fare * 0.25, 'deposit_inr');

    const initialStatus = ride.allow_auto_confirm ? 'confirmed' : 'pending';
    const { rows: bRows } = await client.query(
      `INSERT INTO bookings
         (ride_id, rider_id, from_stop_id, to_stop_id,
          seats_booked, fare_total_inr, deposit_inr, status)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
       RETURNING *`,
      [rideId, riderId, fromStopId, toStopId, seats, fare, deposit, initialStatus]
    );
    const booking = bRows[0];

    if (ride.allow_auto_confirm) {
      const available = toIntSafe(ride.seats_available, 'seats_available');
      if (available < seats) throw new Error('Not enough seats');

      await client.query(
        `UPDATE rides
            SET seats_available = seats_available - $2,
                updated_at = now()
          WHERE id = $1`,
        [rideId, seats]
      );
      await reserveDepositForRider(client, riderId, deposit, booking.id);
    }

    await client.query('COMMIT');
    return booking;
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }
}

/**
 * Driver accepts a PENDING booking:
 * - Checks seats, decrements seats
 * - Reserves 25% deposit now
 * - Sets status -> confirmed
 */
async function acceptBooking({ bookingId, driverId }) {
  const client = await db.connect();
  try {
    await client.query('BEGIN');

    const { rows } = await client.query(
      `SELECT b.*, r.driver_id, r.seats_available, r.price_per_seat_inr
         FROM bookings b
         JOIN rides r ON r.id = b.ride_id
        WHERE b.id = $1
        FOR UPDATE`,
      [bookingId]
    );
    if (!rows.length) throw new Error('Booking not found');
    const b = rows[0];

    if (b.status !== 'pending') throw new Error('Only pending bookings can be accepted');
    if (driverId && b.driver_id !== driverId) throw new Error('Not your ride');

    const need = toIntSafe(b.seats_booked, 'seats_booked');
    const available = toIntSafe(b.seats_available, 'seats_available');
    if (need > available) throw new Error('Not enough seats');

    await client.query(
      `UPDATE rides
          SET seats_available = seats_available - $2,
              updated_at = now()
        WHERE id = $1`,
      [b.ride_id, need]
    );

    await reserveDepositForRider(client, b.rider_id, toIntSafe(b.deposit_inr, 'deposit_inr'), b.id);

    const { rows: upd } = await client.query(
      `UPDATE bookings
          SET status = 'confirmed',
              updated_at = now()
        WHERE id = $1
        RETURNING *`,
      [bookingId]
    );

    await client.query('COMMIT');
    return upd[0];
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }
}

/**
 * Driver rejects a PENDING booking (no deposit ops)
 */
async function rejectBooking({ bookingId, driverId }) {
  const client = await db.connect();
  try {
    await client.query('BEGIN');

    const { rows } = await client.query(
      `SELECT b.id, b.status, r.driver_id
         FROM bookings b
         JOIN rides r ON r.id = b.ride_id
        WHERE b.id = $1
        FOR UPDATE`,
      [bookingId]
    );
    if (!rows.length) throw new Error('Booking not found');
    const b = rows[0];

    if (b.status !== 'pending') throw new Error('Only pending bookings can be rejected');
    if (driverId && b.driver_id !== driverId) throw new Error('Not your ride');

    const { rows: upd } = await client.query(
      `UPDATE bookings
          SET status = 'cancelled_by_driver',
              updated_at = now()
        WHERE id = $1
        RETURNING *`,
      [bookingId]
    );

    await client.query('COMMIT');
    return upd[0];
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }
}

/**
 * Cancel booking (rider/driver) — works for both PENDING and CONFIRMED
 */
async function cancelBooking({ bookingId, actor, actorId }) {
  if (!bookingId) throw new Error('bookingId is required');
  if (!actor || !['rider', 'driver'].includes(actor)) {
    throw new Error('actor must be "rider" or "driver"');
  }

  const client = await db.connect();
  try {
    await client.query('BEGIN');

    const { rows } = await client.query(
      `SELECT
         b.*, r.driver_id, r.depart_date, r.depart_time
       FROM bookings b
       JOIN rides r ON r.id = b.ride_id
       WHERE b.id = $1
       FOR UPDATE`,
      [bookingId]
    );
    if (!rows.length) throw new Error('Booking not found');
    const b = rows[0];

    // PENDING: never touched seats/deposit yet
    if (b.status === 'pending') {
      const newStatus = actor === 'rider' ? 'cancelled_by_rider' : 'cancelled_by_driver';
      const { rows: upd } = await client.query(
        `UPDATE bookings
            SET status = $2,
                updated_at = now()
          WHERE id = $1
          RETURNING *`,
        [bookingId, newStatus]
      );
      await client.query('COMMIT');
      return { ok: true, booking: upd[0] };
    }

    // CONFIRMED flow (deposit + seats involved)
    if (b.status !== 'confirmed') {
      throw new Error('Cannot cancel in current status');
    }

    const departAt = combineDateTime(b.depart_date, b.depart_time);
    const hoursToDepart = (departAt.getTime() - new Date().getTime()) / (1000 * 60 * 60);
    const deposit = toIntSafe(b.deposit_inr, 'deposit_inr');

    if (actor === 'rider') {
      if (hoursToDepart < 12) {
        await transferDepositRiderToDriver(client, b.rider_id, b.driver_id, deposit, b.id);
      } else {
        await releaseDepositToRider(client, b.rider_id, deposit, b.id, 'Cancel >=12h: deposit released');
      }
      await client.query(
        `UPDATE bookings
            SET status = 'cancelled_by_rider',
                updated_at = now()
          WHERE id = $1`,
        [bookingId]
      );
    } else {
      await releaseDepositToRider(client, b.rider_id, deposit, b.id, 'Driver cancelled: deposit released');
      await client.query(
        `UPDATE bookings
            SET status = 'cancelled_by_driver',
                updated_at = now()
          WHERE id = $1`,
        [bookingId]
      );
    }

    // Restore seats for confirmed bookings
    await client.query(
      `UPDATE rides
          SET seats_available = seats_available + $2,
              updated_at = now()
        WHERE id = $1`,
      [b.ride_id, toIntSafe(b.seats_booked, 'seats_booked')]
    );

    await client.query('COMMIT');
    return { ok: true };
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }
}
// COMPLETE a confirmed booking:
// - Releases the rider's reserved deposit back to rider
// - Marks booking -> completed
async function completeBooking({ bookingId, driverId }) {
  const client = await db.connect();
  try {
    await client.query('BEGIN');

    const { rows } = await client.query(
      `SELECT b.*, r.driver_id
         FROM bookings b
         JOIN rides r ON r.id = b.ride_id
        WHERE b.id = $1
        FOR UPDATE`,
      [bookingId]
    );
    if (rows.length === 0) throw new Error('Booking not found');
    const b = rows[0];

    if (b.status !== 'confirmed') throw new Error('Only confirmed bookings can be completed');
    if (driverId && b.driver_id !== driverId) throw new Error('Not your ride');

    // release deposit back to rider
    await releaseDepositToRider(client, b.rider_id, b.deposit_inr, b.id, 'Ride completed: deposit released');

    const { rows: upd } = await client.query(
      `UPDATE bookings
          SET status = 'completed',
              updated_at = now()
        WHERE id = $1
        RETURNING *`,
      [bookingId]
    );

    await client.query('COMMIT');
    return upd[0];
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }
}

module.exports = {
  createBooking,
  acceptBooking,
  rejectBooking,
  cancelBooking,
  completeBooking,
};
