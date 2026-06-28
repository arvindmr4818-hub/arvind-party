// =========================================================================
// MODULE: SECURITY — SERVICES
// =========================================================================


// ─── FROM: fraudDetection.service.js ────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════
// FILE: src/services/fraudDetection.service.js
// ARVIND PARTY — Financial Fraud Protection Engine [Phase 34]
// • Google Play Store Server-to-Server verification
// • Abnormal coin transfer detection & auto-hold
// • Rapid gifting / multi-wallet drain analysis
// ═══════════════════════════════════════════════════════════════════════════

const axios = require('axios');
const User = require('../../models/User');
const Transaction = require('../../models/Transaction');
const WalletTransaction = require('../../models/WalletTransaction');
const FraudAlert = require('../../models/FraudAlert');
const AuditLog = require('../../models/AuditLog');
const Recharge = require('../../models/Recharge');

// ── Configurable thresholds ────────────────────────────────────────────────
const MAX_COIN_TRANSFER_PER_MINUTE = 50000; // coins
const MAX_GIFT_VALUE_PER_HOUR = 100000;
const MIN_TRANSFER_INTERVAL_MS = 1000; // min 1s between transfers (anti-bot)
const GOOGLE_PLAY_PACKAGE_NAME = process.env.GOOGLE_PLAY_PACKAGE_NAME || 'com.arvindparty.app';
const GOOGLE_PLAY_SERVICE_ACCOUNT = process.env.GOOGLE_PLAY_SERVICE_ACCOUNT || null;

/**
 * Verify a Google Play Store purchase / subscription token server-to-server.
 * POST body includes purchaseToken for the specific product (e.g., coin pack).
 */
const verifyGooglePlayPurchase = async ({ packageName, productId, purchaseToken }) => {
  if (!GOOGLE_PLAY_SERVICE_ACCOUNT) {
    // In development without service account, simulate success for allowed products
    const devAllowed = ['coins_100', 'coins_500', 'coins_1000'];
    if (devAllowed.includes(productId)) {
      return { valid: true, consumed: false, purchaseTime: Date.now() };
    }
    return { valid: false, reason: 'Google Play verification skipped in dev mode for unknown product.' };
  }

  try {
    const { OAuth2Client } = require('google-auth-library');
    const client = new OAuth2Client();
    // Service account credentials are expected in env var as JSON string
    const credentials = JSON.parse(process.env.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON || '{}');
    await client.setCredentials(credentials);
    const url = `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${packageName || GOOGLE_PLAY_PACKAGE_NAME}/purchases/products/${productId}/tokens/${purchaseToken}`;
    const res = await axios.get(url, { headers: { Authorization: `Bearer ${(await client.getAccessToken()).token}` } });
    const data = res.data;
    if (data.purchaseState !== 0) {
      return { valid: false, reason: `Purchase state is ${data.purchaseState}` };
    }
    return { valid: true, consumed: data.consumptionState === 1, purchaseTime: data.purchaseTimeMillis };
  } catch (err) {
    console.error('Google Play verification failed:', err.response?.data || err.message);
    return { valid: false, reason: err.response?.data?.error?.message || err.message };
  }
};

/**
 * Evaluate wallet/coin activity for anomaly patterns.
 * Called AFTER a successful recharge or gift event.
 */
const evaluateFinancialActivity = async ({ userId, uid, actionType, amountInCoins, metadata = {} }) => {
  if (actionType === 'RECHARGE') {
    // Already verified server-to-server by controller — just log
    await AuditLog.create({
      action: 'RECHARGE_SUCCESS',
      executorId: userId,
      executorUid: uid,
      reason: `Recharge verified: ${amountInCoins} coins`,
      metadata: { packageName: metadata.packageName, productId: metadata.productId }
    });
    return { flagged: false };
  }

  // For gifts/transfers, check rapid pattern
  const oneMinuteAgo = new Date(Date.now() - 60 * 1000);
  const recentGifts = await WalletTransaction.find({
    userId,
    type: 'gift_sent',
    createdAt: { $gte: oneMinuteAgo },
  });

  const totalCoinsLastMinute = recentGifts.reduce((sum, t) => sum + (t.amount || 0), 0);

  if (totalCoinsLastMinute > MAX_COIN_TRANSFER_PER_MINUTE) {
    await _createFraudAlert(userId, uid, 'ABNORMAL_COIN_TRANSFER', `Transferred ${totalCoinsLastMinute} coins in under 1 minute.`, 'CRITICAL', amountInCoins, metadata);
    await _holdAccount(userId, 'Abnormal transfer pattern detected.');
    return { flagged: true, reason: 'ABNORMAL_TRANSFER_RATE' };
  }

  // Anti multi-wallet drain: check if receiving wallet has unusual inflow
  if (actionType === 'gift_sent') {
    const hourAgo = new Date(Date.now() - 60 * 60 * 1000);
    const receivedLastHour = await WalletTransaction.find({
      userId,
      type: 'gift_received',
      createdAt: { $gte: hourAgo },
    });
    const totalReceived = receivedLastHour.reduce((sum, t) => sum + (t.amount || 0), 0);
    if (totalReceived > MAX_GIFT_VALUE_PER_HOUR) {
      await _createFraudAlert(userId, uid, 'MULTI_WALLET_DRAIN', `Received ${totalReceived} coins via gifts in 1 hour.`, 'HIGH', amountInCoins, metadata);
    }
  }

  return { flagged: false };
};

/**
 * Evaluate Google Play fake receipt attempts.
 * Returns true if verification passed.
 */
const verifyAndEvaluateRecharge = async ({ userId, uid, productId, purchaseToken, amountInCoins }) => {
  const verification = await verifyGooglePlayPurchase({
    packageName: GOOGLE_PLAY_PACKAGE_NAME,
    productId,
    purchaseToken,
  });

  if (!verification.valid) {
    await _createFraudAlert(userId, uid, 'FAKE_RECHARGE', `Invalid Google Play receipt for ${productId}.`, 'CRITICAL', amountInCoins, { productId, purchaseToken });
    await AuditLog.create({
      action: 'INVALID_PAYMENT_CLAIM',
      executorId: userId,
      executorUid: uid,
      reason: `Fake recharge attempt: ${productId}`,
      metadata: { purchaseToken, productId }
    });
    return { success: false, reason: verification.reason };
  }

  // Also guard against duplicate purchase tokens
  const existing = await Recharge.findOne({ purchaseToken, productId, status: 'success' });
  if (existing) {
    await _createFraudAlert(userId, uid, 'PLAY_STORE_FAKE_RECEIPT', `Duplicate purchaseToken detected for ${productId}.`, 'HIGH', amountInCoins, { purchaseToken });
    return { success: false, reason: 'Duplicate purchase token.' };
  }

  return { success: true, purchaseTime: verification.purchaseTime };
};

// ── Private helpers ────────────────────────────────────────────────────────

const _createFraudAlert = async (userId, uid, type, description, severity, amountInvolved = 0, metadata = {}) => {
  try {
    const alert = await FraudAlert.create({
      userId,
      uid,
      type,
      description,
      severity,
      amountInvolved: amountInvolved || 0,
      ipAddress: null,
      deviceId: null,
      metadata,
    });

    // Notify finance manager (email/in-app) — leaving as push hook
    await AuditLog.create({
      action: 'SUSPICIOUS_ACTIVITY',
      executorId: userId,
      executorUid: uid,
      reason: `Fraud alert created: ${type}`,
      metadata: { alertId: alert._id.toString() }
    });

    return alert;
  } catch (_) {
    return null;
  }
};

const _holdAccount = async (userId, reason) => {
  try {
    await User.findByIdAndUpdate(userId, {
      $set: { isBlocked: true, isCoinSeller: false },
    });
    await _createFraudAlert(userId, '', 'ABNORMAL_COIN_TRANSFER', reason, 'CRITICAL', 0);
  } catch (_) {}
};

module.exports = {
  verifyGooglePlayPurchase,
  evaluateFinancialActivity,
  verifyAndEvaluateRecharge,
};

// ─── FROM: anti.spam.service.js ────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════
// FILE: src/services/anti.spam.service.js
// ARVIND PARTY — Anti-Spam & Anti-Abuse Engine [Phase 33]
// • Repeated message detection
// • Profanity filter (configurable word list)
// • Rapid-fire message rate check
// • Game anti-cheat timing validator
// ═══════════════════════════════════════════════════════════════════════════

const SpamLog  = require('../../models/SpamLog');
const User     = require('../../models/User');
const AuditLog = require('../../models/AuditLog');

// ── Profanity word list (seed list; extend via DB in production) ──────────
const PROFANITY_LIST = [
  'abuse1', 'abuse2', 'slur1', 'slur2',
  // INSERT YOUR PROFANITY WORDS HERE — one per entry, lowercase
];

// ── Per-user in-memory message tracking (resets on server restart) ────────
// For production: use Redis with per-user sliding window counters.
const userMessageWindows = new Map(); // userId -> [timestamp, ...]
const userLastMessages   = new Map(); // userId -> lastMessage string

const MAX_MESSAGES_PER_10S = 8;  // Max 8 messages in 10 seconds before throttle
const REPEAT_THRESHOLD     = 3;  // Same message 3 times = spam

/**
 * Analyse an incoming chat message for spam/abuse.
 * @param {string} userId  - Mongo ObjectId string
 * @param {string} uid     - Public UID
 * @param {string} message - Message text
 * @param {string} roomId  - Room or chat context
 * @param {string} ip      - Sender IP
 * @returns {{ allowed: boolean, reason?: string, autoAction?: string }}
 */
const analyseMessage = async (userId, uid, message, roomId = '', ip = '') => {
  const now   = Date.now();
  const lower = message.toLowerCase().trim();

  // 1. Profanity check
  const foundWord = PROFANITY_LIST.find((w) => lower.includes(w));
  if (foundWord) {
    await _logSpam(userId, uid, roomId, 'PROFANITY_DETECTED', 'HIGH', `Word: ${foundWord}`, message.slice(0, 200), 'MUTED_5MIN', ip);
    await _muteChatUser(userId, 5);
    return { allowed: false, reason: 'Abusive language detected.', autoAction: 'MUTED_5MIN' };
  }

  // 2. Repeated message check
  const lastMsg = userLastMessages.get(userId) || '';
  if (lower === lastMsg) {
    const repeatKey = `repeat:${userId}`;
    const repeatCount = (userMessageWindows.get(repeatKey) || 0) + 1;
    userMessageWindows.set(repeatKey, repeatCount);
    if (repeatCount >= REPEAT_THRESHOLD) {
      userMessageWindows.set(repeatKey, 0);
      await _logSpam(userId, uid, roomId, 'REPEATED_MESSAGE', 'MEDIUM', `Repeated ${repeatCount}x`, message.slice(0, 200), 'MUTED_2MIN', ip);
      await _muteChatUser(userId, 2);
      return { allowed: false, reason: 'Stop sending the same message repeatedly.', autoAction: 'MUTED_2MIN' };
    }
  } else {
    userMessageWindows.delete(`repeat:${userId}`);
    userLastMessages.set(userId, lower);
  }

  // 3. Rate-of-fire check (sliding window)
  const timestamps = (userMessageWindows.get(`rate:${userId}`) || []).filter(t => now - t < 10000);
  timestamps.push(now);
  userMessageWindows.set(`rate:${userId}`, timestamps);

  if (timestamps.length > MAX_MESSAGES_PER_10S) {
    await _logSpam(userId, uid, roomId, 'RAPID_FIRE_MESSAGES', 'MEDIUM', `${timestamps.length} msgs in 10s`, '', 'MUTED_1MIN', ip);
    await _muteChatUser(userId, 1);
    return { allowed: false, reason: 'Sending messages too fast. Slow down.', autoAction: 'MUTED_1MIN' };
  }

  return { allowed: true };
};

/**
 * Validate a game action click timing to detect third-party bots/scripts.
 * The game must send a sequence of click timestamps; this checks min intervals.
 * @param {string}   userId
 * @param {string}   uid
 * @param {string}   gameType   - e.g. 'BLIND_DATE', 'PK_BATTLE', 'LUCKY_WHEEL'
 * @param {number[]} timestamps - Array of client-sent action timestamps (ms)
 */
const validateGameTiming = async (userId, uid, gameType, timestamps) => {
  if (!Array.isArray(timestamps) || timestamps.length < 2) return { valid: true };

  const intervals = [];
  for (let i = 1; i < timestamps.length; i++) {
    intervals.push(timestamps[i] - timestamps[i - 1]);
  }

  // If median interval is < 50ms — definitely a bot (human reaction ≥ ~100ms)
  intervals.sort((a, b) => a - b);
  const median = intervals[Math.floor(intervals.length / 2)];

  if (median < 50) {
    await _logSpam(userId, uid, '', 'GAME_CHEAT_ATTEMPT', 'CRITICAL', `Game: ${gameType}, MedianInterval: ${median}ms`, '', 'ACCOUNT_HOLD', '');
    await AuditLog.create({
      action: 'SUSPICIOUS_ACTIVITY',
      executorId: userId,
      executorUid: uid,
      reason: `Game cheat detected in ${gameType}. Median action interval ${median}ms.`,
    });
    return { valid: false, reason: 'Suspicious activity detected. Your account has been flagged.' };
  }

  return { valid: true };
};

// ── Private helpers ────────────────────────────────────────────────────────

const _logSpam = async (userId, uid, roomId, type, severity, details, messageContent, autoAction, ipAddress) => {
  try {
    await SpamLog.create({ userId, uid, roomId, type, severity, details, messageContent, autoAction, ipAddress });
  } catch (_) {
    // Non-blocking; never crash the message handler
  }
};

const _muteChatUser = async (userId, minutes) => {
  try {
    const muteExpiry = new Date(Date.now() + minutes * 60 * 1000);
    await User.findByIdAndUpdate(userId, {
      $set: { chatMutedUntil: muteExpiry },
    });
  } catch (_) {}
};

module.exports = { analyseMessage, validateGameTiming };


// ─── FROM: ip.service.js ────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════
// FILE: src/services/ip.service.js
// ARVIND PARTY - IP INTELLIGENCE SERVICE
// This service checks an IP address against an external API to detect VPNs/Proxies.
// NOTE: This uses a free service for demonstration. For production, use a robust,
// paid service like IPQualityScore, IPinfo.io, or MaxMind.
// ═══════════════════════════════════════════════════════════════════════════

const axios = require('axios');

/**
 * Checks IP information using an external service.
 * @param {string} ipAddress The IP address to check.
 * @returns {Promise<{isVpn: boolean, country: string, city: string, isp: string}>}
 */
const checkIpInfo = async (ipAddress) => {
  // In a production environment, you would use a more reliable, paid API.
  // Example using the free ip-api.com for demonstration purposes.
  // It has a 'proxy' field which can indicate VPN/hosting usage.
  const apiUrl = `http://ip-api.com/json/${ipAddress}?fields=status,message,country,city,isp,proxy`;

  try {
    // Skip checks for local IPs during development
    if (ipAddress === '::1' || ipAddress === '127.0.0.1' || ipAddress.startsWith('192.168.')) {
      return { isVpn: false, country: 'Local', city: 'Local', isp: 'Local Network' };
    }

    const response = await axios.get(apiUrl);
    const data = response.data;

    if (data.status === 'fail') {
      console.warn(`[IP Service] Failed to check IP ${ipAddress}: ${data.message}`);
      return { isVpn: false, country: 'Unknown', city: 'Unknown', isp: 'Unknown' };
    }

    // The 'proxy' field is a boolean indicating if the IP is a known proxy/VPN.
    return {
      isVpn: data.proxy === true,
      country: data.country || 'Unknown',
      city: data.city || 'Unknown',
      isp: data.isp || 'Unknown',
    };
  } catch (error) {
    console.error(`[IP Service] Error checking IP ${ipAddress}:`, error.message);
    // Fail-safe: If the service fails, do not block the user.
    return { isVpn: false, country: 'Unknown', city: 'Unknown', isp: 'Unknown' };
  }
};

module.exports = { checkIpInfo };

// ─── FROM: auditLogService.js ────────────────────────────────────────
const mongoose = require('mongoose');
const AuditLog = require('../../models/AuditLog');
const Logger = require('../../utils/logger');

class AuditLogService {
  constructor() {
    this.isEnabled = process.env.AUDIT_LOGGING_ENABLED !== 'false';
    this.bufferSize = parseInt(process.env.AUDIT_BUFFER_SIZE) || 100;
    this.flushIntervalMs = parseInt(process.env.AUDIT_FLUSH_INTERVAL) || 5000;
    this.logBuffer = [];
    this.flushInterval = null;
    this.retentionDays = parseInt(process.env.AUDIT_RETENTION_DAYS) || 90;
  }

  async initialize() {
    if (!this.isEnabled) {
      Logger.info('Audit Logging Service is disabled');
      return false;
    }

    try {
      this.flushInterval = setInterval(() => {
        this.flush();
      }, this.flushIntervalMs);

      Logger.info('Audit Logging Service initialized', {
        bufferSize: this.bufferSize,
        flushInterval: this.flushIntervalMs,
        retentionDays: this.retentionDays
      });

      return true;
    } catch (error) {
      Logger.error('Audit Logging Service initialization failed', { error: error.message });
      return false;
    }
  }

  log(action, actor, resource, details = {}, severity = 'info') {
    if (!this.isEnabled) return null;

    const logEntry = {
      action,
      actor: {
        userId: actor?.userId || null,
        username: actor?.username || 'system',
        role: actor?.role || 'system',
        ipAddress: actor?.ipAddress || null,
        userAgent: actor?.userAgent || null
      },
      resource: {
        type: resource?.type || 'unknown',
        id: resource?.id || null,
        name: resource?.name || null
      },
      details,
      severity,
      timestamp: new Date(),
      serverId: process.env.SERVER_ID || 'primary'
    };

    this.logBuffer.push(logEntry);

    if (this.logBuffer.length >= this.bufferSize) {
      this.flush();
    }

    Logger.info(`[Audit] ${action}`, {
      userId: logEntry.actor.userId,
      resourceType: logEntry.resource.type,
      severity
    });

    return logEntry;
  }

  async flush() {
    if (this.logBuffer.length === 0) return;

    const entries = [...this.logBuffer];
    this.logBuffer = [];

    try {
      await AuditLog.insertMany(entries, { ordered: false });
      Logger.info(`Flushed ${entries.length} audit log entries`);
    } catch (error) {
      Logger.error('Failed to flush audit logs', { error: error.message });
      this.logBuffer.unshift(...entries.slice(0, 20));
    }
  }

  async query(filters = {}, pagination = {}) {
    const { page = 1, limit = 50 } = pagination;
    const skip = (page - 1) * limit;

    try {
      let query = AuditLog.find();

      if (filters.userId) {
        query = query.where('actor.userId').equals(filters.userId);
      }

      if (filters.action) {
        query = query.where('action').equals(filters.action);
      }

      if (filters.resourceType) {
        query = query.where('resource.type').equals(filters.resourceType);
      }

      if (filters.severity) {
        query = query.where('severity').equals(filters.severity);
      }

      if (filters.startDate && filters.endDate) {
        query = query.where('timestamp').gte(filters.startDate).lte(filters.endDate);
      }

      if (filters.search) {
        query = query.where('details').regex(filters.search, 'i');
      }

      const total = await AuditLog.countDocuments(query.getFilter());
      const logs = await query
        .sort({ timestamp: -1 })
        .skip(skip)
        .limit(limit)
        .exec();

      return {
        logs,
        pagination: {
          page,
          limit,
          total,
          pages: Math.ceil(total / limit)
        }
      };
    } catch (error) {
      Logger.error('Failed to query audit logs', { error: error.message });
      return { logs: [], pagination: { page, limit, total: 0, pages: 0 } };
    }
  }

  async getActivityReport(durationMs = 86400000) {
    try {
      const startDate = new Date(Date.now() - durationMs);
      const pipeline = [
        { $match: { timestamp: { $gte: startDate } } },
        {
          $group: {
            _id: {
              userId: '$actor.userId',
              username: '$actor.username',
              role: '$actor.role'
            },
            actionCount: { $sum: 1 },
            lastAction: { $max: '$timestamp' },
            actions: { $push: '$action' },
            severities: { $push: '$severity' }
          }
        },
        { $sort: { actionCount: -1 } },
        { $limit: 100 }
      ];

      const results = await AuditLog.aggregate(pipeline);

      return results.map(item => ({
        userId: item._id.userId,
        username: item._id.username,
        role: item._id.role,
        actionCount: item.actionCount,
        lastAction: item.lastAction,
        uniqueActions: [...new Set(item.actions)],
        severityBreakdown: this.countSeverities(item.severities)
      }));
    } catch (error) {
      Logger.error('Failed to generate activity report', { error: error.message });
      return [];
    }
  }

  countSeverities(severities) {
    return severities.reduce((acc, severity) => {
      acc[severity] = (acc[severity] || 0) + 1;
      return acc;
    }, {});
  }

  async getResourceAccessHistory(resourceType, resourceId, limit = 50) {
    try {
      const logs = await AuditLog.find({
        'resource.type': resourceType,
        'resource.id': resourceId
      })
        .sort({ timestamp: -1 })
        .limit(limit)
        .exec();

      return logs;
    } catch (error) {
      Logger.error('Failed to fetch resource access history', { error: error.message });
      return [];
    }
  }

  async getSuspiciousActivity(durationMs = 3600000) {
    try {
      const startDate = new Date(Date.now() - durationMs);
      const threshold = 100;

      const pipeline = [
        { $match: { timestamp: { $gte: startDate } } },
        {
          $group: {
            _id: '$actor.userId',
            count: { $sum: 1 },
            actions: { $push: '$action' },
            ipAddresses: { $addToSet: '$actor.ipAddress' },
            resources: { $addToSet: '$resource.type' }
          }
        },
        { $match: { count: { $gt: threshold } } },
        { $sort: { count: -1 } }
      ];

      const suspicious = await AuditLog.aggregate(pipeline);

      return suspicious.map(item => ({
        userId: item._id,
        actionCount: item.count,
        uniqueActions: [...new Set(item.actions)],
        ipAddresses: item.ipAddresses.filter(Boolean),
        resourceTypes: item.resources.filter(Boolean),
        suspicionLevel: item.count > 500 ? 'high' : 'medium'
      }));
    } catch (error) {
      Logger.error('Failed to detect suspicious activity', { error: error.message });
      return [];
    }
  }

  async exportLogs(startDate, endDate, format = 'json') {
    try {
      const filters = { startDate, endDate };
      const result = await this.query(filters, { limit: 10000 });

      if (format === 'csv') {
        const csv = this.convertToCSV(result.logs);
        return { format: 'csv', data: csv };
      }

      return { format: 'json', data: result.logs };
    } catch (error) {
      Logger.error('Failed to export logs', { error: error.message });
      throw error;
    }
  }

  convertToCSV(logs) {
    if (!logs || logs.length === 0) return '';

    const headers = ['Timestamp', 'Action', 'UserId', 'Username', 'Role', 'ResourceType', 'ResourceId', 'Severity'];
    const rows = logs.map(log => [
      log.timestamp,
      log.action,
      log.actor.userId || '',
      log.actor.username || '',
      log.actor.role || '',
      log.resource.type || '',
      log.resource.id || '',
      log.severity || ''
    ]);

    return [headers, ...rows].map(row => row.join(',')).join('\n');
  }

  async cleanupOldLogs() {
    try {
      const cutoffDate = new Date();
      cutoffDate.setDate(cutoffDate.getDate() - this.retentionDays);

      const result = await AuditLog.deleteMany({
        timestamp: { $lt: cutoffDate }
      });

      Logger.info('Old audit logs cleaned up', { deletedCount: result.deletedCount });
      return result.deletedCount;
    } catch (error) {
      Logger.error('Failed to cleanup old audit logs', { error: error.message });
      return 0;
    }
  }

  getStats() {
    return {
      enabled: this.isEnabled,
      bufferedEntries: this.logBuffer.length,
      flushInterval: this.flushIntervalMs,
      retentionDays: this.retentionDays
    };
  }

  stop() {
    if (this.flushInterval) {
      clearInterval(this.flushInterval);
      this.flushInterval = null;
      this.flush();
      Logger.info('Audit Logging Service stopped');
    }
  }
}

module.exports = new AuditLogService();