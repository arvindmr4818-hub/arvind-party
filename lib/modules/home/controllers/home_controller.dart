import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';

class HomeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // ==========================
  // ROOMS
  // ==========================

  var liveRooms = <Map<String, dynamic>>[].obs;
  var discoverRooms = <Map<String, dynamic>>[].obs;

  var isLoading = false.obs;
  var isRoomsLoading = false.obs;

  // ==========================
  // USER
  // ==========================

  var userName = 'Guest'.obs;
  var userCoins = 0.obs;

  // ==========================
  // SEARCH
  // ==========================

  var isSearching = false.obs;

  final TextEditingController searchController =
      TextEditingController();

  final TextEditingController searchCtrl =
      TextEditingController();

  var searchQuery = ''.obs;

  // ==========================
  // CATEGORY
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
  // FILTERS
  // ==========================

  var roomFilters = <String>[
    'Popular',
    'Newest',
    'Nearby',
  ].obs;

  var selectedRoomFilter = 'Popular'.obs;

  @override
  void onInit() {
    super.onInit();

    fetchLiveRooms();
    fetchDiscoverRooms();
    loadUserData();
  }

  // ==========================
  // USER DATA
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
  // LIVE ROOMS
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
  // DISCOVER
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
  // SEARCH
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
  // CATEGORY
  // ==========================

  void selectCategory(
    String category,
  ) {
    selectedCategory.value =
        category;

    filterRooms();
  }

  // ==========================
  // FILTER
  // ==========================

  void selectRoomFilter(
    String filter,
  ) {
    selectedRoomFilter.value =
        filter;

    filterRooms();
  }

  // ==========================
  // FILTER LOGIC
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