// ═══════════════════════════════════════════════════════════════════════════
// MODULE: auth/firebaseLoginRoute.js — Firebase Token Exchange
// Mobile app sends Firebase idToken, backend verifies and issues own JWT
// ═══════════════════════════════════════════════════════════════════════════

const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const admin = require('firebase-admin');
const User = require('../../models/User');

// POST /api/auth/firebase-login
router.post('/firebase-login', async (req, res) => {
  try {
    const { idToken, phone, email, name, avatar } = req.body;
    if (!idToken) return res.status(400).json({ success: false, message: 'idToken required' });

    // Verify Firebase token
    let decodedToken;
    try {
      decodedToken = await admin.auth().verifyIdToken(idToken);
    } catch (err) {
      return res.status(401).json({ success: false, message: 'Invalid Firebase token' });
    }

    const firebaseUid = decodedToken.uid;
    const userPhone = phone || decodedToken.phone_number;
    const userEmail = email || decodedToken.email;

    // Find or create user
    let user = await User.findOne({
      $or: [
        { firebaseUid },
        ...(userPhone ? [{ phone: userPhone }] : []),
        ...(userEmail ? [{ email: userEmail }] : []),
      ],
    });

    let isNewUser = false;

    if (!user) {
      isNewUser = true;
      const arvindId = 'AP' + Math.floor(1000000 + Math.random() * 9000000);
      user = await User.create({
        firebaseUid,
        phone: userPhone,
        email: userEmail,
        name: name || 'New User',
        avatar: avatar || '',
        role: 'user',
        coins: 500, // Welcome bonus
        diamonds: 0,
        vipLevel: 0,
        arvindId,
        isActive: true,
      });
    } else if (!user.firebaseUid) {
      user.firebaseUid = firebaseUid;
      await user.save();
    }

    if (user.isBanned) {
      return res.status(403).json({ success: false, message: `Account banned: ${user.banReason || 'Contact support'}` });
    }

    user.lastLoginAt = new Date();
    await user.save();

    // Generate backend JWT
    const token = jwt.sign(
      { id: user._id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '30d' }
    );

    res.json({
      success: true,
      data: {
        token,
        isNewUser,
        user: {
          _id: user._id,
          name: user.name,
          phone: user.phone,
          email: user.email,
          avatar: user.avatar,
          coins: user.coins,
          diamonds: user.diamonds,
          vipLevel: user.vipLevel,
          arvindId: user.arvindId,
          role: user.role,
        },
      },
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// GET /api/users/me — current user profile
router.get('/me', require('../../middlewares/auth.middleware').protect, async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('-password').lean();
    res.json({ success: true, data: user });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;
