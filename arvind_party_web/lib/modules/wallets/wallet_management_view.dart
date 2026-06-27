// ═══════════════════════════════════════════════════════════════════════════
// WALLET MANAGEMENT VIEW
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../shared/admin_shell.dart';

class WalletManagementView extends StatefulWidget {
  const WalletManagementView({super.key});
  @override
  State<WalletManagementView> createState() => _WalletManagementViewState();
}

class _WalletManagementViewState extends State<WalletManagementView> with SingleTickerProviderStateMixin {
  final _api = Get.find<ApiService>();
  late TabController _tabs;
  List<Map<String, dynamic>> _pending = [];
  bool _isLoading = true;
  Map<String, dynamic> _summary = {};

  @override
  void initState() { super.initState(); _tabs = TabController(length: 2, vsync: this); _load(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final r = await _api.get('/wallet/admin/withdrawals');
      if (r['success'] == true) _pending = List<Map<String, dynamic>>.from(r['data'] ?? []);
      final s = await _api.get('/wallet/admin/transactions');
      if (s['success'] == true) _summary = Map<String, dynamic>.from(s['summary'] ?? {});
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _approve(String id) async {
    await _api.put('/wallet/admin/withdrawals/$id/approve', {});
    Get.snackbar('✅ Approved', 'Withdrawal approved', backgroundColor: const Color(0xFF2ED573), colorText: Colors.black);
    _load();
  }

  Future<void> _reject(String id) async {
    await _api.put('/wallet/admin/withdrawals/$id/reject', {});
    Get.snackbar('Rejected', 'Withdrawal rejected & diamonds refunded', backgroundColor: const Color(0xFFFF4757), colorText: Colors.white);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Wallet Management',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Row(children: [
            Expanded(child: StatCard(title: 'Total Revenue', value: '₹${_summary['totalRevenue'] ?? 0}', icon: Icons.trending_up, color: const Color(0xFF2ED573))),
            const SizedBox(width: 12),
            Expanded(child: StatCard(title: 'Total Withdrawals', value: '₹${_summary['totalWithdrawals'] ?? 0}', icon: Icons.money_off, color: const Color(0xFFFF4757))),
            const SizedBox(width: 12),
            Expanded(child: StatCard(title: 'Pending Approval', value: '${_pending.length}', icon: Icons.pending, color: const Color(0xFFFFD700))),
          ]),
          const SizedBox(height: 20),
          Container(decoration: BoxDecoration(color: const Color(0xFF0F0E1A), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E1D2F))),
            child: TabBar(controller: _tabs, labelColor: const Color(0xFFFF8906), unselectedLabelColor: const Color(0xFF6B7280),
              indicatorColor: const Color(0xFFFF8906),
              tabs: const [Tab(text: '⏳ Pending Withdrawals'), Tab(text: '📊 All Transactions')])),
          const SizedBox(height: 16),
          Expanded(child: TabBarView(controller: _tabs, children: [
            // Pending withdrawals
            LuxuryDataTable(
              isLoading: _isLoading,
              emptyMessage: 'No pending withdrawals 🎉',
              columns: const ['User', 'Phone', 'Amount', 'Method', 'Requested', 'Actions'],
              rows: _pending.map((w) => [
                Text(w['userName'] ?? '—', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text(w['userPhone'] ?? '—', style: const TextStyle(color: Color(0xFFB8B8D1))),
                Text('💎${w['amount'] ?? 0}', style: const TextStyle(color: Color(0xFFFF8906), fontWeight: FontWeight.bold, fontSize: 15)),
                StatusBadge(label: (w['method'] ?? 'UPI').toUpperCase(), color: const Color(0xFF00B4D8)),
                Text(_fmt(w['createdAt']), style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                Row(children: [
                  LuxuryButton(label: 'Approve', icon: Icons.check, color: const Color(0xFF2ED573),
                    onPressed: () => _approve(w['_id'])),
                  const SizedBox(width: 8),
                  LuxuryButton(label: 'Reject', icon: Icons.close, color: const Color(0xFFFF4757),
                    onPressed: () => _reject(w['_id'])),
                ]),
              ]).toList(),
            ),
            // All transactions - reuse TransactionsView logic
            const Center(child: Text('See Transactions page for full history', style: TextStyle(color: Color(0xFF6B7280)))),
          ])),
        ]),
      ),
    );
  }

  String _fmt(dynamic d) {
    if (d == null) return '—';
    try { final dt = DateTime.parse(d.toString()); return '${dt.day}/${dt.month}/${dt.year}'; } catch (_) { return '—'; }
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }
}
