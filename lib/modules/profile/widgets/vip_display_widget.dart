import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../controllers/vip_controller.dart';

class VipDisplayWidget extends StatelessWidget {
  final VipController controller = Get.put(VipController());

  VipDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFD700)),
        );
      }

      final vip = controller.vipData.value;

      // UI for Non-VIP Users
      if (!vip.isVip) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xff15141F),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              const Icon(Icons.workspace_premium, color: Colors.white38, size: 40),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Not a VIP', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Text('Upgrade to unlock premium perks!', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 5,
                  shadowColor: const Color(0xFFFFD700).withOpacity(0.4),
                ),
                onPressed: () => controller.startRazorpayCheckout(),
                child: const Text('Upgrade', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        );
      }

      // UI for Active VIP Users
      return Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFF8C00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xff15141F),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Shimmer.fromColors(
                    baseColor: const Color(0xFFFFD700),
                    highlightColor: Colors.white,
                    child: const Icon(Icons.diamond, size: 30),
                  ),
                  const SizedBox(width: 10),
                  Text('VIP Level ${vip.level}', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.w900)),
                  const Spacer(),
                  if (vip.expiryDate != null)
                    Text('Valid till: ${DateFormat('MMM dd, yyyy').format(vip.expiryDate!)}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Active Perks:', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: vip.perks.map((perk) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3))),
                  child: Text(perk, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11)),
                )).toList(),
              )
            ],
          ),
        ),
      );
    });
  }
}