// ═══════════════════════════════════════════════════════════════════════════
// ARVIND PARTY — Environment Configuration
// Change devBaseUrl to your computer's IP when testing on phone
// ═══════════════════════════════════════════════════════════════════════════

class EnvConfig {
  EnvConfig._();

  // ─── Switch environment here ──────────────────────────────────────────
  static const bool isProduction = bool.fromEnvironment('IS_PRODUCTION', defaultValue: false);

  // ─── API Base URLs ────────────────────────────────────────────────────
  // Dev: your PC IP (run: ipconfig/ifconfig to find)
  static const String devBaseUrl = 'http://192.168.1.100:5000';
  static const String stagingBaseUrl = 'https://staging-api.arvindparty.com';
  static const String prodBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.arvindparty.com');

  static String get baseUrl => isProduction ? prodBaseUrl : devBaseUrl;
  static String get apiBaseUrl => '\$baseUrl/api';

  // ─── LiveKit ──────────────────────────────────────────────────────────
  static const String devLiveKitUrl = 'ws://192.168.1.100:7880';
  static const String prodLiveKitUrl = String.fromEnvironment('LIVEKIT_URL', defaultValue: 'wss://livekit.arvindparty.com');
  static String get liveKitUrl => isProduction ? prodLiveKitUrl : devLiveKitUrl;

  // ─── Socket.IO ────────────────────────────────────────────────────────
  static String get socketUrl => baseUrl;

  // ─── App Settings ─────────────────────────────────────────────────────
  static const String appName = 'Arvind Party';
  static const String appVersion = '1.0.0';
  static const int requestTimeoutSeconds = 30;
  static const int pageSize = 20;

  // ─── Feature Flags ────────────────────────────────────────────────────
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = isProduction;
  static const bool enableLogs = !isProduction;
}
