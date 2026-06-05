class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type; // 'system', 'gift', 'follow', 'message'
  final DateTime timestamp;
  final bool isRead;
  final String? avatarUrl;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.avatarUrl,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      avatarUrl: avatarUrl,
    );
  }
}
