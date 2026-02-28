import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/health_journal_entry.dart';
import '../../domain/entry_parser_service.dart';
import '../entry_type_ui.dart';

class ConfirmCheckInSheet extends StatefulWidget {
  const ConfirmCheckInSheet({
    super.key,
    required this.transcription,
    required this.parsedEntries,
    this.scrollController,
  });

  final String transcription;
  final List<ParsedEntry> parsedEntries;
  final ScrollController? scrollController;

  /// Shows the confirmation sheet. Returns a list of confirmed entries
  /// as (entryType, content) tuples, or null if cancelled.
  static Future<List<({EntryType entryType, String content})>?> show(
    BuildContext context, {
    required String transcription,
    required List<ParsedEntry> parsedEntries,
  }) {
    return showModalBottomSheet<List<({EntryType entryType, String content})>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ConfirmCheckInSheet(
          transcription: transcription,
          parsedEntries: parsedEntries,
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  State<ConfirmCheckInSheet> createState() => _ConfirmCheckInSheetState();
}

class _ConfirmCheckInSheetState extends State<ConfirmCheckInSheet> {
  late List<_EditableEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = widget.parsedEntries
        .map(
          (e) => _EditableEntry(
            entryType: e.entryType,
            content: e.content,
            isIncluded: true,
          ),
        )
        .toList();

    // If parser produced nothing, fall back to a single note
    if (_entries.isEmpty) {
      _entries.add(
        _EditableEntry(
          entryType: EntryType.note,
          content: widget.transcription,
          isIncluded: true,
        ),
      );
    }
  }

  void _confirm() {
    final confirmed = _entries
        .where((e) => e.isIncluded)
        .map((e) => (entryType: e.entryType, content: e.content))
        .toList();
    Navigator.pop(context, confirmed);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
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

          // Title
          Text(
            'Confirm Check-in',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Transcription display
          Container(
            width: double.infinity,
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We heard:',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '"${widget.transcription}"',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Parsed entries header
          Text(
            'Parsed entries:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Parsed entries list
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];
                final color = entry.entryType.color;

                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        entry.entryType.icon,
                        color: entry.isIncluded ? color : AppColors.textTertiary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      entry.entryType.label,
                      style: TextStyle(
                        color: entry.isIncluded
                            ? null
                            : AppColors.textTertiary,
                        decoration: entry.isIncluded
                            ? null
                            : TextDecoration.lineThrough,
                      ),
                    ),
                    subtitle: Text(
                      entry.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: entry.isIncluded
                            ? AppColors.textSecondary
                            : AppColors.textTertiary,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        entry.isIncluded ? Icons.close : Icons.undo,
                        color: entry.isIncluded
                            ? AppColors.textTertiary
                            : AppColors.primary,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _entries[index] = entry.copyWith(
                            isIncluded: !entry.isIncluded,
                          );
                        });
                      },
                    ),
                  ),
                );
              },
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
                  onPressed: _entries.any((e) => e.isIncluded) ? _confirm : null,
                  child: const Text('Confirm & Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditableEntry {
  const _EditableEntry({
    required this.entryType,
    required this.content,
    required this.isIncluded,
  });

  final EntryType entryType;
  final String content;
  final bool isIncluded;

  _EditableEntry copyWith({
    EntryType? entryType,
    String? content,
    bool? isIncluded,
  }) {
    return _EditableEntry(
      entryType: entryType ?? this.entryType,
      content: content ?? this.content,
      isIncluded: isIncluded ?? this.isIncluded,
    );
  }
}
