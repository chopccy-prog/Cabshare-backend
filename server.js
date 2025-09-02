// server.js
require('dotenv').config();

const express = require('express');
const cors = require('cors');
const morgan = require('morgan');

// health check expects /health on port 3000
const PORT = process.env.PORT ? Number(process.env.PORT) : 3000;

const app = express();
app.use(cors());
app.use(express.json());         // <-- critical for depart_date etc.
app.use(morgan('dev'));

// mount routes
const ridesRouter = require('./routes/rides.routes');
app.use('/rides', ridesRouter);

// health endpoint (you confirmed this is what you call)
app.get('/health', (_req, res) => res.json({ ok: true }));

// 404 fallback LAST
app.use((_req, res) => res.status(404).json({ error: 'not_found' }));

app.listen(PORT, () => {
  console.log(`cabshare backend listening on :${PORT}`);
});
