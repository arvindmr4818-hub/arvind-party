import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../models/user_profile_model.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nicknameController;
  late TextEditingController bioController;
  late TextEditingController websiteController;
  String? selectedGender;
  String? selectedCountry;
  DateTime? selectedBirthday;
  List<String> selectedInterests = [];

  @override
  void initState() {
    super.initState();
    nicknameController = TextEditingController(text: widget.profile.nickname);
    bioController = TextEditingController(text: widget.profile.bio);
    websiteController = TextEditingController(text: widget.profile.website);
    selectedGender = widget.profile.gender;
    selectedCountry = widget.profile.country;
    selectedBirthday = widget.profile.birthday;
    selectedInterests = List.from(widget.profile.interests);
  }

  @override
  void dispose() {
    nicknameController.dispose();
    bioController.dispose();
    websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: () {
              controller.updateProfile(
                nickname: nicknameController.text,
                bio: bioController.text,
                gender: selectedGender,
                country: selectedCountry,
                birthday: selectedBirthday,
                website: websiteController.text,
                interests: selectedInterests,
              );
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nicknameController,
              decoration: const InputDecoration(
                labelText: 'Nickname',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: websiteController,
              decoration: const InputDecoration(
                labelText: 'Website',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedGender,
              items: const [
                DropdownMenuItem(value: 'male', child: Text('Male')),
                DropdownMenuItem(value: 'female', child: Text('Female')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (value) => setState(() => selectedGender = value),
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedBirthday ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => selectedBirthday = picked);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Birthday',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  selectedBirthday != null
                      ? '${selectedBirthday!.day}/${selectedBirthday!.month}/${selectedBirthday!.year}'
                      : 'Select date',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}