// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/modules/room/controllers/room_controller.dart
//
// MASTER ROOM CONTROLLER
// Yeh ek hi controller pura room system handle karta hai:
//   - Room info & state
//   - Seat system (8/10/15/20/25)
//   - Members list
//   - Admin system (label-based admin count)
//   - Chat
//   - Socket integration
//   - Ban system
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../models/room_model.dart';
import '../models/seat_model.dart';
import '../models/room_member_model.dart';
import '../models/room_permission_model.dart';
import '../../../core/services/socket_service.dart';

class RoomController extends GetxController {
  // ─── ROOM STATE ──────────────────────────────────────────────────────────
  final currentRoom = Rxn<RoomModel>();
  final isLoading = false.obs;

  // ─── SEAT STATE ──────────────────────────────────────────────────────────
  final seats = <SeatModel>[].obs;

  // ─── MEMBERS STATE ───────────────────────────────────────────────────────
  final members = <RoomMemberModel>[].obs;

  // ─── CURRENT USER STATE ──────────────────────────────────────────────────
  late final String _currentUserId;
  late final String _currentUserName;
  late final String _currentAvatar;

  final currentUserRole = MemberRole.visitor.obs;

  // Shortcuts (Obx mein use karne ke liye)
  bool get isOwner => currentUserRole.value == MemberRole.owner;
  bool get isHost => currentUserRole.value == MemberRole.host || isOwner;
  bool get isCoHost => currentUserRole.value == MemberRole.coHost;
  bool get isAdmin => currentUserRole.value == MemberRole.admin;
  bool get canManageRoom => isHost || isCoHost;
  bool get canManageMembers => isHost || isCoHost || isAdmin;

  // My permission set (role se automatically derive hoti hai)
  RoomPermissionModel get myPermissions => RoomPermissionModel.forRole(
      currentUserRole.value.toString().split('.').last);

  // ─── MY MIC STATE ────────────────────────────────────────────────────────
  final isUserMuted = false.obs;
  final myCurrentSeatIndex = (-1).obs; // -1 = not on any seat

  // ─── ADMIN COUNT SYSTEM ──────────────────────────────────────────────────
  // Owner ka label badhne par maxAdmins bhi badhta hai:
  // Level 1-9  → 8 admins
  // Level 10+  → 10 admins
  // Level 15+  → 15 admins
  // Level 20+  → 20 admins (future)
  int get maxAdminsAllowed {
    final ownerLevel = _getOwnerLevel();
    if (ownerLevel >= 20) return 20;
    if (ownerLevel >= 15) return 15;
    if (ownerLevel >= 10) return 10;
    return 8;
  }

  int get currentAdminCount =>
      members.where((m) => m.role == MemberRole.admin).length;

  int _getOwnerLevel() {
    final owner = members.firstWhereOrNull((m) => m.role == MemberRole.owner);
    return owner?.userLevel ?? 1;
  }

  // ─── CHAT STATE ──────────────────────────────────────────────────────────
  final chatMessages = <ChatMessage>[].obs;
  final isChatVisible = true.obs;

  // ─── RAISE HAND REQUESTS ─────────────────────────────────────────────────
  final raiseHandRequests = <RaiseHandRequest>[].obs;

  // ─── BANNED USERS ────────────────────────────────────────────────────────
  final bannedUsers = <BannedUser>[].obs;

  // ─── SERVICES ────────────────────────────────────────────────────────────
  late final SocketService _socket;
  final _storage = GetStorage();

  // ─────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _socket = Get.find<SocketService>();
    _loadCurrentUser();
    _setupSocketListeners();
    _loadDummyRoom(); // Remove when backend ready
  }

  @override
  void onClose() {
    _removeSocketListeners();
    super.onClose();
  }

  void _loadCurrentUser() {
    _currentUserId = _storage.read<String>('user_id') ?? 'user_001';
    _currentUserName = _storage.read<String>('user_name') ?? 'You';
    _currentAvatar = _storage.read<String>('user_avatar') ?? '';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SOCKET LISTENERS
  // ─────────────────────────────────────────────────────────────────────────

  void _setupSocketListeners() {
    _socket.onReceiveMessage((data) {
      if (data is Map) {
        chatMessages.add(ChatMessage(
          senderId: data['senderId']?.toString() ?? '',
          senderName: data['senderName']?.toString() ?? 'Unknown',
          message: data['message']?.toString() ?? '',
          time: DateTime.now(),
        ));
        _autoScrollChat();
      }
    });

    _socket.onSeatUpdated((data) {
      // TODO: Parse full seat update from backend
    });

    _socket.onRoomOnlineUpdate((data) {
      if (currentRoom.value != null && data is Map) {
        final count = data['count'] as int?;
        if (count != null) {
          currentRoom.value = currentRoom.value!.copyWith(onlineUsers: count);
        }
      }
    });

    _socket.onNewRaiseHand((data) {
      if (data is Map) {
        raiseHandRequests.add(RaiseHandRequest(
          requestId: data['requestId']?.toString() ?? '',
          userId: data['userId']?.toString() ?? '',
          userName: data['userName']?.toString() ?? 'User',
          avatar: data['avatar']?.toString() ?? '',
          requestedAt: DateTime.now(),
        ));
        _showRaiseHandNotification(data['userName']?.toString() ?? 'Someone');
      }
    });
  }

  void _removeSocketListeners() {
    _socket.offEvent('receive_message');
    _socket.offEvent('seat_updated');
    _socket.offEvent('room_online_update');
    _socket.offEvent('new_raise_hand');
  }

  void _showRaiseHandNotification(String name) {
    if (!canManageRoom) return;
    Get.snackbar(
      '✋ Raise Hand',
      '$name wants to join mic',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF15141F),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      mainButton: TextButton(
        onPressed: () {
          Get.back();
          // Open raise hand sheet
        },
        child: const Text('View', style: TextStyle(color: Color(0xFFFF8906))),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ROOM SETUP
  // ─────────────────────────────────────────────────────────────────────────

  /// Naya room create karo (CreateRoomController se call hota hai)
  void initRoom(RoomModel room, {bool asOwner = true}) {
    currentRoom.value = room;
    generateSeats(room.seatCount);
    currentUserRole.value = asOwner ? MemberRole.owner : MemberRole.visitor;

    if (asOwner) {
      // Owner ko seat 1 par automatically bithao
      takeSeat(0, _currentUserId, _currentUserName, _currentAvatar);
    }

    // Socket mein room join karo
    if (_socket.isConnected.value) {
      _socket.joinRoom(room.id, _currentUserId, _currentUserName);
    }
  }

  /// Existing room join karo (rooms list se)
  void joinRoom(RoomModel room) {
    currentRoom.value = room;
    generateSeats(room.seatCount);
    currentUserRole.value = MemberRole.visitor;

    members.add(RoomMemberModel(
      id: _currentUserId,
      name: _currentUserName,
      avatar: _currentAvatar,
      role: MemberRole.visitor,
      joinedAt: DateTime.now(),
    ));

    if (_socket.isConnected.value) {
      _socket.joinRoom(room.id, _currentUserId, _currentUserName);
    }
  }

  void leaveRoom() {
    if (currentRoom.value != null) {
      _socket.leaveRoom(currentRoom.value!.id, _currentUserId);
    }
    // Agar user seat par tha toh chhod do
    if (myCurrentSeatIndex.value >= 0) {
      leaveSeat(myCurrentSeatIndex.value);
    }
    currentRoom.value = null;
    seats.clear();
    members.clear();
    chatMessages.clear();
    raiseHandRequests.clear();
    Get.back();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SEAT SYSTEM
  // ─────────────────────────────────────────────────────────────────────────

  void generateSeats(int count) {
    seats.assignAll(List.generate(count, (i) => SeatModel(seatNumber: i + 1)));
  }

  void takeSeat(int index, String userId, String userName, String avatar) {
    if (index < 0 || index >= seats.length) return;

    if (seats[index].isLocked) {
      if (!canManageRoom) {
        _snack('🔒 Locked', 'This seat is locked by host.');
        return;
      }
    }

    if (seats[index].userId != null && seats[index].userId != userId) {
      _snack('Occupied', 'This seat is already taken.');
      return;
    }

    // Pehli seat chhodo agar already on mic
    if (myCurrentSeatIndex.value >= 0 && userId == _currentUserId) {
      final oldIdx = myCurrentSeatIndex.value;
      seats[oldIdx] = seats[oldIdx].copyWith(clearUser: true);
    }

    final bool isCurrentUserHost = (userId == _currentUserId && isHost);
    seats[index] = seats[index].copyWith(
      userId: userId,
      userName: userName,
      avatar: avatar,
      isHost: isCurrentUserHost,
      isCoHost: (currentUserRole.value == MemberRole.coHost &&
          userId == _currentUserId),
    );

    if (userId == _currentUserId) {
      myCurrentSeatIndex.value = index;
    }

    if (_socket.isConnected.value && currentRoom.value != null) {
      _socket.joinSeat(currentRoom.value!.id, index + 1, userId, userName);
    }
  }

  void leaveSeat(int index) {
    if (index < 0 || index >= seats.length) return;

    if (_socket.isConnected.value && currentRoom.value != null) {
      _socket.leaveSeat(currentRoom.value!.id, index + 1);
    }

    if (seats[index].userId == _currentUserId) {
      myCurrentSeatIndex.value = -1;
    }

    seats[index] = seats[index].copyWith(clearUser: true);
  }

  void toggleSelfMute() {
    isUserMuted.toggle();
    _snack(
      isUserMuted.value ? '🔇 Muted' : '🎙️ Live',
      isUserMuted.value ? 'Your mic is muted' : 'You are now live',
      isBottom: true,
    );
  }

  // ─── HOST/ADMIN SEAT CONTROLS ─────────────────────────────────────────────

  void toggleLockSeat(int index) {
    if (!canManageRoom) return;
    if (index < 0 || index >= seats.length) return;

    final locked = !seats[index].isLocked;
    seats[index] = seats[index].copyWith(isLocked: locked);

    if (_socket.isConnected.value && currentRoom.value != null) {
      locked
          ? _socket.lockSeat(currentRoom.value!.id, index + 1)
          : _socket.unlockSeat(currentRoom.value!.id, index + 1);
    }
    _snack(locked ? '🔒 Locked' : '🔓 Unlocked',
        'Seat ${index + 1} ${locked ? 'locked' : 'unlocked'}');
  }

  void toggleMuteSeatByAdmin(int index) {
    if (!canManageMembers) return;
    if (index < 0 || index >= seats.length) return;

    final muted = !seats[index].isMuted;
    seats[index] = seats[index].copyWith(isMuted: muted);

    if (_socket.isConnected.value && currentRoom.value != null) {
      muted
          ? _socket.muteSeat(currentRoom.value!.id, index + 1)
          : _socket.unmuteSeat(currentRoom.value!.id, index + 1);
    }
  }

  void kickUserFromSeat(int index) {
    if (!canManageMembers) return;
    if (index < 0 || index >= seats.length) return;
    if (seats[index].userId == null) return;

    final name = seats[index].userName ?? 'User';
    leaveSeat(index);
    _snack('👢 Kicked', '$name removed from mic');
  }

  // ─── RAISE HAND ───────────────────────────────────────────────────────────

  void sendRaiseHand() {
    if (currentRoom.value == null) return;
    _socket.raiseHand(currentRoom.value!.id, _currentUserId, _currentUserName);
    _snack('✋ Hand Raised', 'Host will see your request');
  }

  void approveRaiseHand(RaiseHandRequest request) {
    if (!canManageRoom) return;
    if (currentRoom.value == null) return;

    _socket.approveRaiseHand(
        currentRoom.value!.id, request.requestId, request.userId);
    raiseHandRequests.removeWhere((r) => r.requestId == request.requestId);

    // Find first empty seat
    final emptyIdx = seats.indexWhere((s) => s.userId == null && !s.isLocked);
    if (emptyIdx >= 0) {
      takeSeat(emptyIdx, request.userId, request.userName, request.avatar);
    }
    _snack('✅ Approved', '${request.userName} added to mic');
  }

  void rejectRaiseHand(String requestId) {
    raiseHandRequests.removeWhere((r) => r.requestId == requestId);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MEMBERS & ADMIN SYSTEM
  // ─────────────────────────────────────────────────────────────────────────

  /// Admin promote karo (label-based limit check ke saath)
  void promoteToAdmin(String userId) {
    if (!isHost) {
      _snack('Permission Denied', 'Only Host/Owner can assign admins');
      return;
    }

    if (currentAdminCount >= maxAdminsAllowed) {
      _snack(
        '❌ Admin Limit Reached',
        'Max $maxAdminsAllowed admins allowed at your level.\nLevel up to unlock more!',
      );
      return;
    }

    _updateMemberRole(userId, MemberRole.admin);
    _snack('👑 Promoted', 'User is now Admin');
  }

  /// Admin demote karo
  void removeAdminRole(String userId) {
    if (!isHost) return;
    _updateMemberRole(userId, MemberRole.member);
    _snack('⬇️ Demoted', 'Admin role removed');
  }

  /// Co-Host banao
  void makeCoHost(String userId) {
    if (!isHost) return;
    _updateMemberRole(userId, MemberRole.coHost);
    _snack('🎤 Co-Host', 'User is now Co-Host');
  }

  /// Room ownership transfer karo
  void transferOwnership(String userId) {
    if (!isOwner) {
      _snack('Permission Denied', 'Only room owner can transfer ownership');
      return;
    }

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF15141F),
        title: const Text('Transfer Ownership?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'You will lose Owner privileges. This cannot be undone easily.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _doTransferOwnership(userId);
            },
            child: const Text('Transfer',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _doTransferOwnership(String newOwnerId) {
    // Purana owner → member
    final oldOwnerIdx = members.indexWhere((m) => m.role == MemberRole.owner);
    if (oldOwnerIdx >= 0) {
      members[oldOwnerIdx] =
          members[oldOwnerIdx].copyWith(role: MemberRole.member);
    }
    // Naya owner
    _updateMemberRole(newOwnerId, MemberRole.owner);
    currentUserRole.value = MemberRole.member;
    _snack('🏆 Ownership Transferred', 'You are now a member');
  }

  void kickMember(String userId) {
    if (!canManageMembers) return;
    final idx = members.indexWhere((m) => m.id == userId);
    if (idx < 0) return;

    final name = members[idx].name;
    // Agar seat par tha toh hata do
    final seatIdx = seats.indexWhere((s) => s.userId == userId);
    if (seatIdx >= 0) leaveSeat(seatIdx);

    members.removeAt(idx);
    _snack('👢 Kicked', '$name has been removed from room');
  }

  void banMember({
    required String userId,
    required String username,
    required String reason,
    required BanDuration duration,
  }) {
    if (!canManageMembers) return;

    final idx = members.indexWhere((m) => m.id == userId);
    if (idx >= 0) {
      // Seat se hata do
      final seatIdx = seats.indexWhere((s) => s.userId == userId);
      if (seatIdx >= 0) leaveSeat(seatIdx);
      members.removeAt(idx);
    }

    DateTime? expiresAt;
    if (duration != BanDuration.permanent) {
      expiresAt = DateTime.now().add(duration.toDuration());
    }

    bannedUsers.add(BannedUser(
      userId: userId,
      username: username,
      reason: reason,
      bannedAt: DateTime.now(),
      expiresAt: expiresAt,
      bannedBy: _currentUserName,
      isPermanent: duration == BanDuration.permanent,
    ));

    _snack('🚫 Banned', '$username banned: $reason');
  }

  void unbanMember(String userId) {
    if (!canManageMembers) return;
    bannedUsers.removeWhere((b) => b.userId == userId);
    _snack('✅ Unbanned', 'User can rejoin the room');
  }

  void _updateMemberRole(String userId, MemberRole newRole) {
    final idx = members.indexWhere((m) => m.id == userId);
    if (idx >= 0) {
      members[idx] = members[idx].copyWith(role: newRole);
    }
    // Agar current user hai toh local role bhi update karo
    if (userId == _currentUserId) {
      currentUserRole.value = newRole;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CHAT
  // ─────────────────────────────────────────────────────────────────────────

  final ScrollController chatScrollController = ScrollController();

  void sendChatMessage(String text) {
    if (text.trim().isEmpty) return;
    if (currentRoom.value == null) return;

    final msg = ChatMessage(
      senderId: _currentUserId,
      senderName: _currentUserName,
      message: text.trim(),
      time: DateTime.now(),
      isMe: true,
    );

    chatMessages.add(msg);
    _socket.sendMessage(
        currentRoom.value!.id, _currentUserId, _currentUserName, text.trim());
    _autoScrollChat();
  }

  void _autoScrollChat() {
    if (chatScrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 80), () {
        chatScrollController.animateTo(
          chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ROOM INFO UPDATES (Host only)
  // ─────────────────────────────────────────────────────────────────────────

  void updateAnnouncement(String text) {
    if (!canManageRoom) return;
    if (currentRoom.value == null) return;
    currentRoom.value = currentRoom.value!.copyWith(announcement: text);
  }

  void updateWelcomeMessage(String text) {
    if (!canManageRoom) return;
    if (currentRoom.value == null) return;
    currentRoom.value = currentRoom.value!.copyWith(welcomeMessage: text);
  }

  void updateTopic(String text) {
    if (!canManageRoom) return;
    if (currentRoom.value == null) return;
    currentRoom.value = currentRoom.value!.copyWith(topic: text);
  }

  void updatePinnedMessage(String text) {
    if (!canManageRoom) return;
    if (currentRoom.value == null) return;
    currentRoom.value = currentRoom.value!.copyWith(pinnedMessage: text);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DUMMY DATA (Backend se replace karna)
  // ─────────────────────────────────────────────────────────────────────────

  void _loadDummyRoom() {
    currentRoom.value = const RoomModel(
      id: 'room_arvind_001',
      title: 'Arvind Party Lounge 🎶',
      topic: 'Chill Vibes & Good Music Tonight',
      banner:
          'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800&q=80',
      welcomeMessage: 'Welcome! Please be respectful on mic 🙏',
      announcement: '🔥 DJ Night starts at 10 PM IST — Get ready!',
      pinnedMessage: 'Follow the host for daily live sessions!',
      roomType: 'public',
      seatCount: 8,
      onlineUsers: 124,
      hostId: 'user_host_001',
    );

    generateSeats(8);

    members.assignAll([
      RoomMemberModel(
          id: 'user_host_001',
          name: 'Arvind Kumar',
          avatar: 'https://picsum.photos/seed/host/100',
          role: MemberRole.owner,
          userLevel: 45,
          isOnline: true,
          joinedAt: DateTime.now()),
      RoomMemberModel(
          id: 'user_002',
          name: 'Rahul Sharma',
          avatar: 'https://picsum.photos/seed/r/100',
          role: MemberRole.coHost,
          userLevel: 32,
          isOnline: true,
          joinedAt: DateTime.now()),
      RoomMemberModel(
          id: 'user_003',
          name: 'Priya Patel',
          avatar: 'https://picsum.photos/seed/p/100',
          role: MemberRole.admin,
          userLevel: 18,
          isOnline: true,
          joinedAt: DateTime.now()),
      RoomMemberModel(
          id: 'user_004',
          name: 'Vikram Singh',
          avatar: 'https://picsum.photos/seed/v/100',
          role: MemberRole.member,
          userLevel: 9,
          isOnline: true,
          joinedAt: DateTime.now()),
      RoomMemberModel(
          id: 'user_005',
          name: 'Sneha Gupta',
          avatar: 'https://picsum.photos/seed/s/100',
          role: MemberRole.visitor,
          userLevel: 2,
          isOnline: false,
          joinedAt: DateTime.now()),
    ]);

    // Seats fill karo
    seats[0] = seats[0].copyWith(
        userId: 'user_host_001',
        userName: 'Arvind Kumar',
        avatar: 'https://picsum.photos/seed/host/100',
        isHost: true);
    seats[1] = seats[1].copyWith(
        userId: 'user_002',
        userName: 'Rahul Sharma',
        avatar: 'https://picsum.photos/seed/r/100',
        isCoHost: true);

    currentUserRole.value = MemberRole.owner;
    _currentUserId; // already loaded
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPER
  // ─────────────────────────────────────────────────────────────────────────

  void _snack(String title, String message, {bool isBottom = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: isBottom ? SnackPosition.BOTTOM : SnackPosition.TOP,
      backgroundColor: const Color(0xFF15141F),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUPPORTING DATA CLASSES
// ─────────────────────────────────────────────────────────────────────────────

class ChatMessage {
  final String senderId;
  final String senderName;
  final String message;
  final DateTime time;
  final bool isMe;

  ChatMessage({
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.time,
    this.isMe = false,
  });
}

class RaiseHandRequest {
  final String requestId;
  final String userId;
  final String userName;
  final String avatar;
  final DateTime requestedAt;

  const RaiseHandRequest({
    required this.requestId,
    required this.userId,
    required this.userName,
    required this.avatar,
    required this.requestedAt,
  });
}

class BannedUser {
  final String userId;
  final String username;
  final String reason;
  final DateTime bannedAt;
  final DateTime? expiresAt;
  final String bannedBy;
  final bool isPermanent;

  const BannedUser({
    required this.userId,
    required this.username,
    required this.reason,
    required this.bannedAt,
    this.expiresAt,
    required this.bannedBy,
    this.isPermanent = false,
  });

  bool get isExpired =>
      !isPermanent && expiresAt != null && DateTime.now().isAfter(expiresAt!);
}

enum BanDuration {
  oneHour,
  sixHours,
  oneDay,
  oneWeek,
  permanent;

  Duration toDuration() {
    switch (this) {
      case BanDuration.oneHour:
        return const Duration(hours: 1);
      case BanDuration.sixHours:
        return const Duration(hours: 6);
      case BanDuration.oneDay:
        return const Duration(days: 1);
      case BanDuration.oneWeek:
        return const Duration(days: 7);
      case BanDuration.permanent:
        return const Duration(days: 36500);
    }
  }

  String get label {
    switch (this) {
      case BanDuration.oneHour:
        return '1 Hour';
      case BanDuration.sixHours:
        return '6 Hours';
      case BanDuration.oneDay:
        return '1 Day';
      case BanDuration.oneWeek:
        return '1 Week';
      case BanDuration.permanent:
        return 'Permanent';
    }
  }
}
