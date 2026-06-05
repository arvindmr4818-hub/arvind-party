import 'package:flutter/material.dart';
import '../models/family_model.dart';

class FamilyRankCard extends StatelessWidget {
  final FamilyModel family;
  final int rankPosition;

  const FamilyRankCard({
    super.key,
    required this.family,
    required this.rankPosition,
  });

  @override
  Widget build(BuildContext context) {
    Color positionColor = rankPosition == 1
        ? Colors.amber
        : rankPosition == 2
            ? Colors.grey
            : rankPosition == 3
                ? Colors.orange.shade300
                : Colors.white24;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff15141F),
        borderRadius: BorderRadius.circular(12),
        border: rankPosition <= 3
            ? Border.all(color: positionColor.withOpacity(0.15))
            : null,
      ),
      child: Row(
        children: [
          Text(
            "#$rankPosition",
            style: TextStyle(
                color: positionColor,
                fontWeight: FontWeight.w900,
                fontSize: 14),
          ),
          const SizedBox(width: 14),
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(family.logo),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  family.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
                Text(
                  "Owner: ${family.ownerName}",
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "🔥 ${family.points}",
                style: const TextStyle(
                    color: Colors.cyan,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "LVL ${family.level}",
                style: const TextStyle(color: Colors.white24, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
