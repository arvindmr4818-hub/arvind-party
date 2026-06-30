// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/main.dart
// ARVIND PARTY — ENTRY POINT (Firebase Auth + Node.js Backend + LiveKit)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'core/services/api_service.dart';
import 'core/socket/socket_service.dart';
import 'core/services/auth_session_manager.dart';
import 'core/utils/network_manager.dart';
import 'features/auth/presentation/repositories/auth_repository.dart';
import 'features/home/services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize local storage
  await GetStorage.init();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init error (check google-services.json): $e');
  }

  // ─── Register Core Services (order matters) ──────────────────────────
  Get.put(NetworkManager(), permanent: true);
  Get.put(AuthSessionManager(), permanent: true);
  Get.put(ApiService(), permanent: true);
  Get.put(SocketService(), permanent: true);
  Get.put(UserService(), permanent: true);
  Get.put(AuthRepository(), permanent: true);

  runApp(const ArvindPartyApp());
}

class ArvindPartyApp extends StatelessWidget {
  const ArvindPartyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Arvind Party',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 250),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0D0D1A),
      fontFamily: 'Poppins',
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFF8906),
        secondary: Color(0xFF00B4D8),
        surface: Color(0xFF12111F),
        error: Color(0xFFFF4757),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF12111F),
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF8906),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}
