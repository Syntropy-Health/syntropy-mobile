import 'package:flutter/material.dart';

import '../../../../data/models/health_journal_entry.dart';
import '../../domain/quick_log_preset.dart';

class QuickLogPresetCard extends StatelessWidget {
  const QuickLogPresetCard({
    super.key,
    required this.preset,
    required this.onTap,
    required this.onLongPress,
  });

  final QuickLogPreset preset;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  String _entryTypeEmoji(EntryType type) {
    switch (type) {
      case EntryType.supplement:
        return '\u{1F48A}'; // pill
      case EntryType.meal:
        return '\u{1F957}'; // salad
      case EntryType.symptom:
        return '\u{1F62B}'; // tired face
      case EntryType.exercise:
        return '\u{1F4AA}'; // flexed bicep
      case EntryType.sleep:
        return '\u{1F634}'; // sleeping face
      case EntryType.mood:
        return '\u{1F60A}'; // smiling face
      case EntryType.note:
        return '\u{1F4DD}'; // memo
    }
  }

  Color _entryTypeColor(EntryType type) {
    switch (type) {
      case EntryType.supplement:
        return Colors.blue.shade100;
      case EntryType.meal:
        return Colors.green.shade100;
      case EntryType.symptom:
        return Colors.red.shade100;
      case EntryType.exercise:
        return Colors.orange.shade100;
      case EntryType.sleep:
        return Colors.indigo.shade100;
      case EntryType.mood:
        return Colors.amber.shade100;
      case EntryType.note:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _entryTypeColor(preset.entryType),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: preset.isPinned
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _entryTypeEmoji(preset.entryType),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 4),
                if (preset.isPinned)
                  Icon(
                    Icons.push_pin,
                    size: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              preset.displayName.isNotEmpty
                  ? preset.displayName
                  : preset.content,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
