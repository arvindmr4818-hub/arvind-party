import 'package:get/get.dart';
import '../../auth/views/api_service.dart';
import '../models/transaction_model.dart';

class TransactionController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  var transactions = <TransactionModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      isLoading(true);
      final response = await _apiService.get('users/transactions');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['transactions'] ?? [];
        transactions.value = data.map((json) => TransactionModel.fromJson(json)).toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load transaction history');
    } finally {
      isLoading(false);
    }
  }
}