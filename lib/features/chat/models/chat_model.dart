// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/chat/models/chat_model.dart
// ARVIND PARTY - CHAT MODELS (Chat, Message, Reaction)
// ═══════════════════════════════════════════════════════════════════════════

enum ChatType { room, private, group }
enum MessageType { text, sticker, emoji }

class ReactionModel {
  final String emoji;
  final List<String> userIds;

  ReactionModel({required this.emoji, this.userIds = const []});
  factory ReactionModel.fromJson(Map<String, dynamic> json) => ReactionModel(
    emoji: json['emoji'], userIds: List<String>.from(json['userIds'] ?? []),
  );
}

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final MessageType type;
  final String? text;
  final String? stickerUrl;
  final String? repliedToMessageId;
  final MessageModel? repliedToMessage; // populated locally
  final Map<String, ReactionModel> reactions; // emoji -> ReactionModel
  final bool isPinned;
  final bool isDeleted;
  final DateTime createdAt;
  final List<String> mentionedUserIds;

  MessageModel({
    required this.id, required this.chatId, required this.senderId, required this.senderName,
    this.senderAvatar, required this.type, this.text, this.stickerUrl,
    this.repliedToMessageId, this.repliedToMessage, this.reactions = const {},
    this.isPinned = false, this.isDeleted = false, required this.createdAt,
    this.mentionedUserIds = const [],
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    id: json['id'], chatId: json['chatId'], senderId: json['senderId'],
    senderName: json['senderName'], senderAvatar: json['senderAvatar'],
    type: MessageType.values.firstWhere((e) => e.name == json['type']),
    text: json['text'], stickerUrl: json['stickerUrl'],
    repliedToMessageId: json['repliedToMessageId'],
    reactions: (json['reactions'] as Map<String, dynamic>? ?? {})
        .map((key, value) => MapEntry(key, ReactionModel.fromJson(value))),
    isPinned: json['isPinned'] ?? false, isDeleted: json['isDeleted'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
    mentionedUserIds: List<String>.from(json['mentionedUserIds'] ?? []),
  );
}

class ChatModel {
  final String id;
  final ChatType type;
  final String? name; // Room name or Group name
  final List<String> participantIds;
  final MessageModel? lastMessage;

  ChatModel({
    required this.id, required this.type, this.name, required this.participantIds, this.lastMessage,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
    id: json['id'], type: ChatType.values.firstWhere((e) => e.name == json['type']),
    name: json['name'], participantIds: List<String>.from(json['participantIds'] ?? []),
    lastMessage: json['lastMessage'] != null ? MessageModel.fromJson(json['lastMessage']) : null,
  );
}