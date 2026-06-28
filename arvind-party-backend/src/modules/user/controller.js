// =========================================================================
// MODULE: USER — CONTROLLER
// =========================================================================


// ─── FROM: userController.js ────────────────────────────────────────
const User = require('../../models/User'); // Pulls from your existing User Schema
const badgeController = require('./badgeController');
const crypto = require('crypto');
const Razorpay = require('razorpay');
const Transaction = require('../../models/Transaction');

exports.updateProfile = async (req, res) => {
  try {
    const { name, avatar } = req.body;
    const userId = req.user.userId;

    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ error: 'User not found' });

    // Update properties
    if (name) user.name = name;
    if (avatar) user.avatar = avatar; // We will accept Base64 string for now
    user.isProfileComplete = true;

    await user.save();

    res.status(200).json({
      message: 'Profile updated successfully',
      user: {
        name: user.name,
        avatar: user.avatar,
        isProfileComplete: user.isProfileComplete
      }
    });
  } catch (error) {
    console.error('Update Profile Error:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

exports.getUserCenter = async (req, res) => {
  try {
    const userId = req.user.userId;
    const user = await User.findById(userId);

    // Try to check and award badges automatically
    try {
      await badgeController.checkAndAwardBadges(userId);
    } catch (error) {
      console.log('Badge system not available, using fallback badges');
    }

    // Try to get user badges with unlock status
    let badges = [];
    try {
      badges = await badgeController.getUserBadges(userId);
    } catch (error) {
      console.log('Using fallback badges');
      // Fallback badges when MongoDB is not available
      badges = [
        { id: 'b1', name: 'Top Gifter', description: 'Gifted over 10k diamonds', iconPath: '💎', isUnlocked: false },
        { id: 'b2', name: 'Coin Collector', description: 'Earned over 50k coins', iconPath: '💰', isUnlocked: false },
        { id: 'b3', name: 'Level Master', description: 'Reached level 10', iconPath: '🏆', isUnlocked: false },
        { id: 'b4', name: 'Early Bird', description: 'Joined Arvind Party', iconPath: '🐦', isUnlocked: true }
      ];
    }

    // Get frames (for now, using hardcoded frames)
    const frames = [
      { id: 'f1', name: 'Default Ring', imagePath: 'ring', isUnlocked: true, isEquipped: user?.equippedFrame === 'f1' },
      { id: 'f2', name: 'Gold Ring', imagePath: 'gold_ring', isUnlocked: user?.unlockedFrames.includes('f2'), isEquipped: user?.equippedFrame === 'f2' },
      { id: 'f3', name: 'Diamond Ring', imagePath: 'diamond_ring', isUnlocked: user?.unlockedFrames.includes('f3'), isEquipped: user?.equippedFrame === 'f3' }
    ];

    // Returning real structured response for the app to render dynamically
    res.status(200).json({
      levelInfo: { currentLevel: user?.level || 1, currentExp: 0, nextLevelExp: 100 },
      badges: badges,
      frames: frames
    });
  } catch (error) {
    console.error('User Center Error:', error);
    res.status(500).json({ error: 'Failed to load user center data' });
  }
};

exports.equipFrame = async (req, res) => {
  try {
    const { frameId } = req.body;
    const userId = req.user.userId;
    
    await User.findByIdAndUpdate(userId, { equippedFrame: frameId });
    
    res.status(200).json({ message: 'Frame equipped successfully', frameId });
  } catch (error) {
    console.error('Equip Frame Error:', error);
    res.status(500).json({ error: 'Failed to equip frame' });
  }
};

exports.getVipStatus = async (req, res) => {
  try {
    const userId = req.user.userId;
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ error: 'User not found' });

    const isVip = user.vipExpiry && new Date(user.vipExpiry) > new Date();
    
    res.status(200).json({
      vip: {
        isVip: isVip,
        level: isVip ? (user.vipLevel || 1) : 0,
        expiryDate: user.vipExpiry,
        perks: isVip ? ['Exclusive VIP Badge', 'Premium Entrance Effects', 'Special Chat Colors', 'Priority Support'] : []
      }
    });
  } catch (error) {
    console.error('VIP Status Error:', error);
    res.status(500).json({ error: 'Failed to load VIP status' });
  }
};

exports.createPaymentOrder = async (req, res) => {
  try {
    const instance = new Razorpay({
      key_id: process.env.RAZORPAY_KEY_ID || 'YOUR_RAZORPAY_KEY_ID',
      key_secret: process.env.RAZORPAY_KEY_SECRET || 'YOUR_RAZORPAY_SECRET',
    });

    const options = {
      amount: 50000, // Amount is in subunits (e.g., 50000 paise = ₹500)
      currency: 'INR',
      receipt: `receipt_${req.user.userId}_${Date.now()}`,
      notes: {
        userId: req.user.userId // Added so webhooks know who this payment belongs to
      }
    };

    const order = await instance.orders.create(options);
    res.status(200).json({ success: true, order_id: order.id, amount: order.amount });
  } catch (error) {
    console.error('Create Order Error:', error);
    res.status(500).json({ error: 'Failed to create Razorpay order' });
  }
};

exports.verifyPayment = async (req, res) => {
  try {
    const { razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body;
    const userId = req.user.userId;

    // IMPORTANT: Replace this with your actual Razorpay Key Secret from environment variables!
    const secret = process.env.RAZORPAY_KEY_SECRET || 'YOUR_RAZORPAY_SECRET';

    // Generate the expected signature
    const generated_signature = crypto
      .createHmac('sha256', secret)
      .update(razorpay_order_id + '|' + razorpay_payment_id)
      .digest('hex');

    if (generated_signature === razorpay_signature) {
      // Idempotency check: Ensure we don't grant VIP twice if webhook already processed it
      const existingTx = await Transaction.findOne({ razorpayOrderId: razorpay_order_id });
      if (existingTx && existingTx.status === 'SUCCESS') {
        return res.status(200).json({ success: true, message: 'Payment already verified & VIP granted' });
      }

      // Signature matches! Grant VIP status securely in the database
      const user = await User.findById(userId);
      
      const now = new Date();
      user.vipExpiry = new Date(now.setDate(now.getDate() + 30)); // Grant 30 days
      user.vipLevel = (user.vipLevel || 0) + 1; // Bump VIP level
      await user.save();

      // Record the successful transaction in the database
      const transaction = new Transaction({
        user: userId,
        razorpayOrderId: razorpay_order_id,
        razorpayPaymentId: razorpay_payment_id,
        amount: 50000, // Matches the amount created in createPaymentOrder
        type: 'VIP_UPGRADE',
        status: 'SUCCESS'
      });
      await transaction.save();

      return res.status(200).json({ success: true, message: 'Payment verified & VIP granted' });
    } else {
      return res.status(400).json({ success: false, error: 'Invalid payment signature' });
    }
  } catch (error) {
    console.error('Payment Verification Error:', error);
    res.status(500).json({ error: 'Failed to verify payment' });
  }
};

exports.getTransactionHistory = async (req, res) => {
  try {
    const userId = req.user.userId;
    // Find all transactions for this user and sort by newest first
    const transactions = await Transaction.find({ user: userId }).sort({ createdAt: -1 });
    
    res.status(200).json({ success: true, transactions });
  } catch (error) {
    console.error('Transaction History Error:', error);
    res.status(500).json({ error: 'Failed to load transaction history' });
  }
};

exports.razorpayWebhook = async (req, res) => {
  try {
    // Make sure to set this in your .env file!
    const secret = process.env.RAZORPAY_WEBHOOK_SECRET || 'YOUR_WEBHOOK_SECRET';
    const signature = req.headers['x-razorpay-signature'];

    // Use the raw body buffer if available, as JSON.stringify can alter formatting and break signatures!
    const payload = req.rawBody ? req.rawBody : JSON.stringify(req.body);

    // Generate the expected signature to ensure the request genuinely came from Razorpay
    const expectedSignature = crypto
      .createHmac('sha256', secret)
      .update(payload)
      .digest('hex');

    if (expectedSignature !== signature) {
      return res.status(400).json({ success: false, error: 'Invalid webhook signature' });
    }

    const event = req.body.event;
    const paymentEntity = req.body.payload.payment.entity;
    const razorpay_order_id = paymentEntity.order_id;
    const razorpay_payment_id = paymentEntity.id;
    const userId = paymentEntity.notes?.userId; // Read the userId we injected earlier

    if (!userId) {
      return res.status(200).json({ success: true, message: 'Ignored: No userId found in notes' });
    }

    let transaction = await Transaction.findOne({ razorpayOrderId: razorpay_order_id });

    if (event === 'payment.captured' || event === 'order.paid') {
      if (!transaction) {
        // The Webhook beat the frontend app! Grant the user their VIP status.
        transaction = new Transaction({
          user: userId,
          razorpayOrderId: razorpay_order_id,
          razorpayPaymentId: razorpay_payment_id,
          amount: paymentEntity.amount,
          type: 'VIP_UPGRADE',
          status: 'SUCCESS'
        });
        await transaction.save();

        const user = await User.findById(userId);
        if (user) {
          const now = new Date();
          user.vipExpiry = new Date(now.setDate(now.getDate() + 30));
          user.vipLevel = (user.vipLevel || 0) + 1;
          await user.save();

          // Emit real-time notification to the app via Socket.IO
          const io = req.app.get('io');
          if (io) {
            // If users join a room with their userId, use io.to(userId).emit(...)
            // Otherwise, emit globally and filter on the client side
            io.emit('webhook_payment_success', { userId: userId });
          }
        }
      }
    } else if (event === 'payment.failed' && transaction) {
      transaction.status = 'FAILED';
      await transaction.save();
    }

    res.status(200).json({ success: true });
  } catch (error) {
    console.error('Webhook Error:', error);
    res.status(500).json({ error: 'Webhook processing failed' });
  }
};

// ─── FROM: profileController.js ────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════
// FILE: src/controllers/profileController.js
// ARVIND PARTY - MASTER USER PROFILE SYSTEM
// Handles profile view, update for regular users and restricted staff controls
// ═══════════════════════════════════════════════════════════════════════════

const User = require('../../models/User');
const Staff = require('../../models/Staff');
const Badge = require('../../models/Badge');
const BannedDevice = require('../../models/BannedDevice');
const path = require('path');
const fs = require('fs');

// ═══════════════════════════════════════════════════════════════════════════
// HELPER: Calculate XP needed for next level (exponential growth)
// ═══════════════════════════════════════════════════════════════════════════

function calculateXpToNextLevel(level) {
  return Math.floor(100 * Math.pow(1.15, level - 1));
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER: Calculate XP required for current level threshold
// ═══════════════════════════════════════════════════════════════════════════

function calculateXpForLevel(level) {
  if (level <= 1) return 0;
  return Math.floor(100 * Math.pow(1.15, level - 2));
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER: Mask phone number for privacy (show first 2 and last 4 digits)
// ═══════════════════════════════════════════════════════════════════════════

function maskPhone(phone) {
  if (!phone) return null;
  if (phone.length >= 10) {
    return phone.slice(0, 2) + '****' + phone.slice(-4);
  }
  return '****' + phone.slice(-4);
}

// ═══════════════════════════════════════════════════════════════════════════
// GET FULL PROFILE (with level, XP bar, badges, VIP info)
// GET /api/profile/:userId
// ═══════════════════════════════════════════════════════════════════════════

exports.getProfile = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const requestingUserId = req.user.userId;

    const user = await User.findById(userId).lean();
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    const isOwnProfile = userId === requestingUserId;

    const staffRecord = await Staff.findOne({ userId: user._id }).lean();

    const badgeRecords = await Badge.find({
      _id: { $in: (user.unlockedBadges || []).map(id => id.toString()) }
    }).lean();

    const profileData = {
      _id: user._id,
      uid: user.uid,
      arvindId: user.arvindId,
      phone: isOwnProfile ? user.phone : maskPhone(user.phone),
      email: isOwnProfile ? user.email : null,
      name: user.name || 'User',
      displayName: user.displayName || user.name || 'User',
      username: user.username,
      avatar: user.avatar,
      bio: user.bio || '',
      gender: user.gender || 'Not specified',
      dob: user.dob || null,
      level: user.level || 1,
      xp: user.xp || 0,
      xpToNextLevel: calculateXpToNextLevel(user.level || 1),
      xpProgressPercent: Math.min(100, ((user.xp || 0) / calculateXpToNextLevel(user.level || 1)) * 100),
      coins: isOwnProfile ? (user.coins || 0) : 0,
      diamonds: isOwnProfile ? (user.diamonds || 0) : 0,
      followersCount: user.followersCount || 0,
      followingCount: user.followingCount || 0,
      role: user.role || 'user',
      vipLevel: user.vipLevel || 0,
      isVip: user.isVip || false,
      vipExpiry: user.vipExpiry || null,
      badges: badgeRecords.map(b => ({
        id: b._id,
        name: b.name,
        icon: b.icon,
        color: b.color,
        type: b.type || 'standard',
      })),
      unlockedBadges: user.unlockedBadges || [],
      activeFrame: user.activeFrame || null,
      equippedFrame: user.equippedFrame || null,
      unlockedFrames: user.unlockedFrames || [],
      isProfileComplete: user.isProfileComplete || false,
      familyId: user.familyId || null,
      familyRole: user.familyRole || null,
      familyContribution: user.familyContribution || 0,
      createdAt: user.createdAt,
      joinedDays: Math.floor((Date.now() - new Date(user.createdAt).getTime()) / (1000 * 60 * 60 * 24)),

      isStaff: !!staffRecord,
      staffRole: staffRecord ? staffRecord.role : null,
      staffPermissions: staffRecord ? (staffRecord.permissions || []) : [],
    };

    if (isOwnProfile) {
      profileData.totalGiftsSent = user.totalGiftsSent || 0;
      profileData.totalGiftsReceived = user.totalGiftsReceived || 0;
      profileData.suspiciousActivityCount = user.suspiciousActivityCount || 0;
      profileData.deviceFlags = user.deviceFlags || [];
    }

    res.status(200).json({
      success: true,
      data: profileData,
    });
  } catch (error) {
    console.error('❌ Get Profile Error:', error);
    next(error);
  }
};

// ═══════════════════════════════════════════════════════════════════════════
// UPDATE PROFILE
// Staff Member → Only displayName + avatar (no login credentials)
// Regular User → Full profile edit (name, avatar, bio, gender, dob, username)
// PUT /api/profile/:userId
// ═══════════════════════════════════════════════════════════════════════════

exports.updateProfile = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const requestingUserId = req.user.userId;
    const userRole = req.user.role;

    if (userId !== requestingUserId && !['admin', 'owner'].includes(userRole)) {
      return res.status(403).json({
        success: false,
        message: 'You can only update your own profile',
        code: 'FORBIDDEN',
      });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    const staffRecord = await Staff.findOne({ userId: user._id });
    const isStaffMember = !!staffRecord;

    const allowedFields = {};

    if (isStaffMember && userId === requestingUserId) {
      // Staff can ONLY update display picture and display name
      if (req.body.displayName !== undefined) {
        allowedFields.displayName = req.body.displayName.trim();
        allowedFields.name = req.body.displayName.trim();
      }
      if (req.body.avatar !== undefined) {
        allowedFields.avatar = req.body.avatar;
      }
    } else if (userId === requestingUserId) {
      // Regular user can update full profile (except login credentials)
      if (req.body.name !== undefined) allowedFields.name = req.body.name.trim();
      if (req.body.displayName !== undefined) allowedFields.displayName = req.body.displayName.trim();
      if (req.body.avatar !== undefined) allowedFields.avatar = req.body.avatar;
      if (req.body.bio !== undefined) allowedFields.bio = req.body.bio.trim();
      if (req.body.gender !== undefined) {
        const validGenders = ['Male', 'Female', 'Other', 'Not specified'];
        if (validGenders.includes(req.body.gender)) {
          allowedFields.gender = req.body.gender;
        }
      }
      if (req.body.dob !== undefined) {
        const parsedDob = new Date(req.body.dob);
        if (!isNaN(parsedDob.getTime())) {
          allowedFields.dob = parsedDob;
        }
      }
      if (req.body.username !== undefined) {
        const username = req.body.username.trim().toLowerCase();
        if (/^[a-z0-9_]{3,20}$/.test(username)) {
          const existingUser = await User.findOne({ username, _id: { $ne: userId } });
          if (existingUser) {
            return res.status(409).json({
              success: false,
              message: 'Username is already taken',
            });
          }
          allowedFields.username = username;
        } else {
          return res.status(400).json({
            success: false,
            message: 'Username must be 3-20 characters (lowercase, numbers, underscores only)',
          });
        }
      }
    }

    if (Object.keys(allowedFields).length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No valid fields to update',
      });
    }

    Object.assign(user, allowedFields);
    user.isProfileComplete = true;
    user.updatedAt = new Date();
    await user.save();

    res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      data: {
        _id: user._id,
        name: user.name,
        displayName: user.displayName,
        avatar: user.avatar,
        bio: user.bio,
        gender: user.gender,
        dob: user.dob,
        username: user.username,
        isProfileComplete: user.isProfileComplete,
      },
    });
  } catch (error) {
    console.error('❌ Update Profile Error:', error);
    next(error);
  }
};

// ═══════════════════════════════════════════════════════════════════════════
// UPLOAD PROFILE PICTURE (Avatar/DP)
// POST /api/profile/:userId/avatar
// ═══════════════════════════════════════════════════════════════════════════

exports.uploadAvatar = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const requestingUserId = req.user.userId;

    if (userId !== requestingUserId) {
      return res.status(403).json({
        success: false,
        message: 'You can only update your own avatar',
      });
    }

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No image file provided',
      });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    const avatarUrl = `/uploads/avatars/${req.file.filename}`;
    user.avatar = avatarUrl;
    user.updatedAt = new Date();
    await user.save();

    res.status(200).json({
      success: true,
      message: 'Avatar updated successfully',
      data: {
        avatar: avatarUrl,
      },
    });
  } catch (error) {
    console.error('❌ Upload Avatar Error:', error);
    next(error);
  }
};

// ═══════════════════════════════════════════════════════════════════════════
// GET XP AND LEVEL PROGRESS (Level bar data for profile display)
// GET /api/profile/:userId/xp
// ═══════════════════════════════════════════════════════════════════════════

exports.getXpProgress = async (req, res, next) => {
  try {
    const { userId } = req.params;

    const user = await User.findById(userId).select('level xp coins diamonds');
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    const currentLevel = user.level || 1;
    const currentXp = user.xp || 0;
    const xpToNextLevel = calculateXpToNextLevel(currentLevel);
    const xpForCurrentLevel = calculateXpForLevel(currentLevel);

    res.status(200).json({
      success: true,
      data: {
        level: currentLevel,
        xp: currentXp,
        xpToNextLevel: xpToNextLevel,
        xpForCurrentLevel: xpForCurrentLevel,
        xpProgressPercent: Math.min(100, (currentXp / xpToNextLevel) * 100),
        coins: user.coins || 0,
        diamonds: user.diamonds || 0,
      },
    });
  } catch (error) {
    console.error('❌ Get XP Error:', error);
    next(error);
  }
};

// ─── FROM: socialController.js ────────────────────────────────────────
const User = require('../../models/User');
const Notification = require('../../models/Notification');
const VisitorHistory = require('../../models/VisitorHistory');

// ─────────────────────────────────────────────────────────────────────────
// FOLLOW USER
// POST /api/social/follow/:userId
// ─────────────────────────────────────────────────────────────────────────
exports.followUser = async (req, res) => {
  try {
    const requestingUserId = req.user.id || req.user.userId;
    const { userId } = req.params;

    if (userId === requestingUserId) {
      return res.status(400).json({ success: false, message: 'Cannot follow yourself' });
    }

    const targetUser = await User.findById(userId);
    if (!targetUser) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const currentUser = await User.findById(requestingUserId);
    if (!currentUser) {
      return res.status(404).json({ success: false, message: 'Current user not found' });
    }

    if (currentUser.following.includes(userId)) {
      return res.status(400).json({ success: false, message: 'Already following this user' });
    }

    currentUser.following.push(userId);
    currentUser.followingCount = currentUser.following.length;

    if (!targetUser.followers.includes(requestingUserId)) {
      targetUser.followers.push(requestingUserId);
      targetUser.followersCount = targetUser.followers.length;
    }

    await currentUser.save();
    await targetUser.save();

    await Notification.create({
      userId: userId,
      type: 'follow',
      title: 'New Follower',
      body: `${currentUser.name || 'Someone'} started following you.`,
      data: {
        followerId: requestingUserId,
        followerName: currentUser.name,
        followerAvatar: currentUser.avatar
      }
    });

    res.status(200).json({
      success: true,
      message: 'User followed successfully',
      data: {
        followersCount: targetUser.followersCount,
        followingCount: currentUser.followingCount
      }
    });
  } catch (error) {
    console.error('Follow User Error:', error);
    res.status(500).json({ success: false, message: 'Failed to follow user' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// UNFOLLOW USER
// POST /api/social/unfollow/:userId
// ─────────────────────────────────────────────────────────────────────────
exports.unfollowUser = async (req, res) => {
  try {
    const requestingUserId = req.user.id || req.user.userId;
    const { userId } = req.params;

    if (userId === requestingUserId) {
      return res.status(400).json({ success: false, message: 'Cannot unfollow yourself' });
    }

    const targetUser = await User.findById(userId);
    if (!targetUser) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const currentUser = await User.findById(requestingUserId);
    if (!currentUser) {
      return res.status(404).json({ success: false, message: 'Current user not found' });
    }

    currentUser.following = currentUser.following.filter(id => id.toString() !== userId);
    currentUser.followingCount = currentUser.following.length;

    targetUser.followers = targetUser.followers.filter(id => id.toString() !== requestingUserId);
    targetUser.followersCount = targetUser.followers.length;

    await currentUser.save();
    await targetUser.save();

    res.status(200).json({
      success: true,
      message: 'User unfollowed successfully',
      data: {
        followersCount: targetUser.followersCount,
        followingCount: currentUser.followingCount
      }
    });
  } catch (error) {
    console.error('Unfollow User Error:', error);
    res.status(500).json({ success: false, message: 'Failed to unfollow user' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// GET USER'S FOLLOWERS LIST
// GET /api/social/followers/:userId
// ─────────────────────────────────────────────────────────────────────────
exports.getFollowers = async (req, res) => {
  try {
    const { userId } = req.params;
    const requestingUserId = req.user.id || req.user.userId;

    const user = await User.findById(userId)
      .populate('followers', 'name avatar uid arvindId level isVip vipLevel')
      .lean();

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const followers = (user.followers || []).map(follower => {
      if (!follower || typeof follower !== 'object') return null;
      return {
        _id: follower._id,
        name: follower.name || 'User',
        avatar: follower.avatar,
        uid: follower.uid,
        arvindId: follower.arvindId,
        level: follower.level || 1,
        isVip: follower.isVip || false,
        vipLevel: follower.vipLevel || 0
      };
    }).filter(Boolean);

    res.status(200).json({
      success: true,
      data: followers,
      count: followers.length
    });
  } catch (error) {
    console.error('Get Followers Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch followers' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// GET USER'S FOLLOWING LIST
// GET /api/social/following/:userId
// ─────────────────────────────────────────────────────────────────────────
exports.getFollowing = async (req, res) => {
  try {
    const { userId } = req.params;
    const requestingUserId = req.user.id || req.user.userId;

    const user = await User.findById(userId)
      .populate('following', 'name avatar uid arvindId level isVip vipLevel')
      .lean();

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const following = (user.following || []).map(followedUser => {
      if (!followedUser || typeof followedUser !== 'object') return null;
      return {
        _id: followedUser._id,
        name: followedUser.name || 'User',
        avatar: followedUser.avatar,
        uid: followedUser.uid,
        arvindId: followedUser.arvindId,
        level: followedUser.level || 1,
        isVip: followedUser.isVip || false,
        vipLevel: followedUser.vipLevel || 0
      };
    }).filter(Boolean);

    res.status(200).json({
      success: true,
      data: following,
      count: following.length
    });
  } catch (error) {
    console.error('Get Following Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch following list' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// RECORD VISITOR HISTORY
// POST /api/social/visit/:userId
// ─────────────────────────────────────────────────────────────────────────
exports.recordVisit = async (req, res) => {
  try {
    const requestingUserId = req.user.id || req.user.userId;
    const { userId } = req.params;

    if (userId === requestingUserId) {
      return res.status(400).json({ success: false, message: 'Cannot visit your own profile' });
    }

    const profileUser = await User.findById(userId);
    if (!profileUser) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const visitorUser = await User.findById(requestingUserId);
    if (!visitorUser) {
      return res.status(404).json({ success: false, message: 'Visitor not found' });
    }

    const existingVisit = await VisitorHistory.findOneAndUpdate(
      { profileUserId: userId, visitorId: requestingUserId },
      {
        visitorUid: visitorUser.uid,
        visitorName: visitorUser.name || visitorUser.displayName || 'Anonymous',
        visitorAvatar: visitorUser.avatar || '',
        visitedAt: new Date()
      },
      { upsert: true, new: true }
    );

    res.status(200).json({
      success: true,
      message: 'Visit recorded',
      data: existingVisit
    });
  } catch (error) {
    console.error('Record Visit Error:', error);
    res.status(500).json({ success: false, message: 'Failed to record visit' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// GET VISITOR HISTORY
// GET /api/social/visitors
// ─────────────────────────────────────────────────────────────────────────
exports.getVisitorHistory = async (req, res) => {
  try {
    const requestingUserId = req.user.id || req.user.userId;

    const user = await User.findById(requestingUserId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const visitors = await VisitorHistory.find({ profileUserId: requestingUserId })
      .sort({ visitedAt: -1 })
      .limit(100);

    const visitorList = visitors.map(visit => ({
      _id: visit._id,
      visitorId: visit.visitorId,
      visitorUid: visit.visitorUid,
      visitorName: visit.visitorName,
      visitorAvatar: visit.visitorAvatar,
      visitedAt: visit.visitedAt
    }));

    res.status(200).json({
      success: true,
      data: visitorList,
      count: visitorList.length
    });
  } catch (error) {
    console.error('Get Visitor History Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch visitor history' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// BLOCK USER
// POST /api/social/block/:userId
// ─────────────────────────────────────────────────────────────────────────
exports.blockUser = async (req, res) => {
  try {
    const requestingUserId = req.user.id || req.user.userId;
    const { userId } = req.params;

    if (userId === requestingUserId) {
      return res.status(400).json({ success: false, message: 'Cannot block yourself' });
    }

    const targetUser = await User.findById(userId);
    if (!targetUser) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const currentUser = await User.findById(requestingUserId);

    if (currentUser.blockList.includes(userId)) {
      return res.status(400).json({ success: false, message: 'User already blocked' });
    }

    currentUser.blockList.push(userId);
    currentUser.blockedCount = currentUser.blockList.length;

    if (currentUser.following.includes(userId)) {
      currentUser.following = currentUser.following.filter(id => id.toString() !== userId);
      currentUser.followingCount = currentUser.following.length;
    }

    if (currentUser.followers.includes(userId)) {
      currentUser.followers = currentUser.followers.filter(id => id.toString() !== userId);
      currentUser.followersCount = currentUser.followers.length;
    }

    await currentUser.save();

    res.status(200).json({
      success: true,
      message: 'User blocked successfully',
      blockedCount: currentUser.blockedCount
    });
  } catch (error) {
    console.error('Block User Error:', error);
    res.status(500).json({ success: false, message: 'Failed to block user' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// UNBLOCK USER
// POST /api/social/unblock/:userId
// ─────────────────────────────────────────────────────────────────────────
exports.unblockUser = async (req, res) => {
  try {
    const requestingUserId = req.user.id || req.user.userId;
    const { userId } = req.params;

    const currentUser = await User.findById(requestingUserId);
    if (!currentUser) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    if (!currentUser.blockList.includes(userId)) {
      return res.status(400).json({ success: false, message: 'User is not blocked' });
    }

    currentUser.blockList = currentUser.blockList.filter(id => id.toString() !== userId);
    currentUser.blockedCount = currentUser.blockList.length;
    await currentUser.save();

    res.status(200).json({
      success: true,
      message: 'User unblocked successfully',
      blockedCount: currentUser.blockedCount
    });
  } catch (error) {
    console.error('Unblock User Error:', error);
    res.status(500).json({ success: false, message: 'Failed to unblock user' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// GET BLOCK LIST
// GET /api/social/block-list
// ─────────────────────────────────────────────────────────────────────────
exports.getBlockList = async (req, res) => {
  try {
    const requestingUserId = req.user.id || req.user.userId;

    const user = await User.findById(requestingUserId)
      .populate('blockList', 'name avatar uid arvindId level')
      .lean();

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const blockedUsers = (user.blockList || []).map(blocked => {
      if (!blocked || typeof blocked !== 'object') return null;
      return {
        _id: blocked._id,
        name: blocked.name || 'User',
        avatar: blocked.avatar,
        uid: blocked.uid,
        arvindId: blocked.arvindId,
        level: blocked.level || 1
      };
    }).filter(Boolean);

    res.status(200).json({
      success: true,
      data: blockedUsers,
      count: blockedUsers.length,
      blockedCount: user.blockedCount || 0
    });
  } catch (error) {
    console.error('Get Block List Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch block list' });
  }
};

// ─────────────────────────────────────────────────────────────────────────
// CHECK IF BLOCKED
// GET /api/social/check-block/:userId
// ─────────────────────────────────────────────────────────────────────────
exports.checkBlockStatus = async (req, res) => {
  try {
    const requestingUserId = req.user.id || req.user.userId;
    const { userId } = req.params;

    const currentUser = await User.findById(requestingUserId);
    const targetUser = await User.findById(userId);

    if (!currentUser || !targetUser) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const isBlockedByMe = currentUser.blockList.includes(userId);
    const isBlockedByThem = targetUser.blockList.includes(requestingUserId);

    res.status(200).json({
      success: true,
      isBlocked: isBlockedByMe || isBlockedByThem,
      isBlockedByMe,
      isBlockedByThem
    });
  } catch (error) {
    console.error('Check Block Status Error:', error);
    res.status(500).json({ success: false, message: 'Failed to check block status' });
  }
};

// ─── FROM: appUserController.js ────────────────────────────────────────
const User = require('../../models/User');
const Agency = require('../../models/Agency');
const Withdrawal = require('../../models/Withdrawal');

exports.joinAgency = async (req, res) => {
  try {
    const { userId, agencyId } = req.body;

    if (!userId || !agencyId) return res.status(400).json({ success: false, message: 'User ID and Agency ID required' });

    const agency = await Agency.findById(agencyId);
    if (!agency) return res.status(404).json({ success: false, message: 'Invalid Agency ID' });

    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });

    user.agencyId = agency._id;
    await user.save();

    agency.totalHosts = (agency.totalHosts || 0) + 1;
    await agency.save();

    return res.status(200).json({ success: true, message: 'Successfully joined the Agency' });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server Error' });
  }
};

exports.requestWithdrawal = async (req, res) => {
  try {
    const { userId, coins, paymentDetails } = req.body;

    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });

    if (user.coins < coins) return res.status(400).json({ success: false, message: 'Insufficient coins balance' });

    // Conversion Logic: 1000 Coins = 1 USD (Example)
    const amountUSD = coins / 1000;

    // Instant deduction to prevent double-spending
    user.coins -= coins;
    await user.save();

    const withdrawal = new Withdrawal({ userId: user._id, amountUSD, coinsDeducted: coins, paymentDetails });
    await withdrawal.save();

    return res.status(200).json({ success: true, message: 'Cash-out request submitted successfully' });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server Error' });
  }
};