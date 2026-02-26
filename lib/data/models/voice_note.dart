import 'package:freezed_annotation/freezed_annotation.dart';

part 'voice_note.freezed.dart';
part 'voice_note.g.dart';

enum TranscriptionStatus { pending, processing, completed, failed }

@freezed
class VoiceNote with _$VoiceNote {
  const factory VoiceNote({
    required String id,
    required String userId,
    required String audioPath,
    required Duration duration,
    String? transcription,
    @Default(TranscriptionStatus.pending) TranscriptionStatus transcriptionStatus,
    DateTime? createdAt,
    DateTime? transcribedAt,
    String? errorMessage,
    @Default(false) bool isProcessedForHealth,
    String? healthEntryId,
  }) = _VoiceNote;

  factory VoiceNote.fromJson(Map<String, dynamic> json) =>
      _$VoiceNoteFromJson(json);
}

extension VoiceNoteExtension on VoiceNote {
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'user_id': userId,
      'audio_path': audioPath,
      'duration_ms': duration.inMilliseconds,
      'transcription': transcription,
      'transcription_status': transcriptionStatus.name,
      'created_at': createdAt?.toIso8601String(),
      'transcribed_at': transcribedAt?.toIso8601String(),
      'error_message': errorMessage,
      'is_processed_for_health': isProcessedForHealth ? 1 : 0,
      'health_entry_id': healthEntryId,
    };
  }

  static VoiceNote fromDbMap(Map<String, dynamic> map) {
    return VoiceNote(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      audioPath: map['audio_path'] as String,
      duration: Duration(milliseconds: map['duration_ms'] as int),
      transcription: map['transcription'] as String?,
      transcriptionStatus: TranscriptionStatus.values
          .byName(map['transcription_status'] as String),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      transcribedAt: map['transcribed_at'] != null
          ? DateTime.parse(map['transcribed_at'] as String)
          : null,
      errorMessage: map['error_message'] as String?,
      isProcessedForHealth: (map['is_processed_for_health'] as int?) == 1,
      healthEntryId: map['health_entry_id'] as String?,
    );
  }
}
