import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/room_settings_controller.dart';
import '../widgets/room_info_card.dart';
import '../widgets/room_security_card.dart';
import '../widgets/room_seat_card.dart';
import '../widgets/room_welcome_card.dart';
import '../widgets/room_announcement_card.dart';

class RoomSettingsScreen extends StatelessWidget {
  const RoomSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Injecting controller instance specifically bound to this structural view scope lifecycle
    final RoomSettingsController controller = Get.put(RoomSettingsController());

    return Scaffold(
      backgroundColor:
          const Color(0xff0F0E17), // Theme background base color matching
      appBar: AppBar(
        backgroundColor: const Color(0xff15141F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Room Room Control Deck",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(
                maxWidth:
                    600), // Perfect look on Flutter Web panel layouts or mobile viewports
            child: Column(
              children: [
                // 1. Scrollable Control Parameter Panel Deck Cards
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const RoomInfoCard(),
                        const SizedBox(height: 14),
                        const RoomSecurityCard(),
                        const SizedBox(height: 14),
                        const RoomSeatCard(),
                        const SizedBox(height: 14),
                        const RoomWelcomeCard(),
                        const SizedBox(height: 14),
                        const RoomAnnouncementCard(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // 2. Sticky Execution Bottom Panel (Global Sync Pipeline Trigger)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xff15141F),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Obx(() {
                    bool processing = controller.isLoading.value;
                    return SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                              0xffFF8906), // Brand theme neon orange accent
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(23)),
                        ),
                        onPressed: processing
                            ? null
                            : () => controller.saveRoomConfigurations(),
                        child: processing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                "Apply Settings Sync ⚙️",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
