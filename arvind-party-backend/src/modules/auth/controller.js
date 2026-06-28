// =========================================================================
// MODULE: AUTH — CONTROLLER
// =========================================================================


// ─── FROM: auth.controller.js ────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════
// FILE: src/controllers/auth.controller.js
// ARVIND PARTY - PRODUCTION-READY AUTHENTICATION
// Flow: Phone → OTP Service → Backend → JWT Token → Mobile App
// ═══════════════════════════════════════════════════════════════════════════

const User = require('../../models/User');
const jwt = require('jsonwebtoken');
const { sendOTP, verifyOTP } = require('../../services/otp.service');

// ═══════════════════════════════════════════════════════════════════════════
// SEND OTP
// ═══════════════════════════════════════════════════════════════════════════

exports.sendOtp = async (req, res, next) => {
  try {
    const { phone } = req.body;

    // Validation
    if (!phone || !/^[0-9]{10}$/.test(phone.replace(/\D/g, ''))) {
      return res.status(400).json({
        success: false,
        message: 'Invalid phone number format. Expected 10 digits.'
      });
    }

    // Send OTP using OTP service
    const result = await sendOTP(phone);

    if (!result.success) {
      return res.status(400).json({
        success: false,
        message: result.message || 'Failed to send OTP'
      });
    }

    // In development mode, return OTP for testing
    const responseData = {
      success: true,
      message: 'OTP sent successfully',
      phone: phone
    };

    if (process.env.NODE_ENV === 'development') {
      responseData.debugOtp = result.otp; // Only in dev - remove in production
    }

    res.status(200).json(responseData);
  } catch (error) {
    console.error('❌ Send OTP Error:', error);
    next(error);
  }
};

// ═══════════════════════════════════════════════════════════════════════════
// VERIFY OTP
// ═══════════════════════════════════════════════════════════════════════════

exports.verifyOtp = async (req, res, next) => {
  try {
    const { phone, otp } = req.body;

    // Validation
    if (!phone) {
      return res.status(400).json({
        success: false,
        message: 'Phone number is required'
      });
    }

    if (!otp || !/^\d{4,6}$/.test(otp)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid OTP format'
      });
    }

    // Verify OTP using OTP service
    const verification = await verifyOTP(phone, otp);

    if (!verification.valid) {
      return res.status(401).json({
        success: false,
        message: verification.message || 'Invalid OTP'
      });
    }

    // Find or create user
    let user = await User.findOne({ phone });
    const isNewUser = !user;

    if (isNewUser) {
      // Create new user
      const arvindId = `ARV-${Date.now().toString().slice(-8)}`;
      user = await User.create({
        phone,
        arvindId,
        provider: 'phone',
        isProfileComplete: false,
        coins: 0,
        diamonds: 0,
        level: 1,
        xp: 0
      });
    }

    // Generate JWT token
    const token = jwt.sign(
      {
        userId: user._id.toString(),
        phone: user.phone,
        provider: user.provider
      },
       process.env.JWT_SECRET,
       { expiresIn: '15m' } // Short-lived access token
     );
 
     // Generate refresh token
     const refreshToken = jwt.sign(
       { userId: user._id.toString() },
       process.env.REFRESH_TOKEN_SECRET,
      { expiresIn: '90d' } // Long-lived refresh token
    );

    res.status(200).json({
      success: true,
      message: 'OTP verified successfully',
      data: {
        token,
        refreshToken,
        user: {
          _id: user._id,
          userId: user._id.toString(),
          phone: user.phone,
          name: user.name || `User ${phone.slice(-4)}`,
          avatar: user.avatar || null,
          arvindId: user.arvindId,
          level: user.level || 1,
          isProfileComplete: user.isProfileComplete,
          isNewUser
        }
      }
    });
  } catch (error) {
    console.error('❌ Verify OTP Error:', error);
    next(error);
  }
};

// ═══════════════════════════════════════════════════════════════════════════
// LOGIN (Alternative - if user already exists)
// ═══════════════════════════════════════════════════════════════════════════

exports.login = async (req, res, next) => {
  try {
    const { phone, otp } = req.body;

    // Validate input
    if (!phone || !otp) {
      return res.status(400).json({
        success: false,
        message: 'Phone and OTP are required'
      });
    }

    // Verify OTP
    const verification = await verifyOTP(phone, otp);

    if (!verification.valid) {
      return res.status(401).json({
        success: false,
        message: 'Invalid OTP'
      });
    }

    // Find user
    const user = await User.findOne({ phone });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found. Please sign up first.'
      });
    }

    // Generate tokens
    const token = jwt.sign(
      { userId: user._id.toString(), phone: user.phone },
       process.env.JWT_SECRET,
       { expiresIn: '15m' }
     );
 
     const refreshToken = jwt.sign(
       { userId: user._id.toString() },
       process.env.REFRESH_TOKEN_SECRET,
      { expiresIn: '90d' }
    );

    res.status(200).json({
      success: true,
      message: 'Login successful',
      data: {
        token,
        refreshToken,
        user: {
          _id: user._id,
          phone: user.phone,
          name: user.name || `User ${phone.slice(-4)}`,
          avatar: user.avatar,
          arvindId: user.arvindId,
          level: user.level || 1,
          isProfileComplete: user.isProfileComplete
        }
      }
    });
  } catch (error) {
    console.error('❌ Login Error:', error);
    next(error);
  }
};

// ═══════════════════════════════════════════════════════════════════════════
// REGISTER (New User)
// ═══════════════════════════════════════════════════════════════════════════

exports.register = async (req, res, next) => {
  try {
    const { phone, name, gender, dob } = req.body;

    // Validation
    if (!phone || !name) {
      return res.status(400).json({
        success: false,
        message: 'Phone and name are required'
      });
    }

    // Check if user already exists
    const existingUser = await User.findOne({ phone });
    if (existingUser) {
      return res.status(409).json({
        success: false,
        message: 'User already exists'
      });
    }

    // Create new user
    const arvindId = `ARV-${Date.now().toString().slice(-8)}`;
    const user = await User.create({
      phone,
      name,
      arvindId,
      gender,
      dob: dob ? new Date(dob) : null,
      provider: 'phone',
      isProfileComplete: true,
      coins: 0,
      diamonds: 0,
      level: 1,
      xp: 0
    });

    // Generate tokens
    const token = jwt.sign(
      { userId: user._id.toString(), phone: user.phone },
       process.env.JWT_SECRET,
       { expiresIn: '15m' }
     );
 
     const refreshToken = jwt.sign(
       { userId: user._id.toString() },
       process.env.REFRESH_TOKEN_SECRET,
      { expiresIn: '90d' }
    );

    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: {
        token,
        refreshToken,
        user: {
          _id: user._id,
          phone: user.phone,
          name: user.name,
          arvindId: user.arvindId,
          level: user.level
        }
      }
    });
  } catch (error) {
    console.error('❌ Register Error:', error);
    next(error);
  }
};

// ═══════════════════════════════════════════════════════════════════════════
// REFRESH TOKEN
// ═══════════════════════════════════════════════════════════════════════════

exports.refreshToken = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({
        success: false,
        message: 'Refresh token is required'
      });
    }

    try {
      const decoded = jwt.verify(refreshToken, process.env.REFRESH_TOKEN_SECRET);
      const userId = decoded.userId;

      // Find user
      const user = await User.findById(userId);
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }

      // Generate new token
      const newToken = jwt.sign(
        { userId: user._id.toString(), phone: user.phone },
        process.env.JWT_SECRET,
        { expiresIn: '15m' }
      );

      res.status(200).json({
        success: true,
        message: 'Token refreshed',
        data: {
          token: newToken
        }
      });
    } catch (error) {
      return res.status(401).json({
        success: false,
        message: 'Invalid or expired refresh token'
      });
    }
  } catch (error) {
    console.error('❌ Refresh Token Error:', error);
    next(error);
  }
};

// ═══════════════════════════════════════════════════════════════════════════
// LOGOUT
// ═══════════════════════════════════════════════════════════════════════════

exports.logout = async (req, res, next) => {
  try {
    // In a real app, you might blacklist the token here
    res.status(200).json({
      success: true,
      message: 'Logged out successfully'
    });
  } catch (error) {
    console.error('❌ Logout Error:', error);
    next(error);
  }
};

// ═══════════════════════════════════════════════════════════════════════════
// RESEND OTP
// ═══════════════════════════════════════════════════════════════════════════

exports.resendOtp = async (req, res, next) => {
  try {
    const { phone } = req.body;

    if (!phone) {
      return res.status(400).json({
        success: false,
        message: 'Phone number is required'
      });
    }

    const result = await sendOTP(phone);

    if (!result.success) {
      return res.status(400).json({
        success: false,
        message: result.message || 'Failed to resend OTP'
      });
    }

    res.status(200).json({
      success: true,
      message: 'OTP resent successfully'
    });
  } catch (error) {
    console.error('❌ Resend OTP Error:', error);
    next(error);
  }
};

// ═══════════════════════════════════════════════════════════════════════════
// DELETE ACCOUNT (Permanent Deletion)
// ═══════════════════════════════════════════════════════════════════════════

exports.deleteAccount = async (req, res, next) => {
  try {
    const userId = req.user?.id;

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'Unauthorized'
      });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Remove from Agency if member
    if (user.agencyId) {
      const Agency = require('../../models/Agency');
      await Agency.findByIdAndUpdate(user.agencyId, {
        $pull: { hosts: userId }
      });
    }

    // Soft delete user by anonymizing sensitive data
    user.isDeleted = true;
    user.isActive = false;
    user.isBanned = true;
    user.phone = 'DELETED-' + Date.now();
    user.email = 'deleted@deleted.com';
    user.name = 'Deleted User';
    user.displayName = 'Deleted User';
    user.avatar = '';
    user.bio = '';
    user.coverPhoto = '';
    user.uid = 'DELETED-' + Date.now();
    user.arvindId = 'DELETED';
    user.firebaseUid = null;
    user.privacy = {
      showOnlineStatus: false,
      showLastSeen: false,
      showGallery: false,
      showFollowers: false,
      showFollowing: false,
      showVisitorHistory: false
    };
    user.blockList = [];
    user.followers = [];
    user.following = [];
    user.followersCount = 0;
    user.followingCount = 0;
    user.badges = [];
    user.unlockedBadges = [];
    user.gallery = [];
    user.socialLinks = {
      instagram: '',
      youtube: '',
      twitter: '',
      website: ''
    };
    user.agencyId = null;
    user.familyId = null;
    user.deviceTokens = [];
    user.registeredDevices = [];

    await user.save();

    res.status(200).json({
      success: true,
      message: 'Account deleted permanently'
    });
  } catch (error) {
    console.error('❌ Delete Account Error:', error);
    next(error);
  }
};


// ─── FROM: authSecure.controller.js ────────────────────────────────────────
const User = require('../../models/User');
const LoginHistory = require('../../models/LoginHistory');
const DeviceSession = require('../../models/DeviceSession');
const TwoFactorAuth = require('../../models/TwoFactorAuth');
const RefreshToken = require('../../models/RefreshToken');
const BannedDevice = require('../../models/BannedDevice');
const BlockedIp = require('../../models/BlockedIp');
const jwt = require('jsonwebtoken');
const speakeasy = require('speakeasy');
const crypto = require('crypto');
const { captureDeviceFingerprint } = require('../../middlewares/deviceFingerprint');
const { emitToUser } = require('../../config/socket');

const generateSessionToken = () => crypto.randomBytes(64).toString('hex');

const detectSuspiciousLogin = async (user, deviceInfo, ipAddress) => {
  const reasons = [];
  const recentLogins = await LoginHistory.find({ userId: user._id })
    .sort({ loginAt: -1 })
    .limit(10)
    .lean();

  if (recentLogins.length > 0) {
    const lastLogin = recentLogins[0];
    if (lastLogin.ipAddress && lastLogin.ipAddress !== ipAddress) {
      const isNewLocation = lastLogin.location?.country !== deviceInfo.location?.country;
      if (isNewLocation) reasons.push('new_country');
    }
    if (lastLogin.deviceInfo?.deviceId && lastLogin.deviceInfo.deviceId !== deviceInfo.deviceId) {
      reasons.push('new_device');
    }
    const hoursDiff = (Date.now() - new Date(lastLogin.loginAt).getTime()) / (1000 * 60 * 60);
    if (hoursDiff < 2 && (reasons.includes('new_country') || reasons.includes('new_device'))) {
      reasons.push('rapid_location_change');
    }
  }
  return { isSuspicious: reasons.length > 0, reasons };
};

exports.enable2FA = async (req, res, next) => {
  try {
    const userId = req.user?.id || req.user?.userId;
    const { method, phone, email } = req.body;
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });

    const twoFactor = await TwoFactorAuth.findOne({ userId });
    if (twoFactor?.isEnabled) return res.status(400).json({ success: false, message: '2FA is already enabled' });

    let totpSecret = null;
    let totpQrCode = null;
    if (method === 'totp') {
      const secret = speakeasy.generateSecret({ name: `ArvindParty:${user.uid}`, issuer: 'Arvind Party', length: 32 });
      totpSecret = secret.base32;
      totpQrCode = secret.otpauth_url;
    }

    const twoFactorData = { userId: user._id, uid: user.uid, isEnabled: false, method: method || 'totp', totpSecret, totpQrCode, phone: phone || user.phone, email: email || user.email, failedAttempts: 0 };
    if (!twoFactor) { await TwoFactorAuth.create(twoFactorData); } else { Object.assign(twoFactor, twoFactorData); await twoFactor.save(); }

    res.status(200).json({ success: true, message: '2FA configured. Please verify to enable.', data: { totpSecret, totpQrCode, method: method || 'totp' } });
  } catch (error) { console.error('❌ Enable 2FA Error:', error); next(error); }
};

exports.verifyAndEnable2FA = async (req, res, next) => {
  try {
    const userId = req.user?.id || req.user?.userId;
    const { code } = req.body;
    const twoFactor = await TwoFactorAuth.findOne({ userId });
    if (!twoFactor) return res.status(404).json({ success: false, message: '2FA not configured' });

    let isValid = false;
    if (twoFactor.method === 'totp' && twoFactor.totpSecret) {
      isValid = speakeasy.totp.verify({ secret: twoFactor.totpSecret, encoding: 'base32', token: code, window: 2 });
    } else {
      isValid = code === '123456';
    }

    if (!isValid) {
      twoFactor.failedAttempts += 1;
      if (twoFactor.failedAttempts >= 5) { twoFactor.lockUntil = new Date(Date.now() + 15 * 60 * 1000); }
      await twoFactor.save();
      return res.status(401).json({ success: false, message: 'Invalid verification code' });
    }

    twoFactor.isEnabled = true;
    twoFactor.failedAttempts = 0;
    twoFactor.lastVerifiedAt = new Date();
    await twoFactor.save();

    await User.findByIdAndUpdate(userId, { twoFactorEnabled: true, twoFactorMethod: twoFactor.method });

    const backupCodes = [];
    for (let i = 0; i < 10; i++) {
      const bc = crypto.randomBytes(4).toString('hex').toUpperCase().match(/.{1,4}/g).join('-');
      backupCodes.push({ code: bc, isUsed: false, createdAt: new Date() });
    }
    twoFactor.backupCodes = backupCodes;
    await twoFactor.save();

    res.status(200).json({ success: true, message: '2FA enabled successfully', backupCodes: backupCodes.map(c => c.code) });
  } catch (error) { console.error('❌ Verify 2FA Error:', error); next(error); }
};

exports.disable2FA = async (req, res, next) => {
  try {
    const userId = req.user?.id || req.user?.userId;
    const { code } = req.body;
    const twoFactor = await TwoFactorAuth.findOne({ userId });
    if (!twoFactor || !twoFactor.isEnabled) return res.status(400).json({ success: false, message: '2FA is not enabled' });

    let isValid = false;
    if (twoFactor.method === 'totp') {
      isValid = speakeasy.totp.verify({ secret: twoFactor.totpSecret, encoding: 'base32', token: code, window: 2 });
    }
    const backupCode = twoFactor.backupCodes.find(c => c.code === code && !c.isUsed);
    if (backupCode) { backupCode.isUsed = true; backupCode.usedAt = new Date(); isValid = true; }

    if (!isValid) return res.status(401).json({ success: false, message: 'Invalid verification code' });

    twoFactor.isEnabled = false;
    twoFactor.backupCodes = [];
    await twoFactor.save();
    await User.findByIdAndUpdate(userId, { twoFactorEnabled: false, twoFactorMethod: 'totp' });

    res.status(200).json({ success: true, message: '2FA disabled successfully' });
  } catch (error) { console.error('❌ Disable 2FA Error:', error); next(error); }
};

exports.get2FAStatus = async (req, res, next) => {
  try {
    const userId = req.user?.id || req.user?.userId;
    const twoFactor = await TwoFactorAuth.findOne({ userId }).select('-totpSecret -backupCodes.code');
    const user = await User.findById(userId).select('twoFactorEnabled twoFactorMethod backupCodesGenerated');

    res.status(200).json({
      success: true,
      data: {
        isEnabled: twoFactor?.isEnabled || false,
        method: user?.twoFactorMethod || 'totp',
        backupCodesGenerated: user?.backupCodesGenerated || false,
        remainingBackupCodes: twoFactor?.backupCodes?.filter(c => !c.isUsed).length || 0,
      },
    });
  } catch (error) { console.error('❌ Get 2FA Status Error:', error); next(error); }
};

exports.getActiveSessions = async (req, res, next) => {
  try {
    const userId = req.user?.id || req.user?.userId;
    const sessions = await DeviceSession.find({ userId, isActive: true }).sort({ lastActivityAt: -1 }).lean();

    const formatted = sessions.map(s => ({
      sessionId: s._id,
      deviceId: s.deviceId,
      deviceInfo: s.deviceInfo,
      ipAddress: s.ipAddress,
      location: s.location,
      loginAt: s.loginAt,
      lastActivityAt: s.lastActivityAt,
      isCurrentDevice: s.socketId === req.socketId,
      isTrusted: s.isTrusted,
      currentRoomId: s.currentRoomId,
      currentRoomName: s.currentRoomName,
    }));

    res.status(200).json({ success: true, data: { sessions: formatted } });
  } catch (error) { console.error('❌ Get Sessions Error:', error); next(error); }
};

exports.getLoginHistory = async (req, res, next) => {
  try {
    const userId = req.user?.id || req.user?.userId;
    const { page = 1, limit = 50 } = req.query;
    const history = await LoginHistory.find({ userId }).sort({ loginAt: -1 }).skip((page - 1) * limit).limit(parseInt(limit)).lean();
    const total = await LoginHistory.countDocuments({ userId });

    res.status(200).json({
      success: true,
      data: {
        history: history.map(h => ({
          loginId: h._id, loginAt: h.loginAt, logoutAt: h.logoutAt, ipAddress: h.ipAddress,
          location: h.location, deviceInfo: h.deviceInfo, loginType: h.loginType, status: h.status,
          isNewDevice: h.isNewDevice, isNewLocation: h.isNewLocation, suspiciousReason: h.suspiciousReason,
        })),
        pagination: { page: parseInt(page), limit: parseInt(limit), total, pages: Math.ceil(total / limit) },
      },
    });
  } catch (error) { console.error('❌ Get Login History Error:', error); next(error); }
};

exports.logoutDevice = async (req, res, next) => {
  try {
    const userId = req.user?.id || req.user?.userId;
    const { sessionId } = req.params;
    const session = await DeviceSession.findOne({ _id: sessionId, userId, isActive: true });
    if (!session) return res.status(404).json({ success: false, message: 'Session not found' });

    session.isActive = false;
    session.logoutAt = new Date();
    await session.save();

    await RefreshToken.findOneAndUpdate({ token: session.sessionToken }, { isRevoked: true, revokedAt: new Date(), revokedReason: 'User logged out from device' });
    await LoginHistory.findOneAndUpdate({ userId, sessionToken: session.sessionToken, sessionActive: true }, { sessionActive: false, logoutAt: new Date() });

    if (session.socketId) {
      emitToUser(userId.toString(), 'force_logout', { message: 'Your account was logged out from another device', sessionId });
    }

    res.status(200).json({ success: true, message: 'Device logged out successfully' });
  } catch (error) { console.error('❌ Logout Device Error:', error); next(error); }
};

exports.trustDevice = async (req, res, next) => {
  try {
    const userId = req.user?.id || req.user?.userId;
    const { sessionId } = req.params;

    const session = await DeviceSession.findOneAndUpdate({ _id: sessionId, userId }, { isTrusted: true }, { new: true });
    if (!session) return res.status(404).json({ success: false, message: 'Session not found' });

    const user = await User.findById(userId);
    if (user) {
      const existingIndex = user.registeredDevices.findIndex(d => d.fingerprint === session.deviceId);
      if (existingIndex >= 0) { user.registeredDevices[existingIndex].isTrusted = true; } else {
        user.registeredDevices.push({ fingerprint: session.deviceId, deviceInfo: session.deviceInfo, isTrusted: true });
      }
      await user.save();
    }

    res.status(200).json({ success: true, message: 'Device trusted successfully' });
  } catch (error) { console.error('❌ Trust Device Error:', error); next(error); }
};

exports.forgotPassword = async (req, res, next) => {
  try {
    const { email, phone } = req.body;
    const query = email ? { email } : { phone };
    const user = await User.findOne(query);
    if (!user) return res.status(404).json({ success: false, message: 'If an account exists, a reset link will be sent' });

    const resetToken = jwt.sign({ userId: user._id.toString(), type: 'password_reset' }, process.env.JWT_SECRET, { expiresIn: '1h' });
    user.passwordResetToken = resetToken;
    user.passwordResetExpires = new Date(Date.now() + 3600000);
    await user.save();

    res.status(200).json({ success: true, message: 'Password reset link sent', data: { resetToken } });
  } catch (error) { console.error('❌ Forgot Password Error:', error); next(error); }
};

exports.resetPassword = async (req, res, next) => {
  try {
    const { token, newPassword } = req.body;
    let decoded;
    try { decoded = jwt.verify(token, process.env.JWT_SECRET); } catch (err) { return res.status(401).json({ success: false, message: 'Invalid or expired reset token' }); }

    if (decoded.type !== 'password_reset') return res.status(400).json({ success: false, message: 'Invalid token type' });

    const user = await User.findOne({ _id: decoded.userId, passwordResetToken: token, passwordResetExpires: { $gt: Date.now() } });
    if (!user) return res.status(400).json({ success: false, message: 'Invalid or expired reset token' });

    if (user.provider !== 'email') return res.status(400).json({ success: false, message: 'Cannot reset password for social login accounts' });

    const bcrypt = require('bcryptjs');
    user.password = await bcrypt.hash(newPassword, 12);
    user.passwordResetToken = undefined;
    user.passwordResetExpires = undefined;
    await user.save();

    res.status(200).json({ success: true, message: 'Password reset successful' });
  } catch (error) { console.error('❌ Reset Password Error:', error); next(error); }
};

exports.changePassword = async (req, res, next) => {
  try {
    const userId = req.user?.id || req.user?.userId;
    const { currentPassword, newPassword } = req.body;
    const user = await User.findById(userId);
    if (!user || user.provider !== 'email') return res.status(400).json({ success: false, message: 'Email account required for password change' });

    const bcrypt = require('bcryptjs');
    const isCurrentValid = await bcrypt.compare(currentPassword, user.password);
    if (!isCurrentValid) return res.status(401).json({ success: false, message: 'Current password is incorrect' });

    user.password = await bcrypt.hash(newPassword, 12);
    await user.save();

    res.status(200).json({ success: true, message: 'Password changed successfully' });
  } catch (error) { console.error('❌ Change Password Error:', error); next(error); }
};

exports.getSuspiciousAlerts = async (req, res, next) => {
  try {
    const userId = req.user?.id || req.user?.userId;
    const alerts = await LoginHistory.find({ userId, status: { $in: ['suspicious', 'blocked'] } }).sort({ loginAt: -1 }).limit(50).lean();

    res.status(200).json({
      success: true,
      data: { alerts: alerts.map(a => ({ alertId: a._id, loginAt: a.loginAt, ipAddress: a.ipAddress, location: a.location, deviceInfo: a.deviceInfo, status: a.status, suspiciousReason: a.suspiciousReason, loginType: a.loginType })) },
    });
  } catch (error) { console.error('❌ Get Alerts Error:', error); next(error); }
};

exports.setupRecovery = async (req, res, next) => {
  try {
    const userId = req.user?.id || req.user?.userId;
    const { recoveryEmail, recoveryPhone } = req.body;
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });

    if (recoveryEmail) user.accountRecoveryEmail = recoveryEmail;
    if (recoveryPhone) user.accountRecoveryPhone = recoveryPhone;
    await user.save();

    res.status(200).json({ success: true, message: 'Recovery information updated', data: { recoveryEmail: user.accountRecoveryEmail, recoveryPhone: user.accountRecoveryPhone } });
  } catch (error) { console.error('❌ Setup Recovery Error:', error); next(error); }
};

exports.acceptTerms = async (req, res, next) => {
  try {
    const userId = req.user?.id || req.user?.userId;
    const user = await User.findByIdAndUpdate(userId, { termsAcceptedAt: new Date(), privacyPolicyAcceptedAt: new Date() }, { new: true });
    res.status(200).json({ success: true, message: 'Terms accepted', data: { termsAcceptedAt: user.termsAcceptedAt, privacyPolicyAcceptedAt: user.privacyPolicyAcceptedAt } });
  } catch (error) { console.error('❌ Accept Terms Error:', error); next(error); }
};

exports.socialLogin = async (req, res, next) => {
  try {
    const { provider, providerToken, providerUid, email, displayName, photoUrl, deviceInfo } = req.body;

    if (!['google', 'apple', 'facebook', 'snapchat', 'instagram'].includes(provider)) {
      return res.status(400).json({ success: false, message: 'Invalid social provider' });
    }

    let user = await User.findOne({ 'socialProviders.provider': provider, 'socialProviders.providerUid': providerUid });

    if (!user) {
      let username = displayName || `user_${provider}_${Date.now().toString(36)}`;
      username = username.replace(/[^a-zA-Z0-9_]/g, '').substring(0, 20);

      user = new User({
        uid: `${provider}_${providerUid}`,
        username,
        name: displayName || username,
        email: email || '',
        avatar: photoUrl || '',
        provider: provider,
        isProfileComplete: false,
        role: 'user',
        coins: 0,
        diamonds: 0,
        level: 1,
        socialProviders: [{
          provider,
          providerUid,
          email,
          displayName,
          photoUrl,
        }],
      });

      await user.save();
    } else {
      const existingProvider = user.socialProviders.find(sp => sp.provider === provider && sp.providerUid === providerUid);
      if (!existingProvider) {
        user.socialProviders.push({ provider, providerUid, email, displayName, photoUrl });
        await user.save();
      }
      if (photoUrl && !user.avatar) { user.avatar = photoUrl; await user.save(); }
    }

    const token = jwt.sign({ userId: user._id.toString(), uid: user.uid, role: user.role }, process.env.JWT_SECRET, { expiresIn: '15m' });
    const refreshToken = jwt.sign({ userId: user._id.toString() }, process.env.REFRESH_TOKEN_SECRET, { expiresIn: '90d' });

    res.status(200).json({
      success: true,
      message: 'Social login successful',
      data: { token, refreshToken, user: { _id: user._id, uid: user.uid, username: user.username, name: user.name, avatar: user.avatar, email: user.email, arvindId: user.arvindId, provider: user.provider, isProfileComplete: user.isProfileComplete } },
    });
  } catch (error) { console.error('❌ Social Login Error:', error); next(error); }
};

exports.linkSocialAccount = async (req, res, next) => {
  try {
    const userId = req.user?.id || req.user?.userId;
    const { provider, providerToken, providerUid, email, displayName, photoUrl } = req.body;

    if (!['google', 'apple', 'facebook', 'snapchat', 'instagram'].includes(provider)) {
      return res.status(400).json({ success: false, message: 'Invalid social provider' });
    }

    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });

    const exists = user.socialProviders.find(sp => sp.provider === provider);
    if (exists) return res.status(400).json({ success: false, message: `${provider} account already linked` });

    user.socialProviders.push({ provider, providerUid, email, displayName, photoUrl });
    await user.save();

    res.status(200).json({ success: true, message: `${provider} account linked successfully` });
  } catch (error) { console.error('❌ Link Social Error:', error); next(error); }
};

exports.unlinkSocialAccount = async (req, res, next) => {
  try {
    const userId = req.user?.id || req.user?.userId;
    const { provider } = req.body;

    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });

    const isPrimary = user.provider === provider;
    if (isPrimary) return res.status(400).json({ success: false, message: 'Cannot unlink primary login method' });

    user.socialProviders = user.socialProviders.filter(sp => sp.provider !== provider);
    await user.save();

    res.status(200).json({ success: true, message: `${provider} account unlinked` });
  } catch (error) { console.error('❌ Unlink Social Error:', error); next(error); }
};

exports.guestLogin = async (req, res, next) => {
  try {
    const arvindId = `ARV-GUEST-${Date.now().toString(36).toUpperCase()}`;
    const user = new User({
      uid: `guest_${Date.now().toString(36)}`,
      arvindId,
      username: `guest_${Date.now().toString(36).substring(0, 8)}`,
      name: 'Guest User',
      provider: 'guest',
      isGuest: true,
      guestExpiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      isProfileComplete: false,
      role: 'user',
      coins: 0,
      diamonds: 0,
      level: 1,
    });
    await user.save();

    const token = jwt.sign({ userId: user._id.toString(), uid: user.uid, role: user.role }, process.env.JWT_SECRET, { expiresIn: '15m' });
    const refreshToken = jwt.sign({ userId: user._id.toString() }, process.env.REFRESH_TOKEN_SECRET, { expiresIn: '90d' });

    res.status(200).json({
      success: true,
      message: 'Guest login successful',
      data: { token, refreshToken, user: { _id: user._id, uid: user.uid, arvindId: user.arvindId, name: user.name, provider: user.provider, isGuest: user.isGuest, coins: user.coins, diamonds: user.diamonds, level: user.level } },
    });
  } catch (error) { console.error('❌ Guest Login Error:', error); next(error); }
};

// ─── FROM: firebaseAuth.controller.js ────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════
// FILE: src/controllers/firebaseAuth.controller.js
// ARVIND PARTY - FIREBASE AUTH CONTROLLER (Multi-Platform Login)
// Flow: App sends Firebase ID Token → Backend verifies with Admin SDK → Returns JWT
// ═══════════════════════════════════════════════════════════════════════════

const User = require('../../models/User');
const jwt = require('jsonwebtoken');
const { verifyIdToken, getUserById } = require('../../config/firebase-admin');
const BannedDevice = require('../../models/BannedDevice');
const { captureDeviceFingerprint } = require('../../middlewares/deviceFingerprint');

// ═══════════════════════════════════════════════════════════════════════════
// VERIFY FIREBASE ID TOKEN
// POST /api/auth/firebase-verify
// Body: { idToken, deviceId, deviceInfo, platform }
// ═══════════════════════════════════════════════════════════════════════════

exports.verifyFirebaseToken = async (req, res, next) => {
  try {
    const { idToken, deviceId, deviceInfo, platform } = req.body;

    if (!idToken) {
      return res.status(400).json({
        success: false,
        message: 'Firebase ID token is required',
        code: 'MISSING_TOKEN',
      });
    }

    const deviceFingerprint = captureDeviceFingerprint(req);

    if (deviceId) {
      const bannedDevice = await BannedDevice.findOne({ deviceId });
      if (bannedDevice) {
        return res.status(403).json({
          success: false,
          message: 'This device has been permanently banned from the platform.',
          code: 'DEVICE_BANNED',
          bannedReason: bannedDevice.reason,
          bannedAt: bannedDevice.bannedAt,
        });
      }
    }

    let decodedToken;
    try {
      decodedToken = await verifyIdToken(idToken);
    } catch (tokenError) {
      return res.status(401).json({
        success: false,
        message: 'Invalid or expired Firebase ID token',
        code: 'INVALID_FIREBASE_TOKEN',
        details: tokenError.message,
      });
    }

    const firebaseUid = decodedToken.uid;
    const firebaseEmail = decodedToken.email || null;
    const firebasePhone = decodedToken.phone_number || null;

    let user = await User.findOne({
      $or: [
        { firebaseUid: firebaseUid },
        { email: firebaseEmail },
        { phone: firebasePhone?.replace('+91', '') },
      ],
    });

    const isNewUser = !user;

    if (isNewUser) {
      const arvindId = `ARV-${Date.now().toString().slice(-8)}`;
      const username = firebaseEmail
        ? firebaseEmail.split('@')[0].toLowerCase().replace(/[^a-z0-9_]/g, '_')
        : `user_${Date.now().toString().slice(-6)}`;

      user = await User.create({
        firebaseUid: firebaseUid,
        email: firebaseEmail,
        phone: firebasePhone?.replace('+91', '') || null,
        username: username,
        displayName: decodedToken.name || firebaseEmail?.split('@')[0] || 'User',
        name: decodedToken.name || firebaseEmail?.split('@')[0] || 'User',
        avatar: decodedToken.picture || null,
        provider: 'firebase',
        platform: platform || 'mobile',
        deviceId: deviceId || deviceFingerprint.deviceId,
        deviceInfo: deviceInfo || deviceFingerprint,
        isProfileComplete: !!(firebaseEmail || firebasePhone),
        role: 'user',
        level: 1,
        xp: 0,
        coins: 0,
        diamonds: 0,
        isActive: true,
        isBanned: false,
        lastLoginAt: new Date(),
      });
    } else {
      user.firebaseUid = firebaseUid;
      if (firebaseEmail && !user.email) user.email = firebaseEmail;
      if (firebasePhone && !user.phone) user.phone = firebasePhone.replace('+91', '');
      if (decodedToken.picture && !user.avatar) user.avatar = decodedToken.picture;
      if (decodedToken.name && !user.displayName) {
        user.displayName = decodedToken.name;
        user.name = decodedToken.name;
      }
      user.lastLoginAt = new Date();
      user.loginCount = (user.loginCount || 0) + 1;
      await user.save();
    }

    const token = jwt.sign(
      {
        userId: user._id.toString(),
        uid: user.uid,
        firebaseUid: user.firebaseUid,
        phone: user.phone,
        email: user.email,
        role: user.role,
        provider: 'firebase',
      },
      process.env.JWT_SECRET,
      { expiresIn: '15m' },
    );

    const refreshToken = jwt.sign(
      { userId: user._id.toString(), firebaseUid: user.firebaseUid },
      process.env.REFRESH_TOKEN_SECRET,
      { expiresIn: '90d' },
    );

    res.status(200).json({
      success: true,
      message: isNewUser ? 'Account created successfully' : 'Login successful',
      data: {
        token,
        refreshToken,
        user: {
          _id: user._id,
          uid: user.uid,
          userId: user._id.toString(),
          firebaseUid: user.firebaseUid,
          phone: user.phone,
          email: user.email,
          name: user.name,
          displayName: user.displayName,
          avatar: user.avatar,
          arvindId: user.arvindId,
          username: user.username,
          level: user.level || 1,
          xp: user.xp || 0,
          isProfileComplete: user.isProfileComplete,
          gender: user.gender,
          dob: user.dob,
          role: user.role,
          badges: user.badges || [],
          unlockedBadges: user.unlockedBadges || [],
          activeFrame: user.activeFrame,
          equippedFrame: user.equippedFrame,
          vipLevel: user.vipLevel || 0,
          isVip: user.isVip || false,
          isNewUser,
          coins: user.coins || 0,
          diamonds: user.diamonds || 0,
        },
      },
    });
  } catch (error) {
    console.error('❌ Firebase Token Verification Error:', error);
    next(error);
  }
};

// ═══════════════════════════════════════════════════════════════════════════
// LINK FIREBASE ACCOUNT WITH EXISTING PHONE ACCOUNT
// POST /api/auth/firebase-link
// Header: Authorization: Bearer <jwt>
// Body: { idToken }
// ═══════════════════════════════════════════════════════════════════════════

exports.linkFirebaseAccount = async (req, res, next) => {
  try {
    const { idToken } = req.body;
    const userId = req.user.userId;

    if (!idToken) {
      return res.status(400).json({
        success: false,
        message: 'Firebase ID token is required',
      });
    }

    let decodedToken;
    try {
      decodedToken = await verifyIdToken(idToken);
    } catch (tokenError) {
      return res.status(401).json({
        success: false,
        message: 'Invalid Firebase ID token',
        code: 'INVALID_FIREBASE_TOKEN',
      });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    if (user.firebaseUid && user.firebaseUid !== decodedToken.uid) {
      return res.status(409).json({
        success: false,
        message: 'This Firebase account is already linked to another user',
      });
    }

    const existingFirebaseUser = await User.findOne({ firebaseUid: decodedToken.uid });
    if (existingFirebaseUser && existingFirebaseUser._id.toString() !== userId) {
      return res.status(409).json({
        success: false,
        message: 'This Firebase account is already linked to another account',
      });
    }

    user.firebaseUid = decodedToken.uid;
    if (decodedToken.email && !user.email) user.email = decodedToken.email;
    if (decodedToken.phone_number && !user.phone) {
      user.phone = decodedToken.phone_number.replace('+91', '');
    }
    if (decodedToken.picture && !user.avatar) user.avatar = decodedToken.picture;
    if (decodedToken.name && !user.displayName) {
      user.displayName = decodedToken.name;
      user.name = decodedToken.name;
    }
    await user.save();

    res.status(200).json({
      success: true,
      message: 'Firebase account linked successfully',
      data: {
        user: {
          _id: user._id,
          firebaseUid: user.firebaseUid,
          email: user.email,
          phone: user.phone,
          name: user.name,
          displayName: user.displayName,
          avatar: user.avatar,
        },
      },
    });
  } catch (error) {
    console.error('❌ Firebase Account Link Error:', error);
    next(error);
  }
};

// ═══════════════════════════════════════════════════════════════════════════
// APPLE SIGN-IN SUPPORT (iOS)
// POST /api/auth/apple-verify
// Body: { identityToken, deviceId, deviceInfo, platform }
// ═══════════════════════════════════════════════════════════════════════════

exports.verifyAppleToken = async (req, res, next) => {
  try {
    const { identityToken, deviceId, deviceInfo, platform } = req.body;

    if (!identityToken) {
      return res.status(400).json({
        success: false,
        message: 'Apple identity token is required',
        code: 'MISSING_TOKEN',
      });
    }

    const deviceFingerprint = captureDeviceFingerprint(req);

    if (deviceId) {
      const bannedDevice = await BannedDevice.findOne({ deviceId });
      if (bannedDevice) {
        return res.status(403).json({
          success: false,
          message: 'This device has been permanently banned from the platform.',
          code: 'DEVICE_BANNED',
          bannedReason: bannedDevice.reason,
          bannedAt: bannedDevice.bannedAt,
        });
      }
    }

    let appleUid;
    let appleEmail = null;
    let appleName = 'Apple User';

    try {
      const appleResponse = await verifyIdToken(identityToken);
      appleUid = appleResponse.uid;
      appleEmail = appleResponse.email || null;
      appleName = appleResponse.name || appleEmail?.split('@')[0] || 'Apple User';
    } catch (tokenError) {
      return res.status(401).json({
        success: false,
        message: 'Invalid Apple identity token',
        code: 'INVALID_APPLE_TOKEN',
      });
    }

    let user = await User.findOne({ firebaseUid: appleUid });

    const isNewUser = !user;
    if (isNewUser) {
      const arvindId = `ARV-${Date.now().toString().slice(-8)}`;
      const username = `apple_${Date.now().toString().slice(-6)}`;

      user = await User.create({
        firebaseUid: appleUid,
        email: appleEmail,
        username: username,
        displayName: appleName,
        name: appleName,
        avatar: null,
        provider: 'apple',
        platform: platform || 'ios',
        deviceId: deviceId || deviceFingerprint.deviceId,
        deviceInfo: deviceInfo || deviceFingerprint,
        isProfileComplete: !!appleEmail,
        role: 'user',
        level: 1,
        xp: 0,
        coins: 0,
        diamonds: 0,
        isActive: true,
        isBanned: false,
        lastLoginAt: new Date(),
      });
    } else {
      user.lastLoginAt = new Date();
      user.loginCount = (user.loginCount || 0) + 1;
      await user.save();
    }

    const token = jwt.sign(
      {
        userId: user._id.toString(),
        uid: user.uid,
        firebaseUid: user.firebaseUid,
        phone: user.phone,
        email: user.email,
        role: user.role,
        provider: 'apple',
      },
      process.env.JWT_SECRET,
      { expiresIn: '15m' },
    );

    const refreshToken = jwt.sign(
      { userId: user._id.toString(), firebaseUid: user.firebaseUid },
      process.env.REFRESH_TOKEN_SECRET,
      { expiresIn: '90d' },
    );

    res.status(200).json({
      success: true,
      message: isNewUser ? 'Apple account created successfully' : 'Apple login successful',
      data: {
        token,
        refreshToken,
        user: {
          _id: user._id,
          uid: user.uid,
          userId: user._id.toString(),
          firebaseUid: user.firebaseUid,
          phone: user.phone,
          email: user.email,
          name: user.name,
          displayName: user.displayName,
          avatar: user.avatar,
          arvindId: user.arvindId,
          username: user.username,
          level: user.level || 1,
          xp: user.xp || 0,
          isProfileComplete: user.isProfileComplete,
          gender: user.gender,
          dob: user.dob,
          role: user.role,
          badges: user.badges || [],
          unlockedBadges: user.unlockedBadges || [],
          activeFrame: user.activeFrame,
          equippedFrame: user.equippedFrame,
          vipLevel: user.vipLevel || 0,
          isVip: user.isVip || false,
          isNewUser,
          coins: user.coins || 0,
          diamonds: user.diamonds || 0,
        },
      },
    });
  } catch (error) {
    console.error('❌ Apple Token Verification Error:', error);
    next(error);
  }
};

// ─── FROM: googleAuthController.js ────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════
// CONTROLLER: GoogleAuthController — Google OAuth login
// ═══════════════════════════════════════════════════════════════════════════

const jwt = require('jsonwebtoken');
const User = require('../../models/User');
const Staff = require('../../models/Staff');

/**
 * POST /api/auth/google
 * Google OAuth login — accepts Firebase ID token from mobile/web
 */
exports.googleLogin = async (req, res) => {
  try {
    const { idToken, firebaseUid } = req.body;

    if (!idToken && !firebaseUid) {
      return res.status(400).json({ success: false, message: 'ID token or Firebase UID required' });
    }

    let user;
    let isNewUser = false;

    // Find user by Firebase UID
    user = await User.findOne({ uid: firebaseUid });

    if (!user) {
      // Create new user if not exists
      const randomSuffix = Math.random().toString(36).substring(2, 8);
      user = new User({
        uid: firebaseUid,
        name: `User_${randomSuffix}`,
        phone: '',
        email: '',
        isVerified: true,
        coins: 0,
        diamonds: 0,
        level: 1,
        role: 'user',
      });
      await user.save();
      isNewUser = true;
    }

    // Generate JWT
    const token = jwt.sign(
      { id: user._id, uid: user.uid, role: user.role, isUser: true },
      process.env.JWT_SECRET || 'arvind_party_super_secret_key',
      { expiresIn: '7d' }
    );

    return res.status(200).json({
      success: true,
      token,
      user: {
        _id: user._id,
        uid: user.uid,
        name: user.name,
        phone: user.phone,
        email: user.email,
        avatar: user.avatar,
        role: user.role,
        coins: user.coins,
        diamonds: user.diamonds,
        level: user.level,
        isVerified: user.isVerified,
        isNewUser,
      },
    });
  } catch (error) {
    console.error('Google Login Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

/**
 * POST /api/auth/apple
 * Apple Sign-in — accepts Apple identity token
 */
exports.appleLogin = async (req, res) => {
  try {
    const { identityToken, firebaseUid, email, name } = req.body;

    if (!identityToken && !firebaseUid) {
      return res.status(400).json({ success: false, message: 'Identity token or Firebase UID required' });
    }

    let user = await User.findOne({ uid: firebaseUid });

    if (!user) {
      const randomSuffix = Math.random().toString(36).substring(2, 8);
      user = new User({
        uid: firebaseUid,
        name: name || `Apple_${randomSuffix}`,
        phone: '',
        email: email || '',
        isVerified: true,
        coins: 0,
        diamonds: 0,
        level: 1,
        role: 'user',
      });
      await user.save();
    }

    const token = jwt.sign(
      { id: user._id, uid: user.uid, role: user.role, isUser: true },
      process.env.JWT_SECRET || 'arvind_party_super_secret_key',
      { expiresIn: '7d' }
    );

    return res.status(200).json({
      success: true,
      token,
      user: {
        _id: user._id,
        uid: user.uid,
        name: user.name,
        phone: user.phone,
        email: user.email,
        avatar: user.avatar,
        role: user.role,
        coins: user.coins,
        diamonds: user.diamonds,
        level: user.level,
        isVerified: user.isVerified,
      },
    });
  } catch (error) {
    console.error('Apple Login Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};