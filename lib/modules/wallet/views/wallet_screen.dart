import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/wallet_controller.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WalletController controller = Get.put(WalletController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Wallet'),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Wallet"),
              Tab(text: "Recharge"),
              Tab(text: "History"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildWalletTab(controller),
            _buildRechargeTab(controller),
            _buildHistoryTab(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletTab(WalletController controller) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Colors.orange.shade100,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text("Coins", style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Text("${controller.coins.value}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            color: Colors.purple.shade100,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text("Diamonds", style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Text("${controller.diamonds.value}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.purple)),
                ],
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              Get.snackbar("Withdraw", "Minimum withdrawal not reached.");
            },
            child: const Text("Withdraw Diamonds"),
          )
        ],
      )),
    );
  }

  Widget _buildRechargeTab(WalletController controller) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        itemCount: controller.rechargePlans.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.5,
        ),
        itemBuilder: (_, index) {
          final plan = controller.rechargePlans[index];
          return GestureDetector(
            onTap: () {
              controller.recharge(plan);
            },
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.orange, size: 30),
                  const SizedBox(height: 10),
                  Text("$plan Coins", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryTab(WalletController controller) {
    return Obx(() {
      if (controller.transactions.isEmpty) {
        return const Center(child: Text("No Transactions"));
      }
      return ListView.builder(
        itemCount: controller.transactions.length,
        itemBuilder: (_, index) {
          final tx = controller.transactions[controller.transactions.length - 1 - index];
          return ListTile(
            leading: Icon(
              tx.type == 'recharge' || tx.type == 'gift_received' || tx.type == 'bonus'
                  ? Icons.add_circle 
                  : Icons.remove_circle,
              color: tx.type == 'recharge' || tx.type == 'gift_received' || tx.type == 'bonus'
                  ? Colors.green 
                  : Colors.red,
            ),
            title: Text(tx.title),
            subtitle: Text(tx.createdAt.toString().split('.')[0]),
            trailing: Text(
              tx.type == 'recharge' || tx.type == 'gift_received' || tx.type == 'bonus'
                  ? "+${tx.amount}" 
                  : "-${tx.amount}",
              style: TextStyle(
                color: tx.type == 'recharge' || tx.type == 'gift_received' || tx.type == 'bonus'
                    ? Colors.green 
                    : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      );
    });
  }
}
