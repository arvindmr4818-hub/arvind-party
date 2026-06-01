import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/room_model.dart';
import '../models/seat_model.dart';
import '../models/member_model.dart';
import '../models/room_message_model.dart';
import '../models/gift_model.dart';

class RoomController extends GetxController {

  RxList<GiftModel> gifts = <GiftModel>[].obs;
  RxInt myCoins = 10000.obs;

  RxList<RoomModel> rooms =
      <RoomModel>[].obs;

  RxList<SeatModel> seats =
      <SeatModel>[].obs;

  RxList<MemberModel> members =
      <MemberModel>[].obs;

  RxList<RoomMessageModel> messages =
      <RoomMessageModel>[].obs;

  final TextEditingController chatController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    loadFakeRooms();
    generateSeats();
    loadMembers();
    loadMessages();
  }

  void loadFakeRooms() {

    rooms.assignAll([

      RoomModel(
        id: "1",
        roomName: "Arvind Official",
        ownerName: "Arvind",
        onlineUsers: 120,
      ),

      RoomModel(
        id: "2",
        roomName: "Music Party",
        ownerName: "Rahul",
        onlineUsers: 80,
      ),

      RoomModel(
        id: "3",
        roomName: "Fun Room",
        ownerName: "Aman",
        onlineUsers: 45,
      ),

    ]);
  }

  void generateSeats() {

    seats.assignAll([

      SeatModel(
        seatNumber: 1,
        userName: "Arvind",
        isLocked: false,
        isMuted: false,
        isHost: true,
        isOccupied: true,
      ),

      SeatModel(
        seatNumber: 2,
        userName: "",
        isLocked: false,
        isMuted: false,
        isHost: false,
        isOccupied: false,
      ),

      SeatModel(
        seatNumber: 3,
        userName: "",
        isLocked: true,
        isMuted: false,
        isHost: false,
        isOccupied: false,
      ),

      SeatModel(
        seatNumber: 4,
        userName: "Rahul",
        isLocked: false,
        isMuted: true,
        isHost: false,
        isOccupied: true,
      ),

      SeatModel(
        seatNumber: 5,
        userName: "",
        isLocked: false,
        isMuted: false,
        isHost: false,
        isOccupied: false,
      ),

      SeatModel(
        seatNumber: 6,
        userName: "",
        isLocked: false,
        isMuted: false,
        isHost: false,
        isOccupied: false,
      ),

      SeatModel(
        seatNumber: 7,
        userName: "",
        isLocked: false,
        isMuted: false,
        isHost: false,
        isOccupied: false,
      ),

      SeatModel(
        seatNumber: 8,
        userName: "",
        isLocked: false,
        isMuted: false,
        isHost: false,
        isOccupied: false,
      ),
    ]);
  }

  void loadMembers() {
    members.assignAll([
      MemberModel(
        id: "1",
        name: "Arvind",
        isHost: true,
        isAdmin: true,
        isMuted: false,
        isOnSeat: true,
      ),
      MemberModel(
        id: "2",
        name: "Rahul",
        isHost: false,
        isAdmin: true,
        isMuted: false,
        isOnSeat: true,
      ),
      MemberModel(
        id: "3",
        name: "Priya",
        isHost: false,
        isAdmin: false,
        isMuted: false,
        isOnSeat: false,
      ),
    ]);
  }

  void loadMessages() {

    messages.assignAll([

      RoomMessageModel(
        senderName: "System",
        message: "Welcome To ARVIND PARTY",
        type: "system",
      ),

      RoomMessageModel(
        senderName: "Rahul",
        message: "Hello Everyone",
        type: "chat",
      ),

      RoomMessageModel(
        senderName: "Priya",
        message: "Joined Room",
        type: "join",
      ),

    ]);
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    messages.add(

      RoomMessageModel(
        senderName: "Me",
        message: text,
        type: "chat",
      ),

    );
  }

  void loadGifts() {
    gifts.assignAll([
      GiftModel(
        id: "1",
        name: "Rose",
        price: 10,
        image: "",
      ),
      GiftModel(
        id: "2",
        name: "Cake",
        price: 50,
        image: "",
      ),
      GiftModel(
        id: "3",
        name: "Car",
        price: 500,
        image: "",
      ),
      GiftModel(
        id: "4",
        name: "Castle",
        price: 2000,
        image: "",
      ),
    ]);
  }

  void sendGift(GiftModel gift) {
    if (myCoins.value < gift.price) {
      Get.snackbar(
        "Failed",
        "Not Enough Coins",
      );
      return;
    }

    myCoins.value -= gift.price;

    addGiftMessage(gift);
  }

  void addGiftMessage(GiftModel gift) {
    messages.add(
      RoomMessageModel(
        senderName: "Me",
        message: "Sent ${gift.name}",
        type: "gift",
      ),
    );
  }
}