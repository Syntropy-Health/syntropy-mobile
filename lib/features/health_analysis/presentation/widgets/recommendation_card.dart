import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/health_recommendation.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.onDismiss,
    this.onAction,
  });

  final HealthRecommendation recommendation;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;

  Color _getTypeColor() {
    switch (recommendation.type) {
      case RecommendationType.nutrition:
        return AppColors.nutrition;
      case RecommendationType.supplement:
        return AppColors.supplements;
      case RecommendationType.lifestyle:
        return AppColors.mental;
      case RecommendationType.exercise:
        return AppColors.exercise;
      case RecommendationType.sleep:
        return AppColors.sleep;
    }
  }

  IconData _getTypeIcon() {
    switch (recommendation.type) {
      case RecommendationType.nutrition:
        return Icons.restaurant;
      case RecommendationType.supplement:
        return Icons.medication;
      case RecommendationType.lifestyle:
        return Icons.self_improvement;
      case RecommendationType.exercise:
        return Icons.fitness_center;
      case RecommendationType.sleep:
        return Icons.bedtime;
    }
  }

  String _getPriorityLabel() {
    switch (recommendation.priority) {
      case Priority.low:
        return 'Low Priority';
      case Priority.medium:
        return 'Medium Priority';
      case Priority.high:
        return 'High Priority';
      case Priority.urgent:
        return 'Urgent';
    }
  }

  Color _getPriorityColor() {
    switch (recommendation.priority) {
      case Priority.low:
        return AppColors.info;
      case Priority.medium:
        return AppColors.warning;
      case Priority.high:
        return AppColors.error;
      case Priority.urgent:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor();

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Icon(
                    _getTypeIcon(),
                    color: typeColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getPriorityColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getPriorityLabel(),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: _getPriorityColor(),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!recommendation.isActioned)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: onDismiss,
                    color: AppColors.textTertiary,
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // Description
            Text(
              recommendation.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),

            // Rationale
            if (recommendation.rationale != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        recommendation.rationale!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Actions
            if (!recommendation.isActioned) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (recommendation.suggestedProducts?.isNotEmpty ?? false)
                    TextButton.icon(
                      icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                      label: const Text('View Products'),
                      onPressed: () {
                        // TODO: Navigate to products
                      },
                    ),
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton(
                    onPressed: onAction,
                    child: const Text('Take Action'),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 16, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text(
                      'Completed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
