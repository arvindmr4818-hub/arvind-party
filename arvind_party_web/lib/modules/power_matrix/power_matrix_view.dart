import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../shared/admin_shell.dart';

class PowerMatrixView extends StatefulWidget {
  const PowerMatrixView({super.key});
  @override
  State<PowerMatrixView> createState() => _PowerMatrixViewState();
}

class _PowerMatrixViewState extends State<PowerMatrixView> {
  final _api = Get.find<ApiService>();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get('/users/admin/list', queryParams: {'sort': 'power', 'limit': '50'});
      if (res['success'] == true) _users = List<Map<String, dynamic>>.from(res['data'] ?? []);
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Power Matrix',
      child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        const LuxuryCard(child: Padding(
          padding: EdgeInsets.all(4),
          child: Text('Top users by activity, gifts sent, and revenue contribution.',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
        )),
        const SizedBox(height: 16),
        Expanded(child: LuxuryDataTable(
          isLoading: _isLoading,
          emptyMessage: 'No data',
          columns: const ['Rank', 'User', 'Coins Spent', 'Gifts Sent', 'VIP', 'Power Score'],
          rows: _users.asMap().entries.map((e) {
            final u = e.value; final rank = e.key + 1;
            return [
              Text('#$rank', style: const TextStyle(color: Color(0xFFFF8906), fontWeight: FontWeight.bold)),
              Text(u['name'] ?? '—', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              Text('🪙${u['coins'] ?? 0}', style: const TextStyle(color: Color(0xFFFF8906))),
              Text('${u['giftsCount'] ?? 0}', style: const TextStyle(color: Color(0xFFB8B8D1))),
              StatusBadge(label: 'L${u['vipLevel'] ?? 0}', color: const Color(0xFFFFD700)),
              Text('${u['powerScore'] ?? 0}', style: const TextStyle(color: Color(0xFF2ED573), fontWeight: FontWeight.bold)),
            ];
          }).toList(),
        )),
      ])),
    );
  }
}
