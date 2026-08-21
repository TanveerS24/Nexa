const authService = require('../services/auth/auth.service');
const logger = require('../utils/logger');

/**
 * Register a new user
 * POST /api/v1/auth/register
 */
const register = async (req, res, next) => {
  const reqId = req.id || 'N/A';
  try {
    const { email, password, displayName, dob, height, weight, sendOtp } = req.body;
    logger.info(`[${reqId}] [AuthController] Register requested for email: "${email}", displayName: "${displayName || ''}"`);

    if (!email || !password) {
      logger.warn(`[${reqId}] [AuthController] Registration validation failed: Email or password missing`);
      return res.status(400).json({
        error: 'BadRequest',
        message: 'Email and password are required for registration',
      });
    }

    if (password.length < 6) {
      logger.warn(`[${reqId}] [AuthController] Registration validation failed: Password length < 6`);
      return res.status(400).json({
        error: 'BadRequest',
        message: 'Password must be at least 6 characters long',
      });
    }

    const result = await authService.register({
      email,
      password,
      displayName,
      dob,
      height,
      weight,
      sendOtp: Boolean(sendOtp),
      reqId,
    });

    logger.info(`[${reqId}] [AuthController] Registration successful for user ID: ${result.user?.id || 'N/A'}`);
    res.status(201).json({
      success: true,
      ...result,
    });
  } catch (error) {
    logger.error(`[${reqId}] [AuthController] Registration error:`, error.message);
    res.status(error.status || 400).json({
      error: error.name || 'RegistrationError',
      message: error.message,
    });
  }
};

/**
 * Login an existing user
 * POST /api/v1/auth/login
 */
const login = async (req, res, next) => {
  const reqId = req.id || 'N/A';
  try {
    const { email, password } = req.body;
    logger.info(`[${reqId}] [AuthController] Login requested for email: "${email}"`);

    if (!email || !password) {
      logger.warn(`[${reqId}] [AuthController] Login validation failed: Email or password missing`);
      return res.status(400).json({
        error: 'BadRequest',
        message: 'Email and password are required for login',
      });
    }

    const result = await authService.login({ email, password, reqId });

    logger.info(`[${reqId}] [AuthController] Login successful for user ID: ${result.user?.id || 'N/A'}`);
    res.status(200).json({
      success: true,
      ...result,
    });
  } catch (error) {
    logger.error(`[${reqId}] [AuthController] Login error for "${req.body.email}":`, error.message);
    res.status(error.status || 401).json({
      error: error.name || 'AuthenticationError',
      message: error.message,
    });
  }
};

/**
 * Send OTP to email via EmailJS
 * POST /api/v1/auth/send-otp
 */
const sendOtp = async (req, res, next) => {
  const reqId = req.id || 'N/A';
  try {
    const { email, userName } = req.body;
    logger.info(`[${reqId}] [AuthController] Send OTP requested for email: "${email}"`);

    if (!email) {
      logger.warn(`[${reqId}] [AuthController] Send OTP validation failed: Email missing`);
      return res.status(400).json({
        error: 'BadRequest',
        message: 'Email is required to send OTP',
      });
    }

    const result = await authService.sendOtp({ email, userName, reqId });

    logger.info(`[${reqId}] [AuthController] OTP successfully processed for "${email}" (simulated: ${Boolean(result.simulated)})`);
    res.status(200).json({
      success: true,
      message: 'OTP sent successfully',
      ...result,
    });
  } catch (error) {
    logger.error(`[${reqId}] [AuthController] Send OTP error:`, error.message);
    next(error);
  }
};

/**
 * Verify an OTP code
 * POST /api/v1/auth/verify-otp
 */
const verifyOtp = async (req, res, next) => {
  const reqId = req.id || 'N/A';
  try {
    const { email, otp } = req.body;
    logger.info(`[${reqId}] [AuthController] Verify OTP requested for email: "${email}"`);

    if (!email || !otp) {
      logger.warn(`[${reqId}] [AuthController] Verify OTP validation failed: Email or OTP missing`);
      return res.status(400).json({
        error: 'BadRequest',
        message: 'Email and OTP code are required',
      });
    }

    const isValid = await authService.verifyOtp({ email, otp, reqId });

    if (!isValid) {
      logger.warn(`[${reqId}] [AuthController] Verify OTP failed: Invalid or expired code for "${email}"`);
      return res.status(400).json({
        success: false,
        error: 'InvalidOtp',
        message: 'Invalid or expired OTP code. Please request a new one.',
      });
    }

    logger.info(`[${reqId}] [AuthController] OTP successfully verified for "${email}"`);
    res.status(200).json({
      success: true,
      message: 'OTP verified successfully',
    });
  } catch (error) {
    logger.error(`[${reqId}] [AuthController] Verify OTP error:`, error.message);
    next(error);
  }
};

/**
 * Get current authenticated user profile
 * GET /api/v1/auth/me
 */
const getMe = async (req, res, next) => {
  const reqId = req.id || 'N/A';
  try {
    logger.info(`[${reqId}] [AuthController] Fetching profile for authenticated user ID: ${req.user.id}`);
    const profile = await authService.getProfileByUserId(req.user.id, reqId);

    res.status(200).json({
      success: true,
      user: req.user,
      profile,
    });
  } catch (error) {
    logger.error(`[${reqId}] [AuthController] GetMe error:`, error.message);
    next(error);
  }
};

/**
 * Update user profile
 * PUT /api/v1/auth/profile
 */
const updateProfile = async (req, res, next) => {
  const reqId = req.id || 'N/A';
  try {
    logger.info(`[${reqId}] [AuthController] Update profile requested for user ID: ${req.user.id}`);
    const profile = await authService.updateProfile(req.user.id, req.body, reqId);

    logger.info(`[${reqId}] [AuthController] Profile updated successfully for user ID: ${req.user.id}`);
    res.status(200).json({
      success: true,
      profile,
    });
  } catch (error) {
    logger.error(`[${reqId}] [AuthController] UpdateProfile error:`, error.message);
    next(error);
  }
};

module.exports = {
  register,
  login,
  sendOtp,
  verifyOtp,
  getMe,
  updateProfile,
};
