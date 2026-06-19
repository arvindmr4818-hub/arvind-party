// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/family/presentation/bindings/family_binding.dart
// ARVIND PARTY - FAMILY BINDING
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/family_controller.dart';

class FamilyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FamilyController>(() => FamilyController());
  }
}