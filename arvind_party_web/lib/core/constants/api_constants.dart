// arvind_party_web/lib/core/constants/api_constants.dart
class ApiConstants {
  // Production mein apna server URL dalo
  static const String baseUrl    = 'http://localhost:5000';
  static const String apiBaseUrl = '$baseUrl/api';
  static const String socketUrl  = baseUrl;

  // Admin panel ke liye secret key (server se match honi chahiye)
  static const String adminKey   = 'arvind_admin_2024';
}
