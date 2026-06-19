// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/home/presentation/bindings/home_binding.dart
// ARVIND PARTY - HOME BINDING
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}