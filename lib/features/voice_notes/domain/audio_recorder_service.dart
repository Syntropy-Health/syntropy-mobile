import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/logger.dart';

enum RecordingState { idle, recording, paused, stopped }

class AudioRecorderService {
  AudioRecorderService() : _recorder = AudioRecorder();

  final AudioRecorder _recorder;
  final _uuid = const Uuid();

  String? _currentPath;
  DateTime? _recordingStartTime;
  RecordingState _state = RecordingState.idle;

  RecordingState get state => _state;
  String? get currentPath => _currentPath;

  Duration get recordingDuration {
    if (_recordingStartTime == null) return Duration.zero;
    return DateTime.now().difference(_recordingStartTime!);
  }

  Future<bool> hasPermission() async {
    return _recorder.hasPermission();
  }

  Future<String?> startRecording() async {
    try {
      if (!await hasPermission()) {
        AppLogger.warning('Microphone permission denied', 'AudioRecorder');
        return null;
      }

      final directory = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${directory.path}/voice_notes');
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }

      final fileName = 'voice_note_${_uuid.v4()}.m4a';
      _currentPath = '${audioDir.path}/$fileName';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentPath!,
      );

      _state = RecordingState.recording;
      _recordingStartTime = DateTime.now();

      AppLogger.info('Started recording: $_currentPath', 'AudioRecorder');
      return _currentPath;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to start recording', 'AudioRecorder', e, stackTrace);
      _state = RecordingState.idle;
      return null;
    }
  }

  Future<void> pauseRecording() async {
    if (_state != RecordingState.recording) return;

    try {
      await _recorder.pause();
      _state = RecordingState.paused;
      AppLogger.info('Paused recording', 'AudioRecorder');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to pause recording', 'AudioRecorder', e, stackTrace);
    }
  }

  Future<void> resumeRecording() async {
    if (_state != RecordingState.paused) return;

    try {
      await _recorder.resume();
      _state = RecordingState.recording;
      AppLogger.info('Resumed recording', 'AudioRecorder');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to resume recording', 'AudioRecorder', e, stackTrace);
    }
  }

  Future<RecordingResult?> stopRecording() async {
    if (_state == RecordingState.idle) return null;

    try {
      final path = await _recorder.stop();
      final duration = recordingDuration;

      _state = RecordingState.stopped;
      final result = RecordingResult(
        path: path ?? _currentPath!,
        duration: duration,
      );

      AppLogger.info(
        'Stopped recording: ${result.path} (${result.duration.inSeconds}s)',
        'AudioRecorder',
      );

      _currentPath = null;
      _recordingStartTime = null;
      _state = RecordingState.idle;

      return result;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to stop recording', 'AudioRecorder', e, stackTrace);
      _state = RecordingState.idle;
      return null;
    }
  }

  Future<void> cancelRecording() async {
    try {
      await _recorder.stop();

      if (_currentPath != null) {
        final file = File(_currentPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      _currentPath = null;
      _recordingStartTime = null;
      _state = RecordingState.idle;

      AppLogger.info('Cancelled recording', 'AudioRecorder');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to cancel recording', 'AudioRecorder', e, stackTrace);
    }
  }

  Stream<Amplitude> get amplitudeStream {
    return _recorder.onAmplitudeChanged(const Duration(milliseconds: 100));
  }

  Future<void> dispose() async {
    await _recorder.dispose();
  }
}

class RecordingResult {
  const RecordingResult({
    required this.path,
    required this.duration,
  });

  final String path;
  final Duration duration;
}
