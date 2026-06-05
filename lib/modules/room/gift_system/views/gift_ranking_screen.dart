import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GiftRankingScreen extends StatefulWidget {
  const GiftRankingScreen({super.key});

  @override
  State<GiftRankingScreen> createState() => _GiftRankingScreenState();
}

class _GiftRankingScreenState extends State<GiftRankingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          "Global Star Rankings",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xffFF8906),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          tabs: const [
            Tab(text: "Daily"),
            Tab(text: "Weekly"),
            Tab(text: "Monthly"),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildRankList("daily"),
            _buildRankList("weekly"),
            _buildRankList("monthly"),
          ],
        ),
      ),
    );
  }

  Widget _buildRankList(String timeline) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(12),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            int rank = index + 1;
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xff15141F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    "#$rank",
                    style: TextStyle(
                      color:
                          rank <= 3 ? const Color(0xffFF8906) : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  CircleAvatar(
                    radius: 16,
                    backgroundImage:
                        NetworkImage("https://picsum.photos/12$index"),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Global User $rank",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    "${100000 / rank} 🔥",
                    style: const TextStyle(
                        color: Colors.cyan,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
