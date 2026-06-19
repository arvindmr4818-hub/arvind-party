// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/splash/presentation/views/splash_screen.dart
// ARVIND PARTY - SPLASH SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/splash/logo.png', height: 120, width: 120),
            const SizedBox(height: 24),
            const Text(
              'ARVIND PARTY',
              style: TextStyle(
                color: Color(0xFFFF8906),
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8906)),
            ),
          ],
        ),
      ),
    );
  }
}