import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/family_controller.dart' hide FamilyModel;
import '../models/family_model.dart' as model;
import '../widgets/family_rank_card.dart';

class FamilyRankingScreen extends StatefulWidget {
  const FamilyRankingScreen({super.key});

  @override
  State<FamilyRankingScreen> createState() => _FamilyRankingScreenState();
}

class _FamilyRankingScreenState extends State<FamilyRankingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FamilyController controller = Get.find<FamilyController>();
  final List<String> timelines = ["Daily", "Weekly", "Monthly"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: timelines.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        controller.loadFamilyRankings(timelines[_tabController.index]);
      }
    });
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
          "Global Clan Standings",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xffFF8906),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          tabs: timelines.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(12.0),
            child: TabBarView(
              controller: _tabController,
              children:
                  timelines.map((t) => _buildTimelineRankingFeed()).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineRankingFeed() {
    return Obx(() {
      if (controller.globalFamilyRankings.isEmpty) {
        return const Center(
          child: Text("Processing real-time leaderboard arrays...",
              style: TextStyle(color: Colors.white24, fontSize: 13)),
        );
      }

      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: controller.globalFamilyRankings.length,
        itemBuilder: (context, index) {
          final clanData = controller.globalFamilyRankings[index];
          final familyModel = model.FamilyModel(
            id: clanData.id,
            name: clanData.name,
            logo: clanData.avatar,
            banner: clanData.avatar,
            description: clanData.description,
            notice: '',
            level: clanData.level,
            points: clanData.totalCoins,
            currentExp: 0,
            nextLevelExp: 5000,
            membersCount: clanData.memberCount,
            maxMembersLimit: 100,
            ownerId: clanData.ownerId,
            ownerName: 'Leader',
          );
          return FamilyRankCard(
            family: familyModel,
            rankPosition: index + 1,
          );
        },
      );
    });
  }
}