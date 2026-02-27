# Implementation Plan: PRD-10 Phase 1 -- Check-in UX Redesign

## Summary

Add a dedicated Check-in screen to Syntropy Mobile that replaces the current scattered quick-action workflow. The new screen puts a prominent voice-recording button at the center, shows a confirmation/edit step after transcription, writes the result to the `health_journal_entries` table as a structured `HealthJournalEntry`, and displays today's logged entries below the recording area. The screen is reachable from a new bottom-nav tab and from the Home page's quick-action buttons.

## User Story

> As a biohacker on-the-go, I want to open the app, tap one button, speak what I ate or supplemented, see the parsed result, confirm it, and be done in under 30 seconds -- so I never break my tracking streak.

## Problem Statement

The current app has voice recording buried inside the "Voice Notes" tab. After recording, the transcription is stored as a `VoiceNote` but never converted into a `HealthJournalEntry`. There is no confirmation step, no entry-type categorization, and no visibility into "what did I log today?" on any screen. The home page quick-action buttons for "Log Meal" just redirect to the Voice Notes page, which has no structured logging concept.

---

## UX Before / After

### BEFORE (current flow)

```
+-----------------------------------+
|  Home                      [bell] |
|  Good Morning                     |
|  Syntropy Health                  |
|                                   |
|  +-----------------------------+  |
|  | Your Health Score    85/100 |  |
|  +-----------------------------+  |
|                                   |
|  Quick Actions                    |
|  [Voice Note] [Log Meal] [Supps] |
|       |            |        |     |
|       v            v        |     |
|  /voice-notes  /voice-notes |     |
|  (same page!)  (same page!) |     |
|                         /catalog  |
|                                   |
|  Recent Activity (hardcoded)      |
|                                   |
| [Home] [Voice] [Anlys] [Shop] [Set] |
+-----------------------------------+

Problem: "Log Meal" goes to voice-notes page.
         No structured entry creation.
         No "today's check-ins" view.
```

### AFTER (Phase 1)

```
+-----------------------------------+
|  Check In              [history]  |
|  Good Morning                     |
|  What did you do today?           |
|                                   |
|  +-----------------------------+  |
|  |                             |  |
|  |      ( ( ( MIC ) ) )       |  |
|  |       Tap to record         |  |
|  |          00:00              |  |
|  |                             |  |
|  +-----------------------------+  |
|                                   |
|  -- or log manually --            |
|  [Meal] [Supplement] [Symptom]    |
|  [Exercise] [Sleep]  [Mood]       |
|                                   |
|  Today's Check-ins (3)            |
|  +-----------------------------+  |
|  | [pill] Creatine 5g   8:02a |  |
|  | [fork] Salmon salad  12:30p|  |
|  | [warn] Headache      2:15p |  |
|  +-----------------------------+  |
|                                   |
| [Home] [Check-in] [Anlys] [Shop] [Set] |
+-----------------------------------+

After voice recording + transcription:

+-----------------------------------+
|  Confirm Check-in         [edit]  |
|                                   |
|  We heard:                        |
|  "Took 5g creatine and had       |
|   salmon salad for lunch"         |
|                                   |
|  Parsed entries:                  |
|  +-----------------------------+  |
|  | [pill] Supplement            | |
|  |  Creatine 5g         [x]   |  |
|  +-----------------------------+  |
|  | [fork] Meal                  | |
|  |  Salmon salad for lunch [x] |  |
|  +-----------------------------+  |
|                                   |
|  [ Cancel ]    [ Confirm & Save ] |
|                                   |
+-----------------------------------+
```

---

## Mandatory Reading

| # | File | Lines | What to Learn |
|---|------|-------|---------------|
| 1 | `lib/core/router/app_router.dart` | 1-73 | GoRouter + ShellRoute + NoTransitionPage pattern for adding new route |
| 2 | `lib/core/router/routes.dart` | 1-17 | Routes constants pattern (path + name pairs) |
| 3 | `lib/core/widgets/main_scaffold.dart` | 1-81 | Bottom nav bar: index mapping, destination list, `_onItemTapped` switch |
| 4 | `lib/features/voice_notes/presentation/pages/voice_notes_page.dart` | 1-146 | ConsumerWidget page pattern, `_userId = 'demo_user'`, AsyncValue.when rendering |
| 5 | `lib/features/voice_notes/presentation/providers/voice_notes_provider.dart` | 1-138 | StateNotifierProvider pattern, family providers, controller class structure |
| 6 | `lib/features/voice_notes/presentation/widgets/recording_button.dart` | 1-182 | ConsumerStatefulWidget with AnimationController, timer, toggle recording logic |
| 7 | `lib/features/voice_notes/domain/audio_recorder_service.dart` | 1-162 | AudioRecorder lifecycle, RecordingResult, amplitudeStream (unused) |
| 8 | `lib/data/models/health_journal_entry.dart` | 1-70 | Freezed model, EntryType enum, SyncStatus enum, toDbMap/fromDbMap extensions |
| 9 | `lib/data/repositories/health_journal_repository.dart` | 1-191 | Result<T> return pattern, createEntry / getEntries / updateEntry signatures |
| 10 | `lib/data/repositories/voice_note_repository.dart` | 1-187 | Nullable DatabaseHelper pattern for web compatibility, transcription flow |
| 11 | `lib/core/di/providers.dart` | 1-53 | Repository provider wiring: nullable for web, Provider<T?> pattern |
| 12 | `lib/core/theme/app_colors.dart` | 1-57 | Health category colors: nutrition, exercise, sleep, mental, supplements |
| 13 | `lib/core/theme/app_spacing.dart` | 1-37 | Spacing constants (xxs=4, xs=8, sm=12, md=16, lg=24), padding presets |
| 14 | `lib/core/utils/result.dart` | 1-27 | `Result<T> = Either<Failure, T>` typedef, extension methods |
| 15 | `lib/core/utils/failure.dart` | 1-43 | Failure subclasses: CacheFailure, TranscriptionFailure, etc. |
| 16 | `lib/data/models/voice_note.dart` | 1-65 | VoiceNote Freezed model, isProcessedForHealth, healthEntryId fields |
| 17 | `lib/features/home/presentation/pages/home_page.dart` | 96-141 | Quick Actions section to rewire to check-in route |
| 18 | `lib/data/datasources/remote/transcription_service.dart` | 1-70 | Whisper API call, Result<String> return |

---

## Patterns to Mirror

### Pattern 1: Route Registration (GoRouter + ShellRoute)

From `lib/core/router/app_router.dart:21-34`:

```dart
// Each route inside ShellRoute gets the bottom nav via MainScaffold
GoRoute(
  path: Routes.voiceNotes,
  name: Routes.voiceNotesName,
  pageBuilder: (context, state) => const NoTransitionPage(
    child: VoiceNotesPage(),
  ),
),
```

### Pattern 2: Route Constants

From `lib/core/router/routes.dart:1-17`:

```dart
abstract class Routes {
  static const String voiceNotes = '/voice-notes';
  static const String voiceNotesName = 'voice-notes';
}
```

### Pattern 3: Bottom Nav Destination + Index

From `lib/core/widgets/main_scaffold.dart:15-41`:

```dart
int _calculateSelectedIndex(BuildContext context) {
  final location = GoRouterState.of(context).uri.path;
  if (location.startsWith(Routes.voiceNotes)) return 1;
  // ...
  return 0;
}

void _onItemTapped(BuildContext context, int index) {
  switch (index) {
    case 1:
      context.go(Routes.voiceNotes);
      break;
    // ...
  }
}
```

### Pattern 4: StateNotifierProvider with Family

From `lib/features/voice_notes/presentation/providers/voice_notes_provider.dart:56-138`:

```dart
class VoiceNotesController extends StateNotifier<AsyncValue<List<VoiceNote>>> {
  VoiceNotesController({
    required this.repository,
    required this.audioRecorder,
    required this.userId,
  }) : super(const AsyncValue.loading()) {
    loadVoiceNotes();
  }
  // ...
}

final voiceNotesControllerProvider = StateNotifierProvider.autoDispose
    .family<VoiceNotesController, AsyncValue<List<VoiceNote>>, String>(
  (ref, userId) {
    // ...
  },
);
```

### Pattern 5: Repository with Result<T>

From `lib/data/repositories/health_journal_repository.dart:21-53`:

```dart
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
      // ...
    );
    await databaseHelper.insert('health_journal_entries', entry.toDbMap());
    AppLogger.info('Created journal entry: ${entry.id}', 'HealthJournalRepo');
    return Right(entry);
  } catch (e, stackTrace) {
    AppLogger.error('Failed to create entry', 'HealthJournalRepo', e, stackTrace);
    return Left(CacheFailure(message: 'Failed to create entry: $e'));
  }
}
```

### Pattern 6: ConsumerWidget Page with AsyncValue.when

From `lib/features/voice_notes/presentation/pages/voice_notes_page.dart:10-146`:

```dart
class VoiceNotesPage extends ConsumerWidget {
  const VoiceNotesPage({super.key});
  static const String _userId = 'demo_user';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceNotesAsync = ref.watch(voiceNotesControllerProvider(_userId));
    return Scaffold(
      // ...
      child: voiceNotesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(/* error widget */),
        data: (notes) { /* list */ },
      ),
    );
  }
}
```

### Pattern 7: Recording Button (ConsumerStatefulWidget + Animation)

From `lib/features/voice_notes/presentation/widgets/recording_button.dart:11-24`:

```dart
class RecordingButton extends ConsumerStatefulWidget {
  const RecordingButton({super.key, required this.userId});
  final String userId;

  @override
  ConsumerState<RecordingButton> createState() => _RecordingButtonState();
}

class _RecordingButtonState extends ConsumerState<RecordingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  // ...
}
```

### Pattern 8: QuickActionButton Widget

From `lib/features/home/presentation/widgets/quick_action_button.dart:5-57`:

```dart
class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });
  // ...
}
```

---

## Files to Change

| # | File | Action | Description |
|---|------|--------|-------------|
| 1 | `lib/core/router/routes.dart` | EDIT | Add `checkIn` and `checkInName` constants |
| 2 | `lib/core/router/app_router.dart` | EDIT | Add GoRoute for `/check-in` with `CheckInPage`, import |
| 3 | `lib/core/widgets/main_scaffold.dart` | EDIT | Replace Voice tab (index 1) with Check-in tab, update index mappings |
| 4 | `lib/features/check_in/presentation/pages/check_in_page.dart` | CREATE | Main check-in screen: voice recorder, category chips, today's list |
| 5 | `lib/features/check_in/presentation/widgets/check_in_recording_button.dart` | CREATE | Reusable large mic button for check-in (mirrors RecordingButton) |
| 6 | `lib/features/check_in/presentation/widgets/entry_type_chip.dart` | CREATE | Colored chip for each EntryType (manual log trigger) |
| 7 | `lib/features/check_in/presentation/widgets/today_entries_list.dart` | CREATE | List of today's HealthJournalEntry items |
| 8 | `lib/features/check_in/presentation/widgets/confirm_check_in_sheet.dart` | CREATE | Bottom sheet for reviewing/editing parsed entries before save |
| 9 | `lib/features/check_in/presentation/widgets/manual_entry_sheet.dart` | CREATE | Bottom sheet for manual text entry with EntryType pre-selected |
| 10 | `lib/features/check_in/presentation/providers/check_in_provider.dart` | CREATE | CheckInController (StateNotifier), todayEntriesProvider, recording state |
| 11 | `lib/features/check_in/domain/entry_parser_service.dart` | CREATE | Parse transcription text into list of (EntryType, content) tuples |
| 12 | `lib/features/home/presentation/pages/home_page.dart` | EDIT | Rewire quick-action buttons to navigate to `/check-in` |
| 13 | `lib/data/repositories/health_journal_repository.dart` | EDIT | Add `getTodayEntries(userId)` convenience method |

---

## Step-by-Step Tasks

### Task 1: Add route constants

**File**: `lib/core/router/routes.dart`

Add check-in route path and name constants.

```dart
static const String checkIn = '/check-in';
static const String checkInName = 'check-in';
```

- **MIRROR**: Follow the exact `path` / `Name` pair pattern used for every other route (lines 3-16).
- **IMPORTS**: None needed.
- **GOTCHA**: The path must start with `/` to work inside ShellRoute.
- **VALIDATE**: `flutter analyze` passes with no unused-variable warnings.

---

### Task 2: Create the CheckInController provider

**File**: `lib/features/check_in/presentation/providers/check_in_provider.dart` (CREATE)

Build the state management layer before the UI. The controller manages:
- Today's entries (loaded from `HealthJournalRepository.getEntries` filtered to today)
- Recording state delegation to `AudioRecorderService`
- Entry creation (single and batch from parsed transcription)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../data/models/health_journal_entry.dart';
import '../../../../data/repositories/health_journal_repository.dart';
import '../../../voice_notes/domain/audio_recorder_service.dart';
import '../../../voice_notes/presentation/providers/voice_notes_provider.dart';

// Today's entries provider
final todayEntriesProvider = FutureProvider.autoDispose
    .family<List<HealthJournalEntry>, String>((ref, userId) async {
  final repository = ref.watch(healthJournalRepositoryProvider);
  if (repository == null) return [];
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final result = await repository.getEntries(userId: userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (entries) => entries
        .where((e) =>
            e.entryDate != null && e.entryDate!.isAfter(startOfDay))
        .toList(),
  );
});
```

- **MIRROR**: `VoiceNotesController` pattern at `voice_notes_provider.dart:56-121`. Use `StateNotifier<AsyncValue<List<HealthJournalEntry>>>` with `autoDispose.family`.
- **IMPORTS**: Reuse `healthJournalRepositoryProvider` from `core/di/providers.dart:22-30`, `audioRecorderServiceProvider` from `voice_notes/presentation/providers/voice_notes_provider.dart:10-16`.
- **GOTCHA**: `healthJournalRepositoryProvider` returns `HealthJournalRepository?` (nullable for web). Handle the null case with an early return of empty list, same pattern as `voiceNoteRepositoryProvider` at `voice_notes_provider.dart:24-31`.
- **GOTCHA**: The `getEntries` method takes `userId`, `entryType`, `limit`, `offset` -- filter by today's date must be done client-side since the repository doesn't support date range queries. This is acceptable for MVP (entries-per-day volume is small).
- **VALIDATE**: `flutter analyze` -- provider must be `autoDispose` to match existing pattern.

---

### Task 3: Create the EntryParserService

**File**: `lib/features/check_in/domain/entry_parser_service.dart` (CREATE)

A simple keyword-based parser that takes raw transcription text and produces a list of `ParsedEntry(EntryType, String content)` objects. This is the critical bridge between voice note transcription and structured journal entries.

Rules:
- Keywords like "took", "supplement", "creatine", "magnesium", "vitamin" -> `EntryType.supplement`
- Keywords like "ate", "had", "meal", "lunch", "dinner", "breakfast", "salad", "chicken" -> `EntryType.meal`
- Keywords like "feel", "headache", "pain", "nausea", "tired", "symptom" -> `EntryType.symptom`
- Keywords like "slept", "sleep", "hours of sleep", "woke up" -> `EntryType.sleep`
- Keywords like "ran", "walk", "exercise", "workout", "gym", "lifted" -> `EntryType.exercise`
- Keywords like "mood", "happy", "anxious", "stressed", "calm" -> `EntryType.mood`
- Default: `EntryType.note`

Split on "and", commas, or sentence boundaries when multiple items are detected.

- **MIRROR**: Service class style from `audio_recorder_service.dart:11` -- plain Dart class, no Flutter dependencies.
- **IMPORTS**: Import `EntryType` from `data/models/health_journal_entry.dart:6`.
- **GOTCHA**: This is a heuristic parser for MVP. Keep it simple. If the transcription is a single thought (e.g., "took creatine"), produce one entry. If it has conjunctions ("took creatine and had salmon"), produce two.
- **GOTCHA**: Do NOT import any Flutter or Riverpod -- this is a pure Dart domain service.
- **VALIDATE**: Write at least 3 unit tests in `test/features/check_in/domain/entry_parser_service_test.dart`.

---

### Task 4: Add `getTodayEntries` to HealthJournalRepository

**File**: `lib/data/repositories/health_journal_repository.dart`

Add a convenience method that queries entries for a given user where `entry_date` is today.

```dart
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
    return Left(CacheFailure(message: "Failed to get today's entries: \$e"));
  }
}
```

- **MIRROR**: Exact same structure as `getEntries` at lines 55-88. Same try/catch, same `Right(entries)` / `Left(CacheFailure(...))`.
- **IMPORTS**: No new imports needed -- `Right`, `Left`, `CacheFailure`, `AppLogger` are already imported.
- **GOTCHA**: SQLite string comparison on ISO8601 dates works correctly because ISO8601 is lexicographically sortable. The `entry_date` column stores ISO8601 strings (see `toDbMap()` at `health_journal_entry.dart:40`).
- **VALIDATE**: `flutter analyze` passes. The method signature matches the `Result<List<HealthJournalEntry>>` return type convention.

---

### Task 5: Create the CheckInRecordingButton widget

**File**: `lib/features/check_in/presentation/widgets/check_in_recording_button.dart` (CREATE)

A large, prominent mic button with pulsing animation and duration display. This mirrors the existing `RecordingButton` but is visually larger (120x120 vs 80x80) and triggers the check-in confirmation flow after recording stops.

Key differences from `RecordingButton`:
- Size: 120x120 circle
- After stop, calls back with `RecordingResult` instead of silently saving
- The parent widget handles what happens after recording (show confirmation sheet)

- **MIRROR**: `RecordingButton` at `recording_button.dart:1-182`. Copy the `ConsumerStatefulWidget` + `SingleTickerProviderStateMixin` pattern, `AnimationController` with repeat(reverse: true), `_toggleRecording` logic.
- **IMPORTS**: `AudioRecorderService` from `../../voice_notes/domain/audio_recorder_service.dart`, `AppColors`, `AppSpacing`.
- **GOTCHA**: Use `ref.read(audioRecorderServiceProvider)` not `ref.watch` for the recorder service -- same as `recording_button.dart:63`.
- **GOTCHA**: The `AnimatedBuilder` at `recording_button.dart:138` is likely meant to be `AnimatedBuilder` (which is `AnimatedWidget`). Verify this compiles; it may need to be `AnimatedBuilder` or `ListenableBuilder`.
- **VALIDATE**: Widget renders in isolation with no errors. Test by hot-reloading.

---

### Task 6: Create EntryTypeChip widget

**File**: `lib/features/check_in/presentation/widgets/entry_type_chip.dart` (CREATE)

A small colored chip for each `EntryType` used in the "or log manually" section. Tapping a chip opens the manual entry bottom sheet.

```dart
class EntryTypeChip extends StatelessWidget {
  const EntryTypeChip({
    super.key,
    required this.entryType,
    required this.onTap,
  });

  final EntryType entryType;
  final VoidCallback onTap;

  IconData get _icon => switch (entryType) {
    EntryType.meal => Icons.restaurant,
    EntryType.supplement => Icons.medication,
    EntryType.symptom => Icons.warning_amber,
    EntryType.exercise => Icons.fitness_center,
    EntryType.sleep => Icons.bedtime,
    EntryType.mood => Icons.mood,
    EntryType.note => Icons.note,
  };

  Color get _color => switch (entryType) {
    EntryType.meal => AppColors.nutrition,
    EntryType.supplement => AppColors.supplements,
    EntryType.symptom => AppColors.error,
    EntryType.exercise => AppColors.exercise,
    EntryType.sleep => AppColors.sleep,
    EntryType.mood => AppColors.mental,
    EntryType.note => AppColors.textSecondary,
  };
}
```

- **MIRROR**: `QuickActionButton` pattern at `quick_action_button.dart:5-57` -- `Card` + `InkWell` + icon + label.
- **IMPORTS**: `EntryType` from `data/models/health_journal_entry.dart`, `AppColors`, `AppSpacing`.
- **GOTCHA**: Dart 3 switch expressions (as shown above) require SDK `>=3.0.0`. The project targets `>=3.2.0` (see `pubspec.yaml:7`), so this is safe.
- **VALIDATE**: All 7 entry types have an icon and color mapping. No `default` needed because the switch is exhaustive.

---

### Task 7: Create ManualEntrySheet widget

**File**: `lib/features/check_in/presentation/widgets/manual_entry_sheet.dart` (CREATE)

A bottom sheet with a `TextField` and the pre-selected `EntryType` chip displayed. User types free text, taps "Save", and a single `HealthJournalEntry` is created.

- **MIRROR**: Use `showModalBottomSheet` with `isScrollControlled: true` and `DraggableScrollableSheet` for consistent Material 3 feel. Style the TextField using `InputDecorationTheme` from `app_theme.dart:45-59`.
- **IMPORTS**: `HealthJournalRepository`, `EntryType`, `AppColors`, `AppSpacing`.
- **GOTCHA**: Wrap content in `Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom))` to avoid keyboard overlap.
- **VALIDATE**: Sheet opens, keyboard appears, text can be entered, sheet dismisses on save.

---

### Task 8: Create ConfirmCheckInSheet widget

**File**: `lib/features/check_in/presentation/widgets/confirm_check_in_sheet.dart` (CREATE)

A bottom sheet shown after voice transcription completes. Displays:
1. Raw transcription text (editable)
2. Parsed entries list (each with icon, type label, content, and a delete `[x]` button)
3. "Cancel" and "Confirm & Save" buttons

On confirm, creates one `HealthJournalEntry` per parsed entry via the repository, then refreshes the today-entries list.

- **MIRROR**: Card layout from `VoiceNoteCard` at `voice_note_card.dart:66-199` for each parsed entry row.
- **IMPORTS**: `EntryParserService`, `HealthJournalRepository`, `HealthJournalEntry`, `EntryType`, `AppColors`, `AppSpacing`.
- **GOTCHA**: Use `Navigator.pop(context, true)` to signal confirmation back to the parent, so the parent can refresh providers. Do not call `ref.invalidate` inside the sheet itself.
- **GOTCHA**: If the parser produces zero entries (unrecognizable text), fall back to a single `EntryType.note` entry with the full transcription as content.
- **VALIDATE**: Sheet renders with at least one parsed entry for any non-empty transcription.

---

### Task 9: Create TodayEntriesList widget

**File**: `lib/features/check_in/presentation/widgets/today_entries_list.dart` (CREATE)

A `SliverList` showing today's `HealthJournalEntry` items, grouped by nothing (flat chronological list). Each row shows:
- Colored icon for `EntryType`
- Content text (truncated to 2 lines)
- Time (formatted with `intl` DateFormat `'h:mm a'`)

- **MIRROR**: `SliverList` + `SliverChildListDelegate` pattern from `home_page.dart:203-230`. Card style from `VoiceNoteCard`.
- **IMPORTS**: `intl` (already a dependency), `HealthJournalEntry`, `EntryType`, `AppColors`, `AppSpacing`.
- **GOTCHA**: When today's entries are empty, show an encouraging empty state: "No check-ins yet today. Start your first one above!"
- **VALIDATE**: Renders correctly with 0, 1, and 5+ entries.

---

### Task 10: Create the CheckInPage

**File**: `lib/features/check_in/presentation/pages/check_in_page.dart` (CREATE)

The main screen assembling all widgets:

```
Scaffold
  body: SafeArea
    CustomScrollView
      SliverAppBar (floating, title: "Check In", action: history icon)
      SliverToBoxAdapter: greeting + "What did you do today?"
      SliverToBoxAdapter: CheckInRecordingButton (centered)
      SliverToBoxAdapter: "-- or log manually --" divider
      SliverToBoxAdapter: Wrap of EntryTypeChip widgets (6 types, no 'note')
      SliverToBoxAdapter: "Today's Check-ins (N)" header
      TodayEntriesList (sliver)
      SliverToBoxAdapter: SizedBox(height: 100) bottom padding
```

Flow after recording stops:
1. Transcription runs (reuse `TranscriptionService` via provider)
2. Parse transcription with `EntryParserService`
3. Show `ConfirmCheckInSheet`
4. On confirm, batch-create entries
5. Invalidate `todayEntriesProvider` to refresh list

Flow for manual entry:
1. Tap an `EntryTypeChip`
2. Show `ManualEntrySheet` with that type pre-selected
3. On save, create single entry
4. Invalidate `todayEntriesProvider`

- **MIRROR**: `VoiceNotesPage` at `voice_notes_page.dart:10-146` for overall page structure. `HomePage` at `home_page.dart:13-272` for `CustomScrollView` + `SliverAppBar` pattern.
- **IMPORTS**: All check-in widgets, providers, `AppColors`, `AppSpacing`, `Routes`.
- **GOTCHA**: Use `static const String _userId = 'demo_user'` to match the hardcoded pattern in `voice_notes_page.dart:14`. Auth is not implemented yet.
- **GOTCHA**: After recording stops, show a loading indicator while transcription runs. Use a local `_isTranscribing` state boolean.
- **GOTCHA**: The `TranscriptionService` needs the audio file path. Get it from `RecordingResult.path` returned by `AudioRecorderService.stopRecording()`.
- **VALIDATE**: Full flow: tap mic -> record 3s -> tap stop -> see transcription -> see parsed entries -> confirm -> see entry appear in today's list.

---

### Task 11: Register the route in GoRouter

**File**: `lib/core/router/app_router.dart`

Add import and GoRoute inside the ShellRoute.routes list. Position it after the `home` route (index 1 position, replacing voice-notes as the second tab).

```dart
import '../../features/check_in/presentation/pages/check_in_page.dart';

// Inside ShellRoute.routes, after the home GoRoute:
GoRoute(
  path: Routes.checkIn,
  name: Routes.checkInName,
  pageBuilder: (context, state) => const NoTransitionPage(
    child: CheckInPage(),
  ),
),
```

- **MIRROR**: Exact pattern from lines 22-28 (`home` route).
- **IMPORTS**: `check_in_page.dart` import at top of file.
- **GOTCHA**: Keep the existing `voiceNotes` route in place -- it is still reachable directly but no longer in the bottom nav. Users who bookmarked `/voice-notes` should still be able to navigate there.
- **VALIDATE**: `flutter analyze` passes. App starts without routing errors.

---

### Task 12: Update MainScaffold bottom navigation

**File**: `lib/core/widgets/main_scaffold.dart`

Replace the Voice Notes tab (index 1) with Check-in. Update `_calculateSelectedIndex` and `_onItemTapped` accordingly.

Changes:
1. In `_calculateSelectedIndex`: change `Routes.voiceNotes` check to `Routes.checkIn`
2. In `_onItemTapped`: change `case 1` to navigate to `Routes.checkIn`
3. In `NavigationBar.destinations`: replace mic icon/label with check-in icon/label

```dart
// Destination at index 1:
NavigationDestination(
  icon: Icon(Icons.add_circle_outline),
  selectedIcon: Icon(Icons.add_circle, color: AppColors.primary),
  label: 'Check-in',
),
```

- **MIRROR**: Existing destination pattern at lines 51-77.
- **IMPORTS**: `Routes` is already imported.
- **GOTCHA**: The `_calculateSelectedIndex` uses `location.startsWith(Routes.voiceNotes)`. Change this to `Routes.checkIn`. If Voice Notes page is accessed directly (not via tab), it will not highlight any tab -- this is acceptable.
- **VALIDATE**: Tapping the Check-in tab navigates to `/check-in`. The icon highlights correctly.

---

### Task 13: Rewire Home Page quick actions

**File**: `lib/features/home/presentation/pages/home_page.dart`

Change the `onTap` callbacks for "Voice Note" and "Log Meal" quick action buttons to navigate to `/check-in` instead of `/voice-notes`.

```dart
// Line 116: Change Routes.voiceNotes to Routes.checkIn
onTap: () => context.go(Routes.checkIn),

// Line 125: Change Routes.voiceNotes to Routes.checkIn
onTap: () => context.go(Routes.checkIn),
```

Also update the labels:
- "Voice Note" -> "Check In" (with mic icon kept)
- "Log Meal" -> "Log Meal" (keep as-is, still goes to check-in)

- **MIRROR**: Same `context.go(Routes.xxx)` pattern.
- **IMPORTS**: `Routes` is already imported.
- **GOTCHA**: The "Supplements" button at line 134 should stay pointing to `Routes.catalog` for now.
- **VALIDATE**: Tapping "Check In" and "Log Meal" on the home page both navigate to the check-in screen.

---

## Testing Strategy

### Unit Tests

| Test File | What It Tests |
|-----------|---------------|
| `test/features/check_in/domain/entry_parser_service_test.dart` | Keyword parsing: single supplement, single meal, multi-entry with "and", symptom detection, fallback to note type, empty string handling |
| `test/data/repositories/health_journal_repository_test.dart` | `getTodayEntries` returns only today's entries (mock DatabaseHelper) |

### Widget Tests

| Test File | What It Tests |
|-----------|---------------|
| `test/features/check_in/presentation/widgets/entry_type_chip_test.dart` | All 7 entry types render correct icon and color, onTap fires |
| `test/features/check_in/presentation/widgets/today_entries_list_test.dart` | Empty state message, populated list renders correct count |

### Integration / Manual Tests

| Scenario | Steps | Expected |
|----------|-------|----------|
| Voice check-in happy path | Open app -> tap Check-in tab -> tap mic -> speak "took creatine" -> tap stop -> wait for transcription -> confirm | Entry appears in today's list as supplement type |
| Manual check-in | Open app -> Check-in tab -> tap Meal chip -> type "grilled chicken" -> save | Entry appears in today's list as meal type |
| Multiple parsed entries | Record "took magnesium and had oatmeal for breakfast" | Confirmation sheet shows 2 entries: supplement + meal |
| Empty transcription fallback | Record silence or very short clip | Either transcription fails gracefully or creates a note-type entry |
| Navigation from home | Tap "Check In" on home page | Navigates to check-in screen, tab is highlighted |
| Today's entries persistence | Create 3 entries -> leave check-in tab -> return | All 3 entries still visible |

---

## Validation Commands

```bash
# Static analysis -- must pass with zero issues
flutter analyze

# Run all unit tests
flutter test test/features/check_in/

# Run full test suite to check for regressions
flutter test

# Build check (no compile errors)
flutter build apk --debug

# Generate Freezed/JSON code if any models were added (none in Phase 1)
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Dependency Graph

```
Task 1 (routes.dart)
  |
  +---> Task 11 (app_router.dart) ---> Task 12 (main_scaffold.dart) ---> Task 13 (home_page.dart)
  |
Task 3 (EntryParserService)
  |
  +---> Task 8 (ConfirmCheckInSheet)
  |
Task 4 (getTodayEntries)
  |
  +---> Task 2 (CheckInProvider)
          |
          +---> Task 9 (TodayEntriesList)
          |
          +---> Task 10 (CheckInPage) -- assembles everything
                  |
                  +---> Task 5 (CheckInRecordingButton)
                  +---> Task 6 (EntryTypeChip)
                  +---> Task 7 (ManualEntrySheet)
                  +---> Task 8 (ConfirmCheckInSheet)
                  +---> Task 9 (TodayEntriesList)
```

**Recommended implementation order**: 1 -> 4 -> 3 -> 2 -> 5 -> 6 -> 7 -> 8 -> 9 -> 10 -> 11 -> 12 -> 13

---

## Risk Mitigations

| Risk | Mitigation |
|------|------------|
| `AnimatedBuilder` may not exist in current Flutter version | Check if it should be `AnimatedBuilder` vs `ListenableBuilder`. The existing `recording_button.dart:137` uses it, so if it compiles there, copy it exactly. |
| Transcription takes >5 seconds, user thinks app is frozen | Show a shimmer/loading animation and "Transcribing..." text during the wait. Add a 30-second timeout. |
| `userId = 'demo_user'` makes entries non-separable | Acceptable for beta. Document as known limitation. Will be resolved when auth (PRD future) is implemented. |
| `getTodayEntries` string-compares ISO8601 dates in SQLite | This works because ISO8601 format is lexicographically ordered. Tested pattern used in production SQLite apps. |
| Parser produces wrong entry types | The confirmation sheet allows manual correction before save. Users can delete mis-parsed entries and re-add manually. |

---

*Generated: 2026-02-26*
*PRD: 10-syntropy-mobile-checkin.prd.md*
*Phase: 1 -- Check-in UX Redesign*
*Status: READY FOR IMPLEMENTATION*
