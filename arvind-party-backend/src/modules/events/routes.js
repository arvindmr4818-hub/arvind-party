// =========================================================================
// MODULE: EVENTS ROUTES
// Merged from: eventRoutes.js, tournamentRoutes.js, luckyDrawRoutes.js, treasureHuntRoutes.js
// =========================================================================


// ─── FROM: eventRoutes.js ────────────────────────────────────────
const express = require('express');
const router = express.Router();
const EventController = require('../../controllers/eventController');
const { authenticateUser, adminOnly } = require('../../middlewares/auth');

router.use(authenticateUser);

router.get('/active', EventController.getActiveEvents);
router.get('/dashboard', EventController.getUserEventsDashboard);
router.get('/history', EventController.getUserEventHistory);
router.get('/stats', EventController.getEventStats);
router.get('/:eventId', EventController.getEventDetails);
router.post('/:eventId/join', EventController.joinEvent);
router.post('/:eventId/leave', EventController.leaveEvent);
router.post('/:eventId/claim', EventController.claimEventReward);
router.post('/:eventId/progress', EventController.updateProgress);
router.get('/:eventId/tournament/standings', EventController.getTournamentStandings);
router.get('/:eventId/prize-pool', EventController.getEventPrizePool);

router.use(adminOnly);

router.get('/admin/list', EventController.getAllEventsAdmin);
router.post('/admin/create', EventController.createEvent);
router.put('/admin/:eventId', EventController.updateEvent);
router.delete('/admin/:eventId', EventController.deleteEvent);
router.patch('/admin/:eventId/prize-pool', EventController.updateEventPrizePool);
router.get('/admin/welcome-week/tasks', EventController.getWelcomeWeekTasks);
router.post('/admin/welcome-week/tasks', EventController.createWelcomeWeekTask);
router.put('/admin/welcome-week/tasks/:taskId', EventController.updateWelcomeWeekTask);
router.get('/admin/festival/gifts', EventController.getFestivalGifts);
router.post('/admin/festival/gifts', EventController.createFestivalGift);
router.get('/admin/anniversary/rewards', EventController.getAnniversaryRewards);
router.post('/admin/anniversary/rewards', EventController.createAnniversaryReward);
router.post('/admin/:eventId/inject-gifts', EventController.injectFestivalGifts);


// ─── FROM: tournamentRoutes.js ────────────────────────────────────────
const tournamentController = require('../../controllers/tournamentController');
const championshipController = require('../../controllers/championshipController');
const auth = require('../../middlewares/auth.middleware');
const adminAuth = require('../../middlewares/isAdmin');

// ─── TOURNAMENT ROUTES ──────────────────────────────────────────────────
router.post('/create', auth, adminAuth, tournamentController.createTournament);
router.get('/list', auth, tournamentController.getTournaments);
router.get('/:tournamentId', auth, tournamentController.getTournamentById);
router.post('/:tournamentId/register', auth, tournamentController.registerForTournament);
router.post('/:tournamentId/score', auth, tournamentController.updateTournamentScore);
router.post('/:tournamentId/complete', auth, adminAuth, tournamentController.completeTournament);
router.get('/:tournamentId/leaderboard', auth, tournamentController.getTournamentLeaderboard);
router.get('/admin/all', auth, adminAuth, tournamentController.adminGetAllTournaments);

// ─── CHAMPIONSHIP ROUTES ────────────────────────────────────────────────
router.post('/championship/create', auth, adminAuth, championshipController.createChampionship);
router.get('/championship/list', auth, championshipController.getChampionships);
router.get('/championship/:championshipId', auth, championshipController.getChampionshipById);
router.post('/championship/:championshipId/qualify', auth, championshipController.qualifyForChampionship);
router.post('/championship/:championshipId/complete', auth, adminAuth, championshipController.completeChampionship);
router.get('/championship/:championshipId/leaderboard', auth, championshipController.getChampionshipLeaderboard);
router.post('/championship/:championshipId/claim', auth, championshipController.claimChampionshipRewards);
router.get('/championship/admin/all', auth, adminAuth, championshipController.adminGetAllChampionships);


// ─── FROM: luckyDrawRoutes.js ────────────────────────────────────────
const luckyDrawController = require('../../controllers/luckyDrawController');
const auth = require('../../middlewares/auth.middleware');
const adminAuth = require('../../middlewares/isAdmin');

// ─── PUBLIC ROUTES ────────────────────────────────────────────────────
router.get('/active', auth, luckyDrawController.getActiveLuckyDraws);
router.get('/:id', auth, luckyDrawController.getLuckyDrawById);
router.post('/:drawId/spin', auth, luckyDrawController.spinWheel);

// ─── ADMIN ROUTES ─────────────────────────────────────────────────────
router.get('/admin/all', auth, adminAuth, luckyDrawController.adminGetAll);
router.post('/admin/create', auth, adminAuth, luckyDrawController.createLuckyDraw);
router.put('/admin/:id', auth, adminAuth, luckyDrawController.updateLuckyDraw);
router.delete('/admin/:id', auth, adminAuth, luckyDrawController.deleteLuckyDraw);


// ─── FROM: treasureHuntRoutes.js ────────────────────────────────────────
const treasureHuntController = require('../../controllers/treasureHuntController');
const auth = require('../../middlewares/auth.middleware');
const adminAuth = require('../../middlewares/isAdmin');

// ─── TREASURE HUNT ROUTES ──────────────────────────────────────────────
router.post('/create', auth, adminAuth, treasureHuntController.createTreasureHunt);
router.get('/list', auth, treasureHuntController.getTreasureHunts);
router.get('/active', auth, treasureHuntController.getActiveTreasureHunt);
router.get('/:huntId', auth, treasureHuntController.getTreasureHuntById);
router.post('/:huntId/collect-key', auth, treasureHuntController.collectTreasureKey);
router.get('/admin/all', auth, adminAuth, treasureHuntController.adminGetAllTreasureHunts);


module.exports = router;
