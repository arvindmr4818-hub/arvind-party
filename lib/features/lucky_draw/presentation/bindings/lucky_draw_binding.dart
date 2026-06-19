// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/lucky_draw/presentation/bindings/lucky_draw_binding.dart
// ARVIND PARTY - LUCKY DRAW BINDING
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/lucky_draw_controller.dart';

class LuckyDrawBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LuckyDrawController>(() => LuckyDrawController());
  }
}