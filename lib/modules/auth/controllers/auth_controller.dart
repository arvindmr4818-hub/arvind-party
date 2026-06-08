import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../../core/services/api_service.dart';

class AuthController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isLoading = false.obs;
  var verificationId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initGoogleSignIn();
  }

  Future<void> _initGoogleSignIn() async {
    try {
      await GoogleSignIn.instance.initialize();
    } catch (_) {}
  }

  // 📱 Phone OTP - Send OTP
  Future<void> sendOtp(String phone) async {
    try {
      isLoading(true);
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          Get.snackbar('Error', e.message ?? 'Verification failed');
        },
        codeSent: (String verId, int? resendToken) {
          verificationId.value = verId;
          Get.snackbar('Success', 'OTP sent to $phone');
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId.value = verId;
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to send OTP');
    } finally {
      isLoading(false);
    }
  }

  // 📱 Phone OTP - Verify OTP
  Future<void> verifyOtp(String phone, String otp) async {
    try {
      isLoading(true);
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otp,
      );
      await _signInWithCredential(credential);
    } catch (e) {
      Get.snackbar('Error', 'Invalid OTP');
    } finally {
      isLoading(false);
    }
  }

  // 🌐 Real Google Login
  Future<void> loginWithGoogle() async {
    try {
      isLoading(true);
      final GoogleSignInAccount? account = await GoogleSignIn.instance.authenticate();
      
      if (account == null) return;

      final GoogleSignInAuthentication googleAuth = account.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      await _signInWithCredential(credential);
    } catch (e) {
      Get.snackbar('Error', 'Google login failed: $e');
    } finally {
      isLoading(false);
    }
  }

  // 📘 Real Facebook Login
  Future<void> loginWithFacebook() async {
    try {
      isLoading(true);
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final AuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
        await _signInWithCredential(credential);
      } else {
        Get.snackbar('Error', result.message ?? 'Facebook login failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'Facebook login failed');
    } finally {
      isLoading(false);
    }
  }

  // 🚀 Connect to Node.js Backend
  Future<void> _signInWithCredential(AuthCredential credential) async {
    try {
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      String? idToken = await userCredential.user?.getIdToken();

      if (idToken != null) {
        final response = await _apiService.post('auth/verify-firebase', body: {
          'idToken': idToken,
        });

        if (response != null && response['success'] == true) {
          String serverToken = response['token'];
          bool isNewUser = response['isNewUser'] ?? false;
          
          _apiService.saveToken(serverToken);

          if (isNewUser) {
            Get.offAllNamed('/complete-profile');
          } else {
            Get.offAllNamed('/home');
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Authentication failed on server');
    }
  }
}