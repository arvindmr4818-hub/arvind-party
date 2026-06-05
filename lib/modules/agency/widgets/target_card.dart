import 'package:flutter/material.dart';
import '../models/agency_target_model.dart';

class TargetCard extends StatelessWidget {
  final AgencyTargetModel target;

  const TargetCard({
    super.key,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xff1A1924),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: Row(
        children: [
          const Icon(Icons.track_changes_outlined,
              color: Colors.amber, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  target.targetTitle,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  "Req: ${target.requiredCoins} Coins / ${target.requiredHours} Hrs",
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6)),
            child: Text(
              "+\$${target.rewardBonusUSD}",
              style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
