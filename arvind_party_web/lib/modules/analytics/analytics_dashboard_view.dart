import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../shared/admin_shell.dart';

class AnalyticsDashboardView extends StatefulWidget {
  const AnalyticsDashboardView({super.key});
  @override
  State<AnalyticsDashboardView> createState() => _AnalyticsDashboardViewState();
}

class _AnalyticsDashboardViewState extends State<AnalyticsDashboardView> {
  final _api = Get.find<ApiService>();
  Map<String, dynamic> _data = {};
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get('/analytics/dashboard');
      if (res['success'] == true) _data = Map<String, dynamic>.from(res['data'] ?? {});
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Analytics',
      child: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF8906)))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Row(children: [
                Expanded(child: StatCard(title: 'DAU', value: '${_data['dau'] ?? 0}', icon: Icons.people, color: const Color(0xFFFF8906))),
                const SizedBox(width: 12),
                Expanded(child: StatCard(title: 'MAU', value: '${_data['mau'] ?? 0}', icon: Icons.calendar_month, color: const Color(0xFF00B4D8))),
                const SizedBox(width: 12),
                Expanded(child: StatCard(title: 'Retention', value: '${_data['retention'] ?? 0}%', icon: Icons.loop, color: const Color(0xFF2ED573))),
                const SizedBox(width: 12),
                Expanded(child: StatCard(title: 'ARPU', value: '₹${_data['arpu'] ?? 0}', icon: Icons.trending_up, color: const Color(0xFFFFD700))),
              ]),
              const SizedBox(height: 20),
              LuxuryCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('App Analytics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                _row('Total Sessions', '${_data['totalSessions'] ?? 0}'),
                _row('Avg Session Duration', '${_data['avgSessionDuration'] ?? 0} min'),
                _row('Crash Free Rate', '${_data['crashFreeRate'] ?? 99.9}%'),
                _row('Push Notification CTR', '${_data['pushCtr'] ?? 0}%'),
              ])),
            ]),
          ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      Text(label, style: const TextStyle(color: Color(0xFF6B7280))),
      const Spacer(),
      Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ]),
  );
}
