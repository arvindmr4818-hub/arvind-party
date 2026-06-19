import 'package:flutter/material.dart';

class VerificationBadge extends StatelessWidget {
  final String? badge;
  final String? tooltip;

  const VerificationBadge({super.key, 
    this.badge,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    if (badge == null) return const SizedBox();

    IconData icon;
    Color color;
    String label;

    switch (badge) {
      case 'verified':
        icon = Icons.verified;
        color = Colors.blue;
        label = 'Verified';
        break;
      case 'official':
        icon = Icons.verified_user;
        color = Colors.blue;
        label = 'Official';
        break;
      case 'creator':
        icon = Icons.star;
        color = Colors.amber;
        label = 'Creator';
        break;
      case 'influencer':
        icon = Icons.trending_up;
        color = Colors.orange;
        label = 'Influencer';
        break;
      default:
        return const SizedBox();
    }

    return Tooltip(
      message: tooltip ?? label,
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }
}