import 'package:flutter/material.dart';
import '../models/agency_member_model.dart';

class HostTile extends StatelessWidget {
  final AgencyMemberModel host;
  final VoidCallback onActionTriggered;

  const HostTile({
    super.key,
    required this.host,
    required this.onActionTriggered,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xff15141F),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Dynamic Profile Avatar Ring Stack
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(host.avatar),
              ),
              Container(
                height: 10,
                width: 10,
                decoration: BoxDecoration(
                  color: host.isCurrentlyBroadcasting
                      ? Colors.greenAccent
                      : Colors.white24,
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: const Color(0xff15141F), width: 1.5),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Metadata matrix content descriptors
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        host.username,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Lv${host.level}",
                      style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 9,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text("⏱️ ${host.onlineHoursThisMonth} hrs",
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 10)),
                    const SizedBox(width: 10),
                    Text(
                        "📈 Progress: ${host.targetProgressPercentage.toStringAsFixed(0)}%",
                        style:
                            const TextStyle(color: Colors.cyan, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),

          // Structural Actions Handle Trigger
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white24, size: 18),
            onPressed: onActionTriggered,
          ),
        ],
      ),
    );
  }
}
