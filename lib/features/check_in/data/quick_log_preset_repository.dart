import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/failure.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/result.dart';
import '../../../data/datasources/local/database_helper.dart';
import '../../../data/models/health_journal_entry.dart';
import '../domain/quick_log_preset.dart';

class QuickLogPresetRepository {
  QuickLogPresetRepository(this._databaseHelper);

  final DatabaseHelper _databaseHelper;
  final _uuid = const Uuid();

  Future<Result<List<QuickLogPreset>>> getPresets({
    required String userId,
  }) async {
    try {
      final db = await _databaseHelper.database;
      final results = await db.query(
        'quick_log_presets',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'is_pinned DESC, use_count DESC, created_at DESC',
      );
      final presets = results.map((row) => _fromRow(row)).toList();
      return Right(presets);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get presets', 'QuickLogPresetRepo', e, stackTrace);
      return Left(CacheFailure(message: 'Failed to get presets: $e'));
    }
  }

  Future<Result<QuickLogPreset>> createPreset({
    required String userId,
    required EntryType entryType,
    required String content,
    String? displayName,
  }) async {
    try {
      final db = await _databaseHelper.database;
      final now = DateTime.now();
      final id = _uuid.v4();
      final preset = QuickLogPreset(
        id: id,
        userId: userId,
        entryType: entryType,
        content: content,
        displayName: displayName ?? content,
        createdAt: now,
      );
      await db.insert('quick_log_presets', _toRow(preset));
      AppLogger.info('Created preset: $id', 'QuickLogPresetRepo');
      return Right(preset);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create preset', 'QuickLogPresetRepo', e, stackTrace);
      return Left(CacheFailure(message: 'Failed to create preset: $e'));
    }
  }

  Future<Result<void>> incrementUseCount(String presetId) async {
    try {
      final db = await _databaseHelper.database;
      await db.rawUpdate(
        'UPDATE quick_log_presets SET use_count = use_count + 1, last_used_at = ? WHERE id = ?',
        [DateTime.now().toIso8601String(), presetId],
      );
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to increment use count', 'QuickLogPresetRepo', e, stackTrace);
      return Left(CacheFailure(message: 'Failed to increment use count: $e'));
    }
  }

  Future<Result<void>> togglePin(String presetId) async {
    try {
      final db = await _databaseHelper.database;
      await db.rawUpdate(
        'UPDATE quick_log_presets SET is_pinned = CASE WHEN is_pinned = 1 THEN 0 ELSE 1 END WHERE id = ?',
        [presetId],
      );
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to toggle pin', 'QuickLogPresetRepo', e, stackTrace);
      return Left(CacheFailure(message: 'Failed to toggle pin: $e'));
    }
  }

  Future<Result<void>> deletePreset(String presetId) async {
    try {
      final db = await _databaseHelper.database;
      await db.delete(
        'quick_log_presets',
        where: 'id = ?',
        whereArgs: [presetId],
      );
      AppLogger.info('Deleted preset: $presetId', 'QuickLogPresetRepo');
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete preset', 'QuickLogPresetRepo', e, stackTrace);
      return Left(CacheFailure(message: 'Failed to delete preset: $e'));
    }
  }

  Future<Result<List<QuickLogPreset>>> generatePresetsFromHistory({
    required String userId,
    int limit = 10,
  }) async {
    try {
      final db = await _databaseHelper.database;
      // Find frequently logged entries
      final results = await db.rawQuery('''
        SELECT content, entry_type, COUNT(*) as freq
        FROM health_journal_entries
        WHERE user_id = ?
        GROUP BY content, entry_type
        HAVING freq >= 2
        ORDER BY freq DESC
        LIMIT ?
      ''', [userId, limit],);

      final presets = <QuickLogPreset>[];
      for (final row in results) {
        final content = row['content'] as String;
        final entryTypeStr = row['entry_type'] as String;

        // Check if preset already exists
        final existing = await db.query(
          'quick_log_presets',
          where: 'user_id = ? AND content = ? AND entry_type = ?',
          whereArgs: [userId, content, entryTypeStr],
        );
        if (existing.isNotEmpty) continue;

        final result = await createPreset(
          userId: userId,
          entryType: EntryType.values.firstWhere(
            (e) => e.name == entryTypeStr,
            orElse: () => EntryType.note,
          ),
          content: content,
        );
        result.fold((_) => null, (preset) => presets.add(preset));
      }
      AppLogger.info(
        'Generated ${presets.length} presets from history',
        'QuickLogPresetRepo',
      );
      return Right(presets);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to generate presets from history',
        'QuickLogPresetRepo',
        e,
        stackTrace,
      );
      return Left(CacheFailure(message: 'Failed to generate presets: $e'));
    }
  }

  QuickLogPreset _fromRow(Map<String, dynamic> row) {
    return QuickLogPreset(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      entryType: EntryType.values.firstWhere(
        (e) => e.name == row['entry_type'],
        orElse: () => EntryType.note,
      ),
      content: row['content'] as String,
      displayName: row['display_name'] as String? ?? '',
      useCount: row['use_count'] as int? ?? 0,
      isPinned: (row['is_pinned'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(row['created_at'] as String),
      lastUsedAt: row['last_used_at'] != null
          ? DateTime.parse(row['last_used_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> _toRow(QuickLogPreset preset) {
    return {
      'id': preset.id,
      'user_id': preset.userId,
      'entry_type': preset.entryType.name,
      'content': preset.content,
      'display_name': preset.displayName,
      'use_count': preset.useCount,
      'is_pinned': preset.isPinned ? 1 : 0,
      'created_at': preset.createdAt.toIso8601String(),
      'last_used_at': preset.lastUsedAt?.toIso8601String(),
    };
  }
}
