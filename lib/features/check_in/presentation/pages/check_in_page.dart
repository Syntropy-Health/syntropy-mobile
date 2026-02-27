import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/health_journal_entry.dart';
import '../../../voice_notes/presentation/providers/voice_notes_provider.dart';
import '../../domain/entry_parser_service.dart';
import '../providers/check_in_provider.dart';
import '../widgets/check_in_recording_button.dart';
import '../widgets/confirm_check_in_sheet.dart';
import '../widgets/entry_type_chip.dart';
import '../widgets/manual_entry_sheet.dart';
import '../widgets/today_entries_list.dart';

class CheckInPage extends ConsumerStatefulWidget {
  const CheckInPage({super.key});

  @override
  ConsumerState<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends ConsumerState<CheckInPage> {
  static const String _userId = 'demo_user';
  bool _isTranscribing = false;

  final _entryParserService = EntryParserService();

  // Entry types to show as manual chips (excluding 'note')
  static const _manualEntryTypes = [
    EntryType.meal,
    EntryType.supplement,
    EntryType.symptom,
    EntryType.exercise,
    EntryType.sleep,
    EntryType.mood,
  ];

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Future<void> _handleRecordingComplete(
    dynamic recordingResult,
  ) async {
    final path = recordingResult.path as String;

    setState(() => _isTranscribing = true);

    try {
      // Transcribe the audio
      final transcriptionService = ref.read(transcriptionServiceProvider);
      final transcriptionResult =
          await transcriptionService.transcribeAudio(path);

      if (!mounted) return;
      setState(() => _isTranscribing = false);

      final transcription = transcriptionResult.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Transcription failed: ${failure.message}'),
            ),
          );
          return null;
        },
        (text) => text,
      );

      if (transcription == null || transcription.isEmpty) return;

      // Parse transcription into entries
      final parsedEntries = _entryParserService.parse(transcription);

      // Show confirmation sheet
      if (!mounted) return;
      final confirmedEntries = await ConfirmCheckInSheet.show(
        context,
        transcription: transcription,
        parsedEntries: parsedEntries,
      );

      if (confirmedEntries == null || confirmedEntries.isEmpty) return;

      // Batch create confirmed entries
      final controller =
          ref.read(checkInControllerProvider(_userId).notifier);
      await controller.createBatchEntries(
        entries: confirmedEntries,
        transcription: transcription,
        audioPath: path,
      );

      // Invalidate today entries to refresh
      ref.invalidate(todayEntriesProvider(_userId));
    } catch (e) {
      if (mounted) {
        setState(() => _isTranscribing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _handleManualEntry(EntryType entryType) async {
    final content = await ManualEntrySheet.show(
      context,
      entryType: entryType,
    );

    if (content == null || content.isEmpty) return;

    final controller =
        ref.read(checkInControllerProvider(_userId).notifier);
    await controller.createEntry(
      entryType: entryType,
      content: content,
    );

    // Invalidate today entries to refresh
    ref.invalidate(todayEntriesProvider(_userId));
  }

  @override
  Widget build(BuildContext context) {
    final todayEntriesAsync = ref.watch(todayEntriesProvider(_userId));

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              title: const Text('Check In'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.history),
                  onPressed: () {
                    // TODO: Navigate to check-in history
                  },
                ),
              ],
            ),

            // Greeting
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _getGreeting(),
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'What did you do today?',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),

            // Recording button
            SliverToBoxAdapter(
              child: Center(
                child: _isTranscribing
                    ? Column(
                        children: [
                          const SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Transcribing...',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      )
                    : CheckInRecordingButton(
                        onRecordingComplete: _handleRecordingComplete,
                      ),
              ),
            ),

            // "or log manually" divider
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(color: AppColors.border),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      child: Text(
                        'or log manually',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: AppColors.border),
                    ),
                  ],
                ),
              ),
            ),

            // Entry type chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  alignment: WrapAlignment.center,
                  children: _manualEntryTypes
                      .map(
                        (type) => EntryTypeChip(
                          entryType: type,
                          onTap: () => _handleManualEntry(type),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),

            // Today's check-ins header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: todayEntriesAsync.when(
                  loading: () => Text(
                    "Today's Check-ins",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  error: (_, __) => Text(
                    "Today's Check-ins",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  data: (entries) => Text(
                    "Today's Check-ins (${entries.length})",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
            ),

            // Today's entries list
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: todayEntriesAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text('Failed to load entries: $error'),
                        TextButton(
                          onPressed: () => ref.invalidate(
                            todayEntriesProvider(_userId),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (entries) => TodayEntriesList(entries: entries),
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }
}
