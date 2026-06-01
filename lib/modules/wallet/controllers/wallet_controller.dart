import 'package:get/get.dart';
import '../models/transaction_model.dart';

class WalletController extends GetxController {
  RxInt coins = 10000.obs;
  RxInt diamonds = 0.obs;
  
  RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  
  List<int> rechargePlans = [100, 500, 1000, 5000, 10000];
  
  void recharge(int amount) {
    coins.value += amount;
    transactions.add(TransactionModel(
      title: "Recharge",
      amount: amount,
      type: "recharge",
      createdAt: DateTime.now(),
    ));
    Get.snackbar("Success", "Recharged $amount Coins Successfully");
  }

  void deductCoins(int amount, String title) {
    if (coins.value >= amount) {
      coins.value -= amount;
      transactions.add(TransactionModel(
        title: title,
        amount: amount,
        type: "gift_sent",
        createdAt: DateTime.now(),
      ));
    }
  }

  void earnDiamonds(int amount, String title) {
    diamonds.value += amount;
    transactions.add(TransactionModel(
      title: title,
      amount: amount,
      type: "gift_received",
      createdAt: DateTime.now(),
    ));
  }
}
