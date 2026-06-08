import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/withdrawal_admin_controller.dart';

class WithdrawalManagementView extends StatefulWidget {
  const WithdrawalManagementView({super.key});

  @override
  State<WithdrawalManagementView> createState() =>
      _WithdrawalManagementViewState();
}

class _WithdrawalManagementViewState extends State<WithdrawalManagementView> {
  late final WithdrawalAdminController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(WithdrawalAdminController());
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.redAccent;
      case 'pending':
      default:
        return Colors.orangeAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER PANEL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Withdrawal Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  // ✅ FIX 1: Pointed to real loadRequests method
                  onPressed: () => controller.loadRequests(),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text('Refresh',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15141F),
                    side: const BorderSide(color: Color(0xFFFF8906)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Review pending payouts and manage completed transactions.',
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 24),

            // DATA LEDGER TABLE
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.pendingRequests.isEmpty) {
                  return const Center(
                      child: CircularProgressIndicator(color: Color(0xFFFF8906)));
                }

                // ✅ FIX 2: Pointed to real pendingRequests variable list array stream
                if (controller.pendingRequests.isEmpty) {
                  return const Center(
                      child: Text('No pending withdrawal logs fetched.',
                          style: TextStyle(color: Colors.white54)));
                }

                return SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.black38),
                      dataRowMinHeight: 60,
                      dataRowMaxHeight: 60,
                      columns: const [
                        DataColumn(
                            label: Text('User Details',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF8906)))),
                        DataColumn(
                            label: Text('Amount',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF8906)))),
                        DataColumn(
                            label: Text('Payment Info',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF8906)))),
                        DataColumn(
                            label: Text('Status',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF8906)))),
                        DataColumn(
                            label: Text('Actions',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF8906)))),
                      ],
                      // ✅ FIX 3: Iterating directly over real pendingRequests data stream entries
                      rows: controller.pendingRequests.map((item) {
                        final id = (item['id'] ?? item['_id'] ?? '').toString();
                        final String userName = (item['userName'] ?? 'Unknown User').toString();
                        final String methodType = (item['method'] ?? 'Payout').toString();
                        final status = (item['status'] ?? 'pending').toString();
                        final isPending = status.toLowerCase() == 'pending';
                        
                        // Parse account details dictionary attributes securely
                        String detailsText = 'N/A';
                        if (item['details'] is Map) {
                          final detailsMap = item['details'] as Map;
                          if (detailsMap.containsKey('upiId')) {
                            detailsText = 'UPI: ${detailsMap['upiId']}';
                          } else if (detailsMap.containsKey('accountNumber')) {
                            detailsText = 'A/C: ${detailsMap['accountNumber']} • IFSC: ${detailsMap['ifsc'] ?? ''}';
                          } else if (detailsMap.containsKey('email')) {
                            detailsText = 'PayPal: ${detailsMap['email']}';
                          } else if (detailsMap.containsKey('phone')) {
                            detailsText = 'Phone: ${detailsMap['phone']}';
                          }
                        }

                        return DataRow(
                          cells: [
                            // 1. USER PANEL
                            DataCell(
                              Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: Colors.white10,
                                    radius: 16,
                                    child: Icon(Icons.person, size: 16, color: Colors.white38),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(userName,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            
                            // 2. TOKEN VALUE AMOUNTS
                            DataCell(
                              Text('🪙 ${item['amount'] ?? 0} Beans',
                                  style: const TextStyle(
                                      color: Colors.greenAccent,
                                      fontWeight: FontWeight.bold)),
                            ),
                            
                            // 3. PAYMENT GATEWAY CREDENTIALS DATA RENDERER
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(methodType, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                                  Text(detailsText, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                                ],
                              ),
                            ),
                            
                            // 4. MANAGEMENT LEDGER STATE STATUS
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                      color: _getStatusColor(status),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            
                            // 5. ADMINISTRATIVE MUTATION EVENTS ACTION BOX
                            DataCell(
                              isPending
                                  ? Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.check_circle, color: Colors.green),
                                          // ✅ FIX 4: Hooked to real approveRequest method pipeline logic
                                          onPressed: () => controller.approveRequest(id),
                                          tooltip: 'Approve Payout Transaction',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.cancel, color: Colors.redAccent),
                                          // ✅ FIX 5: Hooked to real rejectRequest method pipeline logic with fallback audit reason text
                                          onPressed: () => controller.rejectRequest(id, 'Admin Verification Disapproved Payout Audit'),
                                          tooltip: 'Reject & Refund Tokens Ledger',
                                        ),
                                      ],
                                    )
                                  : const Text('--', style: TextStyle(color: Colors.white54)),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
    
    