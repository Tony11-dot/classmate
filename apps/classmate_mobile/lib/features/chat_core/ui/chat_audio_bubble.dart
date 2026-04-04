import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class ChatAudioBubble extends StatefulWidget {
  const ChatAudioBubble({
    super.key,
    required this.url,
    this.durationSeconds,
    this.isUnread = false,
    this.onPlayed,
  });

  final String url;
  final int? durationSeconds;
  final bool isUnread;
  final VoidCallback? onPlayed;

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
  bool _playedOnce = false;
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
        _duration = value ?? _fallbackDuration;
      });
    });

    _player.playerStateStream.listen((state) async {
      if (!mounted) return;

      if (state.playing && !_playedOnce) {
        _playedOnce = true;
        widget.onPlayed?.call();
      }

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

  Duration get _fallbackDuration =>
      Duration(seconds: math.max(0, widget.durationSeconds ?? 0));

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
      if (_duration == Duration.zero && _fallbackDuration > Duration.zero) {
        _duration = _fallbackDuration;
      }
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

  Widget _waveBar(BuildContext context, int index, double progress) {
    final active = index / 20.0 <= progress;
    final baseHeights = <double>[6, 10, 14, 18, 12, 8, 16, 11, 15, 9];
    final h = baseHeights[index % baseHeights.length];
    final scheme = Theme.of(context).colorScheme;
    final color = active
        ? scheme.primary
        : Colors.white.withValues(alpha: widget.isUnread ? 0.78 : 0.40);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 3,
      height: h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  @override
  void dispose() {
    _registry.remove(this);
    _player.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final resolvedDuration = _duration > Duration.zero
        ? _duration
        : _fallbackDuration;
    final totalMs = resolvedDuration.inMilliseconds <= 0
        ? 1
        : resolvedDuration.inMilliseconds;
    final posMs = _position.inMilliseconds.clamp(0, totalMs);
    final progress = posMs / totalMs;
    final unreadDot = widget.isUnread && !_playedOnce && !_isPlaying;

    final speedChip = InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: _cycleVoiceSpeed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          speedLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );

    final timeRow = Row(
      children: [
        Flexible(
          child: Text(
            _fmt(_position),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.70),
              fontSize: 10,
              fontWeight: unreadDot ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              _fmt(resolvedDuration),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.70),
                fontSize: 10,
                fontWeight: unreadDot ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: unreadDot ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: unreadDot
                    ? Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.45)
                    : Colors.white.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                            width: 14,
                            height: 14,
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
                if (unreadDot)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final usableWidth = constraints.maxWidth.clamp(48.0, 10000.0);
                          final barCount = math.max(10, (usableWidth / 6).floor());

                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTapDown: (details) {
                              final box = context.findRenderObject() as RenderBox?;
                              if (box == null) return;
                              final local = box.globalToLocal(details.globalPosition);
                              final ratio =
                                  (local.dx / math.max(1, box.size.width)).clamp(0.0, 1.0);
                              _seekToRatio(ratio);
                            },
                            child: SizedBox(
                              height: 22,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: List.generate(
                                  barCount,
                                  (index) => Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 1),
                                    child: _waveBar(context, index, progress),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      timeRow,
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 0,
                  child: speedChip,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
