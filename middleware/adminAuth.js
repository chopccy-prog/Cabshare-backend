const { supabase } = require('../supabase');

/**
 * Admin Authentication Middleware
 * Verifies that the authenticated user is an admin
 */
const adminAuth = async (req, res, next) => {
  try {
    const userId = req.user.id;

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required'
      });
    }

    // Check if user is in admins table
    const { data, error } = await supabase
      .from('admins')
      .select('user_id')
      .eq('user_id', userId)
      .single();

    if (error && error.code !== 'PGRST116') {
      console.error('Admin check error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }

    if (!data) {
      return res.status(403).json({
        success: false,
        message: 'Admin access required'
      });
    }

    // User is admin, proceed
    next();

  } catch (error) {
    console.error('Admin auth middleware error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

module.exports = adminAuth;
