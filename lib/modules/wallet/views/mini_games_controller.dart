// lib/modules/wallet/views/mini_games_controller.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/services/api_service.dart';

enum GameType { luckyWheel, scratchCard, diceRoll, cardFlip, slotSpin }

class GameResult {
  final bool isWin;
  final int rewardCoins;
  final String message;
  final DateTime playedAt;

  GameResult({
    required this.isWin,
    required this.rewardCoins,
    required this.message,
    required this.playedAt,
  });
}

class MiniGamesController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

  final isLoading = false.obs;
  final spinsLeftToday = 5.obs;
  final lastResult = Rxn<GameResult>();
  final history = <GameResult>[].obs;
  final coins = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();
  }

  void _loadFromCache() {
    final cachedSpins = _storage.read<int>('game_spins_left') ?? 5;
    spinsLeftToday.value = cachedSpins;
    final cachedCoins = _storage.read<int>('user_coins') ?? 0;
    coins.value = cachedCoins;
    final cachedHistory = _storage.read<List>('game_history') ?? [];
    history.assignAll(cachedHistory.map((e) {
      final m = Map<String, dynamic>.from(e);
      return GameResult(
        isWin: m['isWin'] == true,
        rewardCoins: (m['rewardCoins'] as num?)?.toInt() ?? 0,
        message: (m['message'] ?? '').toString(),
        playedAt: DateTime.tryParse((m['playedAt'] ?? '').toString()) ?? DateTime.now(),
      );
    }));
  }

  Future<bool> playGame(GameType type, {int bet = 0}) async {
    if (spinsLeftToday.value <= 0 && type == GameType.luckyWheel) {
      Get.snackbar('No Spins Left', 'Come back tomorrow!');
      return false;
    }
    try {
      isLoading.value = true;
      final response = await _api.post('/games/play', body: {
        'type': type.name,
        'bet': bet,
      });
      if (response is Map && response['success'] == true) {
        final data = response['data'] as Map? ?? {};
        final win = data['isWin'] == true;
        final reward = (data['rewardCoins'] as num?)?.toInt() ?? 0;
        final result = GameResult(
          isWin: win,
          rewardCoins: reward,
          message: (data['message'] ?? '').toString(),
          playedAt: DateTime.now(),
        );
        lastResult.value = result;
        history.insert(0, result);
        if (type == GameType.luckyWheel) {
          spinsLeftToday.value--;
          _storage.write('game_spins_left', spinsLeftToday.value);
        }
        coins.value += reward - bet;
        _storage.write('user_coins', coins.value);
        _persistHistory();
        return true;
      }
    } catch (_) {
      // local fallback - generate a result
      final isWin = DateTime.now().millisecondsSinceEpoch % 3 != 0;
      final reward = isWin ? (50 + DateTime.now().millisecondsSinceEpoch % 200).toInt() : 0;
      final result = GameResult(
        isWin: isWin,
        rewardCoins: reward,
        message: isWin ? 'You won $reward coins!' : 'Better luck next time!',
        playedAt: DateTime.now(),
      );
      lastResult.value = result;
      history.insert(0, result);
      coins.value += reward - bet;
      _storage.write('user_coins', coins.value);
      _persistHistory();
      return isWin;
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  void _persistHistory() {
    _storage.write('game_history', history.map((e) => {
          'isWin': e.isWin,
          'rewardCoins': e.rewardCoins,
          'message': e.message,
          'playedAt': e.playedAt.toIso8601String(),
        }).toList());
  }

  Future<void> loadGameState() async {
    try {
      final response = await _api.get('/games/state');
      if (response is Map && response['success'] == true) {
        final data = response['data'] as Map? ?? {};
        if (data['spinsLeft'] is int) spinsLeftToday.value = data['spinsLeft'] as int;
        if (data['coins'] is int) coins.value = data['coins'] as int;
      }
    } catch (_) {}
  }
}
