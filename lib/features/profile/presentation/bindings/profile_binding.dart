// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/profile/presentation/bindings/profile_binding.dart
// ARVIND PARTY - PROFILE BINDING
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}