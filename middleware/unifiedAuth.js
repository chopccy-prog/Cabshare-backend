// middleware/unifiedAuth.js - ENHANCED AUTHENTICATION WITH FLUTTER SUPPORT
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

/**
 * Enhanced unified authentication middleware with comprehensive fallback mechanisms
 * Specifically designed to work with Flutter app authentication
 */
async function unifiedAuthMiddleware(req, res, next) {
  try {
    console.log('🔐 Auth Middleware - Processing request:', req.method, req.path);
    
    // Extract authentication info from various sources
    const authHeader = req.headers.authorization;
    const userIdHeader = req.headers['x-user-id'];
    const userEmailHeader = req.headers['x-user-email'];
    const userPhoneHeader = req.headers['x-user-phone'];
    const userNameHeader = req.headers['x-user-name'];
    const authProviderHeader = req.headers['x-auth-provider'];
    
    console.log('🔍 Auth headers received:', {
      hasAuthHeader: !!authHeader,
      userIdHeader,
      userEmailHeader,
      userPhoneHeader,
      userNameHeader,
      authProviderHeader
    });

    let user = null;
    let token = null;

    // Extract token if present
    if (authHeader?.startsWith('Bearer ')) {
      token = authHeader.substring(7);
      console.log('📋 Token extracted, length:', token.length);
    }

    // Method 1: Try Supabase token verification
    if (token && !user) {
      try {
        console.log('🔄 Attempting Supabase token verification...');
        const { data, error } = await supabase.auth.getUser(token);
        
        if (!error && data.user) {
          console.log('✅ Supabase token verified for user:', data.user.id);
          
          // Get or create user profile
          user = await getOrCreateUserProfile(data.user, {
            email: userEmailHeader,
            phone: userPhoneHeader,
            name: userNameHeader,
            provider: 'supabase'
          });
        } else {
          console.log('❌ Supabase token verification failed:', error?.message);
        }
      } catch (supabaseError) {
        console.log('⚠️ Supabase token verification error:', supabaseError.message);
      }
    }

    // Method 2: Header-based authentication (for Flutter app)
    if (!user && userIdHeader && (userEmailHeader || userPhoneHeader)) {
      try {
        console.log('🔄 Attempting header-based authentication...');
        
        // First, try to find existing user by ID
        const { data: existingUser } = await supabase
          .from('users_app')
          .select('*')
          .eq('id', userIdHeader)
          .single();

        if (existingUser) {
          user = existingUser;
          console.log('✅ Found existing user by ID:', user.id);
        } else {
          // Try to find by email or phone
          let findQuery = supabase.from('users_app').select('*');
          
          if (userEmailHeader) {
            findQuery = findQuery.eq('email', userEmailHeader);
          } else if (userPhoneHeader) {
            findQuery = findQuery.eq('phone', userPhoneHeader);
          }
          
          const { data: foundUser } = await findQuery.single();
          
          if (foundUser) {
            user = foundUser;
            console.log('✅ Found existing user by email/phone:', user.id);
          } else {
            // Create new user from headers
            console.log('🆕 Creating new user from headers...');
            user = await createUserFromHeaders({
              id: userIdHeader,
              email: userEmailHeader,
              phone: userPhoneHeader,
              name: userNameHeader,
              provider: authProviderHeader || 'flutter_app'
            });
          }
        }
      } catch (headerAuthError) {
        console.log('⚠️ Header-based authentication error:', headerAuthError.message);
      }
    }

    // Method 3: Email/Phone lookup without user ID
    if (!user && (userEmailHeader || userPhoneHeader)) {
      try {
        console.log('🔄 Attempting email/phone lookup...');
        
        let lookupQuery = supabase.from('users_app').select('*');
        
        if (userEmailHeader) {
          lookupQuery = lookupQuery.eq('email', userEmailHeader);
        } else if (userPhoneHeader) {
          lookupQuery = lookupQuery.eq('phone', userPhoneHeader);
        }
        
        const { data: lookupUser } = await lookupQuery.single();
        
        if (lookupUser) {
          user = lookupUser;
          console.log('✅ Found user by lookup:', user.id);
        }
      } catch (lookupError) {
        console.log('⚠️ Email/phone lookup failed:', lookupError.message);
      }
    }

    // Method 4: Demo user fallback (for development and testing)
    if (!user && (process.env.NODE_ENV === 'development' || process.env.ALLOW_DEMO_USER === 'true')) {
      console.log('🔄 Using demo user fallback...');
      user = await getOrCreateDemoUser();
    }

    // Method 5: Create anonymous user for testing (if headers provided)
    if (!user && (userEmailHeader || userPhoneHeader || userNameHeader)) {
      try {
        console.log('🔄 Creating anonymous user for testing...');
        user = await createUserFromHeaders({
          id: userIdHeader || generateUUID(),
          email: userEmailHeader || `test-${Date.now()}@worksetu.com`,
          phone: userPhoneHeader || `+91${Math.floor(Math.random() * 9000000000) + 1000000000}`,
          name: userNameHeader || 'Test User',
          provider: authProviderHeader || 'anonymous'
        });
      } catch (anonError) {
        console.log('⚠️ Anonymous user creation failed:', anonError.message);
      }
    }

    if (!user) {
      console.log('❌ No valid authentication found');
      return res.status(401).json({ 
        error: 'Authentication required',
        message: 'Please provide valid authentication credentials',
        debug: {
          hasAuthHeader: !!authHeader,
          hasUserIdHeader: !!userIdHeader,
          hasUserEmailHeader: !!userEmailHeader,
          hasUserPhoneHeader: !!userPhoneHeader,
          isDevelopment: process.env.NODE_ENV === 'development',
          allowDemoUser: process.env.ALLOW_DEMO_USER === 'true'
        }
      });
    }

    // Check if user is active
    if (!user.is_active) {
      console.log('⚠️ User account is deactivated:', user.id);
      return res.status(401).json({ 
        error: 'Account deactivated',
        message: 'Please contact support'
      });
    }

    // Update last login time
    try {
      await supabase
        .from('users_app')
        .update({ 
          last_login_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        })
        .eq('id', user.id);
    } catch (updateError) {
      console.log('⚠️ Failed to update last login:', updateError.message);
    }

    // Attach user to request
    req.user = user;
    req.userId = user.id;
    req.authProvider = user.auth_provider || authProviderHeader || 'unknown';
    
    console.log('✅ Authentication successful:', {
      userId: user.id,
      email: user.email,
      provider: req.authProvider,
      role: user.role
    });
    
    next();

  } catch (error) {
    console.error('💥 Auth middleware error:', error);
    res.status(500).json({ 
      error: 'Authentication failed',
      message: 'Internal server error during authentication',
      debug: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
}

/**
 * Get or create user profile from Supabase auth user
 */
async function getOrCreateUserProfile(authUser, headerData = {}) {
  console.log('👤 Getting/creating user profile for:', authUser.id);
  
  // Try to get existing profile
  const { data: existingProfile } = await supabase
    .from('users_app')
    .select('*')
    .eq('id', authUser.id)
    .single();

  if (existingProfile) {
    console.log('✅ Found existing user profile:', existingProfile.id);
    return existingProfile;
  }

  // Create new profile
  const newProfileData = {
    id: authUser.id,
    email: authUser.email || headerData.email || '',
    phone: authUser.phone || headerData.phone || '',
    full_name: authUser.user_metadata?.full_name || 
               authUser.user_metadata?.name || 
               headerData.name || 
               'User',
    supabase_uid: authUser.id,
    auth_provider: headerData.provider || 'supabase',
    role: 'rider',
    is_verified: !!authUser.email_confirmed_at,
    is_active: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  };

  const { data: newProfile, error: createError } = await supabase
    .from('users_app')
    .insert(newProfileData)
    .select()
    .single();

  if (createError) {
    console.error('❌ Failed to create user profile:', createError);
    throw new Error('Failed to create user profile: ' + createError.message);
  }

  console.log('✅ Created new user profile:', newProfile.id);

  // Create wallet for new user
  await createUserWallet(newProfile.id);

  return newProfile;
}

/**
 * Create user from headers (Flutter app)
 */
async function createUserFromHeaders(headerData) {
  console.log('🆕 Creating user from headers:', headerData);
  
  const userData = {
    id: headerData.id,
    email: headerData.email,
    phone: headerData.phone,
    full_name: headerData.name,
    auth_provider: headerData.provider,
    role: 'rider',
    is_verified: true, // Auto-verify for header-based auth
    is_active: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  };

  const { data: newUser, error: createError } = await supabase
    .from('users_app')
    .insert(userData)
    .select()
    .single();

  if (createError) {
    console.error('❌ Failed to create user from headers:', createError);
    throw new Error('Failed to create user: ' + createError.message);
  }

  console.log('✅ Created user from headers:', newUser.id);

  // Create wallet
  await createUserWallet(newUser.id);

  return newUser;
}

/**
 * Get or create demo user
 */
async function getOrCreateDemoUser() {
  console.log('🔄 Getting/creating demo user...');
  
  const { data: demoUser } = await supabase
    .from('users_app')
    .select('*')
    .eq('email', 'demo@worksetu.com')
    .single();

  if (demoUser) {
    console.log('✅ Using existing demo user:', demoUser.id);
    return demoUser;
  }

  // Create demo user
  const demoUserData = {
    id: '00000000-0000-0000-0000-000000000001',
    email: 'demo@worksetu.com',
    phone: '+919999999999',
    full_name: 'Demo User',
    auth_provider: 'demo',
    role: 'rider',
    is_verified: true,
    is_active: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  };

  const { data: newDemoUser, error: createError } = await supabase
    .from('users_app')
    .insert(demoUserData)
    .select()
    .single();

  if (createError) {
    console.error('❌ Failed to create demo user:', createError);
    throw new Error('Failed to create demo user: ' + createError.message);
  }

  console.log('✅ Created demo user:', newDemoUser.id);

  // Create wallet with demo balance
  await createUserWallet(newDemoUser.id, 1000);

  return newDemoUser;
}

/**
 * Create wallet for user
 */
async function createUserWallet(userId, initialBalance = 0) {
  try {
    await supabase.from('wallets').insert({
      user_id: userId,
      balance_available_inr: initialBalance,
      balance_reserved_inr: 0,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    });
    console.log('✅ Created wallet for user:', userId, 'with balance:', initialBalance);
  } catch (walletError) {
    console.error('⚠️ Wallet creation error:', walletError);
  }
}

/**
 * Generate UUID
 */
function generateUUID() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

/**
 * Optional authentication - doesn't fail if no token provided
 */
async function optionalAuthMiddleware(req, res, next) {
  const authHeader = req.headers.authorization;
  const userIdHeader = req.headers['x-user-id'];
  const userEmailHeader = req.headers['x-user-email'];
  
  if (!authHeader && !userIdHeader && !userEmailHeader) {
    console.log('ℹ️ No authentication provided for optional auth');
    req.user = null;
    req.userId = null;
    req.authProvider = null;
    return next();
  }

  // Try to authenticate, but don't fail if it doesn't work
  try {
    await unifiedAuthMiddleware(req, res, () => {
      console.log('✅ Optional authentication succeeded');
      next();
    });
  } catch (error) {
    console.log('⚠️ Optional auth failed, continuing without user:', error.message);
    req.user = null;
    req.userId = null;
    req.authProvider = null;
    next();
  }
}

/**
 * Middleware to ensure user has specific role
 */
function requireRole(role) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required' });
    }
    
    if (req.user.role !== role) {
      return res.status(403).json({ 
        error: 'Insufficient permissions',
        message: `Role '${role}' required, but user has role '${req.user.role}'`
      });
    }
    
    next();
  };
}

/**
 * Middleware to ensure user is admin
 */
function requireAdmin(req, res, next) {
  if (!req.user) {
    return res.status(401).json({ error: 'Authentication required' });
  }
  
  if (req.user.role !== 'admin') {
    return res.status(403).json({ 
      error: 'Admin access required',
      message: 'This endpoint requires admin privileges'
    });
  }
  
  next();
}

/**
 * Debug middleware to log all request details
 */
function debugAuthMiddleware(req, res, next) {
  if (process.env.NODE_ENV === 'development') {
    console.log('🐛 Debug Auth Info:', {
      method: req.method,
      path: req.path,
      headers: {
        authorization: req.headers.authorization ? 'Bearer [REDACTED]' : undefined,
        'x-user-id': req.headers['x-user-id'],
        'x-user-email': req.headers['x-user-email'],
        'x-user-phone': req.headers['x-user-phone'],
        'x-auth-provider': req.headers['x-auth-provider'],
      },
      query: req.query,
      body: req.method === 'POST' ? req.body : undefined
    });
  }
  next();
}

module.exports = {
  unifiedAuthMiddleware,
  optionalAuthMiddleware,
  requireRole,
  requireAdmin,
  debugAuthMiddleware,
  // Legacy compatibility
  requireAuth: unifiedAuthMiddleware,
  optionalAuth: optionalAuthMiddleware
};
