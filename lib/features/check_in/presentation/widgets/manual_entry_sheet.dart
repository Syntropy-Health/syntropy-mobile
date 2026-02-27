import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/health_journal_entry.dart';

class ManualEntrySheet extends StatefulWidget {
  const ManualEntrySheet({
    super.key,
    required this.entryType,
  });

  final EntryType entryType;

  /// Shows the manual entry sheet and returns the entered text on save,
  /// or null if cancelled.
  static Future<String?> show(
    BuildContext context, {
    required EntryType entryType,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (context) => ManualEntrySheet(entryType: entryType),
    );
  }

  @override
  State<ManualEntrySheet> createState() => _ManualEntrySheetState();
}

class _ManualEntrySheetState extends State<ManualEntrySheet> {
  final _textController = TextEditingController();
  bool _canSave = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      final canSave = _textController.text.trim().isNotEmpty;
      if (canSave != _canSave) {
        setState(() => _canSave = canSave);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  IconData get _icon => switch (widget.entryType) {
        EntryType.meal => Icons.restaurant,
        EntryType.supplement => Icons.medication,
        EntryType.symptom => Icons.warning_amber,
        EntryType.exercise => Icons.fitness_center,
        EntryType.sleep => Icons.bedtime,
        EntryType.mood => Icons.mood,
        EntryType.note => Icons.note,
      };

  Color get _color => switch (widget.entryType) {
        EntryType.meal => AppColors.nutrition,
        EntryType.supplement => AppColors.supplements,
        EntryType.symptom => AppColors.error,
        EntryType.exercise => AppColors.exercise,
        EntryType.sleep => AppColors.sleep,
        EntryType.mood => AppColors.mental,
        EntryType.note => AppColors.textSecondary,
      };

  String get _label => switch (widget.entryType) {
        EntryType.meal => 'Meal',
        EntryType.supplement => 'Supplement',
        EntryType.symptom => 'Symptom',
        EntryType.exercise => 'Exercise',
        EntryType.sleep => 'Sleep',
        EntryType.mood => 'Mood',
        EntryType.note => 'Note',
      };

  String get _hintText => switch (widget.entryType) {
        EntryType.meal => 'What did you eat? e.g., grilled chicken with rice',
        EntryType.supplement => 'What did you take? e.g., creatine 5g',
        EntryType.symptom => 'What are you feeling? e.g., mild headache',
        EntryType.exercise => 'What exercise did you do? e.g., 30 min run',
        EntryType.sleep => 'How did you sleep? e.g., 7 hours, woke up rested',
        EntryType.mood => 'How are you feeling? e.g., calm and focused',
        EntryType.note => 'What would you like to note?',
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header with type icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, color: _color, size: 24),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Log $_label',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Text input
          TextField(
            controller: _textController,
            autofocus: true,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: _hintText,
              border: OutlineInputBorder(
                borderRadius: AppSpacing.borderRadiusMd,
              ),
              filled: true,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: _canSave
                      ? () => Navigator.pop(context, _textController.text.trim())
                      : null,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
