import 'package:flutter/material.dart';

class WithdrawalManagementView extends StatelessWidget {
  const WithdrawalManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Withdrawal Management'), centerTitle: true),
      body: const Center(child: Text('Withdrawal Management View')),
    );
  }
}