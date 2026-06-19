// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/core/constants/api_constants.dart
// ARVIND PARTY - Master API Endpoints (280 Feature System)
// Uses EnvConfig for base URL - NEVER hardcode secrets
// ═══════════════════════════════════════════════════════════════════════════

import 'env_config.dart';

class ApiConstants {
  static String get baseUrl => EnvConfig.devBaseUrl;
  static String get apiBaseUrl => '$baseUrl/api';
  static String get socketUrl => baseUrl;

  // ═══════ AUTH (1-15) ═══════
  static const String phoneLogin = '/auth/phone-login';
  static const String otpVerify = '/auth/otp-verify';
  static const String googleLogin = '/auth/google-login';
  static const String logout = '/auth/logout';

  // ═══════ USER PROFILE (16-30) ═══════
  static const String profile = '/profile';
  static const String avatar = '/profile/avatar';
  static const String coverPhoto = '/profile/cover-photo';
  static const String bio = '/profile/bio';
  static const String profileVerification = '/profile/verification';
  static const String userStatistics = '/profile/statistics';

  // ═══════ SOCIAL (31-42) ═══════
  static const String follow = '/social/follow';
  static const String followers = '/social/followers';
  static const String following = '/social/following';
  static const String friends = '/social/friends';
  static const String blockUser = '/social/block';
  static const String reportUser = '/social/report';
  static const String userSearch = '/social/search';
  static const String recommendation = '/social/recommendation';

  // ═══════ CHAT (43-57) ═══════
  static const String chats = '/chat';

  // ═══════ VOICE ROOM (58-76) ═══════
  static const String rooms = '/rooms';
  static const String roomCreation = '/rooms/create';
  static const String roomJoin = '/rooms/join';
  static const String roomExit = '/rooms/exit';
  static const String roomSearch = '/rooms/search';
  static const String roomCategories = '/rooms/categories';
  static const String roomSettings = '/rooms/settings';

  // ═══════ SEAT (77-86) ═══════
  static const String seatManagement = '/seats/manage';
  static const String raiseHand = '/seats/raise-hand';

  // ═══════ GIFT (93-104) ═══════
  static const String giftShop = '/gifts/shop';
  static const String giftSending = '/gifts/send';
  static const String giftStatistics = '/gifts/statistics';
  static const String giftLeaderboard = '/gifts/leaderboard';

  // ═══════ WALLET (105-113) ═══════
  static const String wallet = '/wallet';
  static const String recharge = '/wallet/recharge';
  static const String withdrawal = '/wallet/withdrawal';
  static const String walletHistory = '/wallet/history';

  // ═══════ MOMENTS (149-157) ═══════
  static const String momentsFeed = '/moments/feed';
  static const String postCreation = '/moments/post';
  static const String likeSystem = '/moments/like';
  static const String commentSystem = '/moments/comment';

  // ═══════ EVENT (158-163) ═══════
  static const String eventCreation = '/events/create';
  static const String eventListing = '/events/list';

  // ═══════ MISSION (164-168) ═══════
  static const String dailyMissions = '/missions/daily';
  static const String rewardClaims = '/missions/claim';

  // ═══════ LUCKY DRAW (169-172) ═══════
  static const String luckySpin = '/lucky/spin';

  // ═══════ PK BATTLE (173-180) ═══════
  static const String pkMatching = '/pk/match';

  // ═══════ BLIND DATE (181-184) ═══════
  static const String blindMatch = '/match/blind';

  // ═══════ FAMILY (185-192) ═══════
  static const String family = '/family';
  static const String familyCreation = '/family/create';
  static const String familyMembers = '/family/members';
  static const String familyChat = '/family/chat';
  static const String familyLeaderboard = '/family/leaderboard';

  // ═══════ AGENCY (193-199) ═══════
  static const String agency = '/agency';
  static const String agencyCreation = '/agency/create';
  static const String agencyHosts = '/agency/hosts';
  static const String agencyEarnings = '/agency/earnings';

  // ═══════ RANKING (200-207) ═══════
  static const String wealthRanking = '/rankings/wealth';
  static const String charmRanking = '/rankings/charm';
  static const String giftRanking = '/rankings/gift';

  // ═══════ NOTIFICATION (208-212) ═══════
  static const String notifications = '/notifications';

  // ═══════ MEDIA (213-217) ═══════
  static const String youtube = '/media/youtube';

  // ═══════ REFERRAL ═══════
  static const String referral = '/system/referral';
}