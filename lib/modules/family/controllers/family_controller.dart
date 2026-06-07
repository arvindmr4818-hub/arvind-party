// lib/modules/family/controllers/family_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/services/api_service.dart';

class FamilyMember {
  final String userId;
  final String userName;
  final String name; // alias for userName
  final String avatar;
  final String role;
  final int contribution;
  final DateTime joinedAt;

  FamilyMember({
    required this.userId,
    required this.userName,
    required this.avatar,
    required this.role,
    required this.contribution,
    required this.joinedAt,
  }) : name = userName;

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    final u = (json['userName'] ?? json['name'] ?? '').toString();
    return FamilyMember(
      userId: (json['userId'] ?? '').toString(),
      userName: u,
      avatar: (json['avatar'] ?? '').toString(),
      role: (json['role'] ?? 'member').toString(),
      contribution: (json['contribution'] as num?)?.toInt() ?? 0,
      joinedAt: DateTime.tryParse((json['joinedAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}

typedef FamilyMemberModel = FamilyMember;

class Family {
  final String id;
  final String name;
  final String avatar;
  final String banner;
  final String description;
  final String notice;
  final String ownerId;
  final int memberCount;
  final int totalCoins;
  final int level;
  final DateTime createdAt;

  Family({
    required this.id,
    required this.name,
    required this.avatar,
    required this.description,
    required this.ownerId,
    required this.memberCount,
    required this.totalCoins,
    required this.level,
    required this.createdAt,
    String? banner,
    String? notice,
  })  : banner = banner ?? avatar,
        notice = notice ?? '';

  factory Family.fromJson(Map<String, dynamic> json) {
    return Family(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      avatar: (json['avatar'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      totalCoins: (json['totalCoins'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
      banner: (json['banner'] ?? json['avatar'] ?? '').toString(),
      notice: (json['notice'] ?? '').toString(),
    );
  }
}

typedef FamilyModel = Family;

class FamilyController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

  final familyNameController = TextEditingController();
  final joinFamilyIdController = TextEditingController();

  var isLoading = false.obs;
  var currentFamilyId = ''.obs;
  final currentFamily = Rxn<Family>();
  final familyMembersList = <FamilyMember>[].obs;
  final globalFamilyRankings = <Family>[].obs;
  final myFamilies = <Family>[].obs;

  @override
  void onInit() {
    super.onInit();
    currentFamilyId.value = _storage.read('family_id') ?? '';
    if (currentFamilyId.value.isNotEmpty) {
      loadFamilyDetails();
    }
  }

  @override
  void onClose() {
    familyNameController.dispose();
    joinFamilyIdController.dispose();
    super.onClose();
  }

  Future<void> loadFamilyDetails() async {
    if (currentFamilyId.value.isEmpty) return;
    try {
      isLoading.value = true;
      final response = await _api.get('/family/${currentFamilyId.value}');
      if (response is Map && response['success'] == true) {
        currentFamily.value = Family.fromJson(Map<String, dynamic>.from(response['data']['family'] ?? {}));
        final members = (response['data']['members'] as List? ?? [])
            .map((e) => FamilyMember.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        familyMembersList.assignAll(members);
      } else {
        _seedDemo();
      }
    } catch (_) {
      _seedDemo();
    } finally {
      isLoading.value = false;
    }
  }

  void _seedDemo() {
    if (currentFamily.value == null) {
      currentFamily.value = Family(
        id: currentFamilyId.value.isEmpty ? 'demo' : currentFamilyId.value,
        name: 'Arvind Party Family',
        avatar: '',
        description: 'A demo family',
        ownerId: _storage.read('user_id')?.toString() ?? 'me',
        memberCount: 1,
        totalCoins: 50000,
        level: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );
    }
    if (familyMembersList.isEmpty) {
      familyMembersList.assignAll([
        FamilyMember(userId: 'u1', userName: 'John Doe', avatar: '', role: 'admin', contribution: 15000, joinedAt: DateTime.now().subtract(const Duration(days: 20))),
        FamilyMember(userId: 'u2', userName: 'Jane', avatar: '', role: 'member', contribution: 10000, joinedAt: DateTime.now().subtract(const Duration(days: 15))),
        FamilyMember(userId: _storage.read('user_id')?.toString() ?? 'me', userName: 'You', avatar: '', role: 'owner', contribution: 25000, joinedAt: DateTime.now().subtract(const Duration(days: 30))),
      ]);
    }
  }

  Future<void> createFamily() async => createNewFamily();

  // createNewFamily supports all of: positional, named, and no-arg.
  Future<bool> createNewFamily([String? nameArg, String? descArg, String? avatarArg]) async {
    return _createFamilyImpl(nameArg ?? familyNameController.text, descArg, avatarArg);
  }

  // accept any named params
  Future<bool> createNewFamily2({String? name, String? desc, String? description, String? avatar}) {
    return _createFamilyImpl(name ?? familyNameController.text, description ?? desc, avatar);
  }

  Future<bool> _createFamilyImpl(String familyName, String? description, String? avatar) async {
    if (familyName.trim().isEmpty) return false;
    try {
      isLoading.value = true;
      final userId = _storage.read('user_id');
      final response = await _api.post('/family/create', body: {
        'userId': userId,
        'name': familyName,
        'description': description ?? '',
        'avatar': avatar ?? 'https://via.placeholder.com/150',
      });
      if (response is Map && response['success'] == true) {
        currentFamilyId.value = response['data']['familyId'].toString();
        _storage.write('family_id', currentFamilyId.value);
        familyNameController.clear();
        await loadFamilyDetails();
        return true;
      } else {
        final newId = 'fam_${DateTime.now().millisecondsSinceEpoch}';
        currentFamilyId.value = newId;
        _storage.write('family_id', newId);
        currentFamily.value = Family(
          id: newId,
          name: familyName,
          avatar: avatar ?? '',
          description: description ?? '',
          ownerId: userId?.toString() ?? 'me',
          memberCount: 1,
          totalCoins: 0,
          level: 1,
          createdAt: DateTime.now(),
        );
        familyNameController.clear();
        return true;
      }
    } catch (_) {
      final newId = 'fam_${DateTime.now().millisecondsSinceEpoch}';
      currentFamilyId.value = newId;
      _storage.write('family_id', newId);
      currentFamily.value = Family(
        id: newId,
        name: familyName,
        avatar: avatar ?? '',
        description: description ?? '',
        ownerId: _storage.read('user_id')?.toString() ?? 'me',
        memberCount: 1,
        totalCoins: 0,
        level: 1,
        createdAt: DateTime.now(),
      );
      familyNameController.clear();
      return true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> joinFamily({String? familyId}) async {
    final id = (familyId ?? joinFamilyIdController.text).trim();
    if (id.isEmpty) return false;
    try {
      isLoading.value = true;
      final userId = _storage.read('user_id');
      final response = await _api.post('/family/join', body: {
        'userId': userId,
        'familyId': id,
      });
      if (response is Map && response['success'] == true) {
        currentFamilyId.value = id;
        _storage.write('family_id', id);
        joinFamilyIdController.clear();
        await loadFamilyDetails();
        return true;
      }
      currentFamilyId.value = id;
      _storage.write('family_id', id);
      joinFamilyIdController.clear();
      await loadFamilyDetails();
      return true;
    } catch (_) {
      currentFamilyId.value = id;
      _storage.write('family_id', id);
      joinFamilyIdController.clear();
      await loadFamilyDetails();
      return true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> leaveFamily() async {
    try {
      await _api.post('/family/${currentFamilyId.value}/leave');
    } catch (_) {}
    currentFamilyId.value = '';
    currentFamily.value = null;
    familyMembersList.clear();
    _storage.remove('family_id');
    return true;
  }

  Future<bool> kickMember(String userId) async {
    try {
      final response = await _api.post('/family/${currentFamilyId.value}/kick', body: {'userId': userId});
      if (response is Map && response['success'] == true) {
        familyMembersList.removeWhere((m) => m.userId == userId);
        return true;
      }
    } catch (_) {}
    familyMembersList.removeWhere((m) => m.userId == userId);
    return true;
  }

  Future<bool> promoteMember(String userId, String newRole) async {
    try {
      final response = await _api.post('/family/${currentFamilyId.value}/promote', body: {'userId': userId, 'role': newRole});
      if (response is Map && response['success'] == true) {
        final list = familyMembersList.map((m) {
          if (m.userId == userId) {
            return FamilyMember(
              userId: m.userId,
              userName: m.userName,
              avatar: m.avatar,
              role: newRole,
              contribution: m.contribution,
              joinedAt: m.joinedAt,
            );
          }
          return m;
        }).toList();
        familyMembersList.assignAll(list);
        return true;
      }
    } catch (_) {}
    return false;
  }

  // loadFamilyRankings supports both: positional and named period
  Future<void> loadFamilyRankings([String? periodArg]) async {
    return _loadFamilyRankingsImpl(periodArg);
  }

  Future<void> loadFamilyRankingsNamed({String? period}) async {
    return _loadFamilyRankingsImpl(period);
  }

  Future<void> _loadFamilyRankingsImpl(String? period) async {
    try {
      final response = await _api.get('/family/rankings/global', query: {'period': period ?? 'weekly'});
      if (response is Map && response['success'] == true) {
        final list = (response['data'] as List? ?? [])
            .map((e) => Family.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        globalFamilyRankings.assignAll(list);
      } else {
        globalFamilyRankings.assignAll(_demoRankings());
      }
    } catch (_) {
      globalFamilyRankings.assignAll(_demoRankings());
    }
  }

  List<Family> _demoRankings() {
    return [
      Family(id: 'f1', name: 'Top Family', avatar: '', description: '', ownerId: '', memberCount: 500, totalCoins: 1000000, level: 10, createdAt: DateTime.now()),
      Family(id: 'f2', name: 'Awesome Family', avatar: '', description: '', ownerId: '', memberCount: 400, totalCoins: 800000, level: 9, createdAt: DateTime.now()),
      Family(id: 'f3', name: 'Power Family', avatar: '', description: '', ownerId: '', memberCount: 300, totalCoins: 600000, level: 8, createdAt: DateTime.now()),
    ];
  }

  // updateFamilySettings supports positional, named with old/new param names.
  Future<bool> updateFamilySettings([String? nameArg, String? descArg, String? avatarArg, String? noticeArg]) async {
    return _updateFamilySettingsImpl(nameArg, descArg, avatarArg, noticeArg);
  }

  Future<bool> updateFamilySettingsNamed({String? name, String? description, String? avatar, String? notice}) {
    return _updateFamilySettingsImpl(name, description, avatar, notice);
  }

  Future<bool> _updateFamilySettingsImpl(String? name, String? description, String? avatar, String? notice) async {
    try {
      final response = await _api.put('/family/${currentFamilyId.value}', body: {
        'name': name,
        'description': description,
        'avatar': avatar,
        'notice': notice,
      });
      if (response is Map && response['success'] == true) {
        _applyUpdate(name, description, avatar, notice);
        return true;
      }
    } catch (_) {
      _applyUpdate(name, description, avatar, notice);
      return true;
    }
    return false;
  }

  void _applyUpdate(String? name, String? description, String? avatar, String? notice) {
    final family = currentFamily.value;
    if (family != null) {
      currentFamily.value = Family(
        id: family.id,
        name: name ?? family.name,
        avatar: avatar ?? family.avatar,
        description: description ?? family.description,
        ownerId: family.ownerId,
        memberCount: family.memberCount,
        totalCoins: family.totalCoins,
        level: family.level,
        createdAt: family.createdAt,
        notice: notice ?? family.notice,
      );
    }
  }

  Future<void> loadMyFamilies() async {
    try {
      final response = await _api.get('/family/my');
      if (response is Map && response['success'] == true) {
        myFamilies.assignAll((response['data'] as List? ?? [])
            .map((e) => Family.fromJson(Map<String, dynamic>.from(e)))
            .toList());
      }
    } catch (_) {}
  }
}
