// ═══════════════════════════════════════════════════════════════════════════
// AUTH CONTROLLER — Real Backend OTP + Google + Apple Login
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/services/api_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../home/services/user_service.dart';

class AuthController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final UserService _userService = Get.find<UserService>();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final phoneNumber = ''.obs;
  final verificationId = ''.obs;
  final resendToken = Rx<int?>(null);
  final otpSentTimestamp = Rx<DateTime?>(null);

  // ─── PHONE OTP LOGIN ────────────────────────────────────────────────────
  Future<void> sendOtp(String phone) async {
    isLoading.value = true;
    errorMessage.value = '';
    phoneNumber.value = phone;

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification on Android
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          errorMessage.value = e.message ?? 'Verification failed';
        },
        codeSent: (String verId, int? token) {
          isLoading.value = false;
          verificationId.value = verId;
          resendToken.value = token;
          otpSentTimestamp.value = DateTime.now();
          Get.toNamed(AppRoutes.otp);
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId.value = verId;
        },
      );
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
    }
  }

  Future<bool> verifyOtp(String otp) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otp,
      );
      return await _signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      errorMessage.value = e.code == 'invalid-verification-code'
          ? 'Invalid OTP. Please try again.'
          : (e.message ?? 'Verification failed');
      return false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> _signInWithCredential(AuthCredential credential) async {
    try {
      final userCred = await _firebaseAuth.signInWithCredential(credential);
      final firebaseToken = await userCred.user?.getIdToken();

      if (firebaseToken == null) {
        isLoading.value = false;
        errorMessage.value = 'Failed to get Firebase token';
        return false;
      }

      // Exchange Firebase token for backend JWT
      final res = await _api.post('/auth/firebase-login', {
        'idToken': firebaseToken,
        'phone': userCred.user?.phoneNumber,
      });

      isLoading.value = false;

      if (res['success'] == true) {
        final token = res['data']['token'];
        final user = Map<String, dynamic>.from(res['data']['user'] ?? {});
        _userService.saveSession(user, token);

        if (res['data']['isNewUser'] == true) {
          Get.offAllNamed(AppRoutes.profileSetup);
        } else {
          Get.offAllNamed(AppRoutes.home);
        }
        return true;
      } else {
        errorMessage.value = res['message'] ?? 'Login failed';
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<void> resendOtp() async {
    if (phoneNumber.value.isEmpty) return;
    await sendOtp(phoneNumber.value);
  }

  // ─── GOOGLE LOGIN ───────────────────────────────────────────────────────
  Future<bool> signInWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return false; // User cancelled
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _firebaseAuth.signInWithCredential(credential);
      final firebaseToken = await userCred.user?.getIdToken();

      final res = await _api.post('/auth/firebase-login', {
        'idToken': firebaseToken,
        'email': userCred.user?.email,
        'name': userCred.user?.displayName,
        'avatar': userCred.user?.photoURL,
      });

      isLoading.value = false;

      if (res['success'] == true) {
        final token = res['data']['token'];
        final user = Map<String, dynamic>.from(res['data']['user'] ?? {});
        _userService.saveSession(user, token);

        if (res['data']['isNewUser'] == true) {
          Get.offAllNamed(AppRoutes.profileSetup);
        } else {
          Get.offAllNamed(AppRoutes.home);
        }
        return true;
      } else {
        errorMessage.value = res['message'] ?? 'Google login failed';
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      return false;
    }
  }

  // ─── LOGOUT ─────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } catch (_) {}
    await _userService.logout();
  }
}
