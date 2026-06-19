// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room/widgets/room_card.dart
// ARVIND PARTY - ROOM CARD WIDGET (List item with type badge)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/room_model.dart';
import '../controllers/room_controller.dart';

class RoomCard extends StatelessWidget {
  final RoomModel room;
  final RoomController controller = Get.find<RoomController>();

  RoomCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.joinRoom(room.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
        ),
        child: Row(
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: Color(int.parse('0xFF${room.settings.themeColorHex ?? '4ECDC4'}')),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  room.type.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(room.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(room.type.name, style: TextStyle(color: Colors.blue, fontSize: 10)),
                      ),
                    ],
                  ),
                  Text('${room.members.length} members • ${room.seats.where((s) => s.status == SeatStatus.occupied).length} seats',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            if (room.type == RoomType.password)
              const Icon(Icons.lock, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}