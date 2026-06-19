// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room/models/room_model.dart
// ARVIND PARTY - ROOM MODEL (10 Types, Voice, Seats, Permissions)
// ═══════════════════════════════════════════════════════════════════════════

// Enums for Room Features
enum RoomType { public, private, password, family, agency, event, pk, radio, temporary, permanent }

enum SeatStatus { empty, locked, reserved, occupied }

enum PermissionRole { owner, coOwner, admin, moderator, vip, member, guest }

enum VoiceEffect { none, reverb, echo, robot, pitchShift, deepVoice }

class RoomMember {
  final String userId;
  final String username;
  final String? avatarUrl;
  final PermissionRole role;
  final bool isMuted;
  final bool isSpeaker;
  final bool isEarMonitoring;

  RoomMember({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.role,
    this.isMuted = false,
    this.isSpeaker = false,
    this.isEarMonitoring = false,
  });

  factory RoomMember.fromJson(Map<String, dynamic> json) => RoomMember(
    userId: json['userId'], username: json['username'], avatarUrl: json['avatarUrl'],
    role: PermissionRole.values.firstWhere((e) => e.name == json['role']),
    isMuted: json['isMuted'] ?? false, isSpeaker: json['isSpeaker'] ?? false,
    isEarMonitoring: json['isEarMonitoring'] ?? false,
  );
}

class MicSeat {
  final String seatId;
  final int seatNumber;
  SeatStatus status;
  String? occupiedByUserId;
  bool isHostSeat;

  MicSeat({
    required this.seatId,
    required this.seatNumber,
    this.status = SeatStatus.empty,
    this.occupiedByUserId,
    this.isHostSeat = false,
  });

  factory MicSeat.fromJson(Map<String, dynamic> json) => MicSeat(
    seatId: json['seatId'], seatNumber: json['seatNumber'],
    status: SeatStatus.values.firstWhere((e) => e.name == json['status']),
    occupiedByUserId: json['occupiedByUserId'], isHostSeat: json['isHostSeat'] ?? false,
  );
}

class RoomSettings {
  String? backgroundUrl;
  String? themeColorHex;
  List<String> tags;
  String? notice;
  String? rules;
  bool isNoiseCancellationEnabled;
  bool isSpatialAudioEnabled;

  RoomSettings({
    this.backgroundUrl, this.themeColorHex, this.tags = const [],
    this.notice, this.rules, this.isNoiseCancellationEnabled = false,
    this.isSpatialAudioEnabled = false,
  });

  factory RoomSettings.fromJson(Map<String, dynamic> json) => RoomSettings(
    backgroundUrl: json['backgroundUrl'], themeColorHex: json['themeColorHex'],
    tags: List<String>.from(json['tags'] ?? []), notice: json['notice'],
    rules: json['rules'], isNoiseCancellationEnabled: json['noiseCancellation'] ?? false,
    isSpatialAudioEnabled: json['spatialAudio'] ?? false,
  );
}

class RoomModel {
  final String id;
  final String name;
  final String? description;
  final RoomType type;
  final String? password;
  final String hostId;
  final List<RoomMember> members;
  final List<MicSeat> seats;
  final RoomSettings settings;
  final DateTime createdAt;
  final bool isTemporary;

  RoomModel({
    required this.id, required this.name, this.description, required this.type,
    this.password, required this.hostId, this.members = const [], this.seats = const [],
    required this.settings, required this.createdAt, this.isTemporary = false,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) => RoomModel(
    id: json['id'], name: json['name'], description: json['description'],
    type: RoomType.values.firstWhere((e) => e.name == json['type']),
    password: json['password'], hostId: json['hostId'],
    members: (json['members'] as List).map((e) => RoomMember.fromJson(e)).toList(),
    seats: (json['seats'] as List).map((e) => MicSeat.fromJson(e)).toList(),
    settings: RoomSettings.fromJson(json['settings'] ?? {}),
    createdAt: DateTime.parse(json['createdAt']),
    isTemporary: json['isTemporary'] ?? false,
  );
}