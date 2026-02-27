import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/health_journal_entry.dart';
import '../entry_type_ui.dart';

class EntryTypeChip extends StatelessWidget {
  const EntryTypeChip({
    super.key,
    required this.entryType,
    required this.onTap,
  });

  final EntryType entryType;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = entryType.color;

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
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  entryType.icon,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                entryType.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: color,
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
