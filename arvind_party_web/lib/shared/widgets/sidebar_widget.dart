// arvind_party_web/lib/shared/widgets/sidebar_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SidebarWidget extends StatelessWidget {
  final int selected;
  const SidebarWidget({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: double.infinity,
      color: const Color(0xFF15141F),
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            child: Row(children: [
              const Icon(Icons.mic, color: Color(0xFFFF8906), size: 28),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('ARVIND PARTY',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                        color: Colors.white, letterSpacing: 1)),
                Text('Admin Panel',
                    style: TextStyle(fontSize: 11, color: Color(0xFFB0B0C3))),
              ]),
            ]),
          ),
          const Divider(color: Color(0xFF2A2940), height: 1),
          const SizedBox(height: 8),

          // Nav Items
          _NavItem(icon: Icons.dashboard,     label: 'Dashboard',      index: 0, selected: selected, route: '/dashboard'),
          _NavItem(icon: Icons.people,        label: 'Users',          index: 1, selected: selected, route: '/users'),
          _NavItem(icon: Icons.card_giftcard, label: 'Gifts',          index: 2, selected: selected, route: '/gifts'),
          _NavItem(icon: Icons.mic,           label: 'Rooms',          index: 3, selected: selected, route: '/rooms'),
          _NavItem(icon: Icons.account_balance_wallet, label: 'Wallet', index: 4, selected: selected, route: '/wallet'),
          _NavItem(icon: Icons.bar_chart,     label: 'Analytics',      index: 5, selected: selected, route: '/analytics'),
          _NavItem(icon: Icons.settings,      label: 'Settings',       index: 6, selected: selected, route: '/settings'),

          const Spacer(),
          const Divider(color: Color(0xFF2A2940), height: 1),
          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFFCF6679), size: 20),
            title: const Text('Logout',
                style: TextStyle(color: Color(0xFFCF6679), fontSize: 14)),
            onTap: () {
              GetStorage().erase();
              Get.offAllNamed('/login');
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label, route;
  final int index, selected;

  const _NavItem({
    required this.icon, required this.label, required this.route,
    required this.index, required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selected;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFFFF8906).withOpacity(0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon,
            color: isSelected ? const Color(0xFFFF8906) : const Color(0xFFB0B0C3),
            size: 20),
        title: Text(label,
            style: TextStyle(
                color: isSelected ? const Color(0xFFFF8906) : const Color(0xFFB0B0C3),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
        onTap: () => Get.offAllNamed(route),
      ),
    );
  }
}
