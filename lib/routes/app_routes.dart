// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/routes/app_routes.dart
// ARVIND PARTY - 280 Feature System Master Routes
// ═══════════════════════════════════════════════════════════════════════════

abstract class AppRoutes {
  // ═══════ CORE AUTH (1-15) ═══════
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const phoneAuth = '/phone-auth';
  static const otp = '/otp-screen';
  static const emailLogin = '/email-login';
  static const googleLogin = '/google-login';
  static const facebookLogin = '/facebook-login';
  static const appleLogin = '/apple-login';
  static const guestLogin = '/guest-login';
  static const passwordReset = '/password-reset';
  static const deviceBinding = '/device-binding';
  static const sessionManagement = '/session-management';
  static const multiDeviceControl = '/multi-device-control';
  static const accountSecurity = '/account-security';
  static const logout = '/logout';

  // ═══════ VIP SYSTEM (16-18) ═══════
  static const vip = '/vip';

  // ═══════ USER PROFILE (28-42) ═══════
  static const home = '/home';
  static const profile = '/profile';
  static const editProfile = '/edit-profile';
  static const userProfile = '/user-profile';
  static const uid = '/uid';
  static const avatar = '/avatar';
  static const coverPhoto = '/cover-photo';
  static const bio = '/bio';
  static const gender = '/gender';
  static const country = '/country';
  static const language = '/language';
  static const onlineStatus = '/online-status';
  static const lastSeen = '/last-seen';
  static const profileVerification = '/profile-verification';
  static const myProfile = '/my-profile';
  static const otherProfile = '/other-profile';
  static const vipProfile = '/vip-profile';
  static const personalTags = '/personal-tags';
  static const profileVisitors = '/profile-visitors';
  static const userStatistics = '/user-statistics';

  // ═══════ SOCIAL (31-42) ═══════
  static const follow = '/follow';
  static const followers = '/followers';
  static const following = '/following';
  static const friends = '/friends';
  static const friendSearch = '/friend-search';
  static const blockUser = '/block-user';
  static const reportUser = '/report-user';
  static const visitorSystem = '/visitor-system';
  static const mention = '/mention';
  static const userSearch = '/user-search';
  static const advancedSearch = '/advanced-search';
  static const nearbyUsers = '/nearby-users';
  static const recommendation = '/recommendation';

  // ═══════ CHAT (43-57) ═══════
  static const chat = '/chat';
  static const privateChat = '/private-chat';
  static const imageChat = '/image-chat';
  static const voiceMessage = '/voice-message';
  static const videoMessage = '/video-message';
  static const fileSharing = '/file-sharing';
  static const emoji = '/emoji';
  static const stickers = '/stickers';
  static const gif = '/gif';
  static const chatTranslation = '/chat-translation';
  static const messageRecall = '/message-recall';
  static const messageDelete = '/message-delete';
  static const chatPin = '/chat-pin';
  static const chatMute = '/chat-mute';
  static const readReceipt = '/read-receipt';
  static const typingIndicator = '/typing-indicator';

  // ═══════ ROOM FEATURE (Complete Room System) ═══════
  static const roomList = '/room-list';
  static const roomDetail = '/room-detail';
  static const roomCreate = '/room-create';
  static const roomEdit = '/room-edit';
  static const roomSettingsFull = '/room-settings';

  // ═══════ VOICE ROOM (58-76) ═══════
  static const voiceRoom = '/voice-room';
  static const publicRoom = '/public-room';
  static const privateRoom = '/private-room';
  static const passwordRoom = '/password-room';
  static const roomCreation = '/room-creation';
  static const createRoom = '/create-room';
  static const roomJoin = '/room-join';
  static const roomExit = '/room-exit';
  static const roomSearch = '/room-search';
  static const roomRecommendation = '/room-recommendation';
  static const roomCategories = '/room-categories';
  static const hostControls = '/host-controls';
  static const coHostControls = '/co-host-controls';
  static const moderatorControls = '/moderator-controls';
  static const audienceControls = '/audience-controls';
  static const roomSettings = '/room-settings';
  static const roomLock = '/room-lock';
  static const roomNotice = '/room-notice';
  static const roomBackground = '/room-background';
  static const roomAnalytics = '/room-analytics';

  // ═══════ SEAT (77-86) ═══════
  static const seatManagement = '/seat-management';
  static const seatLock = '/seat-lock';
  static const seatUnlock = '/seat-unlock';
  static const seatMicOn = '/seat-mic-on';
  static const seatMicOff = '/seat-mic-off';
  static const seatTransfer = '/seat-transfer';
  static const raiseHand = '/raise-hand';
  static const seatQueue = '/seat-queue';
  static const inviteToSeat = '/invite-to-seat';
  static const removeFromSeat = '/remove-from-seat';

  // ═══════ ROOM CHAT (87-92) ═══════
  static const roomMessages = '/room-messages';
  static const barrageMessages = '/barrage-messages';
  static const announcement = '/announcement';
  static const roomEmojis = '/room-emojis';
  static const roomReactions = '/room-reactions';
  static const roomPolls = '/room-polls';

  // ═══════ GIFT (93-104) ═══════
  static const giftShop = '/gift-shop';
  static const staticGifts = '/static-gifts';
  static const animatedGifts = '/animated-gifts';
  static const comboGifts = '/combo-gifts';
  static const luckyGifts = '/lucky-gifts';
  static const giftInventory = '/gift-inventory';
  static const giftSending = '/gift-sending';
  static const giftReceiving = '/gift-receiving';
  static const giftStatistics = '/gift-statistics';
  static const giftLeaderboard = '/gift-leaderboard';
  static const giftBroadcast = '/gift-broadcast';
  static const giftEffects = '/gift-effects';

  // ═══════ WALLET (105-113) ═══════
  static const wallet = '/wallet';
  static const coinWallet = '/coin-wallet';
  static const diamondWallet = '/diamond-wallet';
  static const recharge = '/recharge';
  static const withdrawal = '/withdrawal';
  static const walletHistory = '/wallet-history';
  static const walletLogs = '/wallet-logs';
  static const treasury = '/treasury';
  static const transactionAudit = '/transaction-audit';
  static const rewardWallet = '/reward-wallet';

  // ═══════ VIP (114-119) ═══════
  static const vipLevels = '/vip-levels';
  static const vipSubscription = '/vip-subscription';
  static const vipBenefits = '/vip-benefits';
  static const vipBadge = '/vip-badge';
  static const vipEntryEffect = '/vip-entry-effect';
  static const vipPrivileges = '/vip-privileges';

  // ═══════ LEVEL (120-125) ═══════
  static const userLevel = '/user-level';
  static const roomLevel = '/room-level';
  static const hostLevel = '/host-level';
  static const wealthLevel = '/wealth-level';
  static const charmLevel = '/charm-level';
  static const experience = '/experience';

  // ═══════ BADGE (126-130) ═══════
  static const achievementBadges = '/achievement-badges';
  static const eventBadges = '/event-badges';
  static const vipBadges = '/vip-badges';
  static const agencyBadges = '/agency-badges';
  static const familyBadges = '/family-badges';

  // ═══════ FRAME (131-134) ═══════
  static const avatarFrames = '/avatar-frames';
  static const chatFrames = '/chat-frames';
  static const profileFrames = '/profile-frames';
  static const premiumFrames = '/premium-frames';

  // ═══════ SHOP (135-140) ═══════
  static const shop = '/shop';
  static const frameShop = '/frame-shop';
  static const badgeShop = '/badge-shop';
  static const carShop = '/car-shop';
  static const entranceShop = '/entrance-shop';
  static const bubbleShop = '/bubble-shop';
  static const effectShop = '/effect-shop';

  // ═══════ ENTRANCE EFFECT (141-144) ═══════
  static const userEntrance = '/user-entrance';
  static const vipEntrance = '/vip-entrance';
  static const animatedEntrance = '/animated-entrance';
  static const globalEntrance = '/global-entrance';

  // ═══════ CAR (145-148) ═══════
  static const carCollection = '/car-collection';
  static const carPurchase = '/car-purchase';
  static const carDisplay = '/car-display';
  static const carUpgrade = '/car-upgrade';

  // ═══════ MOMENTS (149-157) ═══════
  static const momentsFeed = '/moments-feed';
  static const postCreation = '/post-creation';
  static const imagePost = '/image-post';
  static const videoPost = '/video-post';
  static const likeSystem = '/like-system';
  static const commentSystem = '/comment-system';
  static const shareSystem = '/share-system';
  static const momentsMention = '/moments-mention';
  static const hashtag = '/hashtag';

  // ═══════ EVENT (158-163) ═══════
  static const eventCreation = '/event-creation';
  static const eventListing = '/event-listing';
  static const eventJoin = '/event-join';
  static const eventRewards = '/event-rewards';
  static const eventRankings = '/event-rankings';
  static const eventHistory = '/event-history';

  // ═══════ MISSION (164-168) ═══════
  static const dailyMissions = '/daily-missions';
  static const weeklyMissions = '/weekly-missions';
  static const monthlyMissions = '/monthly-missions';
  static const achievementMissions = '/achievement-missions';
  static const rewardClaims = '/reward-claims';

  // ═══════ LUCKY DRAW (169-172) ═══════
  static const luckySpin = '/lucky-spin';
  static const wheelRewards = '/wheel-rewards';
  static const jackpotRewards = '/jackpot-rewards';
  static const drawHistory = '/draw-history';

  // ═══════ PK BATTLE (173-180) ═══════
  static const pkMatching = '/pk-matching';
  static const pkRooms = '/pk-rooms';
  static const pkTimer = '/pk-timer';
  static const pkGifts = '/pk-gifts';
  static const pkScore = '/pk-score';
  static const pkPunishment = '/pk-punishment';
  static const pkLeaderboard = '/pk-leaderboard';
  static const pkHistory = '/pk-history';

  // ═══════ BLIND DATE (181-184) ═══════
  static const blindMatch = '/blind-match';
  static const voiceMatch = '/voice-match';
  static const randomMatch = '/random-match';
  static const matchHistory = '/match-history';

  // ═══════ FAMILY (185-192) ═══════
  static const family = '/family';
  static const familyCreation = '/family-creation';
  static const familyMembers = '/family-members';
  static const familyRoles = '/family-roles';
  static const familyChat = '/family-chat';
  static const familyWallet = '/family-wallet';
  static const familyLeaderboard = '/family-leaderboard';
  static const familyTasks = '/family-tasks';
  static const familyWars = '/family-wars';

  // ═══════ AGENCY (193-199) ═══════
  static const agency = '/agency';
  static const agencyCreation = '/agency-creation';
  static const agencyPanel = '/agency-panel';
  static const agencyHosts = '/agency-hosts';
  static const agencyEarnings = '/agency-earnings';
  static const agencyWallet = '/agency-wallet';
  static const agencyCommission = '/agency-commission';
  static const agencyLeaderboard = '/agency-leaderboard';

  // ═══════ RANKING (200-207) ═══════
  static const wealthRanking = '/wealth-ranking';
  static const charmRanking = '/charm-ranking';
  static const giftRanking = '/gift-ranking';
  static const hostRanking = '/host-ranking';
  static const roomRanking = '/room-ranking';
  static const agencyRanking = '/agency-ranking';
  static const familyRankingPage = '/family-ranking-page';
  static const pkRankingPage = '/pk-ranking-page';

  // ═══════ NOTIFICATION (208-212) ═══════
  static const notifications = '/notifications';
  static const pushNotifications = '/push-notifications';
  static const inAppNotifications = '/in-app-notifications';
  static const systemNotifications = '/system-notifications';
  static const giftNotifications = '/gift-notifications';
  static const eventNotifications = '/event-notifications';

  // ═══════ MEDIA (213-217) ═══════
  static const youtube = '/youtube';
  static const mp3Player = '/mp3-player';
  static const playlist = '/playlist';
  static const backgroundMusic = '/background-music';
  static const roomMusic = '/room-music';

  // ═══════ GAMES (218-221) ═══════
  static const games = '/games';
  static const gameCenter = '/game-center';
  static const luckyNumber = '/lucky-number';
  static const diceGame = '/dice-game';
  static const miniCompetitions = '/mini-competitions';

  // ═══════ SAFETY (222-227) ═══════
  static const userReport = '/user-report';
  static const userBan = '/user-ban';
  static const roomBan = '/room-ban';
  static const muteUser = '/mute-user';
  static const blacklist = '/blacklist';
  static const contentModeration = '/content-moderation';

  // ═══════ COIN SELLER ═══════
  static const coinSeller = '/coin-seller';
  static const coinSellerProfile = '/coin-seller-profile';
  static const coinSellerRanking = '/coin-seller-ranking';
  static const rechargeHistory = '/recharge-history-cs';
  static const settlementHistory = '/settlement-history';

  // ═══════ OWNER PANEL (228-233) ═══════
  static const ownerDashboard = '/owner-dashboard';
  static const globalAnalytics = '/global-analytics';
  static const revenueAnalytics = '/revenue-analytics';
  static const treasuryControl = '/treasury-control';
  static const staffControl = '/staff-control';
  static const systemSettings = '/system-settings';

  // ═══════ ADMIN PANEL (234-239) ═══════
  static const userManagement = '/user-management';
  static const roomManagement = '/room-management';
  static const giftManagement = '/gift-management';
  static const eventManagement = '/event-management';
  static const walletManagement = '/wallet-management';
  static const agencyAdminPanel = '/agency-admin-panel';

  // ═══════ STAFF MANAGEMENT (240-253) ═══════
  static const ownerWeb = '/owner-web';
  static const appAdminWeb = '/app-admin-web';
  static const globalManagerWeb = '/global-manager-web';
  static const countryManagerWeb = '/country-manager-web';
  static const superAdminUid = '/super-admin-uid';
  static const adminUid = '/admin-uid';
  static const bdUid = '/bd-uid';
  static const superCoinSellerUid = '/super-coin-seller-uid';
  static const normalCoinSellerUid = '/normal-coin-seller-uid';
  static const csCustomerServiceUid = '/cs-customer-service-uid';
  static const csLeaderUid = '/cs-leader-uid';
  static const ownerAssistantUid = '/owner-assistant-uid';
  static const adminAssistantUid = '/admin-assistant-uid';
  static const globalManagerAssistantUid = '/global-manager-assistant-uid';

  // ═══════ SYSTEM CORE (254-280) ═══════
  static const socketIo = '/socket-io';
  static const realTimePresence = '/real-time-presence';
  static const auditLogs = '/audit-logs';
  static const activityLogs = '/activity-logs';
  static const rolePermissions = '/role-permissions';
  static const securityCenter = '/security-center';
  static const backupSystem = '/backup-system';
  static const monitoringSystem = '/monitoring-system';
  static const apiManagement = '/api-management';
  static const databaseManagement = '/database-management';
  static const cdnMediaSystem = '/cdn-media-system';
  static const cloudStorageSystem = '/cloud-storage-system';
  static const adminActionsTracking = '/admin-actions-tracking';
  static const revenueManagement = '/revenue-management';
  static const commissionEngine = '/commission-engine';
  static const rewardEngine = '/reward-engine';
  static const antiFraud = '/anti-fraud';
  static const antiSpam = '/anti-spam';
  static const multiLanguage = '/multi-language';
  static const localization = '/localization';
  static const theme = '/theme';
  static const darkMode = '/dark-mode';
  static const updateSystem = '/update-system';
  static const appConfig = '/app-config';
  static const maintenanceMode = '/maintenance-mode';
  static const systemAnnouncement = '/system-announcement';
  static const referral = '/referral';

  // ═══════ LEGACY ═══════
  static const events = '/events';
  static const search = '/search';
  static const pkBattle = '/pk-battle';
  static const userCenter = '/user-center';
  static const completeProfile = '/complete-profile';
  static const withdrawalManagement = '/withdrawal-management';
}
