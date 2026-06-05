// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/modules/room/views/room_members_screen.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/room_controller.dart';
import '../models/room_member_model.dart';

class RoomMembersScreen extends StatelessWidget {
  const RoomMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RoomController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        title: Obx(() => Text(
              'Members (${ctrl.members.length})',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white),
            )),
        backgroundColor: const Color(0xFF15141F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.white),
          onPressed: Get.back,
        ),
        actions: [
          // Admin count badge
          Obx(() => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8906).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFFFF8906).withOpacity(0.4)),
                  ),
                  child: Text(
                    'Admins ${ctrl.currentAdminCount}/${ctrl.maxAdminsAllowed}',
                    style: const TextStyle(
                        color: Color(0xFFFF8906),
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )),
        ],
      ),
      body: Obx(() {
        if (ctrl.members.isEmpty) {
          return const Center(
            child: Text('No members yet',
                style: TextStyle(color: Colors.white38, fontSize: 14)),
          );
        }

        // Sort: owner → host → coHost → admin → member → visitor
        final sorted = [...ctrl.members]
          ..sort((a, b) => a.role.index.compareTo(b.role.index));

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: sorted.length,
          separatorBuilder: (_, __) =>
              Divider(color: Colors.white.withOpacity(0.05), height: 1),
          itemBuilder: (context, i) {
            return _MemberTile(member: sorted[i], ctrl: ctrl);
          },
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MEMBER TILE
// ─────────────────────────────────────────────────────────────────────────────

class _MemberTile extends StatelessWidget {
  final RoomMemberModel member;
  final RoomController ctrl;
  const _MemberTile({required this.member, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF2A2838),
            backgroundImage: NetworkImage(member.avatar),
          ),
          // Online indicator
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: member.isOnline ? Colors.greenAccent : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0F0E17), width: 1.5),
              ),
            ),
          ),
        ],
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(member.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
                overflow: TextOverflow.ellipsis),
          ),
          if (member.isOnMic) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8906).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mic, color: Color(0xFFFF8906), size: 10),
                  SizedBox(width: 2),
                  Text('On Mic',
                      style: TextStyle(color: Color(0xFFFF8906), fontSize: 9)),
                ],
              ),
            ),
          ],
        ],
      ),
      subtitle: Row(
        children: [
          _RoleBadge(role: member.role),
          if (member.familyTag != null) ...[
            const SizedBox(width: 6),
            Text('[${member.familyTag}]',
                style:
                    const TextStyle(color: Colors.purpleAccent, fontSize: 11)),
          ],
          const SizedBox(width: 6),
          Text('Lv.${member.userLevel}',
              style: const TextStyle(color: Colors.white30, fontSize: 11)),
        ],
      ),
      trailing: ctrl.canManageMembers
          ? IconButton(
              icon:
                  const Icon(Icons.more_vert, color: Colors.white38, size: 20),
              onPressed: () => _showMemberOptions(context),
            )
          : null,
    );
  }

  void _showMemberOptions(BuildContext context) {
    final canPromote = ctrl.isHost;
    final isAdminLevelAlready = member.role.isAdminLevel;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: Color(0xFF15141F),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // User info
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(member.avatar),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    _RoleBadge(role: member.role),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.08)),
            const SizedBox(height: 8),

            // Options
            if (canPromote && !isAdminLevelAlready) ...[
              _OptionTile(
                icon: Icons.admin_panel_settings,
                iconColor: const Color(0xFFFF8906),
                label: 'Make Admin',
                sublabel:
                    '${ctrl.currentAdminCount}/${ctrl.maxAdminsAllowed} admins used',
                onTap: () {
                  Get.back();
                  ctrl.promoteToAdmin(member.id);
                },
              ),
              _OptionTile(
                icon: Icons.mic_external_on,
                iconColor: Colors.cyanAccent,
                label: 'Make Co-Host',
                onTap: () {
                  Get.back();
                  ctrl.makeCoHost(member.id);
                },
              ),
            ],

            if (canPromote && member.role == MemberRole.admin)
              _OptionTile(
                icon: Icons.remove_moderator,
                iconColor: Colors.amber,
                label: 'Remove Admin Role',
                onTap: () {
                  Get.back();
                  ctrl.removeAdminRole(member.id);
                },
              ),

            if (canPromote && member.role == MemberRole.coHost)
              _OptionTile(
                icon: Icons.remove_moderator,
                iconColor: Colors.amber,
                label: 'Remove Co-Host',
                onTap: () {
                  Get.back();
                  ctrl.removeAdminRole(member.id);
                },
              ),

            if (ctrl.canManageMembers) ...[
              _OptionTile(
                icon: Icons.logout,
                iconColor: Colors.orangeAccent,
                label: 'Kick from Room',
                onTap: () {
                  Get.back();
                  ctrl.kickMember(member.id);
                },
              ),
              _OptionTile(
                icon: Icons.block,
                iconColor: Colors.redAccent,
                label: 'Ban User',
                onTap: () {
                  Get.back();
                  _showBanDialog(member);
                },
              ),
            ],

            if (ctrl.isOwner && member.role != MemberRole.owner)
              _OptionTile(
                icon: Icons.swap_horiz,
                iconColor: Colors.purpleAccent,
                label: 'Transfer Ownership',
                onTap: () {
                  Get.back();
                  ctrl.transferOwnership(member.id);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showBanDialog(RoomMemberModel member) {
    final selectedDuration = BanDuration.oneHour.obs;

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF15141F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Ban ${member.name}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select ban duration:',
                style: TextStyle(color: Colors.white60, fontSize: 13)),
            const SizedBox(height: 12),
            Obx(() => Column(
                  children: BanDuration.values.map((d) {
                    return RadioListTile<BanDuration>(
                      value: d,
                      groupValue: selectedDuration.value,
                      onChanged: (v) => selectedDuration.value = v!,
                      title: Text(d.label,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14)),
                      activeColor: const Color(0xFFFF8906),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              ctrl.banMember(
                userId: member.id,
                username: member.name,
                reason: 'Banned by admin',
                duration: selectedDuration.value,
              );
            },
            child: const Text('Ban',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ROLE BADGE
// ─────────────────────────────────────────────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  final MemberRole role;
  const _RoleBadge({required this.role});

  Color get _color {
    switch (role) {
      case MemberRole.owner:
        return const Color(0xFFFFD700);
      case MemberRole.host:
        return const Color(0xFFFF8906);
      case MemberRole.coHost:
        return Colors.cyanAccent;
      case MemberRole.admin:
        return Colors.purpleAccent;
      case MemberRole.member:
        return Colors.white38;
      case MemberRole.visitor:
        return Colors.white24;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Text(role.label,
          style: TextStyle(
              color: _color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OPTION TILE
// ─────────────────────────────────────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? sublabel;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.sublabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: sublabel != null
          ? Text(sublabel!,
              style: const TextStyle(color: Colors.white30, fontSize: 11))
          : null,
      trailing:
          const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
    );
  }
}
