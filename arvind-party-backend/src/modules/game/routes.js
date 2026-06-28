// =========================================================================
// MODULE: GAME ROUTES
// Merged from: gameRoutes.js, webViewGameRoutes.js, cpRoutes.js
// =========================================================================


// ─── FROM: gameRoutes.js ────────────────────────────────────────
const express = require('express');
const router = express.Router();
const authMiddleware = require('../../middlewares/auth.middleware');

// Import both game controllers
const gameController = require('../../controllers/game.controller');
const gameCtrl = require('../../controllers/gameController');

router.use(authMiddleware); // Strictly secured for logged-in users only

// ─── Lucky Wheel ──────────────────────────────────────────────────────────
router.get('/lucky-wheel/rewards', gameController.getLuckyWheelRewards);
router.post('/lucky-wheel/spin', gameController.spinLuckyWheel);

// ─── Scratch Card ─────────────────────────────────────────────────────────
router.post('/scratch-card/play', gameCtrl.playScratchCard);

// ─── Leaderboard ──────────────────────────────────────────────────────────
router.get('/leaderboard', gameCtrl.getLeaderboard);


// ─── FROM: webViewGameRoutes.js ────────────────────────────────────────
const authMiddleware = require('../../middlewares/auth.middleware');
const webViewGameController = require('../../controllers/webViewGameController');
const isAdmin = require('../../middlewares/isAdmin');

router.use(authMiddleware);

router.get('/games', webViewGameController.getAllGames);
router.get('/games/active', webViewGameController.getActiveGames);
router.get('/games/:gameId', webViewGameController.getGameById);
router.post('/games', isAdmin, webViewGameController.createGame);
router.put('/games/:gameId', isAdmin, webViewGameController.updateGame);
router.delete('/games/:gameId', isAdmin, webViewGameController.deleteGame);
router.post('/games/start-session', webViewGameController.startGameSession);
router.post('/games/end-session', webViewGameController.endGameSession);
router.get('/games/ledger', isAdmin, webViewGameController.getGameLedger);
router.get('/games/leaderboard', webViewGameController.getGameLeaderboard);


// ─── FROM: cpRoutes.js ────────────────────────────────────────
const cpController = require('../../controllers/cpController');
const auth = require('../../middlewares/auth.middleware');

router.get('/mine', auth, cpController.getMyCp);
router.post('/bind', auth, cpController.bindCp);


module.exports = router;
