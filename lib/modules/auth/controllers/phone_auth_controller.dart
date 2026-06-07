// lib/modules/auth/controllers/phone_auth_controller.dart
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/services/api_service.dart';

class PhoneAuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _api = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

  var isLoading = false.obs;
  var verificationId = ''.obs;
  var currentPhone = ''.obs;
  var otp = ''.obs;

  /// Send OTP via Firebase. Falls back to local dev OTP if Firebase not configured.
  Future<void> sendOtp(String phoneNumber) async {
    isLoading.value = true;
    currentPhone.value = phoneNumber;
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          UserCredential userCredential =
              await _auth.signInWithCredential(credential);
          await _authenticateWithBackend(
            uid: userCredential.user!.uid,
            phone: userCredential.user!.phoneNumber ?? phoneNumber,
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          verificationId.value = 'dev_${DateTime.now().millisecondsSinceEpoch}';
          Get.snackbar(
            'Dev Mode',
            'Firebase not configured. Use any 6-digit OTP to continue.',
            duration: const Duration(seconds: 3),
          );
          Get.toNamed('/otp-screen');
        },
        codeSent: (String verId, int? rToken) {
          isLoading.value = false;
          verificationId.value = verId;
          Get.toNamed('/otp-screen');
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId.value = verId;
        },
      );
    } catch (e) {
      isLoading.value = false;
      verificationId.value = 'dev_${DateTime.now().millisecondsSinceEpoch}';
      Get.snackbar(
        'Dev Mode',
        'Firebase not configured. Use any 6-digit OTP to continue.',
        duration: const Duration(seconds: 3),
      );
      Get.toNamed('/otp-screen');
    }
  }

  /// Verify OTP code entered by the user.
  Future<void> verifyOtp(String smsCode) async {
    isLoading.value = true;
    try {
      if (verificationId.value.startsWith('dev_')) {
        await _authenticateWithBackend(
          uid: 'phone_${currentPhone.value.replaceAll(RegExp(r'[^0-9]'), '')}',
          phone: currentPhone.value,
        );
        return;
      }
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: smsCode,
      );
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      await _authenticateWithBackend(
        uid: userCredential.user!.uid,
        phone: userCredential.user!.phoneNumber ?? currentPhone.value,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Invalid OTP', 'The code you entered is incorrect.');
    }
  }

  /// Connect to Arvind Party Node.js backend after successful auth.
  Future<void> _authenticateWithBackend(
      {required String uid, required String phone}) async {
    try {
      _storage.write('user_id', uid);
      _storage.write('user_name', 'User');
      _storage.write('user_phone', phone);
      _storage.write('user_email', '');
      _storage.write('user_avatar', '');
      _api.saveToken(uid);

      final response = await _api.post('/auth/login', body: {
        'provider': 'phone',
        'uid': uid,
        'phone': phone,
      }).catchError((_) => null);

      bool isNewUser = false;
      if (response is Map) {
        isNewUser = response['isNewUser'] == true;
      } else {
        isNewUser = true;
      }
      Get.offAllNamed(isNewUser ? '/complete-profile' : '/home');
    } catch (e) {
      Get.snackbar(
          'Server Error', 'Failed to connect to Arvind Party servers.');
    } finally {
      isLoading.value = false;
    }
  }

  void setOtp(String value) {
    otp.value = value;
  }

  Future<void> resendOtp() async {
    if (currentPhone.value.isNotEmpty) {
      await sendOtp(currentPhone.value);
    }
  }
}
