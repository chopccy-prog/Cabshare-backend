// models/rides.model.js
const db = require('../config/db');

function getNum(n) {
  const v = Number(n);
  if (!Number.isFinite(v)) return null;
  return Math.trunc(v);
}

// ---- small helper used by /search/__diag ----
async function diag() {
  const one = await db.query('SELECT 1 AS ok');
  const counts = await db.query(`
    SELECT
      (SELECT COUNT(*)::int FROM routes)  AS routes,
      (SELECT COUNT(*)::int FROM rides)   AS rides,
      (SELECT COUNT(*)::int FROM cities)  AS cities
  `);
  return { db_ok: one.rows[0].ok === 1, counts: counts.rows[0] };
}

/**
 * Publish a ride (unchanged from your working version)
 */
async function createRide(body) {
  const driverId  = body.driverId  ?? body.driver_id;
  const routeId   = body.routeId   ?? body.route_id;
  const departDate = body.departDate ?? body.depart_date;   // 'YYYY-MM-DD'
  const departTime = body.departTime ?? body.depart_time;   // 'HH:MM'
  const pricePerSeatInr = getNum(body.pricePerSeatInr ?? body.price_per_seat_inr);
  const seatsTotal      = getNum(body.seatsTotal      ?? body.seats_total);
  const carMake  = body.carMake  ?? body.car_make  ?? null;
  const carModel = body.carModel ?? body.car_model ?? null;
  const carPlate = body.carPlate ?? body.car_plate ?? null;
  const notes    = body.notes ?? null;
  const allowAutoConfirm = Boolean(body.allowAutoConfirm ?? body.allow_auto_confirm ?? false);

  if (!driverId)    throw new Error('driverId is required');
  if (!routeId)     throw new Error('routeId is required');
  if (!departDate)  throw new Error('departDate is required (YYYY-MM-DD)');
  if (!departTime)  throw new Error('departTime is required (HH:MM)');
  if (pricePerSeatInr === null) throw new Error('pricePerSeatInr must be a number (integer ₹)');
  if (seatsTotal === null)      throw new Error('seatsTotal must be a number (integer > 0)');
  if (seatsTotal <= 0)          throw new Error('seatsTotal must be > 0');
  if (pricePerSeatInr < 0)      throw new Error('pricePerSeatInr must be ≥ 0');

  const { rows } = await db.query(
    `INSERT INTO rides (
       driver_id, route_id, depart_date, depart_time,
       price_per_seat_inr, seats_total, seats_available,
       car_make, car_model, car_plate, notes,
       status, allow_auto_confirm
     ) VALUES (
       $1,$2,$3,$4,$5,$6,$6,$7,$8,$9,$10,'published',$11
     )
     RETURNING *`,
    [
      driverId,
      routeId,
      departDate,
      departTime,
      pricePerSeatInr,
      seatsTotal,
      carMake,
      carModel,
      carPlate,
      notes,
      allowAutoConfirm,
    ]
  );
  return rows[0];
}

async function getById(rideId) {
  const { rows } = await db.query(`SELECT * FROM rides WHERE id = $1`, [rideId]);
  return rows[0] || null;
}

// ---- the safe, non-blocking search ----
async function search({ routeId, date }) {
  const params = [];
  let where = `WHERE status = 'published'`;

  if (routeId) { params.push(routeId); where += ` AND route_id = $${params.length}`; }
  if (date)    { params.push(date);    where += ` AND depart_date = $${params.length}`; }

  // plain pool.query (no BEGIN); cannot “hang” unless the DB connection itself is broken
  const { rows } = await db.query(
    `SELECT id, driver_id, route_id, depart_date, depart_time,
            price_per_seat_inr, seats_total, seats_available,
            car_make, car_model, car_plate, notes, status, allow_auto_confirm,
            created_at, updated_at
       FROM rides
       ${where}
       ORDER BY depart_date, depart_time
       LIMIT 200`
  , params);

  return rows;
}

// ---- update (kept) ----
async function updateRide(rideId, body) {
  const sets = [];
  const vals = [];
  const add = (col, val) => { vals.push(val); sets.push(`${col} = $${vals.length}`); };

  if ('pricePerSeatInr' in body || 'price_per_seat_inr' in body)
    add('price_per_seat_inr', getNum(body.pricePerSeatInr ?? body.price_per_seat_inr));
  if ('seatsTotal' in body || 'seats_total' in body)
    add('seats_total', getNum(body.seatsTotal ?? body.seats_total));
  if ('allowAutoConfirm' in body || 'allow_auto_confirm' in body)
    add('allow_auto_confirm', !!(body.allowAutoConfirm ?? body.allow_auto_confirm));

  if ('notes' in body)     add('notes', body.notes ?? null);
  if ('carMake' in body || 'car_make' in body)   add('car_make', body.carMake ?? body.car_make ?? null);
  if ('carModel' in body || 'car_model' in body) add('car_model', body.carModel ?? body.car_model ?? null);
  if ('carPlate' in body || 'car_plate' in body) add('car_plate', body.carPlate ?? body.car_plate ?? null);

  if (!sets.length) return getById(rideId);

  vals.push(rideId);
  const { rows } = await db.query(
    `UPDATE rides SET ${sets.join(', ')}, updated_at = now()
      WHERE id = $${vals.length}
      RETURNING *`,
    vals
  );
  return rows[0] || null;
}

module.exports = {
  // core
  createRide,
  getById,
  search,
  updateRide,
  // diag
  diag,
  // aliases
  getRideById: getById,
  searchRides: search,
};
