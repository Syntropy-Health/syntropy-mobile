import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../data/datasources/remote/health_analysis_service.dart';
import '../../../../data/models/health_journal_entry.dart';
import '../../../../data/models/health_recommendation.dart';

// Health Analysis Service Provider
final healthAnalysisServiceProvider = Provider<HealthAnalysisService>((ref) {
  return HealthAnalysisService();
});

// Recommendations Provider
final recommendationsProvider = FutureProvider.autoDispose
    .family<List<HealthRecommendation>, String>((ref, userId) async {
  // Repository may be null on web
  final _ = ref.watch(healthJournalRepositoryProvider);

  // For now, return empty list - would fetch from local DB
  // In production, would query health_recommendations table
  return [];
});

// Unprocessed Entries Provider
final unprocessedEntriesProvider =
    FutureProvider.autoDispose<List<HealthJournalEntry>>((ref) async {
  final repository = ref.watch(healthJournalRepositoryProvider);
  if (repository == null) return []; // Not available on web
  final result = await repository.getUnprocessedEntries();
  return result.fold(
    (failure) => [],
    (entries) => entries,
  );
});

// Health Analysis Controller
class HealthAnalysisController
    extends StateNotifier<AsyncValue<List<HealthRecommendation>>> {
  HealthAnalysisController({
    required this.analysisService,
    required this.userId,
  }) : super(const AsyncValue.data([]));

  final HealthAnalysisService analysisService;
  final String userId;

  Future<void> analyzeEntry(HealthJournalEntry entry) async {
    state = const AsyncValue.loading();

    final result = await analysisService.analyzeHealthEntry(
      entry.id,
      entry.content,
      entry.entryType.name,
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure.message ?? 'Analysis failed', StackTrace.current),
      (recommendations) => AsyncValue.data(recommendations),
    );
  }

  Future<void> analyzeSymptoms(List<String> symptoms) async {
    state = const AsyncValue.loading();

    final result = await analysisService.getSymptomAnalysis(symptoms);

    // Convert result to recommendations
    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message ?? 'Analysis failed', StackTrace.current);
      },
      (data) {
        // Parse recommendations from API response
        final recommendations = <HealthRecommendation>[];
        // Would parse actual response here
        state = AsyncValue.data(recommendations);
      },
    );
  }

  void dismissRecommendation(String id) {
    state.whenData((recommendations) {
      state = AsyncValue.data(
        recommendations.where((r) => r.id != id).toList(),
      );
    });
  }

  void markAsActioned(String id) {
    state.whenData((recommendations) {
      state = AsyncValue.data(
        recommendations.map((r) {
          if (r.id == id) {
            return r.copyWith(isActioned: true);
          }
          return r;
        }).toList(),
      );
    });
  }
}

final healthAnalysisControllerProvider = StateNotifierProvider.autoDispose
    .family<HealthAnalysisController, AsyncValue<List<HealthRecommendation>>,
        String>(
  (ref, userId) {
    return HealthAnalysisController(
      analysisService: ref.watch(healthAnalysisServiceProvider),
      userId: userId,
    );
  },
);
