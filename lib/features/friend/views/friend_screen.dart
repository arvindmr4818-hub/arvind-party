import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/friend_controller.dart';
import '../models/friend_model.dart';
import '../widgets/friend_tile.dart';
import '../widgets/friend_request_tile.dart';

class FriendScreen extends GetView<FriendController> {
  const FriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(FriendController());
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Friends', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(tabs: [
            Tab(text: 'Friends', icon: Icon(Icons.people)),
            Tab(text: 'Following', icon: Icon(Icons.person_add)),
            Tab(text: 'Followers', icon: Icon(Icons.person_outline)),
            Tab(text: 'Requests', icon: Icon(Icons.notifications)),
          ]),
        ),
        body: Obx(() {
          if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
          return TabBarView(children: [
            _buildList(controller.friends, 'No friends yet'),
            _buildList(controller.following, 'Not following anyone'),
            _buildList(controller.followers, 'No followers yet'),
            _buildRequests(),
          ]);
        }),
      ),
    );
  }

  Widget _buildList(List<FriendModel> list, String emptyMessage) {
    if (list.isEmpty) return Center(child: Text(emptyMessage, style: TextStyle(color: Colors.grey)));
    return ListView.builder(padding: const EdgeInsets.all(12), itemCount: list.length,
      itemBuilder: (context, index) => FriendTile(friend: list[index]));
  }

  Widget _buildRequests() {
    if (controller.incomingRequests.isEmpty && controller.outgoingRequests.isEmpty) {
      return const Center(child: Text('No friend requests', style: TextStyle(color: Colors.grey)));
    }
    return ListView(padding: const EdgeInsets.all(12), children: [
      if (controller.incomingRequests.isNotEmpty) ...[
        const Padding(padding: EdgeInsets.only(top: 8, bottom: 4), child: Text('Incoming', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
        ...controller.incomingRequests.map((r) => FriendRequestTile(request: r, isIncoming: true)).toList(),
        const Divider(),
      ],
      if (controller.outgoingRequests.isNotEmpty) ...[
        const Padding(padding: EdgeInsets.only(top: 8, bottom: 4), child: Text('Outgoing', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange))),
        ...controller.outgoingRequests.map((r) => FriendRequestTile(request: r, isIncoming: false)).toList(),
      ],
    ]);
  }
}