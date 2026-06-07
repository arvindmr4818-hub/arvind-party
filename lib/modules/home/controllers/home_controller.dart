// lib/modules/home/controllers/home_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/services/api_service.dart';

class HomeController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

  final isLoading = false.obs;
  final isRoomsLoading = false.obs;
  final isSearching = false.obs;
  final searchQuery = ''.obs;
  final liveRooms = <Map<String, dynamic>>[].obs;
  final discoverRooms = <Map<String, dynamic>>[].obs;
  final categories = <String>['All', 'Music', 'Party', 'Comedy', 'Chat', 'Gaming', 'VIP'].obs;
  final selectedCategory = 'All'.obs;
  final roomFilters = <String>['All', 'Live', 'Voice', 'Video', 'PK'].obs;
  final selectedRoomFilter = 'All'.obs;

  // Getters
  String get userName => (_storage.read('user_name') ?? 'Guest').toString();
  int get userCoins => (_storage.read('user_coins') as int?) ?? 0;
  TextEditingController get searchController => searchCtrl;

  final TextEditingController searchCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchLiveRooms();
    fetchDiscoverRooms();
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    fetchDiscoverRooms();
  }

  void selectRoomFilter(String filter) {
    selectedRoomFilter.value = filter;
    fetchLiveRooms();
  }

  void onSearchChanged(String q) {
    searchQuery.value = q;
  }

  void clearSearch() {
    searchQuery.value = '';
    searchCtrl.clear();
    isSearching.value = false;
    fetchLiveRooms();
  }

  Future<void> fetchLiveRooms() async {
    try {
      isRoomsLoading.value = true;
      final response = await _api.get('/rooms/live', query: {'filter': selectedRoomFilter.value});
      if (response is Map && response['rooms'] != null) {
        liveRooms.assignAll(List<Map<String, dynamic>>.from(response['rooms']));
      } else if (response is Map && response['data'] is List) {
        liveRooms.assignAll(List<Map<String, dynamic>>.from(response['data']));
      } else if (response is List) {
        liveRooms.assignAll(List<Map<String, dynamic>>.from(response));
      } else {
        liveRooms.assignAll(_demoRooms());
      }
    } catch (_) {
      liveRooms.assignAll(_demoRooms());
    } finally {
      isRoomsLoading.value = false;
    }
  }

  Future<void> fetchDiscoverRooms() async {
    try {
      isLoading.value = true;
      final response = await _api.get('/rooms/discover', query: {'category': selectedCategory.value});
      if (response is Map && response['data'] is List) {
        discoverRooms.assignAll(List<Map<String, dynamic>>.from(response['data']));
      } else if (response is List) {
        discoverRooms.assignAll(List<Map<String, dynamic>>.from(response));
      } else {
        discoverRooms.assignAll(_demoRooms());
      }
    } catch (_) {
      discoverRooms.assignAll(_demoRooms());
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> _demoRooms() {
    return [
      {
        'id': 'r1',
        'title': 'Live DJ Party',
        'host': 'DJ Arvind',
        'hostAvatar': '',
        'coverImage': 'https://picsum.photos/seed/r1/400/600',
        'viewers': 1250,
        'category': 'Music',
        'isLive': true,
        'isVip': false,
        'tags': ['music', 'live', 'party'],
      },
      {
        'id': 'r2',
        'title': 'Standup Comedy Night',
        'host': 'Funny Guy',
        'hostAvatar': '',
        'coverImage': 'https://picsum.photos/seed/r2/400/600',
        'viewers': 850,
        'category': 'Comedy',
        'isLive': true,
        'isVip': false,
        'tags': ['comedy', 'standup'],
      },
      {
        'id': 'r3',
        'title': 'VIP Private Room',
        'host': 'VIP Host',
        'hostAvatar': '',
        'coverImage': 'https://picsum.photos/seed/r3/400/600',
        'viewers': 200,
        'category': 'VIP',
        'isLive': true,
        'isVip': true,
        'tags': ['vip', 'private'],
      },
    ];
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      clearSearch();
    }
  }

  Future<void> searchRooms(String query) async {
    if (query.trim().isEmpty) {
      fetchLiveRooms();
      return;
    }
    try {
      isLoading.value = true;
      final response = await _api.get('/rooms/search', query: {'q': query});
      if (response is List) {
        liveRooms.assignAll(List<Map<String, dynamic>>.from(response));
      } else if (response is Map && response['data'] is List) {
        liveRooms.assignAll(List<Map<String, dynamic>>.from(response['data']));
      }
    } catch (_) {
      Get.snackbar('Search Error', 'Failed to find rooms.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> joinRoom(String roomId) async {
    try {
      await _api.post('/rooms/$roomId/join');
    } catch (_) {}
  }
}
