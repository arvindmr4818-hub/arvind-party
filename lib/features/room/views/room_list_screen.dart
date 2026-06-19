// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room/views/room_list_screen.dart
// ARVIND PARTY - ROOM LIST SCREEN (Filter by 10 Types)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/room_controller.dart';
import '../widgets/room_card.dart';
import '../models/room_model.dart';

class RoomListScreen extends GetView<RoomController> {
  RoomListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RoomController());
    final String? filterType = Get.arguments?['type'];

    return Scaffold(
      appBar: AppBar(
        title: Text(filterType != null ? '${filterType.capitalizeFirst} Rooms' : 'All Rooms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed('/create-room'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Type Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: RoomType.values.map((type) => GestureDetector(
                onTap: () => controller.loadRooms(type: type.name),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: filterType == type.name ? Colors.blue : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(type.name, style: TextStyle(
                    color: filterType == type.name ? Colors.white : Colors.black,
                  )),
                ),
              )).toList(),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: controller.rooms.length,
                itemBuilder: (context, index) => RoomCard(room: controller.rooms[index]),
              );
            }),
          ),
        ],
      ),
    );
  }
}