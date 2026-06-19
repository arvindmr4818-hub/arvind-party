import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/block_model.dart';
import '../controllers/block_controller.dart';

class MutedTile extends GetView<BlockController> {
  final MutedUserModel user;
  const MutedTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(user.avatarUrl ?? 'https://picsum.photos/100')),
      title: Text(user.username),
      subtitle: Text(
        user.mutedUntil == null ? 'Muted forever' : 'Muted until ${_formatDate(user.mutedUntil!)}',
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      trailing: TextButton.icon(
        icon: const Icon(Icons.volume_up, size: 16),
        label: const Text('Unmute'),
        onPressed: () => controller.unmuteUser(user.userId),
        style: TextButton.styleFrom(foregroundColor: Colors.orange),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
}