import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../../../core/utils/failure.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/result.dart';

class TranscriptionService {
  static const String _whisperEndpoint =
      'https://api.openai.com/v1/audio/transcriptions';

  Future<Result<String>> transcribeAudio(String audioPath) async {
    try {
      final apiKey = AppConfig.instance.openAiApiKey;
      if (apiKey.isEmpty) {
        return Left(TranscriptionFailure(
          message: 'OpenAI API key not configured',
        ));
      }

      final file = File(audioPath);
      if (!await file.exists()) {
        return Left(TranscriptionFailure(
          message: 'Audio file not found',
        ));
      }

      final request = http.MultipartRequest('POST', Uri.parse(_whisperEndpoint))
        ..headers['Authorization'] = 'Bearer $apiKey'
        ..fields['model'] = 'whisper-1'
        ..fields['language'] = 'en'
        ..files.add(await http.MultipartFile.fromPath('file', audioPath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final transcription = data['text'] as String;
        AppLogger.info(
          'Transcription successful: ${transcription.length} chars',
          'TranscriptionService',
        );
        return Right(transcription);
      } else {
        AppLogger.error(
          'Transcription failed: ${response.statusCode}',
          'TranscriptionService',
        );
        return Left(TranscriptionFailure(
          message: 'Transcription failed: ${response.statusCode}',
        ));
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Transcription error',
        'TranscriptionService',
        e,
        stackTrace,
      );
      return Left(TranscriptionFailure(
        message: 'Transcription error: $e',
      ));
    }
  }
}
