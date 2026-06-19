import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_routes.dart';

// ─── Middleware ──────────────────────────────────────────────
import '../shared/widgets/auth_middleware.dart';
import '../shared/widgets/owner_guard_middleware.dart';
import '../shared/widgets/login_view.dart';

// ─── Auth ────────────────────────────────────────────────────

// ─── Dashboard ───────────────────────────────────────────────
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';

// ─── Users ───────────────────────────────────────────────────
import '../modules/users/bindings/users_binding.dart';
import '../modules/users/views/user_management_view.dart';

// ─── Rooms ───────────────────────────────────────────────────
import '../modules/rooms/bindings/rooms_binding.dart';
import '../modules/rooms/views/room_management_view.dart';

// ─── Gifts ───────────────────────────────────────────────────
import '../modules/gifts/bindings/gifts_binding.dart';
import '../modules/gifts/views/gifts_view.dart';

// ─── Wallets ─────────────────────────────────────────────────
import '../modules/wallet/bindings/wallet_binding.dart';
import '../modules/wallet/views/wallet_view.dart';

// ─── Withdrawals (Owner) ─────────────────────────────────────
import '../modules/withdrawals/bindings/withdrawal_binding.dart';
import '../modules/withdrawals/views/withdrawal_view.dart';

// ─── Recharges ───────────────────────────────────────────────
import '../modules/recharge/bindings/recharge_binding.dart';
import '../modules/recharge/views/recharge_view.dart';

// ─── Rewards ─────────────────────────────────────────────────
import '../modules/rewards/bindings/rewards_binding.dart';
import '../modules/rewards/views/reward_center_view.dart';

// ─── Coin Generation (Owner) ────────────────────────────────
import '../modules/system/bindings/system_binding.dart';
import '../modules/system/views/coin_generation_view.dart';

// ─── Agencies ────────────────────────────────────────────────
import '../modules/agency/bindings/agency_binding.dart';
import '../modules/agency/views/agency_view.dart';

// ─── Families ────────────────────────────────────────────────
import '../modules/family/bindings/family_binding.dart';
import '../modules/family/views/family_view.dart';

// ─── VIP (Owner) ────────────────────────────────────────────
import '../modules/vip/bindings/vip_binding.dart';
import '../modules/vip/views/vip_view.dart';

// ─── Events (Owner) ─────────────────────────────────────────
import '../modules/events/bindings/events_binding.dart';
import '../modules/events/views/events_view.dart';

// ─── Announcements ───────────────────────────────────────────
import '../modules/announcements/bindings/announcements_binding.dart';
import '../modules/announcements/views/announcements_view.dart';

// ─── Reports ─────────────────────────────────────────────────
import '../modules/reports/bindings/reports_binding.dart';
import '../modules/reports/views/reports_view.dart';

// ─── Bans ────────────────────────────────────────────────────
import '../modules/bans/bindings/bans_binding.dart';
import '../modules/bans/views/bans_view.dart';

// ─── Notifications ───────────────────────────────────────────
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notifications_view.dart';

// ─── Leaderboard ─────────────────────────────────────────────
import '../modules/leaderboard/bindings/leaderboard_binding.dart';
import '../modules/leaderboard/views/leaderboard_view.dart';

// ─── Support Tickets ─────────────────────────────────────────
import '../modules/tickets/bindings/tickets_binding.dart';
import '../modules/tickets/views/tickets_view.dart';

// ─── Security (Owner) ───────────────────────────────────────
import '../modules/security/bindings/security_binding.dart';
import '../modules/security/views/security_view.dart';

// ─── Audit Logs (Owner) ─────────────────────────────────────
import '../modules/audit_log/bindings/audit_log_binding.dart';
import '../modules/audit_log/views/audit_log_view.dart';

// ─── Admin Roles (Owner) ────────────────────────────────────
import '../modules/admin_roles/bindings/admin_roles_binding.dart';
import '../modules/admin_roles/views/admin_roles_view.dart';

// ─── Settings (Owner) ───────────────────────────────────────
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';

// ============================================================
// ARVIND PARTY WEB — Route Page Definitions (Full)
// ============================================================

class AppPages {
  AppPages._();

  static Widget _placeholder(String title) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '$title\nComing Soon',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  static final List<GetPage> pages = [
    // ─── AUTH ──────────────────────────────────────────────
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.unauthorized,
      page: () => _placeholder('Access Denied'),
      transition: Transition.fadeIn,
    ),

    // ─── DASHBOARD ─────────────────────────────────────────
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),

    // ─── USER MANAGEMENT ──────────────────────────────────
    GetPage(
      name: AppRoutes.users,
      page: () => const UserManagementView(),
      binding: UsersBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),

    // ─── ROOM MANAGEMENT ──────────────────────────────────
    GetPage(
      name: AppRoutes.rooms,
      page: () => const RoomManagementView(),
      binding: RoomsBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),

    // ─── GIFTS ────────────────────────────────────────────
    GetPage(
      name: AppRoutes.gifts,
      page: () => const GiftsView(),
      binding: GiftsBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),

    // ─── WALLETS ──────────────────────────────────────────
    GetPage(
      name: AppRoutes.wallets,
      page: () => const WalletView(),
      binding: WalletBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),

    // ─── WITHDRAWALS (Owner) ──────────────────────────────
    GetPage(
      name: AppRoutes.withdrawals,
      page: () => const WithdrawalView(),
      binding: WithdrawalBinding(),
      middlewares: [AuthMiddleware(), OwnerGuardMiddleware()],
      transition: Transition.fadeIn,
    ),

    // ─── RECHARGES ────────────────────────────────────────
    GetPage(
      name: AppRoutes.recharges,
      page: () => const RechargeView(),
      binding: RechargeBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),

    // ─── REWARDS ──────────────────────────────────────────
    GetPage(
      name: AppRoutes.rewards,
      page: () => const RewardCenterView(),
      binding: RewardsBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),

    // ─── COIN GENERATION (Owner) ─────────────────────────
    GetPage(
      name: AppRoutes.coinGeneration,
      page: () => const CoinGenerationView(),
      binding: SystemBinding(),
      middlewares: [AuthMiddleware(), OwnerGuardMiddleware()],
      transition: Transition.fadeIn,
    ),

    // ─── AGENCIES ─────────────────────────────────────────
    GetPage(
      name: AppRoutes.agencies,
      page: () => const AgencyView(),
      binding: AgencyBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),

    // ─── FAMILIES ─────────────────────────────────────────
    GetPage(
      name: AppRoutes.families,
      page: () => const FamilyView(),
      binding: FamilyBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),

    // ─── VIP (Owner) ─────────────────────────────────────
    GetPage(
      name: AppRoutes.vip,
      page: () => const VipView(),
      binding: VipBinding(),
      middlewares: [AuthMiddleware(), OwnerGuardMiddleware()],
      transition: Transition.fadeIn,
    ),

    // ─── EVENTS (Owner) ──────────────────────────────────
    GetPage(
      name: AppRoutes.events,
      page: () => const EventsView(),
      binding: EventsBinding(),
      middlewares: [AuthMiddleware(), OwnerGuardMiddleware()],
      transition: Transition.fadeIn,
    ),

    // ─── ANNOUNCEMENTS ───────────────────────────────────
    GetPage(
      name: AppRoutes.announcements,
      page: () => const AnnouncementsView(),
      binding: AnnouncementsBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),

    // ─── REPORTS ──────────────────────────────────────────
    GetPage(
      name: AppRoutes.reports,
      page: () => const ReportsView(),
      binding: ReportsBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),

    // ─── BANS ─────────────────────────────────────────────
    GetPage(
      name: AppRoutes.bans,
      page: () => const BansView(),
      binding: BansBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),

    // ─── NOTIFICATIONS ────────────────────────────────────
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),

    // ─── LEADERBOARD ──────────────────────────────────────
    GetPage(
      name: AppRoutes.leaderboard,
      page: () => const LeaderboardView(),
      binding: LeaderboardBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),

    // ─── SUPPORT TICKETS ──────────────────────────────────
    GetPage(
      name: AppRoutes.tickets,
      page: () => const TicketsView(),
      binding: TicketsBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),

    // ─── SECURITY (Owner) ────────────────────────────────
    GetPage(
      name: AppRoutes.security,
      page: () => const SecurityView(),
      binding: SecurityBinding(),
      middlewares: [AuthMiddleware(), OwnerGuardMiddleware()],
      transition: Transition.fadeIn,
    ),

    // ─── AUDIT LOGS (Owner) ──────────────────────────────
    GetPage(
      name: AppRoutes.auditLogs,
      page: () => const AuditLogView(),
      binding: AuditLogBinding(),
      middlewares: [AuthMiddleware(), OwnerGuardMiddleware()],
      transition: Transition.fadeIn,
    ),

    // ─── ADMIN ROLES (Owner) ─────────────────────────────
    GetPage(
      name: AppRoutes.permissions,
      page: () => const AdminRolesView(),
      binding: AdminRolesBinding(),
      middlewares: [AuthMiddleware(), OwnerGuardMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.adminRoles,
      page: () => const AdminRolesView(),
      binding: AdminRolesBinding(),
      middlewares: [AuthMiddleware(), OwnerGuardMiddleware()],
      transition: Transition.fadeIn,
    ),

    // ─── SYSTEM SETTINGS (Owner) ─────────────────────────
    GetPage(
      name: AppRoutes.systemSettings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      middlewares: [AuthMiddleware(), OwnerGuardMiddleware()],
      transition: Transition.fadeIn,
    ),
  ];
}