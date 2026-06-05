// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/modules/room/models/seat_model.dart
// ═══════════════════════════════════════════════════════════════════════════

class SeatModel {
  final int seatNumber;
  final String? userId;
  final String? userName;
  final String? avatar;
  final bool isHost;
  final bool isCoHost;
  final bool isMuted;
  final bool isLocked;
  final bool isSpeaking;

  const SeatModel({
    required this.seatNumber,
    this.userId,
    this.userName,
    this.avatar,
    this.isHost = false,
    this.isCoHost = false,
    this.isMuted = false,
    this.isLocked = false,
    this.isSpeaking = false,
  });

  bool get isOccupied => userId != null;

  SeatModel copyWith({
    int? seatNumber,
    String? userId,
    String? userName,
    String? avatar,
    bool? isHost,
    bool? isCoHost,
    bool? isMuted,
    bool? isLocked,
    bool? isSpeaking,
    bool clearUser = false, // true hone par seat khali ho jaati hai
  }) {
    if (clearUser) {
      return SeatModel(
        seatNumber: seatNumber ?? this.seatNumber,
        isLocked: isLocked ?? this.isLocked,
        // baki sab reset
      );
    }
    return SeatModel(
      seatNumber: seatNumber ?? this.seatNumber,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      avatar: avatar ?? this.avatar,
      isHost: isHost ?? this.isHost,
      isCoHost: isCoHost ?? this.isCoHost,
      isMuted: isMuted ?? this.isMuted,
      isLocked: isLocked ?? this.isLocked,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }
}
