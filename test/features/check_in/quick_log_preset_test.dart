import 'package:flutter_test/flutter_test.dart';
import 'package:syntropy_mobile/features/check_in/domain/quick_log_preset.dart';
import 'package:syntropy_mobile/data/models/health_journal_entry.dart';

void main() {
  group('QuickLogPreset', () {
    test('creates with required fields', () {
      final preset = QuickLogPreset(
        id: '1',
        userId: 'user1',
        entryType: EntryType.supplement,
        content: 'Creatine 5g',
        createdAt: DateTime(2024, 1, 1),
      );
      expect(preset.id, '1');
      expect(preset.userId, 'user1');
      expect(preset.entryType, EntryType.supplement);
      expect(preset.content, 'Creatine 5g');
      expect(preset.useCount, 0);
      expect(preset.isPinned, false);
      expect(preset.lastUsedAt, isNull);
    });

    test('displayName defaults to empty', () {
      final preset = QuickLogPreset(
        id: '1',
        userId: 'user1',
        entryType: EntryType.meal,
        content: 'Salmon salad',
        createdAt: DateTime(2024, 1, 1),
      );
      expect(preset.displayName, '');
    });

    test('serializes to JSON and back', () {
      final preset = QuickLogPreset(
        id: '1',
        userId: 'user1',
        entryType: EntryType.supplement,
        content: 'Vitamin D 5000IU',
        displayName: 'Vitamin D',
        useCount: 5,
        isPinned: true,
        createdAt: DateTime(2024, 1, 1),
      );
      final json = preset.toJson();
      final fromJson = QuickLogPreset.fromJson(json);
      expect(fromJson.id, preset.id);
      expect(fromJson.userId, preset.userId);
      expect(fromJson.entryType, preset.entryType);
      expect(fromJson.content, preset.content);
      expect(fromJson.displayName, 'Vitamin D');
      expect(fromJson.isPinned, true);
      expect(fromJson.useCount, 5);
    });

    test('serializes with lastUsedAt', () {
      final lastUsed = DateTime(2024, 6, 15, 10, 30);
      final preset = QuickLogPreset(
        id: '2',
        userId: 'user1',
        entryType: EntryType.exercise,
        content: '30min run',
        createdAt: DateTime(2024, 1, 1),
        lastUsedAt: lastUsed,
      );
      final json = preset.toJson();
      final fromJson = QuickLogPreset.fromJson(json);
      expect(fromJson.lastUsedAt, lastUsed);
    });

    test('copyWith updates fields correctly', () {
      final preset = QuickLogPreset(
        id: '1',
        userId: 'user1',
        entryType: EntryType.supplement,
        content: 'Creatine 5g',
        createdAt: DateTime(2024, 1, 1),
      );
      final updated = preset.copyWith(
        useCount: 10,
        isPinned: true,
      );
      expect(updated.useCount, 10);
      expect(updated.isPinned, true);
      expect(updated.content, 'Creatine 5g');
      expect(updated.id, '1');
    });

    test('equality works for same data', () {
      final a = QuickLogPreset(
        id: '1',
        userId: 'user1',
        entryType: EntryType.meal,
        content: 'Eggs',
        createdAt: DateTime(2024, 1, 1),
      );
      final b = QuickLogPreset(
        id: '1',
        userId: 'user1',
        entryType: EntryType.meal,
        content: 'Eggs',
        createdAt: DateTime(2024, 1, 1),
      );
      expect(a, equals(b));
    });

    test('inequality when fields differ', () {
      final a = QuickLogPreset(
        id: '1',
        userId: 'user1',
        entryType: EntryType.meal,
        content: 'Eggs',
        createdAt: DateTime(2024, 1, 1),
      );
      final b = QuickLogPreset(
        id: '2',
        userId: 'user1',
        entryType: EntryType.meal,
        content: 'Eggs',
        createdAt: DateTime(2024, 1, 1),
      );
      expect(a, isNot(equals(b)));
    });
  });
}
