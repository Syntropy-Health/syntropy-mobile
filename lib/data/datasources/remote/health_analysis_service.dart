import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../../../core/utils/failure.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/result.dart';
import '../../models/health_recommendation.dart';

class HealthAnalysisService {
  Future<Result<List<HealthRecommendation>>> analyzeHealthEntry(
    String entryId,
    String content,
    String entryType,
  ) async {
    try {
      final apiUrl = AppConfig.instance.dietInsightApiUrl;
      final endpoint = '$apiUrl/api/v1/analyze';

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'entry_id': entryId,
          'content': content,
          'entry_type': entryType,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final recommendations = (data['recommendations'] as List?)
                ?.map((r) => HealthRecommendation.fromJson(r))
                .toList() ??
            [];
        AppLogger.info(
          'Health analysis returned ${recommendations.length} recommendations',
          'HealthAnalysisService',
        );
        return Right(recommendations);
      } else {
        return Left(ServerFailure(
          message: 'Health analysis failed: ${response.statusCode}',
        ));
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Health analysis error',
        'HealthAnalysisService',
        e,
        stackTrace,
      );
      return Left(ServerFailure(message: 'Health analysis error: $e'));
    }
  }

  Future<Result<Map<String, dynamic>>> getSymptomAnalysis(
    List<String> symptoms,
  ) async {
    try {
      final apiUrl = AppConfig.instance.dietInsightApiUrl;
      final endpoint = '$apiUrl/api/v1/symptoms/analyze';

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'symptoms': symptoms}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Right(data);
      } else {
        return Left(ServerFailure(
          message: 'Symptom analysis failed: ${response.statusCode}',
        ));
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Symptom analysis error',
        'HealthAnalysisService',
        e,
        stackTrace,
      );
      return Left(ServerFailure(message: 'Symptom analysis error: $e'));
    }
  }
}
