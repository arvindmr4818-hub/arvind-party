// ═══════════════════════════════════════════════════════════════════════════
// LIVE ROOM SCREEN — LiveKit Integration (Production Ready)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import '../controllers/room_controller.dart';
import '../../gift/presentation/views/gift_panel_sheet.dart';

class LiveRoomScreen extends StatefulWidget {
  const LiveRoomScreen({super.key});

  @override
  State<LiveRoomScreen> createState() => _LiveRoomScreenState();
}

class _LiveRoomScreenState extends State<LiveRoomScreen> {
  late RoomController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<RoomController>();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _ctrl.leaveRoom();
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D1A),
        body: SafeArea(
          child: Column(children: [
            // ─── TOP BAR ────────────────────────────────────────────────
            _TopBar(ctrl: _ctrl),

            // ─── ROOM BACKGROUND / SEATS ─────────────────────────────────
            Expanded(
              child: Obx(() => _ctrl.isLoading.value
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF8906)))
                  : _RoomBody(ctrl: _ctrl)),
            ),

            // ─── BOTTOM CONTROLS ─────────────────────────────────────────
            _BottomControls(ctrl: _ctrl),
          ]),
        ),
      ),
    );
  }
}

// ─── TOP BAR ──────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final RoomController ctrl;
  const _TopBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        // Room info
        Obx(() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(ctrl.roomName.value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          Text('${ctrl.memberCount.value} listeners', style: const TextStyle(color: Color(0xFFB0B0C0), fontSize: 12)),
        ])),
        const Spacer(),
        // Live badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
          child: const Row(children: [
            Icon(Icons.circle, color: Colors.white, size: 8),
            SizedBox(width: 4),
            Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ]),
        ),
        const SizedBox(width: 8),
        // Close
        GestureDetector(
          onTap: () async { await ctrl.leaveRoom(); Get.back(); },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: const Icon(Icons.close, color: Colors.white, size: 18),
          ),
        ),
      ]),
    );
  }
}

// ─── ROOM BODY with Seats ─────────────────────────────────────────────────
class _RoomBody extends StatelessWidget {
  final RoomController ctrl;
  const _RoomBody({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final seats = ctrl.seats;
      return GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, mainAxisSpacing: 20, crossAxisSpacing: 16, childAspectRatio: 0.75),
        itemCount: seats.length,
        itemBuilder: (_, i) => _SeatWidget(seat: seats[i], ctrl: ctrl),
      );
    });
  }
}

class _SeatWidget extends StatelessWidget {
  final Map<String, dynamic> seat;
  final RoomController ctrl;
  const _SeatWidget({required this.seat, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final occupied = seat['userId'] != null;
    final isSpeaking = ctrl.activeSpeakers.contains(seat['userId']);
    final micEnabled = seat['isAudioEnabled'] == true;

    return GestureDetector(
      onTap: () => ctrl.onSeatTap(seat['seatNumber']),
      child: Column(children: [
        // Avatar
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSpeaking ? const Color(0xFF2ED573) : occupied ? const Color(0xFFFF8906) : Colors.white24,
              width: isSpeaking ? 3 : 2,
            ),
            color: occupied ? null : Colors.white12,
          ),
          child: occupied
              ? ClipOval(child: seat['userAvatar'] != null
                  ? Image.network(seat['userAvatar'], fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _avatar(seat['userName']))
                  : _avatar(seat['userName']))
              : const Icon(Icons.add, color: Colors.white38, size: 28),
        ),
        const SizedBox(height: 6),
        if (occupied) ...[
          Text(seat['userName'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 10),
            maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Icon(!micEnabled ? Icons.mic_off : Icons.mic, color: !micEnabled ? Colors.red : Colors.white60, size: 12),
        ] else
          Text('Seat ${seat['seatNumber']}', style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ]),
    );
  }

  Widget _avatar(String? name) => Container(
    color: const Color(0xFFFF8906),
    child: Center(child: Text((name ?? 'U')[0].toUpperCase(),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20))),
  );
}

// ─── BOTTOM CONTROLS ─────────────────────────────────────────────────────
class _BottomControls extends StatelessWidget {
  final RoomController ctrl;
  const _BottomControls({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black38,
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(children: [
        // Mic toggle
        Obx(() => _ControlBtn(
          icon: ctrl.isMicOn.value ? Icons.mic : Icons.mic_off,
          color: ctrl.isMicOn.value ? Colors.white : Colors.red,
          onTap: ctrl.toggleMic,
          label: ctrl.isMicOn.value ? 'Mute' : 'Unmute',
        )),
        const SizedBox(width: 12),
        // Gift
        _ControlBtn(
          icon: Icons.card_giftcard,
          color: const Color(0xFFFF8906),
          onTap: () => showModalBottomSheet(
            context: context, isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => GiftPanelSheet(roomId: ctrl.currentRoomId.value),
          ),
          label: 'Gift',
        ),
        const SizedBox(width: 12),
        // Chat
        _ControlBtn(
          icon: Icons.chat_bubble_outline,
          color: Colors.white,
          onTap: () => ctrl.toggleChat(),
          label: 'Chat',
        ),
        const Spacer(),
        // Leave
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          onPressed: () async { await ctrl.leaveRoom(); Get.back(); },
          child: const Text('Leave', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String label;
  const _ControlBtn({required this.icon, required this.color, required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      Icon(icon, color: color, size: 24),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
    ]),
  );
}
