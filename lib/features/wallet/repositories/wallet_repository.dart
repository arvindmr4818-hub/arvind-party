import 'package:dio/dio.dart';
import '../../../core/constants/env_config.dart';
import '../models/wallet_model.dart';

class WalletRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: EnvConfig.plainApiBaseUrl));

  Future<WalletBalance> getBalance() async {
    try {
      final response = await _dio.get('/wallet/balance');
      return WalletBalance.fromJson(response.data['data']);
    } catch (e) { return WalletBalance(coins: 5000, diamonds: 120, beans: 30); }
  }

  Future<List<RechargePackage>> getRechargePackages() async {
    try {
      final response = await _dio.get('/wallet/packages');
      return (response.data['data'] as List).map((e) => RechargePackage.fromJson(e)).toList();
    } catch (e) { return _mockPackages(); }
  }

  Future<List<WithdrawMethod>> getWithdrawMethods() async {
    try {
      final response = await _dio.get('/wallet/withdraw-methods');
      return (response.data['data'] as List).map((e) => WithdrawMethod.fromJson(e)).toList();
    } catch (e) { return _mockWithdrawMethods(); }
  }

  Future<List<TransactionModel>> getTransactions({int page = 1}) async {
    try {
      final response = await _dio.get('/wallet/transactions', queryParameters: {'page': page});
      return (response.data['data'] as List).map((e) => TransactionModel.fromJson(e)).toList();
    } catch (e) { return _mockTransactions(); }
  }

  Future<void> recharge(String packageId, String paymentMethodId) async => await Future.delayed(const Duration(seconds: 2));
  Future<void> withdraw(String methodId, double amount, String accountDetails) async => await Future.delayed(const Duration(seconds: 2));

  List<RechargePackage> _mockPackages() => [
    RechargePackage(id: 'p1', name: 'Starter', price: 1.99, coins: 100, diamonds: 0, beans: 0),
    RechargePackage(id: 'p2', name: 'Popular', price: 4.99, coins: 500, diamonds: 10, beans: 5, isPopular: true),
    RechargePackage(id: 'p3', name: 'Pro', price: 9.99, coins: 1200, diamonds: 30, beans: 20),
    RechargePackage(id: 'p4', name: 'VIP', price: 19.99, coins: 2500, diamonds: 80, beans: 50),
  ];

  List<WithdrawMethod> _mockWithdrawMethods() => [
    WithdrawMethod(id: 'wm1', name: 'PayPal', iconUrl: 'https://picsum.photos/seed/paypal/50', minAmount: 5.0, maxAmount: 500.0, feePercentage: 2.5),
    WithdrawMethod(id: 'wm2', name: 'Bank Transfer', iconUrl: 'https://picsum.photos/seed/bank/50', minAmount: 10.0, maxAmount: 1000.0, feePercentage: 1.0),
    WithdrawMethod(id: 'wm3', name: 'UPI', iconUrl: 'https://picsum.photos/seed/upi/50', minAmount: 1.0, maxAmount: 200.0, feePercentage: 0.0),
  ];

  List<TransactionModel> _mockTransactions() {
    final types = TransactionType.values;
    final currencies = CurrencyType.values;
    return List.generate(20, (i) => TransactionModel(
      id: 'txn_$i', type: types[i % types.length], currency: currencies[i % currencies.length], amount: (i + 1) * 50,
      description: i % 2 == 0 ? 'Recharge via PayPal' : 'Gift sent to User ${i % 5}',
      status: i % 3 == 0 ? TransactionStatus.completed : (i % 2 == 0 ? TransactionStatus.pending : TransactionStatus.failed),
      createdAt: DateTime.now().subtract(Duration(days: i, hours: i * 2)),
    ));
  }
}