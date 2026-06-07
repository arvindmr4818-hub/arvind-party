// lib/modules/wallet/views/user_center_controller.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/models/user_center_models.dart';

class UserCenterController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

  final isLoading = false.obs;
  final levelInfo = Rxn<UserLevelInfo>();
  final badges = <AppBadge>[].obs;
  final frames = <AvatarFrame>[].obs;
  final selectedFrame = Rxn<AvatarFrame>();

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();
    loadAll();
  }

  void _loadFromCache() {
    final cached = _storage.read<Map>('user_level');
    if (cached != null) {
      levelInfo.value = UserLevelInfo.fromJson(Map<String, dynamic>.from(cached));
    } else {
      levelInfo.value = UserLevelInfo(level: 1, title: 'Newbie', currentXp: 0, nextLevelXp: 100, totalXp: 0);
    }
    final cachedBadges = _storage.read<List>('user_badges') ?? [];
    badges.assignAll(cachedBadges.map((e) => AppBadge.fromJson(Map<String, dynamic>.from(e))));
    final cachedFrames = _storage.read<List>('user_frames') ?? [];
    frames.assignAll(cachedFrames.map((e) => AvatarFrame.fromJson(Map<String, dynamic>.from(e))));
  }

  Future<void> loadAll() async {
    await Future.wait([loadLevel(), loadBadges(), loadFrames()]);
  }

  Future<void> loadLevel() async {
    try {
      final response = await _api.get('/user/level');
      if (response is Map && response['success'] == true) {
        final data = UserLevelInfo.fromJson(Map<String, dynamic>.from(response['data']));
        levelInfo.value = data;
        _storage.write('user_level', {
          'level': data.level,
          'title': data.title,
          'currentXp': data.currentXp,
          'nextLevelXp': data.nextLevelXp,
          'totalXp': data.totalXp,
        });
      }
    } catch (_) {}
  }

  Future<void> loadBadges() async {
    try {
      final response = await _api.get('/user/badges');
      if (response is Map && response['success'] == true) {
        final list = (response['data'] as List? ?? [])
            .map((e) => AppBadge.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        badges.assignAll(list);
        _storage.write('user_badges', list.map((e) => {
              'id': e.id,
              'name': e.name,
              'description': e.description,
              'iconUrl': e.iconUrl,
              'rarity': e.rarity,
              'unlockedAt': e.unlockedAt?.toIso8601String(),
            }).toList());
      } else {
        badges.assignAll(_demoBadges());
      }
    } catch (_) {
      badges.assignAll(_demoBadges());
    }
  }

  List<AppBadge> _demoBadges() {
    return [
      AppBadge(id: 'b1', name: 'First Room', description: 'Created your first room', iconUrl: '', rarity: 'common', unlockedAt: DateTime.now().subtract(const Duration(days: 30))),
      AppBadge(id: 'b2', name: 'Top Host', description: 'Reached top 100 hosts', iconUrl: '', rarity: 'rare', unlockedAt: DateTime.now().subtract(const Duration(days: 5))),
      AppBadge(id: 'b3', name: 'Party Animal', description: 'Hosted 50+ parties', iconUrl: '', rarity: 'epic'),
      AppBadge(id: 'b4', name: 'Legend', description: 'Reach 1M coins earned', iconUrl: '', rarity: 'legendary'),
    ];
  }

  Future<void> loadFrames() async {
    try {
      final response = await _api.get('/user/frames');
      if (response is Map && response['success'] == true) {
        final list = (response['data'] as List? ?? [])
            .map((e) => AvatarFrame.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        frames.assignAll(list);
        _storage.write('user_frames', list.map((e) => {
              'id': e.id,
              'name': e.name,
              'imageUrl': e.imageUrl,
              'priceCoins': e.priceCoins,
              'isVipOnly': e.isVipOnly,
              'isOwned': e.isOwned,
              'isEquipped': e.isEquipped,
            }).toList());
      } else {
        frames.assignAll(_demoFrames());
      }
    } catch (_) {
      frames.assignAll(_demoFrames());
    }
  }

  List<AvatarFrame> _demoFrames() {
    return [
      AvatarFrame(id: 'f0', name: 'No Frame', imageUrl: '', priceCoins: 0, isVipOnly: false, isOwned: true, isEquipped: true),
      AvatarFrame(id: 'f1', name: 'Golden Frame', imageUrl: '', priceCoins: 5000, isVipOnly: false, isOwned: true, isEquipped: false),
      AvatarFrame(id: 'f2', name: 'Diamond Frame', imageUrl: '', priceCoins: 20000, isVipOnly: true, isOwned: false, isEquipped: false),
      AvatarFrame(id: 'f3', name: 'Fire Frame', imageUrl: '', priceCoins: 10000, isVipOnly: false, isOwned: false, isEquipped: false),
    ];
  }

  Future<bool> equipFrame(String frameId) async {
    try {
      final response = await _api.post('/user/frames/$frameId/equip');
      if (response is Map && response['success'] == true) {
        final list = frames.map((f) => f.copyWith(isEquipped: f.id == frameId)).toList();
        frames.assignAll(list);
        return true;
      }
    } catch (_) {
      final list = frames.map((f) => f.copyWith(isEquipped: f.id == frameId)).toList();
      frames.assignAll(list);
      return true;
    }
    return false;
  }

  void addXp(int amount) {
    final current = levelInfo.value;
    if (current == null) return;
    final newTotal = current.totalXp + amount;
    final newLevel = _calculateLevel(newTotal);
    levelInfo.value = current.copyWith(
      totalXp: newTotal,
      level: newLevel,
      currentXp: newTotal - _xpForLevel(newLevel),
      nextLevelXp: _xpForLevel(newLevel + 1) - _xpForLevel(newLevel),
    );
  }

  int _xpForLevel(int level) => level * level * 100;

  int _calculateLevel(int totalXp) {
    int level = 1;
    while (totalXp >= _xpForLevel(level + 1)) {
      level++;
    }
    return level;
  }
}
