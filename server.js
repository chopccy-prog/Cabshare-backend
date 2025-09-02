// server.js
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// health
app.get('/health', (_req, res) => res.json({ ok: true }));

// routes
const ridesRoutes = require('./routes/rides.routes');
app.use('/rides', ridesRoutes);

// optional stubs so the app never 404s here
app.get('/inbox', (_req, res) => res.json([]));
app.get('/messages', (_req, res) => res.json([]));
app.post('/messages', (_req, res) => res.json({ ok: true }));

const PORT = process.env.PORT || 3000; // keep 3000 if that's what you use
app.listen(PORT, '0.0.0.0', () => {
  console.log(`cabshare backend listening on :${PORT}`);
});
