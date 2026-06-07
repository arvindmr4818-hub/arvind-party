import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'wallet_controller.dart';

class WithdrawalScreen extends StatefulWidget {
  @override
  _WithdrawalScreenState createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final WalletController controller = Get.find<WalletController>();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController accountDetailsController = TextEditingController();
  
  String selectedMethod = 'payoneer';

  void submitWithdrawal() {
    final amount = int.tryParse(amountController.text) ?? 0;
    final details = accountDetailsController.text.trim();

    if (amount <= 0) {
      Get.snackbar('Error', 'Please enter a valid amount', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    if (details.isEmpty) {
      Get.snackbar('Error', 'Please enter your payment details', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    // Combine method ID and account details to pass into the API request payload
    String methodWithDetails = '$selectedMethod: $details';
    
    controller.requestWithdrawal(methodWithDetails, amount);
    
    // Clear fields and go back after slight delay
    Future.delayed(Duration(seconds: 1), () {
      Get.back();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Withdraw Funds'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedMethod,
              items: [
                DropdownMenuItem(value: 'payoneer', child: Text('Payoneer')),
                DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
                DropdownMenuItem(value: 'epay', child: Text('Epay')),
              ],
              onChanged: (val) {
                setState(() { selectedMethod = val!; });
              },
              decoration: InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12)),
            ),
            SizedBox(height: 20),
            Text('Payment Details (Email / Bank Account)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: accountDetailsController,
              decoration: InputDecoration(hintText: 'e.g. user@payoneer.com', border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            Text('Amount to Withdraw (USD)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'Enter amount in USD', border: OutlineInputBorder()),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: submitWithdrawal,
                style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: Text('Submit Request', style: TextStyle(fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }
}