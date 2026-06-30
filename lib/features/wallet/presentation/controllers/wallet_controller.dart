// ═══════════════════════════════════════════════════════════════════════════
// WALLET CONTROLLER — Real Razorpay Payment Integration
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/services/api_service.dart';
import '../../../home/services/user_service.dart';

class WalletController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final UserService _user = Get.find<UserService>();
  late Razorpay _razorpay;

  final coins = 0.obs;
  final diamonds = 0.obs;
  final transactions = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final isWithdrawing = false.obs;
  final withdrawAmountCtrl = TextEditingController();

  Map<String, dynamic>? _pendingPlan;

  final rechargePlans = [
    {'coins': 100, 'price': 99},
    {'coins': 500, 'price': 449},
    {'coins': 1000, 'price': 849},
    {'coins': 5000, 'price': 3999},
    {'coins': 10000, 'price': 7499},
    {'coins': 50000, 'price': 34999},
  ];

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
    refresh();
  }

  Future<void> refresh() async {
    isLoading.value = true;
    try {
      final balRes = await _api.get('/wallet/balance');
      if (balRes['success'] == true) {
        coins.value = balRes['data']?['coins'] ?? 0;
        diamonds.value = balRes['data']?['diamonds'] ?? 0;
      }
      final txnRes = await _api.get('/wallet/transactions');
      if (txnRes['success'] == true) {
        transactions.value = List<Map<String, dynamic>>.from(txnRes['data'] ?? []);
      }
    } catch (_) {}
    isLoading.value = false;
  }

  /// STEP 1: Create order on backend, then open Razorpay checkout
  Future<void> startRecharge(Map<String, dynamic> plan) async {
    _pendingPlan = plan;
    try {
      final res = await _api.post('/wallet/create-order', {
        'amount': plan['price'],
        'coins': plan['coins'],
      });

      if (res['success'] != true) {
        Get.snackbar('Error', res['message'] ?? 'Could not create order',
          backgroundColor: const Color(0xFFFF4757), colorText: Colors.white);
        return;
      }

      final orderId = res['data']['orderId'];
      final amount = res['data']['amount']; // in paise
      final keyId = res['data']['keyId'];

      var options = {
        'key': keyId,
        'amount': amount,
        'name': 'Arvind Party',
        'description': '${plan['coins']} Coins',
        'order_id': orderId,
        'prefill': {
          'contact': _user.currentUser.value?['phone'] ?? '',
          'email': _user.currentUser.value?['email'] ?? '',
        },
        'theme': {'color': '#FF8906'},
      };

      _razorpay.open(options);
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: const Color(0xFFFF4757), colorText: Colors.white);
    }
  }

  /// STEP 2: Verify payment on backend after Razorpay success
  void _onPaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final res = await _api.post('/wallet/verify-payment', {
        'razorpay_payment_id': response.paymentId,
        'razorpay_order_id': response.orderId,
        'razorpay_signature': response.signature,
      });

      if (res['success'] == true) {
        Get.snackbar('Success! 🎉', 'Coins added to your wallet',
          backgroundColor: const Color(0xFF2ED573), colorText: Colors.black);
        await refresh();
      } else {
        Get.snackbar('Verification Failed', res['message'] ?? 'Please contact support',
          backgroundColor: const Color(0xFFFF4757), colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Payment verification failed: $e',
        backgroundColor: const Color(0xFFFF4757), colorText: Colors.white);
    }
    _pendingPlan = null;
  }

  void _onPaymentError(PaymentFailureResponse response) {
    Get.snackbar('Payment Failed', response.message ?? 'Transaction cancelled',
      backgroundColor: const Color(0xFFFF4757), colorText: Colors.white);
    _pendingPlan = null;
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    Get.snackbar('External Wallet', 'Selected: ${response.walletName}');
  }

  /// Withdraw diamonds
  Future<void> submitWithdrawal() async {
    final amount = int.tryParse(withdrawAmountCtrl.text);
    if (amount == null || amount < 500) {
      Get.snackbar('Invalid Amount', 'Minimum withdrawal is 500 diamonds',
        backgroundColor: const Color(0xFFFF4757), colorText: Colors.white);
      return;
    }
    if (amount > diamonds.value) {
      Get.snackbar('Insufficient Balance', 'You don\\'t have enough diamonds',
        backgroundColor: const Color(0xFFFF4757), colorText: Colors.white);
      return;
    }

    isWithdrawing.value = true;
    try {
      final res = await _api.post('/wallet/withdraw', {'amount': amount});
      if (res['success'] == true) {
        Get.snackbar('Request Submitted', 'Your withdrawal request is pending approval',
          backgroundColor: const Color(0xFF2ED573), colorText: Colors.black);
        withdrawAmountCtrl.clear();
        await refresh();
      } else {
        Get.snackbar('Failed', res['message'] ?? 'Could not submit request',
          backgroundColor: const Color(0xFFFF4757), colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
    isWithdrawing.value = false;
  }

  @override
  void onClose() {
    _razorpay.clear();
    withdrawAmountCtrl.dispose();
    super.onClose();
  }
}
