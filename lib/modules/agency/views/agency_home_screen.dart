import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/agency_controller.dart';
import 'agency_members_screen.dart';
import 'agency_salary_screen.dart';
import 'agency_events_screen.dart';
import 'agency_ranking_screen.dart';
import 'agency_analytics_screen.dart';
import 'agency_settings_screen.dart';

class AgencyHomeScreen extends StatelessWidget {
  const AgencyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject and instantiate the central data coordinate module
    final AgencyController controller = Get.put(AgencyController());

    return Scaffold(
      backgroundColor: const Color(0xff0F0E17),
      body: Obx(() {
        final agency = controller.currentAgency.value;
        if (controller.isLoading.value && agency == null) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xffFF8906)));
        }
        if (agency == null) {
          return const Center(
            child: Text("No operational corporate agency node linked.",
                style: TextStyle(color: Colors.white24, fontSize: 13)),
          );
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Corporate Identity Banner Frame Layout
            SliverAppBar(
              expandedHeight: 170,
              pinned: true,
              backgroundColor: const Color(0xff15141F),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    color: Colors.white, size: 18),
                onPressed: () => Get.back(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
                title: Text(
                  agency.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(agency.banner, fit: BoxFit.cover),
                    Container(
                        color: Colors
                            .black45), // Transparent matte protection over graphics textures
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon:
                      const Icon(Icons.analytics_outlined, color: Colors.cyan),
                  onPressed: () => Get.to(() => const AgencyAnalyticsScreen()),
                )
              ],
            ),

            // 2. Control Matrix Workspace Grid Node Layouts
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Financial Metric Snapshot Header Row
                    _buildFinancialLedgerHeader(agency),
                    const SizedBox(height: 16),

                    const Text(
                      "Institutional Operations Management Deck",
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),

                    // Functional Navigation Action Grids
                    _buildCorporateGridMenu(),
                    const SizedBox(height: 20),

                    // Compliance Info Footnote Card Ticker
                    _buildComplianceTermsNotice(agency),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFinancialLedgerHeader(dynamic agency) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff15141F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.cyan.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(agency.logo),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.cyan,
                          borderRadius: BorderRadius.circular(4)),
                      child: Text("LEVEL ${agency.level}",
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 8,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Text("👥 Hosts Active: ${agency.totalHosts}",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                          text: "Monthly Volume: ",
                          style:
                              TextStyle(color: Colors.white38, fontSize: 11)),
                      TextSpan(
                        text:
                            "\$${agency.monthlyRevenue.toStringAsFixed(2)} USD",
                        style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorporateGridMenu() {
    final List<Map<String, dynamic>> operationalNodes = [
      {
        "title": "Hosts Roster",
        "sub": "Track live activity",
        "icon": Icons.assignment_ind_outlined,
        "color": Colors.amber,
        "target": () => const AgencyMembersScreen()
      },
      {
        "title": "Salary Core",
        "sub": "Settlement ledgers",
        "icon": Icons.account_balance_wallet_outlined,
        "color": Colors.greenAccent,
        "target": () => const AgencySalaryScreen()
      },
      {
        "title": "Talent Events",
        "sub": "Recruitment clash",
        "icon": Icons.festival_outlined,
        "color": Colors.purpleAccent,
        "target": () => const AgencyEventsScreen()
      },
      {
        "title": "Global Standings",
        "sub": "Agency leaderboards",
        "icon": Icons.star_border_purple500_rounded,
        "color": Colors.cyan,
        "target": () => const AgencyRankingScreen()
      },
      {
        "title": "Settings Panel",
        "sub": "Contract parameters",
        "icon": Icons.settings_applications_outlined,
        "color": Colors.white60,
        "target": () => const AgencySettingsScreen()
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.5,
      ),
      itemCount: operationalNodes.length,
      itemBuilder: (context, index) {
        final item = operationalNodes[index];
        return InkWell(
          onTap: () => Get.to(item['target']),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xff15141F),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item['icon'], color: item['color'], size: 22),
                const SizedBox(height: 8),
                Text(item['title'],
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(item['sub'],
                    style: const TextStyle(color: Colors.white38, fontSize: 9)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComplianceTermsNotice(dynamic agency) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xff1A1924),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.gavel_outlined, color: Colors.amber, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Settlement & Compliance Terms",
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(agency.paymentTerms,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 10, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
