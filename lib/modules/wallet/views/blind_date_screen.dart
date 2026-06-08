import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/blind_date_controller.dart';

class BlindDateScreen extends StatelessWidget {
  const BlindDateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BlindDateController());

    return Scaffold(
      backgroundColor: const Color(0xFF1A0B2E), // Romantic Dark Theme
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Blind Date',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back()),
      ),
      body: Center(
        child: Obx(() {
          if (controller.currentMatch.value != null) {
            final match = controller.currentMatch.value!;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("It's a Match! 💕",
                    style: TextStyle(
                        color: Colors.pinkAccent,
                        fontSize: 32,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                CircleAvatar(
                    radius: 60, backgroundImage: NetworkImage(match.avatar)),
                const SizedBox(height: 16),
                Text('${match.name}, ${match.age}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {}, // Accept
                      icon: const Icon(Icons.favorite, color: Colors.white),
                      label: const Text('Say Hi',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: controller.startSearch, // Skip
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white54),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      child: const Text('Skip',
                          style: TextStyle(color: Colors.white54)),
                    )
                  ],
                )
              ],
            );
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Radar Animation Placeholder
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                width: controller.isSearching.value ? 250 : 200,
                height: controller.isSearching.value ? 250 : 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: controller.isSearching.value
                      ? Colors.pinkAccent.withOpacity(0.2)
                      : Colors.white10,
                  border: Border.all(
                      color: controller.isSearching.value
                          ? Colors.pinkAccent
                          : Colors.white24,
                      width: 2),
                ),
                child: Icon(Icons.favorite,
                    size: 80,
                    color: controller.isSearching.value
                        ? Colors.pinkAccent
                        : Colors.white54),
              ),
              const SizedBox(height: 50),
              Text(
                controller.isSearching.value
                    ? 'Searching for your perfect match...'
                    : 'Ready to meet someone new?',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: controller.isSearching.value
                    ? controller.stopSearch
                    : controller.startSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.isSearching.value
                      ? Colors.grey
                      : Colors.pinkAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(
                    controller.isSearching.value ? 'Stop Search' : 'Find Match',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ],
          );
        }),
      ),
    );
  }
}
