import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/room_model.dart';
import '../views/voice_room_screen.dart';

class RoomCard extends StatelessWidget {

  final RoomModel room;

  const RoomCard({
    super.key,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      child: ListTile(
        onTap: () {
          Get.to(
            () => const VoiceRoomScreen(),
          );
        },
        leading: const CircleAvatar(
          child: Icon(Icons.mic),
        ),

        title: Text(room.roomName),

        subtitle: Text(
          "Host: ${room.ownerName}",
        ),

        trailing: Text(
          "${room.onlineUsers}",
        ),
      ),
    );
  }
}
