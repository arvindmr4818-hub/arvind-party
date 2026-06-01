class SeatModel {

  final int seatNumber;

  final String userName;

  final bool isLocked;

  final bool isMuted;

  final bool isHost;

  final bool isOccupied;

  SeatModel({
    required this.seatNumber,
    required this.userName,
    required this.isLocked,
    required this.isMuted,
    required this.isHost,
    required this.isOccupied,
  });
}
