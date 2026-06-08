import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/models/withdrawal_method_model.dart';

class WithdrawalController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

  // ── Reactive State Variables ───────────────────────────────────
  final isLoading = false.obs;
  final methods = <WithdrawalMethod>[].obs;
  final selectedMethod = Rxn<WithdrawalMethod>();
  final amount = 0.obs;
  final accountDetails = <String, String>{}.obs;
  final withdrawalHistory = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadMethods();
    _loadHistoryFromCache();
  }

  void _loadHistoryFromCache() {
    final cached = _storage.read<List>('withdrawal_history') ?? [];
    withdrawalHistory.assignAll(cached.map((e) => Map<String, dynamic>.from(e)).toList());
  }

  // 🌐 REAL TIME API: Database se active payment configurations fetch karna
  Future<void> loadMethods() async {
    try {
      isLoading.value = true;
      // Real Node.js endpoint router path mapping
      final response = await _api.get('/wallet/withdrawal-methods');
      if (response is Map && response['success'] == true) {
        final List<dynamic> serverData = response['data'] ?? [];
        final list = serverData
            .map((e) => WithdrawalMethod.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        methods.assignAll(list);
      } else {
        methods.clear(); // Real empty validation state layout frame
      }
    } catch (e) {
      debugPrint('Database payout matrix collection lookup failure: $e');
      methods.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void selectMethod(WithdrawalMethod m) {
    selectedMethod.value = m;
    accountDetails.clear();
  }

  void setAmount(int a) {
    amount.value = a;
  }

  void setField(String key, String value) {
    accountDetails[key] = value;
  }

  int get feeAmount {
    if (selectedMethod.value == null) return 0;
    return ((amount.value * selectedMethod.value!.feePercent) / 100).round();
  }

  int get finalAmount => amount.value - feeAmount;

  bool get isValid {
    if (selectedMethod.value == null) return false;
    if (amount.value < selectedMethod.value!.minAmount) return false;
    if (amount.value > selectedMethod.value!.maxAmount) return false;
    for (final field in selectedMethod.value!.requiredFields) {
      if ((accountDetails[field] ?? '').isEmpty) return false;
    }
    return true;
  }

  // 💸 REAL TIME API: Submit payout ledger requests directly to backend MongoDB
  Future<bool> submitWithdrawal() async {
    if (!isValid) return false;
    try {
      isLoading.value = true;
      final response = await _api.post('/wallet/withdraw', body: {
        'method': selectedMethod.value!.id,
        'amount': amount.value,
        'details': Map<String, String>.from(accountDetails),
      });
      
      if (response is Map && response['success'] == true) {
        final newRecord = {
          'id': response['transactionId']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'method': selectedMethod.value!.name,
          'amount': amount.value,
          'fee': feeAmount,
          'finalAmount': finalAmount,
          'status': 'pending',
          'createdAt': DateTime.now().toIso8601String(),
        };
        withdrawalHistory.insert(0, newRecord);
        _storage.write('withdrawal_history', withdrawalHistory.toList());
        
        // Reset local states fields parameters
        amount.value = 0;
        accountDetails.clear();
        
        Get.snackbar('Success 🎉', 'Payout dispatch request streamed to verification queues.');
        return true;
      }
    } catch (e) {
      debugPrint('Payout operation gateway submission drop exception: $e');
    } finally {
      isLoading.value = false;
    }
    return false;
  }
}