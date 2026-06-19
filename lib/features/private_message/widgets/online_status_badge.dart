import 'package:flutter/material.dart';
import '../models/private_message_model.dart';

class OnlineStatusBadge extends StatelessWidget {
  final UserStatus status;
  final bool showText;

  const OnlineStatusBadge({
    super.key,
    required this.status,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.isOnline ? Colors.green[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status.isOnline ? Colors.green : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: status.isOnline ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          if (showText) ...[
            const SizedBox(width: 4),
            Text(
              status.getStatusText(),
              style: TextStyle(
                fontSize: 12,
                color: status.isOnline ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}