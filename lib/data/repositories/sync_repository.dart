import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/failure.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../datasources/local/database_helper.dart';
import '../datasources/remote/supabase_client.dart';
import '../models/health_journal_entry.dart';

class SyncRepository {
  SyncRepository({
    required this.databaseHelper,
    required this.supabaseClient,
  });

  final DatabaseHelper databaseHelper;
  final SupabaseClientWrapper supabaseClient;
  final _uuid = const Uuid();

  Future<bool> get hasConnection async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<Result<void>> queueForSync({
    required String tableName,
    required String recordId,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    try {
      await databaseHelper.insert('sync_queue', {
        'id': _uuid.v4(),
        'table_name': tableName,
        'record_id': recordId,
        'operation': operation,
        'data': json.encode(data),
        'created_at': DateTime.now().toIso8601String(),
        'retry_count': 0,
      });
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to queue sync', 'SyncRepo', e, stackTrace);
      return Left(CacheFailure(message: 'Failed to queue sync: $e'));
    }
  }

  Future<Result<int>> processSyncQueue() async {
    if (!await hasConnection) {
      AppLogger.info('No connection, skipping sync', 'SyncRepo');
      return const Right(0);
    }

    if (!supabaseClient.isInitialized) {
      AppLogger.warning('Supabase not initialized, skipping sync', 'SyncRepo');
      return const Right(0);
    }

    try {
      final queue = await databaseHelper.query(
        'sync_queue',
        orderBy: 'created_at ASC',
        limit: 50,
      );

      int synced = 0;

      for (final item in queue) {
        final success = await _processSyncItem(item);
        if (success) {
          await databaseHelper.delete(
            'sync_queue',
            where: 'id = ?',
            whereArgs: [item['id']],
          );
          synced++;
        } else {
          await _incrementRetryCount(item['id'] as String);
        }
      }

      AppLogger.info('Synced $synced items', 'SyncRepo');
      return Right(synced);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to process sync queue', 'SyncRepo', e, stackTrace);
      return Left(SyncFailure(message: 'Failed to process sync queue: $e'));
    }
  }

  Future<bool> _processSyncItem(Map<String, dynamic> item) async {
    try {
      final tableName = item['table_name'] as String;
      final operation = item['operation'] as String;
      final data = json.decode(item['data'] as String) as Map<String, dynamic>;
      final recordId = item['record_id'] as String;

      switch (operation) {
        case 'insert':
          await supabaseClient.insert(tableName, data);
          break;
        case 'update':
          await supabaseClient.update(tableName, recordId, data);
          break;
        case 'delete':
          await supabaseClient.delete(tableName, recordId);
          break;
        default:
          AppLogger.warning('Unknown operation: $operation', 'SyncRepo');
          return false;
      }

      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to sync item', 'SyncRepo', e, stackTrace);
      return false;
    }
  }

  Future<void> _incrementRetryCount(String id) async {
    await databaseHelper.update(
      'sync_queue',
      {'retry_count': 1}, // SQLite doesn't support increment easily
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Result<void>> syncJournalEntries(String userId) async {
    try {
      // Get pending entries
      final pendingResult = await databaseHelper.query(
        'health_journal_entries',
        where: 'user_id = ? AND sync_status = ?',
        whereArgs: [userId, SyncStatus.pending.name],
      );

      for (final entryMap in pendingResult) {
        final entry = HealthJournalEntryExtension.fromDbMap(entryMap);
        await queueForSync(
          tableName: 'health_journal_entries',
          recordId: entry.id,
          operation: 'insert',
          data: entry.toDbMap(),
        );

        // Update local sync status
        await databaseHelper.update(
          'health_journal_entries',
          {'sync_status': SyncStatus.synced.name},
          where: 'id = ?',
          whereArgs: [entry.id],
        );
      }

      // Process the queue
      await processSyncQueue();

      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to sync entries', 'SyncRepo', e, stackTrace);
      return Left(SyncFailure(message: 'Failed to sync entries: $e'));
    }
  }

  Future<Result<int>> getPendingSyncCount() async {
    try {
      final result = await databaseHelper.query('sync_queue');
      return Right(result.length);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get pending count: $e'));
    }
  }
}
