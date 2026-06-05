// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/modules/home/controllers/home_controller.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../room/models/room_model.dart';

class HomeController extends GetxController {
  // ─── NAVIGATION ───────────────────────────────────────────────────────────
  final currentIndex = 0.obs;

  void changeTab(int index) => currentIndex.value = index;

  // ─── USER SESSION ─────────────────────────────────────────────────────────
  final userName = ''.obs;
  final userAvatar = ''.obs;
  final userLevel = 1.obs;
  final userCoins = 0.obs;

  // ─── DISCOVER STATE ───────────────────────────────────────────────────────
  final selectedCategory = 'All'.obs;
  final isDiscoverLoading = false.obs;
  final searchQuery = ''.obs;

  final discoverRooms = <RoomModel>[].obs; // filtered list shown in UI
  final _allRooms = <RoomModel>[]; // master list

  final categories = const [
    'All',
    'Trending',
    'Music',
    'Gaming',
    'Talk',
    'Study',
    'Dating',
    'Sports',
  ];

  // ─── ROOMS TAB STATE ──────────────────────────────────────────────────────
  final isRoomsLoading = false.obs;
  final liveRooms = <RoomModel>[].obs;
  final selectedRoomFilter = 'All'.obs;

  final roomFilters = const ['All', 'Public', 'Private', 'New'];

  // ─── SEARCH CONTROLLER ────────────────────────────────────────────────────
  final searchCtrl = TextEditingController();

  // ─── STORAGE ──────────────────────────────────────────────────────────────
  final _storage = GetStorage();

  // ─────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadUserSession();
    _loadDummyRooms();
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // USER SESSION
  // ─────────────────────────────────────────────────────────────────────────

  void _loadUserSession() {
    userName.value = _storage.read<String>('user_name') ?? 'User';
    userAvatar.value = _storage.read<String>('user_avatar') ?? '';
    userCoins.value = _storage.read<int>('user_coins') ?? 0;
    userLevel.value = _storage.read<int>('user_level') ?? 1;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DISCOVER — CATEGORY FILTER
  // ─────────────────────────────────────────────────────────────────────────

  void selectCategory(String cat) {
    selectedCategory.value = cat;
    _applyFilters();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void clearSearch() {
    searchCtrl.clear();
    searchQuery.value = '';
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = List<RoomModel>.from(_allRooms);

    // Category filter
    if (selectedCategory.value != 'All') {
      filtered = filtered
          .where((r) => r.topic
              .toLowerCase()
              .contains(selectedCategory.value.toLowerCase()))
          .toList();
    }

    // Search filter
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      filtered = filtered
          .where((r) =>
              r.title.toLowerCase().contains(q) ||
              r.topic.toLowerCase().contains(q))
          .toList();
    }

    discoverRooms.assignAll(filtered);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ROOMS TAB — FILTER
  // ─────────────────────────────────────────────────────────────────────────

  void selectRoomFilter(String filter) {
    selectedRoomFilter.value = filter;
    _applyRoomFilter();
  }

  void _applyRoomFilter() {
    var filtered = List<RoomModel>.from(_allRooms);
    switch (selectedRoomFilter.value) {
      case 'Public':
        filtered = filtered.where((r) => r.roomType == 'public').toList();
        break;
      case 'Private':
        filtered = filtered.where((r) => r.roomType != 'public').toList();
        break;
      case 'New':
        filtered = filtered.take(5).toList();
        break;
    }
    liveRooms.assignAll(filtered);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DUMMY DATA — Backend se replace karna
  // ─────────────────────────────────────────────────────────────────────────

  void _loadDummyRooms() {
    final rooms = [
      RoomModel(
          id: 'r1',
          title: 'Bollywood Night 🎵',
          topic: 'Music • Trending',
          banner:
              'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&q=80',
          welcomeMessage: 'Welcome!',
          announcement: 'Sing with us!',
          roomType: 'public',
          seatCount: 10,
          onlineUsers: 234,
          hostId: 'u1'),
      RoomModel(
          id: 'r2',
          title: 'Cricket Talk ⚡',
          topic: 'Sports • Talk',
          banner:
              'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=400&q=80',
          welcomeMessage: 'Welcome!',
          announcement: '',
          roomType: 'public',
          seatCount: 8,
          onlineUsers: 189,
          hostId: 'u2'),
      RoomModel(
          id: 'r3',
          title: 'Desi Beats 🥁',
          topic: 'Music • Gaming',
          banner:
              'https://images.unsplash.com/photo-1571330735066-03aaa9429d89?w=400&q=80',
          welcomeMessage: 'Welcome!',
          announcement: '',
          roomType: 'public',
          seatCount: 15,
          onlineUsers: 412,
          hostId: 'u3'),
      RoomModel(
          id: 'r4',
          title: 'Study With Me 📚',
          topic: 'Study • Chill',
          banner:
              'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=400&q=80',
          welcomeMessage: 'Let\'s focus!',
          announcement: 'Pomodoro 25min starts now',
          roomType: 'public',
          seatCount: 8,
          onlineUsers: 67,
          hostId: 'u4'),
      RoomModel(
          id: 'r5',
          title: 'VIP Lounge 👑',
          topic: 'Dating • Talk',
          banner:
              'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400&q=80',
          welcomeMessage: 'VIPs welcome!',
          announcement: '',
          roomType: 'password',
          seatCount: 8,
          onlineUsers: 55,
          hostId: 'u5'),
      RoomModel(
          id: 'r6',
          title: 'Rap Battle 🎤',
          topic: 'Music • Trending',
          banner:
              'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&q=80',
          welcomeMessage: 'Spit bars!',
          announcement: 'Next battle in 10 min',
          roomType: 'public',
          seatCount: 10,
          onlineUsers: 301,
          hostId: 'u6'),
      RoomModel(
          id: 'r7',
          title: 'Meditation 🧘',
          topic: 'Study • Chill',
          banner:
              'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=400&q=80',
          welcomeMessage: 'Find your peace',
          announcement: '',
          roomType: 'public',
          seatCount: 8,
          onlineUsers: 28,
          hostId: 'u7'),
      RoomModel(
          id: 'r8',
          title: 'Gaming Squad 🎮',
          topic: 'Gaming • Talk',
          banner:
              'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400&q=80',
          welcomeMessage: 'GG!',
          announcement: 'BGMI tournament tonight',
          roomType: 'public',
          seatCount: 20,
          onlineUsers: 533,
          hostId: 'u8'),
    ];

    _allRooms
      ..clear()
      ..addAll(rooms);

    discoverRooms.assignAll(rooms);
    liveRooms.assignAll(rooms);
  }
}
