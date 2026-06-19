import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/admin_api.dart';

class UsersController extends GetxController {
  final users = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final isSearching = false.obs;
  final searchQuery = ''.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalUsers = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers({int page = 1, String? search}) async {
    isLoading.value = true;
    currentPage.value = page;
    searchQuery.value = search ?? '';

    try {
      final response = await AdminApi.to.getUsers(
        page: page,
        limit: 20,
        search: search,
      );
      final data = response['data'];
      if (data != null) {
        users.value = (data['users'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>() ??
            [];
        totalPages.value = (data['total_pages'] ?? 1) as int;
        totalUsers.value = (data['total'] ?? 0) as int;
      }
    } catch (e) {
      debugPrint('[UsersController] loadUsers error: $e');
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> toggleBlockStatus(String userId, String currentStatus) async {
    try {
      if (currentStatus == 'active') {
        await AdminApi.to.blockUser(userId);
      } else {
        await AdminApi.to.unblockUser(userId);
      }
      // Refresh the list
      await loadUsers(page: currentPage.value, search: searchQuery.value);
    } catch (e) {
      _showError('Failed to update user status');
    }
  }

  void searchUsers(String query) {
    if (query.isEmpty) {
      loadUsers();
      return;
    }
    isSearching.value = true;
    loadUsers(search: query).then((_) => isSearching.value = false);
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFE53935),
      colorText: const Color(0xFFFFFFFF),
    );
  }
}