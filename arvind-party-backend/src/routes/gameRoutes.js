const express = require('express');
const router = express.Router();
const gameController = require('../controllers/game.controller');
const authMiddleware = require('../middlewares/auth.middleware');

router.use(authMiddleware); // Strictly secured for logged-in users only

router.get('/lucky-wheel/rewards', gameController.getLuckyWheelRewards);
router.post('/lucky-wheel/spin', gameController.spinLuckyWheel);

module.exports = router;