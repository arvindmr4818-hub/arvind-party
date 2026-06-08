import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/network/api_client.dart';

class ProfileController extends GetxController {
  final agencyIdController = TextEditingController();
  final cashOutCoinsController = TextEditingController();
  final paymentDetailsController = TextEditingController();

  var isLoading = false.obs;
  var currentAgencyId = ''.obs;

  // Profile data
  final userName = 'User'.obs;
  final userId = ''.obs;
  final userLevel = 1.obs;
  final isVip = false.obs;
  final followers = 0.obs;
  final following = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final storage = GetStorage();
    userName.value = storage.read('user_name') ?? 'User';
    userId.value = storage.read('user_id') ?? '';
  }

  Future<void> joinAgency() async {
    final agencyId = agencyIdController.text.trim();
    if (agencyId.isEmpty) return;

    isLoading.value = true;
    try {
      final userId = GetStorage().read('user_id');

      final data = await ApiClient().post('/app-users/join-agency', {
        'userId': userId,
        'agencyId': agencyId,
      });

      if (data['success'] == true) {
        Get.snackbar('Success', 'You have joined the agency!');
        currentAgencyId.value = agencyId;
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed to join agency');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestCashOut() async {
    final coins = int.tryParse(cashOutCoinsController.text.trim()) ?? 0;
    final payment = paymentDetailsController.text.trim();
    if (coins <= 0 || payment.isEmpty) return;

    isLoading.value = true;
    try {
      final userId = GetStorage().read('user_id');

      final data = await ApiClient().post('/app-users/withdraw', {
        'userId': userId,
        'coins': coins,
        'paymentDetails': payment,
      });

      if (data['success'] == true) {
        Get.snackbar('Success', 'Cash-out request submitted!');
        cashOutCoinsController.clear();
        paymentDetailsController.clear();
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed to submit request');
      }
    } finally {
      isLoading.value = false;
    }
  }
}