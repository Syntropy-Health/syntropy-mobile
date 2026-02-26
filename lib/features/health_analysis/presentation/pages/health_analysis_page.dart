import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/health_recommendation.dart';
import '../providers/health_analysis_provider.dart';
import '../widgets/recommendation_card.dart';

class HealthAnalysisPage extends ConsumerWidget {
  const HealthAnalysisPage({super.key});

  static const String _userId = 'demo_user';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisState = ref.watch(healthAnalysisControllerProvider(_userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Show history
            },
            tooltip: 'History',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Health Score Summary
          SliverToBoxAdapter(
            child: Container(
              margin: AppSpacing.pagePadding,
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppSpacing.borderRadiusLg,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Health Score',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '85/100',
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.trending_up,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      _buildScoreItem(context, 'Nutrition', '90%'),
                      _buildScoreItem(context, 'Sleep', '75%'),
                      _buildScoreItem(context, 'Activity', '80%'),
                      _buildScoreItem(context, 'Stress', '85%'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recommendations',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: See all recommendations
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),
          ),

          // Recommendations List
          analysisState.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (error, stack) => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text('Failed to load recommendations'),
                    ],
                  ),
                ),
              ),
            ),
            data: (recommendations) {
              if (recommendations.isEmpty) {
                return SliverToBoxAdapter(
                  child: _buildEmptyRecommendations(context),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return RecommendationCard(
                        recommendation: recommendations[index],
                        onDismiss: () {
                          ref
                              .read(healthAnalysisControllerProvider(_userId)
                                  .notifier)
                              .dismissRecommendation(recommendations[index].id);
                        },
                        onAction: () {
                          ref
                              .read(healthAnalysisControllerProvider(_userId)
                                  .notifier)
                              .markAsActioned(recommendations[index].id);
                        },
                      );
                    },
                    childCount: recommendations.length,
                  ),
                ),
              );
            },
          ),

          // Demo Recommendations (since we don't have real data yet)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildDemoRecommendation(
                  context,
                  title: 'Increase Magnesium Intake',
                  description:
                      'Based on your recent sleep patterns, consider adding magnesium-rich foods or supplements.',
                  type: RecommendationType.supplement,
                  priority: Priority.high,
                ),
                _buildDemoRecommendation(
                  context,
                  title: 'Morning Sunlight Exposure',
                  description:
                      'Get 10-15 minutes of morning sunlight to improve circadian rhythm and vitamin D levels.',
                  type: RecommendationType.lifestyle,
                  priority: Priority.medium,
                ),
                _buildDemoRecommendation(
                  context,
                  title: 'Add More Omega-3s',
                  description:
                      'Your recent entries suggest inflammation. Consider fatty fish or fish oil supplements.',
                  type: RecommendationType.nutrition,
                  priority: Priority.medium,
                ),
              ]),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(BuildContext context, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRecommendations(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No recommendations yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Record voice notes about your health to receive personalized insights',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoRecommendation(
    BuildContext context, {
    required String title,
    required String description,
    required RecommendationType type,
    required Priority priority,
  }) {
    return RecommendationCard(
      recommendation: HealthRecommendation(
        id: title.hashCode.toString(),
        userId: _userId,
        type: type,
        title: title,
        description: description,
        priority: priority,
        createdAt: DateTime.now(),
      ),
      onDismiss: () {},
      onAction: () {},
    );
  }
}
