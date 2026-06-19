// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/core/network/network_manager.dart
// ARVIND PARTY - NETWORK STATE MANAGER & CONNECTIVITY MONITOR
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class NetworkManager extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final isOnline = true.obs;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      isOnline.value = false;
    } else {
      isOnline.value = !results.contains(ConnectivityResult.none);
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  bool get isConnected => isOnline.value;
}