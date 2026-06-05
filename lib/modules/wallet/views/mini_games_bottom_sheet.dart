import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'mini_games_controller.dart';

class MiniGamesBottomSheet extends StatelessWidget {
  const MiniGamesBottomSheet({super.key});

  static void show() {
    Get.bottomSheet(const MiniGamesBottomSheet(), isScrollControlled: true);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MiniGamesController());

    return Container(
      height: Get.height * 0.5,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF15141F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Play Mini Games',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: Obx(() => GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16),
                  itemCount: controller.games.length,
                  itemBuilder: (context, index) {
                    final game = controller.games[index];
                    return GestureDetector(
                      onTap: () => controller.launchGame(game),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(game.icon,
                                style: const TextStyle(fontSize: 40)),
                            const SizedBox(height: 8),
                            Text(game.title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                                textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }
}
