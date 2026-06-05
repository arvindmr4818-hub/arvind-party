import 'package:flutter/material.dart';

class FamilyBadge extends StatelessWidget {
  final String familyName;
  final int familyLevel;
  final double fontSize;

  const FamilyBadge({
    super.key,
    required this.familyName,
    required this.familyLevel,
    this.fontSize = 9,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffFF8906), Colors.deepOrange],
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: const Color(0xffFF8906).withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shield, color: Colors.white, size: 9),
          const SizedBox(width: 3),
          Text(
            "$familyName L$familyLevel",
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
