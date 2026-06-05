import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/agency_salary_controller.dart';
import '../widgets/salary_card.dart';

class AgencySalaryScreen extends StatelessWidget {
  const AgencySalaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject and locate financial controller context
    final AgencySalaryController salaryController =
        Get.put(AgencySalaryController());

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
          "Payouts & Escrow Ledger",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Active Cycle Monitoring Strip Indicator
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: Colors.greenAccent.withOpacity(0.15)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Current Billing Cycle Track",
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 10)),
                          const SizedBox(height: 2),
                          Obx(() => Text(
                                salaryController.activeBillingCycle.value
                                    .replaceAll('_', ' '),
                                style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              )),
                        ],
                      ),
                      Obx(() {
                        bool locked = salaryController.isCalculating.value;
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                          ),
                          onPressed: locked
                              ? null
                              : () =>
                                  salaryController.lockingSettlementsEscrow(),
                          child: locked
                              ? const SizedBox(
                                  height: 14,
                                  width: 14,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 1.5, color: Colors.black))
                              : const Text("Release Cycle 🚀",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  "Calculated Earnings Distributed Ledgers",
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),

                // Financial lists mappings array viewports
                Expanded(
                  child: Obx(() {
                    if (salaryController.automatedSalariesList.isEmpty) {
                      return const Center(
                          child: Text("Ledgers are completely empty.",
                              style: TextStyle(color: Colors.white24)));
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: salaryController.automatedSalariesList.length,
                      itemBuilder: (context, index) {
                        final salaryNode =
                            salaryController.automatedSalariesList[index];
                        return SalaryCard(salary: salaryNode);
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
