// ═══════════════════════════════════════════════════════════════════════════
// STAFF MANAGEMENT VIEW — Complete CRUD
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../shared/admin_shell.dart';

class StaffManagementView extends StatefulWidget {
  const StaffManagementView({super.key});
  @override
  State<StaffManagementView> createState() => _StaffManagementViewState();
}

class _StaffManagementViewState extends State<StaffManagementView> {
  final _api = Get.find<ApiService>();
  List<Map<String, dynamic>> _staff = [];
  bool _isLoading = true;
  final _searchCtrl = TextEditingController();

  // Add staff form
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _selectedRole = 'moderator';
  bool _isAdding = false;

  final List<Map<String, String>> _roles = [
    {'value': 'moderator', 'label': 'Moderator'},
    {'value': 'support', 'label': 'Support Agent'},
    {'value': 'content_manager', 'label': 'Content Manager'},
    {'value': 'finance', 'label': 'Finance'},
    {'value': 'admin', 'label': 'Admin'},
    {'value': 'super_admin', 'label': 'Super Admin'},
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get('/staff', queryParams: {
        if (_searchCtrl.text.isNotEmpty) 'search': _searchCtrl.text,
      });
      if (res['success'] == true) {
        _staff = List<Map<String, dynamic>>.from(res['data'] ?? []);
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _addStaff() async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty) return;
    setState(() => _isAdding = true);
    try {
      final res = await _api.post('/staff/create', {
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'role': _selectedRole,
      });
      if (res['success'] == true) {
        Get.snackbar('Success ✅', 'Staff member added. Password sent to email.',
            backgroundColor: const Color(0xFF2ED573), colorText: Colors.black);
        _nameCtrl.clear(); _emailCtrl.clear(); _phoneCtrl.clear();
        Get.back();
        _load();
      } else {
        Get.snackbar('Error', res['message'] ?? 'Failed',
            backgroundColor: const Color(0xFFFF4757), colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: const Color(0xFFFF4757), colorText: Colors.white);
    }
    setState(() => _isAdding = false);
  }

  Future<void> _toggleStatus(String id, bool current) async {
    try {
      await _api.put('/staff/$id/status', {'isActive': !current});
      _load();
    } catch (_) {}
  }

  Future<void> _deleteStaff(String id, String name) async {
    final ok = await showDialog<bool>(context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1928),
        title: const Text('Delete Staff', style: TextStyle(color: Colors.white)),
        content: Text('Remove $name from staff?', style: const TextStyle(color: Color(0xFFB8B8D1))),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4757)),
            onPressed: () => Get.back(result: true),
            child: const Text('Delete', style: TextStyle(color: Colors.white))),
        ],
      )) ?? false;
    if (!ok) return;
    try {
      await _api.delete('/staff/$id');
      Get.snackbar('Deleted', '$name removed from staff', backgroundColor: const Color(0xFFFF4757), colorText: Colors.white);
      _load();
    } catch (_) {}
  }

  void _showAddDialog() {
    showDialog(context: context, builder: (_) => StatefulBuilder(
      builder: (ctx, setS) => AlertDialog(
        backgroundColor: const Color(0xFF1A1928),
        title: const Text('Add Staff Member', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SizedBox(width: 420, child: Column(mainAxisSize: MainAxisSize.min, children: [
          _field(_nameCtrl, 'Full Name', Icons.person),
          const SizedBox(height: 12),
          _field(_emailCtrl, 'Email Address', Icons.email),
          const SizedBox(height: 12),
          _field(_phoneCtrl, 'Phone Number', Icons.phone),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            dropdownColor: const Color(0xFF1A1928),
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecor('Role', Icons.admin_panel_settings),
            items: _roles.map((r) => DropdownMenuItem(value: r['value'], child: Text(r['label']!))).toList(),
            onChanged: (v) => setS(() => _selectedRole = v!),
          ),
        ])),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          LuxuryButton(label: 'Add Staff', icon: Icons.add, onPressed: _addStaff, isLoading: _isAdding),
        ],
      ),
    ));
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'super_admin': return const Color(0xFFFF4757);
      case 'admin': return const Color(0xFFFF8906);
      case 'finance': return const Color(0xFF2ED573);
      case 'moderator': return const Color(0xFF00B4D8);
      default: return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Staff Management',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Row(children: [
            Expanded(child: LuxurySearchBar(controller: _searchCtrl, hint: 'Search staff...', onChanged: _load)),
            const SizedBox(width: 12),
            LuxuryButton(label: 'Add Staff', icon: Icons.add, onPressed: _showAddDialog),
          ]),
          const SizedBox(height: 20),
          Expanded(child: LuxuryDataTable(
            isLoading: _isLoading,
            emptyMessage: 'No staff members found',
            columns: const ['Name', 'Email', 'Role', 'Status', 'Joined', 'Actions'],
            rows: _staff.map((s) => [
              Row(children: [
                CircleAvatar(radius: 16, backgroundColor: _roleColor(s['role'] ?? ''),
                  child: Text((s['name'] ?? 'S')[0], style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))),
                const SizedBox(width: 8),
                Text(s['name'] ?? '—', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ]),
              Text(s['email'] ?? '—', style: const TextStyle(color: Color(0xFFB8B8D1))),
              StatusBadge(label: (s['role'] ?? 'staff').toUpperCase(), color: _roleColor(s['role'] ?? '')),
              Switch(value: s['isActive'] == true,
                activeColor: const Color(0xFF2ED573),
                onChanged: (_) => _toggleStatus(s['_id'], s['isActive'] == true)),
              Text(_formatDate(s['createdAt']), style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
              Row(children: [
                IconButton(icon: const Icon(Icons.edit, color: Color(0xFFFF8906), size: 18),
                  onPressed: () => _showEditPermDialog(s)),
                IconButton(icon: const Icon(Icons.delete, color: Color(0xFFFF4757), size: 18),
                  onPressed: () => _deleteStaff(s['_id'], s['name'] ?? '')),
              ]),
            ]).toList(),
          )),
        ]),
      ),
    );
  }

  void _showEditPermDialog(Map<String, dynamic> staff) {
    String newRole = staff['role'] ?? 'moderator';
    showDialog(context: context, builder: (_) => StatefulBuilder(
      builder: (ctx, setS) => AlertDialog(
        backgroundColor: const Color(0xFF1A1928),
        title: Text('Edit Role: ${staff['name']}', style: const TextStyle(color: Colors.white)),
        content: DropdownButtonFormField<String>(
          value: newRole,
          dropdownColor: const Color(0xFF1A1928),
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecor('Role', Icons.admin_panel_settings),
          items: _roles.map((r) => DropdownMenuItem(value: r['value'], child: Text(r['label']!))).toList(),
          onChanged: (v) => setS(() => newRole = v!),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          LuxuryButton(label: 'Update', icon: Icons.save, onPressed: () async {
            await _api.put('/staff/${staff['_id']}/role', {'role': newRole});
            Get.back();
            _load();
          }),
        ],
      ),
    ));
  }

  Widget _field(TextEditingController c, String label, IconData icon) => TextField(
    controller: c, style: const TextStyle(color: Colors.white),
    decoration: _inputDecor(label, icon),
  );

  InputDecoration _inputDecor(String label, IconData icon) => InputDecoration(
    labelText: label, labelStyle: const TextStyle(color: Color(0xFF6B7280)),
    prefixIcon: Icon(icon, color: const Color(0xFF6B7280), size: 18),
    filled: true, fillColor: const Color(0xFF0F0E1A),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E1D2F))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E1D2F))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF8906))),
  );

  String _formatDate(dynamic d) {
    if (d == null) return '—';
    try { final dt = DateTime.parse(d.toString()); return '${dt.day}/${dt.month}/${dt.year}'; } catch (_) { return '—'; }
  }
}
