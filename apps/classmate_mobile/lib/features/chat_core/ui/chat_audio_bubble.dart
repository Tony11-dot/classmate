import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class ChatAudioBubble extends StatefulWidget {
  const ChatAudioBubble({super.key, required this.url});

  final String url;

  @override
  State<ChatAudioBubble> createState() => _ChatAudioBubbleState();
}

class _ChatAudioBubbleState extends State<ChatAudioBubble> {
  final AudioPlayer _player = AudioPlayer();

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _loading = false;
  bool _ready = false;
  double _voiceSpeed = 1.0;

  @override
  void initState() {
    super.initState();

    _player.positionStream.listen((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        _position = value;
      });
    });

    _player.durationStream.listen((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        _duration = value ?? Duration.zero;
      });
    });

    _player.playerStateStream.listen((state) {
      if (!mounted) {
        return;
      }
      if (state.processingState == ProcessingState.completed) {
        _player.seek(Duration.zero);
        setState(() {
          _position = Duration.zero;
        });
      } else {
        setState(() {});
      }
    });
  }

  bool get _isPlaying => _player.playing;

  String get speedLabel {
    if (_voiceSpeed == 1.0) {
      return '1x';
    }
    if (_voiceSpeed == 1.5) {
      return '1.5x';
    }
    return '2x';
  }

  Future<void> _ensureReady() async {
    if (_ready) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await _player.setUrl(widget.url);
      await _player.setSpeed(_voiceSpeed);
      _ready = true;
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _togglePlay() async {
    try {
      await _ensureReady();
      if (_isPlaying) {
        await _player.pause();
      } else {
        if (_duration > Duration.zero &&
            _position >= _duration - const Duration(milliseconds: 250)) {
          await _player.seek(Duration.zero);
        }
        await _player.play();
      }
    } catch (_) {}
  }

  Future<void> _seekToRatio(double ratio) async {
    try {
      await _ensureReady();
      final clamped = ratio.clamp(0.0, 1.0);
      final ms = (_duration.inMilliseconds * clamped).round();
      await _player.seek(Duration(milliseconds: ms));
    } catch (_) {}
  }

  Future<void> _cycleVoiceSpeed() async {
    final next = _voiceSpeed == 1.0
        ? 1.5
        : _voiceSpeed == 1.5
        ? 2.0
        : 1.0;

    if (mounted) {
      setState(() {
        _voiceSpeed = next;
      });
    }

    try {
      await _player.setSpeed(_voiceSpeed);
    } catch (_) {}
  }

  String _fmt(Duration d) {
    final total = d.inSeconds;
    final mm = (total ~/ 60).toString().padLeft(2, '0');
    final ss = (total % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalMs = _duration.inMilliseconds <= 0
        ? 1
        : _duration.inMilliseconds;
    final posMs = _position.inMilliseconds.clamp(0, totalMs);
    final progress = posMs / totalMs;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: _loading ? null : _togglePlay,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 12,
                          ),
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: Colors.white,
                          overlayColor: Colors.white24,
                        ),
                        child: Slider(
                          value: progress.isNaN ? 0 : progress.clamp(0.0, 1.0),
                          onChanged: (v) {
                            setState(() {
                              final totalMs = _duration.inMilliseconds <= 0
                                  ? 1
                                  : _duration.inMilliseconds;
                              _position = Duration(
                                milliseconds: (totalMs * v).round(),
                              );
                            });
                          },
                          onChangeEnd: _seekToRatio,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            _fmt(_position),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _fmt(_duration),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: _cycleVoiceSpeed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              speedLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
