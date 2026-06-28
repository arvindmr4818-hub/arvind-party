// =========================================================================
// MODULE: NOTIFICATION ROUTES
// Merged from: notificationRoutes.js
// =========================================================================


// ─── FROM: notificationRoutes.js ────────────────────────────────────────
const express = require('express');
const router = express.Router();
const { protect } = require('../../middlewares/auth.middleware');
const { requireRole } = require('../../middlewares/role.middleware');
const Notification = require('../../models/Notification.model');

const adminOnly = requireRole(['owner', 'super_admin', 'admin']);

// GET /api/notifications/admin/history
router.get('/admin/history', protect, adminOnly, async (req, res) => {
  try {
    const history = await Notification.find({ target: { $exists: true } })
      .sort({ createdAt: -1 }).limit(50).lean();
    res.json({ success: true, data: history });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});

// POST /api/notifications/broadcast
router.post('/broadcast', protect, adminOnly, async (req, res) => {
  try {
    const { title, body, target, type } = req.body;
    if (!title || !body) return res.status(400).json({ success: false, message: 'Title and body required' });
    const notif = await Notification.create({ title, body, target: target || 'all', type: type || 'general', sentBy: req.user._id, sentCount: 0 });
    // FCM push would go here
    res.json({ success: true, message: 'Notification sent', data: notif });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});

// GET /api/notifications — User notifications
router.get('/', protect, async (req, res) => {
  try {
    const notifs = await Notification.find({ userId: req.user._id }).sort({ createdAt: -1 }).limit(50).lean();
    res.json({ success: true, data: notifs });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});

// PUT /api/notifications/:id/read
router.put('/:id/read', protect, async (req, res) => {
  try {
    await Notification.findOneAndUpdate({ _id: req.params.id, userId: req.user._id }, { isRead: true });
    res.json({ success: true });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});


module.exports = router;
