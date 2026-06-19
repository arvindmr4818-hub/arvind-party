import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/admin_api.dart';

class RechargeController extends GetxController {
  final recharges = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadRecharges();
  }

  Future<void> loadRecharges({Map<String, String>? params}) async {
    isLoading.value = true;
    try {
      final result = await AdminApi.to.getRecharges(params: params);
      recharges.value = result.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[RechargeController] loadRecharges error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}