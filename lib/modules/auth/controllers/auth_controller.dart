import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthController extends GetxController {
  var isLoading = false.obs;
  
  // Backend API URL
  final String baseUrl = 'http://10.0.2.2:5000/api/auth';

  // 📱 Real Login (Phone OTP) - Send OTP
  Future<void> sendOtp(String phone) async {
    try {
      isLoading(true);
      final response = await http.post(
        Uri.parse('$baseUrl/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone': phone}),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'OTP sent successfully to $phone');
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      Get.snackbar('Error', 'Server connection failed');
    } finally {
      isLoading(false);
    }
  }

  // 📱 Real Login (Phone OTP) - Verify OTP
  Future<void> verifyOtp(String phone, String otp) async {
    try {
      isLoading(true);
      // TODO: Call backend /verify-otp and save JWT Token locally
      Get.snackbar('Success', 'Login Successful!');
    } catch (e) {
      Get.snackbar('Error', 'Invalid OTP');
    } finally {
      isLoading(false);
    }
  }

  // 🌐 Real Google Login
  Future<void> loginWithGoogle() async {
    // TODO: Implement google_sign_in package logic here
  }

  // 📘 Real Facebook Login
  Future<void> loginWithFacebook() async {
    // TODO: Implement flutter_facebook_auth logic here
  }
}
