// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/core/network/api_response.dart
// ARVIND PARTY - STANDARDIZED API RESPONSE WRAPPER
// ═══════════════════════════════════════════════════════════════════════════

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.message = '',
    this.data,
    this.statusCode = 200,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, {T Function(dynamic)? fromJsonT}) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : json['data'] as T?,
      statusCode: json['statusCode'] as int? ?? 200,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data,
    'statusCode': statusCode,
  };

  @override
  String toString() => 'ApiResponse(success: $success, message: $message, statusCode: $statusCode)';
}

class ApiListResponse<T> {
  final bool success;
  final String message;
  final List<T> data;
  final int total;
  final int page;
  final int totalPages;

  ApiListResponse({
    required this.success,
    this.message = '',
    this.data = const [],
    this.total = 0,
    this.page = 1,
    this.totalPages = 1,
  });

  factory ApiListResponse.fromJson(Map<String, dynamic> json, {required T Function(dynamic) fromJsonT}) {
    final List<dynamic> rawData = json['data'] as List<dynamic>? ?? [];
    return ApiListResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: rawData.map((e) => fromJsonT(e)).toList(),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}