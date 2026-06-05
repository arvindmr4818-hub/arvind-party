enum FamilyEventStatus { upcoming, live, completed }

class FamilyEventModel {
  final String eventId;
  final String familyId;
  final String title;
  final String description;
  final String banner;
  final DateTime scheduledTime;
  final String targetRoomId; // Room coordinate where event takes place
  final FamilyEventStatus status;
  final int attendeesCount;

  const FamilyEventModel({
    required this.eventId,
    required this.familyId,
    required this.title,
    required this.description,
    required this.banner,
    required this.scheduledTime,
    required this.targetRoomId,
    required this.status,
    this.attendeesCount = 0,
  });

  factory FamilyEventModel.fromJson(Map<String, dynamic> json) {
    return FamilyEventModel(
      eventId: json['_id'] ?? json['eventId'] ?? '',
      familyId: json['familyId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      banner: json['banner'] ?? '',
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.parse(json['scheduledTime'])
          : DateTime.now(),
      targetRoomId: json['targetRoomId'] ?? '',
      status: FamilyEventStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => FamilyEventStatus.upcoming,
      ),
      attendeesCount: json['attendeesCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'familyId': familyId,
      'title': title,
      'description': description,
      'banner': banner,
      'scheduledTime': scheduledTime.toIso8601String(),
      'targetRoomId': targetRoomId,
      'status': status.toString().split('.').last,
      'attendeesCount': attendeesCount,
    };
  }

  FamilyEventModel copyWith({
    String? eventId,
    String? familyId,
    String? title,
    String? description,
    String? banner,
    DateTime? scheduledTime,
    String? targetRoomId,
    FamilyEventStatus? status,
    int? attendeesCount,
  }) {
    return FamilyEventModel(
      eventId: eventId ?? this.eventId,
      familyId: familyId ?? this.familyId,
      title: title ?? this.title,
      description: description ?? this.description,
      banner: banner ?? this.banner,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      targetRoomId: targetRoomId ?? this.targetRoomId,
      status: status ?? this.status,
      attendeesCount: attendeesCount ?? this.attendeesCount,
    );
  }
}
