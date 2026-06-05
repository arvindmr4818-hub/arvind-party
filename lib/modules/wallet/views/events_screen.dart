import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/events_controller.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventsController());

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF15141F),
        elevation: 0,
        title: const Text('Event Center',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back()),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF8906)));
        }

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
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(event.bannerUrl,
                        width: double.infinity, height: 160, fit: BoxFit.cover),
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
                                  child: Text(event.title,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold))),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFFF8906)
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Text(event.endDate,
                                      style: const TextStyle(
                                          color: Color(0xFFFF8906),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)))
                            ]),
                        const SizedBox(height: 8),
                        Text(event.description,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 14)),
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
