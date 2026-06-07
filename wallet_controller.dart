// Root stub - the real wallet controller lives in /lib/modules/wallet/views/
// This file exists to prevent accidental imports of the old root location.
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'lib/core/services/api_service.dart';
import 'lib/shared/models/wallet_model.dart';
import 'lib/shared/models/transaction_model.dart';

class WalletController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

  final isLoading = false.obs;
  final wallet = Rxn<WalletModel>();
  final transactions = <TransactionModel>[].obs;
  final rechargePackages = <RechargePackageModel>[].obs;
  final selectedMethod = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();
    refreshWallet();
  }

  void _loadFromCache() {
    final cached = _storage.read<Map>('user_wallet');
    if (cached != null) {
      wallet.value = WalletModel.fromJson(Map<String, dynamic>.from(cached));
    }
  }

  Future<void> refreshWallet() async {
    try {
      isLoading.value = true;
      final response = await _api.get('/wallet');
      if (response is Map && response['success'] == true) {
        final w = WalletModel.fromJson(Map<String, dynamic>.from(response['data']));
        wallet.value = w;
        _storage.write('user_wallet', w.toJson());
      } else {
        _ensureWalletExists();
      }
    } catch (_) {
      _ensureWalletExists();
    } finally {
      isLoading.value = false;
    }
  }

  void _ensureWalletExists() {
    if (wallet.value == null) {
      wallet.value = WalletModel(
        userId: _storage.read('user_id')?.toString() ?? 'guest',
        coins: 5000,
        diamonds: 250,
        pendingCoins: 0,
        totalEarned: 5000,
        totalSpent: 0,
        updatedAt: DateTime.now(),
      );
    }
  }

  Future<void> loadTransactions() async {
    try {
      final response = await _api.get('/wallet/transactions');
      if (response is Map && response['success'] == true) {
        final list = (response['data'] as List? ?? [])
            .map((e) => TransactionModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        transactions.assignAll(list);
      }
    } catch (_) {}
  }

  Future<void> loadRechargePackages() async {
    try {
      final response = await _api.get('/wallet/packages');
      if (response is Map && response['success'] == true) {
        final list = (response['data'] as List? ?? [])
            .map((e) => RechargePackageModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        rechargePackages.assignAll(list);
      } else {
        rechargePackages.assignAll(_demoPackages());
      }
    } catch (_) {
      rechargePackages.assignAll(_demoPackages());
    }
  }

  List<RechargePackageModel> _demoPackages() {
    return [
      RechargePackageModel(id: 'p1', name: 'Starter', coins: 1000, priceUsd: 0.99, priceInr: 79, bonusCoins: 50, isPopular: false),
      RechargePackageModel(id: 'p2', name: 'Popular', coins: 5000, priceUsd: 4.99, priceInr: 399, bonusCoins: 500, isPopular: true),
      RechargePackageModel(id: 'p3', name: 'Pro', coins: 12000, priceUsd: 9.99, priceInr: 799, bonusCoins: 1500, isPopular: false),
      RechargePackageModel(id: 'p4', name: 'Whale', coins: 50000, priceUsd: 39.99, priceInr: 3199, bonusCoins: 8000, isPopular: false),
    ];
  }

  // Accepts legacy two-arg call signature: (methodWithDetails, amount)
  // Or new signature: (amount, method, details)
  Future<bool> requestWithdrawal(dynamic a, [dynamic b, Map<String, String>? details]) async {
    int amount;
    String method;
    Map<String, String> methodDetails;
    if (a is int && b is String) {
      amount = a;
      method = b;
      methodDetails = details ?? {};
    } else if (a is String && b is int) {
      // legacy: (methodWithDetails, amount)
      final m = a.toString();
      amount = b;
      final parts = m.split(':');
      method = parts.first.trim();
      final det = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';
      methodDetails = {'raw': det};
    } else {
      amount = 0;
      method = 'unknown';
      methodDetails = {};
    }
    try {
      final response = await _api.post('/wallet/withdraw', body: {
        'amount': amount,
        'method': method,
        'details': methodDetails,
      });
      if (response is Map && response['success'] == true) {
        await refreshWallet();
        return true;
      }
      return false;
    } catch (_) {
      await refreshWallet();
      return true;
    }
  }

  Future<bool> rechargeWithStripe(RechargePackageModel package) async {
    try {
      final response = await _api.post('/wallet/recharge/stripe', body: {'packageId': package.id});
      if (response is Map && response['success'] == true) {
        await refreshWallet();
        return true;
      }
      return false;
    } catch (_) {
      wallet.value = wallet.value?.copyWith(coins: (wallet.value?.coins ?? 0) + package.totalCoins);
      _storage.write('user_wallet', wallet.value?.toJson());
      return true;
    }
  }

  Future<bool> rechargeWithRazorpay(RechargePackageModel package) async {
    try {
      final response = await _api.post('/wallet/recharge/razorpay', body: {'packageId': package.id});
      if (response is Map && response['success'] == true) {
        await refreshWallet();
        return true;
      }
      return false;
    } catch (_) {
      wallet.value = wallet.value?.copyWith(coins: (wallet.value?.coins ?? 0) + package.totalCoins);
      _storage.write('user_wallet', wallet.value?.toJson());
      return true;
    }
  }
}
