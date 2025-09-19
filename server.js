require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();

// Basic middleware only
app.use(cors({ origin: true, credentials: false }));
app.use(express.json());

// Import enhanced auth middleware
const { 
  unifiedAuthMiddleware, 
  optionalAuthMiddleware,
  debugAuthMiddleware 
} = require('./middleware/unifiedAuth');

// Add debug middleware in development
if (process.env.NODE_ENV === 'development') {
  app.use(debugAuthMiddleware);
}

// Minimal logging middleware
app.use((req, res, next) => {
  console.log(`${req.method} ${req.path}`);
  next();
});

// Import routes
const authRouter = require('./routes/auth.routes');
const userManagementRouter = require('./routes/userManagement.routes');
const ridesRouter = require('./routes/rides.routes');
const bookingsRouter = require('./routes/bookings.routes');
const citiesRouter = require('./routes/cities.routes');
const routesRouter = require('./routes/routes.routes');
const profilesRouter = require('./routes/profiles.routes');
const profileRouter = require('./routes/profile.routes');
const messagesRouter = require('./routes/messages.routes');
const inboxRouter = require('./routes/inbox.routes');
const adminRoutes = require('./routes/admin');

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    auth_middleware: 'enhanced',
    environment: process.env.NODE_ENV || 'production'
  });
});

// API Routes - UPDATED WITH ENHANCED MIDDLEWARE
app.use('/auth', authRouter);
app.use('/user-management', userManagementRouter);
app.use('/cities', citiesRouter);
app.use('/routes', routesRouter);
app.use('/profiles', optionalAuthMiddleware, profilesRouter);
app.use('/rides', ridesRouter); // Routes handle auth internally
app.use('/bookings', bookingsRouter);
app.use('/messages', unifiedAuthMiddleware, messagesRouter);
app.use('/inbox', unifiedAuthMiddleware, inboxRouter);

// Add API prefix routes for compatibility
app.use('/api/auth', authRouter);
app.use('/api/user-management', userManagementRouter);
app.use('/api/wallet', require('./routes/wallet'));
app.use('/api/profile', profileRouter);
app.use('/api/rides', ridesRouter); // Routes handle auth internally
app.use('/api/bookings', bookingsRouter);
app.use('/api/cities', citiesRouter);
app.use('/api/routes', routesRouter);
app.use('/api/inbox', unifiedAuthMiddleware, inboxRouter);
app.use('/api/admin', adminRoutes);

// Simple error handling
app.use((error, req, res, next) => {
  console.error('💥 Server Error:', error.message);
  res.status(500).json({ 
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? error.message : undefined,
    timestamp: new Date().toISOString()
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ 
    error: 'Route not found',
    path: req.originalUrl,
    method: req.method,
    timestamp: new Date().toISOString()
  });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 CabShare backend running on port ${PORT}`);
  console.log(`🔐 Enhanced Auth: ${process.env.NODE_ENV === 'development' ? 'Development Mode' : 'Production Mode'}`);
  console.log(`🛣️  API Routes:`);
  console.log(`   • Auth endpoints: http://localhost:${PORT}/auth/*`);
  console.log(`   • Rides API: http://localhost:${PORT}/api/rides/*`);
  console.log(`   • Bookings API: http://localhost:${PORT}/api/bookings/*`);
  console.log(`   • Profile API: http://localhost:${PORT}/api/profile/*`);
  console.log(`   • Cities API: http://localhost:${PORT}/api/cities/*`);
  console.log(`   • Routes API: http://localhost:${PORT}/api/routes/*`);
  console.log(`📊 Admin panel: http://localhost:${PORT}/admin`);
  console.log(`💚 Health check: http://localhost:${PORT}/health`);
  console.log(`🔧 Demo User Support: ${process.env.ALLOW_DEMO_USER === 'true' ? 'Enabled' : 'Disabled'}`);
});

module.exports = app;
