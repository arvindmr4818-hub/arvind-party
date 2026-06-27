// ═══════════════════════════════════════════════════════════════════════════
// ARVIND PARTY WEB PANEL — Environment Configuration
// ═══════════════════════════════════════════════════════════════════════════
// HOW TO USE:
//   Dev:  flutter run -d chrome
//   Prod: flutter build web --dart-define=BACKEND_URL=https://api.yourdomain.com
// ═══════════════════════════════════════════════════════════════════════════

class EnvConfig {
  // ─── API URLS ───────────────────────────────────────────────────────────
  // Dev: your local PC IP (change to your machine IP)
  static const String devApiBaseUrl = 'http://localhost:5000/api';

  // Prod: set via --dart-define=BACKEND_URL=https://api.yourdomain.com/api
  static const String prodApiBaseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://api.arvindparty.com/api',
  );

  // ─── SOCKET.IO ──────────────────────────────────────────────────────────
  static const String devSocketUrl = 'http://localhost:5000';
  static const String prodSocketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'https://api.arvindparty.com',
  );

  // ─── FIREBASE ───────────────────────────────────────────────────────────
  static const String firebaseApiKey =
      String.fromEnvironment('FIREBASE_API_KEY', defaultValue: '');
  static const String firebaseAuthDomain =
      String.fromEnvironment('FIREBASE_AUTH_DOMAIN', defaultValue: '');
  static const String firebaseProjectId =
      String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: '');
  static const String firebaseStorageBucket =
      String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: '');
  static const String firebaseMessagingSenderId =
      String.fromEnvironment('FIREBASE_SENDER_ID', defaultValue: '');
  static const String firebaseAppId =
      String.fromEnvironment('FIREBASE_APP_ID', defaultValue: '');

  // ─── APP CONFIG ─────────────────────────────────────────────────────────
  static const String appName = 'Arvind Party Admin';
  static const String appVersion = '1.0.0';
  static const int pageSize = 20;
  static const int requestTimeoutSeconds = 30;

  // ─── PRODUCTION BUILD COMMAND ───────────────────────────────────────────
  // flutter build web \
  //   --dart-define=BACKEND_URL=https://api.yourdomain.com/api \
  //   --dart-define=SOCKET_URL=https://api.yourdomain.com \
  //   --dart-define=FIREBASE_API_KEY=your_key \
  //   --dart-define=FIREBASE_AUTH_DOMAIN=your_domain \
  //   --dart-define=FIREBASE_PROJECT_ID=your_project \
  //   --dart-define=FIREBASE_STORAGE_BUCKET=your_bucket \
  //   --dart-define=FIREBASE_SENDER_ID=your_sender_id \
  //   --dart-define=FIREBASE_APP_ID=your_app_id
}
