import 'package:flutter/material.dart';
import '../models/agency_salary_model.dart';

class SalaryCard extends StatelessWidget {
  final AgencySalaryModel salary;

  const SalaryCard({
    super.key,
    required this.salary,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = salary.status == SettlementStatus.approved
        ? Colors.greenAccent
        : salary.status == SettlementStatus.released
            ? Colors.cyan
            : Colors.amberAccent;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff15141F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                salary.hostName,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                "Coins: ${salary.coinsEarned}  |  Hours: ${salary.validBroadcastingHours}",
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4)),
                child: Text(
                  salary.status.toString().split('.').last.toUpperCase(),
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 8,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "\$${salary.finalNetSalaryUSD.toStringAsFixed(2)}",
                style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              if (salary.targetAchieved)
                const Text(
                  "Target Bonus Included",
                  style: TextStyle(
                      color: Colors.amber,
                      fontSize: 8,
                      fontWeight: FontWeight.w500),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
