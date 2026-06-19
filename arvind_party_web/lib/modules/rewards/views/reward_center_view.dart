import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/web_theme.dart';
import '../../../shared/widgets/admin_scaffold.dart';
import '../controllers/rewards_controller.dart';

class RewardCenterView extends GetView<RewardsController> {
  const RewardCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Rewards Center',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Coin Control Section ──────────────────────
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Coin Control',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: controller.coinUidCtrl,
                        decoration: const InputDecoration(
                          labelText: 'User UID *',
                          hintText: 'Enter user UID',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.coinAmountCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Coin Amount *',
                          hintText: 'Enter amount',
                          prefixIcon: Icon(Icons.token),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.coinReasonCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Audit Description',
                          hintText: 'Reason for this operation',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() => ElevatedButton(
                              onPressed:
                                  controller.isGeneratingCoins.value ? null : controller.generateCoins,
                              child: controller.isGeneratingCoins.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    )
                                  : const Text('Generate Coins'),
                            )),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Obx(() => ElevatedButton(
                              onPressed:
                                  controller.isDeductingCoins.value ? null : controller.deductCoins,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: WebTheme.errorRed,
                                foregroundColor: Colors.white,
                              ),
                              child: controller.isDeductingCoins.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Deduct Coins'),
                            )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),

            // ─── Reward Center Section ─────────────────────
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Send Reward',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: controller.rewardUidCtrl,
                        decoration: const InputDecoration(
                          labelText: 'User UID *',
                          hintText: 'Enter user UID',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(() => DropdownButtonFormField<String>(
                        initialValue: controller.selectedRewardType.value,
                        decoration: const InputDecoration(
                          labelText: 'Reward Type',
                          prefixIcon: Icon(Icons.workspace_premium),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'VIP', child: Text('VIP Status')),
                          DropdownMenuItem(value: 'FRAME', child: Text('Frame')),
                          DropdownMenuItem(value: 'CAR', child: Text('Car')),
                          DropdownMenuItem(value: 'DIAMONDS', child: Text('Diamonds')),
                          DropdownMenuItem(value: 'COINS', child: Text('Coins')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedRewardType.value = value;
                          }
                        },
                      )),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.rewardQuantityCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          hintText: '1',
                          prefixIcon: Icon(Icons.numbers),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: Obx(() => ElevatedButton(
                          onPressed: controller.isSendingReward.value
                              ? null
                              : controller.sendReward,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF64B5F6),
                            foregroundColor: Colors.white,
                          ),
                          child: controller.isSendingReward.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Send Reward'),
                        )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}