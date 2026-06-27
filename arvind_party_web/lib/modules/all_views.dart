// ═══════════════════════════════════════════════════════════════════════════
// TRANSACTIONS VIEW
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../shared/admin_shell.dart';

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});
  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  final _api = Get.find<ApiService>();
  List<Map<String, dynamic>> _txns = [];
  bool _isLoading = true;
  String _filter = 'all';
  final _searchCtrl = TextEditingController();
  Map<String, dynamic> _summary = {};

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get('/wallet/admin/transactions', queryParams: {
        if (_filter != 'all') 'type': _filter,
        if (_searchCtrl.text.isNotEmpty) 'search': _searchCtrl.text,
      });
      if (res['success'] == true) {
        _txns = List<Map<String, dynamic>>.from(res['data'] ?? []);
        _summary = Map<String, dynamic>.from(res['summary'] ?? {});
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Color _txnColor(String type) {
    switch (type) {
      case 'recharge': return const Color(0xFF2ED573);
      case 'gift': return const Color(0xFFFF8906);
      case 'withdrawal': return const Color(0xFFFF4757);
      case 'bonus': return const Color(0xFFFFD700);
      default: return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Transactions',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // Summary cards
          Row(children: [
            Expanded(child: StatCard(title: 'Total Revenue', value: '₹${_summary['totalRevenue'] ?? 0}',
                icon: Icons.trending_up, color: const Color(0xFF2ED573), subtitle: 'ALL TIME')),
            const SizedBox(width: 12),
            Expanded(child: StatCard(title: 'Today Revenue', value: '₹${_summary['todayRevenue'] ?? 0}',
                icon: Icons.today, color: const Color(0xFFFF8906))),
            const SizedBox(width: 12),
            Expanded(child: StatCard(title: 'Total Withdrawals', value: '₹${_summary['totalWithdrawals'] ?? 0}',
                icon: Icons.money_off, color: const Color(0xFFFF4757))),
            const SizedBox(width: 12),
            Expanded(child: StatCard(title: 'Pending Withdrawals', value: '${_summary['pendingWithdrawals'] ?? 0}',
                icon: Icons.pending, color: const Color(0xFFFFD700))),
          ]),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: LuxurySearchBar(controller: _searchCtrl, hint: 'Search by user or transaction ID...', onChanged: _load)),
            const SizedBox(width: 12),
            ...[['all', 'All'], ['recharge', 'Recharge'], ['gift', 'Gift'], ['withdrawal', 'Withdrawal'], ['bonus', 'Bonus']].map((f) =>
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
            emptyMessage: 'No transactions found',
            columns: const ['TXN ID', 'User', 'Type', 'Amount', 'Status', 'Date'],
            rows: _txns.map((t) => [
              Text(((t['_id'] ?? '') as String).length > 8 ? (t['_id'] as String).substring(0, 8).toUpperCase() : '—',
                style: const TextStyle(color: Color(0xFF6B7280), fontFamily: 'monospace', fontSize: 11)),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t['userName'] ?? '—', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                Text(t['userId'] ?? '', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10)),
              ]),
              StatusBadge(label: (t['type'] ?? 'unknown').toUpperCase(), color: _txnColor(t['type'] ?? '')),
              Text('${t['type'] == 'withdrawal' ? '-' : '+'}₹${t['amount'] ?? 0}',
                style: TextStyle(
                  color: t['type'] == 'withdrawal' ? const Color(0xFFFF4757) : const Color(0xFF2ED573),
                  fontWeight: FontWeight.bold, fontSize: 14)),
              StatusBadge(
                label: (t['status'] ?? 'pending').toUpperCase(),
                color: t['status'] == 'completed' ? const Color(0xFF2ED573)
                    : t['status'] == 'failed' ? const Color(0xFFFF4757)
                    : const Color(0xFFFFD700),
              ),
              Text(_formatDate(t['createdAt']), style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
            ]).toList(),
          )),
        ]),
      ),
    );
  }

  String _formatDate(dynamic d) {
    if (d == null) return '—';
    try { final dt = DateTime.parse(d.toString()); return '${dt.day}/${dt.month}/${dt.year}'; } catch (_) { return '—'; }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ROOMS MANAGEMENT VIEW
// ═══════════════════════════════════════════════════════════════════════════

class RoomsAdminView extends StatefulWidget {
  const RoomsAdminView({super.key});
  @override
  State<RoomsAdminView> createState() => _RoomsAdminViewState();
}

class _RoomsAdminViewState extends State<RoomsAdminView> {
  final _api = Get.find<ApiService>();
  List<Map<String, dynamic>> _rooms = [];
  bool _isLoading = true;
  String _filter = 'all';
  final _searchCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get('/rooms/admin', queryParams: {
        if (_filter != 'all') 'status': _filter,
        if (_searchCtrl.text.isNotEmpty) 'search': _searchCtrl.text,
      });
      if (res['success'] == true) _rooms = List<Map<String, dynamic>>.from(res['data'] ?? []);
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _kickRoom(String id) async {
    await _api.post('/rooms/$id/force-close', {});
    Get.snackbar('Done', 'Room closed', backgroundColor: const Color(0xFFFF4757), colorText: Colors.white);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Rooms Management',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Row(children: [
            Expanded(child: LuxurySearchBar(controller: _searchCtrl, hint: 'Search rooms...', onChanged: _load)),
            const SizedBox(width: 12),
            ...[['all', 'All'], ['live', '🔴 Live'], ['idle', 'Idle'], ['locked', 'Locked']].map((f) =>
              Padding(padding: const EdgeInsets.only(left: 8), child: FilterChip(
                label: Text(f[1], style: const TextStyle(fontSize: 11)),
                selected: _filter == f[0],
                selectedColor: const Color(0xFFFF8906).withOpacity(0.15),
                labelStyle: TextStyle(color: _filter == f[0] ? const Color(0xFFFF8906) : const Color(0xFF6B7280)),
                side: BorderSide(color: _filter == f[0] ? const Color(0xFFFF8906) : const Color(0xFF1E1D2F)),
                backgroundColor: const Color(0xFF0F0E1A),
                onSelected: (_) { setState(() => _filter = f[0]); _load(); },
              ))),
          ]),
          const SizedBox(height: 20),
          Expanded(child: LuxuryDataTable(
            isLoading: _isLoading,
            emptyMessage: 'No rooms found',
            columns: const ['Room Name', 'Owner', 'Members', 'Status', 'Type', 'Action'],
            rows: _rooms.map((r) => [
              Row(children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: r['isLive'] == true ? const Color(0xFF2ED573) : const Color(0xFF6B7280))),
                const SizedBox(width: 8),
                Text(r['name'] ?? '—', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ]),
              Text(r['ownerName'] ?? '—', style: const TextStyle(color: Color(0xFFB8B8D1))),
              Row(children: [
                const Icon(Icons.people, color: Color(0xFF6B7280), size: 14),
                const SizedBox(width: 4),
                Text('${r['memberCount'] ?? 0}', style: const TextStyle(color: Color(0xFFB8B8D1))),
              ]),
              StatusBadge(
                label: r['isLive'] == true ? 'LIVE' : 'OFFLINE',
                color: r['isLive'] == true ? const Color(0xFF2ED573) : const Color(0xFF6B7280),
              ),
              StatusBadge(label: (r['type'] ?? 'public').toUpperCase(), color: const Color(0xFF00B4D8)),
              r['isLive'] == true
                ? TextButton.icon(
                    icon: const Icon(Icons.cancel, size: 14, color: Color(0xFFFF4757)),
                    label: const Text('Close', style: TextStyle(color: Color(0xFFFF4757), fontSize: 12)),
                    onPressed: () => _kickRoom(r['_id']))
                : const Text('—', style: TextStyle(color: Color(0xFF6B7280))),
            ]).toList(),
          )),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NOTIFICATIONS VIEW
// ═══════════════════════════════════════════════════════════════════════════

class NotificationsAdminView extends StatefulWidget {
  const NotificationsAdminView({super.key});
  @override
  State<NotificationsAdminView> createState() => _NotificationsAdminViewState();
}

class _NotificationsAdminViewState extends State<NotificationsAdminView> {
  final _api = Get.find<ApiService>();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _target = 'all';
  String _type = 'general';
  bool _isSending = false;
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get('/notifications/admin/history');
      if (res['success'] == true) _history = List<Map<String, dynamic>>.from(res['data'] ?? []);
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _send() async {
    if (_titleCtrl.text.isEmpty || _bodyCtrl.text.isEmpty) {
      Get.snackbar('Error', 'Title and body required', backgroundColor: const Color(0xFFFF4757), colorText: Colors.white);
      return;
    }
    setState(() => _isSending = true);
    try {
      final res = await _api.post('/notifications/broadcast', {
        'title': _titleCtrl.text.trim(),
        'body': _bodyCtrl.text.trim(),
        'target': _target,
        'type': _type,
      });
      if (res['success'] == true) {
        Get.snackbar('Sent ✅', 'Notification sent to ${_target == 'all' ? 'all users' : _target}',
            backgroundColor: const Color(0xFF2ED573), colorText: Colors.black);
        _titleCtrl.clear(); _bodyCtrl.clear();
        _load();
      }
    } catch (_) {}
    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Notifications',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Send form
          SizedBox(width: 380, child: LuxuryCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Send Notification', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 20),
              TextField(controller: _titleCtrl, style: const TextStyle(color: Colors.white),
                decoration: _inputDecor('Title', Icons.title)),
              const SizedBox(height: 12),
              TextField(controller: _bodyCtrl, style: const TextStyle(color: Colors.white),
                maxLines: 4,
                decoration: _inputDecor('Body Message', Icons.message)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _target,
                dropdownColor: const Color(0xFF0F0E1A),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecor('Target', Icons.group),
                items: [
                  const DropdownMenuItem(value: 'all', child: Text('All Users')),
                  const DropdownMenuItem(value: 'vip', child: Text('VIP Users')),
                  const DropdownMenuItem(value: 'active', child: Text('Active Users')),
                  const DropdownMenuItem(value: 'inactive', child: Text('Inactive (7+ days)')),
                ],
                onChanged: (v) => setState(() => _target = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _type,
                dropdownColor: const Color(0xFF0F0E1A),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecor('Notification Type', Icons.category),
                items: [
                  const DropdownMenuItem(value: 'general', child: Text('General')),
                  const DropdownMenuItem(value: 'event', child: Text('Event')),
                  const DropdownMenuItem(value: 'promo', child: Text('Promotion')),
                  const DropdownMenuItem(value: 'alert', child: Text('Alert')),
                ],
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 20),
              LuxuryButton(label: 'Send Now', icon: Icons.send, onPressed: _send, isLoading: _isSending),
            ]),
          )),
          const SizedBox(width: 20),
          // History
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Notification History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Expanded(child: LuxuryDataTable(
              isLoading: _isLoading,
              emptyMessage: 'No notifications sent yet',
              columns: const ['Title', 'Body', 'Target', 'Sent', 'Date'],
              rows: _history.map((n) => [
                Text(n['title'] ?? '—', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text(n['body'] ?? '—', style: const TextStyle(color: Color(0xFFB8B8D1), fontSize: 12),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                StatusBadge(label: (n['target'] ?? 'all').toUpperCase(), color: const Color(0xFF00B4D8)),
                Text('${n['sentCount'] ?? 0}', style: const TextStyle(color: Color(0xFF2ED573), fontWeight: FontWeight.bold)),
                Text(_formatDate(n['createdAt']), style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
              ]).toList(),
            )),
          ])),
        ]),
      ),
    );
  }

  InputDecoration _inputDecor(String label, IconData icon) => InputDecoration(
    labelText: label, labelStyle: const TextStyle(color: Color(0xFF6B7280)),
    prefixIcon: Icon(icon, color: const Color(0xFF6B7280), size: 18),
    filled: true, fillColor: const Color(0xFF1A1928),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E1D2F))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E1D2F))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF8906))),
  );

  String _formatDate(dynamic d) {
    if (d == null) return '—';
    try { final dt = DateTime.parse(d.toString()); return '${dt.day}/${dt.month}/${dt.year}'; } catch (_) { return '—'; }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// REPORTS VIEW
// ═══════════════════════════════════════════════════════════════════════════

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});
  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> with SingleTickerProviderStateMixin {
  final _api = Get.find<ApiService>();
  late TabController _tabs;
  Map<String, dynamic> _revenueData = {};
  Map<String, dynamic> _userGrowth = {};
  Map<String, dynamic> _giftStats = {};
  bool _isLoading = true;
  String _period = '7d';

  @override
  void initState() { super.initState(); _tabs = TabController(length: 4, vsync: this); _load(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final r = await _api.get('/admin/reports/revenue', queryParams: {'period': _period});
      if (r['success'] == true) _revenueData = Map<String, dynamic>.from(r['data'] ?? {});
      final u = await _api.get('/admin/reports/users', queryParams: {'period': _period});
      if (u['success'] == true) _userGrowth = Map<String, dynamic>.from(u['data'] ?? {});
      final g = await _api.get('/admin/reports/gifts', queryParams: {'period': _period});
      if (g['success'] == true) _giftStats = Map<String, dynamic>.from(g['data'] ?? {});
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Reports & Analytics',
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            ...[['7d', '7 Days'], ['30d', '30 Days'], ['90d', '3 Months'], ['1y', '1 Year']].map((p) =>
              Padding(padding: const EdgeInsets.only(right: 8), child: FilterChip(
                label: Text(p[1], style: const TextStyle(fontSize: 12)),
                selected: _period == p[0],
                selectedColor: const Color(0xFFFF8906).withOpacity(0.15),
                labelStyle: TextStyle(color: _period == p[0] ? const Color(0xFFFF8906) : const Color(0xFF6B7280)),
                side: BorderSide(color: _period == p[0] ? const Color(0xFFFF8906) : const Color(0xFF1E1D2F)),
                backgroundColor: const Color(0xFF0F0E1A),
                onSelected: (_) { setState(() => _period = p[0]); _load(); },
              ))),
            const Spacer(),
            LuxuryButton(label: 'Export CSV', icon: Icons.download, isOutlined: true,
              onPressed: () => Get.snackbar('Export', 'CSV export started', backgroundColor: const Color(0xFF2ED573), colorText: Colors.black)),
          ]),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(color: const Color(0xFF0F0E1A), borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E1D2F))),
          child: TabBar(controller: _tabs, labelColor: const Color(0xFFFF8906),
            unselectedLabelColor: const Color(0xFF6B7280), indicatorColor: const Color(0xFFFF8906),
            tabs: const [Tab(text: '💰 Revenue'), Tab(text: '👥 Users'), Tab(text: '🎁 Gifts'), Tab(text: '🏆 Top Users')]),
        ),
        const SizedBox(height: 16),
        Expanded(child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF8906)))
          : TabBarView(controller: _tabs, children: [
              _buildRevenueTab(),
              _buildUsersTab(),
              _buildGiftsTab(),
              _buildTopUsersTab(),
            ])),
      ]),
    );
  }

  Widget _buildRevenueTab() => SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(children: [
      Row(children: [
        Expanded(child: StatCard(title: 'Total Revenue', value: '₹${_revenueData['total'] ?? 0}', icon: Icons.trending_up, color: const Color(0xFF2ED573))),
        const SizedBox(width: 12),
        Expanded(child: StatCard(title: 'Recharge Revenue', value: '₹${_revenueData['recharge'] ?? 0}', icon: Icons.add_card, color: const Color(0xFFFF8906))),
        const SizedBox(width: 12),
        Expanded(child: StatCard(title: 'Avg Per Day', value: '₹${_revenueData['avgPerDay'] ?? 0}', icon: Icons.calendar_today, color: const Color(0xFF00B4D8))),
        const SizedBox(width: 12),
        Expanded(child: StatCard(title: 'Growth', value: '${_revenueData['growth'] ?? 0}%', icon: Icons.show_chart, color: const Color(0xFFFFD700), subtitle: 'vs prev period')),
      ]),
      const SizedBox(height: 20),
      LuxuryCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Revenue Breakdown', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 16),
        ...((_revenueData['breakdown'] as List?)?.cast<Map<String, dynamic>>() ?? []).map((item) =>
          Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(children: [
            Row(children: [
              Text(item['label'] ?? '', style: const TextStyle(color: Color(0xFFB8B8D1), fontSize: 13)),
              const Spacer(),
              Text('₹${item['amount'] ?? 0}', style: const TextStyle(color: Color(0xFFFF8906), fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: (item['percent'] as num?)?.toDouble() ?? 0,
              backgroundColor: const Color(0xFF1A1928),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF8906)),
            ),
          ]))),
      ])),
    ]));

  Widget _buildUsersTab() => SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(children: [
      Row(children: [
        Expanded(child: StatCard(title: 'New Users', value: '${_userGrowth['newUsers'] ?? 0}', icon: Icons.person_add, color: const Color(0xFF2ED573))),
        const SizedBox(width: 12),
        Expanded(child: StatCard(title: 'Active Users', value: '${_userGrowth['activeUsers'] ?? 0}', icon: Icons.people, color: const Color(0xFFFF8906))),
        const SizedBox(width: 12),
        Expanded(child: StatCard(title: 'Churned', value: '${_userGrowth['churned'] ?? 0}', icon: Icons.person_remove, color: const Color(0xFFFF4757))),
        const SizedBox(width: 12),
        Expanded(child: StatCard(title: 'Retention Rate', value: '${_userGrowth['retention'] ?? 0}%', icon: Icons.loop, color: const Color(0xFF00B4D8))),
      ]),
    ]));

  Widget _buildGiftsTab() => SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: LuxuryCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Top Gifted Items', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 16),
        ...((_giftStats['topGifts'] as List?)?.cast<Map>() ?? []).asMap().entries.map((e) =>
          Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
            Text('${e.key + 1}', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            Text(e.value['name'] ?? '—', style: const TextStyle(color: Colors.white)),
            const Spacer(),
            Text('${e.value['count'] ?? 0}x', style: const TextStyle(color: Color(0xFFFF8906), fontWeight: FontWeight.bold)),
          ]))),
      ]))),
    ]));

  Widget _buildTopUsersTab() => Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
    child: LuxuryDataTable(
      isLoading: _isLoading,
      emptyMessage: 'No data available',
      columns: const ['Rank', 'User', 'Total Spent', 'Gifts Sent', 'Level'],
      rows: [],
    ));

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }
}

// ═══════════════════════════════════════════════════════════════════════════
// SETTINGS VIEW
// ═══════════════════════════════════════════════════════════════════════════

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});
  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> with SingleTickerProviderStateMixin {
  final _api = Get.find<ApiService>();
  late TabController _tabs;
  Map<String, dynamic> _config = {};
  bool _isLoading = true;
  bool _isSaving = false;

  final _appNameCtrl = TextEditingController();
  final _supportEmailCtrl = TextEditingController();
  final _minAgeCtrl = TextEditingController();
  bool _maintenanceMode = false;
  bool _registrationOpen = true;
  bool _gamesEnabled = true;
  bool _giftsEnabled = true;

  @override
  void initState() { super.initState(); _tabs = TabController(length: 3, vsync: this); _load(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get('/admin/app-config');
      if (res['success'] == true) {
        _config = Map<String, dynamic>.from(res['data'] ?? {});
        _appNameCtrl.text = _config['appName'] ?? 'Arvind Party';
        _supportEmailCtrl.text = _config['supportEmail'] ?? '';
        _minAgeCtrl.text = '${_config['minAge'] ?? 16}';
        _maintenanceMode = _config['maintenanceMode'] == true;
        _registrationOpen = _config['registrationOpen'] != false;
        _gamesEnabled = _config['gamesEnabled'] != false;
        _giftsEnabled = _config['giftsEnabled'] != false;
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await _api.put('/admin/app-config', {
        'appName': _appNameCtrl.text,
        'supportEmail': _supportEmailCtrl.text,
        'minAge': int.tryParse(_minAgeCtrl.text) ?? 16,
        'maintenanceMode': _maintenanceMode,
        'registrationOpen': _registrationOpen,
        'gamesEnabled': _gamesEnabled,
        'giftsEnabled': _giftsEnabled,
      });
      Get.snackbar('Saved ✅', 'Settings updated', backgroundColor: const Color(0xFF2ED573), colorText: Colors.black);
    } catch (_) {}
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Settings',
      child: Column(children: [
        Padding(padding: const EdgeInsets.all(20), child: Row(children: [
          Container(decoration: BoxDecoration(color: const Color(0xFF0F0E1A), borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E1D2F))),
            child: TabBar(controller: _tabs, labelColor: const Color(0xFFFF8906),
              unselectedLabelColor: const Color(0xFF6B7280), indicatorColor: const Color(0xFFFF8906),
              isScrollable: true,
              tabs: const [Tab(text: '⚙️ General'), Tab(text: '🔒 Security'), Tab(text: '🔔 Feature Flags')])),
          const Spacer(),
          LuxuryButton(label: 'Save All', icon: Icons.save, onPressed: _save, isLoading: _isSaving),
        ])),
        Expanded(child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF8906)))
          : TabBarView(controller: _tabs, children: [
              _buildGeneralTab(),
              _buildSecurityTab(),
              _buildFlagsTab(),
            ])),
      ]),
    );
  }

  Widget _buildGeneralTab() => SingleChildScrollView(padding: const EdgeInsets.all(20),
    child: LuxuryCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('App Configuration', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: _field(_appNameCtrl, 'App Name', Icons.apps)),
        const SizedBox(width: 16),
        Expanded(child: _field(_supportEmailCtrl, 'Support Email', Icons.email)),
        const SizedBox(width: 16),
        Expanded(child: _field(_minAgeCtrl, 'Minimum Age', Icons.cake, TextInputType.number)),
      ]),
      const SizedBox(height: 20),
      _toggle('Maintenance Mode', 'Disable app for all users', _maintenanceMode,
        (v) => setState(() => _maintenanceMode = v), icon: Icons.construction, dangerColor: true),
      _toggle('Registration Open', 'Allow new user registrations', _registrationOpen,
        (v) => setState(() => _registrationOpen = v), icon: Icons.app_registration),
    ])));

  Widget _buildSecurityTab() => SingleChildScrollView(padding: const EdgeInsets.all(20),
    child: LuxuryCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Security Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 20),
      _infoRow('Rate Limiting', 'Enabled — 1000 req/15min'),
      _infoRow('JWT Expiry', '15 minutes (+ refresh 30 days)'),
      _infoRow('2FA for Admin', 'Available via Firebase'),
      _infoRow('CORS', 'Restricted to allowed origins'),
      _infoRow('Helmet.js', 'Security headers active'),
    ])));

  Widget _buildFlagsTab() => SingleChildScrollView(padding: const EdgeInsets.all(20),
    child: LuxuryCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Feature Flags', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 20),
      _toggle('Games Enabled', 'Lucky Wheel, Scratch Card etc', _gamesEnabled,
        (v) => setState(() => _gamesEnabled = v), icon: Icons.sports_esports),
      _toggle('Gifts Enabled', 'Allow gift sending in rooms', _giftsEnabled,
        (v) => setState(() => _giftsEnabled = v), icon: Icons.card_giftcard),
    ])));

  Widget _toggle(String label, String desc, bool value, Function(bool) onChanged,
      {IconData? icon, bool dangerColor = false}) =>
    Padding(padding: const EdgeInsets.only(bottom: 12), child: LuxuryCard(
      borderColor: dangerColor && value ? const Color(0xFFFF4757).withOpacity(0.4) : null,
      child: Row(children: [
        if (icon != null) Icon(icon, color: dangerColor && value ? const Color(0xFFFF4757) : const Color(0xFF6B7280), size: 20),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: dangerColor && value ? const Color(0xFFFF4757) : Colors.white, fontWeight: FontWeight.w600)),
          Text(desc, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
        ])),
        Switch(value: value, activeColor: dangerColor ? const Color(0xFFFF4757) : const Color(0xFF2ED573), onChanged: onChanged),
      ]),
    ));

  Widget _infoRow(String label, String value) => Padding(padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [
      Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
      const Spacer(),
      StatusBadge(label: value, color: const Color(0xFF2ED573)),
    ]));

  Widget _field(TextEditingController c, String label, IconData icon, [TextInputType? type]) =>
    TextField(controller: c, style: const TextStyle(color: Colors.white), keyboardType: type,
      decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Color(0xFF6B7280)),
        prefixIcon: Icon(icon, color: const Color(0xFF6B7280), size: 18),
        filled: true, fillColor: const Color(0xFF1A1928),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E1D2F))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E1D2F))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF8906)))));

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }
}

// ═══════════════════════════════════════════════════════════════════════════
// SUPPORT VIEW
// ═══════════════════════════════════════════════════════════════════════════

class SupportView extends StatefulWidget {
  const SupportView({super.key});
  @override
  State<SupportView> createState() => _SupportViewState();
}

class _SupportViewState extends State<SupportView> {
  final _api = Get.find<ApiService>();
  List<Map<String, dynamic>> _tickets = [];
  bool _isLoading = true;
  String _filter = 'open';
  Map<String, dynamic>? _selected;
  final _replyCtrl = TextEditingController();
  bool _isReplying = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get('/support/tickets', queryParams: {'status': _filter});
      if (res['success'] == true) _tickets = List<Map<String, dynamic>>.from(res['data'] ?? []);
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _reply(String ticketId) async {
    if (_replyCtrl.text.isEmpty) return;
    setState(() => _isReplying = true);
    try {
      await _api.post('/support/tickets/$ticketId/reply', {'message': _replyCtrl.text.trim()});
      _replyCtrl.clear();
      Get.snackbar('Sent ✅', 'Reply sent', backgroundColor: const Color(0xFF2ED573), colorText: Colors.black);
      _load();
    } catch (_) {}
    setState(() => _isReplying = false);
  }

  Future<void> _closeTicket(String id) async {
    await _api.put('/support/tickets/$id/close', {});
    setState(() => _selected = null);
    _load();
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'high': return const Color(0xFFFF4757);
      case 'medium': return const Color(0xFFFF8906);
      default: return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Support Tickets',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Ticket list
          SizedBox(width: 340, child: Column(children: [
            Row(children: [
              ...[['open', 'Open'], ['in_progress', 'In Progress'], ['closed', 'Closed']].map((f) =>
                Padding(padding: const EdgeInsets.only(right: 8), child: FilterChip(
                  label: Text(f[1], style: const TextStyle(fontSize: 11)),
                  selected: _filter == f[0],
                  selectedColor: const Color(0xFFFF8906).withOpacity(0.15),
                  labelStyle: TextStyle(color: _filter == f[0] ? const Color(0xFFFF8906) : const Color(0xFF6B7280)),
                  side: BorderSide(color: _filter == f[0] ? const Color(0xFFFF8906) : const Color(0xFF1E1D2F)),
                  backgroundColor: const Color(0xFF0F0E1A),
                  onSelected: (_) { setState(() { _filter = f[0]; _selected = null; }); _load(); },
                ))),
            ]),
            const SizedBox(height: 12),
            Expanded(child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF8906)))
              : _tickets.isEmpty
                ? const Center(child: Text('No tickets', style: TextStyle(color: Color(0xFF6B7280))))
                : ListView.builder(itemCount: _tickets.length, itemBuilder: (_, i) {
                    final t = _tickets[i];
                    final isSelected = _selected?['_id'] == t['_id'];
                    return InkWell(
                      onTap: () => setState(() => _selected = t),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFF8906).withOpacity(0.1) : const Color(0xFF0F0E1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? const Color(0xFFFF8906) : const Color(0xFF1E1D2F))),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Expanded(child: Text(t['subject'] ?? 'No subject',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                              maxLines: 1, overflow: TextOverflow.ellipsis)),
                            StatusBadge(label: (t['priority'] ?? 'low').toUpperCase(),
                              color: _priorityColor(t['priority'] ?? 'low')),
                          ]),
                          const SizedBox(height: 6),
                          Text(t['userName'] ?? '—', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(t['lastMessage'] ?? '', style: const TextStyle(color: Color(0xFFB8B8D1), fontSize: 11),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        ]),
                      ),
                    );
                  })),
          ])),
          const SizedBox(width: 16),
          // Ticket detail + reply
          Expanded(child: _selected == null
            ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.support_agent, color: Color(0xFF1E1D2F), size: 80),
                SizedBox(height: 16),
                Text('Select a ticket to view', style: TextStyle(color: Color(0xFF6B7280))),
              ]))
            : LuxuryCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_selected!['subject'] ?? '—', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('From: ${_selected!['userName']} • ${_selected!['userEmail'] ?? ''}',
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                  ])),
                  if (_selected!['status'] != 'closed')
                    LuxuryButton(label: 'Close Ticket', icon: Icons.check, isOutlined: true, color: const Color(0xFF2ED573),
                      onPressed: () => _closeTicket(_selected!['_id'])),
                ]),
                const Divider(color: Color(0xFF1E1D2F), height: 24),
                Expanded(child: ListView(children: [
                  ...((_selected!['messages'] as List?) ?? []).map((msg) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment:
                      msg['isAdmin'] == true ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        Container(padding: const EdgeInsets.all(12), constraints: const BoxConstraints(maxWidth: 380),
                          decoration: BoxDecoration(
                            color: msg['isAdmin'] == true ? const Color(0xFFFF8906).withOpacity(0.15) : const Color(0xFF1A1928),
                            borderRadius: BorderRadius.circular(12)),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(msg['sender'] ?? '—', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(msg['text'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 13)),
                          ])),
                      ]),
                  )),
                ])),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: TextField(controller: _replyCtrl, style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(hintText: 'Type reply...', hintStyle: TextStyle(color: Color(0xFF6B7280)),
                      filled: true, fillColor: Color(0xFF1A1928),
                      border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E1D2F))),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E1D2F))),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFFF8906)))))),
                  const SizedBox(width: 8),
                  LuxuryButton(label: 'Reply', icon: Icons.send,
                    onPressed: () => _reply(_selected!['_id']), isLoading: _isReplying),
                ]),
              ]))),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GAMES ADMIN VIEW
// ═══════════════════════════════════════════════════════════════════════════

class GamesAdminView extends StatefulWidget {
  const GamesAdminView({super.key});
  @override
  State<GamesAdminView> createState() => _GamesAdminViewState();
}

class _GamesAdminViewState extends State<GamesAdminView> {
  final _api = Get.find<ApiService>();
  List<Map<String, dynamic>> _gameLogs = [];
  Map<String, dynamic> _gameStats = {};
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final s = await _api.get('/games/admin/stats');
      if (s['success'] == true) _gameStats = Map<String, dynamic>.from(s['data'] ?? {});
      final l = await _api.get('/games/admin/logs');
      if (l['success'] == true) _gameLogs = List<Map<String, dynamic>>.from(l['data'] ?? []);
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Games Management',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Row(children: [
            Expanded(child: StatCard(title: 'Total Games Played', value: '${_gameStats['totalPlayed'] ?? 0}',
                icon: Icons.sports_esports, color: const Color(0xFFFF8906))),
            const SizedBox(width: 12),
            Expanded(child: StatCard(title: 'Coins Won', value: '${_gameStats['coinsWon'] ?? 0}',
                icon: Icons.emoji_events, color: const Color(0xFFFFD700))),
            const SizedBox(width: 12),
            Expanded(child: StatCard(title: 'Coins Collected', value: '${_gameStats['coinsCollected'] ?? 0}',
                icon: Icons.monetization_on, color: const Color(0xFF2ED573))),
            const SizedBox(width: 12),
            Expanded(child: StatCard(title: 'House Edge', value: '${_gameStats['houseEdge'] ?? 0}%',
                icon: Icons.trending_up, color: const Color(0xFF00B4D8))),
          ]),
          const SizedBox(height: 20),
          Expanded(child: LuxuryDataTable(
            isLoading: _isLoading,
            emptyMessage: 'No game logs',
            columns: const ['User', 'Game', 'Bet', 'Win/Loss', 'Result', 'Time'],
            rows: _gameLogs.map((g) => [
              Text(g['userName'] ?? '—', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              StatusBadge(label: (g['gameType'] ?? 'game').toUpperCase(), color: const Color(0xFFFF8906)),
              Text('🪙${g['betAmount'] ?? 0}', style: const TextStyle(color: Color(0xFFB8B8D1))),
              Text('${(g['winAmount'] ?? 0) > 0 ? '+' : ''}🪙${g['winAmount'] ?? 0}',
                style: TextStyle(color: (g['winAmount'] ?? 0) > 0 ? const Color(0xFF2ED573) : const Color(0xFFFF4757),
                  fontWeight: FontWeight.bold)),
              StatusBadge(label: (g['result'] ?? 'played').toUpperCase(),
                color: g['result'] == 'win' ? const Color(0xFF2ED573) : const Color(0xFFFF4757)),
              Text(_formatDate(g['createdAt']), style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
            ]).toList(),
          )),
        ]),
      ),
    );
  }

  String _formatDate(dynamic d) {
    if (d == null) return '—';
    try { final dt = DateTime.parse(d.toString()); return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}'; } catch (_) { return '—'; }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LEADERBOARD VIEW
// ═══════════════════════════════════════════════════════════════════════════

class LeaderboardAdminView extends StatefulWidget {
  const LeaderboardAdminView({super.key});
  @override
  State<LeaderboardAdminView> createState() => _LeaderboardAdminViewState();
}

class _LeaderboardAdminViewState extends State<LeaderboardAdminView> with SingleTickerProviderStateMixin {
  final _api = Get.find<ApiService>();
  late TabController _tabs;
  List<Map<String, dynamic>> _wealth = [];
  List<Map<String, dynamic>> _charm = [];
  List<Map<String, dynamic>> _family = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _tabs = TabController(length: 3, vsync: this); _load(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final w = await _api.get('/rankings/wealth');
      if (w['success'] == true) _wealth = List<Map<String, dynamic>>.from(w['data'] ?? []);
      final c = await _api.get('/rankings/charm');
      if (c['success'] == true) _charm = List<Map<String, dynamic>>.from(c['data'] ?? []);
      final f = await _api.get('/rankings/family');
      if (f['success'] == true) _family = List<Map<String, dynamic>>.from(f['data'] ?? []);
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Leaderboards',
      child: Column(children: [
        Padding(padding: const EdgeInsets.all(20), child: Row(children: [
          Container(decoration: BoxDecoration(color: const Color(0xFF0F0E1A), borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E1D2F))),
            child: TabBar(controller: _tabs, labelColor: const Color(0xFFFF8906),
              unselectedLabelColor: const Color(0xFF6B7280), indicatorColor: const Color(0xFFFF8906),
              isScrollable: true,
              tabs: const [Tab(text: '💰 Wealth'), Tab(text: '✨ Charm'), Tab(text: '👨‍👩‍👧 Family')])),
          const Spacer(),
          LuxuryButton(label: 'Reset Rankings', icon: Icons.refresh, isOutlined: true, color: const Color(0xFFFF4757),
            onPressed: () => Get.snackbar('Confirm', 'Are you sure? This will reset all rankings',
                backgroundColor: const Color(0xFFFF4757), colorText: Colors.white)),
        ])),
        Expanded(child: TabBarView(controller: _tabs, children: [
          _buildRankTable(_wealth, '💰 Wealth'),
          _buildRankTable(_charm, '✨ Charm'),
          _buildRankTable(_family, '👨‍👩‍👧 Family'),
        ])),
      ]),
    );
  }

  Widget _buildRankTable(List<Map<String, dynamic>> data, String type) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: LuxuryDataTable(
      isLoading: _isLoading,
      emptyMessage: 'No ranking data',
      columns: const ['Rank', 'User', 'Score', 'Level', 'Change'],
      rows: data.asMap().entries.map((e) {
        final r = e.value;
        final rank = e.key + 1;
        return [
          Row(children: [
            if (rank <= 3) Text(['🥇', '🥈', '🥉'][rank - 1], style: const TextStyle(fontSize: 18))
            else Text('#$rank', style: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.bold)),
          ]),
          Row(children: [
            CircleAvatar(radius: 16, backgroundColor: const Color(0xFFFF8906),
              child: Text((r['name'] ?? 'U')[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
            const SizedBox(width: 8),
            Text(r['name'] ?? '—', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ]),
          Text('${r['score'] ?? 0}', style: const TextStyle(color: Color(0xFFFF8906), fontWeight: FontWeight.bold, fontSize: 15)),
          StatusBadge(label: 'Lv.${r['level'] ?? 0}', color: const Color(0xFF00B4D8)),
          Row(children: [
            Icon(r['change'] == 'up' ? Icons.arrow_upward : r['change'] == 'down' ? Icons.arrow_downward : Icons.remove,
              color: r['change'] == 'up' ? const Color(0xFF2ED573) : r['change'] == 'down' ? const Color(0xFFFF4757) : const Color(0xFF6B7280),
              size: 14),
            Text('${r['changeAmount'] ?? 0}',
              style: TextStyle(color: r['change'] == 'up' ? const Color(0xFF2ED573) : const Color(0xFFFF4757), fontSize: 12)),
          ]),
        ];
      }).toList(),
    ));

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }
}
