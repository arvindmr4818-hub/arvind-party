// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/shared/models/device_model.dart
// ARVIND PARTY - USER DEVICE MODEL
// Track and manage user devices for multi-device detection
// ═══════════════════════════════════════════════════════════════════════════

class DeviceModel {
  final String id;
  final String userId;
  final String deviceId;
  final String deviceName;
  final String deviceType; // 'mobile', 'tablet', 'web'
  final String osType; // 'android', 'ios', 'windows', 'linux', 'web'
  final String osVersion;
  final String appVersion;
  final String deviceFingerprint;
  final DateTime addedAt;
  final DateTime? lastUsedAt;
  final bool isActive;
  final bool isVerified;
  final bool isTrusted;
  final String? lastIpAddress;
  final String? lastLocation;
  final String? pushToken;
  final Map<String, dynamic>? metadata;

  DeviceModel({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.osType,
    required this.osVersion,
    required this.appVersion,
    required this.deviceFingerprint,
    required this.addedAt,
    this.lastUsedAt,
    this.isActive = true,
    this.isVerified = true,
    this.isTrusted = false,
    this.lastIpAddress,
    this.lastLocation,
    this.pushToken,
    this.metadata,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      deviceId: json['deviceId'] ?? '',
      deviceName: json['deviceName'] ?? 'Unknown Device',
      deviceType: json['deviceType'] ?? 'mobile',
      osType: json['osType'] ?? 'android',
      osVersion: json['osVersion'] ?? 'Unknown',
      appVersion: json['appVersion'] ?? 'Unknown',
      deviceFingerprint: json['deviceFingerprint'] ?? '',
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'].toString())
          : DateTime.now(),
      lastUsedAt: json['lastUsedAt'] != null
          ? DateTime.parse(json['lastUsedAt'].toString())
          : null,
      isActive: json['isActive'] ?? true,
      isVerified: json['isVerified'] ?? true,
      isTrusted: json['isTrusted'] ?? false,
      lastIpAddress: json['lastIpAddress'],
      lastLocation: json['lastLocation'],
      pushToken: json['pushToken'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'userId': userId,
    'deviceId': deviceId,
    'deviceName': deviceName,
    'deviceType': deviceType,
    'osType': osType,
    'osVersion': osVersion,
    'appVersion': appVersion,
    'deviceFingerprint': deviceFingerprint,
    'addedAt': addedAt.toIso8601String(),
    'lastUsedAt': lastUsedAt?.toIso8601String(),
    'isActive': isActive,
    'isVerified': isVerified,
    'isTrusted': isTrusted,
    'lastIpAddress': lastIpAddress,
    'lastLocation': lastLocation,
    'pushToken': pushToken,
    'metadata': metadata,
  };

  DeviceModel copyWith({
    String? id,
    String? userId,
    String? deviceId,
    String? deviceName,
    String? deviceType,
    String? osType,
    String? osVersion,
    String? appVersion,
    String? deviceFingerprint,
    DateTime? addedAt,
    DateTime? lastUsedAt,
    bool? isActive,
    bool? isVerified,
    bool? isTrusted,
    String? lastIpAddress,
    String? lastLocation,
    String? pushToken,
    Map<String, dynamic>? metadata,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      osType: osType ?? this.osType,
      osVersion: osVersion ?? this.osVersion,
      appVersion: appVersion ?? this.appVersion,
      deviceFingerprint: deviceFingerprint ?? this.deviceFingerprint,
      addedAt: addedAt ?? this.addedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      isTrusted: isTrusted ?? this.isTrusted,
      lastIpAddress: lastIpAddress ?? this.lastIpAddress,
      lastLocation: lastLocation ?? this.lastLocation,
      pushToken: pushToken ?? this.pushToken,
      metadata: metadata ?? this.metadata,
    );
  }
}
