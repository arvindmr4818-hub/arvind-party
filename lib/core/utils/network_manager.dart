import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class NetworkManager extends GetxService {
  final isConnected = true.obs;
  late final Connectivity _connectivity;

  @override
  void onInit() {
    super.onInit();
    _connectivity = Connectivity();
    _connectivity.onConnectivityChanged.listen((results) {
      final connected = results.isNotEmpty &&
          !results.contains(ConnectivityResult.none);
      isConnected.value = connected;
      if (!connected) {
        Get.snackbar(
          'No Internet',
          'Please check your connection',
          backgroundColor: const Color(0xFFFF4757),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    });
  }
}
