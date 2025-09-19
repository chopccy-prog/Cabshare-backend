// services/userSync.js - FIXED for Current Schema
// This service ensures users are properly synced between Firebase and Supabase

const { supabase } = require('../supabase');

class UserSyncService {
  /**
   * Create or sync user across Firebase and Supabase
   * @param {Object} userData - User data from Firebase or Supabase
   * @param {string} source - 'firebase' or 'supabase'
   */
  static async syncUser(userData, source = 'firebase') {
    try {
      console.log(`Syncing user from ${source}:`, userData);

      // Normalize user data
      const normalizedUser = this.normalizeUserData(userData, source);
      
      // Check if user exists in unified table (users_app)
      const { data: existingUser, error: findError } = await supabase
        .from('users_app')
        .select('*')
        .or(`id.eq.${normalizedUser.id},email.eq.${normalizedUser.email}`)
        .maybeSingle(); // Use maybeSingle instead of single to avoid error when not found

      if (findError) {
        console.error('Find user error:', findError);
        throw findError;
      }

      let syncedUser;

      if (existingUser) {
        // Update existing user
        const updateData = {
          full_name: normalizedUser.full_name || existingUser.full_name,
          phone: normalizedUser.phone || existingUser.phone,
          photo_url: normalizedUser.photo_url || existingUser.photo_url,
          auth_provider: normalizedUser.auth_provider,
          last_login: new Date().toISOString(),
          updated_at: new Date().toISOString()
        };

        // Add source-specific fields
        if (source === 'firebase') {
          updateData.firebase_uid = normalizedUser.firebase_uid;
          updateData.firebase_synced = true;
        } else {
          updateData.supabase_uid = normalizedUser.supabase_uid;
          updateData.supabase_synced = true;
        }

        const { data: updatedUser, error: updateError } = await supabase
          .from('users_app')
          .update(updateData)
          .eq('id', existingUser.id)
          .select()
          .single();

        if (updateError) throw updateError;
        syncedUser = updatedUser;
        console.log('User updated:', syncedUser.id);
      } else {
        // Create new user
        const { data: newUser, error: createError } = await supabase
          .from('users_app')
          .insert({
            ...normalizedUser,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
            last_login: new Date().toISOString(),
            is_active: true,
            is_verified: false
          })
          .select()
          .single();

        if (createError) {
          console.error('User creation error:', createError);
          throw createError;
        }
        
        syncedUser = newUser;
        console.log('User created:', syncedUser.id);

        // Create wallet for new user
        await this.createUserWallet(syncedUser.id);
      }

      // Sync to profiles table if it exists
      await this.syncToProfiles(syncedUser);

      return syncedUser;
    } catch (error) {
      console.error('User sync error:', error);
      throw error;
    }
  }

  /**
   * Normalize user data from different sources
   */
  static normalizeUserData(userData, source) {
    const baseData = {
      id: userData.id || userData.uid,
      email: userData.email,
      role: userData.role || 'passenger'
    };

    if (source === 'firebase') {
      return {
        ...baseData,
        full_name: userData.displayName || userData.name || '',
        phone: userData.phoneNumber || userData.phone || '',
        photo_url: userData.photoURL || userData.avatar_url || '',
        firebase_uid: userData.uid,
        auth_provider: 'firebase',
        firebase_synced: true,
        supabase_synced: false
      };
    } else if (source === 'supabase') {
      return {
        ...baseData,
        full_name: userData.user_metadata?.full_name || userData.full_name || '',
        phone: userData.phone || userData.user_metadata?.phone || '',
        photo_url: userData.user_metadata?.avatar_url || userData.photo_url || '',
        supabase_uid: userData.id,
        auth_provider: 'supabase',
        firebase_synced: false,
        supabase_synced: true
      };
    }

    return baseData;
  }

  /**
   * Create wallet for new user
   */
  static async createUserWallet(userId) {
    try {
      const { error } = await supabase
        .from('wallets')
        .insert({
          user_id: userId,
          balance_available_inr: 0,
          balance_reserved_inr: 0,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        });

      if (error && error.code !== '23505') { // Ignore duplicate key error
        console.error('Wallet creation error:', error);
      } else {
        console.log('Wallet created for user:', userId);
      }
    } catch (error) {
      console.error('Wallet creation failed:', error);
    }
  }

  /**
   * Sync to profiles table for backward compatibility
   */
  static async syncToProfiles(user) {
    try {
      const { error } = await supabase
        .from('profiles')
        .upsert({
          user_id: user.id,
          full_name: user.full_name,
          phone: user.phone,
          email: user.email,
          avatar_url: user.photo_url,
          updated_at: new Date().toISOString()
        });

      if (error) {
        console.warn('Profile sync warning:', error.message);
      }
    } catch (error) {
      console.warn('Profile sync failed:', error);
    }
  }

  /**
   * Get unified user by ID or email
   */
  static async getUser(identifier) {
    try {
      const { data, error } = await supabase
        .from('users_app')
        .select('*')
        .or(`id.eq.${identifier},email.eq.${identifier}`)
        .maybeSingle(); // Use maybeSingle to avoid errors when not found

      if (error) {
        console.error('Get user error:', error);
        return null;
      }

      return data;
    } catch (error) {
      console.error('Get user error:', error);
      return null;
    }
  }

  /**
   * Authenticate user and return unified user data
   */
  static async authenticateUser(authData, source = 'firebase') {
    try {
      // Sync user first
      const syncedUser = await this.syncUser(authData, source);
      
      // Return clean user object for API responses
      return {
        id: syncedUser.id,
        email: syncedUser.email,
        full_name: syncedUser.full_name,
        phone: syncedUser.phone,
        role: syncedUser.role,
        is_verified: syncedUser.is_verified,
        is_active: syncedUser.is_active,
        photo_url: syncedUser.photo_url,
        auth_provider: syncedUser.auth_provider,
        created_at: syncedUser.created_at
      };
    } catch (error) {
      console.error('Authentication error:', error);
      throw error;
    }
  }
}

module.exports = UserSyncService;
