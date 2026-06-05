// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/modules/room/views/create_room_screen.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/create_room_controller.dart';

class CreateRoomScreen extends StatelessWidget {
  const CreateRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CreateRoomController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        title: const Text('Create Room',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF15141F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.white),
          onPressed: Get.back,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Banner Picker ─────────────────────────────────────────
                  _BannerPicker(ctrl: ctrl),
                  const SizedBox(height: 20),

                  // ── Room Name ─────────────────────────────────────────────
                  _SectionLabel('Room Name *'),
                  _RoomTextField(
                    hint: 'e.g. Arvind Party Lounge',
                    maxLength: 40,
                    onChanged: (v) => ctrl.roomName.value = v,
                  ),
                  const SizedBox(height: 16),

                  // ── Topic ─────────────────────────────────────────────────
                  _SectionLabel('Room Topic'),
                  _RoomTextField(
                    hint: 'e.g. Chill & Music Tonight 🎵',
                    maxLength: 60,
                    onChanged: (v) => ctrl.roomTopic.value = v,
                  ),
                  const SizedBox(height: 16),

                  // ── Welcome Message ───────────────────────────────────────
                  _SectionLabel('Welcome Message'),
                  _RoomTextField(
                    hint: 'Shown when users join...',
                    maxLength: 100,
                    maxLines: 2,
                    onChanged: (v) => ctrl.welcomeMessage.value = v,
                  ),
                  const SizedBox(height: 16),

                  // ── Announcement ──────────────────────────────────────────
                  _SectionLabel('Announcement (optional)'),
                  _RoomTextField(
                    hint: 'Pinned notice for all members...',
                    maxLength: 120,
                    onChanged: (v) => ctrl.announcement.value = v,
                  ),
                  const SizedBox(height: 24),

                  // ── Seat Count ────────────────────────────────────────────
                  _SectionLabel('Mic Seats'),
                  _SeatCountSelector(ctrl: ctrl),
                  const SizedBox(height: 24),

                  // ── Room Type ─────────────────────────────────────────────
                  _SectionLabel('Room Privacy'),
                  _RoomTypeSelector(ctrl: ctrl),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // ── Launch Button ─────────────────────────────────────────────────
          _LaunchButton(ctrl: ctrl),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BANNER PICKER
// ─────────────────────────────────────────────────────────────────────────────

class _BannerPicker extends StatelessWidget {
  final CreateRoomController ctrl;
  const _BannerPicker({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: image_picker integrate karo
        ctrl.bannerUrl.value =
            'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800&q=80';
      },
      child: Obx(() {
        final url = ctrl.bannerUrl.value;
        return Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF15141F),
            borderRadius: BorderRadius.circular(14),
            image: url.isNotEmpty
                ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
                : null,
            border: Border.all(
                color: const Color(0xFFFF8906).withOpacity(0.3), width: 1.5),
          ),
          child: url.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        color: Colors.white38, size: 36),
                    const SizedBox(height: 8),
                    const Text('Tap to add room banner',
                        style: TextStyle(color: Colors.white38, fontSize: 13)),
                  ],
                )
              : Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20)),
                    child: const Text('Change',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEAT COUNT SELECTOR
// ─────────────────────────────────────────────────────────────────────────────

class _SeatCountSelector extends StatelessWidget {
  final CreateRoomController ctrl;
  const _SeatCountSelector({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ctrl.seatOptions.map((count) {
            final selected = ctrl.seatCount.value == count;
            return GestureDetector(
              onTap: () => ctrl.seatCount.value = count,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFFF8906)
                      : const Color(0xFF15141F),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFFFF8906)
                        : Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  children: [
                    Text('$count',
                        style: TextStyle(
                          color: selected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                    const SizedBox(height: 2),
                    Text('Seats',
                        style: TextStyle(
                          color: selected ? Colors.black87 : Colors.white38,
                          fontSize: 11,
                        )),
                  ],
                ),
              ),
            );
          }).toList(),
        ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ROOM TYPE SELECTOR
// ─────────────────────────────────────────────────────────────────────────────

class _RoomTypeSelector extends StatelessWidget {
  final CreateRoomController ctrl;
  const _RoomTypeSelector({required this.ctrl});

  static const _types = [
    {
      'id': 'public',
      'label': 'Public',
      'icon': Icons.public,
      'desc': 'Anyone can join'
    },
    {
      'id': 'private',
      'label': 'Private',
      'icon': Icons.lock_outline,
      'desc': 'Invite only'
    },
    {
      'id': 'password',
      'label': 'Password',
      'icon': Icons.vpn_key,
      'desc': 'Requires a password'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          children: [
            Row(
              children: _types.map((t) {
                final selected = ctrl.roomType.value == t['id'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => ctrl.selectRoomType(t['id'] as String),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFFF8906).withOpacity(0.12)
                            : const Color(0xFF15141F),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFFFF8906)
                              : Colors.white.withOpacity(0.08),
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(t['icon'] as IconData,
                              color: selected
                                  ? const Color(0xFFFF8906)
                                  : Colors.white38,
                              size: 22),
                          const SizedBox(height: 6),
                          Text(t['label'] as String,
                              style: TextStyle(
                                color: selected
                                    ? const Color(0xFFFF8906)
                                    : Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              )),
                          const SizedBox(height: 2),
                          Text(t['desc'] as String,
                              style: const TextStyle(
                                  color: Colors.white30, fontSize: 10),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            // Password Field
            if (ctrl.roomType.value == 'password') ...[
              const SizedBox(height: 16),
              _PasswordField(ctrl: ctrl),
            ],
          ],
        ));
  }
}

class _PasswordField extends StatelessWidget {
  final CreateRoomController ctrl;
  const _PasswordField({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() => TextField(
          obscureText: !ctrl.isPasswordVisible.value,
          onChanged: (v) => ctrl.password.value = v,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter room password (min 4 chars)',
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFF15141F),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF8906)),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                ctrl.isPasswordVisible.value
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: Colors.white38,
                size: 20,
              ),
              onPressed: ctrl.togglePasswordVisibility,
            ),
            prefixIcon:
                const Icon(Icons.vpn_key, color: Color(0xFFFF8906), size: 18),
          ),
        ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3)),
      );
}

class _RoomTextField extends StatelessWidget {
  final String hint;
  final int maxLength;
  final int maxLines;
  final void Function(String) onChanged;

  const _RoomTextField({
    required this.hint,
    required this.maxLength,
    this.maxLines = 1,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLength: maxLength,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
        counterStyle: const TextStyle(color: Colors.white24, fontSize: 11),
        filled: true,
        fillColor: const Color(0xFF15141F),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF8906), width: 1.5),
        ),
      ),
    );
  }
}

class _LaunchButton extends StatelessWidget {
  final CreateRoomController ctrl;
  const _LaunchButton({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF15141F),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Obx(() => SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: ctrl.isLoading.value ? null : ctrl.launchRoom,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8906),
                disabledBackgroundColor:
                    const Color(0xFFFF8906).withOpacity(0.4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                elevation: 0,
              ),
              child: ctrl.isLoading.value
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mic, color: Colors.black, size: 20),
                        SizedBox(width: 8),
                        Text('Go Live Now 🎙️',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ],
                    ),
            ),
          )),
    );
  }
}
