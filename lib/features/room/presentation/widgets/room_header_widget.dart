import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/room_controller.dart';

class RoomHeaderWidget extends StatelessWidget {
  const RoomHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RoomController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => ctrl.leaveRoom(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          
          // Room Info
          Expanded(
            child: Obx(() {
              final room = ctrl.currentRoom.value;
              if (room == null) return const SizedBox.shrink();
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                     room.title ?? room.name,
                     style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white54, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${room.onlineUsers}',
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.tag, color: Colors.white54, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        room.id.replaceAll('room_', ''),
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
          
          // Members / Actions
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // Get.toNamed('/room-members'); // adjust route
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.people_alt_outlined, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  // Open Room Settings
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Dummy class to satisfy the `const RoomHeader()` in room_screen.dart
class RoomHeader extends StatelessWidget {
  const RoomHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); 
  }
}
