import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../../core/services/admin_api_service.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminApiService>(() => AdminApiService());
    Get.lazyPut<DashboardController>(() => DashboardController());
  }
}
