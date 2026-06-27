const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const { protect } = require('../middlewares/auth.middleware');
const { requireRole } = require('../middlewares/role.middleware');
const User = require('../models/User.model');

const adminOnly = requireRole(['owner', 'super_admin', 'admin']);
const ownerOnly = requireRole(['owner', 'super_admin']);

// GET /api/staff — List all staff
router.get('/', protect, adminOnly, async (req, res) => {
  try {
    const { search } = req.query;
    const query = { role: { $in: ['admin', 'super_admin', 'moderator', 'support', 'finance', 'content_manager'] } };
    if (search) query.$or = [{ name: new RegExp(search, 'i') }, { email: new RegExp(search, 'i') }];
    const staff = await User.find(query).select('-password').sort({ createdAt: -1 });
    res.json({ success: true, data: staff });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});

// POST /api/staff/create — Add staff member
router.post('/create', protect, ownerOnly, async (req, res) => {
  try {
    const { name, email, phone, role } = req.body;
    const exists = await User.findOne({ email });
    if (exists) return res.status(400).json({ success: false, message: 'Email already exists' });

    const tempPassword = Math.random().toString(36).slice(-8) + 'A1!';
    const hashed = await bcrypt.hash(tempPassword, 12);

    const staff = await User.create({
      name, email, phone, role,
      password: hashed,
      isActive: true,
      username: email.split('@')[0] + '_' + Date.now(),
    });

    // TODO: Send email with tempPassword via nodemailer
    res.json({ success: true, message: `Staff created. Temp password: ${tempPassword}`, data: { _id: staff._id, name, email, role } });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});

// PUT /api/staff/:id/status — Toggle active status
router.put('/:id/status', protect, ownerOnly, async (req, res) => {
  try {
    const { isActive } = req.body;
    await User.findByIdAndUpdate(req.params.id, { isActive });
    res.json({ success: true, message: `Staff ${isActive ? 'activated' : 'deactivated'}` });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});

// PUT /api/staff/:id/role — Change role
router.put('/:id/role', protect, ownerOnly, async (req, res) => {
  try {
    const { role } = req.body;
    await User.findByIdAndUpdate(req.params.id, { role });
    res.json({ success: true, message: 'Role updated' });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});

// DELETE /api/staff/:id
router.delete('/:id', protect, ownerOnly, async (req, res) => {
  try {
    await User.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: 'Staff removed' });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});

module.exports = router;
