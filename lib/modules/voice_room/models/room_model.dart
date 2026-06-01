class RoomModel {
  final String id;
  final String roomName;
  final String ownerName;
  final int onlineUsers;

  RoomModel({
    required this.id,
    required this.roomName,
    required this.ownerName,
    required this.onlineUsers,
  });
}
