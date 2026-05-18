import 'dart:io';
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
  final String? timeLabel;
  final bool delivered;
  final bool seen;

  @override
  State<ChatAudioBubble> createState() => _ChatAudioBubbleState();
}

class _ChatAudioBubbleState extends State<ChatAudioBubble> {
  static final List<_ChatAudioBubbleState> _registry = [];

  final AudioPlayer _player = AudioPlayer();
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _loading = false;
  bool _ready = false;
  bool _playedOnce = false;
  double _speed = 1.0;

  static bool _isLocalPath(String url) {
    if (url.startsWith('file://')) return true;
    if (!url.startsWith('/')) return false;
    return url.startsWith('/private/') ||
        url.startsWith('/var/') ||
        url.startsWith('/tmp/') ||
        url.startsWith('/Users/');
  }

  @override
  void initState() {
    super.initState();
    _registry.add(this);
    _player.setLoopMode(LoopMode.off);

    _player.positionStream.listen((v) {
      if (mounted) setState(() => _position = v);
    });
    _player.durationStream.listen((v) {
      if (mounted) setState(() => _duration = v ?? _fallback);
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
        } catch (_) {}
        if (mounted) setState(() => _position = Duration.zero);
        return;
      }
      if (mounted) setState(() {});
    });
  }

  Duration get _fallback =>
      Duration(seconds: math.max(0, widget.durationSeconds ?? 0));

  bool get _isPlaying => _player.playing;

  Future<void> _ensureReady() async {
    if (_ready) return;
    if (mounted) setState(() => _loading = true);
    try {
      final url = widget.url.trim();
      if (_isLocalPath(url)) {
        final path =
            url.startsWith('file://') ? Uri.parse(url).toFilePath() : url;
        if (!File(path).existsSync()) return;
        await _player.setFilePath(path);
      } else {
        await _player.setUrl(url);
      }
      await _player.setSpeed(_speed);
      await _player.setLoopMode(LoopMode.off);
      _ready = true;
      if (_duration == Duration.zero && _fallback > Duration.zero) {
        _duration = _fallback;
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _stopOthers() async {
    for (final b in List<_ChatAudioBubbleState>.from(_registry)) {
      if (identical(b, this)) continue;
      try {
        await b._player.pause();
        await b._player.seek(Duration.zero);
      } catch (_) {}
      if (b.mounted) b.setState(() => b._position = Duration.zero);
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
      final resolved = _duration > Duration.zero ? _duration : _fallback;
      if (resolved > Duration.zero &&
          _position >= resolved - const Duration(milliseconds: 250)) {
        await _player.seek(Duration.zero);
      }
      await _player.setLoopMode(LoopMode.off);
      await _player.play();
    } catch (_) {}
  }

  Future<void> _seekToRatio(double ratio) async {
    try {
      await _ensureReady();
      final resolved = _duration > Duration.zero ? _duration : _fallback;
      final ms = (resolved.inMilliseconds * ratio.clamp(0.0, 1.0)).round();
      await _player.seek(Duration(milliseconds: ms));
    } catch (_) {}
  }

  Future<void> _setSpeed(double speed) async {
    setState(() => _speed = speed);
    try {
      await _player.setSpeed(speed);
    } catch (_) {}
  }

  @override
  void dispose() {
    _registry.remove(this);
    _player.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final total = d.inSeconds.clamp(0, 99 * 60);
    final mm = (total ~/ 60).toString().padLeft(2, '0');
    final ss = (total % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final resolved =
        _duration > Duration.zero ? _duration : _fallback;
    final totalMs = math.max(1, resolved.inMilliseconds);
    final posMs = _position.inMilliseconds.clamp(0, totalMs);
    final progress = posMs / totalMs;

    final unreadDot = widget.isUnread && !_playedOnce && !_isPlaying;
    final accent = widget.isMine ? Colors.white : scheme.primary;
    final onBubble = widget.isMine
        ? Colors.white
        : scheme.onSurface;
    final dimColor = onBubble;
    // Contrast layer for content rendered ON TOP of the accent fill (play
    // icon, active speed pill). Without this both the play-arrow and the
    // active speed label were the same color as the circle/pill behind
    // them, so they vanished against the bubble.
    final onAccent = accent.computeLuminance() < 0.5
        ? Colors.white
        : (widget.isMine ? scheme.primary : Colors.white);

    // ── Waveform bars ──────────────────────────────────────────────────────
    const baseHeights = <double>[5, 9, 14, 18, 12, 8, 16, 10, 15, 6];
    final pulseBucket = (_position.inMilliseconds ~/ 240) % 2;

    Widget waveformBar(int i, int count) {
      final frac = (i + 1) / math.max(1, count);
      final active = frac <= progress;
      final focusIdx = (progress * math.max(1, count - 1)).round();
      final isFocus = (i - focusIdx).abs() <= 1;
      final h = baseHeights[i % baseHeights.length] + (isFocus ? 3 : 0);
      final color = active
          ? accent
          : dimColor;
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

    // ── Play/pause button ─────────────────────────────────────────────────
    final playBtn = GestureDetector(
      onTap: _loading ? null : _togglePlay,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: 1,
          end: _isPlaying ? (pulseBucket == 0 ? 1.0 : 1.06) : 1,
        ),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOutCubic,
        builder: (context, scale, _) => Transform.scale(
          scale: scale,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent,
              border: Border.all(
                color: accent.withValues(alpha: unreadDot ? 0.60 : 0.28),
              ),
              boxShadow: _isPlaying
                  ? [
                      BoxShadow(
                        color: accent,
                        blurRadius: 14,
                        spreadRadius: -6,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (_loading)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: onAccent,
                    ),
                  )
                else
                  Icon(
                    _isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: onAccent,
                    size: 22,
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
    );

    // ── Seekable waveform + progress track ───────────────────────────────
    // GestureDetector is inside LayoutBuilder so findRenderObject() returns
    // the seekbar's RenderBox — required for accurate tap + drag seeking.
    final seekBar = LayoutBuilder(
      builder: (ctx, constraints) {
        void seekFromGlobal(Offset globalPosition) {
          final box = ctx.findRenderObject() as RenderBox?;
          if (box == null) return;
          final local = box.globalToLocal(globalPosition);
          _seekToRatio(local.dx / math.max(1, box.size.width));
        }

        final usable = constraints.maxWidth;
        final barCount = math.max(6, (usable / 6).floor());

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => seekFromGlobal(d.globalPosition),
          onHorizontalDragUpdate: (d) => seekFromGlobal(d.globalPosition),
          onPanUpdate: (d) => seekFromGlobal(d.globalPosition),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: dimColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: List.generate(
                  barCount,
                  (i) => Expanded(child: Center(child: waveformBar(i, barCount))),
                ),
              ),
            ],
          ),
        );
      },
    );

    // ── Time display ──────────────────────────────────────────────────────
    // Playing → elapsed time counting up; stopped → total duration.
    final timeText = _isPlaying
        ? _fmt(_position)
        : _fmt(resolved);

    final timeWidget = Text(
      timeText,
      style: TextStyle(
        color: dimColor,
        fontSize: 11,
        fontWeight: _isPlaying ? FontWeight.w800 : FontWeight.w600,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );

    // ── Speed selector (below bubble) ────────────────────────────────────
    const speeds = [1.0, 1.5, 2.0];
    final speedLabels = ['1×', '1.5×', '2×'];

    final speedRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: accent),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(speeds.length, (i) {
              final isActive = (_speed - speeds[i]).abs() < 0.01;
              return GestureDetector(
                onTap: () => _setSpeed(speeds[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: isActive
                        ? accent
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    speedLabels[i],
                    style: TextStyle(
                      // When the pill is filled (active), use the contrast
                      // foreground so the label is visible on the accent
                      // background; otherwise stick with the bubble's
                      // normal text color.
                      color: isActive ? onAccent : dimColor,
                      fontSize: 10,
                      fontWeight: isActive
                          ? FontWeight.w900
                          : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );

    // ── Delivery checks ───────────────────────────────────────────────────
    Widget checksWidget = const SizedBox.shrink();
    if (widget.isMine) {
      final seenColor = const Color(0xFF53BDEB);
      final pendingColor = Colors.white;
      final deliveredColor = Colors.white;
      checksWidget = Icon(
        widget.seen || widget.delivered
            ? Icons.done_all_rounded
            : Icons.done_rounded,
        size: 12,
        color: widget.seen
            ? seenColor
            : widget.delivered
                ? deliveredColor
                : pendingColor,
      );
    }

    // ── Assemble ──────────────────────────────────────────────────────────
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          widget.isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            // Inherit the same bubble color the message uses so the voice
            // pill is visible against the chat canvas in light mode. The
            // hairline outline keeps the pill defined when the fill color
            // is very close to the surrounding surface.
            color: widget.bubbleColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: [play] [waveform] [time]
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  playBtn,
                  const SizedBox(width: 10),
                  Expanded(child: seekBar),
                  const SizedBox(width: 8),
                  timeWidget,
                ],
              ),
              const SizedBox(height: 8),
              // Row 2: [speed selector] ... [timestamp + checks]
              Row(
                children: [
                  speedRow,
                  const Spacer(),
                  if (widget.timeLabel != null) ...[
                    Text(
                      widget.timeLabel!,
                      style: TextStyle(
                        fontSize: 10,
                        color: dimColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 3),
                  ],
                  checksWidget,
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
