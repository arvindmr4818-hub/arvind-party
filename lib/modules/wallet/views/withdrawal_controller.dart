// lib/modules/wallet/views/withdrawal_controller.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/models/withdrawal_method_model.dart';

class WithdrawalController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

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
  }

  Future<void> loadMethods() async {
    try {
      isLoading.value = true;
      final response = await _api.get('/wallet/withdrawal-methods');
      if (response is Map && response['success'] == true) {
        final list = (response['data'] as List? ?? [])
            .map((e) => WithdrawalMethod.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        methods.assignAll(list);
      } else {
        methods.assignAll(_demoMethods());
      }
    } catch (_) {
      methods.assignAll(_demoMethods());
    } finally {
      isLoading.value = false;
    }
  }

  List<WithdrawalMethod> _demoMethods() {
    return [
      WithdrawalMethod(id: 'upi', name: 'UPI', iconUrl: '', minAmount: 100, maxAmount: 50000, feePercent: 0, isActive: true, requiredFields: ['upiId']),
      WithdrawalMethod(id: 'bank', name: 'Bank Transfer', iconUrl: '', minAmount: 500, maxAmount: 100000, feePercent: 2, isActive: true, requiredFields: ['accountNumber', 'ifsc', 'name']),
      WithdrawalMethod(id: 'paypal', name: 'PayPal', iconUrl: '', minAmount: 1000, maxAmount: 200000, feePercent: 5, isActive: true, requiredFields: ['email']),
      WithdrawalMethod(id: 'paytm', name: 'Paytm', iconUrl: '', minAmount: 100, maxAmount: 25000, feePercent: 1, isActive: true, requiredFields: ['phone']),
    ];
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
        withdrawalHistory.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'method': selectedMethod.value!.name,
          'amount': amount.value,
          'fee': feeAmount,
          'finalAmount': finalAmount,
          'status': 'pending',
          'createdAt': DateTime.now().toIso8601String(),
        });
        _storage.write('withdrawal_history', withdrawalHistory.toList());
        return true;
      }
    } catch (_) {
      withdrawalHistory.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'method': selectedMethod.value!.name,
        'amount': amount.value,
        'fee': feeAmount,
        'finalAmount': finalAmount,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      });
      _storage.write('withdrawal_history', withdrawalHistory.toList());
      return true;
    } finally {
      isLoading.value = false;
    }
    return false;
  }
}
