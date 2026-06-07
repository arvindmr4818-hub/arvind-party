// lib/shared/models/pk_battle_model.dart
class PkBattleModel {
  final String id;
  final String roomId;
  final String hostId;
  final String hostName;
  final String hostAvatar;
  final String? opponentId;
  final String? opponentName;
  final String? opponentAvatar;
  final int hostScore;
  final int opponentScore;
  final int duration; // seconds
  final String status; // 'waiting', 'live', 'ended'
  final String? winnerId;
  final DateTime startedAt;
  final DateTime? endedAt;

  PkBattleModel({
    required this.id,
    required this.roomId,
    required this.hostId,
    required this.hostName,
    required this.hostAvatar,
    this.opponentId,
    this.opponentName,
    this.opponentAvatar,
    required this.hostScore,
    required this.opponentScore,
    required this.duration,
    required this.status,
    this.winnerId,
    required this.startedAt,
    this.endedAt,
  });

  factory PkBattleModel.fromJson(Map<String, dynamic> json) {
    return PkBattleModel(
      id: json['id']?.toString() ?? '',
      roomId: json['roomId']?.toString() ?? '',
      hostId: json['hostId']?.toString() ?? '',
      hostName: json['hostName']?.toString() ?? '',
      hostAvatar: json['hostAvatar']?.toString() ?? '',
      opponentId: json['opponentId']?.toString(),
      opponentName: json['opponentName']?.toString(),
      opponentAvatar: json['opponentAvatar']?.toString(),
      hostScore: json['hostScore'] is int ? json['hostScore'] : int.tryParse(json['hostScore']?.toString() ?? '0') ?? 0,
      opponentScore: json['opponentScore'] is int ? json['opponentScore'] : int.tryParse(json['opponentScore']?.toString() ?? '0') ?? 0,
      duration: json['duration'] is int ? json['duration'] : int.tryParse(json['duration']?.toString() ?? '180') ?? 180,
      status: json['status']?.toString() ?? 'waiting',
      winnerId: json['winnerId']?.toString(),
      startedAt: DateTime.tryParse(json['startedAt']?.toString() ?? '') ?? DateTime.now(),
      endedAt: json['endedAt'] != null ? DateTime.tryParse(json['endedAt'].toString()) : null,
    );
  }
}
