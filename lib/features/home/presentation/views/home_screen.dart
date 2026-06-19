// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/home/presentation/views/home_screen.dart
// ARVIND PARTY - HOME SCREEN (Banner + Categories + 6 Room Sections + Search)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/banner_slider.dart';
import '../widgets/category_grid.dart';
import '../widgets/room_section_card.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController()); // Ensure controller is available

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        title: const Text('Arvind Party',
            style: TextStyle(
                color: Color(0xFFFF8906),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2)),
        backgroundColor: const Color(0xFF15141F),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white70),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white70),
            onPressed: () => Get.toNamed('/profile'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.banners.isEmpty) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF8906)));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Search Bar
              HomeSearchBar(),

              // Banner Slider
              BannerSlider(),

              const SizedBox(height: 16),

              // Categories
              CategoryGrid(),

              const SizedBox(height: 8),

              // Room Sections
              RoomSectionCard(
                title: 'Recommended Rooms',
                rooms: controller.recommendedRooms,
                onViewAll: () => Get.toNamed('/rooms', arguments: {'type': 'recommended'}),
              ),

              RoomSectionCard(
                title: 'Trending Rooms',
                rooms: controller.trendingRooms,
                onViewAll: () => Get.toNamed('/rooms', arguments: {'type': 'trending'}),
              ),

              RoomSectionCard(
                title: 'New Rooms',
                rooms: controller.newRooms,
                onViewAll: () => Get.toNamed('/rooms', arguments: {'type': 'new'}),
              ),

              RoomSectionCard(
                title: 'Official Rooms',
                rooms: controller.officialRooms,
                onViewAll: () => Get.toNamed('/rooms', arguments: {'type': 'official'}),
              ),

              RoomSectionCard(
                title: 'Family Rooms',
                rooms: controller.familyRooms,
                onViewAll: () => Get.toNamed('/rooms', arguments: {'type': 'family'}),
              ),

              RoomSectionCard(
                title: 'Agency Rooms',
                rooms: controller.agencyRooms,
                onViewAll: () => Get.toNamed('/rooms', arguments: {'type': 'agency'}),
              ),

              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }
}