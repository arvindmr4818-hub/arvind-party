// arvind_party_web/lib/modules/users/controllers/users_controller.dart
import 'package:get/get.dart';
import '../../../core/network/admin_api.dart';

class UsersController extends GetxController {
  final isLoading = true.obs;
  final users     = <dynamic>[].obs;
  final total     = 0.obs;
  final page      = 1.obs;
  final search    = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers() async {
    isLoading.value = true;
    try {
      final data = await AdminApi.to.getAllUsers(page: page.value);
      if (data['success'] == true) {
        users.value = data['users'] ?? [];
        total.value = (data['total'] as int?) ?? 0;
      }
    } catch (_) {
      users.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> blockUser(String id) async {
    final ok = await AdminApi.to.blockUser(id);
    if (ok) {
      Get.snackbar('✅ Blocked', 'User has been blocked',
          snackPosition: SnackPosition.BOTTOM);
      loadUsers();
    }
  }

  Future<void> unblockUser(String id) async {
    final ok = await AdminApi.to.unblockUser(id);
    if (ok) {
      Get.snackbar('✅ Unblocked', 'User has been unblocked',
          snackPosition: SnackPosition.BOTTOM);
      loadUsers();
    }
  }

  Future<void> adjustCoins(String id, int coins) async {
    final ok = await AdminApi.to.adjustCoins(id, coins, 'Admin adjustment');
    if (ok) {
      Get.snackbar('✅ Coins Updated', '$coins coins adjusted',
          snackPosition: SnackPosition.BOTTOM);
      loadUsers();
    }
  }
}
