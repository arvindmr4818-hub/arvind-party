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
        title: const Text('Withdraw',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF8906)));
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2CB67D), Color(0xFF1C7C54)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Text('Available Beans',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 16)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.monetization_on,
                                  color: Colors.yellowAccent, size: 28),
                              const SizedBox(width: 8),
                              Text(
                                '${controller.beansBalance.value}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '≈ \$${controller.usdEquivalent.toStringAsFixed(2)} USD',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Text('Withdrawal Amount (USD)',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    // Amount Input
                    TextField(
                      controller: controller.amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.attach_money,
                            color: Color(0xFFFF8906), size: 30),
                        filled: true,
                        fillColor: const Color(0xFF15141F),
                        hintText: '0.00',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.2)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: Color(0xFFFF8906), width: 2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Text('Select Payment Method',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    // Methods List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.withdrawalMethods.length,
                      itemBuilder: (context, index) {
                        final method = controller.withdrawalMethods[index];
                        final isSelected =
                            controller.selectedMethod.value?.id == method.id;

                        return GestureDetector(
                          onTap: () => controller.selectMethod(method),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFF8906).withOpacity(0.1)
                                  : const Color(0xFF15141F),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFFF8906)
                                    : Colors.white12,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.account_balance,
                                      color: Colors
                                          .white70), // Replace with real icons/images later
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(method.name,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(
                                          'Min: \$${method.minWithdrawalUsd} • Fee: ${method.feePercentage}%',
                                          style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle,
                                      color: Color(0xFFFF8906)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Submit Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF15141F),
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              child: ElevatedButton(
                onPressed: controller.submitWithdrawal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8906),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Withdraw Now',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
          ],
        );
      }),
    );
  }
}
