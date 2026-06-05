// users_binding.dart
import 'package:get/get.dart';
import '../controllers/users_controller.dart';
import '../../../core/services/admin_api_service.dart';

class UsersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminApiService>(() => AdminApiService());
    Get.lazyPut<UsersController>(() => UsersController());
  }
}
