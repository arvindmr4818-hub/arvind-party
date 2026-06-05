// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/modules/auth/bindings/auth_binding.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../controllers/otp_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}

// OtpController ka alag binding — phone_auth_screen ke liye
class PhoneAuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpController>(() => OtpController());
  }
}
