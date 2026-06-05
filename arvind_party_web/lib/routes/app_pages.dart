// arvind_party_web/lib/routes/app_pages.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/auth/views/admin_login_view.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/users/views/users_view.dart';
import '../modules/gifts/views/gifts_view.dart';
import '../shared/widgets/sidebar_widget.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.login,     page: () => AdminLoginView()),
    GetPage(name: AppRoutes.dashboard, page: () => const DashboardView()),
    GetPage(name: AppRoutes.users,     page: () => const UsersView()),
    GetPage(name: AppRoutes.gifts,     page: () => const GiftsView()),
    GetPage(name: AppRoutes.rooms,     page: () => const _ComingSoon(title: 'Rooms Management',    idx: 3)),
    GetPage(name: AppRoutes.wallet,    page: () => const _ComingSoon(title: 'Wallet Management',   idx: 4)),
    GetPage(name: AppRoutes.analytics, page: () => const _ComingSoon(title: 'Analytics',           idx: 5)),
    GetPage(name: AppRoutes.settings,  page: () => const _ComingSoon(title: 'Settings',            idx: 6)),
  ];
}

class _ComingSoon extends StatelessWidget {
  final String title;
  final int idx;
  const _ComingSoon({required this.title, required this.idx});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: Row(children: [
        SidebarWidget(selected: idx),
        Expanded(
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.construction, color: Color(0xFFFF8906), size: 64),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 8),
              const Text('Coming soon...',
                  style: TextStyle(color: Color(0xFFB0B0C3))),
            ]),
          ),
        ),
      ]),
    );
  }
}
