// =========================================================================
// MODULE: RANKING — SERVICES
// =========================================================================


// ─── FROM: redisRankingService.js ────────────────────────────────────────
/**
 * Arvind Party - Redis Ranking Service
 * High-performance leaderboard using Redis Sorted Sets
 */

const redis = require('../../config/redis');

class RedisRankingService {
  constructor() {
    this.client = redis;
    this.prefix = 'arvind:ranking:';
    this.TTL = 86400; // 24 hours cache TTL
  }

  // ─── HELPER: Build cache keys ───────────────────────────────────────────────
  _wealthKey(period, country = 'global') {
    return `${this.prefix}wealth:${period}:${country}`;
  }

  _charmKey(period, country = 'global') {
    return `${this.prefix}charm:${period}:${country}`;
  }

  _giftKey(period, country = 'global') {
    return `${this.prefix}gift:${period}:${country}`;
  }

  _familyKey(period, country = 'global') {
    return `${this.prefix}family:${period}:${country}`;
  }

  _agencyKey(period, country = 'global') {
    return `${this.prefix}agency:${period}:${country}`;
  }

  _roomKey(period, country = 'global') {
    return `${this.prefix}room:${period}:${country}`;
  }

  _pkKey(period, country = 'global') {
    return `${this.prefix}pk:${period}:${country}`;
  }

  _richKey(period, country = 'global') {
    return this._wealthKey(period, country);
  }

  _popularKey(period, country = 'global') {
    return this._charmKey(period, country);
  }

  _giftRankKey(giftId, period, country = 'global') {
    return `${this.prefix}gift_item:${giftId}:${period}:${country}`;
  }

  _familyMemberKey(familyId, period) {
    return `${this.prefix}family_member:${familyId}:${period}`;
  }

  // ─── HELPER: Normalize period ──────────────────────────────────────────────
  _normalizePeriod(period) {
    const p = period?.toLowerCase();
    if (!p || ['daily', 'weekly', 'monthly', 'yearly'].includes(p)) {
      return p || 'daily';
    }
    return 'daily';
  }

  // ─── HELPER: Get current period token ─────────────────────────────────────
  _getPeriodToken(period) {
    const now = new Date();
    switch (period) {
      case 'daily': {
        return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;
      }
      case 'weekly': {
        const start = new Date(now);
        start.setDate(now.getDate() - now.getDay());
        start.setHours(0, 0, 0, 0);
        return `${start.getFullYear()}-W${Math.ceil((start.getDate() + new Date(start.getFullYear(), 0, 1).getDay()) / 7)}`;
      }
      case 'monthly': {
        return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
      }
      case 'yearly': {
        return `${now.getFullYear()}`;
      }
      default:
        return this._getPeriodToken('daily');
    }
  }

  // ─── GENERIC: Add or update member in a sorted set ────────────────────────
  async _addToSortedSet(key, memberId, score, metadata = {}) {
    try {
      const payload = JSON.stringify({ memberId, score, metadata });
      await this.client.zAdd(key, { score, value: payload });
      await this.client.expire(key, this.TTL);
      return true;
    } catch (error) {
      console.error(`Redis ZADD Error [${key}]:`, error.message);
      return false;
    }
  }

  // ─── GENERIC: Get top N from sorted set ──────────────────────────────────
  async _getTopFromSortedSet(key, limit = 100, offset = 0) {
    try {
      const results = await this.client.zRange(
        key,
        offset,
        offset + limit - 1,
        'WITHSCORES'
      );

      if (!results || results.length === 0) {
        return [];
      }

      const parsed = [];
      for (let i = 0; i < results.length; i += 2) {
        const payload = results[i];
        const score = parseFloat(results[i + 1]);
        let data = {};
        try {
          data = JSON.parse(payload);
        } catch (e) {
          data = { memberId: payload };
        }
        parsed.push({ ...data, score });
      }

      return parsed.reverse();
    } catch (error) {
      console.error(`Redis ZRANGE Error [${key}]:`, error.message);
      return [];
    }
  }

  // ─── GENERIC: Get rank of a member ───────────────────────────────────────
  async _getMemberRank(key, memberId) {
    try {
      const rank = await this.client.zRevRank(key, memberId);
      if (rank === null) return -1;
      return rank + 1;
    } catch (error) {
      console.error(`Redis ZREVRANK Error [${key}]:`, error.message);
      return -1;
    }
  }

  // ─── GENERIC: Get member score ───────────────────────────────────────────
  async _getMemberScore(key, memberId) {
    try {
      const score = await this.client.zScore(key, memberId);
      return score || 0;
    } catch (error) {
      return 0;
    }
  }

  // ─── GENERIC: Remove member ──────────────────────────────────────────────
  async _removeMember(key, memberId) {
    try {
      await this.client.zRem(key, memberId);
      return true;
    } catch (error) {
      return false;
    }
  }

  // ─── GENERIC: Get count of members ──────────────────────────────────────
  async _getCount(key) {
    try {
      return await this.client.zCard(key);
    } catch (error) {
      return 0;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PUBLIC API - WEALTH RANKING (Diamonds)
  // ═══════════════════════════════════════════════════════════════════════
  async addWealthScore(userId, diamonds, country = 'global', username = '', avatar = '') {
    const period = this._getPeriodToken('daily');
    const key = this._wealthKey('daily', country);
    await this._addToSortedSet(
      key,
      userId,
      diamonds,
      { username, avatar, country, period }
    );
  }

  async getWealthRanking(period = 'daily', country = 'global', limit = 100) {
    const p = this._normalizePeriod(period);
    const key = this._wealthKey(p, country);
    return await this._getTopFromSortedSet(key, limit);
  }

  async getWealthRank(userId, period = 'daily', country = 'global') {
    const p = this._normalizePeriod(period);
    const key = this._wealthKey(p, country);
    return await this._getMemberRank(key, userId);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PUBLIC API - CHARM RANKING (Coins / Top Hosts)
  // ═══════════════════════════════════════════════════════════════════════
  async addCharmScore(userId, coins, country = 'global', username = '', avatar = '') {
    const period = this._getPeriodToken('daily');
    const key = this._charmKey('daily', country);
    await this._addToSortedSet(
      key,
      userId,
      coins,
      { username, avatar, country, period }
    );
  }

  async getCharmRanking(period = 'daily', country = 'global', limit = 100) {
    const p = this._normalizePeriod(period);
    const key = this._charmKey(p, country);
    return await this._getTopFromSortedSet(key, limit);
  }

  async getCharmRank(userId, period = 'daily', country = 'global') {
    const p = this._normalizePeriod(period);
    const key = this._charmKey(p, country);
    return await this._getMemberRank(key, userId);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PUBLIC API - GIFT RANKING (Top Gifts Used)
  // ═══════════════════════════════════════════════════════════════════════
  async addGiftUsage(giftId, userId, value = 1, country = 'global', giftName = '', giftIcon = '') {
    const period = this._getPeriodToken('daily');
    const key = this._giftKey('daily', country);
    await this._addToSortedSet(
      key,
      giftId,
      value,
      { giftName, giftIcon, country, period, giftId }
    );
  }

  async getGiftRanking(period = 'daily', country = 'global', limit = 50) {
    const p = this._normalizePeriod(period);
    const key = this._giftKey(p, country);
    return await this._getTopFromSortedSet(key, limit);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PUBLIC API - FAMILY RANKING
  // ═══════════════════════════════════════════════════════════════════════
  async addFamilyScore(familyId, points, country = 'global', familyName = '', icon = '') {
    const period = this._getPeriodToken('daily');
    const key = this._familyKey('daily', country);
    await this._addToSortedSet(
      key,
      familyId,
      points,
      { familyName, icon, country, period }
    );
  }

  async getFamilyRanking(period = 'daily', country = 'global', limit = 50) {
    const p = this._normalizePeriod(period);
    const key = this._familyKey(p, country);
    return await this._getTopFromSortedSet(key, limit);
  }

  async getFamilyRank(familyId, period = 'daily', country = 'global') {
    const p = this._normalizePeriod(period);
    const key = this._familyKey(p, country);
    return await this._getMemberRank(key, familyId);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PUBLIC API - AGENCY RANKING
  // ═══════════════════════════════════════════════════════════════════════
  async addAgencyScore(agencyId, diamonds, country = 'global', agencyName = '', logo = '') {
    const period = this._getPeriodToken('daily');
    const key = this._agencyKey('daily', country);
    await this._addToSortedSet(
      key,
      agencyId,
      diamonds,
      { agencyName, logo, country, period }
    );
  }

  async getAgencyRanking(period = 'daily', country = 'global', limit = 50) {
    const p = this._normalizePeriod(period);
    const key = this._agencyKey(p, country);
    return await this._getTopFromSortedSet(key, limit);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PUBLIC API - ROOM RANKING
  // ═══════════════════════════════════════════════════════════════════════
  async addRoomScore(roomId, trafficScore, country = 'global', roomName = '', hostName = '') {
    const period = this._getPeriodToken('daily');
    const key = this._roomKey('daily', country);
    await this._addToSortedSet(
      key,
      roomId,
      trafficScore,
      { roomName, hostName, country, period }
    );
  }

  async getRoomRanking(period = 'daily', country = 'global', limit = 50) {
    const p = this._normalizePeriod(period);
    const key = this._roomKey(p, country);
    return await this._getTopFromSortedSet(key, limit);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PUBLIC API - PK BATTLE RANKING
  // ═══════════════════════════════════════════════════════════════════════
  async addPKScore(userId, wins, score, country = 'global', username = '', avatar = '') {
    const period = this._getPeriodToken('daily');
    const key = this._pkKey('daily', country);
    await this._addToSortedSet(
      key,
      userId,
      score,
      { username, avatar, wins, country, period }
    );
  }

  async getPKRanking(period = 'daily', country = 'global', limit = 50) {
    const p = this._normalizePeriod(period);
    const key = this._pkKey(p, country);
    return await this._getTopFromSortedSet(key, limit);
  }

  async getPKUserWins(userId, period = 'daily', country = 'global') {
    const p = this._normalizePeriod(period);
    const key = this._pkKey(p, country);
    const results = await this._getTopFromSortedSet(key, 10000);
    const user = results.find(r => r.memberId === userId);
    return user?.wins || 0;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PUBLIC API - RICH LIST (Top Spenders)
  // ═══════════════════════════════════════════════════════════════════════
  async getRichList(period = 'daily', country = 'global', limit = 100) {
    return await this.getWealthRanking(period, country, limit);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PUBLIC API - POPULAR LIST (Top Earners / Hosts)
  // ═══════════════════════════════════════════════════════════════════════
  async getPopularList(period = 'daily', country = 'global', limit = 100) {
    return await this.getCharmRanking(period, country, limit);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // UTILITY - Get current user's rank across all leaderboards
  // ═══════════════════════════════════════════════════════════════════════
  async getUserAllRanks(userId, country = 'global') {
    const periods = ['daily', 'weekly', 'monthly', 'yearly'];
    const result = {};

    for (const period of periods) {
      result[`${period}_wealth`] = await this.getWealthRank(userId, period, country);
      result[`${period}_charm`] = await this.getCharmRank(userId, period, country);
      result[`${period}_family`] = await this.getFamilyRank(userId, period, country);
    }

    return result;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // UTILITY - Get user's score across all leaderboards
  // ═══════════════════════════════════════════════════════════════════════
  async getUserScores(userId, country = 'global') {
    const wealthKey = this._wealthKey('daily', country);
    const charmKey = this._charmKey('daily', country);

    const wealthScore = await this._getMemberScore(wealthKey, userId);
    const charmScore = await this._getMemberScore(charmKey, userId);

    return {
      wealth: wealthScore,
      charm: charmScore,
      totalScore: wealthScore + charmScore
    };
  }

  // ═══════════════════════════════════════════════════════════════════════
  // MAINTENANCE - Flush all ranking keys for a specific period
  // ═══════════════════════════════════════════════════════════════════════
  async flushPeriod(period) {
    try {
      const p = this._normalizePeriod(period);
      const pattern = `${this.prefix}*:${p}:*`;
      const keys = await this.client.keys(pattern);

      if (keys && keys.length > 0) {
        await this.client.del(keys);
        return { success: true, flushed: keys.length };
      }
      return { success: true, flushed: 0 };
    } catch (error) {
      console.error('Redis Flush Error:', error.message);
      return { success: false, error: error.message };
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // MAINTENANCE - Flush all ranking keys
  // ═══════════════════════════════════════════════════════════════════════
  async flushAll() {
    try {
      const pattern = `${this.prefix}*`;
      const keys = await this.client.keys(pattern);

      if (keys && keys.length > 0) {
        await this.client.del(keys);
        return { success: true, flushed: keys.length };
      }
      return { success: true, flushed: 0 };
    } catch (error) {
      console.error('Redis Flush All Error:', error.message);
      return { success: false, error: error.message };
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // MAINTENANCE - Get stats
  // ═══════════════════════════════════════════════════════════════════════
  async getStats() {
    try {
      const pattern = `${this.prefix}*`;
      const keys = await this.client.keys(pattern);

      const stats = {
        totalKeys: keys.length,
        byPeriod: {},
        byType: {}
      };

      for (const key of keys) {
        const parts = key.split(':');
        const type = parts[2] || 'unknown';
        const period = parts[parts.length - 2] || 'unknown';

        stats.byType[type] = (stats.byType[type] || 0) + 1;
        stats.byPeriod[period] = (stats.byPeriod[period] || 0) + 1;
      }

      return stats;
    } catch (error) {
      return { totalKeys: 0, byPeriod: {}, byType: {} };
    }
  }
}

module.exports = new RedisRankingService();

// ─── FROM: redisRankingIntegration.js ────────────────────────────────────────
/**
 * Arvind Party - Redis Ranking Integration Service
 * Call this from controllers to automatically update rankings when events happen
 */

const redisRankingService = require('./redisRankingService');
const User = require('../../models/User');
const Family = require('../../models/Family');
const Agency = require('../../models/Agency');
const Room = require('../../models/Room');
const Gift = require('../../models/Gift');

class RedisRankingIntegration {
  // ─── GIFT SYSTEM INTEGRATION ─────────────────────────────────────────────
  async onGiftSent(senderId, receiverId, giftId, giftValue, giftName = '', giftIcon = '') {
    try {
      const sender = await User.findById(senderId).select('uid name avatar country');
      const receiver = await User.findById(receiverId).select('uid name avatar country');

      if (sender) {
        await redisRankingService.addWealthScore(
          sender.uid,
          giftValue,
          sender.country || 'global',
          sender.name || sender.username,
          sender.avatar || ''
        );
      }

      if (receiver) {
        await redisRankingService.addCharmScore(
          receiver.uid,
          giftValue,
          receiver.country || 'global',
          receiver.name || receiver.username,
          receiver.avatar || ''
        );
      }

      await redisRankingService.addGiftUsage(
        giftId,
        senderId,
        1,
        sender?.country || 'global',
        giftName,
        giftIcon
      );
    } catch (error) {
      console.error('Gift Ranking Integration Error:', error.message);
    }
  }

  // ─── FAMILY SYSTEM INTEGRATION ──────────────────────────────────────────
  async onFamilyActivity(familyId, points, userId) {
    try {
      const family = await Family.findById(familyId).select('name icon country members');
      if (family && family.country) {
        await redisRankingService.addFamilyScore(
          familyId,
          points,
          family.country,
          family.name,
          family.icon || ''
        );
      }

      if (family && family.members && family.members.length > 0) {
        for (const memberId of family.members) {
          const user = await User.findById(memberId).select('uid name avatar country');
          if (user) {
            await redisRankingService.addCharmScore(
              user.uid,
              points,
              user.country || 'global',
              user.name || user.username,
              user.avatar || ''
            );
          }
        }
      }
    } catch (error) {
      console.error('Family Ranking Integration Error:', error.message);
    }
  }

  // ─── AGENCY SYSTEM INTEGRATION ──────────────────────────────────────────
  async onAgencyDiamondEarned(agencyId, diamonds) {
    try {
      const agency = await Agency.findById(agencyId).select('name logo country');
      if (agency) {
        await redisRankingService.addAgencyScore(
          agencyId,
          diamonds,
          agency.country || 'global',
          agency.name,
          agency.logo || ''
        );
      }
    } catch (error) {
      console.error('Agency Ranking Integration Error:', error.message);
    }
  }

  // ─── ROOM SYSTEM INTEGRATION ────────────────────────────────────────────
  async onRoomActivity(roomId, trafficScore, hostId) {
    try {
      const room = await Room.findById(roomId).select('name hostId country');
      const host = await User.findById(hostId).select('uid name avatar country');

      if (room) {
        await redisRankingService.addRoomScore(
          roomId,
          trafficScore,
          room.country || 'global',
          room.name,
          host?.name || host?.username || 'Unknown'
        );
      }
    } catch (error) {
      console.error('Room Ranking Integration Error:', error.message);
    }
  }

  // ─── PK BATTLE SYSTEM INTEGRATION ───────────────────────────────────────
  async onPKBattleEnded(hostId, opponentId, winnerId, hostScore, opponentScore) {
    try {
      const host = await User.findById(hostId).select('uid name avatar country');
      const opponent = await User.findById(opponentId).select('uid name avatar country');

      if (winnerId) {
        if (winnerId.toString() === hostId.toString() && host) {
          await redisRankingService.addPKScore(
            host.uid,
            1,
            hostScore,
            host.country || 'global',
            host.name || host.username,
            host.avatar || ''
          );
        } else if (winnerId.toString() === opponentId.toString() && opponent) {
          await redisRankingService.addPKScore(
            opponent.uid,
            1,
            opponentScore,
            opponent.country || 'global',
            opponent.name || opponent.username,
            opponent.avatar || ''
          );
        }
      }

      if (host) {
        await redisRankingService.addPKScore(
          host.uid,
          0,
          hostScore,
          host.country || 'global',
          host.name || host.username,
          host.avatar || ''
        );
      }

      if (opponent) {
        await redisRankingService.addPKScore(
          opponent.uid,
          0,
          opponentScore,
          opponent.country || 'global',
          opponent.name || opponent.username,
          opponent.avatar || ''
        );
      }
    } catch (error) {
      console.error('PK Battle Ranking Integration Error:', error.message);
    }
  }

  // ─── BATCH INITIALIZATION FROM MONGODB ──────────────────────────────────
  async initializeAllRankingsFromDB() {
    try {
      console.log('🔄 Initializing rankings from MongoDB...');

      const users = await User.find({ isActive: true, isBanned: false })
        .select('uid name avatar diamonds coins level vipLevel country totalGiftsSent totalGiftsReceived');

      for (const user of users) {
        const country = user.country || 'global';
        await redisRankingService.addWealthScore(
          user.uid,
          user.diamonds,
          country,
          user.name || user.username,
          user.avatar || ''
        );
        await redisRankingService.addCharmScore(
          user.uid,
          user.coins,
          country,
          user.name || user.username,
          user.avatar || ''
        );
      }

      const families = await Family.find({ isActive: true });
      for (const family of families) {
        await redisRankingService.addFamilyScore(
          family._id,
          family.members?.length || 0,
          family.country || 'global',
          family.name,
          family.icon || ''
        );
      }

      const agencies = await Agency.find({ isActive: true });
      for (const agency of agencies) {
        await redisRankingService.addAgencyScore(
          agency._id,
          agency.totalDiamonds || 0,
          agency.country || 'global',
          agency.name,
          agency.logo || ''
        );
      }

      const rooms = await Room.find({ isActive: true });
      for (const room of rooms) {
        await redisRankingService.addRoomScore(
          room._id,
          room.viewerCount || 0,
          room.country || 'global',
          room.name,
          ''
        );
      }

      console.log('✅ Rankings initialized from MongoDB');
      return { success: true, usersInitialized: users.length };
    } catch (error) {
      console.error('Ranking Initialization Error:', error.message);
      return { success: false, error: error.message };
    }
  }

  async initializeGiftRankingsFromDB() {
    try {
      const GiftTransaction = require('../../models/GiftTransaction');
      const transactions = await GiftTransaction.find({})
        .populate('giftId')
        .limit(10000);

      const giftCounts = {};
      for (const tx of transactions) {
        const giftId = tx.giftId?._id?.toString() || tx.giftId?.toString();
        if (!giftId) continue;

        if (!giftCounts[giftId]) {
          giftCounts[giftId] = {
            count: 0,
            giftName: tx.giftId?.name || 'Unknown Gift',
            giftIcon: tx.giftId?.icon || ''
          };
        }
        giftCounts[giftId].count += 1;
      }

      for (const [giftId, data] of Object.entries(giftCounts)) {
        await redisRankingService.addGiftUsage(
          giftId,
          'system',
          data.count,
          'global',
          data.giftName,
          data.giftIcon
        );
      }

      console.log(`✅ Gift rankings initialized: ${Object.keys(giftCounts).length} gifts`);
      return { success: true, giftsInitialized: Object.keys(giftCounts).length };
    } catch (error) {
      console.error('Gift Ranking Initialization Error:', error.message);
      return { success: false, error: error.message };
    }
  }
}

module.exports = new RedisRankingIntegration();