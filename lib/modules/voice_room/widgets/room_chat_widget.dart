import 'package:flutter/material.dart';

import '../models/room_message_model.dart';

class RoomChatWidget extends StatelessWidget {

  final RoomMessageModel message;

  const RoomChatWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {

    IconData icon = Icons.chat;

    if (message.type == "join") {
      icon = Icons.login;
    }

    if (message.type == "leave") {
      icon = Icons.logout;
    }

    if (message.type == "gift") {
      icon = Icons.card_giftcard;
    }

    if (message.type == "system") {
      icon = Icons.info;
    }

    return Container(

      margin: const EdgeInsets.symmetric(
        vertical: 3,
      ),

      child: Row(

        children: [

          Icon(
            icon,
            size: 18,
          ),

          const SizedBox(width: 5),

          Expanded(

            child: Text(

              "${message.senderName}: ${message.message}",

            ),

          ),
        ],
      ),
    );
  }
}
