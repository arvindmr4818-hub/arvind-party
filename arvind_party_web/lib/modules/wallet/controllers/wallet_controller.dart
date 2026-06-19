import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/admin_api.dart';

class WalletController extends GetxController {
  final wallets = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadWallets();
  }

  Future<void> loadWallets({String? search}) async {
    isLoading.value = true;
    searchQuery.value = search ?? '';
    try {
      final params = <String, String>{};
      if (search != null && search.isNotEmpty) params['search'] = search;
      final result = await AdminApi.to.getWallets(params: params.isNotEmpty ? params : null);
      wallets.value = result.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[WalletController] loadWallets error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> adjustWallet(String userId, int amount, String reason) async {
    try {
      await AdminApi.to.adjustWallet(userId, amount, reason);
      await loadWallets();
      Get.snackbar('Success', 'Wallet adjusted successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to adjust wallet',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white);
    }
  }
}