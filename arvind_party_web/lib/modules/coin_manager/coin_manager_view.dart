// ═══════════════════════════════════════════════════════════════════════════
// COIN MANAGER VIEW — OWNER ONLY
// Full coin generation, distribution, and audit system
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/services/api_service.dart';
import '../shared/admin_shell.dart';

class CoinManagerView extends StatefulWidget {
  const CoinManagerView({super.key});

  @override
  State<CoinManagerView> createState() => _CoinManagerViewState();
}

class _CoinManagerViewState extends State<CoinManagerView> with SingleTickerProviderStateMixin {
  final _api = Get.find<ApiService>();
  late TabController _tabController;

  // Add coins form
  final _userSearchCtrl = TextEditingController();
  final _coinAmountCtrl = TextEditingController();
  final _diamondAmountCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  String _coinType = 'coins';
  bool _isAdding = false;

  // Bulk form
  final _bulkUserIdsCtrl = TextEditingController();
  final _bulkAmountCtrl = TextEditingController();
  bool _isBulkLoading = false;

  // Stats
  Map<String, dynamic> _coinStats = {};
  List<Map<String, dynamic>> _auditLogs = [];
  List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic>? _selectedUser;
  bool _isLoading = true;
  bool _isSearching = false;

  // Rate config
  final _rateCtrl = TextEditingController();
  final _minWithdrawCtrl = TextEditingController();
  bool _isSavingConfig = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _checkOwnerAccess();
    _loadData();
  }

  void _checkOwnerAccess() {
    final role = GetStorage().read('admin_role') ?? '';
    if (role != 'owner' && role != 'super_admin') {
      Get.back();
      Get.snackbar('Access Denied', 'Only Owner can access Coin Manager',
          backgroundColor: const Color(0xFFFF4757), colorText: Colors.white);
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _api.get('/admin/coin-stats');
      if (stats['success'] == true) _coinStats = Map<String, dynamic>.from(stats['data'] ?? {});

      final logs = await _api.get('/admin/coin-audit', queryParams: {'limit': '50'});
      if (logs['success'] == true) _auditLogs = List<Map<String, dynamic>>.from(logs['data'] ?? []);

      final config = await _api.get('/admin/wallet-config');
      if (config['success'] == true) {
        _rateCtrl.text = '${config['data']?['diamondToCoinRate'] ?? 10}';
        _minWithdrawCtrl.text = '${config['data']?['minWithdrawal'] ?? 500}';
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _searchUser(String query) async {
    if (query.length < 2) return;
    setState(() => _isSearching = true);
    try {
      final res = await _api.get('/users', queryParams: {'search': query, 'limit': '10'});
      if (res['success'] == true) {
        _searchResults = List<Map<String, dynamic>>.from(res['data'] ?? []);
      }
    } catch (_) {}
    setState(() => _isSearching = false);
  }

  Future<void> _addCoins() async {
    if (_selectedUser == null) {
      Get.snackbar('Error', 'Please select a user first', backgroundColor: const Color(0xFFFF4757), colorText: Colors.white);
      return;
    }
    final amount = int.tryParse(_coinAmountCtrl.text);
    if (amount == null || amount <= 0) {
      Get.snackbar('Error', 'Enter valid amount', backgroundColor: const Color(0xFFFF4757), colorText: Colors.white);
      return;
    }
    if (_reasonCtrl.text.trim().isEmpty) {
      Get.snackbar('Error', 'Reason is required', backgroundColor: const Color(0xFFFF4757), colorText: Colors.white);
      return;
    }

    setState(() => _isAdding = true);
    try {
      final res = await _api.post('/admin/adjust-coins', {
        'userId': _selectedUser!['_id'],
        'amount': amount,
        'type': _coinType,
        'reason': _reasonCtrl.text.trim(),
        'action': 'add',
      });
      if (res['success'] == true) {
        Get.snackbar('Success ✅', 'Coins added successfully', backgroundColor: const Color(0xFF2ED573), colorText: Colors.black);
        _coinAmountCtrl.clear();
        _reasonCtrl.clear();
        _selectedUser = null;
        _userSearchCtrl.clear();
        _loadData();
      } else {
        Get.snackbar('Error', res['message'] ?? 'Failed', backgroundColor: const Color(0xFFFF4757), colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: const Color(0xFFFF4757), colorText: Colors.white);
    }
    setState(() => _isAdding = false);
  }

  Future<void> _deductCoins() async {
    if (_selectedUser == null) return;
    final amount = int.tryParse(_coinAmountCtrl.text);
    if (amount == null || amount <= 0) return;
    if (_reasonCtrl.text.trim().isEmpty) {
      Get.snackbar('Error', 'Reason is required', backgroundColor: const Color(0xFFFF4757), colorText: Colors.white);
      return;
    }

    final confirmed = await _showConfirmDialog('Deduct Coins', 'Are you sure you want to deduct $amount ${_coinType} from ${_selectedUser!['name']}?');
    if (!confirmed) return;

    setState(() => _isAdding = true);
    try {
      final res = await _api.post('/admin/adjust-coins', {
        'userId': _selectedUser!['_id'],
        'amount': -amount,
        'type': _coinType,
        'reason': _reasonCtrl.text.trim(),
        'action': 'deduct',
      });
      if (res['success'] == true) {
        Get.snackbar('Done', 'Coins deducted', backgroundColor: const Color(0xFFFF8906), colorText: Colors.black);
        _coinAmountCtrl.clear();
        _selectedUser = null;
        _loadData();
      }
    } catch (e) {}
    setState(() => _isAdding = false);
  }

  Future<void> _bulkAdd() async {
    final ids = _bulkUserIdsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final amount = int.tryParse(_bulkAmountCtrl.text);
    if (ids.isEmpty || amount == null || amount <= 0) {
      Get.snackbar('Error', 'Enter valid user IDs and amount', backgroundColor: const Color(0xFFFF4757), colorText: Colors.white);
      return;
    }
    setState(() => _isBulkLoading = true);
    try {
      final res = await _api.post('/admin/bulk-adjust-coins', {
        'userIds': ids,
        'amount': amount,
        'type': _coinType,
        'reason': 'Bulk addition by owner',
      });
      if (res['success'] == true) {
        Get.snackbar('Success', 'Coins added to ${ids.length} users', backgroundColor: const Color(0xFF2ED573), colorText: Colors.black);
        _bulkUserIdsCtrl.clear();
        _bulkAmountCtrl.clear();
        _loadData();
      }
    } catch (_) {}
    setState(() => _isBulkLoading = false);
  }

  Future<void> _saveConfig() async {
    setState(() => _isSavingConfig = true);
    try {
      await _api.put('/admin/wallet-config', {
        'diamondToCoinRate': int.tryParse(_rateCtrl.text) ?? 10,
        'minWithdrawal': int.tryParse(_minWithdrawCtrl.text) ?? 500,
      });
      Get.snackbar('Saved ✅', 'Configuration updated', backgroundColor: const Color(0xFF2ED573), colorText: Colors.black);
    } catch (_) {}
    setState(() => _isSavingConfig = false);
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1928),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Color(0xFFB8B8D1))),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4757)),
            onPressed: () => Get.back(result: true),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: '💰 Coin Manager',
      child: Column(
        children: [
          // OWNER BADGE
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                const Color(0xFFFF8906).withOpacity(0.2),
                const Color(0xFFFFD700).withOpacity(0.1),
              ]),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFF8906).withOpacity(0.4)),
            ),
            child: const Row(children: [
              Icon(Icons.lock, color: Color(0xFFFF8906), size: 16),
              SizedBox(width: 8),
              Text('OWNER ONLY — Coin Generation & Management System',
                style: TextStyle(color: Color(0xFFFF8906), fontWeight: FontWeight.bold, fontSize: 13)),
            ]),
          ),

          // STATS ROW
          if (!_isLoading) Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Expanded(child: StatCard(title: 'Total Coins Issued', value: '${_coinStats['totalCoinsIssued'] ?? 0}',
                icon: Icons.monetization_on, color: const Color(0xFFFF8906))),
              const SizedBox(width: 12),
              Expanded(child: StatCard(title: 'Total Diamonds', value: '${_coinStats['totalDiamonds'] ?? 0}',
                icon: Icons.diamond, color: const Color(0xFF00B4D8))),
              const SizedBox(width: 12),
              Expanded(child: StatCard(title: 'Today Issued', value: '${_coinStats['todayIssued'] ?? 0}',
                icon: Icons.today, color: const Color(0xFF2ED573))),
              const SizedBox(width: 12),
              Expanded(child: StatCard(title: 'Total Deducted', value: '${_coinStats['totalDeducted'] ?? 0}',
                icon: Icons.remove_circle, color: const Color(0xFFFF4757))),
            ]),
          ),

          const SizedBox(height: 20),

          // TABS
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0E1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E1D2F)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFFF8906),
              unselectedLabelColor: const Color(0xFF6B7280),
              indicatorColor: const Color(0xFFFF8906),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: '➕ Add / Deduct'),
                Tab(text: '👥 Bulk Add'),
                Tab(text: '📊 Audit Log'),
                Tab(text: '⚙️ Configuration'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAddDeductTab(),
                _buildBulkTab(),
                _buildAuditTab(),
                _buildConfigTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddDeductTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: User Search
          Expanded(
            flex: 2,
            child: LuxuryCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Search User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 16),
                  LuxurySearchBar(
                    controller: _userSearchCtrl,
                    hint: 'Search by name, phone, or Arvind ID...',
                    onChanged: () => _searchUser(_userSearchCtrl.text),
                  ),
                  const SizedBox(height: 12),
                  if (_isSearching)
                    const Center(child: CircularProgressIndicator(color: Color(0xFFFF8906)))
                  else
                    ..._searchResults.map((user) => InkWell(
                      onTap: () {
                        setState(() {
                          _selectedUser = user;
                          _userSearchCtrl.text = user['name'] ?? '';
                          _searchResults.clear();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1928),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF1E1D2F)),
                        ),
                        child: Row(children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFFFF8906),
                            radius: 18,
                            child: Text((user['name'] ?? 'U')[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user['name'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              Text('${user['arvindId'] ?? ''} • ${user['phone'] ?? ''}',
                                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
                            ],
                          )),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text('🪙 ${user['coins'] ?? 0}', style: const TextStyle(color: Color(0xFFFF8906), fontSize: 12)),
                            Text('💎 ${user['diamonds'] ?? 0}', style: const TextStyle(color: Color(0xFF00B4D8), fontSize: 12)),
                          ]),
                        ]),
                      ),
                    )),

                  // Selected user display
                  if (_selectedUser != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2ED573).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF2ED573).withOpacity(0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.check_circle, color: Color(0xFF2ED573), size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Selected: ${_selectedUser!['name']}',
                          style: const TextStyle(color: Color(0xFF2ED573), fontWeight: FontWeight.w600))),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF6B7280), size: 16),
                          onPressed: () => setState(() { _selectedUser = null; _userSearchCtrl.clear(); }),
                        ),
                      ]),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Right: Amount form
          Expanded(
            flex: 2,
            child: LuxuryCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Coin Operation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 16),

                  // Coin type selector
                  Row(children: [
                    Expanded(child: _typeBtn('coins', '🪙 Coins')),
                    const SizedBox(width: 8),
                    Expanded(child: _typeBtn('diamonds', '💎 Diamonds')),
                  ]),
                  const SizedBox(height: 16),

                  // Quick amounts
                  const Text('Quick Amount', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [100, 500, 1000, 5000, 10000, 50000].map((amt) =>
                    ActionChip(
                      label: Text('$amt', style: const TextStyle(color: Color(0xFFFF8906), fontSize: 12)),
                      backgroundColor: const Color(0xFFFF8906).withOpacity(0.1),
                      side: BorderSide(color: const Color(0xFFFF8906).withOpacity(0.3)),
                      onPressed: () => _coinAmountCtrl.text = '$amt',
                    ),
                  ).toList()),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _coinAmountCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecor('Amount', '${_coinType == 'coins' ? '🪙' : '💎'} Enter amount'),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _reasonCtrl,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 2,
                    decoration: _inputDecor('Reason (Required)', 'Why are you adding/deducting?'),
                  ),
                  const SizedBox(height: 20),

                  Row(children: [
                    Expanded(child: LuxuryButton(
                      label: 'Add ${_coinType == 'coins' ? 'Coins' : 'Diamonds'}',
                      icon: Icons.add,
                      onPressed: _addCoins,
                      isLoading: _isAdding,
                      color: const Color(0xFF2ED573),
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: LuxuryButton(
                      label: 'Deduct',
                      icon: Icons.remove,
                      onPressed: _deductCoins,
                      isLoading: _isAdding,
                      color: const Color(0xFFFF4757),
                    )),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeBtn(String type, String label) {
    final isSelected = _coinType == type;
    return InkWell(
      onTap: () => setState(() => _coinType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF8906).withOpacity(0.15) : const Color(0xFF1A1928),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? const Color(0xFFFF8906) : const Color(0xFF1E1D2F)),
        ),
        child: Center(child: Text(label,
          style: TextStyle(color: isSelected ? const Color(0xFFFF8906) : const Color(0xFF6B7280),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
      ),
    );
  }

  Widget _buildBulkTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: LuxuryCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bulk Coin Distribution', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 6),
            const Text('Add coins to multiple users at once. Enter comma-separated User IDs.',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
            const SizedBox(height: 20),
            TextField(
              controller: _bulkUserIdsCtrl,
              maxLines: 5,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: _inputDecor('User IDs (comma-separated)', 'userId1, userId2, userId3...'),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _typeBtn('coins', '🪙 Coins')),
              const SizedBox(width: 8),
              Expanded(child: _typeBtn('diamonds', '💎 Diamonds')),
            ]),
            const SizedBox(height: 12),
            TextField(
              controller: _bulkAmountCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecor('Amount per user', 'e.g. 1000'),
            ),
            const SizedBox(height: 20),
            LuxuryButton(label: 'Distribute to All', icon: Icons.send, onPressed: _bulkAdd, isLoading: _isBulkLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LuxuryDataTable(
        isLoading: _isLoading,
        columns: const ['Time', 'Admin', 'User', 'Type', 'Amount', 'Reason'],
        emptyMessage: 'No coin audit logs',
        rows: _auditLogs.map((log) => [
          Text(_formatDate(log['createdAt']), style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
          Text(log['adminName'] ?? 'System', style: const TextStyle(color: Color(0xFFFF8906))),
          Text(log['userName'] ?? '—', style: const TextStyle(color: Colors.white)),
          StatusBadge(
            label: log['type'] ?? 'coins',
            color: log['type'] == 'diamonds' ? const Color(0xFF00B4D8) : const Color(0xFFFF8906),
          ),
          Text(
            '${(log['amount'] ?? 0) > 0 ? '+' : ''}${log['amount']}',
            style: TextStyle(color: (log['amount'] ?? 0) > 0 ? const Color(0xFF2ED573) : const Color(0xFFFF4757),
              fontWeight: FontWeight.bold),
          ),
          Text(log['reason'] ?? '—', style: const TextStyle(color: Color(0xFFB8B8D1))),
        ]).toList(),
      ),
    );
  }

  Widget _buildConfigTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        LuxuryCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Economy Configuration', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Diamond to Coin Rate', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                  const SizedBox(height: 6),
                  TextField(controller: _rateCtrl, keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecor('Rate', '1 Diamond = X Coins')),
                ])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Min Withdrawal (Diamonds)', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                  const SizedBox(height: 6),
                  TextField(controller: _minWithdrawCtrl, keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecor('Min', 'e.g. 500')),
                ])),
              ]),
              const SizedBox(height: 20),
              LuxuryButton(label: 'Save Configuration', icon: Icons.save, onPressed: _saveConfig, isLoading: _isSavingConfig),
            ],
          ),
        ),
      ]),
    );
  }

  InputDecoration _inputDecor(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Color(0xFF6B7280)),
      hintStyle: const TextStyle(color: Color(0xFF3A3A4A), fontSize: 12),
      filled: true,
      fillColor: const Color(0xFF1A1928),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E1D2F))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E1D2F))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF8906))),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '—';
    try {
      final d = DateTime.parse(date.toString());
      return '${d.day}/${d.month} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) { return date.toString(); }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
