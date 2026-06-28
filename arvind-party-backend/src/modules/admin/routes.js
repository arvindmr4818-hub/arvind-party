// =========================================================================
// MODULE: ADMIN ROUTES
// Merged from: adminRoutes.js, adminAuthRoutes.js, coinAdminRoutes.js, staffRoutes.js
// =========================================================================


// ─── FROM: adminRoutes.js ────────────────────────────────────────
const express = require('express');
const router = express.Router();
// ADMIN ROUTES — Complete Admin Panel Backend APIs
// /api/admin/*

const { protect } = require('../../middlewares/auth.middleware');
const { requireRole } = require('../../middlewares/role.middleware');
const User = require('../../models/User.model');
const Room = require('../../models/Room.model');
const Transaction = require('../../models/Transaction.model');
const Gift = require('../../models/Gift.model');
const Notification = require('../../models/Notification.model');

const adminOnly = requireRole(['owner', 'super_admin', 'admin']);
const ownerOnly = requireRole(['owner', 'super_admin']);

// ─── DASHBOARD STATS ─────────────────────────────────────────────────────
router.get('/dashboard-stats', protect, adminOnly, async (req, res) => {
  try {
    const today = new Date(); today.setHours(0,0,0,0);
    const [totalUsers, newToday, activeRooms, totalRevenue, pendingWithdrawals] = await Promise.all([
      User.countDocuments({ role: 'user' }),
      User.countDocuments({ role: 'user', createdAt: { $gte: today } }),
      Room.countDocuments({ isLive: true }),
      Transaction.aggregate([{ $match: { type: 'recharge', status: 'completed' } }, { $group: { _id: null, total: { $sum: '$amount' } } }]),
      Transaction.countDocuments({ type: 'withdrawal', status: 'pending' }),
    ]);
    res.json({ success: true, data: {
      totalUsers, newToday, activeRooms,
      totalRevenue: totalRevenue[0]?.total || 0,
      pendingWithdrawals,
    }});
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});

// ─── APP CONFIG ──────────────────────────────────────────────────────────
let appConfig = {
  appName: 'Arvind Party', supportEmail: 'support@arvindparty.com',
  minAge: 16, maintenanceMode: false, registrationOpen: true,
  gamesEnabled: true, giftsEnabled: true,
};

router.get('/app-config', protect, adminOnly, (req, res) => {
  res.json({ success: true, data: appConfig });
});

router.put('/app-config', protect, ownerOnly, (req, res) => {
  appConfig = { ...appConfig, ...req.body };
  res.json({ success: true, message: 'Config updated', data: appConfig });
});

// ─── WALLET CONFIG ───────────────────────────────────────────────────────
let walletConfig = { diamondToCoinRate: 10, minWithdrawal: 500 };

router.get('/wallet-config', protect, adminOnly, (req, res) => {
  res.json({ success: true, data: walletConfig });
});

router.put('/wallet-config', protect, ownerOnly, (req, res) => {
  walletConfig = { ...walletConfig, ...req.body };
  res.json({ success: true, message: 'Wallet config updated', data: walletConfig });
});

// ─── REPORTS ─────────────────────────────────────────────────────────────
router.get('/reports/revenue', protect, adminOnly, async (req, res) => {
  try {
    const { period = '7d' } = req.query;
    const days = period === '1y' ? 365 : period === '90d' ? 90 : period === '30d' ? 30 : 7;
    const startDate = new Date(); startDate.setDate(startDate.getDate() - days);

    const [total, recharge, prevPeriod] = await Promise.all([
      Transaction.aggregate([{ $match: { type: 'recharge', status: 'completed', createdAt: { $gte: startDate } } }, { $group: { _id: null, total: { $sum: '$amount' } } }]),
      Transaction.aggregate([{ $match: { type: 'recharge', status: 'completed', createdAt: { $gte: startDate } } }, { $group: { _id: null, total: { $sum: '$amount' } } }]),
      Transaction.aggregate([{
        $match: { type: 'recharge', status: 'completed',
          createdAt: { $gte: new Date(startDate.getTime() - days * 86400000), $lt: startDate } }
      }, { $group: { _id: null, total: { $sum: '$amount' } } }]),
    ]);

    const totalVal = total[0]?.total || 0;
    const prevVal = prevPeriod[0]?.total || 1;
    const growth = Math.round(((totalVal - prevVal) / prevVal) * 100);

    res.json({ success: true, data: {
      total: totalVal, recharge: recharge[0]?.total || 0,
      avgPerDay: Math.round(totalVal / days), growth,
      breakdown: [
        { label: 'Recharge', amount: recharge[0]?.total || 0, percent: 0.7 },
        { label: 'Gifts', amount: Math.round(totalVal * 0.2), percent: 0.2 },
        { label: 'Other', amount: Math.round(totalVal * 0.1), percent: 0.1 },
      ],
    }});
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});

router.get('/reports/users', protect, adminOnly, async (req, res) => {
  try {
    const { period = '7d' } = req.query;
    const days = period === '1y' ? 365 : period === '90d' ? 90 : period === '30d' ? 30 : 7;
    const startDate = new Date(); startDate.setDate(startDate.getDate() - days);
    const activeDate = new Date(); activeDate.setDate(activeDate.getDate() - 7);

    const [newUsers, activeUsers, totalUsers] = await Promise.all([
      User.countDocuments({ role: 'user', createdAt: { $gte: startDate } }),
      User.countDocuments({ role: 'user', lastLoginAt: { $gte: activeDate } }),
      User.countDocuments({ role: 'user' }),
    ]);
    const churned = Math.max(0, totalUsers - activeUsers);
    const retention = totalUsers > 0 ? Math.round((activeUsers / totalUsers) * 100) : 0;

    res.json({ success: true, data: { newUsers, activeUsers, churned, retention } });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});

router.get('/reports/gifts', protect, adminOnly, async (req, res) => {
  try {
    res.json({ success: true, data: { topGifts: [] } });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});

// ─── BROADCAST NOTIFICATION ──────────────────────────────────────────────
router.post('/broadcast', protect, adminOnly, async (req, res) => {
  try {
    const { title, body, target } = req.body;
    if (!title || !body) return res.status(400).json({ success: false, message: 'Title and body required' });

    let query = { role: 'user' };
    if (target === 'vip') query.vipLevel = { $gt: 0 };
    if (target === 'active') {
      const activeDate = new Date(); activeDate.setDate(activeDate.getDate() - 7);
      query.lastLoginAt = { $gte: activeDate };
    }

    const count = await User.countDocuments(query);
    await Notification.create({ title, body, target, sentCount: count, sentBy: req.user._id });

    res.json({ success: true, message: `Notification queued for ${count} users`, data: { sentCount: count } });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});

// ─── ADJUST USER BALANCE ─────────────────────────────────────────────────
router.post('/adjust-user-balance', protect, adminOnly, async (req, res) => {
  try {
    const { userId, coins, diamonds, reason } = req.body;
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    if (coins) user.coins = Math.max(0, (user.coins || 0) + coins);
    if (diamonds) user.diamonds = Math.max(0, (user.diamonds || 0) + diamonds);
    await user.save();
    res.json({ success: true, message: 'Balance updated', data: { coins: user.coins, diamonds: user.diamonds } });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});

// ─── BAN / UNBAN USER ────────────────────────────────────────────────────
router.post('/users/:id/ban', protect, adminOnly, async (req, res) => {
  try {
    const { reason } = req.body;
    await User.findByIdAndUpdate(req.params.id, { isBanned: true, banReason: reason, bannedAt: new Date() });
    res.json({ success: true, message: 'User banned' });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});

router.post('/users/:id/unban', protect, adminOnly, async (req, res) => {
  try {
    await User.findByIdAndUpdate(req.params.id, { isBanned: false, banReason: null });
    res.json({ success: true, message: 'User unbanned' });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});


// ─── FROM: adminAuthRoutes.js ────────────────────────────────────────
// ROUTE: Admin Login — /api/auth/admin-login

const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../../models/User.model');
const Logger = require('../../utils/logger');

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


// ─── FROM: coinAdminRoutes.js ────────────────────────────────────────
// ROUTE: /api/admin/coin-stats, /api/admin/adjust-coins, /api/admin/bulk-adjust-coins
// OWNER ONLY — Coin Generation & Audit System

const { protect } = require('../../middlewares/auth.middleware');
const { requireRole } = require('../../middlewares/role.middleware');
const User = require('../../models/User.model');
const CoinAudit = require('../../models/CoinAudit.model');

// ─── OWNER ONLY MIDDLEWARE ────────────────────────────────────────────────
const ownerOnly = requireRole(['owner', 'super_admin']);

// GET /api/admin/coin-stats
router.get('/coin-stats', protect, ownerOnly, async (req, res) => {
  try {
    const [totalCoins, totalDiamonds, todayAudit, deductAudit] = await Promise.all([
      User.aggregate([{ $group: { _id: null, total: { $sum: '$coins' } } }]),
      User.aggregate([{ $group: { _id: null, total: { $sum: '$diamonds' } } }]),
      CoinAudit.aggregate([
        { $match: { createdAt: { $gte: new Date(new Date().setHours(0,0,0,0)) }, amount: { $gt: 0 } } },
        { $group: { _id: null, total: { $sum: '$amount' } } }
      ]),
      CoinAudit.aggregate([
        { $match: { amount: { $lt: 0 } } },
        { $group: { _id: null, total: { $sum: '$amount' } } }
      ]),
    ]);
    res.json({
      success: true,
      data: {
        totalCoinsIssued: totalCoins[0]?.total || 0,
        totalDiamonds: totalDiamonds[0]?.total || 0,
        todayIssued: todayAudit[0]?.total || 0,
        totalDeducted: Math.abs(deductAudit[0]?.total || 0),
      }
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// POST /api/admin/adjust-coins
router.post('/adjust-coins', protect, ownerOnly, async (req, res) => {
  try {
    const { userId, amount, type, reason, action } = req.body;
    if (!userId || !amount || !reason) {
      return res.status(400).json({ success: false, message: 'userId, amount, reason required' });
    }

    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });

    if (type === 'diamonds') {
      user.diamonds = Math.max(0, (user.diamonds || 0) + amount);
    } else {
      user.coins = Math.max(0, (user.coins || 0) + amount);
    }
    await user.save();

    // Audit log
    await CoinAudit.create({
      adminId: req.user._id,
      adminName: req.user.name,
      userId: user._id,
      userName: user.name,
      amount,
      type: type || 'coins',
      reason,
      action: action || (amount > 0 ? 'add' : 'deduct'),
    });

    res.json({ success: true, message: `${Math.abs(amount)} ${type} ${amount > 0 ? 'added to' : 'deducted from'} ${user.name}`, data: { newBalance: type === 'diamonds' ? user.diamonds : user.coins } });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// POST /api/admin/bulk-adjust-coins
router.post('/bulk-adjust-coins', protect, ownerOnly, async (req, res) => {
  try {
    const { userIds, amount, type, reason } = req.body;
    if (!userIds?.length || !amount) return res.status(400).json({ success: false, message: 'userIds and amount required' });

    const field = type === 'diamonds' ? 'diamonds' : 'coins';
    await User.updateMany({ _id: { $in: userIds } }, { $inc: { [field]: amount } });

    const audits = userIds.map(uid => ({
      adminId: req.user._id, adminName: req.user.name,
      userId: uid, userName: 'Bulk', amount, type: type || 'coins',
      reason: reason || 'Bulk distribution', action: 'add',
    }));
    await CoinAudit.insertMany(audits);

    res.json({ success: true, message: `${amount} ${type} added to ${userIds.length} users` });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// GET /api/admin/coin-audit
router.get('/coin-audit', protect, ownerOnly, async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 50;
    const logs = await CoinAudit.find().sort({ createdAt: -1 }).limit(limit).lean();
    res.json({ success: true, data: logs });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});


// ─── FROM: staffRoutes.js ────────────────────────────────────────
const { verifyOwner } = require('../../middlewares/adminMiddleware');
const staffController = require('../../controllers/staffController');

// 🌐 PUBLIC STAFF ROUTE
router.post('/login', staffController.loginStaff);

// ⚠️ STRICTLY OWNER ONLY ROUTE
router.post('/create', verifyOwner, staffController.createStaff);
router.get('/list', verifyOwner, staffController.getStaffList);
router.put('/update/:id', verifyOwner, staffController.updateStaff);
router.delete('/delete/:id', verifyOwner, staffController.deleteStaff);

// POST /api/admin/staff/change-password/:id - Owner force password change (bypasses lock)
router.post('/change-password/:id', verifyAdmin, staffController.changeStaffPassword);

// GET /api/admin/staff/roles - Get role hierarchy
router.get('/roles', staffController.getAdminRoles);


module.exports = router;
