import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class UserProfileView extends StatelessWidget {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile & Cash Out')),
      body: Obx(() => controller.isLoading.value 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Join Agency', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.currentAgencyId.value.isNotEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Text('Joined Agency: ${controller.currentAgencyId.value}', 
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller.agencyIdController,
                    decoration: const InputDecoration(labelText: 'Enter Agency ID', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.joinAgency,
                    child: const Text('JOIN AGENCY'),
                  ),
                ],
              );
            }),
            
            const Divider(height: 48, thickness: 2),
            
            const Text('Request Cash Out', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: controller.cashOutCoinsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Coins to Withdraw', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.paymentDetailsController,
              decoration: const InputDecoration(labelText: 'Bank/PayPal Details', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.requestCashOut,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('SUBMIT REQUEST'),
            ),
          ],
        ),
      )),
    );
  }
}