import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/block_model.dart';
import '../controllers/block_controller.dart';

class BlockActionDialog extends GetView<BlockController> {
  final String targetUserId;
  final String targetUsername;
  final String? targetAvatar;

  const BlockActionDialog({super.key, required this.targetUserId, required this.targetUsername, this.targetAvatar});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 30, backgroundImage: NetworkImage(targetAvatar ?? 'https://picsum.photos/100')),
            const SizedBox(height: 12),
            Text('Actions for $targetUsername', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Block User', style: TextStyle(color: Colors.red)),
              subtitle: const Text('They will not be able to message or add you.'),
              onTap: () {
                controller.blockUser(targetUserId, targetUsername, avatarUrl: targetAvatar);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.volume_off, color: Colors.orange),
              title: const Text('Mute User', style: TextStyle(color: Colors.orange)),
              subtitle: const Text('Stop receiving notifications from this user.'),
              onTap: () => _showMuteDurationPicker(context),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ],
        ),
      ),
    );
  }

  void _showMuteDurationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: MuteDuration.values.map((duration) {
            String label;
            switch (duration) {
              case MuteDuration.fifteenMinutes: label = '15 Minutes'; break;
              case MuteDuration.oneHour: label = '1 Hour'; break;
              case MuteDuration.sixHours: label = '6 Hours'; break;
              case MuteDuration.oneDay: label = '1 Day'; break;
              case MuteDuration.oneWeek: label = '1 Week'; break;
              case MuteDuration.forever: label = 'Forever'; break;
            }
            return ListTile(
              title: Text(label),
              onTap: () {
                controller.muteUser(targetUserId, targetUsername, duration, avatarUrl: targetAvatar);
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}