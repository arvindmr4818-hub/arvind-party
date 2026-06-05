const express = require('express');
const router = express.Router();
const auth = require('../middlewares/authMiddleware');
const Gift = require('../models/Gift');

// GET all active gifts
router.get('/', auth, async (req, res) => {
  try {
    const gifts = await Gift.find({ isActive: true }).sort({ price: 1 });
    return res.json({ success: true, gifts });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
});

module.exports = router;
