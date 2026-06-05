import 'package:flutter/material.dart';

class AnalyticsCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtext;
  final IconData icon;
  final Color tintColor;

  const AnalyticsCard({
    super.key,
    required this.label,
    required this.value,
    required this.subtext,
    required this.icon,
    required this.tintColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff15141F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: tintColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: tintColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 11)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                        color: tintColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 1),
                Text(subtext,
                    style: const TextStyle(color: Colors.white24, fontSize: 9)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
