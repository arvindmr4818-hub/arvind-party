import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/friend_controller.dart';

class MutualFriendsDialog extends GetView<FriendController> {
  const MutualFriendsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Mutual Friends', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
            ]),
            const Divider(),
            Expanded(
              child: Obx(() {
                if (controller.mutualFriends.isEmpty) return const Center(child: Text('No mutual friends found'));
                return ListView.separated(
                  itemCount: controller.mutualFriends.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final friend = controller.mutualFriends[index];
                    return ListTile(
                      leading: CircleAvatar(backgroundImage: NetworkImage(friend.avatarUrl ?? 'https://picsum.photos/100')),
                      title: Text(friend.username),
                      subtitle: Text('${friend.mutualFriendsCount} mutual'),
                      onTap: () => Get.back(),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}