import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/seat_model.dart';

class SeatWidget extends StatelessWidget {

  final SeatModel seat;

  const SeatWidget({
    super.key,
    required this.seat,
  });

  @override
  Widget build(BuildContext context) {

    IconData icon = Icons.mic;

    if (seat.isLocked) {
      icon = Icons.lock;
    }

    if (seat.isMuted) {
      icon = Icons.mic_off;
    }

    if (seat.isHost) {
      icon = Icons.star;
    }

    return GestureDetector(
      onTap: () {
        Get.bottomSheet(
          Container(
            height: 300,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25),
              ),
            ),
            child: Column(
              children: const [
                SizedBox(height: 10),
                ListTile(
                  leading: Icon(Icons.mic),
                  title: Text("Invite User"),
                ),
                ListTile(
                  leading: Icon(Icons.lock),
                  title: Text("Lock Seat"),
                ),
                ListTile(
                  leading: Icon(Icons.lock_open),
                  title: Text("Unlock Seat"),
                ),
                ListTile(
                  leading: Icon(Icons.volume_off),
                  title: Text("Mute Seat"),
                ),
              ],
            ),
          ),
        );
      },
      child: Column(

        children: [

          CircleAvatar(
            radius: 30,
            child: Icon(icon),
          ),

          const SizedBox(height: 5),

          Text(
            seat.userName.isEmpty
                ? "Empty"
                : seat.userName,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
