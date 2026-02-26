import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../data/datasources/remote/transcription_service.dart';
import '../../../../data/models/voice_note.dart';
import '../../../../data/repositories/voice_note_repository.dart';
import '../../domain/audio_recorder_service.dart';

// Audio Recorder Service Provider
final audioRecorderServiceProvider = Provider.autoDispose<AudioRecorderService>(
  (ref) {
    final service = AudioRecorderService();
    ref.onDispose(() => service.dispose());
    return service;
  },
);

// Transcription Service Provider
final transcriptionServiceProvider = Provider<TranscriptionService>((ref) {
  return TranscriptionService();
});

// Voice Note Repository Provider (nullable on web)
final voiceNoteRepositoryProvider = Provider<VoiceNoteRepository?>((ref) {
  final db = ref.watch(databaseHelperProvider);
  if (db == null) return null; // Not available on web
  return VoiceNoteRepository(
    databaseHelper: db,
    transcriptionService: ref.watch(transcriptionServiceProvider),
  );
});

// Voice Notes List Provider
final voiceNotesProvider = FutureProvider.autoDispose
    .family<List<VoiceNote>, String>((ref, userId) async {
  final repository = ref.watch(voiceNoteRepositoryProvider);
  if (repository == null) return []; // Return empty on web
  final result = await repository.getVoiceNotes(userId: userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (notes) => notes,
  );
});

// Recording State Provider
final recordingStateProvider = StateProvider<RecordingState>((ref) {
  return RecordingState.idle;
});

// Current Recording Duration Provider
final recordingDurationProvider = StateProvider<Duration>((ref) {
  return Duration.zero;
});

// Voice Notes Controller
class VoiceNotesController extends StateNotifier<AsyncValue<List<VoiceNote>>> {
  VoiceNotesController({
    required this.repository,
    required this.audioRecorder,
    required this.userId,
  }) : super(const AsyncValue.loading()) {
    loadVoiceNotes();
  }

  final VoiceNoteRepository repository;
  final AudioRecorderService audioRecorder;
  final String userId;

  Future<void> loadVoiceNotes() async {
    state = const AsyncValue.loading();
    final result = await repository.getVoiceNotes(userId: userId);
    state = result.fold(
      (failure) => AsyncValue.error(failure.message ?? 'Unknown error', StackTrace.current),
      (notes) => AsyncValue.data(notes),
    );
  }

  Future<VoiceNote?> startRecording() async {
    final path = await audioRecorder.startRecording();
    if (path == null) return null;

    final result = await repository.createVoiceNote(
      userId: userId,
      audioPath: path,
      duration: Duration.zero,
    );

    return result.fold(
      (failure) => null,
      (note) => note,
    );
  }

  Future<VoiceNote?> stopRecording(VoiceNote note) async {
    final recordingResult = await audioRecorder.stopRecording();
    if (recordingResult == null) return null;

    // Update with actual duration
    final updatedNote = note.copyWith(duration: recordingResult.duration);

    // Start transcription
    final transcriptionResult = await repository.transcribeVoiceNote(updatedNote);

    await loadVoiceNotes();

    return transcriptionResult.fold(
      (failure) => updatedNote,
      (transcribed) => transcribed,
    );
  }

  Future<void> deleteVoiceNote(String id) async {
    await repository.deleteVoiceNote(id);
    await loadVoiceNotes();
  }

  Future<void> retryTranscription(VoiceNote note) async {
    await repository.transcribeVoiceNote(note);
    await loadVoiceNotes();
  }
}

final voiceNotesControllerProvider = StateNotifierProvider.autoDispose
    .family<VoiceNotesController, AsyncValue<List<VoiceNote>>, String>(
  (ref, userId) {
    final repository = ref.watch(voiceNoteRepositoryProvider);
    // Create repository with null db for web (gracefully handles it)
    final repo = repository ?? VoiceNoteRepository(
      databaseHelper: null,
      transcriptionService: ref.watch(transcriptionServiceProvider),
    );
    return VoiceNotesController(
      repository: repo,
      audioRecorder: ref.watch(audioRecorderServiceProvider),
      userId: userId,
    );
  },
);
