// ═══════════════════════════════════════════════════════════════════════════
// ROUTE: /api/admin/coin-stats, /api/admin/adjust-coins, /api/admin/bulk-adjust-coins
// OWNER ONLY — Coin Generation & Audit System
// ═══════════════════════════════════════════════════════════════════════════

const express = require('express');
const router = express.Router();
const { protect } = require('../middlewares/auth.middleware');
const { requireRole } = require('../middlewares/role.middleware');
const User = require('../models/User.model');
const CoinAudit = require('../models/CoinAudit.model');

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

module.exports = router;
