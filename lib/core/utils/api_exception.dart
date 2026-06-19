// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/core/network/api_exception.dart
// ARVIND PARTY - CENTRALIZED API EXCEPTION HANDLING
// ═══════════════════════════════════════════════════════════════════════════

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errors;

  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  factory ApiException.fromDioError(dynamic error) {
    if (error is! Map) {
      return ApiException(message: 'Network error occurred');
    }
    return ApiException(
      message: error['message'] as String? ?? 'Unknown error',
      statusCode: error['statusCode'] as int?,
      errors: error['errors'],
    );
  }

  factory ApiException.unauthorized() => ApiException(
    message: 'Session expired. Please login again.',
    statusCode: 401,
  );

  factory ApiException.notFound(String resource) => ApiException(
    message: '$resource not found',
    statusCode: 404,
  );

  factory ApiException.serverError() => ApiException(
    message: 'Server error occurred. Please try again.',
    statusCode: 500,
  );

  factory ApiException.networkError() => ApiException(
    message: 'No internet connection',
    statusCode: 0,
  );

  factory ApiException.timeoutError() => ApiException(
    message: 'Request timed out',
    statusCode: 408,
  );

  factory ApiException.validationError(Map<String, dynamic> errors) => ApiException(
    message: 'Validation failed',
    statusCode: 422,
    errors: errors,
  );

  @override
  String toString() => 'ApiException(message: $message, statusCode: $statusCode)';
}