import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
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
    try {
      isLoading.value = true;
      await Future.wait([loadLevel(), loadBadges(), loadFrames()]);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadLevel() async {
    try {
      final response = await _api.get('/user/level');
      if (response is Map && response['success'] == true) {
        final data = UserLevelInfo.fromJson(Map<String, dynamic>.from(response['data']));
        levelInfo.value = data;
        _storage.write('user_level', data.toJson());
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
        _storage.write('user_badges', list.map((e) => e.toJson()).toList());
      }
    } catch (_) {}
  }

  Future<void> loadFrames() async {
    try {
      final response = await _api.get('/user/frames');
      if (response is Map && response['success'] == true) {
        final list = (response['data'] as List? ?? [])
            .map((e) => AvatarFrame.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        frames.assignAll(list);
        _storage.write('user_frames', list.map((e) => e.toJson()).toList());
      }
    } catch (_) {}
  }

  Future<bool> equipFrame(String frameId) async {
    try {
      final list = frames.map((f) => f.copyWith(isEquipped: f.id == frameId)).toList();
      frames.assignAll(list);
      _storage.write('user_frames', list.map((e) => e.toJson()).toList());
      
      final response = await _api.post('/user/frames/$frameId/equip', body: {});
      return response is Map && response['success'] == true;
    } catch (_) {
      return true;
    }
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
    _storage.write('user_level', levelInfo.value!.toJson());
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