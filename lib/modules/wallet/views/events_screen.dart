import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/events_controller.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Injecting real-time backend events controller
    final controller = Get.put(EventsController());

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF15141F),
        elevation: 0,
        title: const Text('Live Event Center',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back()),
      ),
      body: Obx(() {
        // 1. Real Server Loading State
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF8906)));
        }

        // 2. Real Database Empty State (No Fake Data Fallback)
        if (controller.events.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, color: Colors.white24, size: 60),
                SizedBox(height: 12),
                Text("No active tournaments or events found", 
                    style: TextStyle(color: Colors.white54, fontSize: 14)),
              ],
            ),
          );
        }

        // 3. Real Server Data Streams List
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.events.length,
          itemBuilder: (context, index) {
            final event = controller.events[index];
            
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF15141F),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Display Backdrop Banner from Server API
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      event.coverUrl, // Direct binding with server database attribute
                      width: double.infinity, 
                      height: 160, 
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 160,
                        color: const Color(0xff0F0E17),
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.white24, size: 40)
                        ),
                      ),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                event.title, // Database field stream
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFFF8906).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                controller.getEventTimeRemaining(event), // Server Time Remaining Method
                                style: const TextStyle(
                                    color: Color(0xFFFF8906),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          event.description, // Database field stream
                          style: const TextStyle(color: Colors.white54, fontSize: 14)
                        ),
                        const SizedBox(height: 16),
                        
                        // Real-Time Action Button for joining events
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8906),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                            ),
                            onPressed: () => controller.joinEvent(event.id),
                            child: const Text('Register / Join Event', 
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      }),
    );
  }
}