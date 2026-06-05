// src/controllers/authController.js
const User = require('../models/User');
const generateToken = require('../utils/jwt');

// POST /api/auth/firebase-login
exports.loginWithFirebase = async (req, res) => {
  try {
    const { phone } = req.body;
    if (!phone) {
      return res.status(400).json({ success: false, message: 'Phone number is required' });
    }

    let user = await User.findOne({ phone });
    const isNewUser = !user;

    if (isNewUser) {
      const userId = 'AP' + Date.now().toString().slice(-8);
      user = await User.create({
        phone,
        userId,
        name: 'User_' + userId.slice(-4),
        level: 1,
        coins: 100,   // Welcome bonus
        diamonds: 0
      });
    }

    if (user.isBlocked) {
      return res.status(403).json({ success: false, message: 'Your account has been blocked. Contact support.' });
    }

    user.lastLoginAt = Date.now();
    user.isOnline    = true;
    await user.save();

    const token = generateToken(user._id);

    return res.json({
      success: true,
      isNewUser,
      token,
      user: {
        _id:      user._id,
        userId:   user.userId,
        name:     user.name,
        avatar:   user.avatar,
        level:    user.level,
        vipLevel: user.vipLevel,
        coins:    user.coins,
        diamonds: user.diamonds,
        followers: user.followers,
        following: user.following,
        bio:      user.bio,
        country:  user.country,
        gender:   user.gender,
      }
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
};

// POST /api/auth/guest-login
exports.guestLogin = async (req, res) => {
  try {
    const guestId = 'GUEST_' + Date.now().toString().slice(-6);
    const user = await User.create({
      phone: `guest_${Date.now()}`,
      userId: guestId,
      name: 'Guest_' + guestId.slice(-4),
      level: 1,
      coins: 50,
      diamonds: 0,
    });

    const token = generateToken(user._id);
    return res.json({ success: true, token, user, isGuest: true });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
};

// POST /api/auth/logout
exports.logout = async (req, res) => {
  try {
    await User.findByIdAndUpdate(req.user.id, { isOnline: false });
    return res.json({ success: true, message: 'Logged out' });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
};
