// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/modules/room/widgets/room_banner_widget.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/room_controller.dart';

class RoomBannerWidget extends StatelessWidget {
  const RoomBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RoomController>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Column(
        children: [
          // ── Banner Image ─────────────────────────────────────────────────
          Obx(() {
            final url = ctrl.currentRoom.value?.banner ?? '';
            return GestureDetector(
              onLongPress:
                  ctrl.canManageRoom ? () => _showEditOptions(ctrl) : null,
              child: Container(
                height: 105,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF15141F),
                  borderRadius: BorderRadius.circular(14),
                  image: url.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(url), fit: BoxFit.cover)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF8906).withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: url.isEmpty
                    ? const Center(
                        child: Icon(Icons.image_outlined,
                            color: Colors.white24, size: 36))
                    : Stack(
                        children: [
                          // Gradient overlay on banner
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.5),
                                ],
                              ),
                            ),
                          ),
                          // Room title overlay
                          Positioned(
                            bottom: 8,
                            left: 12,
                            child: Obx(() => Text(
                                  ctrl.currentRoom.value?.title ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    shadows: [
                                      Shadow(
                                          color: Colors.black54, blurRadius: 6),
                                    ],
                                  ),
                                )),
                          ),
                        ],
                      ),
              ),
            );
          }),

          const SizedBox(height: 8),

          // ── Pinned Message ────────────────────────────────────────────────
          Obx(() {
            final pinned = ctrl.currentRoom.value?.pinnedMessage ?? '';
            if (pinned.isEmpty) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.purpleAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: Colors.purpleAccent.withOpacity(0.25), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.push_pin,
                      color: Colors.purpleAccent, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(pinned,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            );
          }),

          // ── Announcement Ribbon ───────────────────────────────────────────
          Obx(() {
            final ann = ctrl.currentRoom.value?.announcement ?? '';
            if (ann.isEmpty) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF15141F),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFFFF8906).withOpacity(0.2), width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8906).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.volume_up,
                        color: Color(0xFFFF8906), size: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(ann,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  if (ctrl.canManageRoom)
                    GestureDetector(
                      onTap: () => _editAnnouncement(ctrl),
                      child: const Icon(Icons.edit,
                          color: Colors.white30, size: 14),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showEditOptions(RoomController ctrl) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: Color(0xFF15141F),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text('Room Settings',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 16),
            _EditTile(Icons.campaign, 'Edit Announcement', Colors.orange, () {
              Get.back();
              _editAnnouncement(ctrl);
            }),
            _EditTile(Icons.push_pin, 'Edit Pinned Message', Colors.purple, () {
              Get.back();
              _editPinnedMessage(ctrl);
            }),
            _EditTile(Icons.waving_hand, 'Edit Welcome Message', Colors.cyan,
                () {
              Get.back();
              _editWelcomeMessage(ctrl);
            }),
            _EditTile(Icons.topic, 'Edit Topic', Colors.greenAccent, () {
              Get.back();
              _editTopic(ctrl);
            }),
          ],
        ),
      ),
    );
  }

  void _editAnnouncement(RoomController ctrl) {
    _showEditDialog(
      title: 'Edit Announcement',
      current: ctrl.currentRoom.value?.announcement ?? '',
      onSave: ctrl.updateAnnouncement,
    );
  }

  void _editPinnedMessage(RoomController ctrl) {
    _showEditDialog(
      title: 'Edit Pinned Message',
      current: ctrl.currentRoom.value?.pinnedMessage ?? '',
      onSave: ctrl.updatePinnedMessage,
    );
  }

  void _editWelcomeMessage(RoomController ctrl) {
    _showEditDialog(
      title: 'Edit Welcome Message',
      current: ctrl.currentRoom.value?.welcomeMessage ?? '',
      onSave: ctrl.updateWelcomeMessage,
    );
  }

  void _editTopic(RoomController ctrl) {
    _showEditDialog(
      title: 'Edit Topic',
      current: ctrl.currentRoom.value?.topic ?? '',
      onSave: ctrl.updateTopic,
    );
  }

  void _showEditDialog({
    required String title,
    required String current,
    required void Function(String) onSave,
  }) {
    final textCtrl = TextEditingController(text: current);
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF15141F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: textCtrl,
          maxLines: 3,
          maxLength: 150,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0F0E17),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            counterStyle: const TextStyle(color: Colors.white24, fontSize: 11),
          ),
        ),
        actions: [
          TextButton(
              onPressed: Get.back,
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white38))),
          TextButton(
            onPressed: () {
              onSave(textCtrl.text.trim());
              Get.back();
            },
            child: const Text('Save',
                style: TextStyle(
                    color: Color(0xFFFF8906), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _EditTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _EditTile(this.icon, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(label,
          style: const TextStyle(color: Colors.white70, fontSize: 14)),
      trailing:
          const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
    );
  }
}
