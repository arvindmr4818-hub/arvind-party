// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/events/presentation/views/events_screen.dart
// ARVIND PARTY - EVENTS SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/events_controller.dart';

class EventsScreen extends GetView<EventsController> {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.events.isEmpty) {
          return const Center(
            child: Text('No upcoming events', style: TextStyle(color: Colors.grey)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.events.length,
          itemBuilder: (context, index) {
            final event = controller.events[index];
            return Card(
              color: const Color(0xFF1A1A2E),
              child: ListTile(
                leading: const Icon(Icons.event, color: Color(0xFFFF8906)),
                title: Text(event['title'] ?? '', style: const TextStyle(color: Colors.white)),
                subtitle: Text(event['date'] ?? '', style: const TextStyle(color: Colors.grey)),
              ),
            );
          },
        );
      }),
    );
  }
}