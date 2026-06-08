import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/api_service.dart'; // Sahi service injection path

class CoinControlController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final uidController = TextEditingController();
  final amountController = TextEditingController();
  final reasonController = TextEditingController();

  final isLoading = false.obs;
  final treasuryLogs = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTreasuryLogs();
  }

  Future<void> processCoinAction(bool isGenerate) async {
    if (uidController.text.isEmpty || amountController.text.isEmpty || reasonController.text.isEmpty) {
      Get.snackbar("Error", "Bhai, saare fields bharna zaroori hai!", 
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    final endpoint = isGenerate ? '/api/admin/coins/generate' : '/api/admin/coins/deduct';
    
    try {
      // ✅ FIX 1: 'body:' named parameter inject kiya jaisa ApiService ke post method mein required hai
      final response = await _api.post(endpoint, body: {
        'targetUid': uidController.text.trim(),
        'amount': int.parse(amountController.text.trim()),
        'reason': reasonController.text.trim(),
      });

      // ✅ FIX 2: response direct map hai, isliye dot notation (.data) ki zaroorat nahi hai
      if (response != null && response['success'] == true) {
        Get.snackbar("Success", isGenerate ? "Coins generate ho gaye!" : "Coins deduct ho gaye!",
            backgroundColor: Colors.green, colorText: Colors.white);
        _clearForm();
        fetchTreasuryLogs();
      } else {
        final errorMsg = response != null ? response['message'] : "Action failed";
        Get.snackbar("Failed", errorMsg,
            backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTreasuryLogs() async {
    try {
      final response = await _api.get('/api/admin/treasury/logs');
      // ✅ FIX 3: Isme bhi straight map checking logic lagaya bina response.data ke
      if (response != null && response['success'] == true) {
        treasuryLogs.assignAll(List<Map<String, dynamic>>.from(response['data']));
      }
    } catch (_) {}
  }

  void _clearForm() {
    uidController.clear();
    amountController.clear();
    reasonController.clear();
  }

  @override
  void onClose() {
    uidController.dispose();
    amountController.dispose();
    reasonController.dispose();
    super.onClose();
  }
}