// ═══════════════════════════════════════════════════════════════════════════
// GIFTS MANAGEMENT VIEW — Add, Edit, Delete, Preview
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../shared/admin_shell.dart';

class GiftsManagementView extends StatefulWidget {
  const GiftsManagementView({super.key});
  @override
  State<GiftsManagementView> createState() => _GiftsManagementViewState();
}

class _GiftsManagementViewState extends State<GiftsManagementView> with SingleTickerProviderStateMixin {
  final _api = Get.find<ApiService>();
  List<Map<String, dynamic>> _gifts = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  late TabController _tabs;
  String _filterCategory = 'all';

  // Form
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _animCtrl = TextEditingController();
  String _formCategory = 'basic';
  bool _isSpecial = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final g = await _api.get('/gifts');
      if (g['success'] == true) _gifts = List<Map<String, dynamic>>.from(g['data'] ?? []);
      final c = await _api.get('/gifts/categories');
      if (c['success'] == true) _categories = List<Map<String, dynamic>>.from(c['data'] ?? []);
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _saveGift({String? editId}) async {
    if (_nameCtrl.text.isEmpty || _priceCtrl.text.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      final body = {
        'name': _nameCtrl.text.trim(),
        'price': int.tryParse(_priceCtrl.text) ?? 0,
        'imageUrl': _imageCtrl.text.trim(),
        'animationUrl': _animCtrl.text.trim(),
        'category': _formCategory,
        'isSpecial': _isSpecial,
      };
      final res = editId != null
          ? await _api.put('/gifts/$editId', body)
          : await _api.post('/gifts/create', body);
      if (res['success'] == true) {
        Get.back();
        Get.snackbar('Saved ✅', editId != null ? 'Gift updated' : 'Gift created',
            backgroundColor: const Color(0xFF2ED573), colorText: Colors.black);
        _nameCtrl.clear(); _priceCtrl.clear(); _imageCtrl.clear(); _animCtrl.clear();
        _load();
      }
    } catch (_) {}
    setState(() => _isSaving = false);
  }

  Future<void> _deleteGift(String id, String name) async {
    final ok = await showDialog<bool>(context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1928),
        title: const Text('Delete Gift', style: TextStyle(color: Colors.white)),
        content: Text('Delete "$name"?', style: const TextStyle(color: Color(0xFFB8B8D1))),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4757)),
            onPressed: () => Get.back(result: true),
            child: const Text('Delete', style: TextStyle(color: Colors.white))),
        ],
      )) ?? false;
    if (!ok) return;
    await _api.delete('/gifts/$id');
    _load();
  }

  void _showGiftDialog({Map<String, dynamic>? gift}) {
    if (gift != null) {
      _nameCtrl.text = gift['name'] ?? '';
      _priceCtrl.text = '${gift['price'] ?? 0}';
      _imageCtrl.text = gift['imageUrl'] ?? '';
      _animCtrl.text = gift['animationUrl'] ?? '';
      _formCategory = gift['category'] ?? 'basic';
      _isSpecial = gift['isSpecial'] == true;
    } else {
      _nameCtrl.clear(); _priceCtrl.clear(); _imageCtrl.clear(); _animCtrl.clear();
      _formCategory = 'basic'; _isSpecial = false;
    }

    showDialog(context: context, builder: (_) => StatefulBuilder(
      builder: (ctx, setS) => AlertDialog(
        backgroundColor: const Color(0xFF1A1928),
        title: Text(gift != null ? 'Edit Gift' : 'Add New Gift',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SizedBox(width: 480, child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Expanded(child: _field(_nameCtrl, 'Gift Name', Icons.card_giftcard)),
            const SizedBox(width: 12),
            Expanded(child: _field(_priceCtrl, 'Price (Coins)', Icons.monetization_on, TextInputType.number)),
          ]),
          const SizedBox(height: 12),
          _field(_imageCtrl, 'Image URL', Icons.image),
          const SizedBox(height: 12),
          _field(_animCtrl, 'Animation URL (optional)', Icons.animation),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: DropdownButtonFormField<String>(
              value: _formCategory,
              dropdownColor: const Color(0xFF0F0E1A),
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecor('Category', Icons.category),
              items: ['basic', 'premium', 'vip', 'special', 'seasonal'].map((c) =>
                DropdownMenuItem(value: c, child: Text(c.toUpperCase()))).toList(),
              onChanged: (v) => setS(() => _formCategory = v!),
            )),
            const SizedBox(width: 12),
            Column(children: [
              const Text('Special?', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
              Switch(value: _isSpecial, activeColor: const Color(0xFFFF8906),
                onChanged: (v) => setS(() => _isSpecial = v)),
            ]),
          ]),
        ])),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          LuxuryButton(label: gift != null ? 'Update' : 'Create',
            icon: gift != null ? Icons.save : Icons.add,
            onPressed: () => _saveGift(editId: gift?['_id']),
            isLoading: _isSaving),
        ],
      ),
    ));
  }

  List<Map<String, dynamic>> get _filtered => _filterCategory == 'all'
      ? _gifts : _gifts.where((g) => g['category'] == _filterCategory).toList();

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Gifts Management',
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            // Category filter chips
            Expanded(child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: ['all', 'basic', 'premium', 'vip', 'special', 'seasonal'].map((cat) =>
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat.toUpperCase(), style: const TextStyle(fontSize: 11)),
                    selected: _filterCategory == cat,
                    selectedColor: const Color(0xFFFF8906).withOpacity(0.2),
                    checkmarkColor: const Color(0xFFFF8906),
                    labelStyle: TextStyle(color: _filterCategory == cat ? const Color(0xFFFF8906) : const Color(0xFF6B7280)),
                    side: BorderSide(color: _filterCategory == cat ? const Color(0xFFFF8906) : const Color(0xFF1E1D2F)),
                    backgroundColor: const Color(0xFF0F0E1A),
                    onSelected: (_) => setState(() => _filterCategory = cat),
                  ),
                ),
              ).toList()),
            )),
            LuxuryButton(label: 'Add Gift', icon: Icons.add, onPressed: () => _showGiftDialog()),
          ]),
        ),

        // Gift grid
        Expanded(child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF8906)))
          : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.75),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final g = _filtered[i];
                return LuxuryCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(children: [
                    Stack(children: [
                      Container(
                        height: 80, width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1928),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: g['imageUrl'] != null && (g['imageUrl'] as String).isNotEmpty
                          ? ClipRRect(borderRadius: BorderRadius.circular(10),
                              child: Image.network(g['imageUrl'], fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(Icons.card_giftcard, color: Color(0xFFFF8906), size: 40)))
                          : const Icon(Icons.card_giftcard, color: Color(0xFFFF8906), size: 40),
                      ),
                      if (g['isSpecial'] == true)
                        Positioned(top: 4, right: 4, child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(6)),
                          child: const Icon(Icons.star, color: Colors.black, size: 10),
                        )),
                    ]),
                    const SizedBox(height: 10),
                    Text(g['name'] ?? '—', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    StatusBadge(label: (g['category'] ?? 'basic').toUpperCase(),
                      color: _catColor(g['category'] ?? '')),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.monetization_on, color: Color(0xFFFF8906), size: 14),
                      const SizedBox(width: 4),
                      Text('${g['price'] ?? 0}', style: const TextStyle(color: Color(0xFFFF8906), fontWeight: FontWeight.bold, fontSize: 14)),
                    ]),
                    const SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      IconButton(icon: const Icon(Icons.edit, size: 16, color: Color(0xFFFF8906)),
                        onPressed: () => _showGiftDialog(gift: g), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                      const SizedBox(width: 16),
                      IconButton(icon: const Icon(Icons.delete, size: 16, color: Color(0xFFFF4757)),
                        onPressed: () => _deleteGift(g['_id'], g['name'] ?? ''), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                    ]),
                  ]),
                );
              },
            )),
      ]),
    );
  }

  Color _catColor(String cat) {
    switch (cat) {
      case 'premium': return const Color(0xFFFF8906);
      case 'vip': return const Color(0xFFFFD700);
      case 'special': return const Color(0xFFFF4757);
      case 'seasonal': return const Color(0xFF2ED573);
      default: return const Color(0xFF6B7280);
    }
  }

  Widget _field(TextEditingController c, String label, IconData icon, [TextInputType? type]) =>
    TextField(controller: c, style: const TextStyle(color: Colors.white),
      keyboardType: type, decoration: _inputDecor(label, icon));

  InputDecoration _inputDecor(String label, IconData icon) => InputDecoration(
    labelText: label, labelStyle: const TextStyle(color: Color(0xFF6B7280)),
    prefixIcon: Icon(icon, color: const Color(0xFF6B7280), size: 18),
    filled: true, fillColor: const Color(0xFF0F0E1A),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E1D2F))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E1D2F))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF8906))),
  );

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }
}
