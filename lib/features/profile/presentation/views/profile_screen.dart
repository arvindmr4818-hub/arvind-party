// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/profile/presentation/views/profile_screen.dart
// ARVIND PARTY - PROFILE SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFFFF8906),
                child: Text(
                  controller.userName.value.isNotEmpty
                      ? controller.userName.value[0].toUpperCase()
                      : '?',
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                controller.userName.value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.monetization_on, color: Color(0xFFD4AF37)),
                  SizedBox(width: 4),
                  Text('\${controller.coins.value} coins', style: TextStyle(color: Color(0xFFD4AF37))),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}