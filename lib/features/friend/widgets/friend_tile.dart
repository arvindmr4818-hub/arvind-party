import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/friend_model.dart';
import '../controllers/friend_controller.dart';

class FriendTile extends GetView<FriendController> {
  final FriendModel friend;
  final VoidCallback? onTap;
  final bool showStatusActions;

  const FriendTile({super.key, required this.friend, this.onTap, this.showStatusActions = true});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap ?? () => _showFriendOptions(context),
      leading: Stack(children: [
        CircleAvatar(radius: 24, backgroundImage: NetworkImage(friend.avatarUrl ?? 'https://picsum.photos/100')),
        if (friend.isOnline) Positioned(bottom: 0, right: 0, child: Container(width: 14, height: 14,
          decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
        )),
      ]),
      title: Text(friend.username, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Row(children: [
        if (friend.mutualFriendsCount > 0) Text('${friend.mutualFriendsCount} mutual', style: const TextStyle(color: Colors.grey, fontSize: 12)),
        if (friend.mutualFriendsCount > 0 && friend.lastSeen != null) const SizedBox(width: 8),
        if (friend.lastSeen != null && !friend.isOnline) Text('Last seen ${_formatLastSeen(friend.lastSeen!)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ]),
      trailing: showStatusActions ? _buildActionButton() : null,
    );
  }

  Widget _buildActionButton() {
    switch (friend.status) {
      case FriendStatus.friends:
        return Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(icon: const Icon(Icons.chat_bubble_outline, color: Colors.blue), onPressed: () {}),
          PopupMenuButton<String>(onSelected: (value) {
            if (value == 'remove') controller.removeFriend(friend.id);
          }, itemBuilder: (context) => const [
            PopupMenuItem(value: 'remove', child: Text('Remove Friend')),
          ]),
        ]);
      case FriendStatus.following:
        return TextButton(onPressed: () => controller.unfollowUser(friend.id), child: const Text('Unfollow', style: TextStyle(color: Colors.red)));
      case FriendStatus.follower:
        return ElevatedButton(onPressed: () => controller.sendRequest(friend.id), child: const Text('Follow Back'));
      case FriendStatus.pendingOutgoing:
        return const Chip(label: Text('Pending'), backgroundColor: Colors.orange, labelStyle: TextStyle(fontSize: 12));
      case FriendStatus.pendingIncoming:
        return ElevatedButton(onPressed: () => controller.acceptRequest('req_${friend.id}', friend.id), child: const Text('Accept'));
      default:
        return ElevatedButton(onPressed: () => controller.sendRequest(friend.id), child: const Text('Add Friend'));
    }
  }

  String _formatLastSeen(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _showFriendOptions(BuildContext context) {
    showModalBottomSheet(context: context, builder: (ctx) => SafeArea(child: Wrap(children: [
      ListTile(leading: const Icon(Icons.person), title: const Text('View Profile'), onTap: () => Navigator.pop(ctx)),
      ListTile(leading: const Icon(Icons.people), title: const Text('Mutual Friends'),
        onTap: () { Navigator.pop(ctx); controller.loadMutualFriends(friend.id); }),
      if (friend.status == FriendStatus.friends)
        ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text('Remove Friend', style: TextStyle(color: Colors.red)),
          onTap: () { controller.removeFriend(friend.id); Navigator.pop(ctx); }),
    ])));
  }
}