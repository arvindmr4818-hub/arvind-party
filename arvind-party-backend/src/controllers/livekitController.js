// ═══════════════════════════════════════════════════════════════════════════
// CONTROLLER: LiveKit Room — replaces agoraController.js
// Routes: /api/room/:roomId/livekit/*
// ═══════════════════════════════════════════════════════════════════════════

const express = require('express');
const router = express.Router();
const LiveKitService = require('../../modules/room/livekitService');
const { protect } = require('../../middlewares/auth.middleware');
const Room = require('../../models/Room');
const RoomSeat = require('../../models/RoomSeat');
const User = require('../../models/User');

// ─── GENERATE TOKEN ────────────────────────────────────────────────────────
// POST /api/room/:roomId/livekit/token
// Flutter app calls this to get token before joining room
router.post('/room/:roomId/livekit/token', protect, async (req, res) => {
  try {
    const { roomId } = req.params;
    const { role = 'audience' } = req.body;
    const userId = req.user._id.toString();

    const [room, user] = await Promise.all([
      Room.findById(roomId).lean(),
      User.findById(userId).select('name avatar').lean(),
    ]);

    if (!room) return res.status(404).json({ success: false, message: 'Room not found' });
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });

    const roomName = LiveKitService.getRoomName(roomId);

    // Determine role: room owner is always host
    const finalRole = room.ownerId?.toString() === userId ? 'host' : role;

    const { token, serverUrl } = LiveKitService.generateToken({
      roomName,
      participantName: user.name,
      userId,
      role: finalRole,
    });

    res.json({
      success: true,
      data: { token, serverUrl, roomName, role: finalRole, userId },
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// ─── GET ROOM PARTICIPANTS ──────────────────────────────────────────────────
// GET /api/room/:roomId/livekit/participants
router.get('/room/:roomId/livekit/participants', protect, async (req, res) => {
  try {
    const { roomId } = req.params;
    const roomName = LiveKitService.getRoomName(roomId);
    const participants = await LiveKitService.getRoomParticipants(roomName);
    res.json({ success: true, data: participants });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// ─── SEAT MANAGEMENT ───────────────────────────────────────────────────────
// POST /api/room/:roomId/seat/occupy
router.post('/room/:roomId/seat/occupy', protect, async (req, res) => {
  try {
    const { roomId } = req.params;
    const { seatNumber } = req.body;
    const userId = req.user._id;

    const room = await Room.findById(roomId);
    if (!room) return res.status(404).json({ success: false, message: 'Room not found' });

    const existing = await RoomSeat.findOne({ roomId, seatNumber, isActive: true });
    if (existing && existing.userId.toString() !== userId.toString()) {
      return res.status(409).json({ success: false, message: 'Seat already occupied' });
    }

    const seat = await RoomSeat.findOneAndUpdate(
      { roomId, userId },
      { roomId, seatNumber, userId, status: 'joined', isActive: true, isAudioEnabled: true, joinedAt: new Date() },
      { upsert: true, new: true }
    ).populate('userId', 'name avatar');

    req.app.get('io')?.to(`room:${roomId}`).emit('seat:occupied', {
      roomId, seatNumber, userId, userName: seat.userId?.name, userAvatar: seat.userId?.avatar,
    });

    res.json({ success: true, data: { seatNumber: seat.seatNumber, userId, status: seat.status } });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// POST /api/room/:roomId/seat/leave
router.post('/room/:roomId/seat/leave', protect, async (req, res) => {
  try {
    const { roomId } = req.params;
    const userId = req.user._id;

    await RoomSeat.findOneAndUpdate(
      { roomId, userId, isActive: true },
      { isActive: false, leftAt: new Date() }
    );

    req.app.get('io')?.to(`room:${roomId}`).emit('seat:vacant', { roomId, userId });
    res.json({ success: true, message: 'Seat released' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// POST /api/room/:roomId/host/mute
router.post('/room/:roomId/host/mute', protect, async (req, res) => {
  try {
    const { roomId } = req.params;
    const { targetUserId, trackSid } = req.body;
    const roomName = LiveKitService.getRoomName(roomId);
    await LiveKitService.muteParticipant(roomName, targetUserId, trackSid);
    req.app.get('io')?.to(`room:${roomId}`).emit('seat:muted', { roomId, userId: targetUserId, mutedBy: req.user._id });
    res.json({ success: true, message: 'User muted' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// POST /api/room/:roomId/host/kick
router.post('/room/:roomId/host/kick', protect, async (req, res) => {
  try {
    const { roomId } = req.params;
    const { targetUserId } = req.body;
    const roomName = LiveKitService.getRoomName(roomId);
    await LiveKitService.removeParticipant(roomName, targetUserId);
    await RoomSeat.findOneAndUpdate({ roomId, userId: targetUserId }, { isActive: false, leftAt: new Date() });
    req.app.get('io')?.to(`room:${roomId}`).emit('user:kicked', { roomId, userId: targetUserId, kickedBy: req.user._id });
    req.app.get('io')?.to(`user:${targetUserId}`).emit('kicked:from-room', { roomId });
    res.json({ success: true, message: 'User removed from room' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// GET /api/room/:roomId/members
router.get('/room/:roomId/members', protect, async (req, res) => {
  try {
    const { roomId } = req.params;
    const seats = await RoomSeat.find({ roomId, isActive: true }).populate('userId', 'name avatar vipLevel');
    const members = seats.map(s => ({
      userId: s.userId?._id, userName: s.userId?.name, userAvatar: s.userId?.avatar,
      vipLevel: s.userId?.vipLevel || 0,
      seat: s.seatNumber, status: s.status,
      isHost: s.isHost, isCoHost: s.isCoHost,
      isAudioEnabled: s.isAudioEnabled, joinedAt: s.joinedAt,
    }));
    res.json({ success: true, data: { members, total: members.length } });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;
