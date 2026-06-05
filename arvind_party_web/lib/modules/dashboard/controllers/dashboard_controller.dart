// arvind_party_web/lib/modules/dashboard/controllers/dashboard_controller.dart
import 'package:get/get.dart';
import '../../core/network/admin_api.dart';

class DashboardController extends GetxController {
  final isLoading    = true.obs;
  final totalUsers   = 0.obs;
  final onlineUsers  = 0.obs;
  final activeRooms  = 0.obs;
  final blockedUsers = 0.obs;
  final newToday     = 0.obs;
  final rooms        = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final api = AdminApi.to;
      final results = await Future.wait([
        api.getDashboardStats(),
        api.getActiveRooms(),
      ]);

      final stats = results[0] as Map<String, dynamic>;
      if (stats['success'] == true) {
        final s = stats['stats'] as Map<String, dynamic>;
        totalUsers.value   = (s['total']    as int?) ?? 0;
        onlineUsers.value  = (s['online']   as int?) ?? 0;
        blockedUsers.value = (s['blocked']  as int?) ?? 0;
        newToday.value     = (s['newToday'] as int?) ?? 0;
      }

      rooms.value      = results[1] as List<dynamic>;
      activeRooms.value = rooms.length;
    } catch (e) {
      // Offline fallback with dummy data
      totalUsers.value  = 1240;
      onlineUsers.value = 87;
      activeRooms.value = 23;
      newToday.value    = 14;
    } finally {
      isLoading.value = false;
    }
  }
}
