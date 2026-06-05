// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/modules/auth/controllers/login_controller.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_routes.dart';

class LoginController extends GetxController {
  final isLoading = false.obs;
  final loadingMessage = 'Signing in...'.obs;
  final isTermsAccepted = false.obs;

  final _storage = GetStorage();

  // ─── TERMS ────────────────────────────────────────────────────────────────
  void toggleTerms() => isTermsAccepted.toggle();

  bool _checkTerms() {
    if (!isTermsAccepted.value) {
      Get.snackbar(
        'Terms Required',
        'Please accept Terms of Use and Privacy Policy to continue.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1A1A2E),
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.amber),
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    return true;
  }

  // ─── PHONE AUTH — navigates to PhoneAuthScreen ────────────────────────────
  void goToPhoneAuth() {
    if (!_checkTerms()) return;
    Get.toNamed(AppRoutes.phoneAuth); // ✅ Fixed — PhoneAuthScreen pe jaata hai
  }

  // ─── SOCIAL LOGINS ────────────────────────────────────────────────────────
  Future<void> loginWithFacebook() async {
    if (!_checkTerms()) return;
    await _startLogin('Connecting with Facebook...');
    try {
      // REAL IMPLEMENTATION STRUCTURE (Waiting for backend)
      // final result = await FacebookAuth.instance.login();
      // final userData = await FacebookAuth.instance.getUserData();
      // final token = result.accessToken!.tokenString;

      // TODO: Call your real backend API here -> apiService.login('facebook', token);
      throw Exception("Backend API not connected for Facebook Sign In yet.");
    } catch (e) {
      _handleError(e.toString());
    }
  }

  Future<void> loginWithGoogle() async {
    if (!_checkTerms()) return;
    await _startLogin('Connecting with Google...');
    try {
      // REAL IMPLEMENTATION STRUCTURE
      throw Exception("Backend API not connected for Google Sign In yet.");
    } catch (e) {
      _handleError(e.toString());
    }
  }

  Future<void> loginWithWhatsApp() async {
    if (!_checkTerms()) return;
    // WhatsApp login = phone auth ke through — same as phone button
    goToPhoneAuth();
  }

  Future<void> loginWithApple() async {
    if (!_checkTerms()) return;
    await _startLogin('Connecting with Apple...');
    try {
      // REAL IMPLEMENTATION STRUCTURE
      throw Exception("Backend API not connected for Apple Sign In yet.");
    } catch (e) {
      _handleError(e.toString());
    }
  }

  Future<void> loginWithTwitter() async {
    if (!_checkTerms()) return;
    await _startLogin('Connecting with Twitter...');
    try {
      // REAL IMPLEMENTATION STRUCTURE
      throw Exception("Backend API not connected for Twitter Sign In yet.");
    } catch (e) {
      _handleError(e.toString());
    }
  }

  Future<void> loginWithSnapchat() async {
    if (!_checkTerms()) return;
    await _startLogin('Connecting with Snapchat...');
    try {
      // REAL IMPLEMENTATION STRUCTURE
      throw Exception("Backend API not connected for Snapchat Sign In yet.");
    } catch (e) {
      _handleError(e.toString());
    }
  }

  // ─── DEMO MODE ────────────────────────────────────────────────────────────
  // ⚠️ TESTING ONLY — Production se remove karna!
  Future<void> loginAsDemo() async {
    await _startLogin('Entering Demo Mode...');
    await Future.delayed(const Duration(milliseconds: 800));
    _storage.write('user_id', 'demo_user_001');
    _storage.write('user_name', 'Demo User');
    _storage.write('is_logged_in', true);
    isLoading.value = false;
    Get.offAllNamed(AppRoutes.home);
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────
  Future<void> _startLogin(String message) async {
    loadingMessage.value = message;
    isLoading.value = true;
  }

  void _handleError(String error) {
    isLoading.value = false;
    Get.snackbar('Login Failed', error,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16));
  }

  @override
  void onClose() {
    isLoading.value = false;
    super.onClose();
  }
}
