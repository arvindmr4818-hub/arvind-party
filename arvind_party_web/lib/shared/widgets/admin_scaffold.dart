import 'package:flutter/material.dart';
import '../../core/constants/auth_controller.dart';
import '../../core/theme/web_theme.dart';
import 'sidebar_widget.dart';

// ============================================================
// ARVIND PARTY WEB — Admin Scaffold (Main Layout)
// ============================================================
// Provides the core layout: sidebar + top bar + content area.
// Used by dashboard, users, rooms, and other main views.
// ============================================================

class AdminScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? drawer;

  const AdminScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.drawer,
  });

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.to;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    return Scaffold(
      backgroundColor: WebTheme.backgroundDark,
      drawer: !isWide
          ? (drawer ?? _buildMobileDrawer(context, auth))
          : null,
      body: Row(
        children: [
          // ─── Sidebar (desktop) ───────────────────────────
          if (isWide)
            const SizedBox(
              width: 260,
              child: SidebarWidget(),
            ),

          // ─── Main Content Area ───────────────────────────
          Expanded(
            child: Column(
              children: [
                // ─── Top Bar ──────────────────────────────
                Container(
                  padding: EdgeInsets.only(
                    left: isWide ? 24 : 16,
                    right: 16,
                    top: 8,
                    bottom: 8,
                  ),
                  color: WebTheme.cardDark,
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        if (!isWide)
                          Builder(
                            builder: (ctx) => IconButton(
                              icon: const Icon(Icons.menu),
                              onPressed: () => Scaffold.of(ctx).openDrawer(),
                              color: WebTheme.textPrimary,
                            ),
                          ),
                        if (!isWide) const SizedBox(width: 8),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const Spacer(),
                        if (actions != null) ...actions!,
                        const SizedBox(width: 8),

                        // ─── Staff Info ──────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: WebTheme.elevatedDark,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.admin_panel_settings,
                                size: 16,
                                color: WebTheme.primaryOrange,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                auth.currentStaffName.value.isNotEmpty
                                    ? auth.currentStaffName.value
                                    : 'Staff',
                                style: const TextStyle(
                                  color: WebTheme.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: WebTheme.primaryOrange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  auth.currentUserRole.value.displayName,
                                  style: const TextStyle(
                                    color: WebTheme.primaryOrange,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),

                // ─── Page Content ──────────────────────────
                Expanded(
                  child: body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDrawer(BuildContext context, AuthController auth) {
    return Drawer(
      backgroundColor: WebTheme.cardDark,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer header with staff info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFF2D2D3A)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: WebTheme.primaryOrange,
                    child: Icon(Icons.admin_panel_settings, size: 28, color: Colors.black),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    auth.currentStaffName.value.isNotEmpty
                        ? auth.currentStaffName.value
                        : 'Staff',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: WebTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    auth.currentUserRole.value.displayName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: WebTheme.primaryOrange,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: const SidebarWidget(),
            ),
          ],
        ),
      ),
    );
  }
}