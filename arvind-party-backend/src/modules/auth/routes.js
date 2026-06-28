// =========================================================================
// MODULE: AUTH ROUTES
// Merged from: auth.routes.js, authSecure.routes.js, firebaseAuth.routes.js, googleAuthRoutes.js, socialAuthRoutes.js
// =========================================================================


// ─── FROM: auth.routes.js ────────────────────────────────────────
const express = require('express');
const router = express.Router();

const rateLimit = require('express-rate-limit');
const authController = require('../../controllers/auth.controller');
const { validatePhone, validateOTP } = require('../../middlewares/validation.middleware');
const authMiddleware = require('../../middlewares/auth.middleware');

// ─────────────────────────────────────────────────────────────────────────
// RATE LIMITER — 10 attempts per 15 min (dev-friendly)
// ─────────────────────────────────────────────────────────────────────────
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: process.env.NODE_ENV === 'development' ? 100 : 10,
  message: {
    success: false,
    message: 'Too many authentication attempts. Please try again after 15 minutes.'
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// ─────────────────────────────────────────────────────────────────────────
// PUBLIC ROUTES
// ─────────────────────────────────────────────────────────────────────────

/**
 * POST /api/auth/send-otp
 * Body: { phone: "9876543210" }
 * Sends a 6-digit OTP via SMS (or logs it in dev mode).
 */
router.post('/send-otp', authLimiter, validatePhone(), authController.sendOtp);

/**
 * POST /api/auth/otp-verify
 * Body: { phone: "9876543210", otp: "123456" }
 * Verifies OTP → auto-creates user if new → returns JWT + refreshToken.
 * This is the SINGLE entry point for both new and returning users.
 */
router.post('/otp-verify', authLimiter, validatePhone(), validateOTP(), authController.verifyOtp);

/**
 * POST /api/auth/resend-otp
 * Body: { phone: "9876543210" }
 * Resends a fresh OTP (resets the 5-minute TTL).
 */
router.post('/resend-otp', authLimiter, validatePhone(), authController.resendOtp);

/**
 * POST /api/auth/register
 * Body: { phone, name, gender?, dob? }
 * Completes profile after OTP verify when isProfileComplete is false.
 */
router.post('/register', authLimiter, validatePhone(), authController.register);

/**
 * POST /api/auth/refresh-token
 * Body: { refreshToken: "..." }
 * Issues a new access token without re-login.
 */
router.post('/refresh-token', authController.refreshToken);

// ─────────────────────────────────────────────────────────────────────────
// PROTECTED ROUTES
// ─────────────────────────────────────────────────────────────────────────

/**
 * POST /api/auth/logout
 * Header: Authorization: Bearer <token>
 */
router.post('/logout', authMiddleware, authController.logout);

/**
 * GET /api/auth/me
 * Header: Authorization: Bearer <token>
 * Returns current authenticated user's profile.
 */
router.get('/me', authMiddleware, async (req, res) => {
  try {
    const User = require('../../models/User');
    const user = await User.findById(req.user.userId).lean();

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    res.status(200).json({
      success: true,
      data: {
        _id: user._id,
        phone: user.phone,
        name: user.name,
        avatar: user.avatar,
        arvindId: user.arvindId,
        level: user.level,
        xp: user.xp,
        coins: user.coins,
        diamonds: user.diamonds,
        isProfileComplete: user.isProfileComplete,
        gender: user.gender,
        dob: user.dob,
        createdAt: user.createdAt,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch user' });
  }
});


// ─── FROM: authSecure.routes.js ────────────────────────────────────────
const rateLimit = require('express-rate-limit');
const controller = require('../../controllers/authSecure.controller');
const { refreshTokenMiddleware } = require('../../middlewares/refreshToken.middleware');
const authMiddleware = require('../../middlewares/auth.middleware');

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: process.env.NODE_ENV === 'development' ? 100 : 10,
  message: { success: false, message: 'Too many authentication attempts. Please try again after 15 minutes.' },
  standardHeaders: true,
  legacyHeaders: false,
});

// Firebase login
router.post('/firebase-login', authLimiter, controller.firebaseLogin);

// Refresh token (uses custom refresh middleware, not standard JWT)
router.post('/refresh-token', refreshTokenMiddleware, controller.refreshToken);

// Secure logout — blacklists access token + revokes refresh token
router.post('/logout', authMiddleware, controller.logout);

// Revoke all active sessions for current user
router.post('/revoke-all-sessions', authMiddleware, controller.revokeAllSessions);

// Admin: revoke all sessions for any user
router.post('/admin/revoke-user-sessions', authMiddleware, controller.adminRevokeUserSessions);


// ─── FROM: firebaseAuth.routes.js ────────────────────────────────────────

const rateLimit = require('express-rate-limit');
const firebaseAuthController = require('../../controllers/firebaseAuth.controller');
const authMiddleware = require('../../middlewares/auth.middleware');

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: process.env.NODE_ENV === 'development' ? 100 : 10,
  message: {
    success: false,
    message: 'Too many authentication attempts. Please try again after 15 minutes.',
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// PUBLIC ROUTES - Firebase ID Token Verification

router.post('/firebase-verify', authLimiter, (req, res, next) => {
  try {
    const { idToken, deviceId, deviceInfo, platform } = req.body;

    if (!idToken || typeof idToken !== 'string' || idToken.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Firebase ID token is required',
        code: 'MISSING_TOKEN',
      });
    }

    if (!platform || !['android', 'ios', 'web', 'windows'].includes(platform.toLowerCase())) {
      return res.status(400).json({
        success: false,
        message: 'Valid platform is required (android, ios, web, windows)',
        code: 'INVALID_PLATFORM',
      });
    }

    next();
  } catch (error) {
    next(error);
  }
}, firebaseAuthController.verifyFirebaseToken);

router.post('/apple-verify', authLimiter, (req, res, next) => {
  try {
    const { identityToken, deviceId, deviceInfo, platform } = req.body;

    if (!identityToken || typeof identityToken !== 'string' || identityToken.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Apple identity token is required',
        code: 'MISSING_TOKEN',
      });
    }

    if (!platform || !['ios', 'macos', 'windows'].includes(platform.toLowerCase())) {
      return res.status(400).json({
        success: false,
        message: 'Valid platform is required (ios, macos, windows)',
        code: 'INVALID_PLATFORM',
      });
    }

    next();
  } catch (error) {
    next(error);
  }
}, firebaseAuthController.verifyAppleToken);

// PROTECTED ROUTES - Link Firebase with existing account

router.post('/firebase-link', authMiddleware, (req, res, next) => {
  try {
    const { idToken } = req.body;

    if (!idToken || typeof idToken !== 'string' || idToken.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Firebase ID token is required for linking',
        code: 'MISSING_TOKEN',
      });
    }

    if (!req.user || !req.user.userId) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required',
        code: 'NOT_AUTHENTICATED',
      });
    }

    next();
  } catch (error) {
    next(error);
  }
}, firebaseAuthController.linkFirebaseAccount);


// ─── FROM: googleAuthRoutes.js ────────────────────────────────────────
// ROUTES: Google Auth — Google OAuth + Apple Sign-in

const googleAuthController = require('../../controllers/googleAuthController');

// POST /api/auth/google — Google OAuth login
router.post('/google', googleAuthController.googleLogin);

// POST /api/auth/apple — Apple Sign-in
router.post('/apple', googleAuthController.appleLogin);


// ─── FROM: socialAuthRoutes.js ────────────────────────────────────────
// Providers: Google, Apple, Facebook, Snapchat, Instagram, Guest

const rateLimit = require('express-rate-limit');
const authMiddleware = require('../../middlewares/auth.middleware');
const securityController = require('../../controllers/authSecure.controller');

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: process.env.NODE_ENV === 'development' ? 100 : 10,
  message: { success: false, message: 'Too many authentication attempts. Please try again after 15 minutes.' },
  standardHeaders: true,
  legacyHeaders: false,
});

// SOCIAL LOGIN

router.post('/login', authLimiter, securityController.socialLogin);
router.post('/guest-login', authLimiter, securityController.guestLogin);

// LINK / UNLINK SOCIAL ACCOUNTS

router.post('/link', authMiddleware, securityController.linkSocialAccount);
router.post('/unlink', authMiddleware, securityController.unlinkSocialAccount);


module.exports = router;
