class MemberModel {

  final String id;

  final String name;

  final bool isHost;

  final bool isAdmin;

  final bool isMuted;

  final bool isOnSeat;

  MemberModel({
    required this.id,
    required this.name,
    required this.isHost,
    required this.isAdmin,
    required this.isMuted,
    required this.isOnSeat,
  });
}
