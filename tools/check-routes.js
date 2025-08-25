const path = require('path');
const files = [
  '../routes/test.routes.js',
  '../routes/rides.routes.js',
  '../routes/bookings.routes.js',
  '../routes/wallets.routes.js',
  '../routes/deposits.routes.js',
  '../routes/settlements.routes.js',
  '../routes/debug.routes.js',
  '../routes/users.routes.js',
];
for (const rel of files) {
  const abs = path.resolve(__dirname, rel);
  try {
    const r = require(abs);
    console.log(rel, '->', typeof r);
  } catch (e) {
    console.log(rel, 'FAILED:', e.message);
  }
}
