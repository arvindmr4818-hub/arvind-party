// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room/widgets/member_list.dart
// ARVIND PARTY - MEMBER LIST WIDGET (Permissions + Mic Controls)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/room_controller.dart';

class MemberList extends GetView<RoomController> {
  const MemberList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.builder(
      itemCount: controller.members.length,
      itemBuilder: (context, index) {
        final member = controller.members[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(member.avatarUrl ?? 'https://picsum.photos/100'),
          ),
          title: Text(member.username),
          subtitle: Text(member.role.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!member.isMuted) Icon(Icons.mic, color: Colors.green, size: 18),
              if (member.isSpeaker) Icon(Icons.volume_up, color: Colors.blue, size: 18),
              if (member.isEarMonitoring) Icon(Icons.headphones, color: Colors.purple, size: 18),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'mute') controller.toggleMute();
                  if (value == 'kick') controller.kickMember(member.userId);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'mute', child: Text('Mute')),
                  const PopupMenuItem(value: 'kick', child: Text('Kick')),
                ],
              ),
            ],
          ),
        );
      },
    ));
  }
}