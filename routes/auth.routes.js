// routes/auth.routes.js - FIXED REGISTRATION WITH DETAILED ERROR HANDLING
const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { createClient } = require('@supabase/supabase-js');
const router = express.Router();

// Initialize Supabase client
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

// GET /auth/test - Simple test endpoint
router.get('/test', (req, res) => {
  res.json({
    success: true,
    message: 'Auth API is working',
    timestamp: new Date().toISOString(),
    supabase_url: process.env.SUPABASE_URL ? 'configured' : 'missing'
  });
});

// POST /auth/register - ENHANCED REGISTRATION WITH DETAILED LOGGING
router.post('/register', async (req, res) => {
  try {
    console.log('\n=== REGISTRATION ATTEMPT ===');
    console.log('Request body:', { 
      email: req.body.email, 
      phone: req.body.phone,
      fullName: req.body.fullName,
      hasPassword: !!req.body.password
    });
    
    const { email, password, fullName, phone } = req.body;
    
    // STEP 1: Basic field validation
    console.log('Step 1: Validating required fields...');
    if (!email || !password || !fullName || !phone) {
      console.log('❌ Missing required fields');
      return res.status(400).json({ 
        error: 'All fields are required',
        fields: { email: !!email, password: !!password, fullName: !!fullName, phone: !!phone }
      });
    }
    console.log('✅ All required fields present');

    // STEP 2: Password validation
    console.log('Step 2: Validating password...');
    if (password.length < 6) {
      console.log('❌ Password too short');
      return res.status(400).json({ 
        error: 'Password must be at least 6 characters long' 
      });
    }
    console.log('✅ Password length valid');

    // STEP 3: Phone format validation
    console.log('Step 3: Validating phone format...');
    if (!phone.startsWith('+91') || phone.length !== 13) {
      console.log('❌ Phone format invalid:', phone);
      return res.status(400).json({ 
        error: 'Invalid phone number format. Must be in +91XXXXXXXXXX format' 
      });
    }

    const phoneDigits = phone.substring(3);
    if (!/^\d{10}$/.test(phoneDigits)) {
      console.log('❌ Phone digits invalid:', phoneDigits);
      return res.status(400).json({ 
        error: 'Invalid phone number format. Must be 10 digits after +91' 
      });
    }
    console.log('✅ Phone format valid');

    // STEP 4: Check for existing email
    console.log('Step 4: Checking for existing email...');
    try {
      const { data: existingEmailUser, error: emailCheckError } = await supabase
        .from('users_app')
        .select('id, email')
        .eq('email', email)
        .maybeSingle();

      if (emailCheckError) {
        console.error('❌ Email check database error:', emailCheckError);
        return res.status(500).json({ 
          error: 'Database error during email validation',
          details: emailCheckError.message 
        });
      }

      if (existingEmailUser) {
        console.log('❌ Email already exists:', email);
        return res.status(409).json({ 
          error: 'This email is already registered. Please sign in instead.' 
        });
      }
      console.log('✅ Email is available');
    } catch (emailError) {
      console.error('❌ Email check failed:', emailError);
      return res.status(500).json({ 
        error: 'Failed to check email availability',
        details: emailError.message 
      });
    }

    // STEP 5: Check for existing phone
    console.log('Step 5: Checking for existing phone...');
    try {
      const { data: existingPhoneUser, error: phoneCheckError } = await supabase
        .from('users_app')
        .select('id, phone')
        .eq('phone', phone)
        .maybeSingle();

      if (phoneCheckError) {
        console.error('❌ Phone check database error:', phoneCheckError);
        return res.status(500).json({ 
          error: 'Database error during phone validation',
          details: phoneCheckError.message 
        });
      }

      if (existingPhoneUser) {
        console.log('❌ Phone already exists:', phone);
        return res.status(409).json({ 
          error: 'This phone number is already registered. Please use a different number.' 
        });
      }
      console.log('✅ Phone is available');
    } catch (phoneError) {
      console.error('❌ Phone check failed:', phoneError);
      return res.status(500).json({ 
        error: 'Failed to check phone availability',
        details: phoneError.message 
      });
    }

    // STEP 6: Hash password
    console.log('Step 6: Hashing password...');
    let passwordHash;
    try {
      const saltRounds = 12;
      passwordHash = await bcrypt.hash(password, saltRounds);
      console.log('✅ Password hashed successfully');
    } catch (hashError) {
      console.error('❌ Password hashing failed:', hashError);
      return res.status(500).json({ 
        error: 'Failed to process password',
        details: hashError.message 
      });
    }

    // STEP 7: Generate user ID
    console.log('Step 7: Generating user ID...');
    const userId = require('crypto').randomUUID();
    console.log('✅ Generated user ID:', userId);

    // STEP 8: Create user profile
    console.log('Step 8: Creating user profile...');
    try {
      const { data: userData, error: profileError } = await supabase
        .from('users_app')
        .insert({
          id: userId,
          email: email,
          phone: phone,
          full_name: fullName,
          password_hash: passwordHash,
          auth_provider: 'local',
          role: 'rider',
          is_verified: false,
          is_active: true,
          email_verified: false,
          phone_verified: false,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        })
        .select()
        .single();

      if (profileError) {
        console.error('❌ Profile creation error:', profileError);
        console.error('Error code:', profileError.code);
        console.error('Error details:', profileError.details);
        
        if (profileError.code === '23505') { // Unique constraint violation
          return res.status(409).json({ 
            error: 'User already exists with this email or phone number',
            details: profileError.message 
          });
        }
        
        return res.status(500).json({ 
          error: 'Profile creation failed',
          details: profileError.message,
          code: profileError.code 
        });
      }

      console.log('✅ User profile created successfully:', userData.id);

      // STEP 9: Create wallet
      console.log('Step 9: Creating wallet...');
      try {
        await createUserWallet(userData.id);
        console.log('✅ Wallet created successfully');
      } catch (walletError) {
        console.error('⚠️ Wallet creation failed (non-critical):', walletError);
        // Don't fail registration if wallet creation fails
      }

      // STEP 10: Generate JWT token
      console.log('Step 10: Generating JWT token...');
      const token = jwt.sign(
        { 
          userId: userData.id,
          email: userData.email,
          role: userData.role 
        },
        process.env.JWT_SECRET || 'fallback-secret-key',
        { expiresIn: '7d' }
      );
      console.log('✅ JWT token generated');

      console.log('🎉 Registration completed successfully for:', email);

      res.status(201).json({
        success: true,
        message: 'Registration successful',
        user: cleanUserResponse(userData),
        token: token
      });

    } catch (insertError) {
      console.error('❌ User insertion failed:', insertError);
      console.error('Insert error stack:', insertError.stack);
      return res.status(500).json({ 
        error: 'Failed to create user account',
        details: insertError.message,
        type: insertError.constructor.name 
      });
    }

  } catch (error) {
    console.error('❌ REGISTRATION FAILED:', error);
    console.error('Error stack:', error.stack);
    res.status(500).json({ 
      error: 'Registration failed',
      message: error.message,
      type: error.constructor.name 
    });
  }
});

// POST /auth/login - SIMPLE LOGIN (Works with local auth)
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    
    console.log('Login attempt for email:', email);
    
    if (!email || !password) {
      return res.status(400).json({ 
        error: 'Email and password required' 
      });
    }

    // Get user from users_app table
    const { data: userProfile, error: profileError } = await supabase
      .from('users_app')
      .select('*')
      .eq('email', email)
      .eq('is_active', true)
      .single();

    if (profileError || !userProfile) {
      console.error('User lookup error:', profileError);
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    // Check password
    let passwordValid = false;
    
    if (userProfile.password_hash) {
      // Local auth - check hashed password
      passwordValid = await bcrypt.compare(password, userProfile.password_hash);
    }

    if (!passwordValid) {
      console.log('Invalid password for:', email);
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    // Update last login
    await supabase
      .from('users_app')
      .update({ 
        last_login: new Date().toISOString(),
        updated_at: new Date().toISOString()
      })
      .eq('id', userProfile.id);

    // Generate JWT token
    const token = jwt.sign(
      { 
        userId: userProfile.id,
        email: userProfile.email,
        role: userProfile.role 
      },
      process.env.JWT_SECRET || 'fallback-secret-key',
      { expiresIn: '7d' }
    );

    console.log('Login successful for:', email);

    res.json({
      success: true,
      message: 'Login successful',
      user: cleanUserResponse(userProfile),
      token: token
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ 
      error: 'Login failed',
      message: error.message 
    });
  }
});

// GET /auth/check-phone - Check if phone number is registered
router.get('/check-phone', async (req, res) => {
  try {
    const phone = req.headers['x-phone'];
    
    if (!phone) {
      return res.status(400).json({ error: 'Phone number required' });
    }

    const { data, error } = await supabase
      .from('users_app')
      .select('id, full_name, email')
      .eq('phone', phone)
      .eq('is_active', true)
      .maybeSingle();

    if (error && error.code !== 'PGRST116') {
      throw error;
    }

    res.json({
      exists: data !== null,
      user: data ? {
        id: data.id,
        full_name: data.full_name,
        email: data.email
      } : null
    });

  } catch (error) {
    console.error('Phone check error:', error);
    res.status(500).json({ 
      error: 'Failed to check phone number',
      message: error.message 
    });
  }
});

// POST /auth/logout - Simple logout
router.post('/logout', (req, res) => {
  res.json({
    success: true,
    message: 'Logout successful'
  });
});

// Helper Functions

async function createUserWallet(userId) {
  try {
    console.log('Creating wallet for user:', userId);
    
    // Check if wallet already exists
    const { data: existingWallet, error: checkError } = await supabase
      .from('wallets')
      .select('id')
      .eq('user_id', userId)
      .maybeSingle();

    if (checkError && checkError.code !== 'PGRST116') {
      console.error('Wallet check error:', checkError);
      return;
    }

    if (existingWallet) {
      console.log('Wallet already exists for user:', userId);
      return;
    }

    // Create new wallet
    const { error } = await supabase
      .from('wallets')
      .insert({
        user_id: userId,
        balance_available_inr: 0,
        balance_reserved_inr: 0,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      });

    if (error) {
      console.error('Wallet creation error:', error);
      throw error;
    } else {
      console.log('Wallet created successfully for user:', userId);
    }
  } catch (e) {
    console.error('Wallet creation failed:', e);
    throw e;
  }
}

function cleanUserResponse(user) {
  return {
    id: user.id,
    email: user.email,
    full_name: user.full_name,
    phone: user.phone,
    role: user.role,
    is_verified: user.is_verified,
    is_active: user.is_active,
    auth_provider: user.auth_provider,
    email_verified: user.email_verified,
    phone_verified: user.phone_verified,
    created_at: user.created_at
  };
}

module.exports = router;
