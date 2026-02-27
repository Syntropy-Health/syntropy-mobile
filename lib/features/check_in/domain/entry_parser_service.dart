import '../../../data/models/health_journal_entry.dart';

class ParsedEntry {
  const ParsedEntry({
    required this.entryType,
    required this.content,
  });

  final EntryType entryType;
  final String content;
}

class EntryParserService {
  static const _supplementKeywords = [
    'took',
    'supplement',
    'creatine',
    'magnesium',
    'vitamin',
    'zinc',
    'omega',
    'probiotic',
    'collagen',
    'iron',
    'calcium',
    'ashwagandha',
    'melatonin',
    'fish oil',
    'capsule',
    'pill',
    'tablet',
  ];

  static const _mealKeywords = [
    'ate',
    'had',
    'meal',
    'lunch',
    'dinner',
    'breakfast',
    'salad',
    'chicken',
    'snack',
    'drank',
    'coffee',
    'tea',
    'smoothie',
    'rice',
    'eggs',
    'toast',
    'yogurt',
    'fruit',
    'steak',
    'salmon',
    'pasta',
    'soup',
    'sandwich',
    'oatmeal',
    'protein shake',
  ];

  static const _symptomKeywords = [
    'feel',
    'headache',
    'pain',
    'nausea',
    'tired',
    'symptom',
    'ache',
    'sore',
    'dizzy',
    'bloated',
    'cramp',
    'fatigue',
    'inflammation',
    'rash',
    'allergy',
    'congestion',
  ];

  static const _sleepKeywords = [
    'slept',
    'sleep',
    'hours of sleep',
    'woke up',
    'nap',
    'insomnia',
    'bedtime',
    'rest',
  ];

  static const _exerciseKeywords = [
    'ran',
    'walk',
    'exercise',
    'workout',
    'gym',
    'lifted',
    'jogged',
    'cycling',
    'swimming',
    'yoga',
    'hiked',
    'pushups',
    'squats',
    'cardio',
    'stretch',
    'training',
  ];

  static const _moodKeywords = [
    'mood',
    'happy',
    'anxious',
    'stressed',
    'calm',
    'sad',
    'excited',
    'frustrated',
    'grateful',
    'energized',
    'depressed',
    'motivated',
    'relaxed',
  ];

  /// Parses raw transcription text into a list of [ParsedEntry] objects.
  ///
  /// Splits on "and", commas, or sentence boundaries when multiple items
  /// are detected. Falls back to [EntryType.note] if no keywords match.
  List<ParsedEntry> parse(String transcription) {
    if (transcription.trim().isEmpty) {
      return [];
    }

    final segments = _splitIntoSegments(transcription);
    final entries = <ParsedEntry>[];

    for (final segment in segments) {
      final trimmed = segment.trim();
      if (trimmed.isEmpty) continue;

      final entryType = _classifySegment(trimmed);
      entries.add(
        ParsedEntry(
          entryType: entryType,
          content: trimmed,
        ),
      );
    }

    // If no entries were produced, fall back to a single note
    if (entries.isEmpty) {
      entries.add(
        ParsedEntry(
          entryType: EntryType.note,
          content: transcription.trim(),
        ),
      );
    }

    return entries;
  }

  List<String> _splitIntoSegments(String text) {
    // Split on " and ", commas, or periods (sentence boundaries)
    // but only if the result has meaningful content on both sides
    final segments = text
        .split(RegExp(r'\s+and\s+|,\s*|\.\s+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    // If splitting produced only one segment, return it as-is
    if (segments.length <= 1) {
      return [text.trim()];
    }

    return segments;
  }

  EntryType _classifySegment(String segment) {
    final lower = segment.toLowerCase();

    if (_matchesAny(lower, _supplementKeywords)) return EntryType.supplement;
    if (_matchesAny(lower, _mealKeywords)) return EntryType.meal;
    if (_matchesAny(lower, _symptomKeywords)) return EntryType.symptom;
    if (_matchesAny(lower, _sleepKeywords)) return EntryType.sleep;
    if (_matchesAny(lower, _exerciseKeywords)) return EntryType.exercise;
    if (_matchesAny(lower, _moodKeywords)) return EntryType.mood;

    return EntryType.note;
  }

  bool _matchesAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }
}
