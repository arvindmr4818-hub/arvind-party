// ═══════════════════════════════════════════════════════════════════════════
// ROUTE: Admin Login — /api/auth/admin-login
// ═══════════════════════════════════════════════════════════════════════════

const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User.model');
const Logger = require('../utils/logger');

// POST /api/auth/admin-login
router.post('/admin-login', async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ success: false, message: 'Username and password required' });
    }

    // Find admin/staff user
    const user = await User.findOne({
      $or: [{ username }, { email: username }, { phone: username }],
      role: { $in: ['owner', 'super_admin', 'admin', 'moderator', 'support', 'finance', 'content_manager'] },
    }).select('+password');

    if (!user) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    if (!user.isActive) {
      return res.status(403).json({ success: false, message: 'Account is deactivated. Contact owner.' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      Logger.warn(`Failed admin login attempt for: ${username}`);
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    // Generate JWT
    const token = jwt.sign(
      { id: user._id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    // Update last login
    user.lastLoginAt = new Date();
    await user.save();

    Logger.info(`Admin login: ${user.name} (${user.role})`);

    res.json({
      success: true,
      message: 'Login successful',
      data: {
        token,
        user: {
          _id: user._id,
          name: user.name,
          email: user.email,
          role: user.role,
          avatar: user.avatar,
        },
      },
    });
  } catch (err) {
    Logger.error('Admin login error:', err);
    res.status(500).json({ success: false, message: 'Login failed. Try again.' });
  }
});

// POST /api/auth/logout
router.post('/logout', async (req, res) => {
  // JWT is stateless; client clears token
  res.json({ success: true, message: 'Logged out successfully' });
});

module.exports = router;
