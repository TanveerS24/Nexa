const { supabase } = require('../config/supabase');
const logger = require('../utils/logger');

/**
 * Middleware to verify Supabase JWT token in Authorization header
 */
const requireAuth = async (req, res, next) => {
  const reqId = req.id || 'N/A';
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      logger.warn(`[${reqId}] [AuthMiddleware] Access denied: Missing or invalid Authorization header format.`);
      return res.status(401).json({
        error: 'Unauthorized',
        message: 'Authentication token is required',
      });
    }

    const token = authHeader.split(' ')[1];
    if (!token || token.trim().length === 0) {
      logger.warn(`[${reqId}] [AuthMiddleware] Access denied: Empty Bearer token.`);
      return res.status(401).json({
        error: 'Unauthorized',
        message: 'Authentication token is required',
      });
    }

    if (!supabase) {
      logger.error(`[${reqId}] [AuthMiddleware] Supabase client not initialized. Cannot verify token.`);
      return res.status(500).json({
        error: 'Server Configuration Error',
        message: 'Authentication service not initialized',
      });
    }

    logger.debug(`[${reqId}] [AuthMiddleware] Verifying user token with Supabase...`);
    const { data, error } = await supabase.auth.getUser(token);

    if (error || !data.user) {
      logger.warn(`[${reqId}] [AuthMiddleware] Token verification failed: ${error ? error.message : 'No user found'}`);
      return res.status(401).json({
        error: 'Unauthorized',
        message: 'Invalid or expired session token',
      });
    }

    logger.info(`[${reqId}] [AuthMiddleware] Authenticated user: ${data.user.email} (ID: ${data.user.id})`);
    req.user = data.user;
    next();
  } catch (err) {
    logger.error(`[${reqId}] [AuthMiddleware] Unexpected exception:`, err);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to authenticate request',
    });
  }
};

module.exports = {
  requireAuth,
};
