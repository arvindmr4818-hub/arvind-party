import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/admin_api.dart';

class AuditLogController extends GetxController {
  final logs = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final fromDateCtrl = TextEditingController();
  final toDateCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadLogs();
  }

  @override
  void onClose() {
    fromDateCtrl.dispose();
    toDateCtrl.dispose();
    super.onClose();
  }

  Future<void> loadLogs({String? from, String? to, String? adminId}) async {
    isLoading.value = true;
    try {
      final params = <String, String>{};
      if (from != null) params['from'] = from;
      if (to != null) params['to'] = to;
      if (adminId != null) params['admin_id'] = adminId;
      final result = await AdminApi.to.getAuditLogs(
          params: params.isNotEmpty ? params : null);
      logs.value = result.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[AuditLogController] loadLogs error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}