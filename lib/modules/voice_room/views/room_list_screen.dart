import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/room_controller.dart';
import '../widgets/room_card.dart';

class RoomListScreen extends StatelessWidget {

  const RoomListScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final RoomController controller =
        Get.put(RoomController());

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Voice Rooms",
        ),
      ),

      body: Obx(
        () => ListView.builder(

          itemCount:
              controller.rooms.length,

          itemBuilder: (_, index) {

            return RoomCard(
              room:
                  controller.rooms[index],
            );
          },
        ),
      ),

      floatingActionButton:
          FloatingActionButton(

        onPressed: () {},

        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}
