// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/vip_system/views/vip_screen.dart
// ARVIND PARTY - VIP SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vip_controller.dart';
import '../widgets/vip_tier_card.dart';
import '../widgets/payment_dialog.dart';

class VIPScreen extends StatelessWidget {
  const VIPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VIPController>(
      init: VIPController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('VIP Membership'),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Current VIP Status
                _buildVIPStatusCard(controller),

                const SizedBox(height: 24),

                // VIP Tiers List
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (controller.vipTiers.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No VIP tiers available'),
                      ),
                    );
                  }

                  return Column(
                    children: controller.vipTiers.map((tier) {
                      final currentTier = controller.userVIPStatus.value?.vipTier;
                      final isCurrentTier = tier.id == currentTier;

                      return VIPTierCard(
                        tier: tier,
                        isCurrentTier: isCurrentTier,
                        onSelect: !isCurrentTier
                            ? () => _showPurchaseDialog(context, controller, tier)
                            : () {},
                      );
                    }).toList(),
                  );
                }),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVIPStatusCard(VIPController controller) {
    return Obx(() {
      final status = controller.userVIPStatus.value;

      if (status == null || status.vipTier == 'free') {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF9F7AEA)],
            ),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'No VIP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Upgrade to enjoy premium features',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        );
      }

      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00B894), Color(0xFF00D2D3)],
          ),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  status.vipTier.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.verified, color: Colors.white, size: 24),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: controller.getDaysRemaining() / 30,
              minHeight: 6,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              'Days Remaining: ${controller.getDaysRemaining()}',
              style: const TextStyle(color: Colors.white70),
            ),
            if (controller.getDaysRemaining() <= 7)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: ElevatedButton(
                  onPressed: null,
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.white),
                  ),
                  child: Text(
                    'Renew Now',
                    style: TextStyle(color: Color(0xFF00B894)),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  void _showPurchaseDialog(
    BuildContext context,
    VIPController controller,
    dynamic tier,
  ) {
    showDialog(
      context: context,
      builder: (context) => PaymentDialog(
        tier: tier,
        isLoading: controller.isLoading.value,
        onPaymentMethodSelected: (method) {
          controller.purchaseVIP(tier);
        },
      ),
    );
  }
}