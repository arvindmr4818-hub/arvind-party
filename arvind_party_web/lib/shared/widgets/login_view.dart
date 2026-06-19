import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../core/theme/web_theme.dart';

// ============================================================
// ARVIND PARTY WEB — Login View
// ============================================================
// 🔴 FIXED: After successful login, redirects to /dashboard
//           (previously incorrectly redirected to /home which
//            did not exist as a registered route)
// ============================================================

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _loginIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _isLoading = false.obs;
  final _obscurePassword = true.obs;

  @override
  void dispose() {
    _loginIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = AuthController.to;
    final success = await auth.login(
      _loginIdController.text.trim(),
      _passwordController.text,
    );

    if (success) {
      // 🔴 Redirect to /dashboard after successful login
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      // Show the actual backend error message
      final errorMsg = auth.loginError.isNotEmpty
          ? auth.loginError
          : 'Invalid Login ID or Password. Please try again.';
      Get.snackbar(
        'Login Failed',
        errorMsg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: WebTheme.errorRed,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WebTheme.backgroundDark,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ─── Logo / Brand ─────────────────────
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: WebTheme.primaryOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings,
                          size: 40,
                          color: WebTheme.primaryOrange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Arvind Party',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: WebTheme.primaryOrange,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Admin Panel',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: WebTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 32),

                      // ─── Login ID Field ───────────────────
                      TextFormField(
                        controller: _loginIdController,
                        decoration: const InputDecoration(
                          labelText: 'Login ID',
                          hintText: 'Enter your Login ID',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your Login ID';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // ─── Password Field ───────────────────
                      Obx(() => TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword.value,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  _obscurePassword.value =
                                      !_obscurePassword.value;
                                },
                              ),
                            ),
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleLogin(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 4) {
                                return 'Password must be at least 4 characters';
                              }
                              return null;
                            },
                          )),
                      const SizedBox(height: 24),

      // ─── Login Button ─────────────────────
                      Obx(() => SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading.value ? null : _handleLogin,
                              child: _isLoading.value
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    )
                                  : const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          )),

                      const SizedBox(height: 16),

                      // ─── Footer ───────────────────────────
                      Text(
                        'Arvind Party Admin Panel v1.0',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: WebTheme.textSecondary.withValues(alpha: 0.6),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}