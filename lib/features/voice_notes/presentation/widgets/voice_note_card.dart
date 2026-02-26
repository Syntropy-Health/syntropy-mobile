import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/voice_note.dart';

class VoiceNoteCard extends StatelessWidget {
  const VoiceNoteCard({
    super.key,
    required this.voiceNote,
    this.onDelete,
    this.onRetryTranscription,
  });

  final VoiceNote voiceNote;
  final VoidCallback? onDelete;
  final VoidCallback? onRetryTranscription;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Color _getStatusColor() {
    switch (voiceNote.transcriptionStatus) {
      case TranscriptionStatus.pending:
        return AppColors.warning;
      case TranscriptionStatus.processing:
        return AppColors.info;
      case TranscriptionStatus.completed:
        return AppColors.success;
      case TranscriptionStatus.failed:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon() {
    switch (voiceNote.transcriptionStatus) {
      case TranscriptionStatus.pending:
        return Icons.schedule;
      case TranscriptionStatus.processing:
        return Icons.sync;
      case TranscriptionStatus.completed:
        return Icons.check_circle;
      case TranscriptionStatus.failed:
        return Icons.error;
    }
  }

  String _getStatusText() {
    switch (voiceNote.transcriptionStatus) {
      case TranscriptionStatus.pending:
        return 'Pending';
      case TranscriptionStatus.processing:
        return 'Processing...';
      case TranscriptionStatus.completed:
        return 'Transcribed';
      case TranscriptionStatus.failed:
        return 'Failed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: const Icon(
                    Icons.mic,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voice Note',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        voiceNote.createdAt != null
                            ? dateFormat.format(voiceNote.createdAt!)
                            : 'Unknown date',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDuration(voiceNote.duration),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Transcription Status
            Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  size: 16,
                  color: _getStatusColor(),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  _getStatusText(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(),
                      ),
                ),
                if (voiceNote.transcriptionStatus == TranscriptionStatus.failed)
                  TextButton(
                    onPressed: onRetryTranscription,
                    child: const Text('Retry'),
                  ),
              ],
            ),

            // Transcription Text
            if (voiceNote.transcription != null &&
                voiceNote.transcription!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Text(
                  voiceNote.transcription!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            // Error message
            if (voiceNote.errorMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                voiceNote.errorMessage!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
              ),
            ],

            // Actions
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () {
                    // TODO: Implement audio playback
                  },
                  tooltip: 'Play',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                  color: AppColors.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
