import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/models/search_result_model.dart';

class GlobalSearchController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

  // ── Reactive State Variables ───────────────────────────────────
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
    loadTrendingFromBackend(); // Real backend pull
  }

  @override
  void onClose() {
    searchInput.dispose();
    super.onClose();
  }

  // Local storage cache memory sync loops
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

  // 🌐 REAL TIME API: Query channels database indices via Node.js
  Future<void> search(String q) async {
    if (q.trim().isEmpty) return;
    try {
      isLoading.value = true;
      // Endpoint: /search?q=Arvind
      final response = await _api.get('/search', query: {'q': q});
      if (response is Map && response['success'] == true) {
        final List<dynamic> serverData = response['data'] ?? [];
        final list = serverData
            .map((e) => SearchResultModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        results.assignAll(list);
      } else {
        results.clear(); // Real empty state if response status fails
      }
    } catch (e) {
      debugPrint('Database query cluster search exception: $e');
      results.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // 🌐 REAL TIME API: Live trending aggregations from backend router
  Future<void> loadTrendingFromBackend() async {
    try {
      final response = await _api.get('/search/trending');
      if (response is Map && response['success'] == true) {
        final List<dynamic> trends = response['data'] ?? [];
        trending.assignAll(trends.map((e) => e.toString()).toList());
      }
    } catch (e) {
      debugPrint('Trending metric collection lookup failed: $e');
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

  // ⚔️ REAL TIME API: Follow/Unfollow database document streams updates
  Future<void> toggleFollow(SearchResultModel result) async {
    final isFollowingUser = followingUserIds.contains(result.id);
    try {
      // Optimistic UI updates
      if (isFollowingUser) {
        followingUserIds.remove(result.id);
      } else {
        followingUserIds.add(result.id);
      }
      _storage.write('following_user_ids', followingUserIds.toList());
      results.refresh(); // Triggers reactivity to update lists layout frames

      // Router Post request execution
      await _api.post('/user/follow/${result.id}', body: {
        'action': isFollowingUser ? 'unfollow' : 'follow'
      });
    } catch (e) {
      // Fallback rollback tracking if sync network handshake drops down
      debugPrint('Relationship stream handshake failure: $e');
      if (isFollowingUser) {
        followingUserIds.add(result.id);
      } else {
        followingUserIds.remove(result.id);
      }
      _storage.write('following_user_ids', followingUserIds.toList());
      results.refresh();
    }
  }

  bool isFollowing(String userId) => followingUserIds.contains(userId);
}