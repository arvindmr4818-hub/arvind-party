import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../auth/views/api_service.dart';
import '../models/badge_model.dart';

class BadgeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();
  final AudioPlayer _audioPlayer = AudioPlayer();
  IO.Socket? _socket;
  
  var badges = <BadgeModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserBadges();
    _initSocketListener();
  }

  void _initSocketListener() {
    _socket = IO.io('http://YOUR_BACKEND_URL', IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build());
        
    _socket?.connect();
    
    _socket?.on('badge_unlocked', (data) {
      // Re-fetching the badges will automatically trigger the unlock animation 
      // if the backend response contains a new badge ID!
      fetchUserBadges();
    });
  }

  Future<void> fetchUserBadges() async {
    try {
      // 1. Load from cache first (Stale-while-revalidate pattern)
      final List<dynamic>? cachedData = _storage.read<List<dynamic>>('cached_badges');
      if (cachedData != null) {
        badges.value = cachedData.map((json) => BadgeModel.fromJson(json)).toList();
      } else {
        isLoading(true);
      }

      // 2. Fetch fresh data from network
      final response = await _apiService.get('users/badges');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['badges'] ?? [];
        final newBadges = data.map((json) => BadgeModel.fromJson(json)).toList();

        // 3. Compare to find newly unlocked badges & trigger animation
        if (cachedData != null) {
          final oldIds = badges.map((b) => b.id).toSet();
          for (var badge in newBadges) {
            if (!oldIds.contains(badge.id)) {
              _showBadgeUnlockAnimation(badge);
            }
          }
        }

        // 4. Update observable and cache
        badges.value = newBadges;
        _storage.write('cached_badges', newBadges.map((b) => b.toJson()).toList());
      }
    } catch (e) {
      // Only show error if we also have no cached data
      if (badges.isEmpty) {
        Get.snackbar('Error', 'Failed to load user badges');
      }
    } finally {
      isLoading(false);
    }
  }

  // Stunning animation dialog for new badge unlocks!
  void _showBadgeUnlockAnimation(BadgeModel badge) {
    // Play the unlock sound effect (ensure badge_unlock.mp3 is in assets/sounds/ and pubspec.yaml)
    _audioPlayer.play(AssetSource('sounds/badge_unlock.mp3'))
        .catchError((_) => null); // Fail silently if audio asset is missing

    Get.dialog(
      Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 900),
          curve: Curves.elasticOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: const Color(0xff15141F),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFFF8906), width: 2),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFFF8906).withOpacity(0.5), blurRadius: 30, spreadRadius: 5)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("🎉 New Badge Unlocked! 🎉", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  badge.iconUrl.isNotEmpty
                      ? Image.network(badge.iconUrl, width: 80, height: 80, errorBuilder: (_, __, ___) => const Icon(Icons.star, color: Colors.amber, size: 80))
                      : const Icon(Icons.star, color: Colors.amber, size: 80),
                  const SizedBox(height: 20),
                  Text(badge.name, style: const TextStyle(color: Color(0xFFFF8906), fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  Text(badge.description, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void onClose() {
    _socket?.disconnect();
    _socket?.dispose();
    _audioPlayer.dispose();
    super.onClose();
  }
}