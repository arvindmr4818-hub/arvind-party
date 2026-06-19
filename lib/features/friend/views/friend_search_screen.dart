import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/friend_controller.dart';
import '../models/friend_model.dart';
import '../widgets/friend_tile.dart';

class FriendSearchScreen extends GetView<FriendController> {
  const FriendSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(FriendController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Users'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by username...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (query) {
                final mockResults = List.generate(5, (i) => FriendModel(
                  id: 'search_$i',
                  username: 'User $i ($query)',
                  avatarUrl: 'https://picsum.photos/seed/s$i/100',
                  status: i % 2 == 0 ? FriendStatus.none : FriendStatus.following,
                ));
                Get.dialog(
                  Dialog(
                    child: Container(
                      height: 400,
                      padding: const EdgeInsets.all(16),
                      child: ListView.builder(
                        itemCount: mockResults.length,
                        itemBuilder: (context, index) => FriendTile(friend: mockResults[index]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Center(
              child: Text('Search for users to follow or add as friends', style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }
}