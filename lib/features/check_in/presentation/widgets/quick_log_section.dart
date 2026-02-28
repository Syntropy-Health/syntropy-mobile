import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/quick_log_preset.dart';
import '../providers/check_in_provider.dart';
import '../providers/quick_log_provider.dart';
import 'quick_log_preset_card.dart';

class QuickLogSection extends ConsumerWidget {
  const QuickLogSection({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presetsAsync = ref.watch(quickLogControllerProvider(userId));
    final quickLogController =
        ref.read(quickLogControllerProvider(userId).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick Log',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton.icon(
                onPressed: () => quickLogController.generateFromHistory(),
                icon: const Icon(Icons.auto_awesome, size: 16),
                label: const Text('Suggest'),
              ),
            ],
          ),
        ),
        presetsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error loading presets: $e'),
          ),
          data: (presets) {
            if (presets.isEmpty) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Tap "Suggest" to create presets from your history, or add your own.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: presets.map((preset) {
                  return QuickLogPresetCard(
                    preset: preset,
                    onTap: () {
                      final checkInCtrl = ref.read(
                        checkInControllerProvider(userId).notifier,
                      );
                      quickLogController.tapPreset(preset, checkInCtrl);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Logged: ${preset.displayName.isNotEmpty ? preset.displayName : preset.content}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    onLongPress: () => _showPresetOptions(
                      context,
                      preset,
                      quickLogController,
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showPresetOptions(
    BuildContext context,
    QuickLogPreset preset,
    QuickLogController quickLogController,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                preset.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
              ),
              title: Text(preset.isPinned ? 'Unpin' : 'Pin to top'),
              onTap: () {
                quickLogController.togglePin(preset.id);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title:
                  const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                quickLogController.deletePreset(preset.id);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
