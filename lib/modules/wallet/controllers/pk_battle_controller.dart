import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/models/pk_battle_model.dart';

class PkBattleController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

  // ── Reactive State Variables ───────────────────────────────────
  final isLoading = false.obs;
  final currentBattle = Rxn<PkBattleModel>();
  final recentBattles = <PkBattleModel>[].obs;
  final globalLeaderboard = <Map<String, dynamic>>[].obs;
  final myStats = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCache();
    loadLiveBattleState(); // Live active room state check on init
  }

  void _loadCache() {
    final cached = _storage.read<Map>('my_pk_stats');
    if (cached != null) myStats.assignAll(Map<String, dynamic>.from(cached));
  }

  // 🌐 REAL TIME API: Check if current room has an ongoing active live battle
  Future<void> loadLiveBattleState() async {
    try {
      final response = await _api.get('/pk/current-active');
      if (response is Map && response['success'] == true && response['data'] != null) {
        currentBattle.value = PkBattleModel.fromJson(Map<String, dynamic>.from(response['data']));
      }
    } catch (e) {
      debugPrint('Error syncing live pk state metrics: $e');
    }
  }

  // ⚔️ REAL TIME API: Matchmaking start pipeline request execution
  Future<void> startBattle({
    required String opponentId, 
    required String opponentName, 
    required String opponentAvatar, 
    required String roomId
  }) async {
    try {
      isLoading.value = true;
      // Real Node.js Route: router.post('/pk/start', ...)
      final response = await _api.post('/pk/start', body: {
        'opponentId': opponentId,
        'roomId': roomId,
      });
      if (response is Map && response['success'] == true) {
        currentBattle.value = PkBattleModel.fromJson(Map<String, dynamic>.from(response['data']));
      }
    } catch (e) {
      debugPrint('PK Battle request trigger transaction failure: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 🎁 REAL TIME API: Send gift live calculations update to backend MongoDB logs
  Future<void> sendGiftDuringBattle(String giftId, int amountValue) async {
    if (currentBattle.value == null) return;
    try {
      // Endpoint: /pk/:battleId/gift
      final response = await _api.post('/pk/${currentBattle.value!.id}/gift', body: {
        'giftId': giftId,
        'amount': amountValue,
      });
      if (response is Map && response['success'] == true) {
        final data = response['data'] as Map? ?? {};
        currentBattle.value = PkBattleModel.fromJson(Map<String, dynamic>.from(data['battle'] ?? {}));
      }
    } catch (e) {
      debugPrint('Failed to stream gift calculations data to server: $e');
    }
  }

  // 🛑 REAL TIME API: Force end or automatic timeout synchronization logic
  Future<void> endBattle() async {
    if (currentBattle.value == null) return;
    final id = currentBattle.value!.id;
    try {
      final response = await _api.post('/pk/$id/end', body: {});
      if (response is Map && response['success'] == true) {
        final data = response['data'] as Map? ?? {};
        currentBattle.value = PkBattleModel.fromJson(Map<String, dynamic>.from(data));
        _updateStats();
      }
    } catch (_) {
      _updateStats();
    } finally {
      if (currentBattle.value != null) {
        recentBattles.insert(0, currentBattle.value!);
      }
    }
  }

  void _updateStats() {
    final b = currentBattle.value;
    if (b == null) return;
    final wins = (myStats['wins'] as int? ?? 0) + (b.winnerId == b.hostId ? 1 : 0);
    final losses = (myStats['losses'] as int? ?? 0) + (b.winnerId != null && b.winnerId != b.hostId ? 1 : 0);
    final draws = (myStats['draws'] as int? ?? 0) + (b.winnerId == null ? 1 : 0);
    
    myStats['wins'] = wins;
    myStats['losses'] = losses;
    myStats['draws'] = draws;
    myStats['totalBattles'] = wins + losses + draws;
    _storage.write('my_pk_stats', myStats.value);
  }

  // 🌐 REAL TIME API: Leaderboard standings aggregations
  Future<void> loadLeaderboard() async {
    try {
      final response = await _api.get('/pk/leaderboard');
      if (response is Map && response['success'] == true) {
        globalLeaderboard.assignAll(List<Map<String, dynamic>>.from(
          (response['data'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)),
        ));
      }
    } catch (_) {}
  }
}