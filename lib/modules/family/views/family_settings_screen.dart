import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/family_controller.dart';

class FamilySettingsScreen extends StatefulWidget {
  const FamilySettingsScreen({super.key});

  @override
  State<FamilySettingsScreen> createState() => _FamilySettingsScreenState();
}

class _FamilySettingsScreenState extends State<FamilySettingsScreen> {
  final FamilyController controller = Get.find<FamilyController>();

  final _noticeController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (controller.currentFamily.value != null) {
      _noticeController.text = controller.currentFamily.value!.notice;
      _descController.text = controller.currentFamily.value!.description;
    }
  }

  @override
  void dispose() {
    _noticeController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xff15141F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Family Control Settings",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 550),
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Notice Text Input
                  _buildLabel("Edit Pinned Family Notice"),
                  TextFormField(
                    controller: _noticeController,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration:
                        _inputDecoration("Enter pinned bulletin ticker..."),
                  ),
                  const SizedBox(height: 16),

                  // 2. Description Text Input
                  _buildLabel("Edit Manifesto Description"),
                  TextFormField(
                    controller: _descController,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration:
                        _inputDecoration("Update description details..."),
                  ),
                  const SizedBox(height: 24),

                  // 3. Execution Action Trigger Sticky Button
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffFF8906),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(23)),
                      ),
                      onPressed: () {
                        controller.updateFamilySettings(
                            _noticeController.text, _descController.text);
                        Get.back();
                      },
                      child: const Text("Apply Operational Sync ⚙️",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 6, left: 2),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
        filled: true,
        fillColor: const Color(0xff15141F),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
      );
}
