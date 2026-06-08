import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/coin_control_controller.dart';
import 'package:intl/intl.dart';

class CoinControlView extends StatelessWidget {
  const CoinControlView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CoinControlController());

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        title: const Text("Treasury & Coin Control", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF15141F),
      ),
      body: Row(
        children: [
          // Action Panel
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: Colors.white12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Update User Balance", 
                    style: TextStyle(color: Colors.orangeAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildTextField(controller.uidController, "Target User UID", Icons.person),
                  const SizedBox(height: 16),
                  _buildTextField(controller.amountController, "Amount", Icons.monetization_on, isNumber: true),
                  const SizedBox(height: 16),
                  _buildTextField(controller.reasonController, "Reason / Audit Note", Icons.edit, maxLines: 3),
                  const SizedBox(height: 32),
                  Obx(() => controller.isLoading.value 
                    ? const Center(child: CircularProgressIndicator())
                    : Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => controller.processCoinAction(true),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 20)),
                              child: const Text("GENERATE COINS", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => controller.processCoinAction(false),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 20)),
                              child: const Text("DEDUCT COINS", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ),
          // Logs Panel
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Treasury Audit Logs", style: TextStyle(color: Colors.white70, fontSize: 18)),
                      IconButton(onPressed: controller.fetchTreasuryLogs, icon: const Icon(Icons.refresh, color: Colors.cyan)),
                    ],
                  ),
                ),
                Expanded(
                  child: Obx(() => ListView.builder(
                    itemCount: controller.treasuryLogs.length,
                    itemBuilder: (context, index) {
                      final log = controller.treasuryLogs[index];
                      return ListTile(
                        leading: Icon(
                          log['type'] == 'GENERATE' ? Icons.add_circle : Icons.remove_circle,
                          color: log['type'] == 'GENERATE' ? Colors.green : Colors.red,
                        ),
                        title: Text("UID: ${log['targetUid']} - Amount: ${log['amount']}", style: const TextStyle(color: Colors.white)),
                        subtitle: Text("By: ${log['adminName']} | Reason: ${log['reason']}", style: const TextStyle(color: Colors.white38)),
                        trailing: Text(
                          DateFormat('dd MMM, HH:mm').format(DateTime.parse(log['createdAt'])),
                          style: const TextStyle(color: Colors.white24, fontSize: 12),
                        ),
                      );
                    },
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.orangeAccent),
        filled: true,
        fillColor: const Color(0xFF15141F),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}