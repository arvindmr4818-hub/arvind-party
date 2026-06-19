// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/modules/room/widgets/raise_hand_sheet.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/room_controller.dart';

class RaiseHandSheet extends StatelessWidget {
  final RoomController ctrl;
  const RaiseHandSheet({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                color: Colors.white24, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.back_hand, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              const Text('Raise Hand Requests',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const Spacer(),
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${ctrl.raiseHandRequests.length}',
                      style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (ctrl.raiseHandRequests.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('No pending requests',
                    style: TextStyle(color: Colors.white38, fontSize: 14)),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ctrl.raiseHandRequests.length,
              separatorBuilder: (_, __) =>
                  Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
              itemBuilder: (_, i) {
                final req = ctrl.raiseHandRequests[i];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF2A2838),
                    backgroundImage: (req.avatar?.isNotEmpty ?? false) ? NetworkImage(req.avatar!) : null,
                    child: (req.avatar?.isEmpty ?? true)
                        ? const Icon(Icons.person, color: Colors.white38, size: 18)
                        : null,
                  ),
                  title: Text(req.userName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  subtitle: const Text('Wants to join mic',
                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Reject Button
                      GestureDetector(
                        onTap: () => ctrl.rejectRaiseHand(req.requestId),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.redAccent, size: 16),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Approve Button
                      GestureDetector(
                        onTap: () {
                          ctrl.approveRaiseHand(req.requestId);
                          if (ctrl.raiseHandRequests.isEmpty) Get.back();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: Colors.greenAccent, size: 16),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}