// lib/modules/wallet/views/pk_battle_controller.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/models/pk_battle_model.dart';

class PkBattleController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

  final isLoading = false.obs;
  final currentBattle = Rxn<PkBattleModel>();
  final recentBattles = <PkBattleModel>[].obs;
  final globalLeaderboard = <Map<String, dynamic>>[].obs;
  final myStats = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCache();
  }

  void _loadCache() {
    final cached = _storage.read<Map>('my_pk_stats');
    if (cached != null) myStats.assignAll(Map<String, dynamic>.from(cached));
  }

  Future<void> startBattle({required String opponentId, required String opponentName, required String opponentAvatar, required String roomId}) async {
    try {
      isLoading.value = true;
      final response = await _api.post('/pk/start', body: {
        'opponentId': opponentId,
        'roomId': roomId,
      });
      if (response is Map && response['success'] == true) {
        currentBattle.value = PkBattleModel.fromJson(Map<String, dynamic>.from(response['data']));
      } else {
        currentBattle.value = PkBattleModel(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}',
          roomId: roomId,
          hostId: _storage.read('user_id')?.toString() ?? '',
          hostName: _storage.read('user_name')?.toString() ?? 'You',
          hostAvatar: _storage.read('user_avatar')?.toString() ?? '',
          opponentId: opponentId,
          opponentName: opponentName,
          opponentAvatar: opponentAvatar,
          hostScore: 0,
          opponentScore: 0,
          duration: 180,
          status: 'live',
          startedAt: DateTime.now(),
        );
      }
    } catch (_) {
      currentBattle.value = PkBattleModel(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        roomId: roomId,
        hostId: _storage.read('user_id')?.toString() ?? '',
        hostName: _storage.read('user_name')?.toString() ?? 'You',
        hostAvatar: _storage.read('user_avatar')?.toString() ?? '',
        opponentId: opponentId,
        opponentName: opponentName,
        opponentAvatar: opponentAvatar,
        hostScore: 0,
        opponentScore: 0,
        duration: 180,
        status: 'live',
        startedAt: DateTime.now(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendGiftDuringBattle(String giftId, int amount) async {
    if (currentBattle.value == null) return;
    try {
      final response = await _api.post('/pk/${currentBattle.value!.id}/gift', body: {
        'giftId': giftId,
        'amount': amount,
      });
      if (response is Map && response['success'] == true) {
        final data = response['data'] as Map? ?? {};
        final updated = PkBattleModel.fromJson(Map<String, dynamic>.from(data['battle'] ?? {}));
        currentBattle.value = updated;
      }
    } catch (_) {
      // local optimistic
      final b = currentBattle.value!;
      currentBattle.value = PkBattleModel(
        id: b.id,
        roomId: b.roomId,
        hostId: b.hostId,
        hostName: b.hostName,
        hostAvatar: b.hostAvatar,
        opponentId: b.opponentId,
        opponentName: b.opponentName,
        opponentAvatar: b.opponentAvatar,
        hostScore: b.hostScore + amount,
        opponentScore: b.opponentScore,
        duration: b.duration,
        status: b.status,
        winnerId: b.winnerId,
        startedAt: b.startedAt,
        endedAt: b.endedAt,
      );
    }
  }

  Future<void> endBattle() async {
    if (currentBattle.value == null) return;
    final id = currentBattle.value!.id;
    try {
      final response = await _api.post('/pk/$id/end');
      if (response is Map && response['success'] == true) {
        final data = response['data'] as Map? ?? {};
        currentBattle.value = PkBattleModel.fromJson(Map<String, dynamic>.from(data));
        _updateStats();
      }
    } catch (_) {
      _updateStats();
    } finally {
      recentBattles.insert(0, currentBattle.value!);
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
    _storage.write('my_pk_stats', myStats.toJson());
  }

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
