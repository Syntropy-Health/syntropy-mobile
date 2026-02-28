import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../data/models/health_journal_entry.dart';
import '../../../../data/repositories/health_journal_repository.dart';
import '../../../voice_notes/domain/audio_recorder_service.dart';
import '../../../voice_notes/presentation/providers/voice_notes_provider.dart';

// Today's entries provider
final todayEntriesProvider = FutureProvider.autoDispose
    .family<List<HealthJournalEntry>, String>((ref, userId) async {
  final repository = ref.watch(healthJournalRepositoryProvider);
  if (repository == null) return [];

  final result = await repository.getTodayEntries(userId: userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (entries) => entries,
  );
});

// Check-in Controller
class CheckInController extends StateNotifier<AsyncValue<List<HealthJournalEntry>>> {
  CheckInController({
    required this.repository,
    required this.audioRecorder,
    required this.userId,
  }) : super(const AsyncValue.loading()) {
    loadTodayEntries();
  }

  final HealthJournalRepository repository;
  final AudioRecorderService audioRecorder;
  final String userId;

  Future<void> loadTodayEntries() async {
    state = const AsyncValue.loading();
    final result = await repository.getTodayEntries(userId: userId);
    state = result.fold(
      (failure) => AsyncValue.error(failure.message ?? 'Unknown error', StackTrace.current),
      (entries) => AsyncValue.data(entries),
    );
  }

  Future<String?> startRecording() async {
    return audioRecorder.startRecording();
  }

  Future<RecordingResult?> stopRecording() async {
    return audioRecorder.stopRecording();
  }

  Future<HealthJournalEntry?> createEntry({
    required EntryType entryType,
    required String content,
    String? transcription,
    String? audioPath,
  }) async {
    final result = await repository.createEntry(
      userId: userId,
      entryType: entryType,
      content: content,
      transcription: transcription,
      audioPath: audioPath,
    );

    return result.fold(
      (failure) => null,
      (entry) {
        // Refresh today's entries after creating a new one
        loadTodayEntries();
        return entry;
      },
    );
  }

  Future<List<HealthJournalEntry>> createBatchEntries({
    required List<({EntryType entryType, String content})> entries,
    String? transcription,
    String? audioPath,
  }) async {
    final created = <HealthJournalEntry>[];

    for (final entry in entries) {
      final result = await repository.createEntry(
        userId: userId,
        entryType: entry.entryType,
        content: entry.content,
        transcription: transcription,
        audioPath: audioPath,
      );

      result.fold(
        (failure) => null,
        (e) => created.add(e),
      );
    }

    // Refresh today's entries after batch create
    await loadTodayEntries();
    return created;
  }
}

final checkInControllerProvider = StateNotifierProvider.autoDispose
    .family<CheckInController, AsyncValue<List<HealthJournalEntry>>, String>(
  (ref, userId) {
    final repository = ref.watch(healthJournalRepositoryProvider);
    if (repository == null) {
      // Return a controller that will show empty state on web
      return CheckInController(
        repository: HealthJournalRepository(
          databaseHelper: ref.watch(databaseHelperProvider)!,
          supabaseClient: ref.watch(supabaseClientProvider),
        ),
        audioRecorder: ref.watch(audioRecorderServiceProvider),
        userId: userId,
      );
    }
    return CheckInController(
      repository: repository,
      audioRecorder: ref.watch(audioRecorderServiceProvider),
      userId: userId,
    );
  },
);
