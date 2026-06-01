import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/room_controller.dart';
import '../widgets/seat_widget.dart';
import '../widgets/room_chat_widget.dart';

class VoiceRoomScreen extends StatelessWidget {
  const VoiceRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RoomController controller = Get.find<RoomController>();

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "ARVIND PARTY ROOM",
        ),
      ),

      body: Column(

        children: [

          const SizedBox(height: 15),

          _buildRoomHeader(),

          const SizedBox(height: 20),

          Expanded(
            child: _buildSeats(),
          ),
          
          _buildChatArea(controller),
          
          _buildChatInput(controller),

          _buildBottomBar(),

        ],
      ),
    );
  }

  Widget _buildRoomHeader() {

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
      ),

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius:
            BorderRadius.circular(15),
      ),

      child: const Row(

        children: [

          CircleAvatar(
            radius: 25,
            child: Icon(Icons.mic),
          ),

          SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  "Arvind Official Room",
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                Text(
                  "120 Online",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeats() {
    final RoomController controller = Get.find<RoomController>();

    return Obx(
      () => GridView.builder(

        shrinkWrap: true,

        itemCount:
            controller.seats.length,

        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),

        itemBuilder: (_, index) {

          return SeatWidget(
            seat:
                controller.seats[index],
          );
        },
      ),
    );
  }

  Widget _buildChatArea(RoomController controller) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(10),
      child: Obx(
        () => ListView.builder(
          itemCount: controller.messages.length,
          itemBuilder: (_, index) {
            return RoomChatWidget(
              message: controller.messages[index],
            );
          },
        ),
      ),
    );
  }

  Widget _buildChatInput(RoomController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.chatController,
              decoration: const InputDecoration(
                hintText: "Type Message",
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              controller.sendMessage(controller.chatController.text);
              controller.chatController.clear();
            },
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final RoomController controller = Get.find<RoomController>();

    return Container(

      padding: const EdgeInsets.all(12),

      child: Row(

        mainAxisAlignment:
            MainAxisAlignment.spaceAround,

        children: [

          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.mic),
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chat),
          ),

          IconButton(
            onPressed: () {
              _showGiftPanel(controller);
            },
            icon: const Icon(Icons.card_giftcard),
          ),

          IconButton(
            onPressed: () {
              _showMembersPanel(controller);
            },
            icon: const Icon(Icons.people),
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
    );
  }

  void _showMembersPanel(RoomController controller) {
    Get.bottomSheet(
      Container(
        height: 500,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25),
          ),
        ),
        child: Obx(
          () => ListView.builder(
            itemCount: controller.members.length,
            itemBuilder: (_, index) {
              final user = controller.members[index];

              return ListTile(
                leading: const CircleAvatar(),
                title: Text(user.name),
                subtitle: Text(
                  user.isHost
                      ? "Host"
                      : user.isAdmin
                          ? "Admin"
                          : "Member",
                ),
                trailing: const Icon(Icons.more_vert),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showGiftPanel(RoomController controller) {
    Get.bottomSheet(
      Container(
        height: 350,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25),
          ),
        ),
        child: Obx(
          () => GridView.builder(
            itemCount: controller.gifts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
            ),
            itemBuilder: (_, index) {
              final gift = controller.gifts[index];

              return GestureDetector(
                onTap: () {
                  controller.sendGift(gift);
                  Get.back();
                },
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.card_giftcard,
                        size: 40,
                      ),
                      Text(gift.name),
                      Text("${gift.price}"),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
