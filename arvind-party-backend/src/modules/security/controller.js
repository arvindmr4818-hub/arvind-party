// =========================================================================
// MODULE: SECURITY — CONTROLLER
// =========================================================================


// ─── FROM: security.controller.js ────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════
// FILE: src/controllers/security.controller.js
// ARVIND PARTY — Security Dashboard Controller for Owner Web Panel
// Endpoints: fraud alerts, banned devices, blocked IPs, audit logs
// ═══════════════════════════════════════════════════════════════════════════

const AuditLog = require('../../models/AuditLog');
const FraudAlert = require('../../models/FraudAlert');
const BannedDevice = require('../../models/BannedDevice');
const BlockedIp = require('../../models/BlockedIp');
const User = require('../../models/User');
const RefreshToken = require('../../models/RefreshToken');
const authMiddleware = require('../../middlewares/auth.middleware');
const { requireRole } = require('../../middlewares/auth.middleware');

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD SUMMARY (requires owner or admin role)
// ─────────────────────────────────────────────────────────────────────────────
exports.getDashboard = async (req, res) => {
  try {
    const [fraudOpen, fraudCritical, bannedCount, blockedCount, recentLogsCount, flaggedUsers] = await Promise.all([
      FraudAlert.countDocuments({ status: 'OPEN' }),
      FraudAlert.countDocuments({ severity: 'CRITICAL', status: 'OPEN' }),
      BannedDevice.countDocuments({}),
      BlockedIp.countDocuments({}),
      AuditLog.countDocuments({ createdAt: { $gte: new Date(Date.now() - 24 * 60 * 60 * 1000) } }),
      User.countDocuments({ $or: [{ isBanned: true }, { isBlocked: true }, { suspiciousActivityCount: { $gt: 5 } }] }),
    ]);

    res.status(200).json({
      success: true,
      data: {
        openFraudAlerts: fraudOpen,
        criticalFraudAlerts: fraudCritical,
        bannedDevices: bannedCount,
        blockedIps: blockedCount,
        auditLogsLast24h: recentLogsCount,
        flaggedUsers,
        timestamp: new Date().toISOString(),
      },
    });
  } catch (error) {
    console.error('Security Dashboard Error:', error);
    res.status(500).json({ success: false, message: 'Failed to load dashboard.' });
  }
};

// ─────────────────────────────────────────────────────────────────────────────
// FRAUD ALERTS (paginated)
// ─────────────────────────────────────────────────────────────────────────────
exports.getFraudAlerts = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    const severity = req.query.severity;
    const status = req.query.status;

    const filter = {};
    if (severity) filter.severity = severity;
    if (status) filter.status = status;

    const [alerts, total] = await Promise.all([
      FraudAlert.find(filter).sort({ createdAt: -1 }).skip(skip).limit(limit).lean(),
      FraudAlert.countDocuments(filter),
    ]);

    res.status(200).json({
      success: true,
      data: alerts,
      pagination: { page, limit, total, pages: Math.ceil(total / limit) },
    });
  } catch (error) {
    console.error('Get Fraud Alerts Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch fraud alerts.' });
  }
};

exports.updateFraudAlert = async (req, res) => {
  try {
    const alert = await FraudAlert.findById(req.params.id);
    if (!alert) {
      return res.status(404).json({ success: false, message: 'Audit alert not found.' });
    }

    const allowed = ['status', 'severity', 'resolutionNote', 'accountHeld', 'heldUntil', 'financeManagerNotified'];
    const updates = {};
    for (const key of allowed) {
      if (req.body[key] !== undefined) updates[key] = req.body[key];
    }

    Object.assign(alert, updates);
    await alert.save();

    await AuditLog.create({
      action: 'SETTINGS_UPDATED',
      executorId: req.user.id || req.user._id,
      executorUid: req.user.uid,
      executorRole: req.user.role,
      reason: `Fraud alert ${req.params.id} updated`,
      metadata: { alertId: req.params.id, updates }
    });

    res.status(200).json({ success: true, data: alert });
  } catch (error) {
    console.error('Update Fraud Alert Error:', error);
    res.status(500).json({ success: false, message: 'Failed to update alert.' });
  }
};

// ─────────────────────────────────────────────────────────────────────────────
// BANNED DEVICES
// ─────────────────────────────────────────────────────────────────────────────
exports.getBannedDevices = async (req, res) => {
  try {
    const devices = await BannedDevice.find({}).sort({ bannedAt: -1 }).lean();
    res.status(200).json({ success: true, data: devices });
  } catch (error) {
    console.error('Get Banned Devices Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch banned devices.' });
  }
};

exports.banDevice = async (req, res) => {
  try {
    const { deviceId, reason } = req.body;
    if (!deviceId) {
      return res.status(400).json({ success: false, message: 'deviceId is required.' });
    }

    const existing = await BannedDevice.findOne({ deviceId });
    if (existing) {
      return res.status(409).json({ success: false, message: 'Device already banned.' });
    }

    const device = await BannedDevice.create({
      deviceId,
      reason: reason || 'Violation of platform policies.',
      bannedBy: req.user._id || req.user.id,
    });

    await AuditLog.create({
      action: 'DEVICE_FLAGGED',
      executorId: req.user._id || req.user.id,
      executorUid: req.user.uid,
      executorRole: req.user.role,
      reason: `Banned device ${deviceId}`,
      deviceId,
      metadata: { reason }
    });

    res.status(201).json({ success: true, data: device });
  } catch (error) {
    console.error('Ban Device Error:', error);
    res.status(500).json({ success: false, message: 'Failed to ban device.' });
  }
};

exports.unbanDevice = async (req, res) => {
  try {
    await BannedDevice.findByIdAndDelete(req.params.id);
    await AuditLog.create({
      action: 'SETTINGS_UPDATED',
      executorId: req.user._id || req.user.id,
      executorUid: req.user.uid,
      executorRole: req.user.role,
      reason: `Unbanned device ${req.params.id}`,
      metadata: { deviceId: req.params.id }
    });
    res.status(200).json({ success: true, message: 'Device unbanned.' });
  } catch (error) {
    console.error('Unban Device Error:', error);
    res.status(500).json({ success: false, message: 'Failed to unban device.' });
  }
};

// ─────────────────────────────────────────────────────────────────────────────
// BLOCKED IPs
// ─────────────────────────────────────────────────────────────────────────────
exports.getBlockedIps = async (req, res) => {
  try {
    const ips = await BlockedIp.find({}).sort({ createdAt: -1 }).lean();
    res.status(200).json({ success: true, data: ips });
  } catch (error) {
    console.error('Get Blocked IPs Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch blocked IPs.' });
  }
};

exports.blockIp = async (req, res) => {
  try {
    const { ipAddress, reason, isPermanent } = req.body;
    if (!ipAddress) {
      return res.status(400).json({ success: false, message: 'ipAddress is required.' });
    }

    const existing = await BlockedIp.findOne({ ipAddress });
    if (existing) {
      return res.status(409).json({ success: false, message: 'IP already blocked.' });
    }

    const ip = await BlockedIp.create({
      ipAddress,
      reason: reason || 'Security violation',
      blockedBy: req.user._id || req.user.id,
      isPermanent: !!isPermanent,
      isVpnBlock: false,
    });

    await AuditLog.create({
      action: 'RATE_LIMIT_EXCEEDED',
      executorId: req.user._id || req.user.id,
      executorUid: req.user.uid,
      executorRole: req.user.role,
      reason: `Blocked IP ${ipAddress}`,
      ipAddress,
      metadata: { reason, isPermanent: !!isPermanent }
    });

    res.status(201).json({ success: true, data: ip });
  } catch (error) {
    console.error('Block IP Error:', error);
    res.status(500).json({ success: false, message: 'Failed to block IP.' });
  }
};

exports.unblockIp = async (req, res) => {
  try {
    await BlockedIp.findByIdAndDelete(req.params.id);
    res.status(200).json({ success: true, message: 'IP unblocked.' });
  } catch (error) {
    console.error('Unblock IP Error:', error);
    res.status(500).json({ success: false, message: 'Failed to unblock IP.' });
  }
};

// ─────────────────────────────────────────────────────────────────────────────
// AUDIT LOGS (append-only)
// ─────────────────────────────────────────────────────────────────────────────
exports.getAuditLogs = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 50;
    const skip = (page - 1) * limit;
    const action = req.query.action;

    const filter = {};
    if (action) filter.action = action;

    const [logs, total] = await Promise.all([
      AuditLog.find(filter).sort({ createdAt: -1 }).skip(skip).limit(limit).lean(),
      AuditLog.countDocuments(filter),
    ]);

    res.status(200).json({
      success: true,
      data: logs,
      pagination: { page, limit, total, pages: Math.ceil(total / limit) },
    });
  } catch (error) {
    console.error('Get Audit Logs Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch audit logs.' });
  }
};

// ─────────────────────────────────────────────────────────────────────────────
// LIVE THREAT MONITOR: active sessions + suspicious users
// ─────────────────────────────────────────────────────────────────────────────
exports.getLiveThreats = async (req, res) => {
  try {
    const suspiciousUsers = await User.find({
      $or: [{ isBanned: true }, { isBlocked: true }, { suspiciousActivityCount: { $gt: 3 } }],
    }).sort({ suspiciousActivityCount: -1 }).limit(100).lean();

    // Recent critical alerts not yet resolved
    const criticalAlerts = await FraudAlert.find({
      severity: 'CRITICAL',
      status: { $in: ['OPEN', 'INVESTIGATING'] },
    }).sort({ createdAt: -1 }).limit(50).lean();

    res.status(200).json({
      success: true,
      data: {
        suspiciousUsers,
        criticalAlerts,
        timestamp: new Date().toISOString(),
      },
    });
  } catch (error) {
    console.error('Get Live Threats Error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch live threats.' });
  }
};

// ─── FROM: antiBanController.js ────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════
// FILE: src/controllers/antiBanController.js
// ARVIND PARTY - ANTI-BAN & DEVICE MANAGEMENT (Owner Panel)
// ═══════════════════════════════════════════════════════════════════════════

const BannedDevice = require('../../models/BannedDevice');
const User = require('../../models/User');
const AuditLog = require('../../models/AuditLog');

// ═══════════════════════════════════════════════════════════════════════════
// BAN DEVICE PERMANENTLY
// POST /api/admin/anti-ban/ban-device
// Body: { deviceId, userId, reason }
// ═══════════════════════════════════════════════════════════════════════════

exports.banDevice = async (req, res, next) => {
  try {
    const { deviceId, userId, reason } = req.body;
    const bannedBy = req.user.userId;
    const adminRole = req.user.role;

    if (!['admin', 'owner'].includes(adminRole)) {
      return res.status(403).json({
        success: false,
        message: 'Only admins and owners can ban devices',
        code: 'FORBIDDEN',
      });
    }

    if (!deviceId) {
      return res.status(400).json({
        success: false,
        message: 'Device ID is required',
      });
    }

    const existingBan = await BannedDevice.findOne({ deviceId });
    if (existingBan) {
      return res.status(409).json({
        success: false,
        message: 'This device is already banned',
        code: 'DEVICE_ALREADY_BANNED',
        bannedAt: existingBan.bannedAt,
        bannedReason: existingBan.reason,
      });
    }

    const bannedDevice = await BannedDevice.create({
      deviceId: deviceId.trim(),
      reason: reason || 'Repeated violation of platform policies.',
      bannedBy: bannedBy,
      bannedAt: new Date(),
    });

    if (userId) {
      await User.findByIdAndUpdate(userId, {
        isBanned: true,
        isActive: false,
        banReason: reason || 'Device banned for policy violation',
        bannedAt: new Date(),
        bannedBy: bannedBy,
      });
    }

    await AuditLog.create({
      action: 'DEVICE_BANNED',
      performedBy: bannedBy,
      targetUser: userId || null,
      targetDevice: deviceId,
      reason: reason || 'Policy violation',
      metadata: {
        deviceId: deviceId,
        ipAddress: req.ip,
        userAgent: req.headers['user-agent'],
      },
    });

    res.status(200).json({
      success: true,
      message: 'Device has been permanently banned.',
      data: {
        deviceId: bannedDevice.deviceId,
        reason: bannedDevice.reason,
        bannedAt: bannedDevice.bannedAt,
      },
    });
  } catch (error) {
    console.error('❌ Ban Device Error:', error);
    next(error);
  }
};

// ═══════════════════════════════════════════════════════════════════════════
// UNBAN DEVICE
// POST /api/admin/anti-ban/unban-device
// Body: { deviceId }
// ═══════════════════════════════════════════════════════════════════════════

exports.unbanDevice = async (req, res, next) => {
  try {
    const { deviceId } = req.body;
    const userId = req.user.userId;
    const adminRole = req.user.role;

    if (!['admin', 'owner'].includes(adminRole)) {
      return res.status(403).json({
        success: false,
        message: 'Only admins and owners can unban devices',
        code: 'FORBIDDEN',
      });
    }

    if (!deviceId) {
      return res.status(400).json({
        success: false,
        message: 'Device ID is required',
      });
    }

    const bannedDevice = await BannedDevice.findOneAndDelete({ deviceId: deviceId.trim() });
    if (!bannedDevice) {
      return res.status(404).json({
        success: false,
        message: 'Device not found in banned list',
      });
    }

    await AuditLog.create({
      action: 'DEVICE_UNBANNED',
      performedBy: userId,
      targetDevice: deviceId,
      metadata: {
        ipAddress: req.ip,
        userAgent: req.headers['user-agent'],
      },
    });

    res.status(200).json({
      success: true,
      message: 'Device has been unbanned successfully.',
    });
  } catch (error) {
    console.error('❌ Unban Device Error:', error);
    next(error);
  }
};

// ═══════════════════════════════════════════════════════════════════════════
// LIST ALL BANNED DEVICES
// GET /api/admin/anti-ban/banned-devices
// Query: { page, limit, search }
// ═══════════════════════════════════════════════════════════════════════════

exports.listBannedDevices = async (req, res, next) => {
  try {
    const adminRole = req.user.role;
    if (!['admin', 'owner'].includes(adminRole)) {
      return res.status(403).json({
        success: false,
        message: 'Access denied',
        code: 'FORBIDDEN',
      });
    }

    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const search = req.query.search || '';
    const skip = (page - 1) * limit;

    let query = {};
    if (search) {
      query = {
        $or: [
          { deviceId: { $regex: search, $options: 'i' } },
          { reason: { $regex: search, $options: 'i' } },
        ],
      };
    }

    const [bannedDevices, total] = await Promise.all([
      BannedDevice.find(query)
        .populate('bannedBy', 'name username email')
        .sort({ bannedAt: -1 })
        .skip(skip)
        .limit(limit)
        .lean(),
      BannedDevice.countDocuments(query),
    ]);

    res.status(200).json({
      success: true,
      data: {
        bannedDevices,
        pagination: {
          page,
          limit,
          total,
          totalPages: Math.ceil(total / limit),
        },
      },
    });
  } catch (error) {
    console.error('❌ List Banned Devices Error:', error);
    next(error);
  }
};

// ═══════════════════════════════════════════════════════════════════════════
// CHECK IF DEVICE IS BANNED (for app startup validation)
// POST /api/security/check-device
// Body: { deviceId }
// ═══════════════════════════════════════════════════════════════════════════

exports.checkDeviceStatus = async (req, res, next) => {
  try {
    const { deviceId } = req.body;

    if (!deviceId) {
      return res.status(400).json({
        success: false,
        message: 'Device ID is required',
      });
    }

    const bannedDevice = await BannedDevice.findOne({ deviceId: deviceId.trim() });

    if (bannedDevice) {
      return res.status(403).json({
        success: false,
        isBanned: true,
        code: 'DEVICE_BANNED',
        message: 'This device has been banned from the platform.',
        bannedReason: bannedDevice.reason,
        bannedAt: bannedDevice.bannedAt,
      });
    }

    res.status(200).json({
      success: true,
      isBanned: false,
      message: 'Device is not banned',
    });
  } catch (error) {
    console.error('❌ Check Device Status Error:', error);
    next(error);
  }
};

// ─── FROM: moderationController.js ────────────────────────────────────────
const User = require('../../models/User');

// GET /api/moderation/reports
exports.getReports = async (req, res) => {
  try {
    res.json({ success: true, reports: [] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// POST /api/safety/report
exports.reportContent = async (req, res) => {
  try {
    const { userId, roomId, reason } = req.body;
    res.json({ success: true, message: 'Report submitted' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// POST /api/social/block
exports.blockUser = async (req, res) => {
  try {
    const currentUserId = req.user?.id || req.body.currentUserId;
    const { userId } = req.body;
    if (!currentUserId || !userId) return res.status(400).json({ success: false, message: 'User IDs required' });
    await User.findByIdAndUpdate(currentUserId, { $addToSet: { blockedUsers: userId } });
    res.json({ success: true, message: 'User blocked' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// ─── FROM: badgeController.js ────────────────────────────────────────
const Badge = require('../../models/Badge');
const User = require('../../models/User');

/**
 * Check if a user has unlocked a badge
 * @param {Object} user - User object
 * @param {Object} badge - Badge object
 * @returns {boolean} - Whether the badge is unlocked
 */
const checkBadgeUnlocked = (user, badge) => {
  const condition = badge.unlockCondition;

  switch (condition.conditionType) {
    case 'diamonds':
      return compareValues(user.diamonds, condition.value, condition.comparison);
    case 'coins':
      return compareValues(user.coins, condition.value, condition.comparison);
    case 'level':
      return compareValues(user.level, condition.value, condition.comparison);
    case 'custom':
      // For custom conditions, we'll assume they're unlocked for now
      return true;
    default:
      return false;
  }
};

/**
 * Compare two values based on comparison operator
 * @param {number} value1 - First value
 * @param {number} value2 - Second value
 * @param {string} comparison - Comparison operator
 * @returns {boolean} - Result of comparison
 */
const compareValues = (value1, value2, comparison) => {
  switch (comparison) {
    case '>=':
      return value1 >= value2;
    case '>':
      return value1 > value2;
    case '=':
      return value1 === value2;
    case '<':
      return value1 < value2;
    case '<=':
      return value1 <= value2;
    default:
      return value1 >= value2;
  }
};

/**
 * Get all badges with unlock status for a user
 * @param {string} userId - User ID
 * @returns {Promise<Array>} - Array of badges with unlock status
 */
exports.getUserBadges = async (userId) => {
  try {
    const user = await User.findById(userId);
    if (!user) return [];

    const badges = await Badge.find({ isActive: true });

    return badges.map(badge => ({
      id: badge.id,
      name: badge.name,
      description: badge.description,
      iconPath: badge.iconPath,
      isUnlocked: user.badges.includes(badge.id) || checkBadgeUnlocked(user, badge)
    }));
  } catch (error) {
    console.error('Error getting user badges:', error);
    return [];
  }
};

/**
 * Check and award badges to user
 * @param {string} userId - User ID
 * @returns {Promise<Array>} - Array of newly awarded badge IDs
 */
exports.checkAndAwardBadges = async (userId) => {
  try {
    const user = await User.findById(userId);
    if (!user) return [];

    const badges = await Badge.find({ isActive: true });
    const newlyAwarded = [];

    for (const badge of badges) {
      if (!user.badges.includes(badge.id) && checkBadgeUnlocked(user, badge)) {
        user.badges.push(badge.id);
        newlyAwarded.push(badge.id);
      }
    }

    if (newlyAwarded.length > 0) {
      await user.save();
    }

    return newlyAwarded;
  } catch (error) {
    console.error('Error checking and awarding badges:', error);
    return [];
  }
};

/**
 * Initialize default badges
 */
// Hardcoded default badges (used when MongoDB is not available)
const FALLBACK_BADGES = [
  {
    id: 'b1',
    name: 'Top Gifter',
    description: 'Gifted over 10k diamonds',
    iconPath: '💎',
    isUnlocked: false
  },
  {
    id: 'b2',
    name: 'Coin Collector',
    description: 'Earned over 50k coins',
    iconPath: '💰',
    isUnlocked: false
  },
  {
    id: 'b3',
    name: 'Level Master',
    description: 'Reached level 10',
    iconPath: '🏆',
    isUnlocked: false
  },
  {
    id: 'b4',
    name: 'Early Bird',
    description: 'Joined Arvind Party',
    iconPath: '🐦',
    isUnlocked: true
  }
];

exports.initializeDefaultBadges = async () => {
  try {
    const existingBadges = await Badge.find();
    if (existingBadges.length > 0) return;

    const defaultBadges = [
      {
        id: 'b1',
        name: 'Top Gifter',
        description: 'Gifted over 10k diamonds',
        iconPath: '💎',
        unlockCondition: {
          conditionType: 'diamonds',
          value: 10000,
          comparison: '>='
        }
      },
      {
        id: 'b2',
        name: 'Coin Collector',
        description: 'Earned over 50k coins',
        iconPath: '💰',
        unlockCondition: {
          conditionType: 'coins',
          value: 50000,
          comparison: '>='
        }
      },
      {
        id: 'b3',
        name: 'Level Master',
        description: 'Reached level 10',
        iconPath: '🏆',
        unlockCondition: {
          conditionType: 'level',
          value: 10,
          comparison: '>='
        }
      },
      {
        id: 'b4',
        name: 'Early Bird',
        description: 'Joined Arvind Party',
        iconPath: '🐦',
        unlockCondition: {
          conditionType: 'custom',
          value: 0,
          comparison: '='
        }
      }
    ];

    await Badge.insertMany(defaultBadges);
    console.log('✅ Default badges initialized');
  } catch (error) {
    console.error('Error initializing default badges:', error);
  }
};
