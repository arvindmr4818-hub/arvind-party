import 'package:get/get.dart';
import '../../models/coin_seller_model.dart';

class CoinSellerController extends GetxController {
  final sellers = <CoinSeller>[].obs;
  final rechargeRequests = <RechargeRequest>[].obs;
  final settlementHistory = <SettlementRecord>[].obs;
  final isLoading = false.obs;
  final selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    sellers.assignAll([
      CoinSeller(id: 'cs1', name: 'CoinMaster', type: 'super', coinsAvailable: 50000, pricePerCoin: 0.9, rating: 4.8, totalSales: 1520, phone: '+91 98765 43210'),
      CoinSeller(id: 'cs2', name: 'Official Coins', type: 'official', coinsAvailable: 100000, pricePerCoin: 1.0, rating: 4.9, totalSales: 5000, phone: '+91 88888 88888'),
      CoinSeller(id: 'cs3', name: 'QuickRecharge', type: 'normal', coinsAvailable: 10000, pricePerCoin: 0.95, rating: 4.5, totalSales: 850, phone: '+91 77777 77777'),
    ]);
    rechargeRequests.assignAll([
      RechargeRequest(id: 'rr1', sellerId: 'cs1', sellerName: 'CoinMaster', coins: 1000, amount: 900.0, status: 'completed', createdAt: DateTime.now().subtract(const Duration(hours: 2))),
      RechargeRequest(id: 'rr2', sellerId: 'cs2', sellerName: 'Official Coins', coins: 500, amount: 500.0, status: 'pending', createdAt: DateTime.now().subtract(const Duration(minutes: 30))),
    ]);
    settlementHistory.assignAll([
      SettlementRecord(id: 'st1', sellerId: 'cs2', amount: 4500.0, status: 'completed', createdAt: DateTime.now().subtract(const Duration(days: 1))),
      SettlementRecord(id: 'st2', sellerId: 'cs1', amount: 1800.0, status: 'pending', createdAt: DateTime.now().subtract(const Duration(days: 3))),
    ]);
    isLoading.value = false;
  }

  Future<void> submitRechargeRequest(String sellerId, String sellerName, int coins, double amount) async {
    rechargeRequests.insert(0, RechargeRequest(
      id: 'rr_${DateTime.now().millisecondsSinceEpoch}',
      sellerId: sellerId,
      sellerName: sellerName,
      coins: coins,
      amount: amount,
      status: 'pending',
      createdAt: DateTime.now(),
    ));
    Get.snackbar('Success', 'Recharge request submitted for $coins coins');
  }

  Future<void> submitSettlement(String sellerId, double amount) async {
    settlementHistory.insert(0, SettlementRecord(
      id: 'st_${DateTime.now().millisecondsSinceEpoch}',
      sellerId: sellerId,
      amount: amount,
      status: 'pending',
      createdAt: DateTime.now(),
    ));
    Get.snackbar('Success', 'Settlement request of \$${amount.toStringAsFixed(2)} submitted');
  }
}