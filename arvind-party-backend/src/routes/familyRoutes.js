const express = require('express');
const router = express.Router();
const auth = require('../middlewares/authMiddleware');

// Placeholder — Family model baad mein banana
router.get('/mine', auth, async (req, res) => {
  return res.json({ success: true, family: null });
});

router.post('/', auth, async (req, res) => {
  return res.json({ success: false, message: 'Family system coming soon' });
});

module.exports = router;
