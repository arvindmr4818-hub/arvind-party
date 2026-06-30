import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/wallet_controller.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(WalletController());

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12111F),
        title: const Text('My Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: Get.back),
      ),
      body: RefreshIndicator(
        color: const Color(0xFFFF8906),
        onRefresh: ctrl.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            // Balance cards
            Row(children: [
              Expanded(child: _BalanceCard(icon: Icons.monetization_on, label: 'Coins',
                balance: ctrl.coins, color: const Color(0xFFFF8906))),
              const SizedBox(width: 12),
              Expanded(child: _BalanceCard(icon: Icons.diamond, label: 'Diamonds',
                balance: ctrl.diamonds, color: const Color(0xFF00B4D8))),
            ]),
            const SizedBox(height: 24),

            // Recharge section
            const Align(alignment: Alignment.centerLeft,
              child: Text('Recharge Coins', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.2),
              itemCount: ctrl.rechargePlans.length,
              itemBuilder: (_, i) {
                final plan = ctrl.rechargePlans[i];
                return GestureDetector(
                  onTap: () => ctrl.startRecharge(plan),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF1E1D35), Color(0xFF252340)]),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFF8906).withOpacity(0.3)),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.monetization_on, color: Color(0xFFFF8906), size: 28),
                      const SizedBox(height: 6),
                      Text('${plan['coins']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      const Text('coins', style: TextStyle(color: Color(0xFFB0B0C0), fontSize: 11)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFFFF8906), borderRadius: BorderRadius.circular(10)),
                        child: Text('₹${plan['price']}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ]),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Withdraw
            const Align(alignment: Alignment.centerLeft,
              child: Text('Withdraw Diamonds', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF12111F),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(children: [
                Obx(() => Row(children: [
                  const Icon(Icons.diamond, color: Color(0xFF00B4D8), size: 20),
                  const SizedBox(width: 8),
                  Text('Available: ${ctrl.diamonds.value} diamonds',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ])),
                const SizedBox(height: 12),
                TextField(
                  controller: ctrl.withdrawAmountCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter amount (min 500)',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true, fillColor: Colors.white10,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.diamond, color: Color(0xFF00B4D8), size: 18),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: Obx(() => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B4D8), foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: ctrl.isWithdrawing.value ? null : ctrl.submitWithdrawal,
                  child: ctrl.isWithdrawing.value
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text('Request Withdrawal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ))),
              ]),
            ),
            const SizedBox(height: 24),

            // Transaction history
            const Align(alignment: Alignment.centerLeft,
              child: Text('Transaction History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
            const SizedBox(height: 12),
            Obx(() => ctrl.transactions.isEmpty
              ? const Center(child: Padding(padding: EdgeInsets.all(20),
                  child: Text('No transactions yet', style: TextStyle(color: Colors.white38))))
              : ListView.separated(
                  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  itemCount: ctrl.transactions.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
                  itemBuilder: (_, i) {
                    final t = ctrl.transactions[i];
                    final isPositive = (t['amount'] as int? ?? 0) > 0;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isPositive ? const Color(0xFF2ED573).withOpacity(0.15) : const Color(0xFFFF4757).withOpacity(0.15),
                        child: Icon(isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isPositive ? const Color(0xFF2ED573) : const Color(0xFFFF4757), size: 18),
                      ),
                      title: Text(t['description'] ?? t['type'] ?? '—', style: const TextStyle(color: Colors.white, fontSize: 14)),
                      subtitle: Text(_fmt(t['createdAt']), style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      trailing: Text('${isPositive ? '+' : ''}${t['amount']}',
                        style: TextStyle(
                          color: isPositive ? const Color(0xFF2ED573) : const Color(0xFFFF4757),
                          fontWeight: FontWeight.bold, fontSize: 15)),
                    );
                  },
                )),
          ]),
        ),
      ),
    );
  }

  String _fmt(dynamic d) {
    if (d == null) return '';
    try {
      final dt = DateTime.parse(d.toString());
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) { return ''; }
  }
}

class _BalanceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final RxInt balance;
  final Color color;
  const _BalanceCard({required this.icon, required this.label, required this.balance, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [color.withOpacity(0.15), color.withOpacity(0.05)]),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 28),
      const SizedBox(height: 12),
      Obx(() => Text('${balance.value}', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold))),
      Text(label, style: TextStyle(color: color, fontSize: 13)),
    ]),
  );
}
