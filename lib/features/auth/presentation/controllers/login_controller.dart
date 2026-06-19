// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/auth/presentation/controllers/login_controller.dart
// ARVIND PARTY - LOGIN CONTROLLER (Delegates to AuthController)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;
  var loadingMessage = ''.obs;
  var isTermsAccepted = false.obs;

  void toggleTerms() {
    isTermsAccepted.value = !isTermsAccepted.value;
  }

  bool _checkTerms() {
    if (!isTermsAccepted.value) {
      Get.snackbar(
        'Terms & Conditions',
        'Please accept the Terms of Use and Privacy Policy first.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    return true;
  }

  void goToSignup() {
    Get.toNamed('/signup');
  }

  void goToPhoneAuth() {
    Get.toNamed('/phone-auth');
  }

  Future<void> loginWithGoogle() async {
    if (!_checkTerms()) return;
    Get.snackbar('Info', 'Google login coming soon');
  }
}