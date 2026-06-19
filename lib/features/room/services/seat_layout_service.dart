// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room/services/seat_layout_service.dart
// ARVIND PARTY - SEAT LAYOUT SERVICE
// ═══════════════════════════════════════════════════════════════════════════

import '../models/room_models.dart';

class SeatLayoutService {
  static const List<int> availableSeatCounts = [6, 8, 10, 12, 15, 20, 25, 30];

  static List<SeatModel> generateInitialSeats(int count) {
    return List.generate(
      count,
      (i) => SeatModel(index: i, isOccupied: false, isLocked: false),
    );
  }

  static bool canAssignSeat(SeatModel seat, MemberRole role) {
    if (seat.isOccupied) return false;
    if (seat.isLocked && role != MemberRole.host) return false;
    return true;
  }
}
