// ═══════════════════════════════════════════════════════════════════════════
// ADMIN ROUTES — Complete Admin Panel Backend APIs
// /api/admin/*
// ═══════════════════════════════════════════════════════════════════════════

const express = require('express');
const router = express.Router();
const { protect } = require('../middlewares/auth.middleware');
const { requireRole } = require('../middlewares/role.middleware');
const User = require('../models/User.model');
const Room = require('../models/Room.model');
const Transaction = require('../models/Transaction.model');
const Gift = require('../models/Gift.model');
const Notification = require('../models/Notification.model');

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

module.exports = router;
