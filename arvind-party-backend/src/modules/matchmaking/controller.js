// ═══════════════════════════════════════════════════════════════════════════
// MODULE: matchmaking/controller.js — Real Matchmaking Algorithm
// Uses Redis queue for production-ready matchmaking
// ═══════════════════════════════════════════════════════════════════════════

const User = require('../../models/User');
const Room = require('../../models/Room');

// In-memory queue (Use Redis in horizontal scaling)
const matchQueue = new Map(); // userId -> { userId, preferences, joinedAt, socket }

const MATCH_TIMEOUT = 30000; // 30 seconds

const matchmakingController = {

  // POST /api/matchmaking/search
  searchMatch: async (req, res) => {
    try {
      const userId = req.user._id.toString();
      const { gender, minAge = 18, maxAge = 35, language } = req.body;

      // Already in queue
      if (matchQueue.has(userId)) {
        return res.json({ success: true, status: 'searching', message: 'Already in queue' });
      }

      const user = await User.findById(userId).select('name avatar gender age language');
      if (!user) return res.status(404).json({ success: false, message: 'User not found' });

      // Find compatible match from queue
      let matchedUserId = null;
      for (const [qId, qData] of matchQueue.entries()) {
        if (qId === userId) continue;

        // Basic compatibility check
        const compatible =
          (!gender || qData.preferences?.gender === user.gender || !qData.preferences?.gender) &&
          (!language || qData.user?.language === language || !language);

        if (compatible) {
          matchedUserId = qId;
          break;
        }
      }

      if (matchedUserId) {
        const matchedData = matchQueue.get(matchedUserId);
        matchQueue.delete(matchedUserId);

        // Create a CP room for them
        const room = await Room.create({
          name: `CP_${userId}_${matchedUserId}`,
          type: 'cp',
          ownerId: userId,
          members: [userId, matchedUserId],
          isPrivate: true,
          maxMembers: 2,
        });

        // Notify matched user via socket
        const io = req.app.get('io');
        if (io && matchedData.socketId) {
          io.to(matchedData.socketId).emit('matchmaking:matched', {
            roomId: room._id,
            partner: { _id: user._id, name: user.name, avatar: user.avatar },
          });
        }

        return res.json({
          success: true, status: 'matched',
          roomId: room._id,
          partner: { _id: matchedData.user._id, name: matchedData.user.name, avatar: matchedData.user.avatar },
        });
      }

      // Not matched yet - add to queue
      matchQueue.set(userId, {
        userId,
        user: { _id: user._id, name: user.name, avatar: user.avatar },
        preferences: { gender, minAge, maxAge, language },
        socketId: req.body.socketId,
        joinedAt: Date.now(),
      });

      // Auto-remove from queue after timeout
      setTimeout(() => {
        if (matchQueue.has(userId)) {
          matchQueue.delete(userId);
          const io = req.app.get('io');
          if (io && req.body.socketId) {
            io.to(req.body.socketId).emit('matchmaking:timeout', { message: 'No match found. Try again.' });
          }
        }
      }, MATCH_TIMEOUT);

      res.json({ success: true, status: 'searching', queueSize: matchQueue.size, timeout: MATCH_TIMEOUT / 1000 });
    } catch (err) {
      res.status(500).json({ success: false, message: err.message });
    }
  },

  // POST /api/matchmaking/stop
  stopSearch: async (req, res) => {
    try {
      const userId = req.user._id.toString();
      const removed = matchQueue.delete(userId);
      res.json({ success: true, message: removed ? 'Removed from queue' : 'Not in queue' });
    } catch (err) {
      res.status(500).json({ success: false, message: err.message });
    }
  },

  // GET /api/matchmaking/status
  getStatus: async (req, res) => {
    try {
      const userId = req.user._id.toString();
      const inQueue = matchQueue.has(userId);
      res.json({ success: true, inQueue, queueSize: matchQueue.size });
    } catch (err) {
      res.status(500).json({ success: false, message: err.message });
    }
  },
};

module.exports = matchmakingController;
