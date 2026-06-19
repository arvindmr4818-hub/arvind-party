// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/wallet/presentation/views/user_center_screen.dart
// ARVIND PARTY - USER CENTER SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserCenterScreen extends StatelessWidget {
  const UserCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Center'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Info Header
          const Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFFFF8906),
                  child: Text(
                    'U',
                    style: TextStyle(fontSize: 40, color: Colors.white),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'User',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // User Center Options
          _buildMenuItem(
            icon: Icons.person,
            title: 'My Profile',
            onTap: () => Get.toNamed('/profile'),
          ),
          _buildMenuItem(
            icon: Icons.account_balance_wallet,
            title: 'Wallet',
            onTap: () => Get.toNamed('/wallet'),
          ),
          _buildMenuItem(
            icon: Icons.card_giftcard,
            title: 'Withdrawal',
            onTap: () => Get.toNamed('/withdrawal'),
          ),
          _buildMenuItem(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () => _logout(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFFF8906)),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed('/login');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
