import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_recommendation.freezed.dart';
part 'health_recommendation.g.dart';

enum RecommendationType { nutrition, supplement, lifestyle, exercise, sleep }

enum Priority { low, medium, high, urgent }

@freezed
class HealthRecommendation with _$HealthRecommendation {
  const factory HealthRecommendation({
    required String id,
    required String userId,
    required RecommendationType type,
    required String title,
    required String description,
    String? rationale,
    @Default(Priority.medium) Priority priority,
    List<String>? relatedSymptoms,
    List<String>? suggestedProducts,
    DateTime? createdAt,
    @Default(false) bool isDismissed,
    @Default(false) bool isActioned,
  }) = _HealthRecommendation;

  factory HealthRecommendation.fromJson(Map<String, dynamic> json) =>
      _$HealthRecommendationFromJson(json);
}

extension HealthRecommendationExtension on HealthRecommendation {
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'title': title,
      'description': description,
      'rationale': rationale,
      'priority': priority.name,
      'related_symptoms': relatedSymptoms?.join(','),
      'suggested_products': suggestedProducts?.join(','),
      'created_at': createdAt?.toIso8601String(),
      'is_dismissed': isDismissed ? 1 : 0,
      'is_actioned': isActioned ? 1 : 0,
    };
  }

  static HealthRecommendation fromDbMap(Map<String, dynamic> map) {
    return HealthRecommendation(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      type: RecommendationType.values.byName(map['type'] as String),
      title: map['title'] as String,
      description: map['description'] as String,
      rationale: map['rationale'] as String?,
      priority: Priority.values.byName(map['priority'] as String),
      relatedSymptoms: (map['related_symptoms'] as String?)?.split(','),
      suggestedProducts: (map['suggested_products'] as String?)?.split(','),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      isDismissed: (map['is_dismissed'] as int?) == 1,
      isActioned: (map['is_actioned'] as int?) == 1,
    );
  }
}
