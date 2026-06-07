import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../shared/models/frame_model.dart';

class FrameController extends GetxController {
  var isLoading = true.obs;
  var frames = <FrameModel>[].obs;
  
  final String baseUrl = 'http://10.0.2.2:5000/api/shop';
  String token = ''; // Get from AuthController

  @override
  void onInit() {
    super.onInit();
    fetchFrames();
  }

  Future<void> fetchFrames() async {
    try {
      isLoading(true);
      final response = await http.get(Uri.parse('$baseUrl/frames'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          var list = data['frames'] as List;
          frames.value = list.map((e) => FrameModel.fromJson(e)).toList();
        }
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> buyFrame(String frameId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/buy-frame'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: json.encode({'frameId': frameId}),
    );
    final data = json.decode(response.body);
    if (data['success']) Get.snackbar('Success', 'Frame equipped!');
    else Get.snackbar('Failed', data['message'] ?? 'Not enough coins');
  }
}