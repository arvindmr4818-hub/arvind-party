const express = require('express');
const router = express.Router();
const { protect } = require('../middlewares/auth.middleware');
const { requireRole } = require('../middlewares/role.middleware');
const GameLog = require('../models/GameLog.model');

const adminOnly = requireRole(['owner', 'super_admin', 'admin']);

// GET /api/games/admin/stats
router.get('/admin/stats', protect, adminOnly, async (req, res) => {
  try {
    const [totalPlayed, wonAgg, collectedAgg] = await Promise.all([
      GameLog.countDocuments(),
      GameLog.aggregate([{ $group: { _id: null, total: { $sum: '$winAmount' } } }]),
      GameLog.aggregate([{ $group: { _id: null, total: { $sum: '$betAmount' } } }]),
    ]);
    const coinsCollected = collectedAgg[0]?.total || 0;
    const coinsWon = wonAgg[0]?.total || 0;
    const houseEdge = coinsCollected > 0 ? Math.round(((coinsCollected - coinsWon) / coinsCollected) * 100) : 0;
    res.json({ success: true, data: { totalPlayed, coinsWon, coinsCollected, houseEdge } });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});

// GET /api/games/admin/logs
router.get('/admin/logs', protect, adminOnly, async (req, res) => {
  try {
    const logs = await GameLog.find()
      .populate('userId', 'name')
      .sort({ createdAt: -1 }).limit(100).lean();
    const mapped = logs.map(l => ({ ...l, userName: l.userId?.name || 'Unknown' }));
    res.json({ success: true, data: mapped });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});

module.exports = router;
