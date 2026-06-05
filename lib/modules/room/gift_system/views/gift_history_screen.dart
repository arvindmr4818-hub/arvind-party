import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/gift_controller.dart';

class GiftHistoryScreen extends StatelessWidget {
  const GiftHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GiftController controller = Get.find<GiftController>();

    return Scaffold(
      backgroundColor: const Color(0xff0F0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xff15141F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Billing & Gift Ledger Logs",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Obx(() {
              if (controller.transactionHistory.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          color: Colors.white10, size: 54),
                      SizedBox(height: 12),
                      Text("No transaction logs recorded yet.",
                          style:
                              TextStyle(color: Colors.white24, fontSize: 13)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: controller.transactionHistory.length,
                itemBuilder: (context, index) {
                  final log = controller.transactionHistory[index];

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xff15141F),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Sent to ${log.receiverName}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${log.giftName}  x${log.comboMultiplier}",
                              style: const TextStyle(
                                  color: Colors.cyan, fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('yyyy-MM-dd HH:mm')
                                  .format(log.timestamp),
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 10),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text("🪙 ", style: TextStyle(fontSize: 12)),
                            Text(
                              "-${log.totalCoins * log.comboMultiplier}",
                              style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}
