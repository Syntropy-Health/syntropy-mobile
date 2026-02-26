import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/voice_note.dart';
import '../../domain/audio_recorder_service.dart';
import '../providers/voice_notes_provider.dart';

class RecordingButton extends ConsumerStatefulWidget {
  const RecordingButton({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  ConsumerState<RecordingButton> createState() => _RecordingButtonState();
}

class _RecordingButtonState extends ConsumerState<RecordingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Timer? _durationTimer;
  Duration _recordingDuration = Duration.zero;
  RecordingState _state = RecordingState.idle;
  VoiceNote? _currentNote;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _durationTimer?.cancel();
    super.dispose();
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _recordingDuration = Duration.zero;
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration = Duration(seconds: timer.tick);
      });
    });
  }

  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  Future<void> _toggleRecording() async {
    final controller = ref.read(
      voiceNotesControllerProvider(widget.userId).notifier,
    );

    if (_state == RecordingState.idle) {
      // Start recording
      setState(() => _state = RecordingState.recording);
      _startDurationTimer();

      final note = await controller.startRecording();
      if (note != null) {
        _currentNote = note;
      } else {
        setState(() => _state = RecordingState.idle);
        _stopDurationTimer();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to start recording')),
          );
        }
      }
    } else if (_state == RecordingState.recording) {
      // Stop recording
      setState(() => _state = RecordingState.idle);
      _stopDurationTimer();

      if (_currentNote != null) {
        final transcribed = await controller.stopRecording(_currentNote!);
        _currentNote = null;

        if (mounted && transcribed != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                transcribed.transcriptionStatus == TranscriptionStatus.completed
                    ? 'Transcription complete'
                    : 'Recording saved, transcription pending',
              ),
            ),
          );
        }
      }
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = _state == RecordingState.recording;

    return Column(
      children: [
        // Duration display
        AnimatedOpacity(
          opacity: isRecording ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Text(
            _formatDuration(_recordingDuration),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
          ),
        ),
        const SizedBox(height: 16),

        // Record button
        GestureDetector(
          onTap: _toggleRecording,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRecording
                      ? AppColors.error.withOpacity(
                          0.8 + (_animationController.value * 0.2),
                        )
                      : AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: (isRecording ? AppColors.error : AppColors.primary)
                          .withOpacity(0.3),
                      blurRadius: isRecording
                          ? 20 + (_animationController.value * 10)
                          : 10,
                      spreadRadius: isRecording
                          ? 5 + (_animationController.value * 5)
                          : 0,
                    ),
                  ],
                ),
                child: Icon(
                  isRecording ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 36,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Status text
        Text(
          isRecording ? 'Tap to stop' : 'Tap to record',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
