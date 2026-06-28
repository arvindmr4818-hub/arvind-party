// ═══════════════════════════════════════════════════════════════════════════
// ARVIND PARTY WEB ADMIN PANEL — main.dart
// Production Ready: Flutter Web + GetX + Real Backend
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/env_config.dart';
import 'core/services/api_service.dart';
import 'core/constants/auth_controller.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  await GetStorage.init();

  // Initialize Firebase (only if keys are set)
  if (EnvConfig.firebaseProjectId.isNotEmpty) {
    try {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: EnvConfig.firebaseApiKey,
          authDomain: EnvConfig.firebaseAuthDomain,
          projectId: EnvConfig.firebaseProjectId,
          storageBucket: EnvConfig.firebaseStorageBucket,
          messagingSenderId: EnvConfig.firebaseMessagingSenderId,
          appId: EnvConfig.firebaseAppId,
        ),
      );
    } catch (e) {
      debugPrint('Firebase init skipped: $e');
    }
  }

  // Register global services
  Get.put(ApiService(), permanent: true);
  Get.put(AuthController(), permanent: true);

  runApp(const ArvindPartyAdminApp());
}

class ArvindPartyAdminApp extends StatelessWidget {
  const ArvindPartyAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Arvind Party Admin',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      initialRoute: _getInitialRoute(),
      getPages: AppPages.pages,
      unknownRoute: GetPage(name: AppRoutes.notFound, page: () => const NotFoundPage()),
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0A14),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFF8906),
        secondary: Color(0xFF00B4D8),
        surface: Color(0xFF0F0E1A),
        error: Color(0xFFFF4757),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F0E1A),
        elevation: 0,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1928),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E1D2F))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E1D2F))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF8906))),
        labelStyle: const TextStyle(color: Color(0xFF6B7280)),
        hintStyle: const TextStyle(color: Color(0xFF3A3A4A)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF8906),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF0F0E1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
    );
  }

  String _getInitialRoute() {
    final storage = GetStorage();
    final token = storage.read('auth_token');
    return token != null && token.toString().isNotEmpty
        ? AppRoutes.dashboard
        : AppRoutes.login;
  }
}
