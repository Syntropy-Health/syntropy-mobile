import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({
    super.key,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.status,
  });

  final String type;
  final String title;
  final String subtitle;
  final DateTime time;
  final String status;

  IconData get _icon {
    switch (type) {
      case 'voice_note':
        return Icons.mic;
      case 'recommendation':
        return Icons.lightbulb;
      case 'sync':
        return Icons.sync;
      case 'meal':
        return Icons.restaurant;
      case 'supplement':
        return Icons.medication;
      default:
        return Icons.info;
    }
  }

  Color get _color {
    switch (type) {
      case 'voice_note':
        return AppColors.primary;
      case 'recommendation':
        return AppColors.warning;
      case 'sync':
        return AppColors.info;
      case 'meal':
        return AppColors.nutrition;
      case 'supplement':
        return AppColors.supplements;
      default:
        return AppColors.secondary;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(_icon, color: _color, size: 20),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTime(time),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            ),
            const SizedBox(height: 2),
            if (status == 'new')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'NEW',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              )
            else if (status == 'completed')
              Icon(
                Icons.check_circle,
                size: 14,
                color: AppColors.success,
              ),
          ],
        ),
      ),
    );
  }
}
