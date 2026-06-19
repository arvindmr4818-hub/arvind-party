import 'package:get/get.dart';
import '../models/block_model.dart';
import '../repositories/block_repository.dart';

class BlockController extends GetxController {
  final BlockRepository _repo = BlockRepository();

  final blockedUsers = <BlockedUserModel>[].obs;
  final mutedUsers = <MutedUserModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadBlacklist();
  }

  Future<void> loadBlacklist() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([_repo.getBlockedUsers(), _repo.getMutedUsers()]);
      blockedUsers.assignAll(results[0] as List<BlockedUserModel>);
      mutedUsers.assignAll(results[1] as List<MutedUserModel>);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load blacklist data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> blockUser(String userId, String username, {String? avatarUrl}) async {
    try {
      await _repo.blockUser(userId);
      blockedUsers.add(BlockedUserModel(userId: userId, username: username, avatarUrl: avatarUrl, blockedAt: DateTime.now()));
      Get.snackbar('Blocked', '$username has been blocked.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to block user');
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      await _repo.unblockUser(userId);
      final user = blockedUsers.firstWhereOrNull((u) => u.userId == userId);
      blockedUsers.removeWhere((u) => u.userId == userId);
      Get.snackbar('Unblocked', '${user?.username ?? 'User'} has been unblocked.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to unblock user');
    }
  }

  Future<void> muteUser(String userId, String username, MuteDuration duration, {String? avatarUrl}) async {
    try {
      await _repo.muteUser(userId, duration);
      final until = duration == MuteDuration.forever ? null : DateTime.now().add(_durationToTime(duration));
      mutedUsers.add(MutedUserModel(userId: userId, username: username, avatarUrl: avatarUrl, mutedAt: DateTime.now(), mutedUntil: until));
      Get.snackbar('Muted', '$username has been muted.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to mute user');
    }
  }

  Future<void> unmuteUser(String userId) async {
    try {
      await _repo.unmuteUser(userId);
      final user = mutedUsers.firstWhereOrNull((u) => u.userId == userId);
      mutedUsers.removeWhere((u) => u.userId == userId);
      Get.snackbar('Unmuted', '${user?.username ?? 'User'} has been unmuted.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to unmute user');
    }
  }

  bool isUserBlocked(String userId) => blockedUsers.any((u) => u.userId == userId);
  bool isUserMuted(String userId) => mutedUsers.any((u) => u.userId == userId && u.isActive);

  Duration _durationToTime(MuteDuration duration) {
    switch (duration) {
      case MuteDuration.fifteenMinutes: return const Duration(minutes: 15);
      case MuteDuration.oneHour: return const Duration(hours: 1);
      case MuteDuration.sixHours: return const Duration(hours: 6);
      case MuteDuration.oneDay: return const Duration(days: 1);
      case MuteDuration.oneWeek: return const Duration(days: 7);
      case MuteDuration.forever: return const Duration(days: 365 * 100);
    }
  }
}