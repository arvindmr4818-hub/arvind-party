import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../routes/app_routes.dart';

class AdminScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  const AdminScaffold({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: Row(
        children: [
          _Sidebar(),
          Expanded(
            child: Column(
              children: [
                _TopBar(title: title),
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final current = Get.currentRoute;
    return Container(
      width: 220,
      color: const Color(0xFF15141F),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Icon(Icons.admin_panel_settings, color: Color(0xFFFF8906), size: 36),
          const SizedBox(height: 4),
          const Text('Admin Panel',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFF2A2940)),
          _NavItem(Icons.dashboard, 'Dashboard', AppRoutes.dashboard, current),
          _NavItem(Icons.people, 'Users', AppRoutes.users, current),
          _NavItem(Icons.meeting_room, 'Rooms', AppRoutes.rooms, current),
          _NavItem(Icons.card_giftcard, 'Gifts', AppRoutes.gifts, current),
          _NavItem(Icons.settings, 'Settings', AppRoutes.settings, current),
          const Spacer(),
          const Divider(color: Color(0xFF2A2940)),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontSize: 14)),
            onTap: () {
              GetStorage().remove('admin_token');
              Get.offAllNamed(AppRoutes.login);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String current;
  const _NavItem(this.icon, this.label, this.route, this.current);

  @override
  Widget build(BuildContext context) {
    final active = current == route;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFF8906).withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: active ? Border.all(color: const Color(0xFFFF8906).withOpacity(0.3)) : null,
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: active ? const Color(0xFFFF8906) : Colors.white54, size: 20),
        title: Text(label,
            style: TextStyle(
                color: active ? const Color(0xFFFF8906) : Colors.white70,
                fontSize: 14,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
        onTap: () => Get.toNamed(route),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF15141F),
        border: Border(bottom: BorderSide(color: Color(0xFF2A2940))),
      ),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          const Spacer(),
          const Icon(Icons.notifications_outlined, color: Colors.white54, size: 22),
          const SizedBox(width: 16),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFFF8906),
            child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
