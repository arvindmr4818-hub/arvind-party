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

    final HomeController controller =
        Get.put(HomeController());

    final pages = [
      const DiscoverTab(),
      const RoomsTab(),
      const MessagesTab(),
      const ProfileTab(),
    ];

    return Scaffold(

      body: Obx(
        () => pages[
          controller.currentIndex.value
        ],
      ),

      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex:
              controller.currentIndex.value,

          onTap: controller.changeTab,

          type: BottomNavigationBarType.fixed,

          items: const [

            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: "Discover",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.mic),
              label: "Rooms",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: "Messages",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
