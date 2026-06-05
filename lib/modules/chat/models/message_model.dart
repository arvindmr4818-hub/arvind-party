class MessageModel {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String message;
  final String messageType;
  final DateTime? createdAt;

  MessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.messageType,
    this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] ?? '',
      roomId: json['roomId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      message: json['message'] ?? '',
      messageType: json['messageType'] ?? 'text',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'roomId': roomId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'messageType': messageType,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
