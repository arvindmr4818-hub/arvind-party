import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/block_model.dart';
import '../controllers/block_controller.dart';

class BlockedTile extends GetView<BlockController> {
  final BlockedUserModel user;
  const BlockedTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(user.avatarUrl ?? 'https://picsum.photos/100')),
      title: Text(user.username),
      subtitle: Text('Blocked on ${user.blockedAt.day}/${user.blockedAt.month}/${user.blockedAt.year}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
      trailing: TextButton.icon(
        icon: const Icon(Icons.block, size: 16),
        label: const Text('Unblock'),
        onPressed: () => controller.unblockUser(user.userId),
        style: TextButton.styleFrom(foregroundColor: Colors.blue),
      ),
    );
  }
}