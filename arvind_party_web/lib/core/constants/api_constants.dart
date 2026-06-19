// ============================================================
// ARVIND PARTY WEB — API Constants (Full Admin API Map)
// ============================================================

/// Centralized API endpoint configuration
class ApiConstants {
  ApiConstants._();

  // ─── BASE URLS ────────────────────────────────────────────
  static const String baseUrl = 'http://192.168.1.100:5000';
  static const String apiUrl = '$baseUrl/api';
  static const String socketUrl = baseUrl;

  // ─── AUTH & SECURITY ──────────────────────────────────────
  // adminKey loaded from env at runtime — set once at app startup
  static String adminKey = '';
  static const String tokenStorageKey = 'admin_token';
  static const String roleStorageKey = 'staff_role';
  static const String staffDataStorageKey = 'staff_data';

  // ─── AUTH ENDPOINTS ───────────────────────────────────────
  static const String firebaseLogin = '/auth/firebase-login';
  static const String staffLogin = '/staff/login';
  static const String adminAuthLogin = '/admin/auth/login';
  static const String adminAuthLogout = '/admin/auth/logout';
  static const String adminAuthRefresh = '/admin/auth/refresh';

  // ─── DASHBOARD ────────────────────────────────────────────
  static const String adminStats = '/admin/stats';
  static const String liveRooms = '/rooms/live';
  static const String dashboardActivity = '/admin/dashboard/activity';

  // ─── USER MANAGEMENT ─────────────────────────────────────
  static const String users = '/admin/users';
  static const String userDetail = '/admin/users';       // + /:id
  static const String userBlock = '/admin/users/block';
  static const String userUnblock = '/admin/users/unblock';
  static const String userBalance = '/admin/users/balance';
  static const String userVerify = '/admin/users/verify'; // + /:id
  static const String userAdjustCoins = '/admin/users/adjust-coins'; // + /:id

  // ─── ROOM MANAGEMENT ─────────────────────────────────────
  static const String rooms = '/rooms';
  static const String roomClose = '/rooms/close';
  static const String roomBan = '/rooms/ban';              // + /:id

  // ─── GIFT MANAGEMENT ─────────────────────────────────────
  static const String gifts = '/gifts';

  // ─── WALLET MANAGEMENT ───────────────────────────────────
  static const String wallets = '/admin/wallets';
  static const String walletAdjust = '/admin/wallets/adjust'; // + /:userId

  // ─── WITHDRAWALS ─────────────────────────────────────────
  static const String pendingWithdrawals = '/admin/withdrawals/pending';
  static const String processWithdrawal = '/admin/withdrawals/process';
  static const String withdrawalApprove = '/admin/withdrawals/approve'; // + /:id
  static const String withdrawalReject = '/admin/withdrawals/reject';   // + /:id

  // ─── ANNOUNCEMENTS ───────────────────────────────────────
  static const String announcement = '/admin/announcement';
  static const String announcements = '/admin/announcements';

  // ─── STAFF / ADMIN MANAGEMENT ────────────────────────────
  static const String staffList = '/staff/list';
  static const String staffCreate = '/staff/create';
  static const String staffUpdate = '/staff/update';
  static const String staffDelete = '/staff/delete';
  static const String staffSearchUser = '/staff/search-user';
  static const String adminRoles = '/admin/roles';
  static const String adminRoleCreate = '/admin/roles/create';
  static const String adminRoleUpdate = '/admin/roles/update'; // + /:id

  // ─── SETTINGS ────────────────────────────────────────────
  static const String settings = '/admin/settings';

  // ─── COINS ───────────────────────────────────────────────
  static const String coinGenerate = '/admin/coins/generate';
  static const String coinDeduct = '/admin/coins/deduct';

  // ─── REWARDS ─────────────────────────────────────────────
  static const String rewardSend = '/admin/rewards/send';

  // ─── VIP ─────────────────────────────────────────────────
  static const String vipPlans = '/admin/vip/plans';
  static const String vipPlanCreate = '/admin/vip/plans/create';
  static const String vipPlanUpdate = '/admin/vip/plans/update'; // + /:id

  // ─── AGENCY ──────────────────────────────────────────────
  static const String agencies = '/admin/agencies';
  static const String agencyApprove = '/admin/agencies/approve'; // + /:id
  static const String agencyRevoke = '/admin/agencies/revoke';   // + /:id

  // ─── FAMILY ──────────────────────────────────────────────
  static const String families = '/admin/families';

  // ─── REPORTS ─────────────────────────────────────────────
  static const String reports = '/admin/reports';
  static const String reportResolve = '/admin/reports/resolve'; // + /:id

  // ─── BANS ────────────────────────────────────────────────
  static const String bans = '/admin/bans';

  // ─── NOTIFICATIONS ───────────────────────────────────────
  static const String notificationSend = '/admin/notifications/send';
  static const String notificationHistory = '/admin/notifications/history';

  // ─── AUDIT LOGS ──────────────────────────────────────────
  static const String auditLogs = '/admin/audit-logs';

  // ─── EVENTS ──────────────────────────────────────────────
  static const String events = '/admin/events';

  // ─── LEADERBOARD ─────────────────────────────────────────
  static const String leaderboard = '/admin/leaderboard';
  static const String leaderboardReset = '/admin/leaderboard/reset';

  // ─── SUPPORT TICKETS ─────────────────────────────────────
  static const String supportTickets = '/admin/support/tickets';
  static const String supportTicketReply = '/admin/support/tickets/reply'; // + /:id

  // ─── SECURITY ────────────────────────────────────────────
  static const String securityLogins = '/admin/security/logins';
  static const String securityBlockIp = '/admin/security/block-ip';

  // ─── RECHARGE ────────────────────────────────────────────
  static const String recharges = '/admin/recharges';

  // ─── COIN ORDERS ─────────────────────────────────────────
  static const String coinOrders = '/admin/coin-orders';
}