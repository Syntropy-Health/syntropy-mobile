import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/failure.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../datasources/local/database_helper.dart';
import '../datasources/remote/supabase_client.dart';
import '../models/health_journal_entry.dart';

class HealthJournalRepository {
  HealthJournalRepository({
    required this.databaseHelper,
    required this.supabaseClient,
  });

  final DatabaseHelper databaseHelper;
  final SupabaseClientWrapper supabaseClient;
  final _uuid = const Uuid();

  Future<Result<HealthJournalEntry>> createEntry({
    required String userId,
    required EntryType entryType,
    required String content,
    String? transcription,
    String? audioPath,
  }) async {
    try {
      final entry = HealthJournalEntry(
        id: _uuid.v4(),
        userId: userId,
        entryType: entryType,
        content: content,
        transcription: transcription,
        audioPath: audioPath,
        entryDate: DateTime.now(),
        syncStatus: SyncStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await databaseHelper.insert(
        'health_journal_entries',
        entry.toDbMap(),
      );

      AppLogger.info('Created journal entry: ${entry.id}', 'HealthJournalRepo');
      return Right(entry);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create entry', 'HealthJournalRepo', e, stackTrace);
      return Left(CacheFailure(message: 'Failed to create entry: $e'));
    }
  }

  Future<Result<List<HealthJournalEntry>>> getEntries({
    required String userId,
    EntryType? entryType,
    int? limit,
    int? offset,
  }) async {
    try {
      String? where = 'user_id = ?';
      List<Object?> whereArgs = [userId];

      if (entryType != null) {
        where = '$where AND entry_type = ?';
        whereArgs.add(entryType.name);
      }

      final results = await databaseHelper.query(
        'health_journal_entries',
        where: where,
        whereArgs: whereArgs,
        orderBy: 'created_at DESC',
        limit: limit,
        offset: offset,
      );

      final entries = results
          .map((map) => HealthJournalEntryExtension.fromDbMap(map))
          .toList();

      return Right(entries);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get entries', 'HealthJournalRepo', e, stackTrace);
      return Left(CacheFailure(message: 'Failed to get entries: $e'));
    }
  }

  Future<Result<HealthJournalEntry?>> getEntry(String id) async {
    try {
      final results = await databaseHelper.query(
        'health_journal_entries',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (results.isEmpty) {
        return const Right(null);
      }

      return Right(HealthJournalEntryExtension.fromDbMap(results.first));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get entry', 'HealthJournalRepo', e, stackTrace);
      return Left(CacheFailure(message: 'Failed to get entry: $e'));
    }
  }

  Future<Result<HealthJournalEntry>> updateEntry(
    HealthJournalEntry entry,
  ) async {
    try {
      final updated = entry.copyWith(updatedAt: DateTime.now());

      await databaseHelper.update(
        'health_journal_entries',
        updated.toDbMap(),
        where: 'id = ?',
        whereArgs: [entry.id],
      );

      return Right(updated);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update entry', 'HealthJournalRepo', e, stackTrace);
      return Left(CacheFailure(message: 'Failed to update entry: $e'));
    }
  }

  Future<Result<void>> deleteEntry(String id) async {
    try {
      await databaseHelper.delete(
        'health_journal_entries',
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete entry', 'HealthJournalRepo', e, stackTrace);
      return Left(CacheFailure(message: 'Failed to delete entry: $e'));
    }
  }

  Future<Result<List<HealthJournalEntry>>> getTodayEntries({
    required String userId,
  }) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final results = await databaseHelper.query(
        'health_journal_entries',
        where: 'user_id = ? AND entry_date >= ? AND entry_date < ?',
        whereArgs: [
          userId,
          startOfDay.toIso8601String(),
          endOfDay.toIso8601String(),
        ],
        orderBy: 'created_at DESC',
      );

      final entries = results
          .map((map) => HealthJournalEntryExtension.fromDbMap(map))
          .toList();

      return Right(entries);
    } catch (e, stackTrace) {
      AppLogger.error("Failed to get today's entries", 'HealthJournalRepo', e, stackTrace);
      return Left(CacheFailure(message: "Failed to get today's entries: $e"));
    }
  }

  Future<Result<List<HealthJournalEntry>>> getUnprocessedEntries({
    int limit = 100,
  }) async {
    try {
      final results = await databaseHelper.query(
        'health_journal_entries',
        where: 'is_processed = ?',
        whereArgs: [0],
        orderBy: 'created_at ASC',
        limit: limit,
      );

      final entries = results
          .map((map) => HealthJournalEntryExtension.fromDbMap(map))
          .toList();

      return Right(entries);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get unprocessed entries',
        'HealthJournalRepo',
        e,
        stackTrace,
      );
      return Left(CacheFailure(message: 'Failed to get unprocessed entries: $e'));
    }
  }

  Future<Result<void>> markAsProcessed(String id) async {
    try {
      await databaseHelper.update(
        'health_journal_entries',
        {'is_processed': 1, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to mark as processed',
        'HealthJournalRepo',
        e,
        stackTrace,
      );
      return Left(CacheFailure(message: 'Failed to mark as processed: $e'));
    }
  }
}
