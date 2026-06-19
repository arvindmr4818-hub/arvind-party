import 'package:get/get.dart';
import '../../controllers/wallet_controller.dart' as wc;
import '../controllers/withdrawal_controller.dart' as wd;

class WalletBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<wc.WalletController>(() => wc.WalletController());
    Get.lazyPut<wd.WithdrawalController>(() => wd.WithdrawalController());
  }
}