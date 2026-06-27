// ═══════════════════════════════════════════════════════════════════════════
// APP PAGES — COMPLETE (All 30+ pages registered)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../core/constants/auth_controller.dart';
import '../core/services/api_service.dart';
import '../core/services/role_permission_service.dart';
import '../core/theme/web_theme.dart';
import 'app_routes.dart';

// Existing imports
import '../modules/dashboard/dashboard_view.dart';
import '../modules/vip/views/vip_admin_view.dart';
import '../modules/family_management/family_management_view.dart';
import '../modules/security/security_dashboard_view.dart';
import '../modules/security/security_binding.dart';
import '../modules/events/event_management_view.dart';
import '../modules/events/lucky_draw_management_view.dart';
import '../modules/events/daily_task_management_view.dart';
import '../modules/events/invite_management_view.dart';
import '../modules/events/login_streak_management_view.dart';
import '../modules/analytics/views/analytics_dashboard_view.dart';
import '../modules/analytics/bindings/analytics_binding.dart';
import '../modules/localization/localization_management_view.dart';
import '../modules/wallets/wallet_management_view.dart';
import '../modules/pk_battle/pk_battle_management_view.dart';

// New complete page imports
import '../modules/shared/admin_shell.dart';
import '../modules/users/user_management_view.dart';
import '../modules/staff_management/staff_management_view.dart';
import '../modules/gifts/gifts_management_view.dart';
import '../modules/transactions/transactions_view.dart';
import '../modules/rooms/rooms_admin_view.dart';
import '../modules/notifications/notifications_admin_view.dart';
import '../modules/reports/reports_view.dart';
import '../modules/settings/settings_view.dart';
import '../modules/support/support_view.dart';
import '../modules/games/games_admin_view.dart';
import '../modules/leaderboard/leaderboard_admin_view.dart';
import '../modules/coin_manager/coin_manager_view.dart';
import '../modules/agency/agency_view.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),
    GetPage(name: AppRoutes.dashboard, page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController(), fenix: true);
        Get.lazyPut(() => ApiService(), fenix: true);
        Get.lazyPut(() => RolePermissionService(), fenix: true);
      })),

    // ─── USER MANAGEMENT ──────────────────────────────────────────────
    GetPage(name: AppRoutes.users, page: () => const UserManagementView()),

    // ─── STAFF ────────────────────────────────────────────────────────
    GetPage(name: AppRoutes.staff, page: () => const StaffManagementView()),

    // ─── GIFTS ────────────────────────────────────────────────────────
    GetPage(name: AppRoutes.gifts, page: () => const GiftsManagementView()),

    // ─── TRANSACTIONS ─────────────────────────────────────────────────
    GetPage(name: AppRoutes.transactions, page: () => const TransactionsView()),

    // ─── ROOMS ────────────────────────────────────────────────────────
    GetPage(name: AppRoutes.rooms, page: () => const RoomsAdminView()),

    // ─── NOTIFICATIONS ────────────────────────────────────────────────
    GetPage(name: AppRoutes.notifications, page: () => const NotificationsAdminView()),

    // ─── REPORTS ──────────────────────────────────────────────────────
    GetPage(name: AppRoutes.reports, page: () => const ReportsView()),

    // ─── SETTINGS ─────────────────────────────────────────────────────
    GetPage(name: AppRoutes.settings, page: () => const SettingsView()),

    // ─── SUPPORT ──────────────────────────────────────────────────────
    GetPage(name: AppRoutes.support, page: () => const SupportView()),

    // ─── GAMES ────────────────────────────────────────────────────────
    GetPage(name: AppRoutes.games, page: () => const GamesAdminView()),

    // ─── LEADERBOARD ──────────────────────────────────────────────────
    GetPage(name: AppRoutes.leaderboard, page: () => const LeaderboardAdminView()),

    // ─── COIN MANAGER (OWNER ONLY) ────────────────────────────────────
    GetPage(name: AppRoutes.coinManager, page: () => const CoinManagerView()),

    // ─── AGENCY ───────────────────────────────────────────────────────
    GetPage(name: AppRoutes.agency, page: () => const AgencyView()),

    // ─── Existing routes ──────────────────────────────────────────────
    GetPage(name: AppRoutes.securityDashboard, page: () => const SecurityDashboardView(), binding: SecurityBinding()),
    GetPage(name: AppRoutes.vipAdmin, page: () => const VipAdminView()),
    GetPage(name: AppRoutes.families, page: () => const FamilyManagementView()),
    GetPage(name: AppRoutes.events, page: () => const EventManagementView()),
    GetPage(name: AppRoutes.luckyDraws, page: () => const LuckyDrawManagementView()),
    GetPage(name: AppRoutes.dailyTasks, page: () => const DailyTaskManagementView()),
    GetPage(name: AppRoutes.invites, page: () => const InviteManagementView()),
    GetPage(name: AppRoutes.loginStreaks, page: () => const LoginStreakManagementView()),
    GetPage(name: AppRoutes.analyticsDashboard, page: () => const AnalyticsDashboardView(), binding: AnalyticsBinding()),
    GetPage(name: AppRoutes.localization, page: () => const LocalizationManagementView()),
    GetPage(name: AppRoutes.walletManagement, page: () => const WalletManagementView()),
    GetPage(name: AppRoutes.pkBattleManagement, page: () => PkBattleManagementView()),

    // ─── 404 ──────────────────────────────────────────────────────────
    GetPage(name: AppRoutes.notFound, page: () => const NotFoundPage()),
  ];
}

// ─── LOGIN PAGE ───────────────────────────────────────────────────────────
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  late AuthController _auth;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _auth = Get.put(AuthController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      body: Row(children: [
        // Left branding panel
        Expanded(child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF0F0E1A), Color(0xFF1A0A2E)]),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 80, height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF8906), Color(0xFFFF6B00)]),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: const Color(0xFFFF8906).withOpacity(0.3), blurRadius: 30, spreadRadius: 5)]),
              child: const Icon(Icons.local_party_mode, color: Colors.white, size: 40)),
            const SizedBox(height: 24),
            const Text('Arvind Party', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Admin Control Center', style: TextStyle(color: Color(0xFF6B7280), fontSize: 16)),
            const SizedBox(height: 60),
            _featureRow(Icons.people_rounded, 'Manage 1M+ Users'),
            const SizedBox(height: 16),
            _featureRow(Icons.security_rounded, 'Real-time Security Monitoring'),
            const SizedBox(height: 16),
            _featureRow(Icons.analytics_rounded, 'Advanced Analytics'),
            const SizedBox(height: 16),
            _featureRow(Icons.monetization_on_rounded, 'Revenue Management'),
          ]),
        )),
        // Right login form
        SizedBox(width: 480, child: Container(
          color: const Color(0xFF0F0E1A),
          padding: const EdgeInsets.all(48),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Welcome back', style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
            const SizedBox(height: 4),
            const Text('Sign in to Admin Panel', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            const Text('Username', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter admin username',
                hintStyle: const TextStyle(color: Color(0xFF3A3A4A)),
                prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF6B7280)),
                filled: true, fillColor: const Color(0xFF1A1928),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E1D2F))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E1D2F))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF8906))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Password', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            StatefulBuilder(builder: (ctx, setS) => TextField(
              controller: _passwordCtrl,
              obscureText: _obscure,
              style: const TextStyle(color: Colors.white),
              onSubmitted: (_) => _login(),
              decoration: InputDecoration(
                hintText: 'Enter password',
                hintStyle: const TextStyle(color: Color(0xFF3A3A4A)),
                prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6B7280)),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF6B7280)),
                  onPressed: () => setS(() => _obscure = !_obscure)),
                filled: true, fillColor: const Color(0xFF1A1928),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E1D2F))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E1D2F))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF8906))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            )),
            const SizedBox(height: 32),
            Obx(() => SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _auth.isLoading.value ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8906),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0),
                child: _auth.isLoading.value
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )),
            Obx(() => _auth.errorMessage.value.isNotEmpty
              ? Padding(padding: const EdgeInsets.only(top: 16),
                child: Container(padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFFF4757).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFF4757).withOpacity(0.3))),
                  child: Row(children: [
                    const Icon(Icons.error_outline, color: Color(0xFFFF4757), size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_auth.errorMessage.value,
                      style: const TextStyle(color: Color(0xFFFF4757), fontSize: 13))),
                  ])))
              : const SizedBox()),
          ]),
        )),
      ]),
    );
  }

  Widget _featureRow(IconData icon, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, color: const Color(0xFFFF8906), size: 18),
    const SizedBox(width: 12),
    Text(label, style: const TextStyle(color: Color(0xFFB8B8D1), fontSize: 14)),
  ]);

  Future<void> _login() async {
    final ok = await _auth.login(_usernameCtrl.text.trim(), _passwordCtrl.text);
    if (ok) Get.offAllNamed(AppRoutes.dashboard);
  }
}

// ─── 404 PAGE ─────────────────────────────────────────────────────────────
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('404', style: TextStyle(color: Color(0xFFFF8906), fontSize: 80, fontWeight: FontWeight.bold)),
        const Text('Page Not Found', style: TextStyle(color: Colors.white, fontSize: 24)),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8906), foregroundColor: Colors.black),
          onPressed: () => Get.offAllNamed(AppRoutes.dashboard),
          child: const Text('Go to Dashboard'),
        ),
      ])),
    );
  }
}
