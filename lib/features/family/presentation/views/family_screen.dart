// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/family/presentation/views/family_screen.dart
// ARVIND PARTY - FAMILY SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/family_controller.dart';

class FamilyScreen extends GetView<FamilyController> {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.families.isEmpty) {
          return const Center(child: Text('No families yet', style: TextStyle(color: Colors.grey)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.families.length,
          itemBuilder: (context, index) {
            final family = controller.families[index];
            return Card(
              color: const Color(0xFF1A1A2E),
              child: ListTile(
                leading: const Icon(Icons.group, color: Color(0xFFFF8906)),
                title: Text(family['name'] ?? '', style: const TextStyle(color: Colors.white)),
                subtitle: Text("${family['memberCount']} members", style: const TextStyle(color: Colors.grey)),
              ),
            );
          },
        );
      }),
    );
  }
}