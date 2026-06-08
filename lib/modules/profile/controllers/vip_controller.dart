import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../auth/views/api_service.dart';
import '../models/vip_model.dart';

class VipController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  late Razorpay _razorpay;
  IO.Socket? _socket;

  var vipData = VipModel(isVip: false, level: 0, perks: []).obs;
  var isLoading = false.obs;
  bool _hasShownOverlay = false;

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    fetchVipStatus();
    _initSocketListener();
  }

  void _initSocketListener() {
    // IMPORTANT: If you already have a global socket service, listen to the event there instead!
    _socket = IO.io('http://YOUR_BACKEND_URL', IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build());
        
    _socket?.connect();
    
    _socket?.on('webhook_payment_success', (data) {
      // You should ideally check if data['userId'] matches the currently logged-in user
      Get.snackbar(
        'Payment Processed!', 
        'Your delayed payment was successfully received. Welcome to VIP!',
        backgroundColor: Colors.green, 
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      fetchVipStatus(); // Automatically refresh the UI to show VIP perks
    });
  }

  @override
  void onClose() {
    _socket?.disconnect();
    _socket?.dispose();
    _razorpay.clear();
    super.onClose();
  }

  Future<void> fetchVipStatus() async {
    try {
      isLoading(true);
      final response = await _apiService.get('users/vip');
      if (response.statusCode == 200) {
        vipData.value = VipModel.fromJson(response.data['vip'] ?? {});
        
        // Trigger the stunning Lottie overlay for VIP users!
        if (vipData.value.isVip && !_hasShownOverlay) {
          _hasShownOverlay = true;
          _showVipWelcomeOverlay();
        }
      }
    } catch (e) {
      Get.snackbar('VIP System', 'Failed to fetch your VIP status.');
    } finally {
      isLoading(false);
    }
  }

  void _showVipWelcomeOverlay() {
    Get.dialog(
      Center(
        child: Lottie.asset(
          'assets/animations/vip_confetti.json',
          repeat: false,
          onLoaded: (composition) {
            // Automatically dismiss the overlay once the animation finishes
            Future.delayed(composition.duration, () {
              if (Get.isDialogOpen ?? false) {
                Get.back();
              }
            });
          },
        ),
      ),
      barrierColor: Colors.black54, // Dim the background
      barrierDismissible: true,
    );
  }

  // ==========================================
  // Razorpay Checkout Integration
  // ==========================================
  Future<void> startRazorpayCheckout() async {
    try {
      isLoading(true);

      // Fetch the generated Order ID securely from your backend
      final response = await _apiService.post('users/create-order', {});
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final String orderId = response.data['order_id'];
        final int amount = response.data['amount'];

        var options = {
          'key': 'rzp_test_YOUR_KEY_HERE', // Replace with your actual Razorpay API Key
          'amount': amount, 
          'order_id': orderId, // The order ID generated from your backend
          'name': 'Arvind Party VIP',
          'description': 'Premium VIP Upgrade (1 Month)',
          'prefill': {
            'contact': '9876543210', // Consider passing actual user's phone number here
            'email': 'user@example.com' // Pass actual user's email
          },
          'theme': {
            'color': '#FFD700'
          }
        };

        _razorpay.open(options);
      } else {
        Get.snackbar('Error', 'Failed to create payment order.');
      }
    } catch (e) {
      debugPrint('Error starting Razorpay: $e');
      Get.snackbar('Error', 'An error occurred initializing checkout.');
    } finally {
      isLoading(false);
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      isLoading(true);
      
      // Send the payment details to your NodeJS backend to securely verify the signature
      final verificationResponse = await _apiService.post('users/verify-payment', {
        'razorpay_order_id': response.orderId,
        'razorpay_payment_id': response.paymentId,
        'razorpay_signature': response.signature,
      });

      if (verificationResponse.statusCode == 200) {
        Get.snackbar('Success', 'Payment Verified! Welcome to VIP.',
            backgroundColor: Colors.green, colorText: Colors.white);
        
        fetchVipStatus(); // Refresh VIP status now that the backend has updated it!
      } else {
        Get.snackbar('Verification Failed', 'Could not verify the transaction.',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred during payment verification.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Get.snackbar('Payment Failed', 'Transaction was cancelled or failed.',
        backgroundColor: Colors.redAccent, colorText: Colors.white);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar('External Wallet', 'Selected Wallet: ${response.walletName}');
  }
}