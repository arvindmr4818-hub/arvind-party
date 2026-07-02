// ═══════════════════════════════════════════════════════════════════════════
// APP ROUTES — COMPLETE (All pages)
// ═══════════════════════════════════════════════════════════════════════════

class AppRoutes {
  // Core
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String notFound = '/404';

  // Users
  static const String users = '/users';

  // Staff
  static const String staff = '/staff';

  // Rooms
  static const String rooms = '/rooms';

  // Gifts
  static const String gifts = '/gifts';

  // Transactions & Wallet
  static const String transactions = '/transactions';
  static const String wallet = '/wallet';
  static const String walletManagement = '/wallet-management';

  // Coin Manager (OWNER ONLY)
  static const String coinManager = '/coin-manager';
  static const String powerMatrix = '/power-matrix';

  // Agency
  static const String agency = '/agency';
  static const String dealerManagement = '/dealer-management';

  // Reports & Analytics
  static const String reports = '/reports';
  static const String analyticsDashboard = '/analytics-dashboard';

  // Notifications
  static const String notifications = '/notifications';

  // Settings
  static const String settings = '/settings';

  // Support
  static const String support = '/support';

  // Games
  static const String games = '/games';

  // Rankings / Leaderboard
  static const String leaderboard = '/leaderboard';

  // VIP
  static const String vip = '/vip';
  static const String vipAdmin = '/vip-admin';

  // Family
  static const String family = '/family';
  static const String families = '/families';
  static const String familyDetails = '/families/details';

  // Events
  static const String events = '/events';
  static const String luckyDraws = '/events/lucky-draws';
  static const String dailyTasks = '/events/daily-tasks';
  static const String invites = '/events/invites';
  static const String loginStreaks = '/events/login-streaks';
  static const String tournaments = '/tournaments';
  static const String championships = '/championships';
  static const String treasureHunts = '/treasure-hunts';

  // PK Battle
  static const String pkBattleManagement = '/pk-battle-management';

  // Localization
  static const String localization = '/localization';

  // Security
  static const String securityDashboard = '/security';
  static const String securityFraudAlerts = '/security/fraud-alerts';
  static const String securityBannedDevices = '/security/banned-devices';
  static const String securityBlockedIps = '/security/blocked-ips';
  static const String securityAuditLogs = '/security/audit-logs';
  static const String securityLiveThreats = '/security/live-threats';

  // Infrastructure
  static const String infrastructureDashboard = '/infrastructure';
  static const String infrastructureMonitoring = '/infrastructure/monitoring';
  static const String infrastructureScaling = '/infrastructure/scaling';
  static const String infrastructureBackup = '/infrastructure/backup';
  static const String infrastructureErrors = '/infrastructure/errors';
  static const String infrastructureAlerts = '/infrastructure/alerts';
  static const String infrastructureAuditLogs = '/infrastructure/audit-logs';
  static const String infrastructureDeployment = '/infrastructure/deployment';
  static const String infrastructureFeatureFlags = '/infrastructure/feature-flags';
  static const String infrastructureCDN = '/infrastructure/cdn';
}
