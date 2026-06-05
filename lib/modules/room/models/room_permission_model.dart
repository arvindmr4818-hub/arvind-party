// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/modules/room/models/room_permission_model.dart
// ═══════════════════════════════════════════════════════════════════════════

class RoomPermissionModel {
  final bool muteUsers;
  final bool kickUsers;
  final bool banUsers;
  final bool inviteMic; // Kisi ko mic par invite kar sakta hai
  final bool manageSeats; // Seat lock/unlock
  final bool manageChat; // Chat delete/slow mode
  final bool manageAnnouncement;
  final bool
      manageAdmins; // Naye admin add/remove kar sakta hai (only owner/host ke paas)

  const RoomPermissionModel({
    this.muteUsers = false,
    this.kickUsers = false,
    this.banUsers = false,
    this.inviteMic = false,
    this.manageSeats = false,
    this.manageChat = false,
    this.manageAnnouncement = false,
    this.manageAdmins = false,
  });

  // Role-based presets
  factory RoomPermissionModel.forRole(String role) {
    switch (role) {
      case 'owner':
        return const RoomPermissionModel(
          muteUsers: true,
          kickUsers: true,
          banUsers: true,
          inviteMic: true,
          manageSeats: true,
          manageChat: true,
          manageAnnouncement: true,
          manageAdmins: true,
        );
      case 'host':
        return const RoomPermissionModel(
          muteUsers: true,
          kickUsers: true,
          banUsers: true,
          inviteMic: true,
          manageSeats: true,
          manageChat: true,
          manageAnnouncement: true,
          manageAdmins: true,
        );
      case 'coHost':
        return const RoomPermissionModel(
          muteUsers: true,
          kickUsers: true,
          inviteMic: true,
          manageSeats: true,
          manageChat: true,
          manageAnnouncement: true,
        );
      case 'admin':
        return const RoomPermissionModel(
          muteUsers: true,
          kickUsers: true,
          manageChat: true,
        );
      default:
        return const RoomPermissionModel();
    }
  }

  RoomPermissionModel copyWith({
    bool? muteUsers,
    bool? kickUsers,
    bool? banUsers,
    bool? inviteMic,
    bool? manageSeats,
    bool? manageChat,
    bool? manageAnnouncement,
    bool? manageAdmins,
  }) {
    return RoomPermissionModel(
      muteUsers: muteUsers ?? this.muteUsers,
      kickUsers: kickUsers ?? this.kickUsers,
      banUsers: banUsers ?? this.banUsers,
      inviteMic: inviteMic ?? this.inviteMic,
      manageSeats: manageSeats ?? this.manageSeats,
      manageChat: manageChat ?? this.manageChat,
      manageAnnouncement: manageAnnouncement ?? this.manageAnnouncement,
      manageAdmins: manageAdmins ?? this.manageAdmins,
    );
  }

  factory RoomPermissionModel.fromJson(Map<String, dynamic> json) {
    return RoomPermissionModel(
      muteUsers: json['muteUsers'] as bool? ?? false,
      kickUsers: json['kickUsers'] as bool? ?? false,
      banUsers: json['banUsers'] as bool? ?? false,
      inviteMic: json['inviteMic'] as bool? ?? false,
      manageSeats: json['manageSeats'] as bool? ?? false,
      manageChat: json['manageChat'] as bool? ?? false,
      manageAnnouncement: json['manageAnnouncement'] as bool? ?? false,
      manageAdmins: json['manageAdmins'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'muteUsers': muteUsers,
        'kickUsers': kickUsers,
        'banUsers': banUsers,
        'inviteMic': inviteMic,
        'manageSeats': manageSeats,
        'manageChat': manageChat,
        'manageAnnouncement': manageAnnouncement,
        'manageAdmins': manageAdmins,
      };
}
