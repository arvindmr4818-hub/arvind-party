import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/auth_controller.dart';
import '../../core/theme/web_theme.dart';
import '../../routes/app_routes.dart';
import 'require_permission.dart';

// ============================================================
// ARVIND PARTY WEB — Sidebar Navigation (Full)
// ============================================================

class SidebarWidget extends StatelessWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.to;
    final currentRoute = Get.currentRoute;

    return Container(
      width: 260,
      color: WebTheme.cardDark,
      child: Column(
        children: [
          // ─── Brand Header ────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF2D2D3A))),
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: WebTheme.primaryOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.admin_panel_settings, color: WebTheme.primaryOrange, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Arvind Party', style: TextStyle(color: WebTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(auth.currentUserRole.value.displayName, style: const TextStyle(color: WebTheme.primaryOrange, fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),

          // ─── Navigation Items ────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // ─── Dashboard ────────────────────────────
                _NavItem(icon: Icons.dashboard, label: 'Dashboard', route: AppRoutes.dashboard, isActive: currentRoute == AppRoutes.dashboard, onTap: () => _navigate(AppRoutes.dashboard)),

                // ─── Administration Section ────────────────
                _SectionHeader(label: 'Administration'),

                RequirePermission(module: 'user',
                  child: _NavItem(icon: Icons.people_alt, label: 'User Management', route: AppRoutes.users, isActive: currentRoute == AppRoutes.users, onTap: () => _navigate(AppRoutes.users))),

                RequirePermission(module: 'room',
                  child: _NavItem(icon: Icons.meeting_room, label: 'Room Management', route: AppRoutes.rooms, isActive: currentRoute == AppRoutes.rooms, onTap: () => _navigate(AppRoutes.rooms))),

                RequirePermission(module: 'gift',
                  child: _NavItem(icon: Icons.card_giftcard, label: 'Gifts', route: AppRoutes.gifts, isActive: currentRoute == AppRoutes.gifts, onTap: () => _navigate(AppRoutes.gifts))),

                _NavItem(icon: Icons.announcement, label: 'Announcements', route: AppRoutes.announcements, isActive: currentRoute == AppRoutes.announcements, onTap: () => _navigate(AppRoutes.announcements)),

                // ─── Business Section ──────────────────────
                _SectionHeader(label: 'Business'),

                _NavItem(icon: Icons.account_balance_wallet, label: 'Wallet Management', route: AppRoutes.wallets, isActive: currentRoute == AppRoutes.wallets, onTap: () => _navigate(AppRoutes.wallets)),

                _NavItem(icon: Icons.receipt, label: 'Recharge History', route: AppRoutes.recharges, isActive: currentRoute == AppRoutes.recharges, onTap: () => _navigate(AppRoutes.recharges)),

                RequirePermission(module: 'agency',
                  child: _NavItem(icon: Icons.business, label: 'Agencies', route: AppRoutes.agencies, isActive: currentRoute == AppRoutes.agencies, onTap: () => _navigate(AppRoutes.agencies))),

                _NavItem(icon: Icons.family_restroom, label: 'Families', route: AppRoutes.families, isActive: currentRoute == AppRoutes.families, onTap: () => _navigate(AppRoutes.families)),

                RequirePermission(module: 'vip',
                  child: _NavItem(icon: Icons.workspace_premium, label: 'Rewards Center', route: AppRoutes.rewards, isActive: currentRoute == AppRoutes.rewards, onTap: () => _navigate(AppRoutes.rewards))),

                // ─── Owner Section ─────────────────────────
                if (auth.isOwner) ...[
                  _SectionHeader(label: 'Owner Controls'),

                  _NavItem(icon: Icons.token, label: 'Coin Generation', route: AppRoutes.coinGeneration, isActive: currentRoute == AppRoutes.coinGeneration, onTap: () => _navigate(AppRoutes.coinGeneration)),

                  _NavItem(icon: Icons.payment, label: 'Withdrawals', route: AppRoutes.withdrawals, isActive: currentRoute == AppRoutes.withdrawals, onTap: () => _navigate(AppRoutes.withdrawals)),

                  _NavItem(icon: Icons.workspace_premium, label: 'VIP Plans', route: AppRoutes.vip, isActive: currentRoute == AppRoutes.vip, onTap: () => _navigate(AppRoutes.vip)),

                  _NavItem(icon: Icons.event, label: 'Events', route: AppRoutes.events, isActive: currentRoute == AppRoutes.events, onTap: () => _navigate(AppRoutes.events)),

                  _NavItem(icon: Icons.security, label: 'Security', route: AppRoutes.security, isActive: currentRoute == AppRoutes.security, onTap: () => _navigate(AppRoutes.security)),

                  _NavItem(icon: Icons.admin_panel_settings, label: 'Roles & Permissions', route: AppRoutes.adminRoles, isActive: currentRoute == AppRoutes.adminRoles, onTap: () => _navigate(AppRoutes.adminRoles)),

                _NavItem(icon: Icons.list_alt, label: 'Audit Logs', route: AppRoutes.auditLogs, isActive: currentRoute == AppRoutes.auditLogs, onTap: () => _navigate(AppRoutes.auditLogs)),

                  _NavItem(icon: Icons.settings, label: 'System Settings', route: AppRoutes.systemSettings, isActive: currentRoute == AppRoutes.systemSettings, onTap: () => _navigate(AppRoutes.systemSettings)),
                ],

                // ─── Monitoring Section ────────────────────
                _SectionHeader(label: 'Monitoring'),

                _NavItem(icon: Icons.flag, label: 'Reports', route: AppRoutes.reports, isActive: currentRoute == AppRoutes.reports, onTap: () => _navigate(AppRoutes.reports)),

                _NavItem(icon: Icons.block, label: 'Bans', route: AppRoutes.bans, isActive: currentRoute == AppRoutes.bans, onTap: () => _navigate(AppRoutes.bans)),

                _NavItem(icon: Icons.leaderboard, label: 'Leaderboard', route: AppRoutes.leaderboard, isActive: currentRoute == AppRoutes.leaderboard, onTap: () => _navigate(AppRoutes.leaderboard)),

                _NavItem(icon: Icons.support_agent, label: 'Support Tickets', route: AppRoutes.tickets, isActive: currentRoute == AppRoutes.tickets, onTap: () => _navigate(AppRoutes.tickets)),

                _NavItem(icon: Icons.notifications, label: 'Notifications', route: AppRoutes.notifications, isActive: currentRoute == AppRoutes.notifications, onTap: () => _navigate(AppRoutes.notifications)),

                const Divider(indent: 20, endIndent: 20),

                // ─── Logout ────────────────────────────────
                _NavItem(icon: Icons.logout, label: 'Logout', route: '', isActive: false, onTap: () => auth.logout(), textColor: WebTheme.errorRed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigate(String route) {
    final scaffold = Scaffold.maybeOf(Get.context!);
    if (scaffold != null && scaffold.hasDrawer) {
      Navigator.of(Get.context!).maybePop();
    }
    Get.toNamed(route);
  }
}

// ─── Navigation Item Widget ───────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;
  final VoidCallback onTap;
  final Color? textColor;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = textColor ?? (isActive ? WebTheme.primaryOrange : WebTheme.textSecondary);
    return Material(
      color: isActive ? WebTheme.primaryOrange.withValues(alpha: 0.08) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 14),
              Text(label, style: TextStyle(color: color, fontSize: 14, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
              if (isActive) Container(margin: const EdgeInsets.only(left: 8), width: 6, height: 6, decoration: const BoxDecoration(color: WebTheme.primaryOrange, shape: BoxShape.circle)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section Header Widget ────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(label.toUpperCase(), style: const TextStyle(color: WebTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
    );
  }
}