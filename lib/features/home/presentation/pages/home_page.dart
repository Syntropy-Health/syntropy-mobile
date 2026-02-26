import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../widgets/health_summary_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/recent_activity_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good ${_getGreeting()}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  Text(
                    'Syntropy Health',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              actions: [
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () => context.go(Routes.notifications),
                    ),
                    unreadCount.when(
                      data: (count) => count > 0
                          ? Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  count > 9 ? '9+' : '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  onPressed: () => context.go(Routes.settings),
                ),
              ],
            ),

            // Health Summary
            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.pagePadding,
                child: HealthSummaryCard(
                  healthScore: 85,
                  trend: 5,
                  onTap: () => context.go(Routes.healthAnalysis),
                ),
              ),
            ),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: QuickActionButton(
                            icon: Icons.mic,
                            label: 'Voice Note',
                            color: AppColors.primary,
                            onTap: () => context.go(Routes.voiceNotes),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: QuickActionButton(
                            icon: Icons.restaurant_menu,
                            label: 'Log Meal',
                            color: AppColors.nutrition,
                            onTap: () => context.go(Routes.voiceNotes),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: QuickActionButton(
                            icon: Icons.medication,
                            label: 'Supplements',
                            color: AppColors.supplements,
                            onTap: () => context.go(Routes.catalog),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Today's Tips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Today's Tips",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TextButton(
                          onPressed: () => context.go(Routes.healthAnalysis),
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildTipCard(
                      context,
                      icon: Icons.water_drop,
                      title: 'Stay Hydrated',
                      message: 'Aim for 8 glasses of water today',
                      color: AppColors.info,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildTipCard(
                      context,
                      icon: Icons.wb_sunny,
                      title: 'Morning Sunlight',
                      message: 'Get 10 mins of sunlight for vitamin D',
                      color: AppColors.warning,
                    ),
                  ],
                ),
              ),
            ),

            // Recent Activity
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Activity',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),
            ),

            // Activity List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  RecentActivityCard(
                    type: 'voice_note',
                    title: 'Morning journal entry',
                    subtitle: 'Transcribed and analyzed',
                    time: DateTime.now().subtract(const Duration(hours: 2)),
                    status: 'completed',
                  ),
                  RecentActivityCard(
                    type: 'recommendation',
                    title: 'New recommendation',
                    subtitle: 'Increase magnesium intake',
                    time: DateTime.now().subtract(const Duration(hours: 5)),
                    status: 'new',
                  ),
                  RecentActivityCard(
                    type: 'sync',
                    title: 'Data synced',
                    subtitle: '3 entries uploaded to cloud',
                    time: DateTime.now().subtract(const Duration(days: 1)),
                    status: 'completed',
                  ),
                ]),
              ),
            ),

            // Bottom Padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _buildTipCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    required Color color,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title),
        subtitle: Text(message),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
