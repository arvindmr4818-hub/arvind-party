import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../routes/app_routes.dart';
import '../../../home/services/user_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    final box = GetStorage();
    final token = box.read('auth_token');
    if (token != null && token.toString().isNotEmpty) {
      // Try to refresh profile
      try {
        final userService = Get.find<UserService>();
        await userService.fetchProfile();
        Get.offAllNamed(AppRoutes.home);
      } catch (_) {
        Get.offAllNamed(AppRoutes.login);
      }
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
