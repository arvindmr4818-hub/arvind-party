import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

class WithdrawalAdminController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

  final isLoading = false.obs;
  final pendingRequests = <Map<String, dynamic>>[].obs;
  final processedRequests = <Map<String, dynamic>>[].obs;
  final stats = <String, dynamic>{}.obs;
  final filter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCache();
    loadRequests();
  }

  void _loadCache() {
    final cached = _storage.read<List>('admin_pending_withdrawals') ?? [];
    pendingRequests.assignAll(cached.map((e) => Map<String, dynamic>.from(e)));
  }

  // 🌐 REAL TIME API: Fetch pending and processed ledger sets from database
  Future<void> loadRequests() async {
    try {
      isLoading.value = true;
      // Real Node.js Endpoints Route mapping
      final response = await _api.get('/admin/withdrawals', query: {'status': filter.value});
      
      if (response is Map && response['success'] == true) {
        final data = response['data'] as Map? ?? {};
        
        pendingRequests.assignAll(List<Map<String, dynamic>>.from(
          (data['pending'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)),
        ));
        processedRequests.assignAll(List<Map<String, dynamic>>.from(
          (data['processed'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)),
        ));
        
        stats.assignAll(Map<String, dynamic>.from(data['stats'] as Map? ?? {}));
        _storage.write('admin_pending_withdrawals', pendingRequests.toList());
      } else {
        pendingRequests.clear();
        processedRequests.clear();
      }
    } catch (e) {
      debugPrint('Admin database collection pull failure: $e');
      pendingRequests.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // 🛡️ REAL TIME API: Approve ledger payout document
  Future<bool> approveRequest(String id) async {
    try {
      isLoading.value = true;
      final response = await _api.post('/admin/withdrawals/$id/approve', body: {});
      if (response is Map && response['success'] == true) {
        final req = pendingRequests.firstWhere((r) => (r['id'] ?? r['_id']) == id, orElse: () => {});
        if (req.isNotEmpty) {
          req['status'] = 'approved';
          processedRequests.insert(0, req);
          pendingRequests.removeWhere((r) => (r['id'] ?? r['_id']) == id);
          _storage.write('admin_pending_withdrawals', pendingRequests.toList());
        }
        Get.snackbar('Approved!', 'Payout request marked as approved successfully.');
        return true;
      }
    } catch (e) {
      debugPrint('Approval handshake database transaction dropped: $e');
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  // 🛡️ REAL TIME API: Reject ledger payout document with audit logs reason
  Future<bool> rejectRequest(String id, String reason) async {
    try {
      isLoading.value = true;
      final response = await _api.post('/admin/withdrawals/$id/reject', body: {'reason': reason});
      if (response is Map && response['success'] == true) {
        final req = pendingRequests.firstWhere((r) => (r['id'] ?? r['_id']) == id, orElse: () => {});
        if (req.isNotEmpty) {
          req['status'] = 'rejected';
          req['rejectionReason'] = reason;
          processedRequests.insert(0, req);
          pendingRequests.removeWhere((r) => (r['id'] ?? r['_id']) == id);
          _storage.write('admin_pending_withdrawals', pendingRequests.toList());
        }
        Get.snackbar('Rejected', 'Payout transaction request cancelled & funds reverted.');
        return true;
      }
    } catch (e) {
      debugPrint('Rejection mutation transmission failure: $e');
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  void setFilter(String f) {
    filter.value = f;
    loadRequests();
  }
}