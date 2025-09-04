require('dotenv').config();
const express = require('express');
const cors = require('cors');
const ridesRouter = require('./routes/rides.routes');
const bookingsRouter = require('./routes/bookings.routes');
const messagesRouter = require('./routes/messages.routes');

const app = express();
app.use(cors({ origin: true, credentials: false }));
app.use(express.json());
app.use('/rides', ridesRouter);
app.use('/bookings', bookingsRouter);
app.use('/messages', messagesRouter);

const ridesRoutes = require('./routes/rides.routes');
app.use('/', ridesRoutes);

// Keep your known port
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`cabshare backend listening on :${PORT}`));
