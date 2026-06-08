import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/room_settings_controller.dart';

class RoomSecurityCard extends StatelessWidget {
  const RoomSecurityCard({super.key});

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
              Icon(Icons.security_outlined, color: Colors.cyan, size: 20),
              SizedBox(width: 8),
              Text("Privacy & Security Rules",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),

          // 1. Private Room Toggle
          Obx(() => SwitchListTile.adaptive(
                title: const Text("Private (Invite Only Modality)",
                    style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text(
                    "Hides room from general index lobby matching feeds",
                    style: TextStyle(color: Colors.white54, fontSize: 11)),
                contentPadding: EdgeInsets.zero,
                activeColor: const Color(0xffFF8906),
                value: controller.isPrivate.value,
                // ✅ Fix: Pass the boolean variable 'v' inside togglePrivacy
                onChanged: (bool v) => controller.togglePrivacy(v),
              )),

          Divider(color: Colors.white.withValues(alpha: 0.03)),

          // 2. Password Protection Toggle
          Obx(() => SwitchListTile.adaptive(
                title: const Text("Password Door Code Entry",
                    style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text(
                    "Forced challenge keypad validation for entrants",
                    style: TextStyle(color: Colors.white54, fontSize: 11)),
                contentPadding: EdgeInsets.zero,
                activeColor: const Color(0xffFF8906),
                value: controller.hasPassword.value,
                onChanged: (bool v) {
                  if (controller.isPrivate.value) {
                    Get.snackbar("Constraint",
                        "Deactivate Invite-Only layout privacy protocols first.");
                    return;
                  }
                  controller.togglePasswordProtection(v);
                },
              )),

          // 3. Password Input Field
          Obx(() {
            if (!controller.hasPassword.value) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: TextFormField(
                // Added ValueKey for dynamic dynamic reactive updates
                key: ValueKey(controller.roomPassword.value),
                initialValue: controller.roomPassword.value,
                onChanged: (v) => controller.roomPassword.value = v,
                keyboardType: TextInputType.number,
                obscureText: true,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Setup numeric room password doorlock keys",
                  hintStyle:
                      const TextStyle(color: Colors.white24, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xff0F0E17),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Colors.cyan, width: 1)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}