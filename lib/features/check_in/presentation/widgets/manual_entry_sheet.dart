import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/health_journal_entry.dart';
import '../entry_type_ui.dart';

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

  @override
  Widget build(BuildContext context) {
    final color = widget.entryType.color;

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
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.entryType.icon, color: color, size: 24),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Log ${widget.entryType.label}',
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
              hintText: widget.entryType.hintText,
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
