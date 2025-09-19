const express = require('express');
const router = express.Router();
const { supabase } = require('../supabase');
const UserSyncService = require('../services/userSync');
const { v4: uuidv4 } = require('uuid');

// POST /user-management/create-complete-user
router.post('/create-complete-user', async (req, res) => {
  try {
    const { email, password, full_name, phone, role = 'passenger' } = req.body;
    
    if (!email || !password) {
      return res.status(400).json({ 
        error: 'Email and password are required' 
      });
    }

    console.log('Creating complete user:', { email, full_name, role });

    // Step 1: Create Supabase auth user
    const { data: authUser, error: authError } = await supabase.auth.admin.createUser({
      email: email,
      password: password,
      email_confirm: true, // Auto-confirm
      user_metadata: {
        full_name: full_name,
        phone: phone,
        role: role
      }
    });

    if (authError) {
      console.error('Supabase auth creation error:', authError);
      return res.status(400).json({ 
        error: 'Failed to create auth user',
        details: authError.message 
      });
    }

    console.log('Auth user created:', authUser.user.id);

    // Step 2: Sync to unified tables
    const syncedUser = await UserSyncService.syncUser(authUser.user, 'supabase');

    res.json({
      success: true,
      user: syncedUser,
      message: 'Complete user created successfully'
    });

  } catch (error) {
    console.error('Complete user creation error:', error);
    res.status(500).json({ 
      error: 'Failed to create complete user',
      message: error.message 
    });
  }
});

// GET /user-management/audit-users
router.get('/audit-users', async (req, res) => {
  try {
    console.log('Starting user audit...');
    
    // Step 1: Get all Supabase auth users
    const { data: authResponse, error: authError } = await supabase.auth.admin.listUsers();
    
    if (authError) {
      console.error('Auth users fetch error:', authError);
      throw authError;
    }

    const authUsers = authResponse.users || [];
    console.log(`Found ${authUsers.length} auth users`);

    // Step 2: Get all app users
    const { data: appUsers, error: appError } = await supabase
      .from('users_app')
      .select('id, supabase_uid, firebase_uid, email, created_at, full_name');
    
    if (appError) {
      console.error('App users fetch error:', appError);
      throw appError;
    }

    console.log(`Found ${appUsers?.length || 0} app users`);

    // Step 3: Find orphaned auth users (auth users without app records)
    const appUserIds = new Set(appUsers?.map(u => u.id) || []);
    const appSupabaseIds = new Set(appUsers?.map(u => u.supabase_uid).filter(Boolean) || []);
    const appFirebaseIds = new Set(appUsers?.map(u => u.firebase_uid).filter(Boolean) || []);
    
    const orphanedAuth = authUsers.filter(au => {
      // Check if this auth user has a corresponding app record
      return !appUserIds.has(au.id) && 
             !appSupabaseIds.has(au.id) && 
             !appFirebaseIds.has(au.id);
    });

    // Step 4: Find orphaned app users (app users without auth records)
    const authUserIds = new Set(authUsers.map(au => au.id));
    
    const orphanedApp = (appUsers || []).filter(au => {
      // Check if this app user has a corresponding auth record
      return !authUserIds.has(au.id) && 
             !authUserIds.has(au.supabase_uid) && 
             !authUserIds.has(au.firebase_uid);
    });

    // Step 5: Check for users without wallets
    const { data: walletUsers, error: walletError } = await supabase
      .from('wallets')
      .select('user_id');
    
    const walletUserIds = new Set(walletUsers?.map(w => w.user_id) || []);
    const usersWithoutWallets = (appUsers || []).filter(u => !walletUserIds.has(u.id));

    console.log(`Audit complete: ${orphanedAuth.length} orphaned auth, ${orphanedApp.length} orphaned app, ${usersWithoutWallets.length} without wallets`);

    res.json({
      success: true,
      audit: {
        total_auth_users: authUsers.length,
        total_app_users: appUsers?.length || 0,
        total_wallets: walletUsers?.length || 0,
        orphaned_auth_users: orphanedAuth.length,
        orphaned_app_users: orphanedApp.length,
        users_without_wallets: usersWithoutWallets.length,
        orphaned_auth_details: orphanedAuth.map(u => ({
          id: u.id,
          email: u.email,
          created_at: u.created_at,
          phone: u.phone
        })),
        orphaned_app_details: orphanedApp.map(u => ({
          id: u.id,
          email: u.email,
          created_at: u.created_at,
          full_name: u.full_name,
          supabase_uid: u.supabase_uid,
          firebase_uid: u.firebase_uid
        })),
        users_without_wallets_details: usersWithoutWallets.map(u => ({
          id: u.id,
          email: u.email,
          full_name: u.full_name
        }))
      }
    });

  } catch (error) {
    console.error('User audit error:', error);
    res.status(500).json({ 
      error: 'Failed to audit users',
      message: error.message 
    });
  }
});

// DELETE /user-management/cleanup-orphans
router.delete('/cleanup-orphans', async (req, res) => {
  try {
    if (process.env.NODE_ENV === 'production') {
      return res.status(403).json({ 
        error: 'Cleanup not allowed in production' 
      });
    }

    let deletedAuthCount = 0;
    let deletedAppCount = 0;
    let createdWalletCount = 0;

    console.log('Starting cleanup process...');

    // Step 1: Get all users for comparison
    const { data: authResponse } = await supabase.auth.admin.listUsers();
    const authUsers = authResponse?.users || [];
    
    const { data: appUsers } = await supabase
      .from('users_app')
      .select('id, supabase_uid, firebase_uid, email');

    // Step 2: Find and delete orphaned auth users
    const appUserIds = new Set((appUsers || []).map(u => u.id));
    const appSupabaseIds = new Set((appUsers || []).map(u => u.supabase_uid).filter(Boolean));
    const appFirebaseIds = new Set((appUsers || []).map(u => u.firebase_uid).filter(Boolean));
    
    const orphanedAuth = authUsers.filter(au => 
      !appUserIds.has(au.id) && !appSupabaseIds.has(au.id) && !appFirebaseIds.has(au.id)
    );

    console.log(`Found ${orphanedAuth.length} orphaned auth users`);

    for (const authUser of orphanedAuth) {
      try {
        const { error } = await supabase.auth.admin.deleteUser(authUser.id);
        if (!error) {
          deletedAuthCount++;
          console.log(`Deleted orphaned auth user: ${authUser.email}`);
        } else {
          console.error(`Failed to delete auth user ${authUser.id}:`, error);
        }
      } catch (e) {
        console.error(`Error deleting auth user ${authUser.id}:`, e);
      }
    }

    // Step 3: Find and handle orphaned app users
    const authUserIds = new Set(authUsers.map(au => au.id));
    const orphanedApp = (appUsers || []).filter(au => 
      !authUserIds.has(au.id) && !authUserIds.has(au.supabase_uid) && !authUserIds.has(au.firebase_uid)
    );

    console.log(`Found ${orphanedApp.length} orphaned app users`);

    // Delete orphaned app users and their related data
    for (const appUser of orphanedApp) {
      try {
        // Delete related data first
        await supabase.from('wallet_transactions').delete().eq('user_id', appUser.id);
        await supabase.from('wallets').delete().eq('user_id', appUser.id);
        await supabase.from('bookings').delete().eq('rider_id', appUser.id);
        await supabase.from('rides').delete().eq('driver_id', appUser.id);
        
        // Delete user record
        const { error } = await supabase.from('users_app').delete().eq('id', appUser.id);
        
        if (!error) {
          deletedAppCount++;
          console.log(`Deleted orphaned app user: ${appUser.email}`);
        } else {
          console.error(`Failed to delete app user ${appUser.id}:`, error);
        }
      } catch (e) {
        console.error(`Error deleting app user ${appUser.id}:`, e);
      }
    }

    // Step 4: Create missing wallets for existing users
    const { data: walletUsers } = await supabase.from('wallets').select('user_id');
    const walletUserIds = new Set((walletUsers || []).map(w => w.user_id));
    
    const usersWithoutWallets = (appUsers || []).filter(u => !walletUserIds.has(u.id));
    
    console.log(`Found ${usersWithoutWallets.length} users without wallets`);
    
    for (const user of usersWithoutWallets) {
      try {
        const { error } = await supabase.from('wallets').insert({
          user_id: user.id,
          balance_available_inr: 0,
          balance_reserved_inr: 0,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        });
        
        if (!error) {
          createdWalletCount++;
          console.log(`Created wallet for user: ${user.email}`);
        } else {
          console.error(`Failed to create wallet for user ${user.id}:`, error);
        }
      } catch (e) {
        console.error(`Error creating wallet for user ${user.id}:`, e);
      }
    }

    res.json({
      success: true,
      message: `Cleanup completed: ${deletedAuthCount} auth users, ${deletedAppCount} app users deleted, ${createdWalletCount} wallets created`,
      details: {
        orphaned_auth_found: orphanedAuth.length,
        orphaned_auth_deleted: deletedAuthCount,
        orphaned_app_found: orphanedApp.length,
        orphaned_app_deleted: deletedAppCount,
        users_without_wallets: usersWithoutWallets.length,
        wallets_created: createdWalletCount
      }
    });

  } catch (error) {
    console.error('Cleanup error:', error);
    res.status(500).json({ 
      error: 'Cleanup failed',
      message: error.message 
    });
  }
});

// GET /user-management/sql-audit - Direct SQL audit with proper type casting
router.get('/sql-audit', async (req, res) => {
  try {
    if (process.env.NODE_ENV === 'production') {
      return res.status(403).json({ 
        error: 'SQL audit not allowed in production' 
      });
    }

    console.log('Running SQL audit with type casting...');

    // Query 1: Find Supabase auth users without users_app records (FIXED)
    const orphanedAuthQuery = `
      SELECT au.id, au.email, au.created_at, au.phone
      FROM auth.users au
      LEFT JOIN public.users_app ua ON au.id::uuid = ua.id OR au.id::uuid = ua.supabase_uid
      WHERE ua.id IS NULL
      ORDER BY au.created_at DESC
      LIMIT 50;
    `;

    const { data: orphanedAuth, error: orphanedAuthError } = await supabase
      .rpc('execute_sql', { query: orphanedAuthQuery })
      .catch(async () => {
        // If RPC doesn't exist, try direct query
        return await supabase
          .from('auth.users')
          .select('id, email, created_at, phone')
          .limit(50);
      });

    // Query 2: Find users_app records without auth (FIXED)
    const orphanedAppQuery = `
      SELECT ua.id, ua.email, ua.created_at, ua.full_name, ua.supabase_uid, ua.firebase_uid
      FROM public.users_app ua
      LEFT JOIN auth.users au ON ua.id::text = au.id OR ua.supabase_uid::text = au.id
      WHERE au.id IS NULL
      ORDER BY ua.created_at DESC
      LIMIT 50;
    `;

    // Since we can't easily access auth.users from public schema, let's do this via JS
    const { data: authUsers } = await supabase.auth.admin.listUsers();
    const { data: appUsers } = await supabase
      .from('users_app')
      .select('id, email, created_at, full_name, supabase_uid, firebase_uid');

    const authUserIds = new Set(authUsers?.users?.map(u => u.id) || []);
    const orphanedAppUsers = (appUsers || []).filter(ua => {
      return !authUserIds.has(ua.id) && 
             !authUserIds.has(ua.supabase_uid) && 
             !authUserIds.has(ua.firebase_uid);
    });

    // Query 3: Users without wallets
    const { data: usersWithoutWallets, error: walletError } = await supabase
      .from('users_app')
      .select(`
        id, email, full_name, created_at,
        wallets!left(user_id)
      `)
      .is('wallets.user_id', null);

    // Query 4: Check data consistency
    const { data: dataConsistency, error: consistencyError } = await supabase
      .from('users_app')
      .select(`
        id, email, role, is_verified,
        wallets(user_id, balance_available_inr),
        rides!rides_driver_id_fkey(count),
        bookings!bookings_rider_id_fkey(count)
      `);

    res.json({
      success: true,
      sql_audit: {
        orphaned_auth_users: {
          count: orphanedAuth?.length || 0,
          details: orphanedAuth || []
        },
        orphaned_app_users: {
          count: orphanedAppUsers.length,
          details: orphanedAppUsers.slice(0, 50) // Limit for response size
        },
        users_without_wallets: {
          count: usersWithoutWallets?.length || 0,
          details: usersWithoutWallets || []
        },
        data_consistency: {
          total_users: dataConsistency?.length || 0,
          users_with_wallets: dataConsistency?.filter(u => u.wallets?.length > 0).length || 0,
          drivers: dataConsistency?.filter(u => u.role === 'driver').length || 0,
          passengers: dataConsistency?.filter(u => u.role === 'passenger').length || 0
        },
        query_info: {
          note: 'This audit uses proper type casting to avoid UUID/text comparison errors',
          queries_used: [
            'auth.users LEFT JOIN users_app with uuid casting',
            'users_app LEFT JOIN auth.users via JavaScript',
            'users_app LEFT JOIN wallets',
            'Data consistency check'
          ]
        }
      }
    });

  } catch (error) {
    console.error('SQL audit error:', error);
    res.status(500).json({ 
      error: 'SQL audit failed',
      message: error.message,
      details: error.stack
    });
  }
});

// GET /user-management/fix-wallet-missing - Create missing wallets
router.post('/fix-wallet-missing', async (req, res) => {
  try {
    console.log('Fixing missing wallets...');

    // Find users without wallets
    const { data: usersWithoutWallets, error } = await supabase
      .from('users_app')
      .select(`
        id, email, full_name,
        wallets!left(user_id)
      `)
      .is('wallets.user_id', null);

    if (error) {
      console.error('Error finding users without wallets:', error);
      return res.status(400).json({ error: error.message });
    }

    let createdCount = 0;
    const errors = [];

    for (const user of usersWithoutWallets || []) {
      try {
        const { error: walletError } = await supabase
          .from('wallets')
          .insert({
            user_id: user.id,
            balance_available_inr: 0,
            balance_reserved_inr: 0,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString()
          });

        if (walletError) {
          errors.push({ user_id: user.id, email: user.email, error: walletError.message });
        } else {
          createdCount++;
          console.log(`Created wallet for ${user.email}`);
        }
      } catch (e) {
        errors.push({ user_id: user.id, email: user.email, error: e.message });
      }
    }

    res.json({
      success: true,
      message: `Created ${createdCount} wallets for users`,
      details: {
        users_without_wallets_found: usersWithoutWallets?.length || 0,
        wallets_created: createdCount,
        errors: errors
      }
    });

  } catch (error) {
    console.error('Fix wallet missing error:', error);
    res.status(500).json({ 
      error: 'Failed to fix missing wallets',
      message: error.message 
    });
  }
});

module.exports = router;