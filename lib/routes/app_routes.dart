// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/routes/app_routes.dart
// ═══════════════════════════════════════════════════════════════════════════

abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const phoneAuth = '/phone-auth'; // ← NEW
  static const home = '/home';
  static const voiceRoom = '/voice-room';
  static const createRoom = '/create-room'; // ← NEW
  static const profile = '/profile';
  static const wallet = '/wallet';
}
