import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/theme/app_colors.dart';
import '../models/chat_model.dart';

class VoiceMessageBubble extends StatefulWidget {
  final ChatMessageModel message;
  final bool isMe;

  const VoiceMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble> {
  AudioPlayer? _player;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _totalDuration = Duration.zero;
  StreamSubscription? _playerStateSub;
  StreamSubscription? _posSub;
  StreamSubscription? _durationSub;

  @override
  void initState() {
    super.initState();
    try {
      _player = AudioPlayer();
      _initAudio();
    } catch (e) {
      debugPrint('Voice audio player init notice: $e');
    }
  }

  void _initAudio() {
    if (_player == null) return;
    _playerStateSub = _player!.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing && state.processingState != ProcessingState.completed;
          if (state.processingState == ProcessingState.completed) {
            _position = Duration.zero;
          }
        });
      }
    });

    _posSub = _player!.positionStream.listen((pos) {
      if (mounted) {
        setState(() => _position = pos);
      }
    });

    _durationSub = _player!.durationStream.listen((dur) {
      if (mounted && dur != null) {
        setState(() => _totalDuration = dur);
      }
    });
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _posSub?.cancel();
    _durationSub?.cancel();
    _player?.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    try {
      if (_player == null) {
        _player = AudioPlayer();
        _initAudio();
      }
      if (_isPlaying) {
        await _player!.pause();
      } else {
        if (_player!.processingState == ProcessingState.completed) {
          await _player!.seek(Duration.zero);
        } else if (_player!.processingState == ProcessingState.idle) {
          String url = (widget.message.voiceUrl ?? '').trim();
          if (url.isEmpty) return;

          if (url.startsWith('blob%3A') || url.startsWith('blob%3a')) {
            url = 'blob:${url.substring(7)}';
          }
          try {
            url = Uri.decodeFull(url);
          } catch (_) {}

          if (kIsWeb ||
              url.startsWith('http://') ||
              url.startsWith('https://') ||
              url.startsWith('blob:') ||
              url.startsWith('data:')) {
            await _player!.setUrl(url);
          } else if (url.isNotEmpty) {
            await _player!.setFilePath(url);
          }
        }
        await _player!.play();
      }
    } catch (e) {
      debugPrint('Error toggling voice playback: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final peaks = widget.message.waveformPeaks.isNotEmpty
        ? widget.message.waveformPeaks
        : List<double>.generate(22, (i) => (0.3 + (i % 5) * 0.15).clamp(0.2, 0.9));

    final totalSecs = _totalDuration.inSeconds > 0
        ? _totalDuration.inSeconds
        : _parseDurationSeconds(widget.message.duration ?? '0:12');

    final currentSecs = _position.inSeconds;
    final progress = totalSecs > 0 ? (currentSecs / totalSecs).clamp(0.0, 1.0) : 0.0;

    final bubbleBg = widget.isMe ? colors.primary : colors.surface;
    final playBtnBg = widget.isMe ? Colors.white : colors.primary;
    final playBtnFg = widget.isMe ? colors.primary : Colors.white;
    final inactiveBarColor = widget.isMe
        ? Colors.white.withValues(alpha: 0.35)
        : colors.border;
    final activeBarColor = widget.isMe
        ? Colors.white
        : colors.primary;

    final durationLabel = _isPlaying
        ? _formatDuration(_position)
        : (widget.message.duration ?? _formatDuration(_totalDuration));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      constraints: const BoxConstraints(maxWidth: 260),
      decoration: BoxDecoration(
        color: bubbleBg,
        borderRadius: BorderRadius.circular(16).copyWith(
          bottomRight: widget.isMe ? const Radius.circular(4) : const Radius.circular(16),
          bottomLeft: !widget.isMe ? const Radius.circular(4) : const Radius.circular(16),
        ),
        border: widget.isMe ? null : Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play / Pause Button
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: playBtnBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                _isPlaying ? LucideIcons.pause : LucideIcons.play,
                size: 18,
                color: playBtnFg,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Waveform bars + duration label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 24,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(peaks.length, (index) {
                      final barProgress = index / peaks.length;
                      final isPlayed = barProgress <= progress;
                      final barHeight = (peaks[index] * 20).clamp(4.0, 22.0);

                      return Container(
                        width: 3,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: isPlayed ? activeBarColor : inactiveBarColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      durationLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: widget.isMe
                            ? Colors.white.withValues(alpha: 0.8)
                            : colors.textMuted,
                      ),
                    ),
                    Text(
                      widget.message.timeFormatted,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: widget.isMe
                            ? Colors.white.withValues(alpha: 0.6)
                            : colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _parseDurationSeconds(String durStr) {
    final parts = durStr.split(':');
    if (parts.length == 2) {
      final mins = int.tryParse(parts[0]) ?? 0;
      final secs = int.tryParse(parts[1]) ?? 0;
      return mins * 60 + secs;
    }
    return 12;
  }

  String _formatDuration(Duration d) {
    final mins = d.inMinutes;
    final secs = d.inSeconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }
}
