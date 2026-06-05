// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/modules/home/views/home_screen.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'tabs/discover_tab.dart';
import 'tabs/rooms_tab.dart';
import 'tabs/messages_tab.dart';
import 'tabs/profile_tab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get.find — HomeBinding ne inject kiya hai
    final ctrl = Get.find<HomeController>();

    final tabs = const [
      DiscoverTab(),
      RoomsTab(),
      MessagesTab(),
      ProfileTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: Obx(() => tabs[ctrl.currentIndex.value]),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF15141F),
            border: Border(
              top: BorderSide(color: Color(0xFF2A2838), width: 1),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: ctrl.currentIndex.value,
            onTap: ctrl.changeTab,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFFFF8906),
            unselectedItemColor: Colors.white24,
            selectedLabelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore),
                label: 'Discover',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.mic_none),
                activeIcon: Icon(Icons.mic),
                label: 'Rooms',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'Messages',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
