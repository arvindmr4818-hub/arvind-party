import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/room_settings_controller.dart';

class RoomAnnouncementCard extends StatelessWidget {
  const RoomAnnouncementCard({super.key});

  @override
  Widget build(BuildContext context) {
    final RoomSettingsController controller =
        Get.find<RoomSettingsController>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff15141F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.campaign_outlined,
                  color: Colors.amberAccent, size: 20),
              SizedBox(width: 8),
              Text("Pinned Room Announcement Board",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: controller.roomAnnouncement.value,
            maxLines: 2,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            onChanged: (v) => controller.roomAnnouncement.value = v,
            decoration: InputDecoration(
              hintText: "Broadcast dynamic events info tickers...",
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
              filled: true,
              fillColor: const Color(0xff0F0E17),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Colors.amberAccent, width: 1)),
            ),
          ),
        ],
      ),
    );
  }
}
