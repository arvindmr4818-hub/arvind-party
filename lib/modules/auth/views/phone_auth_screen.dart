// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/modules/auth/views/phone_auth_screen.dart
//
// 3 STATES IN ONE SCREEN:
//   State 1 → Phone Number Input
//   State 2 → OTP Verification
//   State 3 → Profile Setup (New User only)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/otp_controller.dart';

class PhoneAuthScreen extends StatelessWidget {
  const PhoneAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OtpController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: Obx(() {
        switch (ctrl.screenState.value) {
          case OtpScreenState.phoneInput:
            return _PhoneInputView(ctrl: ctrl);
          case OtpScreenState.otpInput:
            return _OtpInputView(ctrl: ctrl);
          case OtpScreenState.profileSetup:
            return _ProfileSetupView(ctrl: ctrl);
        }
      }),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// STATE 1 — PHONE NUMBER INPUT
// ═════════════════════════════════════════════════════════════════════════════

class _PhoneInputView extends StatefulWidget {
  final OtpController ctrl;
  const _PhoneInputView({required this.ctrl});

  @override
  State<_PhoneInputView> createState() => _PhoneInputViewState();
}

class _PhoneInputViewState extends State<_PhoneInputView> {
  final _phoneFocus = FocusNode();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneFocus.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.ctrl;

    return SafeArea(
      child: Column(
        children: [
          // ── Top Bar ──────────────────────────────────────────────────────
          _TopBar(onBack: ctrl.goBack),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  // ── Header ────────────────────────────────────────────────
                  const _AuthIcon(
                          icon: Icons.phone_android, color: Color(0xFFFF8906))
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .scale(begin: const Offset(0.8, 0.8)),

                  const SizedBox(height: 20),

                  const Text('Enter Your\nPhone Number',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ))
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 500.ms)
                      .slideX(begin: -0.2),

                  const SizedBox(height: 8),

                  Text('We\'ll send a 6-digit OTP to verify your number',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14))
                      .animate()
                      .fadeIn(delay: 200.ms),

                  const SizedBox(height: 40),

                  // ── Phone Input ───────────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF15141F),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Row(
                      children: [
                        // Country Picker
                        GestureDetector(
                          onTap: () => _showCountryPicker(ctrl),
                          child: Obx(() => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                        color: Colors.white.withOpacity(0.08)),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(ctrl.countryFlag.value,
                                        style: const TextStyle(fontSize: 20)),
                                    const SizedBox(width: 6),
                                    Text(ctrl.countryCode.value,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15)),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.keyboard_arrow_down,
                                        color: Colors.white38, size: 18),
                                  ],
                                ),
                              )),
                        ),

                        // Phone Field
                        Expanded(
                          child: TextField(
                            controller: _phoneCtrl,
                            focusNode: _phoneFocus,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(12),
                            ],
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w500),
                            onChanged: ctrl.onPhoneChanged,
                            onSubmitted: (_) => ctrl.sendOtp(),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '00000 00000',
                              hintStyle: TextStyle(
                                  color: Colors.white24,
                                  fontSize: 18,
                                  letterSpacing: 1.5),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 16),
                            ),
                          ),
                        ),

                        // Clear
                        Obx(() => ctrl.phoneNumber.value.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.cancel,
                                    color: Colors.white24, size: 18),
                                onPressed: () {
                                  _phoneCtrl.clear();
                                  ctrl.onPhoneChanged('');
                                },
                              )
                            : const SizedBox.shrink()),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                  const SizedBox(height: 12),

                  // Error
                  Obx(() => ctrl.errorMsg.value.isNotEmpty
                      ? _ErrorText(ctrl.errorMsg.value)
                      : const SizedBox.shrink()),

                  const SizedBox(height: 8),

                  // Hint
                  Text(
                    'Verify your number to join Arvind Party',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.3), fontSize: 12),
                  ),

                  const SizedBox(height: 40),

                  // ── Send OTP Button ────────────────────────────────────────
                  Obx(() => _PrimaryButton(
                        label: 'Send OTP',
                        icon: Icons.send,
                        isLoading: ctrl.isLoading.value,
                        loadingMsg: ctrl.loadingMsg.value,
                        enabled: ctrl.isPhoneValid.value,
                        onTap: ctrl.sendOtp,
                      )).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),

                  const SizedBox(height: 24),

                  // Terms
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 11,
                            fontFamily: 'Poppins'),
                        children: const [
                          TextSpan(text: 'By continuing you agree to our '),
                          TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(color: Color(0xFF64B5F6))),
                          TextSpan(text: ' & '),
                          TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(color: Color(0xFF64B5F6))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCountryPicker(OtpController ctrl) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.65,
        decoration: const BoxDecoration(
          color: Color(0xFF15141F),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text('Select Country',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: ctrl.countryCodes.length,
                separatorBuilder: (_, __) =>
                    Divider(color: Colors.white.withOpacity(0.05), height: 1),
                itemBuilder: (_, i) {
                  final c = ctrl.countryCodes[i];
                  return Obx(() {
                    final selected = ctrl.countryCode.value == c['code'];
                    return ListTile(
                      onTap: () =>
                          ctrl.selectCountry(c.map((k, v) => MapEntry(k, v))),
                      contentPadding: EdgeInsets.zero,
                      leading: Text(c['flag'] as String,
                          style: const TextStyle(fontSize: 24)),
                      title: Text(c['name'] as String,
                          style: TextStyle(
                              color: selected
                                  ? const Color(0xFFFF8906)
                                  : Colors.white70,
                              fontSize: 14,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                      trailing: Text(c['code'] as String,
                          style: TextStyle(
                              color: selected
                                  ? const Color(0xFFFF8906)
                                  : Colors.white38,
                              fontWeight: FontWeight.w600)),
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// STATE 2 — OTP VERIFICATION
// ═════════════════════════════════════════════════════════════════════════════

class _OtpInputView extends StatefulWidget {
  final OtpController ctrl;
  const _OtpInputView({required this.ctrl});

  @override
  State<_OtpInputView> createState() => _OtpInputViewState();
}

class _OtpInputViewState extends State<_OtpInputView> {
  final _pinCtrl = TextEditingController();
  final _pinFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus OTP field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pinFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.ctrl;

    // Pinput theme
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 58,
      textStyle: const TextStyle(
          color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: const Color(0xFF15141F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF8906), width: 2),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFFF8906).withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1)
        ],
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent, width: 1.5),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: const Color(0xFFFF8906).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF8906).withOpacity(0.5)),
      ),
    );

    return SafeArea(
      child: Column(
        children: [
          _TopBar(onBack: ctrl.goBack),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  const _AuthIcon(
                          icon: Icons.sms_outlined, color: Color(0xFF64B5F6))
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(begin: const Offset(0.8, 0.8)),

                  const SizedBox(height: 20),

                  const Text('Verify\nOTP Code',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              height: 1.2))
                      .animate()
                      .fadeIn(delay: 100.ms)
                      .slideX(begin: -0.2),

                  const SizedBox(height: 8),

                  Obx(() => RichText(
                        text: TextSpan(
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14,
                              fontFamily: 'Poppins'),
                          children: [
                            const TextSpan(text: 'OTP sent to '),
                            TextSpan(
                                text: ctrl.fullPhone,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 48),

                  // ── PIN INPUT ──────────────────────────────────────────────
                  Center(
                    child: Obx(() => Pinput(
                          length: 6,
                          controller: _pinCtrl,
                          focusNode: _pinFocus,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          submittedPinTheme: submittedPinTheme,
                          errorPinTheme: errorPinTheme,
                          showCursor: true,
                          cursor: Container(
                            width: 2,
                            height: 24,
                            color: const Color(0xFFFF8906),
                          ),
                          hapticFeedbackType: HapticFeedbackType.lightImpact,
                          onChanged: ctrl.onOtpChanged,
                          onCompleted: (_) => ctrl.verifyOtp(),
                          errorText: ctrl.errorMsg.value.isNotEmpty
                              ? ctrl.errorMsg.value
                              : null,
                        )),
                  )
                      .animate()
                      .fadeIn(delay: 300.ms)
                      .scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 16),

                  // Error
                  Obx(() => ctrl.errorMsg.value.isNotEmpty
                      ? Center(child: _ErrorText(ctrl.errorMsg.value))
                      : const SizedBox.shrink()),

                  // ── Dev Hint (remove in production) ───────────────────────
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.amber.withOpacity(0.25)),
                      ),
                      child: const Text('🧪 Test OTP: 123456',
                          style: TextStyle(
                              color: Colors.amber,
                              fontSize: 11,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ── Verify Button ──────────────────────────────────────────
                  Obx(() => _PrimaryButton(
                        label: 'Verify OTP',
                        icon: Icons.verified_user_outlined,
                        isLoading: ctrl.isLoading.value,
                        loadingMsg: ctrl.loadingMsg.value,
                        enabled: ctrl.otpCode.value.length == 6,
                        onTap: ctrl.verifyOtp,
                      )).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 24),

                  // ── Resend Section ─────────────────────────────────────────
                  Center(
                    child: Obx(() {
                      final secs = ctrl.resendSeconds.value;
                      return secs > 0
                          ? RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                    fontFamily: 'Poppins', fontSize: 13),
                                children: [
                                  TextSpan(
                                      text: 'Resend OTP in ',
                                      style: TextStyle(
                                          color:
                                              Colors.white.withOpacity(0.4))),
                                  TextSpan(
                                      text: '${secs}s',
                                      style: const TextStyle(
                                          color: Color(0xFFFF8906),
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                          : GestureDetector(
                              onTap: ctrl.resendOtp,
                              child: const Text('Resend OTP',
                                  style: TextStyle(
                                      color: Color(0xFF64B5F6),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Color(0xFF64B5F6))),
                            );
                    }),
                  ),

                  const SizedBox(height: 16),

                  // Wrong number
                  Center(
                    child: GestureDetector(
                      onTap: ctrl.goBack,
                      child: Text('Wrong number? Change it',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.35),
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white.withOpacity(0.3))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// STATE 3 — PROFILE SETUP (New User)
// ═════════════════════════════════════════════════════════════════════════════

class _ProfileSetupView extends StatefulWidget {
  final OtpController ctrl;
  const _ProfileSetupView({required this.ctrl});

  @override
  State<_ProfileSetupView> createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends State<_ProfileSetupView> {
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.ctrl;

    return SafeArea(
      child: Column(
        children: [
          // No back button on profile setup — user is already verified
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, color: Colors.greenAccent, size: 13),
                      SizedBox(width: 5),
                      Text('Verified',
                          style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // ── Avatar Upload ──────────────────────────────────────────
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF15141F),
                            border: Border.all(
                                color: const Color(0xFFFF8906).withOpacity(0.4),
                                width: 2),
                          ),
                          child: const Icon(Icons.person,
                              color: Colors.white24, size: 48),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              // TODO: image_picker integrate karo
                            },
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF8906),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt,
                                  color: Colors.black, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .scale(begin: const Offset(0.8, 0.8)),

                  const SizedBox(height: 8),

                  const Center(
                    child: Text('Add Profile Photo',
                        style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ),

                  const SizedBox(height: 28),

                  // ── Display Name ───────────────────────────────────────────
                  const _FieldLabel('Your Name *'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameCtrl,
                    onChanged: ctrl.onNameChanged,
                    maxLength: 30,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                    decoration: _inputDeco(
                      hint: 'Enter your display name',
                      icon: Icons.badge_outlined,
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),

                  const SizedBox(height: 20),

                  // ── Gender ─────────────────────────────────────────────────
                  const _FieldLabel('Gender *'),
                  const SizedBox(height: 10),
                  Obx(() => Row(
                        children: [
                          _GenderChip(
                            label: 'Male',
                            icon: '👨',
                            selected: ctrl.selectedGender.value == 'male',
                            onTap: () => ctrl.selectGender('male'),
                          ),
                          const SizedBox(width: 10),
                          _GenderChip(
                            label: 'Female',
                            icon: '👩',
                            selected: ctrl.selectedGender.value == 'female',
                            onTap: () => ctrl.selectGender('female'),
                          ),
                          const SizedBox(width: 10),
                          _GenderChip(
                            label: 'Other',
                            icon: '🌈',
                            selected: ctrl.selectedGender.value == 'other',
                            onTap: () => ctrl.selectGender('other'),
                          ),
                        ],
                      )).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 20),

                  // ── Date of Birth ──────────────────────────────────────────
                  const _FieldLabel('Date of Birth (optional)'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _pickDate(ctrl),
                    child: Obx(() => Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF15141F),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.08)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.cake_outlined,
                                  color: Color(0xFFFF8906), size: 20),
                              const SizedBox(width: 10),
                              Text(
                                ctrl.selectedDob.value != null
                                    ? _formatDate(ctrl.selectedDob.value!)
                                    : 'Select date of birth',
                                style: TextStyle(
                                    color: ctrl.selectedDob.value != null
                                        ? Colors.white
                                        : Colors.white30,
                                    fontSize: 14),
                              ),
                              const Spacer(),
                              const Icon(Icons.keyboard_arrow_down,
                                  color: Colors.white24, size: 20),
                            ],
                          ),
                        )),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 12),

                  // Error
                  Obx(() => ctrl.errorMsg.value.isNotEmpty
                      ? _ErrorText(ctrl.errorMsg.value)
                      : const SizedBox.shrink()),

                  const SizedBox(height: 32),

                  // ── Complete Button ────────────────────────────────────────
                  Obx(() => _PrimaryButton(
                        label: 'Start Partying! 🎉',
                        icon: Icons.celebration,
                        isLoading: ctrl.isLoading.value,
                        loadingMsg: ctrl.loadingMsg.value,
                        enabled: ctrl.isProfileValid,
                        onTap: ctrl.completeProfileSetup,
                      )).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _pickDate(OtpController ctrl) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18),
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 13), // min age 13
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFF8906),
              surface: Color(0xFF15141F),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) ctrl.selectDob(picked);
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  InputDecoration _inputDeco({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFF15141F),
      counterStyle: const TextStyle(color: Colors.white24, fontSize: 11),
      prefixIcon: Icon(icon, color: const Color(0xFFFF8906), size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF8906), width: 1.5),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// REUSABLE WIDGETS
// ═════════════════════════════════════════════════════════════════════════════

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon:
                const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
            onPressed: onBack,
          ),
        ],
      ),
    );
  }
}

class _AuthIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _AuthIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3));
  }
}

class _ErrorText extends StatelessWidget {
  final String text;
  const _ErrorText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(text,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final String icon;
  final bool selected;
  final VoidCallback onTap;
  const _GenderChip(
      {required this.label,
      required this.icon,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFFF8906).withOpacity(0.12)
                : const Color(0xFF15141F),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? const Color(0xFFFF8906)
                  : Colors.white.withOpacity(0.08),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      color:
                          selected ? const Color(0xFFFF8906) : Colors.white60,
                      fontSize: 12,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final String loadingMsg;
  final bool enabled;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.loadingMsg,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton(
          onPressed: (enabled && !isLoading) ? onTap : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: enabled
                ? const Color(0xFFFF8906)
                : const Color(0xFFFF8906).withOpacity(0.3),
            disabledBackgroundColor: const Color(0xFFFF8906).withOpacity(0.25),
            elevation: enabled ? 4 : 0,
            shadowColor: const Color(0xFFFF8906).withOpacity(0.3),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          ),
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    ),
                    const SizedBox(width: 12),
                    Text(loadingMsg,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.black, size: 20),
                    const SizedBox(width: 8),
                    Text(label,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
        ),
      ),
    );
  }
}
