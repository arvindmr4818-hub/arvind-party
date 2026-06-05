class AgencyModel {
  final String id;
  final String name;
  final String logo;
  final String banner;
  final int level;
  final int totalHosts;
  final double monthlyRevenue;
  final double lifetimeRevenue;
  final String ownerId;
  final String ownerName;
  final bool isOpenForRecruitment;
  final String paymentTerms;

  const AgencyModel({
    required this.id,
    required this.name,
    required this.logo,
    required this.banner,
    required this.level,
    required this.totalHosts,
    required this.monthlyRevenue,
    required this.lifetimeRevenue,
    required this.ownerId,
    required this.ownerName,
    this.isOpenForRecruitment = true,
    this.paymentTerms = "Default Net-30 Platform Settlement Rule",
  });

  factory AgencyModel.fromJson(Map<String, dynamic> json) {
    return AgencyModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
      banner: json['banner'] ?? '',
      level: json['level'] ?? 1,
      totalHosts: json['totalHosts'] ?? 0,
      monthlyRevenue: (json['monthlyRevenue'] ?? 0.0).toDouble(),
      lifetimeRevenue: (json['lifetimeRevenue'] ?? 0.0).toDouble(),
      ownerId: json['ownerId'] ?? '',
      ownerName: json['ownerName'] ?? '',
      isOpenForRecruitment: json['isOpenForRecruitment'] ?? true,
      paymentTerms:
          json['paymentTerms'] ?? "Default Net-30 Platform Settlement Rule",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'banner': banner,
      'level': level,
      'totalHosts': totalHosts,
      'monthlyRevenue': monthlyRevenue,
      'lifetimeRevenue': lifetimeRevenue,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'isOpenForRecruitment': isOpenForRecruitment,
      'paymentTerms': paymentTerms,
    };
  }

  AgencyModel copyWith({
    String? id,
    String? name,
    String? logo,
    String? banner,
    int? level,
    int? totalHosts,
    double? monthlyRevenue,
    double? lifetimeRevenue,
    String? ownerId,
    String? ownerName,
    bool? isOpenForRecruitment,
    String? paymentTerms,
  }) {
    return AgencyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      banner: banner ?? this.banner,
      level: level ?? this.level,
      totalHosts: totalHosts ?? this.totalHosts,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      lifetimeRevenue: lifetimeRevenue ?? this.lifetimeRevenue,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      isOpenForRecruitment: isOpenForRecruitment ?? this.isOpenForRecruitment,
      paymentTerms: paymentTerms ?? this.paymentTerms,
    );
  }
}
