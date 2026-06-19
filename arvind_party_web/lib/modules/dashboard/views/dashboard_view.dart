import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../../core/theme/web_theme.dart';
import '../../../shared/widgets/admin_scaffold.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Dashboard',
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Welcome Header ──────────────────────────
              Text(
                'Welcome to Arvind Party Admin',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Here\'s what\'s happening with your platform today.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              // ─── Stats Grid ───────────────────────────────
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 900
                      ? 4
                      : constraints.maxWidth > 600
                          ? 2
                          : 1;
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.6,
                    children: [
                      _StatCard(
                        icon: Icons.people_alt,
                        label: 'Total App Users',
                        value: controller.totalUsers.value.toString(),
                        color: const Color(0xFF64B5F6),
                        iconBgColor: const Color(0xFF64B5F6).withValues(alpha: 0.1),
                      ),
                      _StatCard(
                        icon: Icons.meeting_room,
                        label: 'Active Live Rooms',
                        value: controller.activeRooms.value.toString(),
                        color: const Color(0xFF4CAF50),
                        iconBgColor: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      ),
                      _StatCard(
                        icon: Icons.monetization_on,
                        label: 'Total Revenue',
                        value: '₹${controller.totalRevenue.value.toStringAsFixed(0)}',
                        color: const Color(0xFFFFB300),
                        iconBgColor: const Color(0xFFFFB300).withValues(alpha: 0.1),
                      ),
                      _StatCard(
                        icon: Icons.token,
                        label: 'Coins Generated',
                        value: controller.totalCoinsGenerated.value.toString(),
                        color: WebTheme.primaryOrange,
                        iconBgColor: WebTheme.primaryOrange.withValues(alpha: 0.1),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // ─── Recent Activity Section ──────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _ActionChip(
                            icon: Icons.person_add,
                            label: 'Manage Users',
                            onTap: () => Get.toNamed('/users'),
                          ),
                          _ActionChip(
                            icon: Icons.meeting_room,
                            label: 'Manage Rooms',
                            onTap: () => Get.toNamed('/rooms'),
                          ),
                          _ActionChip(
                            icon: Icons.card_giftcard,
                            label: 'Manage Gifts',
                            onTap: () => Get.toNamed('/gifts'),
                          ),
                          _ActionChip(
                            icon: Icons.token,
                            label: 'Generate Coins',
                            onTap: () => Get.toNamed('/coin-generation'),
                          ),
                          _ActionChip(
                            icon: Icons.workspace_premium,
                            label: 'Rewards Center',
                            onTap: () => Get.toNamed('/rewards'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─── Stat Card Widget ─────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color iconBgColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  onPressed: () {},
                  color: WebTheme.textSecondary,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: WebTheme.textPrimary,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: WebTheme.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Action Chip Widget ───────────────────────────────────
class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WebTheme.elevatedDark,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: WebTheme.primaryOrange),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: WebTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}