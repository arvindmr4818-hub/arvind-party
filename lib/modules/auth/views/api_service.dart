import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ApiService extends GetxService {
  late Dio _dio;
  final GetStorage _storage = GetStorage();

  // Base URL Setup (Strict Connection to arvind_party_backend)
  // Emulator ke liye: http://10.0.2.2:3000/api/
  // Real Device / WiFi testing ke liye apne PC ka IP dalein e.g: http://192.168.1.5:3000/api/
  final String baseUrl = 'http://10.0.2.2:3000/api/';

  Future<ApiService> init() async {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
      },
    ));

    // Intercept requests to automatically add the Bearer token if logged in
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        String? token = _storage.read('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Global 401 Unauthorized Handling (Logout User if Token expires)
        if (e.response?.statusCode == 401) {
          clearToken();
          Get.offAllNamed('/login'); // Redirect to login
          Get.snackbar('Session Expired', 'Please login again.');
        }
        return handler.next(e);
      },
    ));

    return this;
  }

  // ==========================================
  // CORE HTTP METHODS
  // ==========================================
  Future post(String path, Map<String, dynamic> data) async {
    return await _dio.post(path, data: data);
  }

  Future get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  // ==========================================
  // SESSION MANAGEMENT
  // ==========================================
  void saveToken(String token) {
    _storage.write('token', token);
  }

  void clearToken() {
    _storage.remove('token');
  }

  bool get isLoggedIn => _storage.hasData('token');
}