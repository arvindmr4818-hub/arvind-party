import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopGiftersScreen extends StatelessWidget {
  const TopGiftersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Local dummy data list mimicking room contextual leaderboard stats
    final List<Map<String, dynamic>> localGifters = [
      {
        "rank": 1,
        "name": "King Arvind 👑",
        "coins": "550,000",
        "avatar": "https://picsum.photos/110"
      },
      {
        "rank": 2,
        "name": "Alpha Dev",
        "coins": "320,000",
        "avatar": "https://picsum.photos/111"
      },
      {
        "rank": 3,
        "name": "Vip Rony",
        "coins": "190,000",
        "avatar": "https://picsum.photos/112"
      },
      {
        "rank": 4,
        "name": "Kabir Singh",
        "coins": "85,000",
        "avatar": "https://picsum.photos/113"
      },
    ];

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
          "Room Contribution Board",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                // Top Podiums Header Banner Container
                _buildPodiumHeader(localGifters.take(3).toList()),
                const SizedBox(height: 20),

                // Remaining Rows Scroll Tape Grid
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: localGifters.length,
                    itemBuilder: (context, index) {
                      final profile = localGifters[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xff15141F),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "#${profile['rank']}",
                              style: TextStyle(
                                color: profile['rank'] == 1
                                    ? Colors.amber
                                    : Colors.white38,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 14),
                            CircleAvatar(
                              radius: 18,
                              backgroundImage: NetworkImage(profile['avatar']),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                profile['name'],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13),
                              ),
                            ),
                            Row(
                              children: [
                                const Text("🪙 ",
                                    style: TextStyle(fontSize: 10)),
                                Text(
                                  profile['coins'],
                                  style: const TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumHeader(List<Map<String, dynamic>> topThree) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.amber.withOpacity(0.05),
          Colors.purple.withOpacity(0.05)
        ]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: topThree.map((user) {
          double avatarSize = user['rank'] == 1 ? 32 : 26;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: CircleAvatar(
                      radius: avatarSize,
                      backgroundColor: Colors.amber,
                      child: CircleAvatar(
                          radius: avatarSize - 2,
                          backgroundImage: NetworkImage(user['avatar'])),
                    ),
                  ),
                  if (user['rank'] == 1)
                    const Text("👑", style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              Text(user['name'],
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
              Text("${user['coins']} pts",
                  style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          );
        }).toList(),
      ),
    );
  }
}
