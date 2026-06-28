// =========================================================================
// MODULE: INFRASTRUCTURE ROUTES
// Merged from: infrastructureRoutes.js, moduleManagerRoutes.js
// =========================================================================


// ─── FROM: infrastructureRoutes.js ────────────────────────────────────────
const express = require('express');
const router = express.Router();
const AutoScalingService = require('../../services/autoScalingService');
const CDNService = require('../../services/cdnService');
const BackupService = require('../../services/backupService');
const ErrorReportingService = require('../../services/errorReportingService');
const AuditLogService = require('../../services/auditLogService');
const HealthAlertService = require('../../services/healthAlertService');
const DeploymentService = require('../../services/deploymentService');
const FeatureFlagService = require('../../services/featureFlagService');
const MonitoringService = require('../../services/monitoringService');
const { isAdmin } = require('../../middlewares/isAdmin');
const { normalizeReq } = require('../../utils/requestParser');

router.use(isAdmin);

router.get('/metrics', (req, res) => {
  try {
    const metrics = MonitoringService.getMetrics();
    const health = MonitoringService.getHealthStatus();
    res.json({ success: true, data: { metrics, health } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch metrics', error: error.message });
  }
});

router.get('/monitoring/health', (req, res) => {
  try {
    const services = {
      monitoring: MonitoringService.getHealthStatus(),
      cdn: CDNService.getHealthStatus(),
      backup: BackupService.getBackupStats(),
      errorReporting: ErrorReportingService.getHealthStatus(),
      auditLog: AuditLogService.getStats(),
      healthAlerts: HealthAlertService.getHealthStatus(),
      deployment: DeploymentService.getHealthStatus(),
      featureFlags: FeatureFlagService.getHealthStatus()
    };

    const overallStatus = Object.values(services).every(s => s.status === 'healthy' || s.status === 'disabled' || !s.status)
      ? 'healthy'
      : 'degraded';

    res.json({ success: true, data: { status: overallStatus, services } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch health status', error: error.message });
  }
});

router.get('/scaling/stats', (req, res) => {
  try {
    const stats = AutoScalingService.getScalingStats();
    res.json({ success: true, data: stats });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch scaling stats', error: error.message });
  }
});

router.post('/scaling/manual', (req, res) => {
  try {
    const { direction } = req.body;
    if (!['up', 'down'].includes(direction)) {
      return res.status(400).json({ success: false, message: 'Invalid direction. Use up or down' });
    }
    AutoScalingService.manualScale(direction);
    res.json({ success: true, message: `Manual scale ${direction} triggered` });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Manual scale failed', error: error.message });
  }
});

router.post('/cdn/upload', async (req, res) => {
  try {
    const { file, options } = req.body;
    const result = await CDNService.uploadAsset(file, options);
    res.json({ success: true, data: result });
  } catch (error) {
    res.status(500).json({ success: false, message: 'CDN upload failed', error: error.message });
  }
});

router.delete('/cdn/asset/:publicId', async (req, res) => {
  try {
    const { publicId } = req.params;
    const { resourceType } = req.query;
    const result = await CDNService.deleteAsset(publicId, resourceType || 'image');
    res.json({ success: true, data: result });
  } catch (error) {
    res.status(500).json({ success: false, message: 'CDN delete failed', error: error.message });
  }
});

router.get('/cdn/stats', (req, res) => {
  try {
    const stats = CDNService.getStats();
    res.json({ success: true, data: stats });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch CDN stats', error: error.message });
  }
});

router.get('/backup/history', (req, res) => {
  try {
    const history = BackupService.getBackupHistory();
    res.json({ success: true, data: history });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch backup history', error: error.message });
  }
});

router.post('/backup/create', async (req, res) => {
  try {
    const result = await BackupService.createBackup();
    res.json({ success: true, data: result });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Backup creation failed', error: error.message });
  }
});

router.post('/backup/restore/:backupId', async (req, res) => {
  try {
    const { backupId } = req.params;
    const result = await BackupService.restoreBackup(backupId);
    res.json({ success: true, data: result });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Backup restore failed', error: error.message });
  }
});

router.get('/errors/recent', (req, res) => {
  try {
    const { duration } = req.query;
    const durationMs = duration ? parseInt(duration) : 3600000;
    const errors = ErrorReportingService.getRecentErrors(durationMs);
    res.json({ success: true, data: errors });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch errors', error: error.message });
  }
});

router.get('/errors/stats', (req, res) => {
  try {
    const stats = ErrorReportingService.getErrorStats();
    res.json({ success: true, data: stats });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch error stats', error: error.message });
  }
});

router.post('/errors/:errorId/ai-resolution', async (req, res) => {
  try {
    const { errorId } = req.params;
    const solution = await ErrorReportingService.generateAIResolution(errorId);
    res.json({ success: true, data: { solution } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'AI resolution failed', error: error.message });
  }
});

router.post('/errors/:errorId/resolve', (req, res) => {
  try {
    const { errorId } = req.params;
    const { resolution } = req.body;
    const success = ErrorReportingService.resolveError(errorId, resolution);
    res.json({ success, message: success ? 'Error resolved' : 'Error not found' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to resolve error', error: error.message });
  }
});

router.get('/audit/logs', async (req, res) => {
  try {
    const filters = {
      userId: req.query.userId,
      action: req.query.action,
      resourceType: req.query.resourceType,
      severity: req.query.severity,
      startDate: req.query.startDate,
      endDate: req.query.endDate,
      search: req.query.search
    };
    const pagination = {
      page: parseInt(req.query.page) || 1,
      limit: parseInt(req.query.limit) || 50
    };
    const result = await AuditLogService.query(filters, pagination);
    res.json({ success: true, data: result });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch audit logs', error: error.message });
  }
});

router.get('/audit/activity-report', async (req, res) => {
  try {
    const { duration } = req.query;
    const durationMs = duration ? parseInt(duration) : 86400000;
    const report = await AuditLogService.getActivityReport(durationMs);
    res.json({ success: true, data: report });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch activity report', error: error.message });
  }
});

router.get('/audit/suspicious', async (req, res) => {
  try {
    const { duration } = req.query;
    const durationMs = duration ? parseInt(duration) : 3600000;
    const suspicious = await AuditLogService.getSuspiciousActivity(durationMs);
    res.json({ success: true, data: suspicious });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch suspicious activity', error: error.message });
  }
});

router.get('/alerts/active', (req, res) => {
  try {
    const alerts = HealthAlertService.getActiveAlerts();
    res.json({ success: true, data: alerts });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch active alerts', error: error.message });
  }
});

router.get('/alerts/history', (req, res) => {
  try {
    const { limit } = req.query;
    const history = HealthAlertService.getAlertHistory(limit ? parseInt(limit) : 50);
    res.json({ success: true, data: history });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch alert history', error: error.message });
  }
});

router.post('/alerts/:alertId/acknowledge', (req, res) => {
  try {
    const { alertId } = req.params;
    const success = HealthAlertService.acknowledgeAlert(alertId);
    res.json({ success, message: success ? 'Alert acknowledged' : 'Alert not found' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to acknowledge alert', error: error.message });
  }
});

router.post('/alerts/:alertId/resolve', (req, res) => {
  try {
    const { alertId } = req.params;
    const success = HealthAlertService.resolveAlert(alertId);
    res.json({ success, message: success ? 'Alert resolved' : 'Alert not found' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to resolve alert', error: error.message });
  }
});

router.post('/deploy', async (req, res) => {
  try {
    const result = await DeploymentService.deploy('manual');
    res.json(result);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Deployment failed', error: error.message });
  }
});

router.post('/deploy/rollback', async (req, res) => {
  try {
    const { targetVersion } = req.body;
    const result = await DeploymentService.rollback(targetVersion);
    res.json(result);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Rollback failed', error: error.message });
  }
});

router.get('/deploy/history', (req, res) => {
  try {
    const { limit } = req.query;
    const history = DeploymentService.getDeploymentHistory(limit ? parseInt(limit) : 20);
    res.json({ success: true, data: history });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch deployment history', error: error.message });
  }
});

router.get('/feature-flags', (req, res) => {
  try {
    const { environment } = req.query;
    const flags = environment ? FeatureFlagService.getFlagsByEnvironment(environment) : FeatureFlagService.getAllFlags();
    res.json({ success: true, data: flags });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch feature flags', error: error.message });
  }
});

router.post('/feature-flags', (req, res) => {
  try {
    const flagData = req.body;
    const createdBy = req.user?.userId || 'admin';
    const flag = FeatureFlagService.createFlag(flagData, createdBy);
    res.json({ success: true, data: flag });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to create feature flag', error: error.message });
  }
});

router.put('/feature-flags/:flagKey', (req, res) => {
  try {
    const { flagKey } = req.params;
    const updates = req.body;
    const updatedBy = req.user?.userId || 'admin';
    const flag = FeatureFlagService.updateFlag(flagKey, updates, updatedBy);
    res.json({ success: true, data: flag });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to update feature flag', error: error.message });
  }
});

router.delete('/feature-flags/:flagKey', (req, res) => {
  try {
    const { flagKey } = req.params;
    const deletedBy = req.user?.userId || 'admin';
    const success = FeatureFlagService.deleteFlag(flagKey, deletedBy);
    res.json({ success, message: success ? 'Feature flag deleted' : 'Feature flag not found' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to delete feature flag', error: error.message });
  }
});

router.get('/feature-flags/stats', (req, res) => {
  try {
    const stats = FeatureFlagService.getStats();
    res.json({ success: true, data: stats });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch feature flag stats', error: error.message });
  }
});


// ─── FROM: moduleManagerRoutes.js ────────────────────────────────────────
// ROUTES: Module Manager Routes — Unified routes for all specialized managers

const moduleManagerController = require('../../controllers/moduleManagerController');
const staffController = require('../../controllers/staffController');
const authMiddleware = require('../../middlewares/auth.middleware');
const { verifyStaff } = require('../../middlewares/adminMiddleware');
const verifyAdmin = require('../../middlewares/isAdmin');

// Protect all module manager routes
router.use(authMiddleware);
router.use(verifyStaff);

// ===========================================================================
// DASHBOARD
// ===========================================================================

// GET /api/admin/modules/dashboard
router.get('/dashboard', moduleManagerController.getManagerDashboard);

// ===========================================================================
// TERMINOLOGY & PERMISSIONS
// ===========================================================================

// GET /api/admin/modules/terminology
router.get('/terminology', moduleManagerController.getTerminology);

// ===========================================================================
// USER MANAGER MODULE
// ===========================================================================

// GET /api/admin/modules/users
router.get('/users', staffController.searchUser);

// PUT /api/admin/modules/users/:id/ban
router.put('/users/:id/ban', verifyAdmin, require('../../controllers/admin.controller').toggleBan);

// PUT /api/admin/modules/users/:id/verify
router.put('/users/:id/verify', verifyAdmin, require('../../controllers/admin.user.controller').verifyUser);

// ===========================================================================
// AGENCY MANAGER MODULE
// ===========================================================================

// GET /api/admin/modules/agencies
router.get('/agencies', require('../../controllers/agencyController').getAgencies);

// POST /api/admin/modules/agencies/:id/approve
router.post('/agencies/:id/approve', verifyAdmin, require('../../controllers/agencyController').approveAgency);

// POST /api/admin/modules/agencies/:id/revoke
router.post('/agencies/:id/revoke', verifyAdmin, require('../../controllers/agencyController').revokeAgency);

// ===========================================================================
// FAMILY MANAGER MODULE
// ===========================================================================

// GET /api/admin/modules/families
router.get('/families', require('../../controllers/familyController').getFamilies);

// DELETE /api/admin/modules/families/:id
router.delete('/families/:id', verifyAdmin, require('../../controllers/familyController').deleteFamily);

// ===========================================================================
// FINANCE MANAGER MODULE
// ===========================================================================

// GET /api/admin/modules/finance/transactions
router.get('/finance/transactions', require('../../controllers/treasuryController').getCoinOrders);

// POST /api/admin/modules/finance/withdrawals/:id/approve
router.post('/finance/withdrawals/:id/approve', verifyAdmin, require('../../controllers/admin.user.controller').approveWithdrawal);

// POST /api/admin/modules/finance/withdrawals/:id/reject
router.post('/finance/withdrawals/:id/reject', verifyAdmin, require('../../controllers/admin.user.controller').rejectWithdrawal);

// GET /api/admin/modules/finance/wallets
router.get('/finance/wallets', require('../../controllers/admin.controller').getWallets);

// ===========================================================================
// EVENT MANAGER MODULE
// ===========================================================================

// GET /api/admin/modules/events
router.get('/events', require('../../controllers/eventController').getAdminEvents);

// POST /api/admin/modules/events
router.post('/events', verifyAdmin, require('../../controllers/eventController').createEvent);

// PUT /api/admin/modules/events/:id
router.put('/events/:id', verifyAdmin, require('../../controllers/eventController').updateEvent);

// DELETE /api/admin/modules/events/:id
router.delete('/events/:id', verifyAdmin, require('../../controllers/eventController').deleteEvent);

// ===========================================================================
// BANNER MANAGER MODULE
// ===========================================================================

// GET /api/admin/modules/banners
router.get('/banners', moduleManagerController.getBanners);

// POST /api/admin/modules/banners
router.post('/banners', verifyAdmin, moduleManagerController.createBanner);

// PUT /api/admin/modules/banners/:id
router.put('/banners/:id', verifyAdmin, moduleManagerController.updateBanner);

// DELETE /api/admin/modules/banners/:id
router.delete('/banners/:id', verifyAdmin, moduleManagerController.deleteBanner);

// ===========================================================================
// ADVERTISEMENT MANAGER MODULE
// ===========================================================================

// GET /api/admin/modules/ads
router.get('/ads', moduleManagerController.getAdvertisements);

// POST /api/admin/modules/ads
router.post('/ads', verifyAdmin, moduleManagerController.createAdvertisement);

// PUT /api/admin/modules/ads/:id
router.put('/ads/:id', verifyAdmin, moduleManagerController.updateAdvertisement);

// DELETE /api/admin/modules/ads/:id
router.delete('/ads/:id', verifyAdmin, moduleManagerController.deleteAdvertisement);

// ===========================================================================
// GIFT MANAGER MODULE
// ===========================================================================

// GET /api/admin/modules/gifts
router.get('/gifts', moduleManagerController.getGifts);

// POST /api/admin/modules/gifts
router.post('/gifts', verifyAdmin, moduleManagerController.createGift);

// PUT /api/admin/modules/gifts/:id
router.put('/gifts/:id', verifyAdmin, moduleManagerController.updateGift);

// DELETE /api/admin/modules/gifts/:id
router.delete('/gifts/:id', verifyAdmin, moduleManagerController.deleteGift);

// ===========================================================================
// VIP MANAGER MODULE
// ===========================================================================

// GET /api/admin/modules/vip/plans
router.get('/vip/plans', moduleManagerController.getVipPlans);

// POST /api/admin/modules/vip/plans
router.post('/vip/plans', verifyAdmin, moduleManagerController.createVipPlan);

// PUT /api/admin/modules/vip/plans/:id
router.put('/vip/plans/:id', verifyAdmin, moduleManagerController.updateVipPlan);

// DELETE /api/admin/modules/vip/plans/:id
router.delete('/vip/plans/:id', verifyAdmin, moduleManagerController.deleteVipPlan);

// ===========================================================================
// CMS MANAGER MODULE
// ===========================================================================

// GET /api/admin/modules/cms/pages
router.get('/cms/pages', moduleManagerController.getCMSPages);

// POST /api/admin/modules/cms/pages
router.post('/cms/pages', verifyAdmin, moduleManagerController.createCMSPage);

// PUT /api/admin/modules/cms/pages/:id
router.put('/cms/pages/:id', verifyAdmin, moduleManagerController.updateCMSPage);

// ===========================================================================
// AUDIT MANAGER MODULE
// ===========================================================================

// GET /api/admin/modules/audit-logs
router.get('/audit-logs', moduleManagerController.getAuditLogs);

// GET /api/admin/modules/audit-logs/export
router.get('/audit-logs/export', moduleManagerController.exportAuditLogs);

// ===========================================================================
// REPORTS MANAGER MODULE
// ===========================================================================

// GET /api/admin/modules/reports
router.get('/reports', moduleManagerController.getReports);

// POST /api/admin/modules/reports/:id/assign
router.post('/reports/:id/assign', verifyAdmin, moduleManagerController.assignReport);

// POST /api/admin/modules/reports/:id/resolve
router.post('/reports/:id/resolve', verifyAdmin, moduleManagerController.resolveReport);

// ===========================================================================
// BACKUP MANAGER MODULE
// ===========================================================================

// POST /api/admin/modules/backup/create
router.post('/backup/create', verifyAdmin, moduleManagerController.createBackup);

// GET /api/admin/modules/backups
router.get('/backups', moduleManagerController.getBackups);

// ===========================================================================
// SETTINGS MANAGER MODULE
// ===========================================================================

// GET /api/admin/modules/settings
router.get('/settings', moduleManagerController.getSettings);

// PUT /api/admin/modules/settings
router.put('/settings', verifyAdmin, moduleManagerController.updateSettings);


module.exports = router;
