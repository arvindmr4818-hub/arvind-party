class AppConstants {
  // ===== APP INFO =====
  static const String appName = 'ARVIND PARTY';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';
  static const String appCopyright = '© 2026 ARVIND PARTY';

  // ===== VALIDATION =====
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 64;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxBioLength = 500;
  static const int maxOtpLength = 6;
  static const int otpResendCooldown = 60;
  static const int sessionTimeoutMinutes = 30;

  // ===== USER UID =====
  static const int minUid = 100000;
  static const int maxUid = 999999999;

  // ===== WALLET =====
  static const int minRechargeAmount = 10;
  static const int maxRechargeAmount = 1000000;

  static const int minWithdrawalAmount = 100;
  static const int maxWithdrawalAmount = 1000000;

  static const double giftCommissionRate = 0.70;
  static const double agencyCommissionRate = 0.15;
  static const double platformCommissionRate = 0.15;

  // ===== LEVEL SYSTEM =====
  static const int maxLevel = 200;
  static const int expPerLevel = 1000;
  static const int dailyExpLimit = 10000;

  // ===== VIP =====
  static const int vipLevels = 10;
  static const int svipLevels = 5;

  // ===== ROOM =====
  static const int defaultSeatCount = 8;
  static const int maxSeatCount = 24;
  static const int roomPasswordLength = 6;
  static const int maxRoomNameLength = 50;
  static const int maxRoomNoticeLength = 500;
  static const int maxRoomMessageLength = 500;

  // ===== CHAT =====
  static const int messagesPerPage = 30;
  static const int maxMessageLength = 2000;
  static const int maxMessageRecallMinutes = 5;

  // ===== VOICE =====
  static const int maxVoiceMessageSeconds = 60;
  static const int maxRecordingSeconds = 300;
  static const int roomMicLimit = 8;

  // ===== FILES =====
  static const int maxFileSizeMB = 20;
  static const int maxImageSizeMB = 10;
  static const int maxVideoSizeMB = 200;

  // ===== MOMENTS =====
  static const int maxPostLength = 5000;
  static const int maxCommentsPerPost = 500;
  static const int maxStoryDurationSeconds = 30;

  // ===== SOCIAL =====
  static const int maxFriends = 5000;
  static const int maxFollowing = 10000;
  static const int maxFollowers = 999999999;

  // ===== FAMILY =====
  static const int maxFamilyMembers = 500;
  static const int maxFamiliesPerUser = 3;

  // ===== AGENCY =====
  static const int maxAgencyHosts = 5000;

  // ===== SECURITY =====
  static const int maxLoginAttempts = 5;
  static const int loginLockoutMinutes = 15;
  static const int maxDevices = 5;

  static const int jwtExpireDays = 30;
  static const int refreshTokenExpireDays = 90;

  // ===== RATE LIMIT =====
  static const int maxMessagesPerMinute = 30;
  static const int maxGiftPerMinute = 50;
  static const int maxRoomCreatePerDay = 20;

  // ===== COINS =====
  static const int maxGiftCombo = 9999;
  static const int maxCoinTransfer = 1000000;

  // ===== STORAGE KEYS =====
  static const String storageToken = 'auth_token';
  static const String storageRefreshToken = 'refresh_token';

  static const String storageUserId = 'user_id';
  static const String storageUid = 'uid';

  static const String storageUserName = 'user_name';
  static const String storageUserAvatar = 'user_avatar';

  static const String storageUserPhone = 'user_phone';
  static const String storageUserEmail = 'user_email';

  static const String storageLanguage = 'language';
  static const String storageTheme = 'theme';

  static const String storageIsLoggedIn = 'is_logged_in';
  static const String storageFirstOpen = 'first_open';

  // ===== SOCKET EVENTS =====
  static const String roomJoinEvent = 'room_join';
  static const String roomLeaveEvent = 'room_leave';
  static const String sendGiftEvent = 'send_gift';
  static const String seatChangeEvent = 'seat_change';
  static const String micStatusEvent = 'mic_status';
  static const String onlineStatusEvent = 'online_status';

  // ===== DEFAULT ASSETS =====
  static const String defaultAvatar =
      'assets/images/default_avatar.png';

  static const String defaultRoomBackground =
      'assets/images/default_room_bg.png';
}