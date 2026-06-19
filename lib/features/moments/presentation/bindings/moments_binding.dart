// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/moments/presentation/bindings/moments_binding.dart
// ARVIND PARTY - MOMENTS BINDING
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/moments_controller.dart';

class MomentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MomentsController>(() => MomentsController());
  }
}