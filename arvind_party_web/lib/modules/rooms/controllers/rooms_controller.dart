import 'package:get/get.dart';
import '../../../core/services/admin_api_service.dart';

class RoomsController extends GetxController {
  final _api = Get.find<AdminApiService>();
  final isLoading = true.obs;
  final rooms = [].obs;
  final total = 0.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final statusFilter = Rx<String?>('active');

  @override
  void onInit() {
    super.onInit();
    loadRooms();
  }

  Future<void> loadRooms({int page = 1}) async {
    isLoading.value = true;
    try {
      final data = await _api.getRooms(page: page, status: statusFilter.value);
      if (data['success'] == true) {
        rooms.value = data['rooms'] ?? [];
        total.value = data['total'] ?? 0;
        currentPage.value = page;
        totalPages.value = data['pages'] ?? 1;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load rooms');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> banRoom(String id) async {
    await _api.banRoom(id);
    loadRooms(page: currentPage.value);
    Get.snackbar('Done', 'Room banned');
  }

  Future<void> closeRoom(String id) async {
    await _api.closeRoom(id);
    loadRooms(page: currentPage.value);
    Get.snackbar('Done', 'Room closed');
  }
}
