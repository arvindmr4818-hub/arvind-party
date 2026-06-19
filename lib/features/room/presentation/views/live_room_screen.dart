import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/live_room_controller.dart';

class LiveRoomScreen extends StatelessWidget {
  final Map<String, dynamic> room;
  late final LiveRoomController controller;
  final TextEditingController chatController = TextEditingController();

  LiveRoomScreen({super.key, required this.room}) {
    final String ownerId = room['ownerId'] != null && room['ownerId'] is Map
        ? (room['ownerId']['_id'] ?? room['ownerId']['userId'] ?? '')
        : (room['ownerId']?.toString() ?? '');

    controller = Get.put(LiveRoomController(
        roomId: room['_id'] ?? room['id'] ?? 'unknown',
        roomOwnerId: ownerId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Opacity(
                opacity: 0.3,
                child: CachedNetworkImage(
                  imageUrl:
                      room['coverImage'] ?? 'https://via.placeholder.com/400',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Column(
              children: [
                _buildRoomHeader(context),
                const SizedBox(height: 20),
                _buildMicSeats(),
                const Spacer(),
                _buildChatList(),
                _buildBottomControls(context),
              ],
            ),

            // Connection Status Overlay
            _buildConnectionOverlay(),

            // Gift Animation Overlay
            _buildGiftAnimationOverlay(),
          ],
        ),
      ),
    );
  }

  // Connection Overlay wrapped to avoid breaking build context
  Widget _buildConnectionOverlay() {
    return Obx(() => controller.isConnected.value
        ? const SizedBox.shrink()
        : const Center(
            child: CircularProgressIndicator(color: Colors.cyanAccent)));
  }

  // ══════════════════════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════════════════════
  Widget _buildRoomHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
                room['ownerId']?['avatar'] ??
                    'https://via.placeholder.com/150'),
            radius: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(room['name'] ?? 'Voice Room',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text('ID: ${room['roomId'] ?? '10000'}',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20)),
            child: const Row(
              children: [
                Icon(Icons.people, color: Colors.cyanAccent, size: 16),
                SizedBox(width: 4),
                Text('Live',
                    style:
                        TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              controller.fetchModerationList();
              _showRoomSettingsBottomSheet(context);
            },
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // MIC SEATS
  // ══════════════════════════════════════════════════════════════
  Widget _buildMicSeats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.8,
        ),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Obx(() {
            // Find seat if controller has seats list structure
            final seat = controller.seats.firstWhereOrNull((s) => s.index == index);

            return GestureDetector(
              onTap: () => _handleSeatTap(seat, index),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: seat != null ? Colors.cyanAccent : Colors.white24, width: 2),
                          color: Colors.black38,
                        ),
                        child: Center(
                          child: seat != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: CachedNetworkImage(
                                    imageUrl: seat.userAvatar ?? 'https://via.placeholder.com/150',
                                    placeholder: (context, url) => const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => const Icon(Icons.person, color: Colors.white),
                                  ),
                                )
                              : const Icon(Icons.mic_none, color: Colors.white38),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    seat != null ? (seat.userName ?? 'User') : 'Empty',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: seat != null ? Colors.white : Colors.white38, fontSize: 11),
                  )
                ],
              ),
            );
          });
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // LIVE CHAT STREAM LIST
  // ══════════════════════════════════════════════════════════════
  Widget _buildChatList() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Obx(() {
          return ListView.builder(
            reverse: true,
            itemCount: controller.chatMessages.length,
            itemBuilder: (context, index) {
              final msg = controller.chatMessages[controller.chatMessages.length - 1 - index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${msg.senderName}: ',
                        style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      TextSpan(
                        text: msg.message,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // BOTTOM ACTION CONTROLS
  // ══════════════════════════════════════════════════════════════
  Widget _buildBottomControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Colors.black26,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: chatController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Say something beautiful...',
                  hintStyle: TextStyle(color: Colors.white38),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: InputBorder.none,
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    controller.sendChatMessage(value.trim());
                    chatController.clear();
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          Obx(() => IconButton(
                icon: Icon(
                  controller.isMuted.value ? Icons.mic_off : Icons.mic,
                  color: controller.isMuted.value ? Colors.redAccent : Colors.white,
                ),
                onPressed: () => controller.toggleMute(),
              )),
          IconButton(
            icon: const Icon(Icons.card_giftcard, color: Colors.orangeAccent, size: 28),
            onPressed: () => _showGiftSheet(context),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // SEAT TAP ACTION HANDLING
  // ══════════════════════════════════════════════════════════════
  void _handleSeatTap(dynamic seat, int index) {
    if (seat == null) {
      // Seat khali hai, toh join karne ka procedure call hoga
      controller.joinSeat(index);
    } else {
      // Seat par koi baitha hai, uski user profile ya details bottom sheet dikhayenge
      Get.bottomSheet(
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 35, backgroundImage: CachedNetworkImageProvider(seat.userAvatar ?? '')),
              const SizedBox(height: 10),
              Text(seat.userName ?? 'User Name', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              if (controller.currentUserId == controller.roomOwnerId && seat.userId != controller.currentUserId)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: () {
                    controller.kickFromSeat(index);
                    Get.back();
                  },
                  child: const Text('Kick From Seat'),
                ),
            ],
          ),
        ),
      );
    }
  }

  // ══════════════════════════════════════════════════════════════
  // GIFT ANIMATION OVERLAY
  // ══════════════════════════════════════════════════════════════
  Widget _buildGiftAnimationOverlay() {
    return Obx(() {
      if (controller.activeGiftAnimation.value == null) return const SizedBox.shrink();
      return Positioned.fill(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 80), // Dynamic frame support can add custom lottie too
              const SizedBox(height: 10),
              Text(
                '${controller.activeGiftAnimation.value!.senderName} sent a Gift!',
                style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ══════════════════════════════════════════════════════════════
  // BOTTOM SHEETS
  // ══════════════════════════════════════════════════════════════
  void _showRoomSettingsBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Room Settings Control', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.redAccent),
              title: const Text('Banned Users List', style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                // Navigate to standard blocking list route
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.orangeAccent),
              title: const Text('Close Room Environment', style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                controller.closeRoom();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showGiftSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: 250,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Send Elegant Gifts', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _giftItem('Rose', Icons.favorite, 10),
                  _giftItem('Crown', Icons.workspace_premium, 100),
                  _giftItem('Super Car', Icons.directions_car, 500),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _giftItem(String name, IconData icon, int price) {
    return GestureDetector(
      onTap: () {
        controller.sendGiftToRoom({'name': name, 'cost': price, 'quantity': 1});
        Get.back();
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.pinkAccent, size: 36),
            const SizedBox(height: 4),
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 12)),
            Text('$price Coins', style: const TextStyle(color: Colors.amber, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}