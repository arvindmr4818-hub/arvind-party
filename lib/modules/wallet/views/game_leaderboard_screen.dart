import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';

class GameLeaderboardScreen extends StatefulWidget {
  const GameLeaderboardScreen({super.key});

  @override
  State<GameLeaderboardScreen> createState() => _GameLeaderboardScreenState();
}

class _GameLeaderboardScreenState extends State<GameLeaderboardScreen> {
  final GameController controller = Get.put(GameController());

  @override
  void initState() {
    super.initState();
    // Fetch the leaderboard as soon as the screen opens
    controller.fetchLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        title: const Text('Top Winners of the Week', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff15141F),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoadingLeaderboard.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8906)));
        }

        if (controller.leaderboard.isEmpty) {
          return const Center(
            child: Text(
              'No winners yet this week!\nBe the first to play and win.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.leaderboard.length,
          itemBuilder: (context, index) {
            final winner = controller.leaderboard[index];
            final isTop3 = index < 3;

            return Card(
              color: const Color(0xff15141F),
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: isTop3 
                    ? const BorderSide(color: Color(0xFFFFD700), width: 1.5) // Gold border for Top 3
                    : BorderSide.none,
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isTop3 ? const Color(0xFFFFD700) : Colors.white24,
                  child: Text('#${index + 1}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                title: Text(winner['name'] ?? 'Unknown User', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                trailing: Text('${winner['totalWon']} Coins', style: const TextStyle(color: Color(0xFFFF8906), fontSize: 16, fontWeight: FontWeight.w900)),
              ),
            );
          },
        );
      }),
    );
  }
}