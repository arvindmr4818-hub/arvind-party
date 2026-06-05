import 'package:flutter/material.dart';
import '../models/agency_model.dart';

class AgencyCard extends StatelessWidget {
  final AgencyModel agency;
  final VoidCallback onTap;

  const AgencyCard({
    super.key,
    required this.agency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xff15141F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.02)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(agency.logo),
              backgroundColor: const Color(0xff2A2838),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    agency.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: Colors.cyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "GUILD LEVEL ${agency.level}",
                      style: const TextStyle(
                          color: Colors.cyan,
                          fontSize: 8,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "🎙️ ${agency.totalHosts} Anchors",
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${agency.monthlyRevenue.toStringAsFixed(0)} MTD",
                  style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
