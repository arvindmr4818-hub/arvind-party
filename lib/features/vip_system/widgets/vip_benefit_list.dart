// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/vip_system/widgets/vip_benefit_list.dart
// ARVIND PARTY - VIP BENEFIT LIST WIDGET
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../models/vip_model.dart';

class VIPBenefitList extends StatelessWidget {
  final VIPBenefits benefits;

  const VIPBenefitList({
    super.key,
    required this.benefits,
  });

  @override
  Widget build(BuildContext context) {
    final benefitsList = [
      {
        'icon': Icons.ads_click,
        'label': 'Ad Free',
        'enabled': benefits.adFree,
      },
      {
        'icon': Icons.meeting_room,
        'label': 'Unlimited Rooms',
        'enabled': benefits.unlimitedRooms,
      },
      {
        'icon': Icons.widgets,
        'label': 'Premium Widgets',
        'enabled': benefits.premiumWidgets,
      },
      {
        'icon': Icons.auto_awesome,
        'label': 'Exclusive Frames',
        'enabled': benefits.exclusiveFrames,
      },
      {
        'icon': Icons.stars,
        'label': 'Exclusive Batches',
        'enabled': benefits.exclusiveBatches,
      },
      {
        'icon': Icons.support_agent,
        'label': 'Priority Support',
        'enabled': benefits.prioritySupport,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: benefitsList.map((benefit) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                benefit['enabled'] as bool
                    ? Icons.check_circle
                    : Icons.cancel,
                color: benefit['enabled'] as bool
                    ? Colors.green
                    : Colors.grey[300],
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                benefit['label'] as String,
                style: TextStyle(
                  fontSize: 16,
                  color: benefit['enabled'] as bool
                      ? Colors.black
                      : Colors.grey[400],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}