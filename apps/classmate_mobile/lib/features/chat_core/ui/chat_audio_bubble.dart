import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class ChatAudioBubble extends StatefulWidget {
  const ChatAudioBubble({super.key, required this.url});

  final String url;

  @override
  State<ChatAudioBubble> createState() => _ChatAudioBubbleState();
}

class _ChatAudioBubbleState extends State<ChatAudioBubble> {
  static final List<_ChatAudioBubbleState> _registry =
      <_ChatAudioBubbleState>[];

  final AudioPlayer _player = AudioPlayer();

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _loading = false;
  bool _ready = false;
  double _voiceSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _registry.add(this);

    _player.setLoopMode(LoopMode.off);

    _player.positionStream.listen((value) {
      if (!mounted) return;
      setState(() {
        _position = value;
      });
    });

    _player.durationStream.listen((value) {
      if (!mounted) return;
      setState(() {
        _duration = value ?? Duration.zero;
      });
    });

    _player.playerStateStream.listen((state) async {
      if (!mounted) return;

      if (state.processingState == ProcessingState.completed) {
        try {
          await _player.pause();
          await _player.seek(Duration.zero);
          await _player.setLoopMode(LoopMode.off);
        } catch (_) {}

        if (!mounted) return;
        setState(() {
          _position = Duration.zero;
        });
        return;
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  bool get _isPlaying => _player.playing;

  String get speedLabel {
    if (_voiceSpeed == 1.0) return '1x';
    if (_voiceSpeed == 1.5) return '1.5x';
    return '2x';
  }

  Future<void> _ensureReady() async {
    if (_ready) return;

    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    try {
      await _player.setUrl(widget.url);
      await _player.setSpeed(_voiceSpeed);
      await _player.setLoopMode(LoopMode.off);
      _ready = true;
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _stopOthers() async {
    for (final bubble in List<_ChatAudioBubbleState>.from(_registry)) {
      if (identical(bubble, this)) continue;
      try {
        await bubble._player.pause();
        await bubble._player.seek(Duration.zero);
      } catch (_) {}
      if (bubble.mounted) {
        bubble.setState(() {
          bubble._position = Duration.zero;
        });
      }
    }
  }

  Future<void> _togglePlay() async {
    try {
      await _ensureReady();

      if (_isPlaying) {
        await _player.pause();
        return;
      }

      await _stopOthers();

      if (_duration > Duration.zero &&
          _position >= _duration - const Duration(milliseconds: 250)) {
        await _player.seek(Duration.zero);
      }

      await _player.setLoopMode(LoopMode.off);
      await _player.play();
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
    _registry.remove(this);
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
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: _loading ? null : _togglePlay,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
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
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2.5,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 4,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 8,
                          ),
                        ),
                        child: Slider(
                          value: progress.isNaN ? 0 : progress.clamp(0.0, 1.0),
                          onChanged: (v) async {
                            await _seekToRatio(v);
                          },
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -4),
                        child: Row(
                          children: [
                            Text(
                              _fmt(_position),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _fmt(_duration),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: _cycleVoiceSpeed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      speedLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
