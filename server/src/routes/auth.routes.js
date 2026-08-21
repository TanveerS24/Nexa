const express = require('express');
const {
  register,
  login,
  sendOtp,
  verifyOtp,
  getMe,
  updateProfile,
} = require('../controllers/auth.controller');
const { requireAuth } = require('../middleware/auth.middleware');

const router = express.Router();

// Public routes
router.post('/register', register);
router.post('/login', login);
router.post('/send-otp', sendOtp);
router.post('/verify-otp', verifyOtp);

// Protected routes (Require Supabase JWT Bearer token)
router.get('/me', requireAuth, getMe);
router.put('/profile', requireAuth, updateProfile);

module.exports = router;
