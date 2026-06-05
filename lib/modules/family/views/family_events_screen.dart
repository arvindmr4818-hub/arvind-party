import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/family_event_controller.dart';
import '../widgets/family_event_card.dart';

class FamilyEventsScreen extends StatelessWidget {
  const FamilyEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Injected local context event tracking system engine
    final FamilyEventController eventController =
        Get.put(FamilyEventController());

    return Scaffold(
      backgroundColor: const Color(0xff0F0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xff15141F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Clan Scheduled Events",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Upcoming Community Galas",
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),

                // Core Events Array Streams rendering
                Expanded(
                  child: Obx(() {
                    if (eventController.isProcessing.value &&
                        eventController.upcomingEvents.isEmpty) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xffFF8906)));
                    }

                    if (eventController.upcomingEvents.isEmpty) {
                      return const Center(
                        child: Text("No official events posted yet.",
                            style:
                                TextStyle(color: Colors.white24, fontSize: 13)),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: eventController.upcomingEvents.length,
                      itemBuilder: (context, index) {
                        final eventData = eventController.upcomingEvents[index];
                        return FamilyEventCard(event: eventData);
                      },
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
