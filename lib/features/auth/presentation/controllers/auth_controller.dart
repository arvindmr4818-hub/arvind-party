// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/auth/presentation/controllers/auth_controller.dart
// ARVIND PARTY - AUTH CONTROLLER (Phone OTP Auth with Node.js Backend)
// Flow: Phone → sendOtp → Backend SMS → OTP → verifyOtp → JWT → Home
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../models/auth_model.dart';
import '../repositories/auth_repository.dart';

class AuthController extends GetxController {
  final authRepository = AuthRepository();
  final storage = GetStorage();

  var isLoggedIn = false.obs;
  var currentUser = Rxn<User>();
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var token = ''.obs;
  var phoneNumber = ''.obs;
  var otpSent = false.obs;
  var isNewUser = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    final savedToken = storage.read('token');
    if (savedToken != null && savedToken.isNotEmpty) {
      token.value = savedToken;
      isLoggedIn.value = true;
      await fetchCurrentUser();
    }
  }

  /// Step 1: Send OTP to phone number
  /// Sends phone to backend: POST /api/auth/send-otp { phone }
  Future<bool> sendOtp(String phone) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await authRepository.sendOtp(phone);
      if (response['success'] == true) {
        phoneNumber.value = phone;
        otpSent.value = true;
        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = response['message'] ?? 'Failed to send OTP';
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      return false;
    }
  }

  /// Step 2: Verify OTP - THE single entry point
  /// Phone + OTP → Backend auto-creates user if new, returns JWT
  Future<bool> verifyOtp(String phone, String otp) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await authRepository.verifyOtp(
        phone: phone,
        otp: otp,
      );

      if (response.success) {
        token.value = response.token;
        currentUser.value = response.user;
        isLoggedIn.value = true;
        isNewUser.value = response.isNewUser;

        // Save to local storage
        await storage.write('token', response.token);
        if (response.refreshToken != null) {
          await storage.write('refreshToken', response.refreshToken);
        }
        await storage.write('userId', response.user.id);
        await storage.write('phone', phone);
        await storage.write('isLoggedIn', true);

        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = response.message;
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      return false;
    }
  }

  /// Resend OTP
  Future<bool> resendOtp(String phone) async {
    isLoading.value = true;

    try {
      final response = await authRepository.resendOtp(phone);
      isLoading.value = false;
      return response['success'] == true;
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      return false;
    }
  }

  /// Register / Complete profile after OTP
  Future<bool> register({
    required String phone,
    required String name,
    String? gender,
    DateTime? dob,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await authRepository.register(
        phone: phone,
        name: name,
        gender: gender,
        dob: dob,
      );

      if (response.success) {
        token.value = response.token;
        currentUser.value = response.user;
        isLoggedIn.value = true;

        await storage.write('token', response.token);
        await storage.write('userId', response.user.id);

        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = response.message;
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      return false;
    }
  }

  /// Traditional email/password login (for web admin)
  Future<bool> emailLogin({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // For mobile: Delegate to web admin, redirect to phone login
      Get.snackbar('Info', 'Please use phone login for mobile app');
      isLoading.value = false;
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      return false;
    }
  }

  void logout() async {
    isLoading.value = true;

    try {
      await authRepository.logout();
    } catch (e) {
      // Continue with local logout even if API fails
    }

    // Clear all local data
    isLoggedIn.value = false;
    currentUser.value = null;
    token.value = '';
    phoneNumber.value = '';
    otpSent.value = false;
    isNewUser.value = false;
    await storage.erase();

    isLoading.value = false;
    Get.offAllNamed('/login');
  }

  Future<void> fetchCurrentUser() async {
    try {
      final user = await authRepository.getCurrentUser();
      currentUser.value = user;
      isLoggedIn.value = true;
    } catch (e) {
      // Token might be expired - try refresh
      final savedRefreshToken = storage.read('refreshToken');
      if (savedRefreshToken != null) {
        try {
          final newToken = await authRepository.refreshToken(savedRefreshToken);
          token.value = newToken;
          await storage.write('token', newToken);
          // Retry fetch
          final user = await authRepository.getCurrentUser();
          currentUser.value = user;
          return;
        } catch (_) {}
      }
      // If all fails, logout
      isLoggedIn.value = false;
      currentUser.value = null;
      token.value = '';
      await storage.erase();
      Get.offAllNamed('/login');
    }
  }

  String getAuthToken() {
    return storage.read('token') ?? token.value;
  }

  String getUserId() {
    return storage.read('userId') ?? currentUser.value?.id ?? '';
  }
}