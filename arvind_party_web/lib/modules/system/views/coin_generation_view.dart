import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/web_theme.dart';
import '../../../shared/widgets/admin_scaffold.dart';
import '../controllers/coin_generation_controller.dart';

class CoinGenerationView extends GetView<CoinGenerationController> {
  const CoinGenerationView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Coin Generation',
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generate Coins',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Generate and credit coins to a user account.',
                        style: TextStyle(
                          color: WebTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ─── User UID ─────────────────────────
                      TextFormField(
                        controller: controller.uidController,
                        decoration: const InputDecoration(
                          labelText: 'User UID *',
                          hintText: 'Enter the user UID',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a UID';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // ─── Coin Amount ──────────────────────
                      TextFormField(
                        controller: controller.amountController,
                        decoration: const InputDecoration(
                          labelText: 'Coin Amount *',
                          hintText: 'Enter number of coins',
                          prefixIcon: Icon(Icons.token),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an amount';
                          }
                          final amount = int.tryParse(value.trim());
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid positive number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // ─── Audit Description ─────────────────
                      TextFormField(
                        controller: controller.reasonController,
                        decoration: const InputDecoration(
                          labelText: 'Audit Description',
                          hintText: 'Reason for this coin generation',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),

                      // ─── Submit ───────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: Obx(() => ElevatedButton(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : controller.handleSubmit,
                          child: controller.isSubmitting.value
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text(
                                  'Generate Coins',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}