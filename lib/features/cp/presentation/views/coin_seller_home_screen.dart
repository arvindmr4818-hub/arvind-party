import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/coin_seller_controller.dart';

class CoinSellerHomeScreen extends GetView<CoinSellerController> {
  const CoinSellerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coin Sellers'), backgroundColor: const Color(0xFF15141F)),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.sellers.length,
          itemBuilder: (context, index) {
            final seller = controller.sellers[index];
            IconData typeIcon;
            Color typeColor;
            switch (seller.type) {
              case 'super':
                typeIcon = Icons.star;
                typeColor = Colors.amber;
                break;
              case 'official':
                typeIcon = Icons.verified;
                typeColor = Colors.blue;
                break;
              default:
                typeIcon = Icons.person;
                typeColor = Colors.grey;
            }
            return Card(
              color: const Color(0xFF1A1A2E),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: typeColor.withValues(alpha: 0.2),
                  child: Icon(typeIcon, color: typeColor),
                ),
                title: Text(seller.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${seller.type.toUpperCase()} Seller', style: TextStyle(color: typeColor, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('${seller.coinsAvailable} coins available', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$${seller.pricePerCoin.toStringAsFixed(2)}/coin', style: const TextStyle(color: const Color(0xFFFF8906), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text(seller.rating.toString(), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                onTap: () => Get.to(() => CoinSellerDetailScreen(seller: seller)),
              ),
            );
          },
        );
      }),
    );
  }
}

class CoinSellerDetailScreen extends StatelessWidget {
  final dynamic seller;
  const CoinSellerDetailScreen({super.key, required this.seller});

  @override
  Widget build(BuildContext context) {
    final coinCtrl = TextEditingController();
    final controller = Get.find<CoinSellerController>();
    return Scaffold(
      appBar: AppBar(title: Text(seller.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: const Color(0xFF1A1A2E),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(seller.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('${seller.type.toUpperCase()} Seller', style: const TextStyle(color: Colors.amber)),
                    const SizedBox(height: 16),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      _statItem('Coins', '${seller.coinsAvailable}', Colors.orange),
                      _statItem('Rating', seller.rating.toString(), Colors.amber),
                      _statItem('Sales', '${seller.totalSales}', Colors.green),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Request Recharge', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: coinCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Number of Coins',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.monetization_on, color: Color(0xFFFF8906)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final coins = int.tryParse(coinCtrl.text) ?? 0;
                  if (coins > 0) {
                    final amount = coins * (seller.pricePerCoin as double);
                    controller.submitRechargeRequest(seller.id, seller.name, coins, amount);
                    coinCtrl.clear();
                    Get.back();
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8906), padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Submit Request', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

class CoinSellerProfileScreen extends GetView<CoinSellerController> {
  const CoinSellerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seller Profile'), backgroundColor: const Color(0xFF15141F)),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (controller.sellers.isEmpty) return const Center(child: Text('No sellers', style: TextStyle(color: Colors.grey)));
        final seller = controller.sellers.first;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            color: const Color(0xFF1A1A2E),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(radius: 40, backgroundColor: Colors.amber.withValues(alpha: 0.2), child: const Icon(Icons.store, color: Colors.amber, size: 40)),
                        const SizedBox(height: 8),
                        Text(seller.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('${seller.type.toUpperCase()} Seller', style: const TextStyle(color: Colors.amber, fontSize: 14)),
                      ],
                    ),
                  ),
                  const Divider(height: 32),
                  _infoRow('Phone', seller.phone ?? 'N/A'),
                  _infoRow('Coins Available', '${seller.coinsAvailable}'),
                  _infoRow('Price per Coin', '\$${seller.pricePerCoin.toStringAsFixed(2)}'),
                  _infoRow('Total Sales', '${seller.totalSales}'),
                  _infoRow('Rating', seller.rating.toString()),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class CoinSellerRankingScreen extends StatelessWidget {
  const CoinSellerRankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CoinSellerController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Seller Ranking'), backgroundColor: const Color(0xFF15141F)),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        final sorted = List<dynamic>.from(controller.sellers)..sort((a, b) => b.rating.compareTo(a.rating));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sorted.length,
          itemBuilder: (context, index) {
            final seller = sorted[index];
            return Card(
              color: const Color(0xFF1A1A2E),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: index < 3 ? Colors.amber : Colors.grey.withValues(alpha: 0.2),
                  child: Text('${index + 1}', style: TextStyle(color: index < 3 ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                ),
                title: Text(seller.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text('${seller.totalSales} sales', style: const TextStyle(color: Colors.grey)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(seller.rating.toString(), style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class RechargeHistoryScreen extends GetView<CoinSellerController> {
  const RechargeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recharge History'), backgroundColor: const Color(0xFF15141F)),
      body: Obx(() {
        if (controller.rechargeRequests.isEmpty) {
          return const Center(child: Text('No recharge requests', style: TextStyle(color: Colors.grey)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.rechargeRequests.length,
          itemBuilder: (context, index) {
            final req = controller.rechargeRequests[index];
            Color statusColor;
            switch (req.status) {
              case 'completed':
                statusColor = Colors.green;
                break;
              case 'pending':
                statusColor = Colors.orange;
                break;
              case 'rejected':
                statusColor = Colors.red;
                break;
              default:
                statusColor = Colors.grey;
            }
            return Card(
              color: const Color(0xFF1A1A2E),
              child: ListTile(
                leading: const Icon(Icons.history, color: Color(0xFFFF8906)),
                title: Text('${req.coins} coins from ${req.sellerName}', style: const TextStyle(color: Colors.white)),
                subtitle: Text('\$${req.amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                  child: Text(req.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class SettlementHistoryScreen extends GetView<CoinSellerController> {
  const SettlementHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settlement History'), backgroundColor: const Color(0xFF15141F)),
      body: Obx(() {
        if (controller.settlementHistory.isEmpty) {
          return const Center(child: Text('No settlements', style: TextStyle(color: Colors.grey)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.settlementHistory.length,
          itemBuilder: (context, index) {
            final st = controller.settlementHistory[index];
            return Card(
              color: const Color(0xFF1A1A2E),
              child: ListTile(
                leading: const Icon(Icons.account_balance, color: Color(0xFFFF8906)),
                title: Text('\$${st.amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(st.status.toUpperCase(), style: TextStyle(color: st.status == 'completed' ? Colors.green : Colors.orange)),
              ),
            );
          },
        );
      }),
    );
  }
}