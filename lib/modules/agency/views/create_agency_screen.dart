import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/agency_controller.dart';

class CreateAgencyScreen extends StatefulWidget {
  const CreateAgencyScreen({super.key});

  @override
  State<CreateAgencyScreen> createState() => _CreateAgencyScreenState();
}

class _CreateAgencyScreenState extends State<CreateAgencyScreen> {
  final AgencyController controller = Get.find<AgencyController>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _termsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _termsController.dispose();
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
          "Register Corporate Agency",
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
                    // 1. Structural Logo Upload Preview Box Mock
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            height: 84,
                            width: 84,
                            decoration: BoxDecoration(
                              color: const Color(0xff15141F),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.cyan.withOpacity(0.3),
                                  width: 1.5),
                            ),
                            child: const Center(
                              child: Icon(Icons.business_center_outlined,
                                  color: Colors.cyan, size: 32),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                                color: Colors.cyan, shape: BoxShape.circle),
                            child: const Icon(Icons.add_a_photo_outlined,
                                color: Colors.black, size: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 2. Agency Name text field blocks
                    _buildInputHeaderLabel("Legal Agency Trading Title"),
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      validator: (v) => v!.trim().isEmpty
                          ? "Agency trading title cannot be blank"
                          : null,
                      decoration:
                          _inputStyle("Enter corporate name identifier..."),
                    ),
                    const SizedBox(height: 16),

                    // 3. Terms configuration block description
                    _buildInputHeaderLabel(
                        "Contractual Settlements Agreement Rules (Terms)"),
                    TextFormField(
                      controller: _termsController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      validator: (v) => v!.trim().length < 15
                          ? "Terms must clarify settlement policies (min 15 chars)"
                          : null,
                      decoration: _inputStyle(
                          "Define payout share allocations, rules, minimum streaming loops criteria..."),
                    ),
                    const SizedBox(height: 26),

                    // 4. Verification Registry Dispatch Trigger Button
                    Obx(() {
                      bool running = controller.isLoading.value;
                      return SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(23)),
                          ),
                          onPressed: running
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    controller.launchNewAgencyHub(
                                      title: _titleController.text,
                                      terms: _termsController.text,
                                    );
                                  }
                                },
                          child: running
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.black, strokeWidth: 2))
                              : const Text("Deploy Talent Grid Hub 🏢",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
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

  Widget _buildInputHeaderLabel(String heading) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 2),
      child: Text(heading,
          style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w500)),
    );
  }

  InputDecoration _inputStyle(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
      filled: true,
      fillColor: const Color(0xff15141F),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.cyan, width: 1)),
    );
  }
}
