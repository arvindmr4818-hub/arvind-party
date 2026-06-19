import 'package:flutter/material.dart';

class FilePickerWidget extends StatelessWidget {
  final Function(String) onFilePicked;

  const FilePickerWidget({super.key, required this.onFilePicked});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _FileOption(
            icon: Icons.image,
            label: 'Photo',
            onTap: () {
              // Pick image from gallery
            },
          ),
          _FileOption(
            icon: Icons.videocam,
            label: 'Video',
            onTap: () {
              // Pick video from gallery
            },
          ),
          _FileOption(
            icon: Icons.description,
            label: 'Document',
            onTap: () {
              // Pick document
            },
          ),
          _FileOption(
            icon: Icons.audio_file,
            label: 'Audio',
            onTap: () {
              // Pick audio file
            },
          ),
          _FileOption(
            icon: Icons.location_on,
            label: 'Location',
            onTap: () {
              // Share location
            },
          ),
          _FileOption(
            icon: Icons.person,
            label: 'Contact',
            onTap: () {
              // Share contact
            },
          ),
        ],
      ),
    );
  }
}

class _FileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FileOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}