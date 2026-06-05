const express = require('express');
const router = express.Router();
const auth = require('../middlewares/authMiddleware');
const Ranking = require('../models/Ranking');

router.get('/', auth, async (req, res) => {
  try {
    const { type = 'sender', period = 'weekly' } = req.query;
    const rankings = await Ranking.find({ rankingType: type, period })
      .sort({ score: -1 }).limit(50)
      .populate('userId', 'name avatar userId level');
    return res.json({ success: true, rankings });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
});

module.exports = router;
