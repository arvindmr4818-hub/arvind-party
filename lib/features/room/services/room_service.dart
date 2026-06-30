// ═══════════════════════════════════════════════════════════════════════════
// ROOM SERVICE — LiveKit Integration (Replaces Agora)
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/env_config.dart';

class RoomService extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  Room? _room;
  EventsListener<RoomEvent>? _listener;

  Room? get room => _room;
  bool get isConnected => _room?.connectionState == ConnectionState.connected;

  // Observables
  final participants = <Participant>[].obs;
  final localMicEnabled = true.obs;
  final localCameraEnabled = false.obs;
  final isSpeaking = false.obs;
  final activeSpeakers = <String>[].obs;

  /// Get LiveKit token from backend then connect
  Future<Map<String, dynamic>> joinRoom({
    required String roomId,
    required String role,
  }) async {
    try {
      // 1. Get token from backend
      final res = await _api.post(
        '/room/$roomId/livekit/token',
        {'role': role},
      );

      if (res['success'] != true) {
        return {'success': false, 'message': res['message'] ?? 'Failed to get token'};
      }

      final token = res['data']['token'] as String;
      final serverUrl = res['data']['serverUrl'] as String? ?? EnvConfig.liveKitUrl;

      // 2. Create LiveKit room
      _room = Room(
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          defaultAudioPublishOptions: AudioPublishOptions(
            name: 'microphone',
            dtx: true,
          ),
        ),
      );

      // 3. Setup event listeners
      _setupListeners();

      // 4. Connect to room
      await _room!.connect(
        serverUrl,
        token,
        connectOptions: const ConnectOptions(
          autoSubscribe: true,
          rtcConfig: RTCConfiguration(
            iceTransportPolicy: RTCIceTransportPolicy.all,
          ),
        ),
      );

      // 5. Enable microphone if speaker/host
      if (role == 'host' || role == 'cohost' || role == 'speaker') {
        await enableMicrophone();
      }

      // Update participants
      _updateParticipants();

      return {'success': true, 'roomName': _room!.name};
    } catch (e) {
      debugPrint('RoomService.joinRoom error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  void _setupListeners() {
    _listener = _room!.createListener();

    _listener!
      ..on<RoomConnectedEvent>((event) {
        debugPrint('Room connected: ${event.room.name}');
        _updateParticipants();
      })
      ..on<ParticipantConnectedEvent>((event) {
        debugPrint('Participant joined: ${event.participant.identity}');
        _updateParticipants();
      })
      ..on<ParticipantDisconnectedEvent>((event) {
        debugPrint('Participant left: ${event.participant.identity}');
        _updateParticipants();
      })
      ..on<TrackSubscribedEvent>((event) {
        _updateParticipants();
      })
      ..on<TrackUnsubscribedEvent>((event) {
        _updateParticipants();
      })
      ..on<ActiveSpeakersChangedEvent>((event) {
        activeSpeakers.value = event.speakers
            .map((s) => s.identity)
            .toList();
      })
      ..on<RoomDisconnectedEvent>((event) {
        debugPrint('Room disconnected: ${event.reason}');
        participants.clear();
        activeSpeakers.clear();
      });
  }

  void _updateParticipants() {
    if (_room == null) return;
    final all = <Participant>[
      if (_room!.localParticipant != null) _room!.localParticipant!,
      ..._room!.remoteParticipants.values,
    ];
    participants.value = all;
  }

  /// Toggle local microphone
  Future<void> enableMicrophone() async {
    try {
      await _room?.localParticipant?.setMicrophoneEnabled(true);
      localMicEnabled.value = true;
    } catch (e) {
      debugPrint('Enable mic error: $e');
    }
  }

  Future<void> toggleMicrophone() async {
    try {
      final enabled = !localMicEnabled.value;
      await _room?.localParticipant?.setMicrophoneEnabled(enabled);
      localMicEnabled.value = enabled;
    } catch (e) {
      debugPrint('Toggle mic error: $e');
    }
  }

  /// Send data message to all in room
  Future<void> sendDataMessage(Map<String, dynamic> data) async {
    try {
      final bytes = utf8.encode(json.encode(data));
      await _room?.localParticipant?.publishData(
        Uint8List.fromList(bytes),
        reliable: true,
      );
    } catch (e) {
      debugPrint('Send data error: $e');
    }
  }

  /// Leave and disconnect
  Future<void> leaveRoom() async {
    try {
      await _room?.localParticipant?.setMicrophoneEnabled(false);
      await _room?.disconnect();
      _listener?.dispose();
      _room = null;
      participants.clear();
      activeSpeakers.clear();
      localMicEnabled.value = false;
    } catch (e) {
      debugPrint('Leave room error: $e');
    }
  }

  bool isActiveSpeaker(String identity) => activeSpeakers.contains(identity);

  @override
  void onClose() {
    leaveRoom();
    super.onClose();
  }
}
