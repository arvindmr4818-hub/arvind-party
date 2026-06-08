import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/family_controller.dart';

class CreateFamilyScreen extends StatefulWidget {
  const CreateFamilyScreen({super.key});

  @override
  State<CreateFamilyScreen> createState() => _CreateFamilyScreenState();
}

class _CreateFamilyScreenState extends State<CreateFamilyScreen> {
  final FamilyController controller = Get.find<FamilyController>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
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
          "Establish New Family Hub",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 550),
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Mock Avatar/Logo Selection Frame Placeholder
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            height: 90,
                            width: 90,
                            decoration: BoxDecoration(
                              color: const Color(0xff15141F),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color:
                                      const Color(0xffFF8906).withOpacity(0.3),
                                  width: 2),
                            ),
                            child: const Center(
                              child: Icon(Icons.shield_outlined,
                                  color: Color(0xffFF8906), size: 36),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                                color: Color(0xffFF8906),
                                shape: BoxShape.circle),
                            child: const Icon(Icons.camera_enhance_outlined,
                                color: Colors.white, size: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 2. Family Name Entry field block
                    _buildFieldLabel("Family Title Identifier Name"),
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      validator: (v) => v!.trim().isEmpty
                          ? "Family title cannot be blank"
                          : null,
                      decoration:
                          _inputDecoration("Enter high-impact family title..."),
                    ),
                    const SizedBox(height: 16),

                    // 3. Family Description Field block
                    _buildFieldLabel("Manifesto / Strategic Goals Description"),
                    TextFormField(
                      controller: _descController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      validator: (v) => v!.trim().length < 10
                          ? "Description must cross 10 characters limit"
                          : null,
                      decoration: _inputDecoration(
                          "Define rules, guidelines and motivation targets..."),
                    ),
                    const SizedBox(height: 30),

                    // 4. Absolute Operational Execution Activation Action Button
                    Obx(() {
                      bool processing = controller.isLoading.value;
                      return SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffFF8906),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(23)),
                          ),
                          onPressed: processing
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                      controller.createNewFamily2(
                                        name: _nameController.text,
                                        desc: _descController.text,
                                      );
                                  }
                                },
                          child: processing
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text("Deploy Clan Network 👑",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 2),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w500)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
      filled: true,
      fillColor: const Color(0xff15141F),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xffFF8906), width: 1)),
    );
  }
}
