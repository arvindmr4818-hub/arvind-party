import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/network/admin_api.dart';

class DashboardController extends GetxController {
  final isLoading = true.obs;
  final totalUsers = 0.obs;
  final activeRooms = 0.obs;
  final totalRevenue = 0.0.obs;
  final totalCoinsGenerated = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  Future<void> loadStats() async {
    isLoading.value = true;
    try {
      final response = await AdminApi.to.getDashboardStats();
      final data = response['data'] as Map<String, dynamic>?;
      if (data != null) {
        totalUsers.value = (data['total_users'] ?? data['totalUsers'] ?? 0) as int;
        activeRooms.value = (data['active_rooms'] ?? data['activeRooms'] ?? 0) as int;
        totalRevenue.value = (data['total_revenue'] ?? data['totalRevenue'] ?? 0).toDouble();
        totalCoinsGenerated.value = (data['total_coins_generated'] ?? data['totalCoinsGenerated'] ?? 0) as int;
      }
    } catch (e) {
      debugPrint('[DashboardController] loadStats error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
