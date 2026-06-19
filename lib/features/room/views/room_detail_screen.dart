// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room/views/room_detail_screen.dart
// ARVIND PARTY - ROOM DETAIL SCREEN (Voice, Seats, Info TabBar)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/room_controller.dart';
import '../widgets/member_list.dart';
import '../models/room_model.dart';

class RoomDetailScreen extends GetView<RoomController> {
  const RoomDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RoomController());

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.currentRoom.value?.name ?? 'Room')),
        actions: [
          Obx(() => IconButton(
            icon: Icon(controller.isMuted.value ? Icons.mic_off : Icons.mic),
            onPressed: controller.toggleMute,
          )),
          Obx(() => IconButton(
            icon: Icon(controller.isSpeaker.value ? Icons.volume_up : Icons.volume_down),
            onPressed: controller.toggleSpeaker,
          )),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'leave') controller.leaveRoom();
              if (value == 'delete') controller.deleteRoom();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'leave', child: Text('Leave Room')),
              const PopupMenuItem(value: 'delete', child: Text('Delete Room')),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.currentRoom.value == null) return const Center(child: Text('Not in a room'));
        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              const TabBar(tabs: [
                Tab(icon: Icon(Icons.chat), text: 'Voice'),
                Tab(icon: Icon(Icons.event_seat), text: 'Seats'),
                Tab(icon: Icon(Icons.settings), text: 'Info'),
              ]),
              Expanded(
                child: TabBarView(
                  children: [
                    // Voice Tab
                    Column(
                      children: [
                        Expanded(child: const MemberList()),
                        // Voice Effect Controls
                        Container(
                          padding: const EdgeInsets.all(12),
                          color: Colors.grey.shade100,
                          child: Wrap(
                            spacing: 8,
                            children: VoiceEffect.values.map((effect) => ChoiceChip(
                              label: Text(effect.name),
                              selected: controller.selectedVoiceEffect.value == effect,
                              onSelected: (selected) => controller.setVoiceEffect(effect),
                            )).toList(),
                          ),
                        ),
                      ],
                    ),
                    // Seats Tab
                    Obx(() => GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, childAspectRatio: 1,
                      ),
                      itemCount: controller.seats.length,
                      itemBuilder: (context, index) {
                        final seat = controller.seats[index];
                        return GestureDetector(
                          onTap: () {
                            if (seat.status == SeatStatus.empty) controller.requestSeat(seat.seatNumber);
                            if (seat.status == SeatStatus.occupied) controller.kickFromSeat(seat.seatId);
                          },
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: seat.status == SeatStatus.empty ? Colors.green.shade100 :
                                     seat.status == SeatStatus.locked ? Colors.grey.shade300 :
                                     seat.status == SeatStatus.reserved ? Colors.orange.shade100 : Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: seat.isHostSeat ? Border.all(color: Colors.red, width: 2) : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Seat ${seat.seatNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(seat.status.name, style: TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          ),
                        );
                      },
                    )),
                    // Info & Settings Tab
                    Obx(() => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Notice: ${controller.currentRoom.value?.settings.notice ?? 'No notice'}'),
                          const SizedBox(height: 12),
                          Text('Rules: ${controller.currentRoom.value?.settings.rules ?? 'Be respectful'}'),
                          const SizedBox(height: 12),
                          Text('Tags: ${controller.currentRoom.value?.settings.tags.join(', ')}'),
                          const Divider(),
                          SwitchListTile(
                            title: const Text('Noise Cancellation'),
                            value: controller.isNoiseCancellation.value,
                            onChanged: (_) => controller.toggleNoiseCancellation(),
                          ),
                          SwitchListTile(
                            title: const Text('Spatial Audio'),
                            value: controller.isSpatialAudio.value,
                            onChanged: (_) => controller.toggleSpatialAudio(),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}