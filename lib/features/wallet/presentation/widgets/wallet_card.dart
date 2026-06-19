import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/withdrawal_controller.dart';

class WithdrawalScreen extends StatelessWidget {
  const WithdrawalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WithdrawalController());

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF15141F),
        elevation: 0,
        title: const Text('Withdraw Funds',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.methods.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8906)));
        }

        return ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // Amount Inputs Section
            const Text('Enter Payout Beans/Tokens Amount', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.monetization_on, color: Colors.amber, size: 26),
                filled: true,
                fillColor: const Color(0xFF15141F),
                hintText: 'Minimum bounds token value',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              onChanged: (val) {
                final numVal = int.tryParse(val) ?? 0;
                controller.setAmount(numVal);
              },
            ),
            const SizedBox(height: 24),

            // Gateways Payment Options Layout Grid
            const Text('Select Payout Method Channel', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.methods.length,
              itemBuilder: (context, index) {
                final method = controller.methods[index];
                final isSelected = controller.selectedMethod.value?.id == method.id;

                return GestureDetector(
                  onTap: () => controller.selectMethod(method),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFF8906).withValues(alpha: 0.1) : const Color(0xFF15141F),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? const Color(0xFFFF8906) : Colors.white12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance_wallet, color: Colors.white70),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(method.name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                              Text('Limits: ${method.minAmount} - ${method.maxAmount} • Fee: ${method.feePercent}%', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                            ],
                          ),
                        ),
                        if (isSelected) const Icon(Icons.check_circle, color: Color(0xFFFF8906)),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Dynamic Form Generation Field Inputs loops mapping
            if (controller.selectedMethod.value != null) ...[
              const Text('Provide Gateway Credentials Details', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...controller.selectedMethod.value!.requiredFields.map((field) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: field.toUpperCase(),
                      labelStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF15141F),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onChanged: (val) => controller.setField(field, val),
                  ),
                );
              }),
            ],
            const SizedBox(height: 30),

            // Fee calculations displays box layouts panels
            if (controller.amount.value > 0 && controller.selectedMethod.value != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Deduction Payout Fee:', style: TextStyle(color: Colors.white54)), Text('${controller.feeAmount} Beans', style: const TextStyle(color: Colors.white70))]),
                    const Divider(color: Colors.white12),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Net Settlement Amount:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text('${controller.finalAmount} Beans', style: const TextStyle(color: Color(0xFFFF8906), fontWeight: FontWeight.bold, fontSize: 16))]),
                  ],
                ),
              ),

            // Final Submit Operational Action Buttons
            ElevatedButton(
              onPressed: controller.isValid ? () => controller.submitWithdrawal() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8906),
                disabledBackgroundColor: Colors.white12,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Submit Withdrawal Demand', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }),
    );
  }
}