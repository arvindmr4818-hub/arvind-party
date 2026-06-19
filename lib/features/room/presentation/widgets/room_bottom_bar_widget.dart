// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/modules/room/widgets/room_bottom_bar_widget.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/room_controller.dart';
import 'raise_hand_sheet.dart';

class RoomBottomBarWidget extends StatefulWidget {
  const RoomBottomBarWidget({super.key});

  @override
  State<RoomBottomBarWidget> createState() => _RoomBottomBarWidgetState();
}

class _RoomBottomBarWidgetState extends State<RoomBottomBarWidget> {
  final _msgCtrl = TextEditingController();

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RoomController>();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF15141F),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // ── Mic Toggle ──────────────────────────────────────────────────
          Obx(() {
            final muted = ctrl.isUserMuted.value;
            final onMic = ctrl.myCurrentSeatIndex.value >= 0;
            if (!onMic) return const SizedBox.shrink();
            return _BarButton(
              icon: muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.redAccent : const Color(0xFFFF8906),
              onTap: ctrl.toggleSelfMute,
            );
          }),

          // ── Chat Input ──────────────────────────────────────────────────
          Expanded(
            child: Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0E17),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _msgCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(ctrl),
                decoration: InputDecoration(
                  hintText: 'Say something...',
                  hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  suffixIcon: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.send, color: Color(0xFFFF8906), size: 18),
                    onPressed: () => _send(ctrl),
                  ),
                ),
              ),
            ),
          ),

          // ── Raise Hand ──────────────────────────────────────────────────
          Obx(() {
            final hasRequests = ctrl.raiseHandRequests.isNotEmpty;
            return Stack(
              children: [
                _BarButton(
                  icon: Icons.back_hand_outlined,
                  color: Colors.amber,
                  onTap: () {
                    if (ctrl.canManageRoom) {
                      Get.bottomSheet(RaiseHandSheet(ctrl: ctrl));
                    } else {
                      ctrl.sendRaiseHand();
                    }
                  },
                ),
                if (hasRequests && ctrl.canManageRoom)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                          color: Colors.redAccent, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          '${ctrl.raiseHandRequests.length}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),

          const SizedBox(width: 4),

          // ── Gift ────────────────────────────────────────────────────────
          _BarButton(
            icon: Icons.card_giftcard,
            color: Colors.purpleAccent,
            onTap: () {
              Get.snackbar('🎁 Gifts', 'Gift panel coming soon!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFF15141F),
                  colorText: Colors.white);
            },
          ),

          const SizedBox(width: 4),

          // ── More (host admin panel) ──────────────────────────────────────
          Obx(() => ctrl.canManageRoom
              ? _BarButton(
                  icon: Icons.settings,
                  color: Colors.white38,
                  onTap: () => _showAdminPanel(ctrl),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  void _send(RoomController ctrl) {
    final text = _msgCtrl.text.trim();
    if (text.isNotEmpty) {
      ctrl.sendChatMessage(text);
      _msgCtrl.clear();
    }
  }

  void _showAdminPanel(RoomController ctrl) {
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
            const SizedBox(height: 14),
            const Text('Room Controls',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 12),
            _AdminTile(
              Icons.campaign,
              'Edit Announcement',
              Colors.orange,
              () {
                Get.back();
                _editDialog(
                    'Announcement',
                    ctrl.currentRoom.value?.announcement ?? '',
                    ctrl.updateAnnouncement);
              },
            ),
            _AdminTile(
              Icons.push_pin,
              'Edit Pinned Message',
              Colors.purple,
              () {
                Get.back();
                _editDialog(
                    'Pinned Message',
                    ctrl.currentRoom.value?.pinnedMessage ?? '',
                    ctrl.updatePinnedMessage);
              },
            ),
            _AdminTile(
              Icons.waving_hand,
              'Edit Welcome Message',
              Colors.cyan,
              () {
                Get.back();
                _editDialog(
                    'Welcome Message',
                    ctrl.currentRoom.value?.welcomeMessage ?? '',
                    ctrl.updateWelcomeMessage);
              },
            ),
            _AdminTile(
              Icons.topic,
              'Edit Topic',
              Colors.greenAccent,
              () {
                Get.back();
                _editDialog('Topic', ctrl.currentRoom.value?.topic ?? '',
                    ctrl.updateTopic);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editDialog(String label, String current, void Function(String) onSave) {
    final tc = TextEditingController(text: current);
    Get.dialog(AlertDialog(
      backgroundColor: const Color(0xFF15141F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Edit $label',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      content: TextField(
        controller: tc,
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
            child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
        TextButton(
          onPressed: () {
            onSave(tc.text.trim());
            Get.back();
          },
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF8906)),
          child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _BarButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _BarButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          // FIXED: Deprecated .withOpacity changed to modern .withValues config runtime method
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AdminTile(this.icon, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            // FIXED: Deprecated .withOpacity changed to modern .withValues config runtime method
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
    );
  }
}