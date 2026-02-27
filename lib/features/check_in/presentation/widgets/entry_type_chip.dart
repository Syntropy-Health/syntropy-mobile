import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/health_journal_entry.dart';

class EntryTypeChip extends StatelessWidget {
  const EntryTypeChip({
    super.key,
    required this.entryType,
    required this.onTap,
  });

  final EntryType entryType;
  final VoidCallback onTap;

  IconData get _icon => switch (entryType) {
        EntryType.meal => Icons.restaurant,
        EntryType.supplement => Icons.medication,
        EntryType.symptom => Icons.warning_amber,
        EntryType.exercise => Icons.fitness_center,
        EntryType.sleep => Icons.bedtime,
        EntryType.mood => Icons.mood,
        EntryType.note => Icons.note,
      };

  Color get _color => switch (entryType) {
        EntryType.meal => AppColors.nutrition,
        EntryType.supplement => AppColors.supplements,
        EntryType.symptom => AppColors.error,
        EntryType.exercise => AppColors.exercise,
        EntryType.sleep => AppColors.sleep,
        EntryType.mood => AppColors.mental,
        EntryType.note => AppColors.textSecondary,
      };

  String get _label => switch (entryType) {
        EntryType.meal => 'Meal',
        EntryType.supplement => 'Supplement',
        EntryType.symptom => 'Symptom',
        EntryType.exercise => 'Exercise',
        EntryType.sleep => 'Sleep',
        EntryType.mood => 'Mood',
        EntryType.note => 'Note',
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _icon,
                  color: _color,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                _label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: _color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
