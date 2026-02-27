import 'package:flutter_test/flutter_test.dart';
import 'package:syntropy_mobile/data/models/health_journal_entry.dart';
import 'package:syntropy_mobile/features/check_in/domain/entry_parser_service.dart';

void main() {
  late EntryParserService parser;

  setUp(() {
    parser = EntryParserService();
  });

  group('EntryParserService', () {
    test('parses single supplement entry', () {
      final entries = parser.parse('took 5g creatine');
      expect(entries.length, 1);
      expect(entries.first.entryType, EntryType.supplement);
      expect(entries.first.content, 'took 5g creatine');
    });

    test('parses single meal entry', () {
      final entries = parser.parse('had salmon salad for lunch');
      expect(entries.length, 1);
      expect(entries.first.entryType, EntryType.meal);
      expect(entries.first.content, 'had salmon salad for lunch');
    });

    test('parses multi-entry with "and" conjunction', () {
      final entries = parser.parse('took creatine and had salmon for lunch');
      expect(entries.length, 2);
      expect(entries[0].entryType, EntryType.supplement);
      expect(entries[0].content, 'took creatine');
      expect(entries[1].entryType, EntryType.meal);
      expect(entries[1].content, 'had salmon for lunch');
    });

    test('detects symptom keywords', () {
      final entries = parser.parse('I have a headache');
      expect(entries.length, 1);
      expect(entries.first.entryType, EntryType.symptom);
    });

    test('detects exercise keywords', () {
      final entries = parser.parse('went to the gym for a workout');
      expect(entries.length, 1);
      expect(entries.first.entryType, EntryType.exercise);
    });

    test('detects sleep keywords', () {
      final entries = parser.parse('slept 8 hours last night');
      expect(entries.length, 1);
      expect(entries.first.entryType, EntryType.sleep);
    });

    test('detects mood keywords', () {
      final entries = parser.parse('my mood is really happy right now');
      expect(entries.length, 1);
      expect(entries.first.entryType, EntryType.mood);
    });

    test('falls back to note type for unrecognized text', () {
      final entries = parser.parse('this is a general observation');
      expect(entries.length, 1);
      expect(entries.first.entryType, EntryType.note);
    });

    test('returns empty list for empty string', () {
      final entries = parser.parse('');
      expect(entries, isEmpty);
    });

    test('returns empty list for whitespace-only string', () {
      final entries = parser.parse('   ');
      expect(entries, isEmpty);
    });

    test('splits on commas for multiple entries', () {
      final entries = parser.parse('took magnesium, had oatmeal for breakfast');
      expect(entries.length, 2);
      expect(entries[0].entryType, EntryType.supplement);
      expect(entries[1].entryType, EntryType.meal);
    });

    test('handles complex multi-item transcription', () {
      final entries = parser.parse(
        'took magnesium and vitamin D, had oatmeal for breakfast and feeling great',
      );
      expect(entries.length, greaterThanOrEqualTo(2));
      // At least one supplement and one meal should be detected
      expect(
        entries.any((e) => e.entryType == EntryType.supplement),
        isTrue,
      );
      expect(
        entries.any((e) => e.entryType == EntryType.meal),
        isTrue,
      );
    });

    test('is case-insensitive for keyword matching', () {
      final entries = parser.parse('TOOK Creatine');
      expect(entries.length, 1);
      expect(entries.first.entryType, EntryType.supplement);
    });

    test('handles special characters gracefully', () {
      final entries = parser.parse("took creatine! & had eggs #breakfast");
      expect(entries, isNotEmpty);
      // Should not crash; at minimum produces a note
      for (final entry in entries) {
        expect(entry.content, isNotEmpty);
      }
    });

    test('trims leading and trailing whitespace from segments', () {
      final entries = parser.parse('  took creatine  and  had eggs  ');
      expect(entries.length, 2);
      expect(entries[0].content, isNot(startsWith(' ')));
      expect(entries[1].content, isNot(startsWith(' ')));
    });

    test('single word matching a keyword produces one entry', () {
      final entries = parser.parse('headache');
      expect(entries.length, 1);
      expect(entries.first.entryType, EntryType.symptom);
      expect(entries.first.content, 'headache');
    });

    test('splits on sentence-ending periods', () {
      final entries =
          parser.parse('Took magnesium. Had salmon for lunch');
      expect(entries.length, 2);
      expect(entries[0].entryType, EntryType.supplement);
      expect(entries[1].entryType, EntryType.meal);
    });

    test('supplement keywords take priority over meal keywords', () {
      // "took" is a supplement keyword, "eggs" is a meal keyword
      // When in the same segment, supplement should win because it is checked first
      final entries = parser.parse('took eggs as a supplement');
      expect(entries.length, 1);
      expect(entries.first.entryType, EntryType.supplement);
    });
  });
}
