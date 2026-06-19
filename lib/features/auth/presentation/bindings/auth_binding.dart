import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/login_controller.dart';
import '../repositories/auth_repository.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthRepository>(AuthRepository());
    Get.put<AuthController>(AuthController());
    Get.put<LoginController>(LoginController());
  }
}