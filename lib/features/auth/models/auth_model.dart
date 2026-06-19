// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/auth/models/auth_model.dart
// ARVIND PARTY - AUTH MODELS (User & AuthResponse)
// MATCHES BACKEND RESPONSE: { success, message, data: { token, refreshToken, user: { _id, phone, name, avatar, arvindId, level, ... } } }
// ═══════════════════════════════════════════════════════════════════════════

class User {
  final String id;
  final String username;
  final String email;
  final String? profileImage;
  final String? bio;
  final String vipTier;
  final DateTime? vipExpiryDate;
  final List<String> followers;
  final List<String> following;
  final bool isVerified;
  final bool isBlocked;
  final DateTime createdAt;

  // Backend-specific fields
  final String? phone;
  final String? name;
  final String? avatar;
  final String? arvindId;
  final int level;
  final int xp;
  final int coins;
  final int diamonds;
  final bool isProfileComplete;
  final String? gender;
  final DateTime? dob;

  User({
    required this.id,
    this.username = '',
    this.email = '',
    this.profileImage,
    this.bio,
    this.vipTier = 'free',
    this.vipExpiryDate,
    this.followers = const [],
    this.following = const [],
    this.isVerified = false,
    this.isBlocked = false,
    required this.createdAt,
    this.phone,
    this.name,
    this.avatar,
    this.arvindId,
    this.level = 1,
    this.xp = 0,
    this.coins = 0,
    this.diamonds = 0,
    this.isProfileComplete = false,
    this.gender,
    this.dob,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profileImage'] ?? json['avatar'],
      bio: json['bio'],
      vipTier: json['vipTier'] ?? 'free',
      vipExpiryDate: json['vipExpiryDate'] != null
          ? DateTime.parse(json['vipExpiryDate'])
          : null,
      followers: List<String>.from(json['followers'] ?? []),
      following: List<String>.from(json['following'] ?? []),
      isVerified: json['isVerified'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      phone: json['phone'],
      name: json['name'],
      avatar: json['avatar'],
      arvindId: json['arvindId'],
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      coins: json['coins'] ?? 0,
      diamonds: json['diamonds'] ?? 0,
      isProfileComplete: json['isProfileComplete'] ?? false,
      gender: json['gender'],
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
    );
  }

  /// Parse from backend response data wrapper: { success, data: { token, refreshToken, user: { _id, phone, name, ... } } }
  factory User.fromBackendJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? json['userId'] ?? '',
      username: json['username'] ?? json['name'] ?? 'User ${(json['phone'] ?? '').toString().slice(-4)}',
      email: json['email'] ?? '',
      profileImage: json['profileImage'] ?? json['avatar'],
      bio: json['bio'],
      vipTier: json['vipTier'] ?? 'free',
      vipExpiryDate: json['vipExpiryDate'] != null
          ? DateTime.parse(json['vipExpiryDate'])
          : null,
      followers: List<String>.from(json['followers'] ?? []),
      following: List<String>.from(json['following'] ?? []),
      isVerified: json['isVerified'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      phone: json['phone'],
      name: json['name'],
      avatar: json['avatar'],
      arvindId: json['arvindId'],
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      coins: json['coins'] ?? 0,
      diamonds: json['diamonds'] ?? 0,
      isProfileComplete: json['isProfileComplete'] ?? false,
      gender: json['gender'],
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profileImage': profileImage,
      'bio': bio,
      'vipTier': vipTier,
      'followers': followers,
      'following': following,
    };
  }
}

class AuthResponse {
  final bool success;
  final String message;
  final String token;
  final String? refreshToken;
  final User user;
  final bool isNewUser;

  AuthResponse({
    required this.success,
    required this.message,
    required this.token,
    this.refreshToken,
    required this.user,
    this.isNewUser = false,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'] ?? '',
      refreshToken: json['refreshToken'],
      user: User.fromJson(json['user'] ?? {}),
      isNewUser: json['isNewUser'] ?? false,
    );
  }

  /// Parse from backend response: { success, message, data: { token, refreshToken, user: { ... } } }
  factory AuthResponse.fromBackendJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: data['token'] ?? '',
      refreshToken: data['refreshToken'],
      user: User.fromBackendJson(data['user'] ?? data['data'] ?? {}),
      isNewUser: data['user']?['isNewUser'] ?? false,
    );
  }
}

// Extension to safely get last N chars from string
extension _StringSlice on String {
  String slice(int start, [int? end]) {
    if (start < 0) start = length + start;
    end ??= length;
    return substring(start, end);
  }
}