import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../auth/views/api_service.dart'; // Make sure this import path matches your local structure
import '../models/room_models.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';

class LiveRoomController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

  IO.Socket? socket;
  final String roomId;
  final String roomOwnerId;
  late RtcEngine engine;
  final String _agoraAppId = 'YOUR_AGORA_APP_ID'; // Replace with real Agora App ID

  String get currentUserId => _storage.read('user_id') ?? '';

  // --- Reactive State Variables ---
  final isConnected = false.obs;
  
  // ✅ Fixed naming convention to match LiveRoomScreen requirements
  final chatMessages = <ChatMessage>[].obs; 
  final seats = <Seat>[].obs;
  
  // ✅ Renamed variable to sync with screen expectations
  final activeGiftAnimation = Rxn<GiftAnimation>(); 
  final availableGifts = <Map<String, dynamic>>[].obs;
  
  // ✅ Synchronized variable name with UI logic
  final isMuted = false.obs; 
  final isVideoEnabled = false.obs;
  final activeSeat = Rxn<int>();
  final remoteVideoUids = <int>[].obs; 
  final mutedRemoteUsers = <int>[].obs; 
  final kickedUsersList = <Map<String, dynamic>>[].obs;
  final mutedUsersList = <Map<String, dynamic>>[].obs;

  LiveRoomController({required this.roomId, required this.roomOwnerId});

  @override
  void onInit() {
    super.onInit();
    _initSocket();
    _initAgora();
    _fetchAvailableGifts();
  }

  // 🎙️ Initialize Agora RTC Engine for Audio/Video Streaming
  Future<void> _initAgora() async {
    try {
      engine = createAgoraRtcEngine();
      await engine.initialize(RtcEngineContext(
        appId: _agoraAppId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));

      engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            print("✅ Joined Agora Channel: ${connection.channelId}");
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            print("👤 Remote user $remoteUid joined Agora stream");
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            print("❌ Remote user $remoteUid left Agora stream");
            remoteVideoUids.remove(remoteUid);
            mutedRemoteUsers.remove(remoteUid);
          },
          onUserEnableLocalVideo: (RtcConnection connection, int remoteUid, bool enabled) {
            if (enabled) {
              if (!remoteVideoUids.contains(remoteUid)) remoteVideoUids.add(remoteUid);
            } else {
              remoteVideoUids.remove(remoteUid);
            }
          },
          onUserEnableVideo: (RtcConnection connection, int remoteUid, bool enabled) {
            if (enabled) {
              if (!remoteVideoUids.contains(remoteUid)) remoteVideoUids.add(remoteUid);
            } else {
              remoteVideoUids.remove(remoteUid);
            }
          },
        ),
      );

      await engine.setClientRole(role: ClientRoleType.clientRoleAudience);
      await engine.enableAudio();

      int localUid = currentUserId.hashCode; 
      String rtcToken = '';
      try {
        final response = await _apiService.get('agora/token', queryParameters: {
          'channelName': roomId,
          'uid': localUid,
        });
        if (response != null && response['token'] != null) {
          rtcToken = response['token'];
        }
      } catch (e) {
        print('Failed to fetch Agora token: $e');
      }

      await engine.joinChannel(
        token: rtcToken,
        channelId: roomId,
        uid: localUid,
        options: const ChannelMediaOptions(),
      );
    } catch (e) {
      print('Agora Initialization Failed: $e');
    }
  }

  void _initSocket() {
    try {
      final userId = _storage.read('user_id');
      final userName = _storage.read('user_name');
      final userAvatar = _storage.read('user_avatar');

      if (userId == null) {
        Get.snackbar('Error', 'You are not logged in.',
            backgroundColor: Colors.redAccent);
        return;
      }

      socket = IO.io(
          _apiService.baseUrl.replaceAll('/api/', ''),
          IO.OptionBuilder()
              .setTransports(['websocket'])
              .disableAutoConnect()
              .build());

      socket!.connect();

      socket!.onConnect((_) {
        print('✅ Connected to Live Room Socket');
        isConnected.value = true;

        socket!.emit('join_room', {
          'roomId': roomId,
          'userId': userId,
          'userProfile': {'name': userName, 'avatar': userAvatar}
        });
      });

      socket!.onDisconnect((_) {
        print('❌ Disconnected from Live Room Socket');
        isConnected.value = false;
      });

      _registerAppEventListeners();
    } catch (e) {
      print('Socket Initialization Failed: $e');
      Get.snackbar('Error', 'Could not connect to the live server.');
    }
  }

  void _registerAppEventListeners() {
    socket!.on('receive_room_message', (data) {
      chatMessages.insert(0, ChatMessage.fromJson(data));
    });

    socket!.on('seat_updated', (data) {
      final updatedSeat = Seat.fromJson(data);
      final index = seats.indexWhere((s) => s.seatIndex == updatedSeat.seatIndex);
      if (index != -1) {
        seats[index] = updatedSeat;
      } else {
        seats.add(updatedSeat);
      }
    });

    socket!.on('gift_animation', (data) {
      activeGiftAnimation.value = GiftAnimation(
          giftId: data['giftId'],
          giftImageUrl: data['giftImageUrl'],
          senderName: data['senderName'],
          quantity: data['quantity']);
          
      // Auto clear animation display frame state after 4 seconds safely
      Future.delayed(const Duration(seconds: 4), () {
        activeGiftAnimation.value = null;
      });
    });

    socket!.on('system_announcement', (data) {
      Get.snackbar(
        data['title'] ?? 'System Notice',
        data['message'] ?? '',
        backgroundColor: Colors.blueAccent.withValues(alpha: 0.95), // Updated withOpacity fallback style
        colorText: Colors.white,
        icon: const Icon(Icons.campaign, color: Colors.white, size: 28),
        duration: const Duration(seconds: 8),
        margin: const EdgeInsets.all(16),
      );
    });

    socket!.on('user_kicked', (data) {
      if (data['targetUserId'] == currentUserId) {
        Get.defaultDialog(
          title: 'Kicked',
          middleText: 'You have been kicked from the room by the owner.',
          textConfirm: 'OK',
          confirmTextColor: Colors.white,
          buttonColor: Colors.redAccent,
          barrierDismissible: false,
          onConfirm: () {
            Get.back(); 
            Get.back(); 
          },
        );
      }
    });

    socket!.on('user_admin_muted', (data) {
      if (data['targetUserId'] == currentUserId) {
        Get.snackbar('Muted', 'You have been muted by the room owner.',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
        if (!isMuted.value) {
          toggleMute(); 
        }
      }
    });

    socket!.on('user_admin_unmuted', (data) {
      if (data['targetUserId'] == currentUserId) {
        Get.snackbar('Unmuted', 'You have been unmuted by the room owner.',
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    });
  }

  void _fetchAvailableGifts() async {
    try {
      final response = await _apiService.get('gifts');
      if (response != null && response['gifts'] != null) {
        availableGifts.assignAll(List<Map<String, dynamic>>.from(response['gifts']));
      }
    } catch (e) {
      print('Failed to fetch gifts: $e');
    }
  }

  Future<void> fetchModerationList() async {
    if (currentUserId != roomOwnerId) return; 
    try {
      final response = await _apiService.get('rooms/$roomId/moderation');
      if (response != null && response['success'] == true) {
        kickedUsersList.assignAll(List<Map<String, dynamic>>.from(response['data']['kickedUsers'] ?? []));
        mutedUsersList.assignAll(List<Map<String, dynamic>>.from(response['data']['mutedUsers'] ?? []));
      }
    } catch (e) {
      print('Failed to fetch moderation list: $e');
    }
  }

  // ✅ UI COMPATIBILITY: Mapping sendChatMessage logic safely
  void sendChatMessage(String text) {
    if (text.trim().isEmpty || socket == null || !isConnected.value) return;

    socket!.emit('send_room_message', {
      'roomId': roomId,
      'senderId': currentUserId,
      'senderName': _storage.read('user_name') ?? 'Guest',
      'message': text,
      'isVip': false,
    });
  }

  // ✅ UI COMPATIBILITY: Renamed from toggleMic to match LiveRoomScreen mapping handle
  void toggleMute() {
    if (socket == null || !isConnected.value) return;
    isMuted.value = !isMuted.value;

    engine.muteLocalAudioStream(isMuted.value);

    socket!.emit('toggle_mic', {
      'roomId': roomId,
      'userId': currentUserId,
      'isMuted': isMuted.value
    });
  }

  void toggleVideo() async {
    if (socket == null || !isConnected.value) return;
    isVideoEnabled.value = !isVideoEnabled.value;

    if (isVideoEnabled.value) {
      await engine.enableVideo();
      await engine.startPreview();
    } else {
      await engine.disableVideo();
    }

    socket!.emit('toggle_video', {
      'roomId': roomId,
      'userId': currentUserId,
      'isVideoEnabled': isVideoEnabled.value
    });
  }

  // ✅ UI COMPATIBILITY: Direct Room Gift broadcaster
  void sendGiftToRoom(String giftName, int cost) {
    if (socket == null || !isConnected.value) return;
    socket!.emit('send_gift', {
      'roomId': roomId,
      'senderId': currentUserId,
      'senderName': _storage.read('user_name') ?? 'Guest',
      'receiverId': roomOwnerId, 
      'giftId': giftName.toLowerCase(), 
      'quantity': 1,
      'cost': cost
    });
  }

  // ✅ UI COMPATIBILITY: Method mapped from claimSeat structure
  void joinSeat(int seatIndex) async {
    if (socket == null || !isConnected.value) return;

    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    isMuted.value = false; 
    await engine.muteLocalAudioStream(false);

    socket!.emit('claim_seat', {
      'roomId': roomId,
      'userId': currentUserId,
      'userName': _storage.read('user_name') ?? 'Guest',
      'userAvatar': _storage.read('user_avatar') ?? '',
      'seatIndex': seatIndex
    });
    activeSeat.value = seatIndex;
  }

  // ✅ UI COMPATIBILITY: Kicking explicit user from mic layout frame directly
  void kickFromSeat(int seatIndex) {
    if (socket == null || !isConnected.value) return;
    socket!.emit('leave_seat', {
      'roomId': roomId,
      'seatIndex': seatIndex,
      'forcedByAdmin': true
    });
  }

  // ✅ UI COMPATIBILITY: Added for closing execution environments cleanly
  void closeRoomEnvironment() {
    if (socket == null || !isConnected.value) return;
    socket!.emit('close_room', {
      'roomId': roomId,
      'ownerId': currentUserId,
    });
    Get.back();
  }

  void leaveSeat(int seatIndex) async {
    if (socket == null || !isConnected.value) return;

    await engine.setClientRole(role: ClientRoleType.clientRoleAudience);
    
    isMuted.value = false; 
    isVideoEnabled.value = false;
    await engine.muteLocalAudioStream(true);
    await engine.disableVideo();

    socket!.emit('leave_seat', {
      'roomId': roomId,
      'userId': currentUserId,
      'seatIndex': seatIndex
    });
    activeSeat.value = null;
  }

  void toggleRemoteAudio(int remoteUid) async {
    bool isRemoteMuted = mutedRemoteUsers.contains(remoteUid);
    await engine.muteRemoteAudioStream(uid: remoteUid, mute: !isRemoteMuted);

    if (isRemoteMuted) {
      mutedRemoteUsers.remove(remoteUid);
    } else {
      mutedRemoteUsers.add(remoteUid);
    }
  }

  @override
  void onClose() {
    engine.leaveChannel();
    engine.release();

    if (socket != null && isConnected.value) {
      socket!.emit('leave_room', {'roomId': roomId, 'userId': currentUserId});
      socket!.disconnect();
      socket!.dispose();
    }
    super.onClose();
  }
}