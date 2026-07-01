import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../shared/admin_shell.dart';

class GamesAdminView extends StatefulWidget {
  const GamesAdminView({super.key});
  @override
  State<GamesAdminView> createState() => _GamesAdminViewState();
}

class _GamesAdminViewState extends State<GamesAdminView> {
  final _api = Get.find<ApiService>();
  List<Map<String, dynamic>> _logs = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final s = await _api.get('/games/admin/stats');
      if (s['success'] == true) _stats = Map<String, dynamic>.from(s['data'] ?? {});
      final l = await _api.get('/games/admin/logs');
      if (l['success'] == true) _logs = List<Map<String, dynamic>>.from(l['data'] ?? []);
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Games Management',
      child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        Row(children: [
          Expanded(child: StatCard(title: 'Total Played', value: '${_stats['totalPlayed'] ?? 0}', icon: Icons.sports_esports, color: const Color(0xFFFF8906))),
          const SizedBox(width: 12),
          Expanded(child: StatCard(title: 'Coins Won', value: '${_stats['coinsWon'] ?? 0}', icon: Icons.emoji_events, color: const Color(0xFFFFD700))),
          const SizedBox(width: 12),
          Expanded(child: StatCard(title: 'Coins Collected', value: '${_stats['coinsCollected'] ?? 0}', icon: Icons.monetization_on, color: const Color(0xFF2ED573))),
          const SizedBox(width: 12),
          Expanded(child: StatCard(title: 'House Edge', value: '${_stats['houseEdge'] ?? 0}%', icon: Icons.trending_up, color: const Color(0xFF00B4D8))),
        ]),
        const SizedBox(height: 20),
        Expanded(child: LuxuryDataTable(
          isLoading: _isLoading,
          emptyMessage: 'No game logs yet',
          columns: const ['User', 'Game', 'Bet', 'Win/Loss', 'Result', 'Time'],
          rows: _logs.map((g) => [
            Text(g['userName'] ?? '—', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            StatusBadge(label: (g['gameType'] ?? 'game').toUpperCase(), color: const Color(0xFFFF8906)),
            Text('🪙${g['betAmount'] ?? 0}', style: const TextStyle(color: Color(0xFFB8B8D1))),
            Text('${(g['winAmount'] ?? 0) > 0 ? '+' : ''}🪙${g['winAmount'] ?? 0}',
              style: TextStyle(color: (g['winAmount'] ?? 0) > 0 ? const Color(0xFF2ED573) : const Color(0xFFFF4757), fontWeight: FontWeight.bold)),
            StatusBadge(label: (g['result'] ?? 'played').toUpperCase(),
              color: g['result'] == 'win' ? const Color(0xFF2ED573) : const Color(0xFFFF4757)),
            Text(_fmt(g['createdAt']), style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
          ]).toList(),
        )),
      ])),
    );
  }

  String _fmt(dynamic d) {
    if (d == null) return '—';
    try { final dt = DateTime.parse(d.toString()); return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2,'0')}'; } catch (_) { return '—'; }
  }
}
