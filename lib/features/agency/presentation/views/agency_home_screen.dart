// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/agency/presentation/views/agency_home_screen.dart
// ARVIND PARTY - AGENCY HOME SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/agency_controller.dart';

class AgencyHomeScreen extends GetView<AgencyController> {
  const AgencyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agency')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = controller.agencyData.value;
        if (data == null) {
          return const Center(child: Text('No data', style: TextStyle(color: Colors.grey)));
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(data['name'] ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              Text('\$${data['totalEarnings']}', style: const TextStyle(fontSize: 36, color: Color(0xFFD4AF37))),
            ],
          ),
        );
      }),
    );
  }
}