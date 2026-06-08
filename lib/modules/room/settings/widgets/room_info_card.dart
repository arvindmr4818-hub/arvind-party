import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/room_settings_controller.dart';

class RoomInfoCard extends StatelessWidget {
  const RoomInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final RoomSettingsController controller = Get.find<RoomSettingsController>();

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
              Icon(Icons.badge_outlined, color: Color(0xffFF8906), size: 20),
              SizedBox(width: 8),
              Text("Room Profile & Identity",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),

          // 1. Dynamic Banner Action Frame
          Obx(() => Container(
                height: 110,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: controller.roomBanner.value.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(controller.roomBanner.value),
                          fit: BoxFit.cover)
                      : null,
                  color: const Color(0xff0F0E17),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black45,
                  ),
                  child: Center(
                    child: TextButton.icon(
                      onPressed: () => controller.updateBanner(
                          "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=500&q=80"),
                      icon: const Icon(Icons.camera_enhance_outlined,
                          color: Colors.white, size: 18),
                      label: const Text("Replace Backdrop",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 16),

          // 2. Room Name Form Field
          _buildFieldLabel("Room Title Name"),
          Obx(() => TextFormField(
                // Key is added so that GetX updates initialValue dynamically
                key: ValueKey(controller.roomName.value),
                initialValue: controller.roomName.value,
                onChanged: controller.updateRoomName,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _inputDecoration("Edit room title..."),
              )),
          const SizedBox(height: 14),

          // 3. Room Tagline Topic Form Field
          _buildFieldLabel("Room Theme Topic Tagline"),
          Obx(() => TextFormField(
                key: ValueKey(controller.roomTopic.value),
                initialValue: controller.roomTopic.value,
                onChanged: controller.updateTopic,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _inputDecoration("Edit dynamic status..."),
              )),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 2),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w500)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
      filled: true,
      fillColor: const Color(0xff0F0E17),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xffFF8906), width: 1)),
    );
  }
}