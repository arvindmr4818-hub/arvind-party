class AgencyEventModel {
  final String eventId;
  final String agencyId;
  final String title;
  final String description;
  final String prizePoolDetails;
  final DateTime startTime;
  final DateTime endTime;
  final int participatingHostsCount;
  final double cumulativeEventPoints;

  const AgencyEventModel({
    required this.eventId,
    required this.agencyId,
    required this.title,
    required this.description,
    required this.prizePoolDetails,
    required this.startTime,
    required this.endTime,
    this.participatingHostsCount = 0,
    this.cumulativeEventPoints = 0.0,
  });

  factory AgencyEventModel.fromJson(Map<String, dynamic> json) {
    return AgencyEventModel(
      eventId: json['_id'] ?? json['eventId'] ?? '',
      agencyId: json['agencyId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      prizePoolDetails: json['prizePoolDetails'] ?? '',
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : DateTime.now(),
      participatingHostsCount: json['participatingHostsCount'] ?? 0,
      cumulativeEventPoints: (json['cumulativeEventPoints'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'agencyId': agencyId,
      'title': title,
      'description': description,
      'prizePoolDetails': prizePoolDetails,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'participatingHostsCount': participatingHostsCount,
      'cumulativeEventPoints': cumulativeEventPoints,
    };
  }
}
