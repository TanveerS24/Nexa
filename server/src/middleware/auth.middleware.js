const { supabase } = require('../config/supabase');
const logger = require('../utils/logger');

/**
 * Middleware to verify Supabase JWT token in Authorization header
 */
const requireAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        error: 'Unauthorized',
        message: 'Authentication token is required',
      });
    }

    const token = authHeader.split(' ')[1];

    if (!supabase) {
      logger.warn('Supabase client not initialized. Check SUPABASE_URL and SUPABASE_ANON_KEY.');
      return res.status(500).json({
        error: 'Server Configuration Error',
        message: 'Authentication service not initialized',
      });
    }

    const { data, error } = await supabase.auth.getUser(token);

    if (error || !data.user) {
      return res.status(401).json({
        error: 'Unauthorized',
        message: 'Invalid or expired session token',
      });
    }

    req.user = data.user;
    next();
  } catch (err) {
    logger.error('Authentication middleware error:', err.message);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to authenticate request',
    });
  }
};

module.exports = {
  requireAuth,
};
