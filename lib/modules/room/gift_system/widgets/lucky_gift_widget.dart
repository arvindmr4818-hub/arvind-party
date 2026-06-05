import 'package:flutter/material.dart';

class LuckyGiftWidget extends StatelessWidget {
  final int multiplierWin;
  final String winnerName;
  final String giftName;

  const LuckyGiftWidget({
    super.key,
    required this.multiplierWin,
    required this.winnerName,
    required this.giftName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.8),
            Colors.deepPurple.withOpacity(0.9)
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.withOpacity(0.4), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.purple.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          // Lucky Clover Badge Left side icon
          const Text("🍀", style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),

          // Meta textual description parameters tracker
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12, height: 1.3),
                children: [
                  TextSpan(
                      text: winnerName,
                      style: const TextStyle(
                          color: Colors.amber, fontWeight: FontWeight.bold)),
                  const TextSpan(
                      text: " cracked the Lucky ",
                      style: TextStyle(color: Colors.white)),
                  TextSpan(
                      text: giftName,
                      style: const TextStyle(
                          color: Colors.cyan, fontWeight: FontWeight.bold)),
                  const TextSpan(
                      text: " pool mechanism!",
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Big Win Multiplier Ribbon Overlay Stamp
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "WIN x$multiplierWin 🔥",
              style: const TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
