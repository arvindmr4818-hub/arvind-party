// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/shared/models/session_model.dart
// ARVIND PARTY - USER SESSION MODEL
// Track active sessions and login history
// ═══════════════════════════════════════════════════════════════════════════

class SessionModel {
  final String id;
  final String userId;
  final String token;
  final String deviceId;
  final String deviceName;
  final String deviceType; // 'mobile', 'tablet', 'web'
  final String osVersion;
  final String appVersion;
  final String ipAddress;
  final String location;
  final DateTime loginTime;
  final DateTime? lastActivityTime;
  final DateTime? logoutTime;
  final bool isActive;
  final bool isSuspicious;
  final String? suspiciousReason;

  SessionModel({
    required this.id,
    required this.userId,
    required this.token,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.osVersion,
    required this.appVersion,
    required this.ipAddress,
    required this.location,
    required this.loginTime,
    this.lastActivityTime,
    this.logoutTime,
    this.isActive = true,
    this.isSuspicious = false,
    this.suspiciousReason,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      token: json['token'] ?? '',
      deviceId: json['deviceId'] ?? '',
      deviceName: json['deviceName'] ?? 'Unknown Device',
      deviceType: json['deviceType'] ?? 'mobile',
      osVersion: json['osVersion'] ?? 'Unknown',
      appVersion: json['appVersion'] ?? 'Unknown',
      ipAddress: json['ipAddress'] ?? 'Unknown',
      location: json['location'] ?? 'Unknown',
      loginTime: json['loginTime'] != null
          ? DateTime.parse(json['loginTime'].toString())
          : DateTime.now(),
      lastActivityTime: json['lastActivityTime'] != null
          ? DateTime.parse(json['lastActivityTime'].toString())
          : null,
      logoutTime: json['logoutTime'] != null
          ? DateTime.parse(json['logoutTime'].toString())
          : null,
      isActive: json['isActive'] ?? true,
      isSuspicious: json['isSuspicious'] ?? false,
      suspiciousReason: json['suspiciousReason'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'userId': userId,
    'token': token,
    'deviceId': deviceId,
    'deviceName': deviceName,
    'deviceType': deviceType,
    'osVersion': osVersion,
    'appVersion': appVersion,
    'ipAddress': ipAddress,
    'location': location,
    'loginTime': loginTime.toIso8601String(),
    'lastActivityTime': lastActivityTime?.toIso8601String(),
    'logoutTime': logoutTime?.toIso8601String(),
    'isActive': isActive,
    'isSuspicious': isSuspicious,
    'suspiciousReason': suspiciousReason,
  };

  SessionModel copyWith({
    String? id,
    String? userId,
    String? token,
    String? deviceId,
    String? deviceName,
    String? deviceType,
    String? osVersion,
    String? appVersion,
    String? ipAddress,
    String? location,
    DateTime? loginTime,
    DateTime? lastActivityTime,
    DateTime? logoutTime,
    bool? isActive,
    bool? isSuspicious,
    String? suspiciousReason,
  }) {
    return SessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      token: token ?? this.token,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      osVersion: osVersion ?? this.osVersion,
      appVersion: appVersion ?? this.appVersion,
      ipAddress: ipAddress ?? this.ipAddress,
      location: location ?? this.location,
      loginTime: loginTime ?? this.loginTime,
      lastActivityTime: lastActivityTime ?? this.lastActivityTime,
      logoutTime: logoutTime ?? this.logoutTime,
      isActive: isActive ?? this.isActive,
      isSuspicious: isSuspicious ?? this.isSuspicious,
      suspiciousReason: suspiciousReason ?? this.suspiciousReason,
    );
  }
}
