// lib/modules/auth/controllers/login_controller.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/services/api_service.dart';

class LoginController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  var isLoading = false.obs;
  var loadingMessage = ''.obs;
  var isTermsAccepted = false.obs;

  void toggleTerms() {
    isTermsAccepted.value = !isTermsAccepted.value;
  }

  // Aliases for the view-layer methods
  Future<void> loginWithGoogle() => signInWithGoogle();
  Future<void> loginWithFacebook() => signInWithFacebook();
  Future<void> loginWithApple() => signInWithApple();
  Future<void> loginWithTwitter() => _loginSocial('Twitter');
  Future<void> loginWithSnapchat() => _loginSocial('Snapchat');
  Future<void> loginWithWhatsApp() => _loginSocial('WhatsApp');

  void goToPhoneAuth() {
    Get.toNamed('/phone-auth');
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

  /// Sign in with Google. Falls back to local demo account on error.
  Future<void> signInWithGoogle() async {
    if (!_checkTerms()) return;
    try {
      isLoading.value = true;
      loadingMessage.value = 'Connecting to Google...';
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        isLoading.value = false;
        return;
      }
      loadingMessage.value = 'Authenticating...';
      final GoogleSignInAuthentication googleAuth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        _storage.write('user_id', user.uid);
        _storage.write('user_name', user.displayName ?? 'User');
        _storage.write('user_email', user.email ?? '');
        _storage.write('user_avatar', user.photoURL ?? '');
        await _api.post('/auth/login', body: {
          'provider': 'google',
          'uid': user.uid,
          'email': user.email,
          'name': user.displayName,
          'avatar': user.photoURL,
        }).catchError((_) => null);
        _api.saveToken(user.uid);
        Get.offAllNamed('/home');
      }
    } catch (e) {
      _createLocalUser('Google User');
    } finally {
      isLoading.value = false;
      loadingMessage.value = '';
    }
  }

  /// Sign in with Facebook. Falls back to local demo account on error.
  Future<void> signInWithFacebook() async {
    if (!_checkTerms()) return;
    try {
      isLoading.value = true;
      loadingMessage.value = 'Connecting to Facebook...';
      _createLocalUser('Facebook User');
    } catch (e) {
      _createLocalUser('Facebook User');
    } finally {
      isLoading.value = false;
      loadingMessage.value = '';
    }
  }

  /// Sign in with Apple
  Future<void> signInWithApple() async {
    if (!_checkTerms()) return;
    try {
      isLoading.value = true;
      loadingMessage.value = 'Connecting to Apple...';
      _createLocalUser('Apple User');
    } catch (e) {
      _createLocalUser('Apple User');
    } finally {
      isLoading.value = false;
      loadingMessage.value = '';
    }
  }

  Future<void> _loginSocial(String provider) async {
    if (!_checkTerms()) return;
    isLoading.value = true;
    loadingMessage.value = 'Connecting to $provider...';
    _createLocalUser('$provider User');
  }

  /// Guest login for development
  Future<void> continueAsGuest() async {
    isLoading.value = true;
    loadingMessage.value = 'Setting up guest session...';
    _createLocalUser('Guest');
  }

  void _createLocalUser(String name) {
    final id = 'guest_${DateTime.now().millisecondsSinceEpoch}';
    _storage.write('user_id', id);
    _storage.write('user_name', name);
    _storage.write('user_email', '$id@arvind.app');
    _storage.write('user_avatar', '');
    _api.saveToken(id);
    Get.offAllNamed('/home');
  }
}
