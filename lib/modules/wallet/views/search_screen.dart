import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/search_controller.dart';

class GlobalSearchScreen extends StatelessWidget {
  const GlobalSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GlobalSearchController());

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF15141F),
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back()),
        title: TextField(
          controller: controller.searchInput,
          style: const TextStyle(color: Colors.white),
          autofocus: true,
          // ✅ FIX 1: Wrapped inside a string value parameter loop callback to fix argument signature mismatch
          onSubmitted: (value) => controller.performSearch(),
          decoration: InputDecoration(
            hintText: 'Search ID, Username or Room...',
            hintStyle: const TextStyle(color: Colors.white38),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search, color: Color(0xFFFF8906)),
              onPressed: () => controller.performSearch(),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Dynamic Tab Streams Layout
          Row(
            children: [
              _buildTab(controller, 'user', 'Users'),
              _buildTab(controller, 'room', 'Rooms'),
            ],
          ),
          const Divider(color: Colors.white12, height: 1),

          // Database Results Frame
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF8906)));
              }
              
              // Reading filtered state properties dynamically
              final searchItems = controller.filteredResults;

              if (searchItems.isEmpty) {
                return const Center(
                    child: Text('No real matching index entries found',
                        style: TextStyle(color: Colors.white54)));
              }

              return ListView.builder(
                itemCount: searchItems.length,
                itemBuilder: (context, index) {
                  final item = searchItems[index];
                  // ✅ FIX 2: Check status using your controller's dynamic reactive lookup mapping
                  final isCurrentlyFollowing = controller.isFollowing(item.id);

                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                        backgroundColor: Colors.white10,
                        backgroundImage: item.imageUrl.isNotEmpty ? NetworkImage(item.imageUrl) : null,
                        radius: 25,
                        child: item.imageUrl.isEmpty ? const Icon(Icons.person, color: Colors.white38) : null,
                    ),
                    title: Text(item.title,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(item.subtitle,
                        style: const TextStyle(color: Colors.white54)),
                    trailing: item.type == 'user'
                        ? ElevatedButton(
                            // ✅ FIX 3: Hooked into your actual backend relationship mutation API stream
                            onPressed: () => controller.toggleFollow(item),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: isCurrentlyFollowing
                                    ? Colors.white10
                                    : const Color(0xFFFF8906),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20))),
                            child: Text(
                                isCurrentlyFollowing ? 'Following' : 'Follow',
                                style: const TextStyle(color: Colors.white)),
                          )
                        : const Icon(Icons.meeting_room,
                            color: Color(0xFFFF8906)),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
      GlobalSearchController controller, String type, String title) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.selectedType.value == type;
        return InkWell(
          onTap: () => controller.switchTab(type),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: isSelected
                            ? const Color(0xFFFF8906)
                            : Colors.transparent,
                        width: 2))),
            child: Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color:
                        isSelected ? const Color(0xFFFF8906) : Colors.white54,
                    fontWeight: FontWeight.bold)),
          ),
        );
      }),
    );
  }
}