// ═══════════════════════════════════════════════════════════════════════════
// MODULE: room/livekitService.js — LiveKit Token Generation
// FREE & SELF-HOSTED: https://livekit.io
// Install: npm install livekit-server-sdk
// Self-host: docker run -d livekit/livekit-server --config /path/to/config.yaml
// ═══════════════════════════════════════════════════════════════════════════

const { AccessToken, RoomServiceClient } = require('livekit-server-sdk');

class LiveKitService {

  static get apiKey() { return process.env.LIVEKIT_API_KEY; }
  static get apiSecret() { return process.env.LIVEKIT_API_SECRET; }
  static get serverUrl() { return process.env.LIVEKIT_SERVER_URL || 'ws://localhost:7880'; }

  /**
   * Generate LiveKit access token for a user joining a room
   * @param {string} roomName - Room name (e.g. "room_6507abc")
   * @param {string} participantName - Display name of user
   * @param {string} userId - User's MongoDB _id
   * @param {string} role - 'host' | 'cohost' | 'speaker' | 'audience'
   * @param {number} ttl - Token TTL in seconds (default 4 hours)
   */
  static generateToken({ roomName, participantName, userId, role = 'audience', ttl = 14400 }) {
    if (!this.apiKey || !this.apiSecret) {
      throw new Error('LIVEKIT_API_KEY and LIVEKIT_API_SECRET must be set in .env');
    }

    const at = new AccessToken(this.apiKey, this.apiSecret, {
      identity: userId,
      name: participantName,
      ttl,
    });

    // Set permissions based on role
    const canPublish = ['host', 'cohost', 'speaker'].includes(role);
    const canPublishData = true; // Allow data messages for all
    const canSubscribe = true;   // Everyone can listen

    at.addGrant({
      roomJoin: true,
      room: roomName,
      canPublish,
      canPublishData,
      canSubscribe,
      canPublishSources: canPublish ? ['microphone', 'camera', 'screen_share'] : [],
      hidden: role === 'audience', // Audience members are hidden participants
      recorder: false,
    });

    return {
      token: at.toJwt(),
      serverUrl: this.serverUrl,
      roomName,
      identity: userId,
    };
  }

  /**
   * Create a room on LiveKit server
   */
  static async createRoom(roomName, options = {}) {
    if (!this.apiKey || !this.apiSecret) return { success: false, message: 'LiveKit not configured' };
    try {
      const svc = new RoomServiceClient(
        this.serverUrl.replace('ws://', 'http://').replace('wss://', 'https://'),
        this.apiKey,
        this.apiSecret
      );
      const room = await svc.createRoom({
        name: roomName,
        emptyTimeout: options.emptyTimeout || 300,
        maxParticipants: options.maxParticipants || 20,
      });
      return { success: true, room };
    } catch (err) {
      return { success: false, message: err.message };
    }
  }

  /**
   * Get list of participants in a room
   */
  static async getRoomParticipants(roomName) {
    if (!this.apiKey || !this.apiSecret) return [];
    try {
      const svc = new RoomServiceClient(
        this.serverUrl.replace('ws://', 'http://').replace('wss://', 'https://'),
        this.apiKey, this.apiSecret
      );
      return await svc.listParticipants(roomName);
    } catch (err) {
      return [];
    }
  }

  /**
   * Mute a participant (host action)
   */
  static async muteParticipant(roomName, identity, trackSid) {
    try {
      const svc = new RoomServiceClient(
        this.serverUrl.replace('ws://', 'http://').replace('wss://', 'https://'),
        this.apiKey, this.apiSecret
      );
      await svc.mutePublishedTrack(roomName, identity, trackSid, true);
      return { success: true };
    } catch (err) {
      return { success: false, message: err.message };
    }
  }

  /**
   * Remove participant from room
   */
  static async removeParticipant(roomName, identity) {
    try {
      const svc = new RoomServiceClient(
        this.serverUrl.replace('ws://', 'http://').replace('wss://', 'https://'),
        this.apiKey, this.apiSecret
      );
      await svc.removeParticipant(roomName, identity);
      return { success: true };
    } catch (err) {
      return { success: false, message: err.message };
    }
  }

  /**
   * Close/end a room
   */
  static async closeRoom(roomName) {
    try {
      const svc = new RoomServiceClient(
        this.serverUrl.replace('ws://', 'http://').replace('wss://', 'https://'),
        this.apiKey, this.apiSecret
      );
      await svc.deleteRoom(roomName);
      return { success: true };
    } catch (err) {
      return { success: false, message: err.message };
    }
  }

  static getRoomName(roomId) {
    return `arvind_room_${roomId}`;
  }
}

module.exports = LiveKitService;
