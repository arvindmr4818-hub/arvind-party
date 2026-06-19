// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/auth/presentation/views/profile_screen.dart
// ARVIND PARTY - PROFILE SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/profile_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Get.back();
                            controller.logout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body: Obx(() {
            final user = controller.currentUser.value;

            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  ProfileHeader(
                    user: user,
                    onEditPressed: () => Get.toNamed('/edit-profile'),
                  ),
                  const SizedBox(height: 24),
                  _buildMenuSection(context, controller),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildMenuSection(BuildContext context, AuthController controller) {
    return Column(
      children: [
        _MenuItem(
          icon: Icons.person_outline,
          label: 'Edit Profile',
          onTap: () => Get.toNamed('/edit-profile'),
        ),
        _MenuItem(
          icon: Icons.lock_outline,
          label: 'Change Password',
          onTap: () => Get.toNamed('/change-password'),
        ),
        _MenuItem(
          icon: Icons.star_outline,
          label: 'VIP Status',
          onTap: () => Get.toNamed('/vip'),
        ),
        _MenuItem(
          icon: Icons.settings,
          label: 'Settings',
          onTap: () {},
        ),
        _MenuItem(
          icon: Icons.help_outline,
          label: 'Help & Support',
          onTap: () {},
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}