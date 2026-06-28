// =========================================================================
// MODULE: REFERRAL ROUTES
// Merged from: referral.routes.js, inviteRoutes.js, loginStreakRoutes.js, dailyTaskRoutes.js
// =========================================================================


// ─── FROM: referral.routes.js ────────────────────────────────────────
const express = require('express');
const router = express.Router();
const referralController = require('../../controllers/referralController');
const auth = require('../../middlewares/auth.middleware');

router.get('/referral', auth, referralController.getReferralInfo);
router.post('/referral/claim', auth, referralController.claimReward);


// ─── FROM: inviteRoutes.js ────────────────────────────────────────
const inviteEventController = require('../../controllers/inviteEventController');
const auth = require('../../middlewares/auth.middleware');
const adminAuth = require('../../middlewares/isAdmin');

// ─── PUBLIC ROUTES ────────────────────────────────────────────────────
router.post('/generate', auth, inviteEventController.generateInviteLink);
router.post('/register', auth, inviteEventController.registerViaInvite);
router.post('/commission', auth, inviteEventController.processRechargeCommission);
router.get('/my-stats', auth, inviteEventController.getMyInviteStats);

// ─── ADMIN ROUTES ─────────────────────────────────────────────────────
router.get('/admin/all', auth, adminAuth, inviteEventController.adminGetAllInvites);
router.put('/admin/:inviteId/commission', auth, adminAuth, inviteEventController.adminUpdateCommission);


// ─── FROM: loginStreakRoutes.js ────────────────────────────────────────
const loginStreakController = require('../../controllers/loginStreakController');
const auth = require('../../middlewares/auth.middleware');
const adminAuth = require('../../middlewares/isAdmin');

// ─── PUBLIC ROUTES ────────────────────────────────────────────────────
router.get('/my-streak', auth, loginStreakController.getLoginStreak);
router.post('/claim-daily', auth, loginStreakController.claimDailyLogin);

// ─── ADMIN ROUTES ─────────────────────────────────────────────────────
router.get('/admin/all', auth, adminAuth, loginStreakController.adminGetAllStreaks);
router.put('/admin/reset/:userId', auth, adminAuth, loginStreakController.adminResetStreak);


// ─── FROM: dailyTaskRoutes.js ────────────────────────────────────────
const dailyTaskController = require('../../controllers/dailyTaskController');
const auth = require('../../middlewares/auth.middleware');
const adminAuth = require('../../middlewares/isAdmin');

// ─── PUBLIC ROUTES ────────────────────────────────────────────────────
router.get('/active', auth, dailyTaskController.getActiveTasks);
router.put('/:taskId/progress', auth, dailyTaskController.updateTaskProgress);
router.post('/:taskId/claim', auth, dailyTaskController.claimTaskReward);

// ─── ADMIN ROUTES ─────────────────────────────────────────────────────
router.get('/admin/all', auth, adminAuth, dailyTaskController.adminGetAllTasks);
router.post('/admin/create', auth, adminAuth, dailyTaskController.createDailyTask);
router.put('/admin/:id', auth, adminAuth, dailyTaskController.adminUpdateTask);
router.delete('/admin/:id', auth, adminAuth, dailyTaskController.adminDeleteTask);
router.post('/admin/seed', auth, adminAuth, dailyTaskController.seedDefaultTasks);


module.exports = router;
