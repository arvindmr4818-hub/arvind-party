const express = require('express');
const router = express.Router();
const auth = require('../middlewares/authMiddleware');

router.get('/mine', auth, async (req, res) => {
  return res.json({ success: true, agency: null });
});

module.exports = router;
