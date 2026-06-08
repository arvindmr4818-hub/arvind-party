import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late VideoPlayerController _videoController;
  bool _videoInitialized = false;

  // Get.find - AuthBinding ne controller pehle se register kar diya hai
  final LoginController controller = Get.find<LoginController>();

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
            // Fallback gradient automatically show hoga
          });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Layer 1: Video / Fallback Background
          _buildBackground(size),

          // Layer 2: Dark Gradient Overlay
          _buildGradientOverlay(),

          // Layer 3: Main Content
          SafeArea(
            child: _buildContent(context, size),
          ),

          // Layer 4: Loading Overlay
          Obx(() => controller.isLoading.value
              ? _buildLoadingOverlay()
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  // ─── BACKGROUND ──────────────────────────────────────────────────────────

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

    // Fallback gradient (video load hone se pehle)
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.3),
          radius: 1.2,
          colors: [
            Color(0xFF3E2723),
            Color(0xFF1A1A1A),
            Color(0xFF000000),
          ],
        ),
      ),
      child: Image.asset(
        'assets/images/lion_fallback.jpg',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }

  // ─── GRADIENT OVERLAY ────────────────────────────────────────────────────

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

  // ─── MAIN CONTENT ────────────────────────────────────────────────────────

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
            SizedBox(height: size.height * 0.28),
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
            _buildMoreWaysSection()
                .animate()
                .fadeIn(delay: 900.ms, duration: 600.ms),
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

  // ─── LOGO ─────────────────────────────────────────────────────────────────

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.3),
            border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1),
          ),
          child: Image.asset(
            'assets/login/login_icon.png',
            width: 48,
            height: 48,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.pets,
              color: Color(0xFFFFC107),
              size: 40,
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
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.1,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                ),
              ),
              TextSpan(
                text: 'Party',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFC107),
                  shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── APP NAME ─────────────────────────────────────────────────────────────

  Widget _buildAppName() {
    return Column(
      children: [
        const Text(
          'Arvind Party',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.5,
            shadows: [
              Shadow(color: Colors.black, blurRadius: 12, offset: Offset(0, 2)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Live Social Streaming',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64B5F6),
            letterSpacing: 1.2,
            shadows: [
              Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 8),
            ],
          ),
        ),
      ],
    );
  }

  // ─── LOGIN BUTTONS ────────────────────────────────────────────────────────

  Widget _buildLoginButtons() {
    return Column(
      children: [
        // Facebook + Google
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                label: 'Facebook',
                icon: FontAwesomeIcons.facebookF,
                color: const Color(0xFF1877F2),
                onTap: controller.loginWithFacebook,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SocialButton(
                label: 'Google',
                icon: FontAwesomeIcons.google,
                color: Colors.white,
                textColor: Colors.black87,
                isGoogle: true,
                onTap: controller.loginWithGoogle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // WhatsApp (full width)
        _SocialButton(
          label: 'WhatsApp',
          icon: FontAwesomeIcons.whatsapp,
          color: const Color(0xFF25D366),
          fullWidth: true,
          iconSize: 22,
          onTap: controller.loginWithWhatsApp,
        ),
        const SizedBox(height: 12),

        // Phone Number
        _PhoneButton(onTap: controller.goToPhoneAuth),
      ],
    );
  }

  // ─── MORE WAYS ────────────────────────────────────────────────────────────

  Widget _buildMoreWaysSection() {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 24),
            Expanded(
              child: Divider(
                  color: Colors.white.withOpacity(0.25), thickness: 0.5),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'More ways to log in',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                  color: Colors.white.withOpacity(0.25), thickness: 0.5),
            ),
            const SizedBox(width: 24),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _IconOnlyButton(
              icon: FontAwesomeIcons.apple,
              color: Colors.black,
              borderColor: Colors.white24,
              onTap: controller.loginWithApple,
              tooltip: 'Sign in with Apple',
            ),
            const SizedBox(width: 16),
            _IconOnlyButton(
              icon: FontAwesomeIcons.twitter,
              color: const Color(0xFF1DA1F2),
              borderColor: Colors.transparent,
              onTap: controller.loginWithTwitter,
              tooltip: 'Sign in with Twitter',
            ),
            const SizedBox(width: 16),
            _IconOnlyButton(
              icon: FontAwesomeIcons.snapchat,
              color: const Color(0xFFFFFC00),
              iconColor: Colors.black,
              borderColor: Colors.transparent,
              onTap: controller.loginWithSnapchat,
              tooltip: 'Sign in with Snapchat',
            ),
          ],
        ),
      ],
    );
  }

  // ─── TERMS ────────────────────────────────────────────────────────────────

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
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: controller.isTermsAccepted.value
                        ? const Color(0xFF1E88E5)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: controller.isTermsAccepted.value
                          ? const Color(0xFF1E88E5)
                          : Colors.white54,
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
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12.5,
                        fontFamily: 'Poppins',
                      ),
                      children: const [
                        TextSpan(text: 'Agree to '),
                        TextSpan(
                          text: 'Terms of Use',
                          style: TextStyle(
                            color: Color(0xFF64B5F6),
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFF64B5F6),
                          ),
                        ),
                        TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: Color(0xFF64B5F6),
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFF64B5F6),
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

  // ─── LOADING OVERLAY ─────────────────────────────────────────────────────

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
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
                color: Color(0xFF1E88E5),
                strokeWidth: 3,
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

// ══════════════════════════════════════════════════════════════════════════════
//  REUSABLE WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

class _SocialButton extends StatelessWidget {
  final String label;
  final dynamic icon;
  final Color color;
  final Color? textColor;
  final Color? iconColor;
  final bool fullWidth;
  final bool isGoogle;
  final double iconSize;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.color,
    this.textColor,
    this.iconColor,
    this.fullWidth = false,
    this.isGoogle = false,
    this.iconSize = 18,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor ?? Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            isGoogle
                ? const FaIcon(FontAwesomeIcons.google,
                    color: Color(0xFF4285F4), size: 16)
                : FaIcon(
                    icon,
                    color: iconColor ?? (textColor ?? Colors.white),
                    size: iconSize,
                  ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PhoneButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white54, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: Colors.white.withOpacity(0.05),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_android, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Sign up with Phone Number',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconOnlyButton extends StatelessWidget {
  final dynamic icon;
  final Color color;
  final Color? iconColor;
  final Color borderColor;
  final VoidCallback onTap;
  final String tooltip;

  const _IconOnlyButton({
    required this.icon,
    required this.color,
    this.iconColor,
    required this.borderColor,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: FaIcon(icon, color: iconColor ?? Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}
