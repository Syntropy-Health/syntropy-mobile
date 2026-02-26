import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/failure.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../datasources/local/database_helper.dart';
import '../datasources/remote/transcription_service.dart';
import '../models/voice_note.dart';

class VoiceNoteRepository {
  VoiceNoteRepository({
    required this.databaseHelper,
    required this.transcriptionService,
  });

  final DatabaseHelper? databaseHelper;
  final TranscriptionService transcriptionService;
  final _uuid = const Uuid();

  Future<Result<VoiceNote>> createVoiceNote({
    required String userId,
    required String audioPath,
    required Duration duration,
  }) async {
    try {
      final voiceNote = VoiceNote(
        id: _uuid.v4(),
        userId: userId,
        audioPath: audioPath,
        duration: duration,
        transcriptionStatus: TranscriptionStatus.pending,
        createdAt: DateTime.now(),
      );

      await databaseHelper?.insert('voice_notes', voiceNote.toDbMap());

      AppLogger.info('Created voice note: ${voiceNote.id}', 'VoiceNoteRepo');
      return Right(voiceNote);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create voice note', 'VoiceNoteRepo', e, stackTrace);
      return Left(CacheFailure(message: 'Failed to create voice note: $e'));
    }
  }

  Future<Result<VoiceNote>> transcribeVoiceNote(VoiceNote voiceNote) async {
    try {
      // Update status to processing
      var updated = voiceNote.copyWith(
        transcriptionStatus: TranscriptionStatus.processing,
      );
      await _updateVoiceNote(updated);

      // Call transcription service
      final result = await transcriptionService.transcribeAudio(
        voiceNote.audioPath,
      );

      return result.fold(
        (failure) async {
          // Update with error
          updated = voiceNote.copyWith(
            transcriptionStatus: TranscriptionStatus.failed,
            errorMessage: failure.message,
          );
          await _updateVoiceNote(updated);
          return Left(failure);
        },
        (transcription) async {
          // Update with transcription
          updated = voiceNote.copyWith(
            transcription: transcription,
            transcriptionStatus: TranscriptionStatus.completed,
            transcribedAt: DateTime.now(),
          );
          await _updateVoiceNote(updated);
          AppLogger.info(
            'Transcribed voice note: ${voiceNote.id}',
            'VoiceNoteRepo',
          );
          return Right(updated);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to transcribe', 'VoiceNoteRepo', e, stackTrace);
      return Left(TranscriptionFailure(message: 'Failed to transcribe: $e'));
    }
  }

  Future<void> _updateVoiceNote(VoiceNote voiceNote) async {
    await databaseHelper?.update(
      'voice_notes',
      voiceNote.toDbMap(),
      where: 'id = ?',
      whereArgs: [voiceNote.id],
    );
  }

  Future<Result<List<VoiceNote>>> getVoiceNotes({
    required String userId,
    int? limit,
    int? offset,
  }) async {
    if (databaseHelper == null) return const Right([]);
    try {
      final results = await databaseHelper!.query(
        'voice_notes',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
        limit: limit,
        offset: offset,
      );

      final notes = results
          .map((map) => VoiceNoteExtension.fromDbMap(map))
          .toList();

      return Right(notes);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get voice notes', 'VoiceNoteRepo', e, stackTrace);
      return Left(CacheFailure(message: 'Failed to get voice notes: $e'));
    }
  }

  Future<Result<VoiceNote?>> getVoiceNote(String id) async {
    if (databaseHelper == null) return const Right(null);
    try {
      final results = await databaseHelper!.query(
        'voice_notes',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (results.isEmpty) {
        return const Right(null);
      }

      return Right(VoiceNoteExtension.fromDbMap(results.first));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get voice note', 'VoiceNoteRepo', e, stackTrace);
      return Left(CacheFailure(message: 'Failed to get voice note: $e'));
    }
  }

  Future<Result<void>> deleteVoiceNote(String id) async {
    if (databaseHelper == null) return const Right(null);
    try {
      await databaseHelper!.delete(
        'voice_notes',
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete voice note', 'VoiceNoteRepo', e, stackTrace);
      return Left(CacheFailure(message: 'Failed to delete voice note: $e'));
    }
  }

  Future<Result<List<VoiceNote>>> getPendingTranscriptions() async {
    if (databaseHelper == null) return const Right([]);
    try {
      final results = await databaseHelper!.query(
        'voice_notes',
        where: 'transcription_status = ?',
        whereArgs: [TranscriptionStatus.pending.name],
        orderBy: 'created_at ASC',
      );

      final notes = results
          .map((map) => VoiceNoteExtension.fromDbMap(map))
          .toList();

      return Right(notes);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get pending transcriptions',
        'VoiceNoteRepo',
        e,
        stackTrace,
      );
      return Left(CacheFailure(message: 'Failed to get pending: $e'));
    }
  }
}
