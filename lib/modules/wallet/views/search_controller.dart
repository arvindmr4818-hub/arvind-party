// lib/modules/wallet/views/search_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/models/search_result_model.dart';

class GlobalSearchController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

  final query = ''.obs;
  final isLoading = false.obs;
  final results = <SearchResultModel>[].obs;
  final trending = <String>[].obs;
  final history = <String>[].obs;
  final selectedType = 'all'.obs;
  final followingUserIds = <String>{}.obs;
  final TextEditingController searchInput = TextEditingController();

  static const types = ['all', 'user', 'room', 'agency', 'family', 'gift'];

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();
    loadTrending();
  }

  @override
  void onClose() {
    searchInput.dispose();
    super.onClose();
  }

  void _loadFromCache() {
    final cached = _storage.read<List>('search_history') ?? [];
    history.assignAll(cached.map((e) => e.toString()));
    final followed = _storage.read<List>('following_user_ids') ?? [];
    followingUserIds.assignAll(followed.map((e) => e.toString()));
  }

  void onQueryChanged(String q) {
    query.value = q;
    if (q.trim().isNotEmpty) {
      search(q);
    } else {
      results.clear();
    }
  }

  void performSearch() {
    final q = searchInput.text.trim();
    if (q.isEmpty) return;
    query.value = q;
    search(q);
    saveToHistory(q);
  }

  void clearSearch() {
    query.value = '';
    searchInput.clear();
    results.clear();
  }

  void switchTab(String type) {
    selectedType.value = type;
  }

  List<SearchResultModel> get filteredResults {
    if (selectedType.value == 'all') return results.toList();
    return results.where((r) => r.type == selectedType.value).toList();
  }

  Future<void> search(String q) async {
    try {
      isLoading.value = true;
      final response = await _api.get('/search', query: {'q': q});
      if (response is Map && response['success'] == true) {
        final list = (response['data'] as List? ?? [])
            .map((e) => SearchResultModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        results.assignAll(list);
      } else {
        results.assignAll(_demoResults(q));
      }
    } catch (_) {
      results.assignAll(_demoResults(q));
    } finally {
      isLoading.value = false;
    }
  }

  List<SearchResultModel> _demoResults(String q) {
    return [
      SearchResultModel(id: 'u1', type: 'user', title: '$q Host', subtitle: 'Top host • 10K followers', imageUrl: '', extra: {'isFollowing': false}),
      SearchResultModel(id: 'r1', type: 'room', title: '$q Party Room', subtitle: 'Live now • Music', imageUrl: ''),
      SearchResultModel(id: 'a1', type: 'agency', title: '$q Agency', subtitle: 'Top agency • 500 members', imageUrl: ''),
      SearchResultModel(id: 'f1', type: 'family', title: '$q Family', subtitle: '100 members', imageUrl: ''),
    ];
  }

  Future<void> loadTrending() async {
    try {
      final response = await _api.get('/search/trending');
      if (response is Map && response['success'] == true) {
        trending.assignAll(List<String>.from(response['data'] as List? ?? []));
      } else {
        trending.assignAll(['Music Party', 'DJ Night', 'Standup Comedy', 'Talent Show', 'VIP Rooms']);
      }
    } catch (_) {
      trending.assignAll(['Music Party', 'DJ Night', 'Standup Comedy', 'Talent Show', 'VIP Rooms']);
    }
  }

  void saveToHistory(String q) {
    if (q.trim().isEmpty) return;
    history.remove(q);
    history.insert(0, q);
    if (history.length > 20) history.removeLast();
    _storage.write('search_history', history.toList());
  }

  void clearHistory() {
    history.clear();
    _storage.remove('search_history');
  }

  Future<void> toggleFollow(SearchResultModel result) async {
    final isFollowing = followingUserIds.contains(result.id);
    try {
      final response = await _api.post('/user/follow/${result.id}', body: {'action': isFollowing ? 'unfollow' : 'follow'});
      if (response is Map && response['success'] == true) {
        if (isFollowing) {
          followingUserIds.remove(result.id);
        } else {
          followingUserIds.add(result.id);
        }
        _storage.write('following_user_ids', followingUserIds.toList());
      }
    } catch (_) {
      if (isFollowing) {
        followingUserIds.remove(result.id);
      } else {
        followingUserIds.add(result.id);
      }
      _storage.write('following_user_ids', followingUserIds.toList());
    }
  }

  bool isFollowing(String userId) => followingUserIds.contains(userId);
}
