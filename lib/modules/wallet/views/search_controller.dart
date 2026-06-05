import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/search_result_model.dart';

class GlobalSearchController extends GetxController {
  final searchInput = TextEditingController();
  final isLoading = false.obs;
  final results = <SearchResultModel>[].obs;
  final selectedType = 'user'.obs; // 'user' or 'room'

  void switchTab(String type) {
    selectedType.value = type;
    if (searchInput.text.isNotEmpty) {
      performSearch(searchInput.text);
    }
  }

  void performSearch(String query) async {
    if (query.trim().isEmpty) {
      results.clear();
      return;
    }
    
    isLoading.value = true;
    // TODO: Call backend -> apiService.search(query, selectedType.value)
    await Future.delayed(const Duration(milliseconds: 600));
    
    if (selectedType.value == 'user') {
      results.assignAll([
        SearchResultModel(id: 'u1', title: 'User $query', subtitle: 'ID: 100234', imageUrl: 'https://picsum.photos/seed/u1/100', type: 'user'),
        SearchResultModel(id: 'u2', title: '${query}XYZ', subtitle: 'ID: 887123', imageUrl: 'https://picsum.photos/seed/u2/100', type: 'user', isFollowing: true),
      ]);
    } else {
      results.assignAll([
        SearchResultModel(id: 'r1', title: '$query Party Room', subtitle: 'Host: Arvind', imageUrl: 'https://picsum.photos/seed/r1/100', type: 'room'),
      ]);
    }
    
    isLoading.value = false;
  }
}