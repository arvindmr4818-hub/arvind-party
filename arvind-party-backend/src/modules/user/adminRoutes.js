// ═══════════════════════════════════════════════════════════════════════════
// USER ADMIN ROUTES — /api/users/admin/*
// ═══════════════════════════════════════════════════════════════════════════
const express = require('express');
const router = express.Router();
const { protect } = require('../../middlewares/auth.middleware');
const { requireRole } = require('../../middlewares/role.middleware');
const User = require('../../models/User');

const adminOnly = requireRole(['owner', 'super_admin', 'admin', 'moderator']);

// GET /api/users/admin/list
router.get('/admin/list', protect, adminOnly, async (req, res) => {
  try {
    const { search, status, page = 1, limit = 20 } = req.query;
    const query = { role: 'user' };
    if (search) {
      query.$or = [
        { name: new RegExp(search, 'i') },
        { phone: new RegExp(search, 'i') },
        { arvindId: new RegExp(search, 'i') },
        { email: new RegExp(search, 'i') },
      ];
    }
    if (status === 'banned') query.isBanned = true;
    if (status === 'active') query.isBanned = { $ne: true };
    if (status === 'vip') query.vipLevel = { $gt: 0 };

    const users = await User.find(query)
      .select('name phone email arvindId coins diamonds vipLevel isBanned createdAt lastLoginAt avatar')
      .sort({ createdAt: -1 })
      .skip((parseInt(page) - 1) * parseInt(limit))
      .limit(parseInt(limit))
      .lean();

    res.json({ success: true, data: users });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// GET /api/users/admin/stats
router.get('/admin/stats', protect, adminOnly, async (req, res) => {
  try {
    const today = new Date(); today.setHours(0,0,0,0);
    const week = new Date(); week.setDate(week.getDate() - 7);
    const [total, newToday, active7d, banned] = await Promise.all([
      User.countDocuments({ role: 'user' }),
      User.countDocuments({ role: 'user', createdAt: { $gte: today } }),
      User.countDocuments({ role: 'user', lastLoginAt: { $gte: week } }),
      User.countDocuments({ role: 'user', isBanned: true }),
    ]);
    res.json({ success: true, data: { total, newToday, active7d, banned } });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;
