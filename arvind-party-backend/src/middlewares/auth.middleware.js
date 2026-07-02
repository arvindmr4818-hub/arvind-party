// ═══════════════════════════════════════════════════════════════════════════
// FILE: src/middlewares/auth.middleware.js
// ARVIND PARTY — JWT Authentication Guard
// ═══════════════════════════════════════════════════════════════════════════

const jwt = require('jsonwebtoken');
const User = require('../models/User');

/**
 * Primary auth middleware — verifies JWT from Authorization header.
 * Exports both 'protect' and 'authMiddleware' for compatibility.
 */
const protect = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        code: 'NO_TOKEN',
        message: 'Authentication token is required.',
      });
    }

    const token = authHeader.split(' ')[1];
    let decoded;
    try {
      decoded = jwt.verify(token, process.env.JWT_SECRET);
    } catch (err) {
      if (err.name === 'TokenExpiredError') {
        return res.status(401).json({
          success: false,
          code: 'TOKEN_EXPIRED',
          message: 'Access token has expired. Please refresh.',
        });
      }
      return res.status(401).json({
        success: false,
        code: 'INVALID_TOKEN',
        message: 'Invalid or malformed token.',
      });
    }

    // Fetch user and attach to request
    const user = await User.findById(decoded.id).select('-password').lean();
    if (!user) {
      return res.status(401).json({ success: false, message: 'User not found.' });
    }
    if (user.isBanned) {
      return res.status(403).json({
        success: false,
        code: 'ACCOUNT_BANNED',
        message: `Account banned: ${user.banReason || 'Contact support'}`,
      });
    }

    req.user = user;
    next();
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

/**
 * Role-based access guard.
 * Usage: router.get('/route', protect, requireRole(['admin', 'owner']), handler)
 */
const requireRole = (roles) => (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({ success: false, message: 'Not authenticated.' });
  }
  const allowed = Array.isArray(roles) ? roles : [roles];
  if (!allowed.includes(req.user.role)) {
    return res.status(403).json({
      success: false,
      code: 'FORBIDDEN',
      message: `Access denied. Required: ${allowed.join(', ')}.`,
    });
  }
  next();
};

/**
 * Optional auth — attaches user if token provided, continues without if not.
 */
const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) return next();
    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.id).select('-password').lean();
    if (user) req.user = user;
  } catch (_) {}
  next();
};

// Export both names for backward compatibility
module.exports = { protect, authMiddleware: protect, requireRole, optionalAuth };
