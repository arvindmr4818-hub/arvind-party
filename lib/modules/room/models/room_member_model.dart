// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/modules/room/models/room_member_model.dart
//
// UNIFIED ROOM MEMBER MODEL
// Yeh file room/models/ aur room/members/models/ dono ki jagah leti hai.
// Duplicate room_member_model.dart files delete karo.
// ═══════════════════════════════════════════════════════════════════════════

// ─── ROLE ENUM ───────────────────────────────────────────────────────────────
// Owner/Host → Label badhne par Admin count bhi badhega (8 → 10 → 15 → 20)
enum MemberRole {
  owner, // Room banane wala - sabse upar
  host, // Owner ki tarah, owner ne assign kiya
  coHost, // Host controls - mute/kick/seat manage
  admin, // Label-based admin - count owner ke label se badh/ghat sakta hai
  member, // Normal logged-in user
  visitor, // Guest / non-registered viewer
}

// ─── HELPER EXTENSION ────────────────────────────────────────────────────────
extension MemberRoleExtension on MemberRole {
  String get label {
    switch (this) {
      case MemberRole.owner:
        return 'Owner';
      case MemberRole.host:
        return 'Host';
      case MemberRole.coHost:
        return 'Co-Host';
      case MemberRole.admin:
        return 'Admin';
      case MemberRole.member:
        return 'Member';
      case MemberRole.visitor:
        return 'Visitor';
    }
  }

  // Kya yeh role admin-level actions kar sakta hai?
  bool get isAdminLevel =>
      this == MemberRole.owner ||
      this == MemberRole.host ||
      this == MemberRole.coHost ||
      this == MemberRole.admin;

  // Can this role be promoted/demoted by owner?
  bool get isPromotable =>
      this == MemberRole.member || this == MemberRole.visitor;
}

// ─── MODEL ───────────────────────────────────────────────────────────────────
class RoomMemberModel {
  final String id;
  final String name;
  final String avatar;
  final MemberRole role;
  final bool isMuted;
  final bool isBlocked;
  final bool isOnMic; // Kya woh currently mic seat par hai
  final bool isOnline;
  final int userLevel;
  final String? familyTag;
  final double contribution; // Gift contribution in room
  final DateTime? joinedAt;

  const RoomMemberModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.role,
    this.isMuted = false,
    this.isBlocked = false,
    this.isOnMic = false,
    this.isOnline = true,
    this.userLevel = 1,
    this.familyTag,
    this.contribution = 0.0,
    this.joinedAt,
  });

  factory RoomMemberModel.fromJson(Map<String, dynamic> json) {
    return RoomMemberModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      role: MemberRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => MemberRole.member,
      ),
      isMuted: json['isMuted'] as bool? ?? false,
      isBlocked: json['isBlocked'] as bool? ?? false,
      isOnMic: json['isOnMic'] as bool? ?? false,
      isOnline: json['isOnline'] as bool? ?? true,
      userLevel: json['userLevel'] as int? ?? 1,
      familyTag: json['familyTag']?.toString(),
      contribution: (json['contribution'] as num?)?.toDouble() ?? 0.0,
      joinedAt: json['joinedAt'] != null
          ? DateTime.tryParse(json['joinedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar': avatar,
        'role': role.toString().split('.').last,
        'isMuted': isMuted,
        'isBlocked': isBlocked,
        'isOnMic': isOnMic,
        'isOnline': isOnline,
        'userLevel': userLevel,
        'familyTag': familyTag,
        'contribution': contribution,
        'joinedAt': joinedAt?.toIso8601String(),
      };

  RoomMemberModel copyWith({
    String? id,
    String? name,
    String? avatar,
    MemberRole? role,
    bool? isMuted,
    bool? isBlocked,
    bool? isOnMic,
    bool? isOnline,
    int? userLevel,
    String? familyTag,
    double? contribution,
    DateTime? joinedAt,
  }) {
    return RoomMemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      isMuted: isMuted ?? this.isMuted,
      isBlocked: isBlocked ?? this.isBlocked,
      isOnMic: isOnMic ?? this.isOnMic,
      isOnline: isOnline ?? this.isOnline,
      userLevel: userLevel ?? this.userLevel,
      familyTag: familyTag ?? this.familyTag,
      contribution: contribution ?? this.contribution,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
