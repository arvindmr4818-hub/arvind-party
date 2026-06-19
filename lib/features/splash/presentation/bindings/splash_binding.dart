// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/splash/presentation/bindings/splash_binding.dart
// ARVIND PARTY - SPLASH BINDING
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}