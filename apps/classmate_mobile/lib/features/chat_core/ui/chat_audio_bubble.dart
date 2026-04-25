import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class ChatAudioBubble extends StatefulWidget {
  const ChatAudioBubble({
    super.key,
    required this.url,
    required this.isMine,
    required this.bubbleColor,
    this.durationSeconds,
    this.isUnread = false,
    this.onPlayed,
    this.timeLabel,
    this.delivered = false,
    this.seen = false,
  });

  final String url;
  final bool isMine;
  final Color bubbleColor;
  final int? durationSeconds;
  final bool isUnread;
  final VoidCallback? onPlayed;
  /// Timestamp string to show inside the bubble (e.g. "14:32").
  final String? timeLabel;
  /// Whether the message has been delivered.
  final bool delivered;
  /// Whether the message has been seen/read.
  final bool seen;

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

  Widget _waveBar(
    BuildContext context,
    int index,
    int totalCount,
    double progress,
  ) {
    final active = ((index + 1) / math.max(1, totalCount)) <= progress;
    final baseHeights = <double>[6, 10, 14, 18, 12, 8, 16, 11, 15, 9];
    final focusIndex = (progress * math.max(1, totalCount - 1)).round();
    final isFocus = (index - focusIndex).abs() <= 1;
    final h = baseHeights[index % baseHeights.length] + (isFocus ? 3 : 0);
    final scheme = Theme.of(context).colorScheme;
    final color = active
        ? (widget.isMine
              ? Colors.white.withValues(alpha: 0.98)
              : scheme.primary)
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
    final scheme = Theme.of(context).colorScheme;
    final resolvedDuration = _duration > Duration.zero
        ? _duration
        : _fallbackDuration;
    final totalMs = resolvedDuration.inMilliseconds <= 0
        ? 1
        : resolvedDuration.inMilliseconds;
    final posMs = _position.inMilliseconds.clamp(0, totalMs);
    final progress = posMs / totalMs;
    final unreadDot = widget.isUnread && !_playedOnce && !_isPlaying;
    final innerGlass = Colors.white.withValues(
      alpha: widget.isMine
          ? (unreadDot ? 0.18 : 0.12)
          : (unreadDot ? 0.16 : 0.10),
    );
    final timeColor = Colors.white.withValues(alpha: unreadDot ? 0.82 : 0.72);
    final pulseBucket = (_position.inMilliseconds ~/ 240) % 2;
    final accent = widget.isMine ? Colors.white : scheme.primary;
    final barGlass = Colors.white.withValues(alpha: widget.isMine ? 0.10 : 0.08);

    final speedChip = InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: _cycleVoiceSpeed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: innerGlass,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        alignment: Alignment.center,
        child: Text(
          speedLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Container(
            // Extra bottom padding when timestamp is shown inside.
            padding: EdgeInsets.fromLTRB(
              8, 8, 8, (widget.timeLabel != null || widget.isMine) ? 22 : 8,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.bubbleColor.withValues(alpha: 0.96),
                  Color.alphaBlend(
                    Colors.white.withValues(alpha: widget.isMine ? 0.04 : 0.03),
                    widget.bubbleColor,
                  ),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            ),
            child: Stack(
              children: [
                // ── Waveform row ─────────────────────────────────────────
                Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: _loading ? null : _togglePlay,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 1,
                      end: _isPlaying ? (pulseBucket == 0 ? 1.0 : 1.07) : 1,
                    ),
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOutCubic,
                    builder: (context, scale, child) => Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              innerGlass,
                              Colors.white.withValues(alpha: 0.04),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: unreadDot ? 0.22 : 0.12),
                          ),
                          boxShadow: _isPlaying
                              ? [
                                  BoxShadow(
                                    color: accent.withValues(alpha: 0.18),
                                    blurRadius: 14,
                                    spreadRadius: -8,
                                    offset: const Offset(0, 8),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            if (_loading)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            else
                              Icon(
                                _isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 21,
                              ),
                            if (unreadDot)
                              Positioned(
                                top: -1,
                                right: -1,
                                child: Container(
                                  width: 9,
                                  height: 9,
                                  decoration: BoxDecoration(
                                    color: accent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: widget.bubbleColor,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: barGlass,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final usableWidth = constraints.maxWidth.clamp(64.0, 10000.0);
                        final showInlineTime = usableWidth >= 132;
                        final timeWidth = showInlineTime ? 76.0 : 0.0;
                        final spacing = showInlineTime ? 10.0 : 0.0;
                        final waveformWidth = math.max(18.0, usableWidth - timeWidth - spacing);
                        final barCount = math.max(4, (waveformWidth / 6).floor());

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
                          child: Row(
                            children: [
                              Expanded(
                                child: Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    Container(
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: progress.clamp(0.0, 1.0),
                                      child: Container(
                                        height: 4,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withValues(alpha: 0.26),
                                              Colors.white.withValues(alpha: 0.82),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: List.generate(
                                        barCount,
                                        (index) => Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 1),
                                          child: _waveBar(
                                            context,
                                            index,
                                            barCount,
                                            progress,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (showInlineTime) ...[
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: timeWidth,
                                  child: Text(
                                    '${_fmt(_position)} / ${_fmt(resolvedDuration)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: timeColor,
                                      fontSize: 10.5,
                                      fontWeight: unreadDot ? FontWeight.w800 : FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                speedChip,
              ],
                ), // end waveform Row

                // ── Timestamp + delivery checks — bottom-right inside bubble ─
                if (widget.timeLabel != null || widget.isMine)
                  Positioned(
                    bottom: 0,
                    right: 2,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (widget.timeLabel != null)
                          Text(
                            widget.timeLabel!,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.65),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (widget.isMine) ...[
                          const SizedBox(width: 3),
                          Icon(
                            widget.seen
                                ? Icons.done_all_rounded
                                : widget.delivered
                                    ? Icons.done_all_rounded
                                    : Icons.done_rounded,
                            size: 12,
                            color: widget.seen
                                ? Colors.lightBlueAccent.withValues(alpha: 0.90)
                                : Colors.white.withValues(alpha: 0.55),
                          ),
                        ],
                      ],
                    ),
                  ),
              ], // end Stack children
            ), // end Stack
          ),
        ),
      ],
    );
  }
}
