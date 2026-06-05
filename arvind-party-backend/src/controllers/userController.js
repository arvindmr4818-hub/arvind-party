const User = require('../models/User');

// GET /api/users/me
exports.getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-__v');
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    return res.json({ success: true, user });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

// PUT /api/users/me
exports.updateMe = async (req, res) => {
  try {
    const allowed = ['name', 'avatar', 'bio', 'gender', 'country'];
    const updates = {};
    allowed.forEach(f => { if (req.body[f] !== undefined) updates[f] = req.body[f]; });

    const user = await User.findByIdAndUpdate(req.user.id, updates, { new: true });
    return res.json({ success: true, user });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

// GET /api/users/:userId — public profile
exports.getUser = async (req, res) => {
  try {
    const user = await User.findOne({ userId: req.params.userId })
      .select('userId name avatar level vipLevel bio country followers following');
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    return res.json({ success: true, user });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

// GET /api/users (admin only)
exports.getAllUsers = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const users = await User.find()
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .select('-__v');

    const total = await User.countDocuments();
    return res.json({ success: true, users, total, page, pages: Math.ceil(total / limit) });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

// PATCH /api/users/:id/block (admin)
exports.blockUser = async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.params.id, { isBlocked: true }, { new: true }
    );
    return res.json({ success: true, user });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

// PATCH /api/users/:id/unblock (admin)
exports.unblockUser = async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.params.id, { isBlocked: false }, { new: true }
    );
    return res.json({ success: true, user });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};
