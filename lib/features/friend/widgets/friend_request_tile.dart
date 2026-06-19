import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/friend_controller.dart';
import '../models/friend_model.dart';

class FriendRequestTile extends GetView<FriendController> {
  final FriendRequestModel request;
  final bool isIncoming;
  const FriendRequestTile({super.key, required this.request, this.isIncoming = true});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(request.senderAvatar ?? 'https://picsum.photos/100')),
      title: Text(request.senderName),
      subtitle: Text(_formatTime(request.createdAt)),
      trailing: isIncoming ? Row(mainAxisSize: MainAxisSize.min, children: [
        ElevatedButton(onPressed: () => controller.acceptRequest(request.id, request.senderId),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text('Accept', style: TextStyle(color: Colors.white))),
        const SizedBox(width: 8),
        OutlinedButton(onPressed: () => controller.rejectRequest(request.id), child: const Text('Reject')),
      ]) : Chip(label: const Text('Sent', style: TextStyle(color: Colors.white)), backgroundColor: Colors.orange),
    );
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${date.day}/${date.month}';
  }
}