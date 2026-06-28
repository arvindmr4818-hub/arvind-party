// ═══════════════════════════════════════════════════════════════════════════
// MODULE: room/service.js — Agora Token Generation Service
// Package: agora-token (npm install agora-token)
// ═══════════════════════════════════════════════════════════════════════════

const { RtcTokenBuilder, RtcRole, RtmTokenBuilder } = require('agora-token');

class AgoraService {
  /**
   * Generate RTC token for voice/video rooms
   */
  static generateRtcToken({ channelName, uid, role = 'audience', expireSeconds = 3600 }) {
    const appId = process.env.AGORA_APP_ID;
    const appCertificate = process.env.AGORA_APP_CERTIFICATE;

    if (!appId || !appCertificate) {
      throw new Error('AGORA_APP_ID and AGORA_APP_CERTIFICATE must be set in .env');
    }

    const currentTime = Math.floor(Date.now() / 1000);
    const privilegeExpireTime = currentTime + expireSeconds;
    const rtcRole = role === 'publisher' ? RtcRole.PUBLISHER : RtcRole.SUBSCRIBER;

    const token = RtcTokenBuilder.buildTokenWithUid(
      appId, appCertificate, channelName,
      uid || 0, rtcRole, privilegeExpireTime
    );
    return token;
  }

  /**
   * Generate RTM token for messaging
   */
  static generateRtmToken(userId, expireSeconds = 3600) {
    const appId = process.env.AGORA_APP_ID;
    const appCertificate = process.env.AGORA_APP_CERTIFICATE;
    if (!appId || !appCertificate) throw new Error('Agora credentials missing');

    const currentTime = Math.floor(Date.now() / 1000);
    const token = RtmTokenBuilder.buildToken(
      appId, appCertificate, String(userId),
      currentTime + expireSeconds
    );
    return token;
  }

  static getChannelName(roomId) {
    return `arvind_room_${roomId}`;
  }
}

module.exports = AgoraService;
