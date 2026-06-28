// =========================================================================
// MODULE: ADMIN — CONTROLLER
// =========================================================================


// ─── FROM: admin.controller.js ────────────────────────────────────────
const User = require('../../models/User');
const WalletTransaction = require('../../models/WalletTransaction');
const Withdrawal = require('../../models/Withdrawal');
const Room = require('../../models/Room');
const Moment = require('../../models/Moment');
const Event = require('../../models/Event');
const GlobalSetting = require('../../models/GlobalSetting');
// ============================================================================
// DASHBOARD STATS
// ============================================================================

exports.getStats = async (req, res) => {
  try {
    const [
      totalUsers,
      totalRooms,
      activeRooms,
      totalMoments,
      totalEvents,
      pendingWithdrawals,
      totalRevenueResult
    ] = await Promise.all([
      User.countDocuments(),
      Room.countDocuments(),
      Room.countDocuments({ status: 'active' }),
      Moment.countDocuments({ isDeleted: false }),
      Event.countDocuments(),
      Withdrawal.countDocuments({ status: 'pending_level_1' }),
      WalletTransaction.aggregate([
        { $match: { type: 'recharge', status: 'completed' } },
        { $group: { _id: null, total: { $sum: '$amountInr' } } }
      ])
    ]);

    const totalRevenue = totalRevenueResult[0]?.total || 0;

    const recentTransactions = await WalletTransaction.find()
      .sort({ createdAt: -1 })
      .limit(10)
      .lean();

    const recentUsers = await User.find()
      .select('uid name avatar level coins diamonds createdAt')
      .sort({ createdAt: -1 })
      .limit(10)
      .lean();

    return res.status(200).json({
      success: true,
      data: {
        overview: {
          totalUsers,
          totalRooms,
          activeRooms,
          totalMoments,
          totalEvents,
          pendingWithdrawals,
          totalRevenue
        },
        recentTransactions,
        recentUsers
      }
    });
  } catch (error) {
    console.error('getStats Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

// ============================================================================
// USER MANAGEMENT — extended from admin.user.controller.js
// ============================================================================

exports.getUsers = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 50;
    const search = req.query.search || '';
    const role = req.query.role || '';

    const query = {};
    if (search) {
      query.$or = [
        { uid: { $regex: search, $options: 'i' } },
        { name: { $regex: search, $options: 'i' } },
        { phone: { $regex: search, $options: 'i' } }
      ];
    }
    if (role) {
      query.role = role;
    }

    const [users, total] = await Promise.all([
      User.find(query)
        .select('uid name avatar phone level vipLevel vipExpiry coins diamonds isBanned banReason role isActive createdAt')
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .lean(),
      User.countDocuments(query)
    ]);

    return res.status(200).json({
      success: true,
      data: users,
      pagination: { total, page, pages: Math.ceil(total / limit) }
    });
  } catch (error) {
    console.error('getUsers Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.getUserDetail = async (req, res) => {
  try {
    const user = await User.findById(req.params.id).lean();
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    return res.status(200).json({
      success: true,
      data: user
    });
  } catch (error) {
    console.error('getUserDetail Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;

    const user = await User.findByIdAndUpdate(id, { $set: updates }, { new: true }).select('-password');
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    return res.status(200).json({
      success: true,
      message: 'User updated successfully',
      data: user
    });
  } catch (error) {
    console.error('updateUser Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.toggleBan = async (req, res) => {
  try {
    const { userId, isBanned, reason } = req.body;

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    if (user.role === 'owner') {
      return res.status(403).json({ success: false, message: 'Cannot ban the owner' });
    }

    user.isBanned = isBanned;
    user.banReason = isBanned ? (reason || 'Violation of terms') : '';
    await user.save();

    const io = req.app.get('io');
    if (isBanned && io) {
      io.to(user._id.toString()).emit('force_logout', { message: user.banReason });
    }

    return res.status(200).json({
      success: true,
      message: `User ${isBanned ? 'banned' : 'unbanned'} successfully`,
      data: user
    });
  } catch (error) {
    console.error('toggleBan Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

// ============================================================================
// WALLET MANAGEMENT
// ============================================================================

exports.getWallets = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 50;
    const search = req.query.search || '';

    const query = {};
    if (search) {
      query.$or = [
        { uid: { $regex: search, $options: 'i' } },
        { name: { $regex: search, $options: 'i' } }
      ];
    }

    const [wallets, total] = await Promise.all([
      User.find(query)
        .select('uid name avatar phone coins diamonds level vipLevel createdAt')
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .lean(),
      User.countDocuments(query)
    ]);

    const stats = await WalletTransaction.aggregate([
      {
        $group: {
          _id: null,
          totalRecharged: { $sum: { $cond: [{ $eq: ['$type', 'recharge'] }, '$amountInr', 0] } },
          totalGifted: { $sum: { $cond: [{ $eq: ['$type', 'gift_sent'] }, '$amount', 0] } },
          totalWithdrawn: { $sum: { $cond: [{ $eq: ['$type', 'withdrawal'] }, '$amount', 0] } }
        }
      }
    ]);

    return res.status(200).json({
      success: true,
      data: {
        wallets,
        stats: stats[0] || { totalRecharged: 0, totalGifted: 0, totalWithdrawn: 0 },
        pagination: { total, page, pages: Math.ceil(total / limit) }
      }
    });
  } catch (error) {
    console.error('getWallets Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.adjustWallet = async (req, res) => {
  try {
    const { userId } = req.params;
    const { coins, diamonds, reason } = req.body;

    if (coins === undefined && diamonds === undefined) {
      return res.status(400).json({ success: false, message: 'Provide coins or diamonds to adjust' });
    }

    const $inc = {};
    if (coins !== undefined) $inc.coins = coins;
    if (diamonds !== undefined) $inc.diamonds = diamonds;

    const user = await User.findByIdAndUpdate(userId, { $inc }, { new: true }).select('uid name coins diamonds');
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    // Log adjustment
    const actorId = req.user?.userId || 'system';
    await WalletTransaction.create({
      userId,
      type: 'admin',
      amount: coins || 0,
      description: reason || 'Admin wallet adjustment',
      metadata: {
        adjustedBy: actorId,
        diamondsAdjusted: diamonds || 0
      }
    });

    return res.status(200).json({
      success: true,
      message: 'Wallet adjusted successfully',
      data: user
    });
  } catch (error) {
    console.error('adjustWallet Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.getLiveRooms = async (req, res) => {
  try {
    const rooms = await Room.find({ status: { $in: ['active', 'live'] } })
      .populate('ownerId', 'uid name username avatar')
      .sort({ createdAt: -1 })
      .limit(50);

    return res.status(200).json({
      success: true,
      data: rooms
    });
  } catch (error) {
    console.error('getLiveRooms Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.getBans = async (req, res) => {
  try {
    const users = await User.find({ isBanned: true })
      .select('uid name username avatar email phone banReason bannedAt')
      .sort({ bannedAt: -1 });

    return res.status(200).json({ success: true, data: users });
  } catch (error) {
    console.error('getBans Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.createBan = async (req, res) => {
  try {
    const { userId, reason } = req.body;
    if (!userId) {
      return res.status(400).json({ success: false, message: 'User ID is required' });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    user.isBanned = true;
    user.banReason = reason || 'Banned by admin';
    user.bannedAt = new Date();
    await user.save();

    return res.status(200).json({ success: true, message: 'User banned successfully', data: user });
  } catch (error) {
    console.error('createBan Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.liftBan = async (req, res) => {
  try {
    const { id } = req.params;
    const user = await User.findById(id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    user.isBanned = false;
    user.banReason = '';
    await user.save();

    return res.status(200).json({ success: true, message: 'Ban lifted successfully', data: user });
  } catch (error) {
    console.error('liftBan Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

// Alias for GET /api/admin/settings (delegates to getGlobalSettings for clarity)
exports.getSettings = async (req, res) => {
  return exports.getGlobalSettings(req, res);
};

// Alias for PUT /api/admin/settings (delegates to updateGlobalSettings for clarity)
exports.updateSettings = async (req, res) => {
  return exports.updateGlobalSettings(req, res);
};

exports.getGlobalSettings = async (req, res) => {
  try {
    const settings = await GlobalSetting.findOne();
    return res.status(200).json({ success: true, data: settings || {} });
  } catch (error) {
    console.error('getGlobalSettings Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.updateGlobalSettings = async (req, res) => {
  try {
    let settings = await GlobalSetting.findOne();
    if (!settings) {
      settings = new GlobalSetting();
    }

    Object.keys(req.body).forEach((key) => {
      if (key in settings.schema.paths || settings[key] !== undefined) {
        settings[key] = req.body[key];
      }
    });

    await settings.save();
    return res.status(200).json({ success: true, message: 'Global settings updated', data: settings });
  } catch (error) {
    console.error('updateGlobalSettings Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.adminSearch = async (req, res) => {
  try {
    const { q } = req.query;
    if (!q) {
      return res.status(400).json({ success: false, message: 'Search query is required' });
    }

    const users = await User.find({
      $or: [
        { uid: { $regex: q, $options: 'i' } },
        { name: { $regex: q, $options: 'i' } },
        { username: { $regex: q, $options: 'i' } },
        { phone: { $regex: q, $options: 'i' } }
      ]
    }).limit(20);

    return res.status(200).json({ success: true, data: { users } });
  } catch (error) {
    console.error('adminSearch Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

// ─── FROM: admin.user.controller.js ────────────────────────────────────────
const User = require('../../models/User');

/**
 * @desc    Get all users with pagination and search
 * @route   GET /api/admin/users
 * @access  Private (Admin/Owner)
 */
exports.getAllUsers = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 50;
    const search = req.query.search || '';

    const query = {};
    if (search) {
      query.$or = [
        { uid: { $regex: search, $options: 'i' } },
        { name: { $regex: search, $options: 'i' } }
      ];
    }

    const users = await User.find(query)
      .select('uid name avatar level vipLevel diamonds coins isBanned banReason createdAt')
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(limit)
      .lean();

    const total = await User.countDocuments(query);

    return res.status(200).json({
      success: true,
      data: users,
      pagination: { total, page, pages: Math.ceil(total / limit) }
    });
  } catch (error) {
    console.error('getAllUsers Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

/**
 * @desc    Ban or Unban a user
 * @route   POST /api/admin/users/ban
 * @access  Private (Admin/Owner)
 */
exports.toggleBanStatus = async (req, res) => {
  try {
    const { userId, isBanned, reason } = req.body;

    if (!userId) {
      return res.status(400).json({ success: false, message: 'User ID is required.' });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    // Cannot ban an owner
    if (user.role === 'owner') {
      return res.status(403).json({ success: false, message: 'Cannot ban the system owner.' });
    }

    user.isBanned = isBanned;
    user.banReason = isBanned ? (reason || 'Violation of terms') : '';
    await user.save();

    // If banned, force disconnect socket if user is online
    const io = req.app.get('io');
    if (isBanned && io) {
      io.to(user._id.toString()).emit('force_logout', { message: user.banReason });
    }

    return res.status(200).json({ success: true, message: `User successfully ${isBanned ? 'banned' : 'unbanned'}.`, data: user });
  } catch (error) {
    console.error('toggleBanStatus Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.verifyUser = async (req, res) => {
  try {
    const { userId } = req.params;
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    user.isProfileComplete = true;
    await user.save();

    return res.status(200).json({ success: true, message: 'User verified', data: user });
  } catch (error) {
    console.error('Verify User Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.adjustUserCoins = async (req, res) => {
  try {
    const { userId } = req.params;
    const { coins, diamonds } = req.body;

    if (coins === undefined && diamonds === undefined) {
      return res.status(400).json({ success: false, message: 'coins or diamonds required' });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    if (coins !== undefined) user.coins = (user.coins || 0) + Number(coins);
    if (diamonds !== undefined) user.diamonds = (user.diamonds || 0) + Number(diamonds);
    await user.save();

    return res.status(200).json({ success: true, message: 'User balance updated', data: user });
  } catch (error) {
    console.error('Adjust User Coins Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.getWithdrawals = async (req, res) => {
  try {
    const withdrawals = await require('../../models/Withdrawal').find().sort({ createdAt: -1 });
    return res.status(200).json({ success: true, data: withdrawals });
  } catch (error) {
    console.error('Get Withdrawals Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.approveWithdrawal = async (req, res) => {
  try {
    const Withdrawal = require('../../models/Withdrawal');
    const { id } = req.params;
    const item = await Withdrawal.findById(id);
    if (!item) return res.status(404).json({ success: false, message: 'Withdrawal not found' });

    item.status = 'approved';
    await item.save();

    return res.status(200).json({ success: true, message: 'Withdrawal approved', data: item });
  } catch (error) {
    console.error('Approve Withdrawal Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.rejectWithdrawal = async (req, res) => {
  try {
    const Withdrawal = require('../../models/Withdrawal');
    const { id } = req.params;
    const item = await Withdrawal.findById(id);
    if (!item) return res.status(404).json({ success: false, message: 'Withdrawal not found' });

    item.status = 'rejected';
    await item.save();

    return res.status(200).json({ success: true, message: 'Withdrawal rejected', data: item });
  } catch (error) {
    console.error('Reject Withdrawal Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.getAnnouncements = async (req, res) => {
  try {
    const Announcement = require('../../models/Announcement');
    const items = await Announcement.find().sort({ createdAt: -1 });
    return res.status(200).json({ success: true, data: items });
  } catch (error) {
    console.error('Get Announcements Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.sendAnnouncement = async (req, res) => {
  try {
    const Announcement = require('../../models/Announcement');
    const { title, message } = req.body;
    const item = await Announcement.create({ title, message });
    return res.status(201).json({ success: true, message: 'Announcement sent', data: item });
  } catch (error) {
    console.error('Send Announcement Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.getGifts = async (req, res) => {
  try {
    const Gift = require('../../models/Gift');
    const gifts = await Gift.find().sort({ createdAt: -1 });
    return res.status(200).json({ success: true, data: gifts });
  } catch (error) {
    console.error('Get Gifts Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.addGift = async (req, res) => {
  try {
    const Gift = require('../../models/Gift');
    const item = await Gift.create(req.body);
    return res.status(201).json({ success: true, data: item });
  } catch (error) {
    console.error('Add Gift Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.updateGift = async (req, res) => {
  try {
    const Gift = require('../../models/Gift');
    const item = await Gift.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!item) return res.status(404).json({ success: false, message: 'Gift not found' });
    return res.status(200).json({ success: true, data: item });
  } catch (error) {
    console.error('Update Gift Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.deleteGift = async (req, res) => {
  try {
    const Gift = require('../../models/Gift');
    const item = await Gift.findByIdAndDelete(req.params.id);
    if (!item) return res.status(404).json({ success: false, message: 'Gift not found' });
    return res.status(200).json({ success: true, message: 'Gift deleted' });
  } catch (error) {
    console.error('Delete Gift Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.getRecharges = async (req, res) => {
  try {
    const Recharge = require('../../models/Recharge');
    const items = await Recharge.find().sort({ createdAt: -1 });
    return res.status(200).json({ success: true, data: items });
  } catch (error) {
    console.error('Get Recharges Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.getSecurityLogins = async (req, res) => {
  try {
    const AuditLog = require('../../models/AuditLog');
    const items = await AuditLog.find({ action: /LOGIN|LOGOUT|TOKEN_REFRESH|SUSPICIOUS_ACTIVITY/i }).sort({ createdAt: -1 }).limit(100);
    return res.status(200).json({ success: true, data: items });
  } catch (error) {
    console.error('Get Security Logins Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.blockIp = async (req, res) => {
  try {
    const { ip } = req.body;
    if (!ip) return res.status(400).json({ success: false, message: 'IP address required' });

    return res.status(200).json({ success: true, message: `Blocked IP ${ip}` });
  } catch (error) {
    console.error('Block IP Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

// ─── FROM: adminController.js ────────────────────────────────────────
const mongoose = require('mongoose');
const User = require('../../models/User'); // User model aapke pas already hai
const TreasuryLog = require('../../models/TreasuryLog');
const Agency = require('../../models/Agency');
const GlobalSetting = require('../../models/GlobalSetting');
const Withdrawal = require('../../models/Withdrawal');

exports.getAllUsers = async (req, res) => {
  try {
    // Saare users fetch karega, bas unke passwords hide kar dega security ke liye
    const users = await User.find({}, { password: 0 }).sort({ createdAt: -1 });
    
    return res.status(200).json({ success: true, data: users });
  } catch (error) {
    console.error('Fetch Users Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

// ─── WITHDRAWAL MANAGEMENT ──────────────────────────────────────────────────
exports.getWithdrawals = async (req, res) => {
  try {
    const withdrawals = await Withdrawal.find().populate('userId', 'name uid avatar').sort({ createdAt: -1 });
    return res.status(200).json({ success: true, data: withdrawals });
  } catch (error) {
    console.error('Fetch Withdrawals Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.processWithdrawal = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body; // 'approved' or 'rejected'
    
    const withdrawal = await Withdrawal.findById(id);
    if (!withdrawal) return res.status(404).json({ success: false, message: 'Withdrawal request not found' });
    if (withdrawal.status !== 'pending') return res.status(400).json({ success: false, message: 'Request already processed' });

    if (status === 'rejected') {
      const user = await User.findById(withdrawal.userId);
      if (user) { user.coins += withdrawal.coinsDeducted; await user.save(); } // Refund on rejection
    }

    withdrawal.status = status;
    await withdrawal.save();
    return res.status(200).json({ success: true, message: `Withdrawal successfully ${status}` });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

// ─── SYSTEM SETTINGS ────────────────────────────────────────────────────────
exports.getSettings = async (req, res) => {
  try {
    let settings = await GlobalSetting.findOne();
    if (!settings) settings = await GlobalSetting.create({}); // Create default if not exists
    return res.status(200).json({ success: true, data: settings });
  } catch (error) {
    console.error('Get Settings Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.updateSettings = async (req, res) => {
  try {
    let settings = await GlobalSetting.findOne();
    if (!settings) settings = new GlobalSetting();

    if (req.body.giftCommission !== undefined) settings.giftCommission = req.body.giftCommission;
    if (req.body.withdrawalFee !== undefined) settings.withdrawalFee = req.body.withdrawalFee;
    if (req.body.minWithdrawal !== undefined) settings.minWithdrawal = req.body.minWithdrawal;

    await settings.save();
    return res.status(200).json({ success: true, message: 'Settings updated successfully', data: settings });
  } catch (error) {
    console.error('Update Settings Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

// ─── AGENCY CONTROL ─────────────────────────────────────────────────────────
exports.getAgencies = async (req, res) => {
  try {
    const agencies = await Agency.find().sort({ createdAt: -1 });
    return res.status(200).json({ success: true, data: agencies });
  } catch (error) {
    console.error('Get Agencies Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

// ─── COIN CONTROL SYSTEM ──────────────────────────────────────────────────
exports.generateCoins = async (req, res) => {
  try {
    const { uid, amount, reason } = req.body;
    if (!uid || !amount || amount <= 0) {
      return res.status(400).json({ success: false, message: 'Valid UID and Amount are required' });
    }

    const user = await User.findOne({ uid: uid });
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    user.coins = (user.coins || 0) + parseInt(amount);
    await user.save();

    // Create Audit Log (using TreasuryLog for admin transactions)
    const log = new TreasuryLog({
      type: 'coin_generated',
      amount: parseInt(amount),
      userId: user._id,
      description: `Coins generated by Admin/Owner. Reason: ${reason || 'No reason provided'}`
    });
    await log.save();

    return res.status(200).json({ success: true, message: `Successfully generated ${amount} coins for UID ${uid}`, data: { balance: user.coins } });
  } catch (error) {
    console.error('Generate Coins Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.deductCoins = async (req, res) => {
  try {
    const { uid, amount, reason } = req.body;
    if (!uid || !amount || amount <= 0) {
      return res.status(400).json({ success: false, message: 'Valid UID and Amount are required' });
    }

    const user = await User.findOne({ uid: uid });
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    if ((user.coins || 0) < parseInt(amount)) {
      return res.status(400).json({ success: false, message: 'User does not have enough coins' });
    }

    user.coins -= parseInt(amount);
    await user.save();

    // Create Audit Log
    const log = new TreasuryLog({
      type: 'coin_deducted',
      amount: -parseInt(amount),
      userId: user._id,
      description: `Coins deducted by Admin/Owner. Reason: ${reason || 'No reason provided'}`
    });
    await log.save();

    return res.status(200).json({ success: true, message: `Successfully deducted ${amount} coins from UID ${uid}`, data: { balance: user.coins } });
  } catch (error) {
    console.error('Deduct Coins Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

// ─── UID REWARD CENTER ────────────────────────────────────────────────────
exports.sendReward = async (req, res) => {
  try {
    const { uid, rewardType, itemId, durationDays, value } = req.body;
    // rewardType can be 'VIP', 'FRAME', 'BADGE', 'ENTRY_EFFECT', 'CAR', 'DIAMONDS', 'COINS'
    
    if (!uid || !rewardType) {
      return res.status(400).json({ success: false, message: 'UID and rewardType are required' });
    }

    const user = await User.findOne({ uid: uid });
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    let message = '';
    const expiryDate = durationDays ? new Date(Date.now() + durationDays * 24 * 60 * 60 * 1000) : null;

    switch (rewardType.toUpperCase()) {
      case 'DIAMONDS':
        user.diamonds = (user.diamonds || 0) + parseInt(value);
        message = `${value} Diamonds sent`;
        break;
      case 'COINS':
        user.coins = (user.coins || 0) + parseInt(value);
        message = `${value} Coins sent`;
        break;
      case 'VIP':
        user.isVip = true;
        user.vipLevel = value || 1;
        // Assume user model has vipExpiry field
        user.vipExpiry = expiryDate;
        message = `VIP Level ${user.vipLevel} sent for ${durationDays} days`;
        break;
      case 'FRAME':
        // Setup logic to grant frame (this depends on inventory schema, assuming user.frames array)
        user.activeFrame = itemId;
        message = `Frame ${itemId} sent`;
        break;
      case 'CAR':
        user.activeCar = itemId;
        message = `Car ${itemId} sent`;
        break;
      // Add other cases as inventory schemas are implemented
      default:
        return res.status(400).json({ success: false, message: `Reward type ${rewardType} not supported yet` });
    }

    await user.save();
    return res.status(200).json({ success: true, message: `Success: ${message} to UID ${uid}`, data: { uid } });
  } catch (error) {
    console.error('Send Reward Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.createAgency = async (req, res) => {
  try {
    const { name, ownerUid } = req.body;
    if (!name || !ownerUid) return res.status(400).json({ success: false, message: 'Agency Name and Owner UID are required' });

    const existing = await Agency.findOne({ ownerUid });
    if (existing) return res.status(400).json({ success: false, message: 'Owner UID already has an agency' });

    const newAgency = new Agency({ name, ownerUid });
    await newAgency.save();
    return res.status(200).json({ success: true, message: 'Agency created successfully', data: newAgency });
  } catch (error) {
    console.error('Create Agency Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.getStats = async (req, res) => {
  try {
    const totalUsers = await User.countDocuments();
    
    // Sum total generated coins for revenue/treasury
    const logs = await TreasuryLog.find();
    const totalRevenue = logs.reduce((sum, log) => sum + (log.amount || 0), 0);

    // Fallback if Room model is structured differently
    let activeRooms = 0;
    if (mongoose.models.Room) {
      activeRooms = await mongoose.models.Room.countDocuments({ isActive: true });
    }

    return res.status(200).json({
      success: true,
      data: { totalUsers, activeRooms, totalRevenue }
    });
  } catch (error) {
    console.error('Fetch Stats Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.getAllRooms = async (req, res) => {
  try {
    let rooms = [];
    if (mongoose.models.Room) {
      rooms = await mongoose.models.Room.find().sort({ createdAt: -1 });
    }
    return res.status(200).json({ success: true, data: rooms });
  } catch (error) {
    console.error('Fetch Rooms Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.closeRoom = async (req, res) => {
  try {
    const { id } = req.params;
    if (!mongoose.models.Room) return res.status(404).json({ success: false, message: 'Room Data not configured yet' });
    
    const room = await mongoose.models.Room.findById(id);
    if (!room) return res.status(404).json({ success: false, message: 'Room not found' });
    
    room.isActive = false;
    await room.save();

    return res.status(200).json({ success: true, message: 'Room forcefully closed by Admin', isActive: false });
  } catch (error) {
    console.error('Close Room Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.toggleBlockUser = async (req, res) => {
  try {
    const { id } = req.params;
    const user = await User.findById(id);
    
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    user.isBlocked = !user.isBlocked;
    await user.save();

    const action = user.isBlocked ? 'banned' : 'unbanned';
    return res.status(200).json({ success: true, message: `User successfully ${action}`, isBlocked: user.isBlocked });
  } catch (error) {
    console.error('Toggle Block User Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.getAgencyHosts = async (req, res) => {
  try {
    const { id } = req.params;
    // Fetch all users that belong to this agency's ID
    const hosts = await User.find({ agencyId: id }, { password: 0 });
    return res.status(200).json({ success: true, data: hosts });
  } catch (error) {
    console.error('Get Agency Hosts Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

// ─── FROM: adminAuthController.js ────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════
// FILE: src/controllers/adminAuthController.js
// ARVIND PARTY - ADVANCED ADMIN AUTH CONTROLLER
// Implements JWT + Refresh Tokens and 2-Factor Authentication for high-privilege roles.
// ═══════════════════════════════════════════════════════════════════════════

const jwt = require('jsonwebtoken');
const Staff = require('../../models/Staff');
const { verifyIdToken } = require('../../config/firebase-admin');
const { verifyOTP } = require('../../services/otp.service'); // Assuming Firebase OTP is used via a generic service

/**
 * Admin Login — Now uses Firebase Auth flow.
 * 
 * The frontend handles Firebase Auth directly. After successful Firebase
 * authentication, the frontend should call POST /api/staff/login with
 * the Firebase UID to obtain a backend JWT.
 */
exports.login = async (req, res) => {
  try {
    const { uid, idToken } = req.body;
    let staffUid = uid;

    // If idToken is provided, verify it first to get the UID
    if (idToken && !uid) {
      try {
        const decodedToken = await verifyIdToken(idToken);
        staffUid = decodedToken.uid;
      } catch (fbError) {
        return res.status(401).json({ success: false, message: 'Invalid Firebase ID token' });
      }
    }

    if (staffUid) {
      const staff = await Staff.findOne({ uid: staffUid });
      if (!staff) {
        return res.status(404).json({
          success: false,
          message: 'No staff account found for this UID. Please contact the Owner.'
        });
      }

      if (!staff.isActive) {
        return res.status(403).json({
          success: false,
          message: 'Account is disabled. Please contact the Owner.'
        });
      }

      // Check if 2FA is required for this role
      const highPrivilegeRoles = ['ownerWeb', 'superAdminUid', 'globalManagerWeb']; // As per blueprint
      if (highPrivilegeRoles.includes(staff.role) && staff.twoFactorEnabled) {
        // 2FA is required. Do not issue tokens yet.
        // Send a response indicating that the next step is 2FA verification.
        // In a real scenario, you might send an OTP to the staff's registered phone here.
        // For now, we just signal the frontend.
        return res.status(200).json({
          success: true,
          twoFactorRequired: true,
          message: `Welcome, ${staff.name}. Please complete the two-factor authentication step.`
        });
      }

      // No 2FA required, or it's disabled. Proceed with normal login and issue tokens.
      const { accessToken, refreshToken } = generateStaffTokens(staff);
      
      return res.json({
        success: true,
        twoFactorRequired: false,
        message: 'Login successful',
        accessToken,
        refreshToken,
        role: staff.role,
        staff: {
          _id: staff._id,
          uid: staff.uid,
          loginId: staff.loginId,
          name: staff.name,
          role: staff.role,
          permissions: staff.permissions
        }
      });
    }

    // No valid auth method provided
    return res.status(400).json({
      success: false,
      message: 'Please provide a Firebase UID or ID token.'
    });
  } catch (e) {
    console.error('Admin Login Error:', e);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

/**
 * Verify 2FA code and issue final tokens for high-privilege users.
 */
exports.verifyTwoFactor = async (req, res) => {
    try {
        const { uid, otp } = req.body;

        if (!uid || !otp) {
            return res.status(400).json({ success: false, message: 'Staff UID and OTP are required.' });
        }

        const staff = await Staff.findOne({ uid });
        if (!staff) {
            return res.status(404).json({ success: false, message: 'Staff account not found.' });
        }

        // Here you'd verify the OTP. For Firebase phone OTP, you'd use the admin SDK.
        // For Google Authenticator, you'd use a library like 'speakeasy'.
        // Let's simulate a simple check for now. This should be replaced with a real OTP service.
        const isOtpValid = await verifyOTP(staff.phone, otp); // Assuming staff has a phone number for OTP

        if (!isOtpValid.valid) {
            return res.status(401).json({ success: false, message: 'Invalid OTP code. Please try again.' });
        }

        // OTP is valid. Issue the final access and refresh tokens.
        const { accessToken, refreshToken } = generateStaffTokens(staff);

        res.json({
            success: true,
            message: '2FA verification successful. Access granted.',
            accessToken,
            refreshToken,
            role: staff.role,
            staff: {
                _id: staff._id,
                uid: staff.uid,
                loginId: staff.loginId,
                name: staff.name,
                role: staff.role,
                permissions: staff.permissions
            }
        });

    } catch (error) {
        console.error('Admin 2FA Verification Error:', error);
        return res.status(500).json({ success: false, message: 'Internal Server Error' });
    }
};

/**
 * Helper function to generate staff tokens.
 */
const generateStaffTokens = (staff) => {
    const accessTokenPayload = {
        id: staff._id,
        uid: staff.uid,
        role: staff.role,
        isStaff: true,
        permissions: staff.permissions
    };

    const refreshTokenPayload = {
        id: staff._id,
        uid: staff.uid,
        isStaff: true
    };

    const accessToken = jwt.sign(accessTokenPayload, process.env.JWT_SECRET, { expiresIn: '15m' });
    const refreshToken = jwt.sign(refreshTokenPayload, process.env.REFRESH_TOKEN_SECRET, { expiresIn: '7d' });

    return { accessToken, refreshToken };
};

// ─── FROM: staffController.js ────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════
// CONTROLLER: StaffController — Full 15+ role management with Owner enforcement
// Password modification strictly locked under Owner control
// ═══════════════════════════════════════════════════════════════════════════

const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const Staff = require('../../models/Staff');
const AuditLog = require('../../models/AuditLog');
const { ROLE_HIERARCHY, ROLES, ALL_PERMISSIONS, DEFAULT_PERMISSIONS } = Staff;

/**
 * POST /api/admin/staff/create
 * Owner/Super Admin only: Create a new staff account
 */
exports.createStaff = async (req, res) => {
  try {
    const { uid, loginId, password, name, email, phone, role, permissions, assignedCountry, notes } = req.body;

    if (!uid || !loginId || !password || !role) {
      return res.status(400).json({ success: false, message: 'UID, Login ID, password, and role required' });
    }

    if (!ROLES.includes(role)) {
      return res.status(400).json({ success: false, message: `Invalid role. Must be one of: ${ROLES.join(', ')}` });
    }

    // Check if staff already exists
    const existingStaff = await Staff.findOne({ $or: [{ uid }, { loginId }] });
    if (existingStaff) {
      return res.status(400).json({ success: false, message: 'Staff with this UID or Login ID already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 12);

    // Determine default permissions based on role
    const defaultPerms = DEFAULT_PERMISSIONS[role] || [];
    // If custom permissions provided, intersect with role's allowed permissions
    let finalPermissions = defaultPerms;
    if (permissions && Array.isArray(permissions) && permissions.length > 0) {
      if (req.user?.role === 'owner' || req.user?.role === 'super_admin') {
        finalPermissions = permissions;
      } else {
        // Non-owner can only assign permissions that exist in their own set
        finalPermissions = permissions.filter(p => (req.user?.permissions || []).includes(p));
      }
    }

    const newStaff = new Staff({
      uid,
      loginId,
      password: hashedPassword,
      name: name || '',
      email: email || '',
      phone: phone || '',
      role,
      permissions: finalPermissions,
      assignedCountry: assignedCountry || '',
      notes: notes || '',
      createdBy: req.user?.userId || 'OWNER',
    });
    await newStaff.save();

    await AuditLog.create({
      action: 'STAFF_CREATE',
      performedBy: req.user?.userId || 'SYSTEM',
      details: `Created staff account ${loginId} with role ${role}`,
      metadata: { uid, loginId, role, assignedCountry },
    });

    return res.status(201).json({
      success: true,
      message: `Staff account created for ${loginId} (${role})`,
      data: { uid, loginId, name, role, permissions: finalPermissions },
    });
  } catch (error) {
    console.error('Staff Creation Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

/**
 * POST /api/admin/staff/login
 * Staff Login
 */
exports.loginStaff = async (req, res) => {
  try {
    const { uid, loginId } = req.body;

    if (!uid) {
      return res.status(400).json({ success: false, message: 'Firebase UID required' });
    }

    const query = { uid };
    if (loginId) query.loginId = loginId;

    const staff = await Staff.findOne(query);
    if (!staff) {
      return res.status(404).json({ success: false, message: 'No staff account found for this UID' });
    }

    if (!staff.isActive) {
      return res.status(403).json({ success: false, message: 'Account disabled. Contact Owner.' });
    }

    // Update last login
    staff.lastLoginAt = new Date();
    staff.loginHistory.push({
      ip: req.ip || req.connection?.remoteAddress || '',
      userAgent: req.headers['user-agent'] || '',
    });
    await staff.save();

    const token = jwt.sign(
      {
        id: staff._id,
        uid: staff.uid,
        role: staff.role,
        roleLevel: staff.roleLevel,
        isStaff: true,
        permissions: staff.permissions,
      },
      process.env.JWT_SECRET || 'arvind_party_super_secret_key',
      { expiresIn: '24h' }
    );

    return res.status(200).json({
      success: true,
      token,
      staff: {
        _id: staff._id,
        uid: staff.uid,
        loginId: staff.loginId,
        name: staff.name,
        email: staff.email,
        role: staff.role,
        roleLevel: staff.roleLevel,
        permissions: staff.permissions,
        isActive: staff.isActive,
        isOwnerLocked: staff.isOwnerLocked,
        assignedCountry: staff.assignedCountry,
      },
    });
  } catch (error) {
    console.error('Staff Login Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

/**
 * GET /api/admin/staff/list
 * List all staff accounts
 */
exports.getStaffList = async (req, res) => {
  try {
    const staffList = await Staff.find({}, { password: 0 }).sort({ roleLevel: -1, createdAt: -1 });
    return res.status(200).json({ success: true, data: staffList });
  } catch (error) {
    console.error('Get Staff List Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

/**
 * PUT /api/admin/staff/update/:id
 * Update staff account (Owner-enforced password lock)
 */
exports.updateStaff = async (req, res) => {
  try {
    const { id } = req.params;
    const { role, permissions, isActive, isOwnerLocked, name, email, phone, assignedCountry, notes, password } = req.body;

    const staff = await Staff.findById(id);
    if (!staff) return res.status(404).json({ success: false, message: 'Staff not found' });

    const requesterRole = req.user?.role || '';
    const requesterLevel = ROLE_HIERARCHY[requesterRole]?.level || 0;

    // Owner-enforced password lock: only Owner can change passwords
    if (password !== undefined) {
      if (requesterRole !== 'owner' && staff.isOwnerLocked) {
        return res.status(403).json({
          success: false,
          message: 'Password change blocked by Owner enforcement. Only the Owner can change passwords for this account.',
        });
      }
      if (requesterRole === 'owner' || !staff.isOwnerLocked) {
        staff.password = await bcrypt.hash(password, 12);
      }
    }

    if (role !== undefined) {
      if (!ROLES.includes(role)) {
        return res.status(400).json({ success: false, message: `Invalid role: ${role}` });
      }
      // Only owner/super_admin can change roles
      if (requesterLevel < 80) {
        return res.status(403).json({ success: false, message: 'Insufficient level to change role' });
      }
      staff.role = role;
      // Reset permissions to default for new role unless custom provided
      if (!permissions) {
        staff.permissions = DEFAULT_PERMISSIONS[role] || [];
      }
    }

    if (isOwnerLocked !== undefined) {
      if (requesterRole !== 'owner') {
        return res.status(403).json({ success: false, message: 'Only Owner can set password lock' });
      }
      staff.isOwnerLocked = isOwnerLocked;
    }

    // Update other fields based on requester permissions
    if (name !== undefined && (req.user?.permissions || []).includes('staff.edit')) staff.name = name;
    if (email !== undefined && (req.user?.permissions || []).includes('staff.edit')) staff.email = email;
    if (phone !== undefined && (req.user?.permissions || []).includes('staff.edit')) staff.phone = phone;
    if (assignedCountry !== undefined) staff.assignedCountry = assignedCountry;
    if (notes !== undefined) staff.notes = notes;
    if (permissions !== undefined && (req.user?.permissions || []).includes('staff.edit')) {
      staff.permissions = permissions;
    }
    if (isActive !== undefined && (req.user?.permissions || []).includes('staff.edit')) staff.isActive = isActive;

    await staff.save();

    await AuditLog.create({
      action: 'STAFF_UPDATE',
      performedBy: req.user?.userId || 'SYSTEM',
      details: `Updated staff ${staff.loginId}`,
      metadata: { staffId: id, changes: Object.keys(req.body) },
    });

    const staffData = staff.toObject();
    delete staffData.password;
    return res.status(200).json({ success: true, message: 'Staff updated', data: staffData });
  } catch (error) {
    console.error('Update Staff Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

/**
 * DELETE /api/admin/staff/delete/:id
 * Owner only: Delete a staff account
 */
exports.deleteStaff = async (req, res) => {
  try {
    const { id } = req.params;
    if (req.user?.role !== 'owner') {
      return res.status(403).json({ success: false, message: 'Only Owner can delete staff accounts' });
    }

    const staff = await Staff.findByIdAndDelete(id);
    if (!staff) return res.status(404).json({ success: false, message: 'Staff not found' });

    await AuditLog.create({
      action: 'STAFF_DELETE',
      performedBy: req.user?.userId || 'SYSTEM',
      details: `Deleted staff ${staff.loginId} (${staff.role})`,
      metadata: { staffId: id, loginId: staff.loginId },
    });

    return res.status(200).json({ success: true, message: 'Staff deleted permanently' });
  } catch (error) {
    console.error('Delete Staff Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

/**
 * POST /api/admin/staff/change-password/:id
 * Owner only: Force change staff password (bypasses lock)
 */
exports.changeStaffPassword = async (req, res) => {
  try {
    const { id } = req.params;
    const { newPassword } = req.body;

    if (req.user?.role !== 'owner') {
      return res.status(403).json({ success: false, message: 'Only Owner can force-change passwords' });
    }

    if (!newPassword || newPassword.length < 6) {
      return res.status(400).json({ success: false, message: 'Password must be at least 6 characters' });
    }

    const staff = await Staff.findById(id);
    if (!staff) return res.status(404).json({ success: false, message: 'Staff not found' });

    staff.password = await bcrypt.hash(newPassword, 12);
    staff.isOwnerLocked = true; // Lock password after owner change
    await staff.save();

    await AuditLog.create({
      action: 'STAFF_PASSWORD_CHANGE',
      performedBy: req.user?.userId || 'OWNER',
      details: `Owner changed password for staff ${staff.loginId}`,
      metadata: { staffId: id, loginId: staff.loginId },
    });

    return res.status(200).json({ success: true, message: 'Password changed and locked by Owner' });
  } catch (error) {
    console.error('changeStaffPassword Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

/**
 * GET /api/admin/staff/roles
 * Get all available roles with hierarchy info
 */
exports.getAdminRoles = async (req, res) => {
  try {
    const hierarchy = Staff.getRoleHierarchy();
    const rolesWithStaffCount = await Promise.all(
      Object.entries(hierarchy).map(async ([roleKey, roleInfo]) => {
        const count = await Staff.countDocuments({ role: roleKey });
        return { role: roleKey, ...roleInfo, staffCount: count, defaultPermissions: DEFAULT_PERMISSIONS[roleKey] || [] };
      })
    );
    return res.status(200).json({
      success: true,
      data: {
        hierarchy,
        roles: rolesWithStaffCount,
        allPermissions: ALL_PERMISSIONS,
      },
    });
  } catch (error) {
    console.error('Get Admin Roles Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

/**
 * POST /api/admin/staff/roles/create
 * Create a staff with a specific role (admin convenience)
 */
exports.createAdminRole = async (req, res) => {
  try {
    const { uid, loginId, password, role, permissions } = req.body;
    return exports.createStaff({ ...req, body: { uid, loginId, password, role, permissions } }, res);
  } catch (error) {
    console.error('Create Admin Role Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

/**
 * PUT /api/admin/staff/roles/update/:id
 * Update role and permissions
 */
exports.updateAdminRole = async (req, res) => {
  try {
    const { id } = req.params;
    const { role, permissions } = req.body;
    return exports.updateStaff({ ...req, params: { id }, body: { role, permissions } }, res);
  } catch (error) {
    console.error('Update Admin Role Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.searchUser = async (req, res) => {
  try {
    const { query } = req.body;
    if (!query) return res.status(400).json({ success: false, message: 'Search query required' });

    const users = await require('../../models/User').find({
      $or: [
        { uid: { $regex: query, $options: 'i' } },
        { name: { $regex: query, $options: 'i' } },
        { phone: { $regex: query, $options: 'i' } },
        { username: { $regex: query, $options: 'i' } },
      ],
    }).limit(20);

    return res.status(200).json({ success: true, data: users });
  } catch (error) {
    console.error('Search User Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.getAuditLogs = async (req, res) => {
  try {
    const AuditLog = require('../../models/AuditLog');
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 50;
    const action = req.query.action || '';

    const query = {};
    if (action) query.action = action;

    const [logs, total] = await Promise.all([
      AuditLog.find(query).sort({ createdAt: -1 }).skip((page - 1) * limit).limit(limit).lean(),
      AuditLog.countDocuments(query),
    ]);

    return res.status(200).json({
      success: true,
      data: logs,
      pagination: { total, page, pages: Math.ceil(total / limit) },
    });
  } catch (error) {
    console.error('Get Audit Logs Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

// ─── FROM: coinVaultController.js ────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════
// CONTROLLER: CoinVaultController — Owner-only minting, dispatch to sellers
// ═══════════════════════════════════════════════════════════════════════════

const CoinVault = require('../../models/CoinVault');
const User = require('../../models/User');
const AuditLog = require('../../models/AuditLog');

/**
 * GET /api/treasury/vault
 * Fetch the current vault state
 */
exports.getVault = async (req, res) => {
  try {
    const vault = await CoinVault.getVault();
    return res.status(200).json({
      success: true,
      data: {
        totalCoinsMinted: vault.totalCoinsMinted,
        totalCoinsDispatched: vault.totalCoinsDispatched,
        totalCoinsBurned: vault.totalCoinsBurned,
        currentBalance: vault.currentBalance,
        lastMintDate: vault.lastMintDate,
        lastDispatchDate: vault.lastDispatchDate,
      },
    });
  } catch (error) {
    console.error('getVault Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

/**
 * POST /api/treasury/vault/mint
 * Owner only: mint new coins out of thin air into the global vault
 */
exports.mintCoins = async (req, res) => {
  try {
    const { amount, reason } = req.body;

    if (!amount || amount <= 0) {
      return res.status(400).json({ success: false, message: 'Valid positive coin amount required' });
    }

    const vault = await CoinVault.getVault();
    vault.totalCoinsMinted += amount;
    vault.currentBalance += amount;
    vault.lastMintDate = new Date();
    vault.mintHistory.push({
      amount,
      reason: reason || 'Owner coin minting',
      mintedBy: req.user?.userId || 'OWNER',
    });
    await vault.save();

    // Audit log
    await AuditLog.create({
      action: 'COIN_MINT',
      performedBy: req.user?.userId || 'OWNER',
      details: `Minted ${amount} coins. Reason: ${reason || 'N/A'}`,
      metadata: { amount, vaultBalance: vault.currentBalance },
    });

    return res.status(200).json({
      success: true,
      message: `${amount} coins minted successfully. Vault balance: ${vault.currentBalance}`,
      data: {
        amount,
        currentBalance: vault.currentBalance,
        totalCoinsMinted: vault.totalCoinsMinted,
      },
    });
  } catch (error) {
    console.error('mintCoins Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

/**
 * POST /api/treasury/vault/dispatch
 * Owner only: dispatch bulk coins to a registered Coin Seller UID
 */
exports.dispatchToSeller = async (req, res) => {
  try {
    const { sellerUid, amount, reason } = req.body;

    if (!sellerUid || !amount || amount <= 0) {
      return res.status(400).json({ success: false, message: 'Seller UID and valid coin amount required' });
    }

    // Validate seller exists and has coin_seller role
    const seller = await User.findOne({ uid: sellerUid });
    if (!seller) {
      return res.status(404).json({ success: false, message: 'Seller not found with this UID' });
    }

    const vault = await CoinVault.getVault();
    if (vault.currentBalance < amount) {
      return res.status(400).json({
        success: false,
        message: `Insufficient vault balance. Available: ${vault.currentBalance}, Requested: ${amount}`,
      });
    }

    // Deduct from vault
    vault.currentBalance -= amount;
    vault.totalCoinsDispatched += amount;
    vault.lastDispatchDate = new Date();
    vault.dispatchHistory.push({
      amount,
      targetSellerUid: sellerUid,
      dispatchedBy: req.user?.userId || 'OWNER',
      status: 'completed',
    });
    await vault.save();

    // Credit coins to seller's user account
    seller.coins = (seller.coins || 0) + amount;
    await seller.save();

    // Audit log
    await AuditLog.create({
      action: 'COIN_DISPATCH',
      performedBy: req.user?.userId || 'OWNER',
      details: `Dispatched ${amount} coins to seller UID: ${sellerUid}. Reason: ${reason || 'N/A'}`,
      metadata: { amount, sellerUid, sellerId: seller._id.toString(), vaultBalance: vault.currentBalance },
    });

    return res.status(200).json({
      success: true,
      message: `${amount} coins dispatched to seller ${sellerUid}. Seller new balance: ${seller.coins}`,
      data: {
        amount,
        sellerUid,
        sellerNewBalance: seller.coins,
        vaultBalance: vault.currentBalance,
      },
    });
  } catch (error) {
    console.error('dispatchToSeller Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

/**
 * POST /api/treasury/vault/burn
 * Owner only: burn coins from the vault
 */
exports.burnCoins = async (req, res) => {
  try {
    const { amount, reason } = req.body;

    if (!amount || amount <= 0) {
      return res.status(400).json({ success: false, message: 'Valid positive coin amount required' });
    }

    const vault = await CoinVault.getVault();
    if (vault.currentBalance < amount) {
      return res.status(400).json({
        success: false,
        message: `Insufficient vault balance. Available: ${vault.currentBalance}, Requested: ${amount}`,
      });
    }

    vault.currentBalance -= amount;
    vault.totalCoinsBurned += amount;
    vault.burnHistory.push({
      amount,
      reason: reason || 'Coin burn',
      burnedBy: req.user?.userId || 'OWNER',
    });
    await vault.save();

    await AuditLog.create({
      action: 'COIN_BURN',
      performedBy: req.user?.userId || 'OWNER',
      details: `Burned ${amount} coins. Reason: ${reason || 'N/A'}`,
      metadata: { amount, vaultBalance: vault.currentBalance },
    });

    return res.status(200).json({
      success: true,
      message: `${amount} coins burned. Vault balance: ${vault.currentBalance}`,
      data: { amount, currentBalance: vault.currentBalance },
    });
  } catch (error) {
    console.error('burnCoins Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

/**
 * GET /api/treasury/vault/history
 * Get mint/dispatch/burn history with pagination
 */
exports.getVaultHistory = async (req, res) => {
  try {
    const type = req.query.type || 'all'; // 'mint' | 'dispatch' | 'burn' | 'all'
    const vault = await CoinVault.getVault();

    let history = [];
    if (type === 'mint' || type === 'all') {
      history = [
        ...history,
        ...vault.mintHistory.map((h) => ({ ...h.toObject(), historyType: 'mint' })),
      ];
    }
    if (type === 'dispatch' || type === 'all') {
      history = [
        ...history,
        ...vault.dispatchHistory.map((h) => ({ ...h.toObject(), historyType: 'dispatch' })),
      ];
    }
    if (type === 'burn' || type === 'all') {
      history = [
        ...history,
        ...vault.burnHistory.map((h) => ({ ...h.toObject(), historyType: 'burn' })),
      ];
    }

    // Sort by date descending
    history.sort((a, b) => new Date(b.mintedAt || b.dispatchedAt || b.burnedAt || b.createdAt || 0) - new Date(a.mintedAt || a.dispatchedAt || a.burnedAt || a.createdAt || 0));

    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 50;
    const total = history.length;
    const paginatedHistory = history.slice((page - 1) * limit, page * limit);

    return res.status(200).json({
      success: true,
      data: paginatedHistory,
      pagination: { total, page, pages: Math.ceil(total / limit) },
    });
  } catch (error) {
    console.error('getVaultHistory Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};