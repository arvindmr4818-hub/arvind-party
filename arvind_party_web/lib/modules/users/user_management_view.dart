// ═══════════════════════════════════════════════════════════════════════════
// USER MANAGEMENT VIEW — Complete Production Level
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../shared/admin_shell.dart';

class UserManagementView extends StatefulWidget {
  const UserManagementView({super.key});
  @override
  State<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> with SingleTickerProviderStateMixin {
  final _api = Get.find<ApiService>();
  late TabController _tabs;
  List<Map<String, dynamic>> _users = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  final _searchCtrl = TextEditingController();
  String _filter = 'all';
  int _page = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  Future<void> _load({bool reset = true}) async {
    if (reset) { _page = 1; _hasMore = true; }
    setState(() => _isLoading = true);
    try {
      final params = {
        'page': '$_page', 'limit': '20',
        if (_searchCtrl.text.isNotEmpty) 'search': _searchCtrl.text,
        if (_filter != 'all') 'status': _filter,
      };
      final res = await _api.get('/users/admin/list', queryParams: params);
      if (res['success'] == true) {
        final newUsers = List<Map<String, dynamic>>.from(res['data'] ?? []);
        if (reset) _users = newUsers;
        else _users.addAll(newUsers);
        _hasMore = newUsers.length == 20;
      }
      final statsRes = await _api.get('/users/admin/stats');
      if (statsRes['success'] == true) _stats = Map<String, dynamic>.from(statsRes['data'] ?? {});
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _banUser(String id, String name) async {
    final reason = await _showInputDialog('Ban User', 'Enter ban reason for $name');
    if (reason == null) return;
    final res = await _api.post('/admin/users/$id/ban', {'reason': reason});
    if (res['success'] == true) {
      Get.snackbar('Banned', '$name has been banned', backgroundColor: const Color(0xFFFF4757), colorText: Colors.white);
      _load();
    }
  }

  Future<void> _unbanUser(String id, String name) async {
    await _api.post('/admin/users/$id/unban', {});
    Get.snackbar('Unbanned', '$name has been unbanned', backgroundColor: const Color(0xFF2ED573), colorText: Colors.black);
    _load();
  }

  Future<void> _addCoins(String id, String name) async {
    Get.toNamed('/coin-manager');
  }

  Future<void> _viewProfile(Map<String, dynamic> user) async {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF1A1928),
      title: Row(children: [
        CircleAvatar(radius: 20, backgroundColor: const Color(0xFFFF8906),
          child: Text((user['name'] ?? 'U')[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(user['name'] ?? '—', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(user['arvindId'] ?? '', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
        ])),
      ]),
      content: SizedBox(width: 420, child: Column(mainAxisSize: MainAxisSize.min, children: [
        _infoRow('Phone', user['phone'] ?? '—'),
        _infoRow('Email', user['email'] ?? '—'),
        _infoRow('Coins', '🪙 ${user['coins'] ?? 0}'),
        _infoRow('Diamonds', '💎 ${user['diamonds'] ?? 0}'),
        _infoRow('VIP Level', 'Level ${user['vipLevel'] ?? 0}'),
        _infoRow('Status', user['isBanned'] == true ? '🚫 Banned' : '✅ Active'),
        _infoRow('Joined', _fmt(user['createdAt'])),
        _infoRow('Last Login', _fmt(user['lastLoginAt'])),
      ])),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        if (user['isBanned'] != true)
          LuxuryButton(label: 'Ban', icon: Icons.block, color: const Color(0xFFFF4757),
            onPressed: () { Get.back(); _banUser(user['_id'], user['name']); })
        else
          LuxuryButton(label: 'Unban', icon: Icons.check, color: const Color(0xFF2ED573),
            onPressed: () { Get.back(); _unbanUser(user['_id'], user['name']); }),
      ],
    ));
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      SizedBox(width: 90, child: Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13))),
      Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))),
    ]),
  );

  Future<String?> _showInputDialog(String title, String hint) async {
    final ctrl = TextEditingController();
    return showDialog<String>(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF1A1928),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      content: TextField(controller: ctrl, style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Color(0xFF6B7280)),
          filled: true, fillColor: const Color(0xFF0F0E1A),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF1E1D2F))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF1E1D2F))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFF8906))))),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8906)),
          onPressed: () => Get.back(result: ctrl.text),
          child: const Text('Confirm', style: TextStyle(color: Colors.black))),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'User Management',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // Stats
          Row(children: [
            Expanded(child: StatCard(title: 'Total Users', value: '${_stats['total'] ?? 0}', icon: Icons.people, color: const Color(0xFFFF8906))),
            const SizedBox(width: 12),
            Expanded(child: StatCard(title: 'New Today', value: '${_stats['newToday'] ?? 0}', icon: Icons.person_add, color: const Color(0xFF2ED573))),
            const SizedBox(width: 12),
            Expanded(child: StatCard(title: 'Active (7d)', value: '${_stats['active7d'] ?? 0}', icon: Icons.trending_up, color: const Color(0xFF00B4D8))),
            const SizedBox(width: 12),
            Expanded(child: StatCard(title: 'Banned', value: '${_stats['banned'] ?? 0}', icon: Icons.block, color: const Color(0xFFFF4757))),
          ]),
          const SizedBox(height: 20),
          // Search + filters
          Row(children: [
            Expanded(child: LuxurySearchBar(controller: _searchCtrl, hint: 'Search by name, phone, Arvind ID...', onChanged: _load)),
            const SizedBox(width: 12),
            ...[['all','All'],['active','Active'],['banned','Banned'],['vip','VIP']].map((f) =>
              Padding(padding: const EdgeInsets.only(left: 8), child: FilterChip(
                label: Text(f[1], style: const TextStyle(fontSize: 11)),
                selected: _filter == f[0],
                selectedColor: const Color(0xFFFF8906).withOpacity(0.2),
                labelStyle: TextStyle(color: _filter == f[0] ? const Color(0xFFFF8906) : const Color(0xFF6B7280)),
                side: BorderSide(color: _filter == f[0] ? const Color(0xFFFF8906) : const Color(0xFF1E1D2F)),
                backgroundColor: const Color(0xFF0F0E1A),
                onSelected: (_) { setState(() => _filter = f[0]); _load(); },
              ))),
          ]),
          const SizedBox(height: 20),
          Expanded(child: LuxuryDataTable(
            isLoading: _isLoading,
            emptyMessage: 'No users found',
            columns: const ['User', 'Phone', 'Balance', 'VIP', 'Status', 'Joined', 'Actions'],
            rows: _users.map((u) => [
              Row(children: [
                CircleAvatar(radius: 16, backgroundColor: const Color(0xFFFF8906),
                  child: Text((u['name'] ?? 'U')[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                const SizedBox(width: 8),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(u['name'] ?? '—', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(u['arvindId'] ?? '', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10)),
                ]),
              ]),
              Text(u['phone'] ?? '—', style: const TextStyle(color: Color(0xFFB8B8D1), fontSize: 12)),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('🪙 ${u['coins'] ?? 0}', style: const TextStyle(color: Color(0xFFFF8906), fontSize: 12)),
                Text('💎 ${u['diamonds'] ?? 0}', style: const TextStyle(color: Color(0xFF00B4D8), fontSize: 12)),
              ]),
              StatusBadge(label: 'L${u['vipLevel'] ?? 0}', color: const Color(0xFFFFD700)),
              StatusBadge(
                label: u['isBanned'] == true ? 'BANNED' : 'ACTIVE',
                color: u['isBanned'] == true ? const Color(0xFFFF4757) : const Color(0xFF2ED573),
              ),
              Text(_fmt(u['createdAt']), style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
              Row(children: [
                IconButton(icon: const Icon(Icons.visibility, color: Color(0xFF00B4D8), size: 16),
                  onPressed: () => _viewProfile(u), constraints: const BoxConstraints(), padding: EdgeInsets.zero),
                const SizedBox(width: 8),
                if (u['isBanned'] != true)
                  IconButton(icon: const Icon(Icons.block, color: Color(0xFFFF4757), size: 16),
                    onPressed: () => _banUser(u['_id'], u['name'] ?? ''),
                    constraints: const BoxConstraints(), padding: EdgeInsets.zero)
                else
                  IconButton(icon: const Icon(Icons.check_circle, color: Color(0xFF2ED573), size: 16),
                    onPressed: () => _unbanUser(u['_id'], u['name'] ?? ''),
                    constraints: const BoxConstraints(), padding: EdgeInsets.zero),
              ]),
            ]).toList(),
          )),
          if (_hasMore && !_isLoading)
            Padding(padding: const EdgeInsets.only(top: 12), child: LuxuryButton(
              label: 'Load More', icon: Icons.expand_more, isOutlined: true,
              onPressed: () { _page++; _load(reset: false); })),
        ]),
      ),
    );
  }

  String _fmt(dynamic d) {
    if (d == null) return '—';
    try { final dt = DateTime.parse(d.toString()); return '\${dt.day}/\${dt.month}/\${dt.year}'; } catch (_) { return '—'; }
  }

  @override
  void dispose() { _tabs.dispose(); _searchCtrl.dispose(); super.dispose(); }
}
