// ═══════════════════════════════════════════════════════════════════════════
// ADMIN SHELL — Luxury Sidebar Layout for All Admin Pages
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../routes/app_routes.dart';

class AdminShell extends StatefulWidget {
  final Widget child;
  final String title;
  const AdminShell({super.key, required this.child, required this.title});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  bool _sidebarExpanded = true;

  final List<_NavItem> _navItems = [
    _NavItem('Dashboard', Icons.dashboard_rounded, AppRoutes.dashboard, null),
    _NavItem('Users', Icons.people_rounded, AppRoutes.users, null),
    _NavItem('Rooms', Icons.meeting_room_rounded, AppRoutes.rooms, null),
    _NavItem('Gifts', Icons.card_giftcard_rounded, AppRoutes.gifts, null),
    _NavItem('Transactions', Icons.receipt_long_rounded, AppRoutes.transactions, null),
    _NavItem('Coin Manager', Icons.monetization_on_rounded, AppRoutes.coinManager, 'owner'),
    _NavItem('Wallet', Icons.account_balance_wallet_rounded, AppRoutes.walletManagement, null),
    _NavItem('Agency', Icons.business_rounded, AppRoutes.agency, null),
    _NavItem('Staff', Icons.manage_accounts_rounded, AppRoutes.staff, null),
    _NavItem('VIP System', Icons.star_rounded, AppRoutes.vipAdmin, null),
    _NavItem('Events', Icons.event_rounded, AppRoutes.events, null),
    _NavItem('Games', Icons.sports_esports_rounded, AppRoutes.games, null),
    _NavItem('Rankings', Icons.leaderboard_rounded, AppRoutes.leaderboard, null),
    _NavItem('Families', Icons.groups_rounded, AppRoutes.families, null),
    _NavItem('Notifications', Icons.notifications_rounded, AppRoutes.notifications, null),
    _NavItem('Reports', Icons.bar_chart_rounded, AppRoutes.reports, null),
    _NavItem('Analytics', Icons.analytics_rounded, AppRoutes.analyticsDashboard, null),
    _NavItem('Security', Icons.security_rounded, AppRoutes.securityDashboard, null),
    _NavItem('Support', Icons.support_agent_rounded, AppRoutes.support, null),
    _NavItem('Settings', Icons.settings_rounded, AppRoutes.settings, null),
  ];

  @override
  Widget build(BuildContext context) {
    final role = GetStorage().read('admin_role') ?? 'admin';
    final currentRoute = Get.currentRoute;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      body: Row(
        children: [
          // ─── SIDEBAR ──────────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: _sidebarExpanded ? 240 : 72,
            color: const Color(0xFF0F0E1A),
            child: Column(
              children: [
                // Logo area
                Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF1E1D2F))),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF8906), Color(0xFFFF6B00)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.local_party_mode, color: Colors.white, size: 20),
                      ),
                      if (_sidebarExpanded) ...[
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Arvind Party', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('Admin Panel', style: TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                      IconButton(
                        icon: Icon(_sidebarExpanded ? Icons.chevron_left : Icons.chevron_right, color: const Color(0xFF6B7280)),
                        onPressed: () => setState(() => _sidebarExpanded = !_sidebarExpanded),
                      ),
                    ],
                  ),
                ),
                // Nav items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: _navItems.where((item) {
                      if (item.requiredRole == 'owner') return role == 'owner' || role == 'super_admin';
                      return true;
                    }).map((item) {
                      final isActive = currentRoute == item.route;
                      return Tooltip(
                        message: _sidebarExpanded ? '' : item.label,
                        child: InkWell(
                          onTap: () => Get.toNamed(item.route),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            padding: EdgeInsets.symmetric(
                              horizontal: _sidebarExpanded ? 12 : 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isActive ? const Color(0xFFFF8906).withOpacity(0.15) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: isActive ? Border.all(color: const Color(0xFFFF8906).withOpacity(0.3)) : null,
                            ),
                            child: Row(
                              children: [
                                Icon(item.icon, size: 20,
                                  color: isActive ? const Color(0xFFFF8906) : const Color(0xFF6B7280)),
                                if (_sidebarExpanded) ...[
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(item.label,
                                    style: TextStyle(
                                      color: isActive ? const Color(0xFFFF8906) : const Color(0xFFB8B8D1),
                                      fontSize: 13, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  )),
                                  if (item.requiredRole == 'owner')
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF8906).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('OWNER', style: TextStyle(color: Color(0xFFFF8906), fontSize: 9, fontWeight: FontWeight.bold)),
                                    ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Bottom user info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFF1E1D2F))),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFFFF8906),
                        child: Text(
                          (GetStorage().read('admin_name') ?? 'A')[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      if (_sidebarExpanded) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(GetStorage().read('admin_name') ?? 'Admin',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                              Text(role.toUpperCase(),
                                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, size: 16, color: Color(0xFF6B7280)),
                          onPressed: _logout,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ─── MAIN CONTENT ──────────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F0E1A),
                    border: Border(bottom: BorderSide(color: Color(0xFF1E1D2F))),
                  ),
                  child: Row(
                    children: [
                      Text(widget.title,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      // Live indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2ED573).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF2ED573).withOpacity(0.3)),
                        ),
                        child: Row(children: [
                          Container(width: 6, height: 6,
                            decoration: const BoxDecoration(color: Color(0xFF2ED573), shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          const Text('Live', style: TextStyle(color: Color(0xFF2ED573), fontSize: 12)),
                        ]),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Color(0xFF6B7280)),
                        onPressed: () => Get.toNamed(AppRoutes.notifications),
                      ),
                    ],
                  ),
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _logout() {
    GetStorage().erase();
    Get.offAllNamed(AppRoutes.login);
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  final String? requiredRole;
  const _NavItem(this.label, this.icon, this.route, this.requiredRole);
}

// ─── LUXURY REUSABLE WIDGETS ──────────────────────────────────────────────

class LuxuryCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  const LuxuryCard({super.key, required this.child, this.padding, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0E1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? const Color(0xFF1E1D2F)),
      ),
      child: child,
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  const StatCard({super.key, required this.title, required this.value, required this.icon, required this.color, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return LuxuryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              if (subtitle != null)
                Text(subtitle!, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
        ],
      ),
    );
  }
}

class LuxuryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color? color;
  final bool isOutlined;
  final bool isLoading;
  const LuxuryButton({super.key, required this.label, this.icon, required this.onPressed,
    this.color, this.isOutlined = false, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFFFF8906);
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined ? Colors.transparent : c,
        foregroundColor: isOutlined ? c : Colors.black,
        side: isOutlined ? BorderSide(color: c) : null,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      child: isLoading
          ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: isOutlined ? c : Colors.black))
          : Row(mainAxisSize: MainAxisSize.min, children: [
              if (icon != null) ...[Icon(icon, size: 16), const SizedBox(width: 6)],
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ]),
    );
  }
}

class LuxurySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback? onChanged;
  const LuxurySearchBar({super.key, required this.controller, required this.hint, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      onChanged: (_) => onChanged?.call(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
        prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280), size: 18),
        filled: true,
        fillColor: const Color(0xFF1A1928),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E1D2F))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E1D2F))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF8906))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class LuxuryDataTable extends StatelessWidget {
  final List<String> columns;
  final List<List<Widget>> rows;
  final bool isLoading;
  final String emptyMessage;
  const LuxuryDataTable({super.key, required this.columns, required this.rows,
    this.isLoading = false, this.emptyMessage = 'No data found'});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0E1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1D2F)),
      ),
      child: isLoading
          ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Color(0xFFFF8906))))
          : rows.isEmpty
              ? SizedBox(height: 200, child: Center(child: Text(emptyMessage, style: const TextStyle(color: Color(0xFF6B7280)))))
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFF1A1928)),
                    dataRowColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.hovered)) return const Color(0xFF1E1D2F);
                      return Colors.transparent;
                    }),
                    headingTextStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.w600),
                    dataTextStyle: const TextStyle(color: Color(0xFFB8B8D1), fontSize: 13),
                    dividerThickness: 0.5,
                    columns: columns.map((c) => DataColumn(label: Text(c.toUpperCase()))).toList(),
                    rows: rows.map((row) => DataRow(
                      cells: row.map((cell) => DataCell(cell)).toList(),
                    )).toList(),
                  ),
                ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const StatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
