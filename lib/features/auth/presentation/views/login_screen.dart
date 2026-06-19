import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/login_controller.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late VideoPlayerController _videoController;
  bool _videoInitialized = false;

  final LoginController controller = Get.find<LoginController>();
  final AuthController authController = Get.find<AuthController>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();
  var showEmailLogin = false.obs;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() {
    _videoController =
        VideoPlayerController.asset('assets/login/videos/lion_bg.mp4')
          ..initialize().then((_) {
            if (mounted) {
              setState(() => _videoInitialized = true);
              _videoController
                ..setLooping(true)
                ..setVolume(0.0)
                ..play();
            }
          }).catchError((e) {
            debugPrint('[LoginScreen] Video load error: $e');
          });
  }

  @override
  void dispose() {
    _videoController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildBackground(size),
          _buildGradientOverlay(),
          SafeArea(child: _buildContent(context, size)),
          Obx(() {
            if (showEmailLogin.value) {
              return _buildEmailLoginOverlay();
            }
            return const SizedBox.shrink();
          }),
          Obx(() => controller.isLoading.value
              ? _buildLoadingOverlay()
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildBackground(Size size) {
    if (_videoInitialized && _videoController.value.isInitialized) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _videoController.value.size.width,
            height: _videoController.value.size.height,
            child: VideoPlayer(_videoController),
          ),
        ),
      );
    }
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.3),
          radius: 1.2,
          colors: [Color(0xFF3E2723), Color(0xFF1A1A1A), Color(0xFF000000)],
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.35, 0.6, 1.0],
          colors: [
            Color(0x99000000),
            Color(0x22000000),
            Color(0xBB000000),
            Color(0xEE000000),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Size size) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: size.height),
        child: Column(
          children: [
            SizedBox(height: size.height * 0.06),
            _buildLogo()
                .animate()
                .fadeIn(delay: 300.ms, duration: 600.ms)
                .slideY(begin: -0.2, end: 0),
            SizedBox(height: size.height * 0.24),
            _buildAppName()
                .animate()
                .fadeIn(delay: 500.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildLoginButtons()
                  .animate()
                  .fadeIn(delay: 700.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),
            ),
            const SizedBox(height: 24),
            _buildTermsSection()
                .animate()
                .fadeIn(delay: 1100.ms, duration: 600.ms),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.3),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3), width: 1),
          ),
          child: Image.asset(
            'assets/login/login_icon.png',
            width: 48,
            height: 48,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.pets, color: Color(0xFFFFC107), size: 40,
            ),
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Arvind\n',
                style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 28,
                  fontWeight: FontWeight.w700, color: Colors.white,
                  height: 1.1,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                ),
              ),
              TextSpan(
                text: 'Party',
                style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 26,
                  fontWeight: FontWeight.w600, color: Color(0xFFFFC107),
                  shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppName() {
    return Column(
      children: [
        const Text(
          'Arvind Party',
          style: TextStyle(
            fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white,
            letterSpacing: 0.5,
            shadows: [Shadow(color: Colors.black, blurRadius: 12, offset: Offset(0, 2))],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Live Social Streaming',
          style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w500,
            color: const Color(0xFF64B5F6), letterSpacing: 1.2,
            shadows: [Shadow(color: Colors.black.withValues(alpha: 0.8), blurRadius: 8)],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: _SocialButton(
            label: 'Login with Email',
            icon: Icons.email,
            color: Colors.white,
            textColor: Colors.black87,
            isGoogle: false,
            onTap: () {
              showEmailLogin.value = !showEmailLogin.value;
            },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: _SocialButton(
            label: 'Continue with Google',
            icon: FontAwesomeIcons.google,
            color: Colors.white,
            textColor: Colors.black87,
            isGoogle: true,
            onTap: controller.loginWithGoogle,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: _PhoneButton(onTap: controller.goToPhoneAuth),
        ),
      ],
    );
  }

  Widget _buildEmailLoginOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => showEmailLogin.value = false,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Form(
                  key: loginFormKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          labelStyle: const TextStyle(color: Colors.white70),
                          hintStyle: const TextStyle(color: Colors.white38),
                          prefixIcon: const Icon(Icons.email, color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white38),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Email is required';
                          if (!value!.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          labelStyle: const TextStyle(color: Colors.white70),
                          hintStyle: const TextStyle(color: Colors.white38),
                          prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white38),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Password is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // For mobile app, redirect to phone auth
                            Get.toNamed('/phone-auth');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(color: Colors.white70),
                          ),
                          GestureDetector(
                            onTap: () {
                              showEmailLogin.value = false;
                              Get.toNamed('/signup');
                            },
                            child: const Text(
                              'Sign up',
                              style: TextStyle(
                                color: Color(0xFF64B5F6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsSection() {
    return Obx(() => GestureDetector(
      onTap: controller.toggleTerms,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20, height: 20,
              decoration: BoxDecoration(
                color: controller.isTermsAccepted.value
                    ? const Color(0xFF1E88E5) : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: controller.isTermsAccepted.value
                      ? const Color(0xFF1E88E5) : Colors.white54,
                  width: 2,
                ),
              ),
              child: controller.isTermsAccepted.value
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12.5, fontFamily: 'Poppins',
                  ),
                  children: const [
                    TextSpan(text: 'Agree to '),
                    TextSpan(
                      text: 'Terms of Use',
                      style: TextStyle(
                        color: Color(0xFF64B5F6),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: Color(0xFF64B5F6),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF1E88E5), strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Obx(() => Text(
                controller.loadingMessage.value,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final dynamic icon;
  final Color color;
  final Color? textColor;
  final bool isGoogle;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.color,
    this.textColor,
    this.isGoogle = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor ?? Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isGoogle
              ? const FaIcon(FontAwesomeIcons.google, color: Color(0xFF4285F4), size: 16)
              : Icon(icon, color: textColor ?? Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontWeight: FontWeight.w600, fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PhoneButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white54, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: Colors.white.withValues(alpha: 0.05),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.phone_android, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text(
            'Sign up with Phone Number',
            style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
