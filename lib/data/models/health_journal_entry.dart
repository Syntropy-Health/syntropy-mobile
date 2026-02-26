import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_journal_entry.freezed.dart';
part 'health_journal_entry.g.dart';

enum EntryType { meal, symptom, supplement, exercise, sleep, mood, note }

enum SyncStatus { pending, synced, failed }

@freezed
class HealthJournalEntry with _$HealthJournalEntry {
  const factory HealthJournalEntry({
    required String id,
    required String userId,
    required EntryType entryType,
    required String content,
    String? transcription,
    String? audioPath,
    DateTime? entryDate,
    @Default(SyncStatus.pending) SyncStatus syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(false) bool isProcessed,
    Map<String, dynamic>? metadata,
  }) = _HealthJournalEntry;

  factory HealthJournalEntry.fromJson(Map<String, dynamic> json) =>
      _$HealthJournalEntryFromJson(json);
}

extension HealthJournalEntryExtension on HealthJournalEntry {
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'user_id': userId,
      'entry_type': entryType.name,
      'content': content,
      'transcription': transcription,
      'audio_path': audioPath,
      'entry_date': entryDate?.toIso8601String(),
      'sync_status': syncStatus.name,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_processed': isProcessed ? 1 : 0,
      'metadata': metadata != null ? metadata.toString() : null,
    };
  }

  static HealthJournalEntry fromDbMap(Map<String, dynamic> map) {
    return HealthJournalEntry(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      entryType: EntryType.values.byName(map['entry_type'] as String),
      content: map['content'] as String,
      transcription: map['transcription'] as String?,
      audioPath: map['audio_path'] as String?,
      entryDate: map['entry_date'] != null
          ? DateTime.parse(map['entry_date'] as String)
          : null,
      syncStatus: SyncStatus.values.byName(map['sync_status'] as String),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      isProcessed: (map['is_processed'] as int?) == 1,
    );
  }
}
