// rooms_binding.dart
import 'package:get/get.dart';
import '../controllers/rooms_controller.dart';
import '../../../core/services/admin_api_service.dart';

class RoomsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminApiService>(() => AdminApiService());
    Get.lazyPut<RoomsController>(() => RoomsController());
  }
}
