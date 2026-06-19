// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/home/presentation/controllers/home_controller.dart
// ARVIND PARTY - HOME CONTROLLER (Full: Banner + Categories + 6 Room Sections)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/services/api_service.dart';
import '../../models/home_model.dart';
import '../repositories/home_repository.dart';

class HomeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final HomeRepository _homeRepository = HomeRepository();

  // ==========================
  // ROOMS (Existing)
  // ==========================

  var liveRooms = <Map<String, dynamic>>[].obs;
  var discoverRooms = <Map<String, dynamic>>[].obs;

  var isLoading = false.obs;
  var isRoomsLoading = false.obs;

  // ==========================
  // USER (Existing)
  // ==========================

  var userName = 'Guest'.obs;
  var userCoins = 0.obs;

  // ==========================
  // SEARCH (Existing)
  // ==========================

  var isSearching = false.obs;

  final TextEditingController searchController =
      TextEditingController();

  final TextEditingController searchCtrl =
      TextEditingController();

  var searchQuery = ''.obs;

  // ==========================
  // CATEGORY (Existing)
  // ==========================

  var categories = <String>[
    'All',
    'Music',
    'Party',
    'Gaming',
    'Dating',
    'Chat',
  ].obs;

  var selectedCategory = 'All'.obs;

  // ==========================
  // FILTERS (Existing)
  // ==========================

  var roomFilters = <String>[
    'Popular',
    'Newest',
    'Nearby',
  ].obs;

  var selectedRoomFilter = 'Popular'.obs;

  // ==========================
  // HOME SECTION MODELS (New Blueprint)
  // ==========================

  final banners = <BannerModel>[].obs;
  final categoryModels = <CategoryModel>[].obs;
  final recommendedRooms = <HomeRoomItem>[].obs;
  final trendingRooms = <HomeRoomItem>[].obs;
  final newRooms = <HomeRoomItem>[].obs;
  final officialRooms = <HomeRoomItem>[].obs;
  final familyRooms = <HomeRoomItem>[].obs;
  final agencyRooms = <HomeRoomItem>[].obs;

  final isHomeLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    fetchLiveRooms();
    fetchDiscoverRooms();
    loadUserData();
    loadHomeSections();
  }

  // ==========================
  // HOME SECTIONS (New Blueprint)
  // ==========================

  Future<void> loadHomeSections() async {
    isHomeLoading.value = true;
    try {
      final results = await Future.wait([
        _homeRepository.getBanners(),
        _homeRepository.getCategories(),
        _homeRepository.getRoomsByType('recommended'),
        _homeRepository.getRoomsByType('trending'),
        _homeRepository.getRoomsByType('new'),
        _homeRepository.getRoomsByType('official'),
        _homeRepository.getRoomsByType('family'),
        _homeRepository.getRoomsByType('agency'),
      ]);

      banners.assignAll(results[0] as List<BannerModel>);
      categoryModels.assignAll(results[1] as List<CategoryModel>);
      recommendedRooms.assignAll(results[2] as List<HomeRoomItem>);
      trendingRooms.assignAll(results[3] as List<HomeRoomItem>);
      newRooms.assignAll(results[4] as List<HomeRoomItem>);
      officialRooms.assignAll(results[5] as List<HomeRoomItem>);
      familyRooms.assignAll(results[6] as List<HomeRoomItem>);
      agencyRooms.assignAll(results[7] as List<HomeRoomItem>);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load home sections');
    } finally {
      isHomeLoading.value = false;
    }
  }

  void navigateToRoom(String roomId) {
    Get.toNamed('/room-detail', arguments: {'id': roomId});
  }

  void navigateToCategory(String categoryId) {
    Get.toNamed('/rooms', arguments: {'categoryId': categoryId});
  }

  // ==========================
  // USER DATA (Existing)
  // ==========================

  Future<void> loadUserData() async {
    try {
      final response =
          await _apiService.get('user/profile');

      if (response != null &&
          response['success'] == true) {
        userName.value =
            response['data']['name'] ?? 'Guest';

        userCoins.value =
            response['data']['coins'] ?? 0;
      }
    } catch (_) {}
  }

  // ==========================
  // LIVE ROOMS (Existing)
  // ==========================

  Future<void> fetchLiveRooms() async {
    isLoading(true);

    try {
      final response =
          await _apiService.get('rooms/live');

      if (response != null &&
          response['success'] == true) {
        liveRooms.assignAll(
          List<Map<String, dynamic>>.from(
            response['data'],
          ),
        );
      } else if (response is List) {
        liveRooms.assignAll(
          List<Map<String, dynamic>>.from(
            response,
          ),
        );
      }

      filterRooms();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch rooms',
      );
    } finally {
      isLoading(false);
    }
  }

  // ==========================
  // DISCOVER (Existing)
  // ==========================

  Future<void> fetchDiscoverRooms() async {
    isRoomsLoading(true);

    try {
      final response =
          await _apiService.get(
        'rooms/discover',
      );

      if (response != null &&
          response['success'] == true) {
        discoverRooms.assignAll(
          List<Map<String, dynamic>>.from(
            response['data'],
          ),
        );
      }
    } catch (_) {} finally {
      isRoomsLoading(false);
    }
  }

  // ==========================
  // SEARCH (Existing)
  // ==========================

  Future<void> searchRooms(
    String query,
  ) async {
    if (query.trim().isEmpty) {
      fetchLiveRooms();
      return;
    }

    isLoading(true);

    try {
      final response =
          await _apiService.get(
        'rooms/search',
        query: {'q': query},
      );

      if (response != null &&
          response['success'] == true) {
        liveRooms.assignAll(
          List<Map<String, dynamic>>.from(
            response['data'],
          ),
        );
      }
    } catch (_) {
      Get.snackbar(
        'Search Error',
        'Failed to search rooms',
      );
    } finally {
      isLoading(false);
    }
  }

  void onSearchChanged(
    String value,
  ) {
    searchQuery.value = value;
    searchRooms(value);
  }

  void clearSearch() {
    searchCtrl.clear();
    searchController.clear();

    searchQuery.value = '';

    fetchLiveRooms();
  }

  void toggleSearch() {
    isSearching.value =
        !isSearching.value;

    if (!isSearching.value) {
      clearSearch();
    }
  }

  // ==========================
  // CATEGORY (Existing)
  // ==========================

  void selectCategory(
    String category,
  ) {
    selectedCategory.value =
        category;

    filterRooms();
  }

  // ==========================
  // FILTER (Existing)
  // ==========================

  void selectRoomFilter(
    String filter,
  ) {
    selectedRoomFilter.value =
        filter;

    filterRooms();
  }

  // ==========================
  // FILTER LOGIC (Existing)
  // ==========================

  void filterRooms() {
    if (selectedCategory.value ==
        'All') {
      discoverRooms.assignAll(
        liveRooms,
      );
      return;
    }

    discoverRooms.assignAll(
      liveRooms.where(
        (room) =>
            room['category'] ==
            selectedCategory.value,
      ),
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    searchCtrl.dispose();

    super.onClose();
  }
}