// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/vip_system/bindings/vip_binding.dart
// ARVIND PARTY - VIP BINDING
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/vip_controller.dart';

class VIPBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VIPController>(
      () => VIPController(),
      fenix: true,
    );
  }
}