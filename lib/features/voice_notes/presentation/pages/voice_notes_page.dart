import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/voice_notes_provider.dart';
import '../widgets/recording_button.dart';
import '../widgets/voice_note_card.dart';

class VoiceNotesPage extends ConsumerWidget {
  const VoiceNotesPage({super.key});

  // TODO: Replace with actual user ID from auth
  static const String _userId = 'demo_user';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceNotesAsync = ref.watch(voiceNotesControllerProvider(_userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(voiceNotesControllerProvider(_userId).notifier)
                  .loadVoiceNotes();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Recording Section
          Container(
            padding: AppSpacing.pagePadding,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Tap to record your health journal',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                RecordingButton(userId: _userId),
              ],
            ),
          ),

          // Voice Notes List
          Expanded(
            child: voiceNotesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Failed to load voice notes',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: () {
                        ref.read(voiceNotesControllerProvider(_userId).notifier)
                            .loadVoiceNotes();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (notes) {
                if (notes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mic_none,
                          size: 64,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No voice notes yet',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Record your first health journal entry',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: AppSpacing.pagePadding,
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return VoiceNoteCard(
                      voiceNote: note,
                      onDelete: () {
                        ref.read(voiceNotesControllerProvider(_userId).notifier)
                            .deleteVoiceNote(note.id);
                      },
                      onRetryTranscription: () {
                        ref.read(voiceNotesControllerProvider(_userId).notifier)
                            .retryTranscription(note);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
