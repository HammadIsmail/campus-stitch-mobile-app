import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/theme/app_colors.dart';
import '../services/chat_service.dart';

class VoiceRecorderBar extends StatefulWidget {
  final Function(String filePath, String duration, List<double> waveformPeaks) onSendVoice;
  final VoidCallback onCancel;
  final VoidCallback onPermissionDenied;

  const VoiceRecorderBar({
    super.key,
    required this.onSendVoice,
    required this.onCancel,
    required this.onPermissionDenied,
  });

  @override
  State<VoiceRecorderBar> createState() => _VoiceRecorderBarState();
}

class _VoiceRecorderBarState extends State<VoiceRecorderBar> with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _seconds = 0;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _seconds++);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String get _formattedDuration {
    final mins = _seconds ~/ 60;
    final secs = _seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _handleStopAndSend() async {
    _timer?.cancel();
    final result = await ChatService.stopRecording();
    if (result != null && mounted) {
      final path = result['path'] as String;
      final dur = result['duration'] as String;
      final peaks = result['waveformPeaks'] as List<double>;
      widget.onSendVoice(path, dur, peaks);
    } else {
      widget.onCancel();
    }
  }

  Future<void> _handleCancel() async {
    _timer?.cancel();
    await ChatService.cancelRecording();
    widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Blinking recording dot
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.danger.withValues(alpha: 0.4 + _pulseController.value * 0.6),
                ),
              );
            },
          ),
          const SizedBox(width: 8),

          // Duration Timer
          Text(
            _formattedDuration,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 12),

          // Waveform animation preview
          Expanded(
            child: SizedBox(
              height: 20,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(14, (i) {
                      final h = 4.0 + ((i + (_pulseController.value * 5)) % 6) * 2.5;
                      return Container(
                        width: 2.5,
                        height: h,
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Cancel Action
          GestureDetector(
            onTap: _handleCancel,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                LucideIcons.trash2,
                size: 20,
                color: colors.danger,
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Send Action
          GestureDetector(
            onTap: _handleStopAndSend,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                LucideIcons.send,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
