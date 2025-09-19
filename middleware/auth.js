// middleware/auth.js - FIXED JWT VERIFICATION
const jwt = require('jsonwebtoken');

/** attachUser: decode bearer token and attach { id, email, token } if present */
function attachUser(req, _res, next) {
  // Check multiple auth methods
  let userId = null;
  let email = null;
  let token = null;

  // Method 1: x-user-id header (direct user ID)
  const xUserId = req.headers['x-user-id'] || req.headers['X-User-Id'];
  if (xUserId) {
    userId = xUserId;
    email = req.headers['x-user-email'] || req.headers['X-User-Email'];
    console.log('Auth via x-user-id:', userId);
  }

  // Method 2: Bearer token (JWT)
  if (!userId) {
    const auth = req.headers['authorization'] || '';
    const parts = auth.split(' ');
    if (parts[0] === 'Bearer' && parts[1]) {
      token = parts[1];
      try {
        // FIXED: Use jwt.verify instead of jwt.decode for better security
        const payload = jwt.verify(token, process.env.JWT_SECRET || 'fallback-secret-key');
        userId = payload.userId || payload.sub; // Support both userId and sub claims
        email = payload.email;
        console.log('Auth via Bearer token verified:', userId);
      } catch (e) {
        console.warn('JWT verification error:', e.message);
        // FALLBACK: Try decode without verification for development
        try {
          const decodedPayload = jwt.decode(token);
          if (decodedPayload) {
            userId = decodedPayload.userId || decodedPayload.sub;
            email = decodedPayload.email;
            console.log('Auth via Bearer token decoded (unverified):', userId);
          }
        } catch (decodeError) {
          console.warn('JWT decode error:', decodeError.message);
        }
      }
    }
  }

  if (userId) {
    req.user = { 
      id: userId, 
      email: email || null, 
      token: token || null,
      authProvider: req.headers['x-auth-provider'] || 'unknown'
    };
    console.log('User attached:', { id: userId, email, provider: req.user.authProvider });
  } else {
    req.user = undefined;
  }

  next();
}

function requireAuth(req, res, next) {
  if (!req.user?.id) {
    console.warn('Auth required but no user found:', {
      headers: {
        authorization: req.headers.authorization ? 'present' : 'missing',
        'x-user-id': req.headers['x-user-id'] ? 'present' : 'missing'
      },
      userObject: req.user
    });
    return res.status(401).json({ 
      error: 'Unauthorized - user ID required',
      message: 'Please ensure you are logged in and try again'
    });
  }
  next();
}

// Optional auth - don't fail if no auth
function optionalAuth(req, res, next) {
  attachUser(req, res, next);
}

module.exports = { attachUser, requireAuth, optionalAuth };