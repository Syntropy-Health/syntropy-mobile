import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../data/models/health_journal_entry.dart';
import '../../data/quick_log_preset_repository.dart';
import '../../domain/quick_log_preset.dart';
import 'check_in_provider.dart';

// Repository provider
final quickLogPresetRepositoryProvider =
    Provider<QuickLogPresetRepository?>((ref) {
  final db = ref.watch(databaseHelperProvider);
  if (db == null) return null;
  return QuickLogPresetRepository(db);
});

// Presets list provider
final quickLogPresetsProvider = FutureProvider.autoDispose
    .family<List<QuickLogPreset>, String>((ref, userId) async {
  final repo = ref.watch(quickLogPresetRepositoryProvider);
  if (repo == null) return [];
  final result = await repo.getPresets(userId: userId);
  return result.fold(
    (failure) => <QuickLogPreset>[],
    (presets) => presets,
  );
});

// Controller for preset actions
class QuickLogController
    extends StateNotifier<AsyncValue<List<QuickLogPreset>>> {
  QuickLogController({
    required this.repository,
    required this.userId,
  }) : super(const AsyncValue.loading()) {
    loadPresets();
  }

  final QuickLogPresetRepository repository;
  final String userId;

  Future<void> loadPresets() async {
    state = const AsyncValue.loading();
    final result = await repository.getPresets(userId: userId);
    state = result.fold(
      (f) => AsyncValue.error(
        f.message ?? 'Failed to load presets',
        StackTrace.current,
      ),
      (presets) => AsyncValue.data(presets),
    );
  }

  Future<void> tapPreset(
    QuickLogPreset preset,
    CheckInController checkInController,
  ) async {
    // Create entry via check-in controller
    await checkInController.createEntry(
      entryType: preset.entryType,
      content: preset.content,
    );
    // Increment use count
    await repository.incrementUseCount(preset.id);
    await loadPresets();
  }

  Future<void> addPreset({
    required EntryType entryType,
    required String content,
    String? displayName,
  }) async {
    await repository.createPreset(
      userId: userId,
      entryType: entryType,
      content: content,
      displayName: displayName,
    );
    await loadPresets();
  }

  Future<void> togglePin(String presetId) async {
    await repository.togglePin(presetId);
    await loadPresets();
  }

  Future<void> deletePreset(String presetId) async {
    await repository.deletePreset(presetId);
    await loadPresets();
  }

  Future<void> generateFromHistory() async {
    await repository.generatePresetsFromHistory(userId: userId);
    await loadPresets();
  }
}

final quickLogControllerProvider = StateNotifierProvider.autoDispose
    .family<QuickLogController, AsyncValue<List<QuickLogPreset>>, String>(
  (ref, userId) {
    final repo = ref.watch(quickLogPresetRepositoryProvider);
    if (repo == null) {
      return QuickLogController(
        repository: QuickLogPresetRepository(
          ref.watch(databaseHelperProvider)!,
        ),
        userId: userId,
      );
    }
    return QuickLogController(repository: repo, userId: userId);
  },
);
