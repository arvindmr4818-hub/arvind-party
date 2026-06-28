// =========================================================================
// MODULE: AGENCY ROUTES
// Merged from: agencyRoutes.js, agentRoutes.js, salaryRoutes.js, attendanceRoutes.js, bonusRoutes.js, penaltyRoutes.js, reportsRoutes.js, agencyInvitationRoutes.js
// =========================================================================


// ─── FROM: agencyRoutes.js ────────────────────────────────────────
const express = require('express');
const router = express.Router();
const auth = require('../../middlewares/auth.middleware');
const agencyController = require('../../controllers/agencyController');

// All agency routes require authentication
router.use(auth);

// GET  /api/agency          — Get current user's agency info
router.get('/', agencyController.getMyAgency);

// POST /api/agency/create   — Create a new agency
router.post('/create', agencyController.createAgency);

// GET  /api/agency/hosts    — List agency members/hosts
router.get('/hosts', agencyController.listHosts);

// GET  /api/agency/earnings — Get agency earnings
router.get('/earnings', agencyController.getEarnings);

// POST /api/agency/apply    — Apply/join an agency
router.post('/apply', agencyController.applyForAgency);


// ─── FROM: agentRoutes.js ────────────────────────────────────────
const auth = require('../../middlewares/auth.middleware');
const agentController = require('../../controllers/agentController');

router.use(auth);

router.post('/agents/add', agentController.addAgent);
router.get('/agents', agentController.listAgents);
router.put('/agents/:agentId', agentController.updateAgent);
router.delete('/agents/:agentId', agentController.deleteAgent);
router.get('/agents/:agentId/performance', agentController.getAgentPerformance);


// ─── FROM: salaryRoutes.js ────────────────────────────────────────
const auth = require('../../middlewares/auth.middleware');
const salaryController = require('../../controllers/salaryController');

router.use(auth);

router.get('/salary/history', salaryController.getSalaryHistory);
router.get('/salary/detail/:hostId', salaryController.getHostSalaryDetail);
router.post('/salary/calculate-monthly/:agencyId', salaryController.calculateMonthlySalary);


// ─── FROM: attendanceRoutes.js ────────────────────────────────────────
const auth = require('../../middlewares/auth.middleware');
const attendanceController = require('../../controllers/attendanceController');
const io = require('../../server').io;

attendanceController.ioInstance = io;

router.use(auth);

router.post('/attendance/start', attendanceController.startSession);
router.post('/attendance/end', attendanceController.endSession);
router.get('/attendance/live', attendanceController.getLiveAttendance);
router.get('/attendance/monthly', attendanceController.getMonthlyAttendance);
router.get('/attendance/history/:hostId', attendanceController.getHostAttendanceHistory);


// ─── FROM: bonusRoutes.js ────────────────────────────────────────
const auth = require('../../middlewares/auth.middleware');
const bonusController = require('../../controllers/bonusController');

router.use(auth);

router.post('/bonus/award', bonusController.awardBonus);
router.get('/bonus/history/:hostId', bonusController.getHostBonuses);
router.get('/bonus/summary', bonusController.getMonthlyBonusSummary);
router.delete('/bonus/:bonusId', bonusController.removeBonus);


// ─── FROM: penaltyRoutes.js ────────────────────────────────────────
const auth = require('../../middlewares/auth.middleware');
const penaltyController = require('../../controllers/penaltyController');

router.use(auth);

router.post('/penalty/apply', penaltyController.applyPenalty);
router.get('/penalty/history/:hostId', penaltyController.getHostPenalties);
router.delete('/penalty/:penaltyId', penaltyController.removePenalty);
router.get('/penalty/summary', penaltyController.getMonthlyPenaltySummary);


// ─── FROM: reportsRoutes.js ────────────────────────────────────────
const auth = require('../../middlewares/auth.middleware');
const reportsController = require('../../controllers/reportsController');

router.use(auth);

router.get('/reports/realtime', reportsController.getRealtimeAnalytics);
router.get('/reports/monthly', reportsController.getMonthlyReport);
router.get('/reports/daily-chart', reportsController.getDailyChartData);
router.get('/reports/host-ranking', reportsController.getHostRanking);


// ─── FROM: agencyInvitationRoutes.js ────────────────────────────────────────
const agencyInvitationController = require('../../controllers/agencyInvitationController');
const { authMiddleware } = require('../../middlewares/auth.middleware');

// ─────────────────────────────────────────────────────────────────────────
// AGENCY INVITATION ROUTES
// ─────────────────────────────────────────────────────────────────────────

// Send invitation to user by UID
router.post('/invitations/send', authMiddleware, agencyInvitationController.sendInvitation);

// Get my inbox (pending invitations)
router.get('/invitations/inbox', authMiddleware, agencyInvitationController.getInbox);

// Accept invitation
router.post('/invitations/accept/:invitationId', authMiddleware, agencyInvitationController.acceptInvitation);

// Reject invitation
router.post('/invitations/reject/:invitationId', authMiddleware, agencyInvitationController.rejectInvitation);

// Search user by UID
router.get('/users/search', authMiddleware, agencyInvitationController.searchUserByUid);

// Get all notifications/inbox
router.get('/inbox', authMiddleware, agencyInvitationController.getNotifications);

// Mark notification as read
router.post('/notifications/read/:notificationId', authMiddleware, agencyInvitationController.markNotificationRead);

// Mark all notifications as read
router.post('/notifications/read-all', authMiddleware, agencyInvitationController.markAllNotificationsRead);


module.exports = router;
