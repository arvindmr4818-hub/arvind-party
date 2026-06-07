// lib/modules/wallet/views/withdrawal_admin_controller.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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

  Future<void> loadRequests() async {
    try {
      isLoading.value = true;
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
        _seedDemo();
      }
    } catch (_) {
      _seedDemo();
    } finally {
      isLoading.value = false;
    }
  }

  void _seedDemo() {
    if (pendingRequests.isEmpty) {
      pendingRequests.assignAll([
        {
          'id': 'w1',
          'userId': 'u1',
          'userName': 'John Doe',
          'amount': 5000,
          'method': 'UPI',
          'details': {'upiId': 'john@paytm'},
          'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
          'status': 'pending',
        },
        {
          'id': 'w2',
          'userId': 'u2',
          'userName': 'Jane Smith',
          'amount': 10000,
          'method': 'Bank',
          'details': {'accountNumber': 'XXXX1234', 'ifsc': 'HDFC0001'},
          'createdAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
          'status': 'pending',
        },
      ]);
    }
    stats.assignAll({
      'totalPending': pendingRequests.length,
      'totalProcessed': processedRequests.length,
      'totalAmountPending': pendingRequests.fold<int>(0, (s, e) => s + ((e['amount'] as int?) ?? 0)),
    });
  }

  Future<bool> approveRequest(String id) async {
    try {
      final response = await _api.post('/admin/withdrawals/$id/approve');
      if (response is Map && response['success'] == true) {
        final req = pendingRequests.firstWhere((r) => r['id'] == id, orElse: () => {});
        if (req.isNotEmpty) {
          req['status'] = 'approved';
          processedRequests.insert(0, req);
          pendingRequests.removeWhere((r) => r['id'] == id);
        }
        return true;
      }
    } catch (_) {
      final req = pendingRequests.firstWhere((r) => r['id'] == id, orElse: () => {});
      if (req.isNotEmpty) {
        req['status'] = 'approved';
        processedRequests.insert(0, req);
        pendingRequests.removeWhere((r) => r['id'] == id);
      }
      return true;
    }
    return false;
  }

  Future<bool> rejectRequest(String id, String reason) async {
    try {
      final response = await _api.post('/admin/withdrawals/$id/reject', body: {'reason': reason});
      if (response is Map && response['success'] == true) {
        final req = pendingRequests.firstWhere((r) => r['id'] == id, orElse: () => {});
        if (req.isNotEmpty) {
          req['status'] = 'rejected';
          req['rejectionReason'] = reason;
          processedRequests.insert(0, req);
          pendingRequests.removeWhere((r) => r['id'] == id);
        }
        return true;
      }
    } catch (_) {
      final req = pendingRequests.firstWhere((r) => r['id'] == id, orElse: () => {});
      if (req.isNotEmpty) {
        req['status'] = 'rejected';
        req['rejectionReason'] = reason;
        processedRequests.insert(0, req);
        pendingRequests.removeWhere((r) => r['id'] == id);
      }
      return true;
    }
    return false;
  }

  void setFilter(String f) {
    filter.value = f;
    loadRequests();
  }
}
