import 'package:get/get.dart';
import '../models/agency_salary_model.dart';

class AgencySalaryController extends GetxController {
  final automatedSalariesList = <AgencySalaryModel>[].obs;
  final activeBillingCycle = "2026_MID_YEAR_CYCLE".obs;
  final isCalculating = false.obs;

  @override
  void onInit() {
    super.onInit();
    compileBillingCalculations();
  }

  void compileBillingCalculations() {
    // Mimicking local dynamic processing matrix engine allocations
    automatedSalariesList.assignAll([
      const AgencySalaryModel(
        hostId: "host_01",
        hostName: "Sonia Sharma",
        coinsEarned: 450000,
        rawGiftRevenueUSD: 4500.00,
        validBroadcastingHours: 44.5,
        targetAchieved: true,
        calculatedBonusUSD: 500.00,
        finalNetSalaryUSD:
            2750.00, // 50% Share Split base rule + Bonus variables
        status: SettlementStatus.approved,
        billingCycleId: "2026_MID_YEAR_CYCLE",
      ),
      const AgencySalaryModel(
        hostId: "host_02",
        hostName: "Rohan Kapoor",
        coinsEarned: 120000,
        rawGiftRevenueUSD: 1200.00,
        validBroadcastingHours: 18.2,
        targetAchieved: false,
        calculatedBonusUSD: 0.00,
        finalNetSalaryUSD:
            600.00, // Flat 50% split base without performance premium
        status: SettlementStatus.calculated,
        billingCycleId: "2026_MID_YEAR_CYCLE",
      ),
    ]);
  }

  Future<void> lockingSettlementsEscrow() async {
    isCalculating.value = true;
    await Future.delayed(const Duration(milliseconds: 900));
    Get.snackbar("Finance Core",
        "All approved calculations pushed to Wallet clearings ledger streams.");
    isCalculating.value = false;
  }
}
