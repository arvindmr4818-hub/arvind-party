import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/mini_games_controller.dart';

// UI Helper class to map icons and names to your real GameType enum
class GameUIWrapper {
  final GameType type;
  final String title;
  final String icon;

  GameUIWrapper({required this.type, required this.title, required this.icon});
}

class MiniGamesBottomSheet extends StatelessWidget {
  const MiniGamesBottomSheet({super.key});

  static void show() {
    Get.bottomSheet(const MiniGamesBottomSheet(), isScrollControlled: true);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Safely find your active MiniGamesController instance
    final controller = Get.find<MiniGamesController>();

    // ✅ Real List: Mapping your real GameType enum with proper UI attributes
    final List<GameUIWrapper> uiGamesList = [
      GameUIWrapper(type: GameType.luckyWheel, title: 'Lucky Wheel', icon: '🎡'),
      GameUIWrapper(type: GameType.scratchCard, title: 'Scratch Card', icon: '👑'),
      GameUIWrapper(type: GameType.diceRoll, title: 'Dice Roll', icon: '🎲'),
      GameUIWrapper(type: GameType.cardFlip, title: 'Card Flip', icon: '🃏'),
      GameUIWrapper(type: GameType.slotSpin, title: 'Slot Machine', icon: '🎰'),
    ];

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Play Mini Games',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              // Display live wallet coins directly from the controller cache/state
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text('${controller.coins.value}',
                            style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Obx(() {
              // Show loader globally if any server api game computation is loading
              if (controller.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF8906)));
              }

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16),
                itemCount: uiGamesList.length,
                itemBuilder: (context, index) {
                  final game = uiGamesList[index];
                  return GestureDetector(
                    // ✅ FIX: Directly invokes your real async playGame method
                    onTap: () async {
                      Get.back(); // Close bottom sheet before starting animation frame
                      bool success = await controller.playGame(game.type, bet: 10); // Standard default bet assigned
                      
                      if (success && controller.lastResult.value != null) {
                        final result = controller.lastResult.value!;
                        Get.snackbar(
                          result.isWin ? 'Winner! 🎉' : 'Better Luck! 👍',
                          result.message,
                          backgroundColor: const Color(0xFF15141F),
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP,
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(game.icon, style: const TextStyle(fontSize: 40)),
                          const SizedBox(height: 8),
                          Text(game.title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                              textAlign: TextAlign.center),
                          if (game.type == GameType.luckyWheel) ...[
                            const SizedBox(height: 4),
                            Text('Spins: ${controller.spinsLeftToday.value}',
                                style: const TextStyle(color: Colors.white38, fontSize: 10)),
                          ]
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}