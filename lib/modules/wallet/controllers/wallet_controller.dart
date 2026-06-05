import 'package:get/get.dart';
import '../models/recharge_package_model.dart';

class WalletController extends GetxController {
  final isLoading = false.obs;
  final diamondBalance = 0.obs;
  final coinBalance = 0.obs;

  final packages = <RechargePackage>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadWalletData();
  }

  void _loadWalletData() async {
    isLoading.value = true;
    // TODO: Fetch real balance and packages from backend API
    // Abhi UI testing ke liye placeholder packages load kar rahe hain
    await Future.delayed(const Duration(milliseconds: 800));

    diamondBalance.value = 0; // Replace with real data logic
    coinBalance.value = 0; // Replace with real data logic

    packages.assignAll([
      RechargePackage(id: 'pkg_1', diamonds: 100, price: 0.99),
      RechargePackage(id: 'pkg_2', diamonds: 500, price: 4.99, bonus: 50),
      RechargePackage(id: 'pkg_3', diamonds: 1000, price: 9.99, bonus: 150),
      RechargePackage(id: 'pkg_4', diamonds: 5000, price: 49.99, bonus: 1000),
      RechargePackage(id: 'pkg_5', diamonds: 10000, price: 99.99, bonus: 3000),
    ]);

    isLoading.value = false;
  }

  void initiateRecharge(RechargePackage package) async {
    // TODO: Integrate real payment gateway (Google Play Billing / Apple IAP / Stripe)
    Get.snackbar(
      'Processing Payment',
      'Initiating purchase for ${package.diamonds} diamonds...',
      snackPosition: SnackPosition.BOTTOM,
    );

    // Future logic layout:
    // final success = await PaymentService.buy(package.id);
    // if (success) {
    //    diamondBalance.value += package.diamonds + package.bonus;
    //    // Notify backend
    // }
  }
}
