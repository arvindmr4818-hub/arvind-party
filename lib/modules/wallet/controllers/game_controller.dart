import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

class GameController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  // ── LEADERBOARD REACTIVE STATES ───────────────────────────────
  final isLoadingLeaderboard = false.obs;
  final leaderboard = <Map<String, dynamic>>[].obs;

  // ── SCRATCH CARD REACTIVE STATES ──────────────────────────────
  final coins = 0.obs;
  final hasBoughtCard = false.obs;
  final isBuyingCard = false.obs;
  
  // Real database dynamic mapping dictionary for rewards
  final currentScratchReward = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeaderboard();
    fetchUserCoinsBalance(); // Sync coins initially
  }

  // 💰 REAL TIME API: Wallet balance fetch karna from Database
  Future<void> fetchUserCoinsBalance() async {
    try {
      final response = await _api.get('/wallet/balance');
      if (response != null && response['success'] == true) {
        coins.value = (response['coins'] as num?)?.toInt() ?? 0;
      }
    } catch (e) {
      debugPrint('Error fetching wallet context balance stream: $e');
    }
  }

  // 🌐 REAL TIME API: Fetch Weekly Winners Leaderboard
  Future<void> fetchLeaderboard() async {
    try {
      isLoadingLeaderboard.value = true;
      final response = await _api.get('/games/leaderboard');

      if (response != null && response['success'] == true) {
        final List<dynamic> serverData = response['data'] ?? [];
        leaderboard.assignAll(
          serverData.map((player) => Map<String, dynamic>.from(player)).toList()
        );
      }
    } catch (e) {
      debugPrint('Error hitting leaderboard channel database: $e');
    } finally {
      isLoadingLeaderboard.value = false;
    }
  }

  // 🎟️ REAL TIME API: Deduct 20 coins and buy a card securely from server
  Future<void> buyScratchCard() async {
    if (coins.value < 20) {
      Get.snackbar('Insufficient Balance', 'You need at least 20 coins to buy a scratch card.',
          backgroundColor: Colors.orangeAccent, colorText: Colors.black);
      return;
    }

    try {
      isBuyingCard.value = true;

      // Real Node.js Route: router.post('/games/scratch/buy', ...)
      final response = await _api.post('/games/scratch/buy', );

      if (response != null && response['success'] == true) {
        final rewardData = response['reward'] ?? {};
        
        // Setting up real rewards fetched directly from server mapping
        currentScratchReward.assignAll(Map<String, dynamic>.from(rewardData));
        
        // Update user metrics state locally
        coins.value = (response['updatedCoins'] as num?)?.toInt() ?? (coins.value - 20);
        hasBoughtCard.value = true;
      } else {
        _showErrorSnackbar('Transaction Failed', 'Server denied purchase framework logic.');
      }
    } catch (e) {
      debugPrint('Scratch card system exception handling: $e');
      _showErrorSnackbar('Server Error', 'Failed to securely buy card from network layer.');
    } finally {
      isBuyingCard.value = false;
    }
  }

  // 🔄 Local state reset logic for playing fresh loop cycles
  void resetScratchCard() {
    hasBoughtCard.value = false;
    isBuyingCard.value = false;
    currentScratchReward.clear();
    fetchUserCoinsBalance(); // Re-sync balance seamlessly
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title, message,
      backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
    );
  }
}