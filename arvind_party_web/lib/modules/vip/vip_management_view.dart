
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../shared/admin_shell.dart';

class VipAdminView extends StatefulWidget {
  const VipAdminView({super.key});
  @override
  State<VipAdminView> createState() => _VipAdminViewState();
}

class _VipAdminViewState extends State<VipAdminView> {
  final _api = Get.find<ApiService>();
  List<Map<String, dynamic>> _vipUsers = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  final List<Map<String, dynamic>> _vipLevels = [
    {'level': 1, 'name': 'VIP 1', 'required': 1000, 'color': 0xFF9E9E9E},
    {'level': 2, 'name': 'VIP 2', 'required': 5000, 'color': 0xFF4CAF50},
    {'level': 3, 'name': 'VIP 3', 'required': 20000, 'color': 0xFF2196F3},
    {'level': 4, 'name': 'VIP 4', 'required': 50000, 'color': 0xFF9C27B0},
    {'level': 5, 'name': 'VIP 5', 'required': 100000, 'color': 0xFFFF9800},
    {'level': 6, 'name': 'VIP 6', 'required': 200000, 'color': 0xFFF44336},
    {'level': 7, 'name': 'SVIP 1', 'required': 500000, 'color': 0xFFFFD700},
    {'level': 8, 'name': 'SVIP 2', 'required': 1000000, 'color': 0xFFFF8906},
  ];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get('/vip/admin/stats');
      if (res['success'] == true) _stats = Map<String, dynamic>.from(res['data'] ?? {});
      final users = await _api.get('/vip/admin/top-users');
      if (users['success'] == true) _vipUsers = List<Map<String, dynamic>>.from(users['data'] ?? []);
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'VIP System',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Row(children: [
            Expanded(child: StatCard(title: 'Total VIP Users', value: '${_stats['totalVip'] ?? 0}', icon: Icons.star, color: const Color(0xFFFFD700))),
            const SizedBox(width: 12),
            Expanded(child: StatCard(title: 'SVIP Users', value: '${_stats['svipCount'] ?? 0}', icon: Icons.workspace_premium, color: const Color(0xFFFF8906))),
            const SizedBox(width: 12),
            Expanded(child: StatCard(title: 'VIP Revenue', value: '${_stats['vipRevenue'] ?? 0}', icon: Icons.monetization_on, color: const Color(0xFF2ED573))),
          ]),
          const SizedBox(height: 24),
          // VIP Level Cards
          const Align(alignment: Alignment.centerLeft,
            child: Text('VIP Level Distribution', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4),
            itemCount: _vipLevels.length,
            itemBuilder: (_, i) {
              final level = _vipLevels[i];
              final count = _stats['level${level['level']}Count'] ?? 0;
              return LuxuryCard(
                borderColor: Color(level['color'] as int).withOpacity(0.4),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.star, color: Color(level['color'] as int), size: 16),
                    const SizedBox(width: 6),
                    Text(level['name'] as String, style: TextStyle(color: Color(level['color'] as int), fontWeight: FontWeight.bold, fontSize: 12)),
                  ]),
                  const SizedBox(height: 8),
                  Text('$count', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Min: ${level['required']} spent', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10)),
                ]),
              );
            },
          ),
          const SizedBox(height: 24),
          const Align(alignment: Alignment.centerLeft,
            child: Text('Top VIP Users', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
          const SizedBox(height: 12),
          LuxuryDataTable(
            isLoading: _isLoading,
            emptyMessage: 'No VIP users found',
            columns: const ['User', 'VIP Level', 'Total Spent', 'Diamonds', 'Since'],
            rows: _vipUsers.map((u) => [
              Row(children: [
                CircleAvatar(radius: 16, backgroundColor: const Color(0xFFFF8906),
                  child: Text((u['name'] ?? 'U')[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                const SizedBox(width: 8),
                Text(u['name'] ?? '—', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ]),
              Row(children: [
                const Icon(Icons.star, color: Color(0xFFFFD700), size: 14),
                const SizedBox(width: 4),
                Text('Level ${u['vipLevel'] ?? 0}', style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
              ]),
              Text('💎 ${u['totalSpent'] ?? 0}', style: const TextStyle(color: Color(0xFF2ED573), fontWeight: FontWeight.bold)),
              Text('${u['diamonds'] ?? 0}', style: const TextStyle(color: Color(0xFF00B4D8))),
              Text(_fmt(u['vipSince']), style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
            ]).toList(),
          ),
        ]),
      ),
    );
  }

  String _fmt(dynamic d) {
    if (d == null) return '—';
    try { final dt = DateTime.parse(d.toString()); return '${dt.day}/${dt.month}/${dt.year}'; } catch (_) { return '—'; }
  }
}
