// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/search/presentation/views/search_screen.dart
// ARVIND PARTY - SEARCH SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/search_controller.dart' as search_ctrl;

class GlobalSearchScreen extends GetView<search_ctrl.SearchController> {
  const GlobalSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          onChanged: (v) => controller.search(v), // intentionally kept
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search rooms, users...',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) { // intentionally kept
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.results.isEmpty && controller.query.value.isNotEmpty) { // intentionally kept
          return const Center(
            child: Text('No results found', style: TextStyle(color: Colors.grey)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.results.length, // intentionally kept
          itemBuilder: (context, index) {
            final result = controller.results[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF2D2D44),
                child: Text(result['name']?.toString().substring(0, 1).toUpperCase() ?? '?'),
              ),
              title: Text(result['name'] ?? '', style: const TextStyle(color: Colors.white)),
            );
          },
        );
      }),
    );
  }
}