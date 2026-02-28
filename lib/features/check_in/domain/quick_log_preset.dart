import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../data/models/health_journal_entry.dart';

part 'quick_log_preset.freezed.dart';
part 'quick_log_preset.g.dart';

@freezed
class QuickLogPreset with _$QuickLogPreset {
  const factory QuickLogPreset({
    required String id,
    required String userId,
    required EntryType entryType,
    required String content,
    @Default('') String displayName,
    @Default(0) int useCount,
    @Default(false) bool isPinned,
    required DateTime createdAt,
    DateTime? lastUsedAt,
  }) = _QuickLogPreset;

  factory QuickLogPreset.fromJson(Map<String, dynamic> json) =>
      _$QuickLogPresetFromJson(json);
}
