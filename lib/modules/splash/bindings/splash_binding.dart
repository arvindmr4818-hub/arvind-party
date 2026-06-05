import 'package:get/get.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {}
}

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 3), () {
      Get.offNamed('/home');
    });
  }
}
