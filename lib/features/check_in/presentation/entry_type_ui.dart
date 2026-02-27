import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/health_journal_entry.dart';

/// UI display properties for [EntryType] values, centralised to avoid
/// duplicating the same switch-expression across multiple widgets.
extension EntryTypeUI on EntryType {
  IconData get icon => switch (this) {
        EntryType.meal => Icons.restaurant,
        EntryType.supplement => Icons.medication,
        EntryType.symptom => Icons.warning_amber,
        EntryType.exercise => Icons.fitness_center,
        EntryType.sleep => Icons.bedtime,
        EntryType.mood => Icons.mood,
        EntryType.note => Icons.note,
      };

  Color get color => switch (this) {
        EntryType.meal => AppColors.nutrition,
        EntryType.supplement => AppColors.supplements,
        EntryType.symptom => AppColors.error,
        EntryType.exercise => AppColors.exercise,
        EntryType.sleep => AppColors.sleep,
        EntryType.mood => AppColors.mental,
        EntryType.note => AppColors.textSecondary,
      };

  String get label => switch (this) {
        EntryType.meal => 'Meal',
        EntryType.supplement => 'Supplement',
        EntryType.symptom => 'Symptom',
        EntryType.exercise => 'Exercise',
        EntryType.sleep => 'Sleep',
        EntryType.mood => 'Mood',
        EntryType.note => 'Note',
      };

  /// Placeholder hint text used in the manual entry text field.
  String get hintText => switch (this) {
        EntryType.meal => 'What did you eat? e.g., grilled chicken with rice',
        EntryType.supplement => 'What did you take? e.g., creatine 5g',
        EntryType.symptom => 'What are you feeling? e.g., mild headache',
        EntryType.exercise =>
          'What exercise did you do? e.g., 30 min run',
        EntryType.sleep =>
          'How did you sleep? e.g., 7 hours, woke up rested',
        EntryType.mood => 'How are you feeling? e.g., calm and focused',
        EntryType.note => 'What would you like to note?',
      };
}
