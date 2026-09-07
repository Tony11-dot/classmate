import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../ui/widgets/cm_loading.dart';
import 'package:just_audio/just_audio.dart';
import 'chat_ticks.dart';

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
    this.senderName = '',
    this.borderRadius,
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

  /// Sender display name — drives the trailing avatar's initial + tint.
  final String senderName;

  /// Outer bubble shape. Passed in by the message bubble so the corner on the
  /// tail side can be squared and the tail welds into THIS container exactly
  /// like a text bubble. Defaults to the classic fully-rounded pill.
  final BorderRadius? borderRadius;

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

  /// Deterministic pseudo-waveform. Real per-message amplitude data isn't
  /// stored, so — like WhatsApp — the bars are decorative but STABLE: seeded
  /// from the url they never re-shuffle on rebuild or between sessions.
  List<double> _barHeights(int count) {
    final rnd = math.Random(widget.url.hashCode);
    final out = <double>[];
    var prev = 0.45;
    for (var i = 0; i < count; i++) {
      // Random walk with pull-to-center: reads as speech, not white noise.
      final target = 0.15 + rnd.nextDouble() * 0.85;
      prev = prev * 0.45 + target * 0.55;
      out.add(prev.clamp(0.12, 1.0));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final resolved =
        _duration > Duration.zero ? _duration : _fallback;
    final totalMs = math.max(1, resolved.inMilliseconds);
    final posMs = _position.inMilliseconds.clamp(0, totalMs);
    final progress = posMs / totalMs;

    final unheard = widget.isUnread && !_playedOnce && !_isPlaying;
    // WhatsApp-parity palette.
    //
    // Own bubble (background ≈ scheme.primary): the "ink" (play triangle,
    // played bars, scrubber, texts) is white with varying opacities.
    // Other bubble (neutral surface): ink is onSurface greys; the scrubber
    // dot and unheard-mic badge take the primary accent so they pop the way
    // WhatsApp's blue dot does on a white bubble.
    final Color ink = widget.isMine ? Colors.white : scheme.onSurface;
    final Color accent = widget.isMine ? Colors.white : scheme.primary;
    final Color playedBar = widget.isMine
        ? Colors.white.withValues(alpha: 0.95)
        : scheme.onSurface.withValues(alpha: 0.78);
    // Incoming idle bars were at 0.28 — nearly invisible against the neutral
    // bubble on some themes (QA #8). Bump the contrast so the waveform reads.
    final Color idleBar = widget.isMine
        ? Colors.white.withValues(alpha: 0.40)
        : scheme.onSurface.withValues(alpha: 0.42);
    final Color timeColor = widget.isMine
        ? Colors.white.withValues(alpha: 0.80)
        : scheme.onSurface.withValues(alpha: 0.60);

    // ── Play / pause (plain glyph, no circle — as in the reference) ────────
    final playBtn = GestureDetector(
      onTap: _loading ? null : _togglePlay,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 36,
        height: 44,
        child: Center(
          child: _loading
              ? CmLoading(size: 18, color: ink.withValues(alpha: 0.75))
              : Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: ink.withValues(alpha: 0.75),
                  size: 34,
                ),
        ),
      ),
    );

    // ── Seekable waveform + scrubber dot ───────────────────────────────────
    final seekBar = LayoutBuilder(
      builder: (ctx, constraints) {
        void seekFromGlobal(Offset globalPosition) {
          final box = ctx.findRenderObject() as RenderBox?;
          if (box == null) return;
          final local = box.globalToLocal(globalPosition);
          _seekToRatio(local.dx / math.max(1, box.size.width));
        }

        const bw = 2.6, gap = 2.0;
        final count =
            math.max(12, (constraints.maxWidth / (bw + gap)).floor());
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => seekFromGlobal(d.globalPosition),
          onHorizontalDragUpdate: (d) => seekFromGlobal(d.globalPosition),
          child: SizedBox(
            height: 34,
            child: CustomPaint(
              size: Size(constraints.maxWidth, 34),
              painter: _VoiceWavePainter(
                heights: _barHeights(count),
                progress: progress.clamp(0.0, 1.0),
                playedColor: playedBar,
                idleColor: idleBar,
                dotColor: widget.isMine ? Colors.white : accent,
                barWidth: bw,
                gap: gap,
              ),
            ),
          ),
        );
      },
    );

    // ── Trailing: avatar + mic badge, or the speed pill while playing ──────
    const speeds = [1.0, 1.5, 2.0];
    final speedIndex = speeds.indexWhere((s) => (_speed - s).abs() < 0.01);
    final currentSpeed = speedIndex < 0 ? 0 : speedIndex;
    final speedLabel = const ['1×', '1.5×', '2×'][currentSpeed];

    // WhatsApp swaps the avatar for the speed pill during playback — the pill
    // is only actionable while listening, the avatar only informative before.
    final showSpeed = _isPlaying || _position > Duration.zero;

    final name = widget.senderName.trim();
    final initial = name.isEmpty ? '' : name.characters.first.toUpperCase();
    // Stable pastel per sender so the same person's voice notes always carry
    // the same avatar tint (screenshot: the soft pink circle).
    final hue = (name.isEmpty ? 210 : (name.hashCode % 360)).toDouble().abs();
    final avatarBg = HSLColor.fromAHSL(
      1,
      hue,
      0.42,
      Theme.of(context).brightness == Brightness.dark ? 0.38 : 0.82,
    ).toColor();
    final avatarFg = HSLColor.fromAHSL(
      1,
      hue,
      0.45,
      Theme.of(context).brightness == Brightness.dark ? 0.85 : 0.28,
    ).toColor();

    final avatar = SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration:
                  BoxDecoration(color: avatarBg, shape: BoxShape.circle),
              child: Center(
                child: initial.isEmpty
                    ? Icon(Icons.person_rounded, size: 24, color: avatarFg)
                    : Text(
                        initial,
                        style: TextStyle(
                          color: avatarFg,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ),
          // Mic badge overlapping the avatar's leading-bottom edge — accent
          // while the note is unheard, muted once played (WhatsApp semantics).
          PositionedDirectional(
            start: -7,
            bottom: 1,
            child: Icon(
              Icons.mic_rounded,
              size: 19,
              color: unheard
                  ? (widget.isMine ? Colors.white : scheme.primary)
                  : timeColor,
            ),
          ),
        ],
      ),
    );

    final speedPill = GestureDetector(
      onTap: () => _setSpeed(speeds[(currentSpeed + 1) % speeds.length]),
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minWidth: 44),
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: widget.isMine
              ? Colors.white.withValues(alpha: 0.22)
              : scheme.onSurface.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          speedLabel,
          style: TextStyle(
            color: ink.withValues(alpha: 0.85),
            fontSize: 12,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );

    final trailing = AnimatedSwitcher(
      duration: const Duration(milliseconds: 160),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeOutCubic,
      child: showSpeed
          ? SizedBox(
              key: const ValueKey('speed'),
              width: 48,
              height: 44,
              child: Center(child: speedPill),
            )
          : KeyedSubtree(key: const ValueKey('avatar'), child: avatar),
    );

    // ── Times row: elapsed/total under the wave, timestamp + ticks at end ──
    final durationText = Text(
      _isPlaying || _position > Duration.zero ? _fmt(_position) : _fmt(resolved),
      style: TextStyle(
        color: timeColor,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );

    Widget checksWidget = const SizedBox.shrink();
    if (widget.isMine) {
      checksWidget = Padding(
        padding: const EdgeInsetsDirectional.only(start: 4),
        child: ChatTicks(
          state: ChatTicks.stateOf(
            delivered: widget.delivered,
            seen: widget.seen,
          ),
          onAccentSurface: true,
          size: 15,
        ),
      );
    }

    // ── Assemble — ONE container, shaped by the caller so the bubble tail
    // welds into it exactly like a text bubble ─────────────────────────────
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsetsDirectional.fromSTEB(4, 6, 8, 4),
      decoration: BoxDecoration(
        color: widget.bubbleColor,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              playBtn,
              const SizedBox(width: 2),
              Expanded(child: seekBar),
              const SizedBox(width: 8),
              trailing,
            ],
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 8, top: 1),
            child: Row(
              children: [
                durationText,
                const Spacer(),
                if (widget.timeLabel != null)
                  Text(
                    widget.timeLabel!,
                    style: TextStyle(
                      fontSize: 11,
                      color: timeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                checksWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Static waveform + progress scrubber. Bars are painted center-aligned in a
/// single pass; the played portion (and the dot) tint by [progress]. Painted
/// physically LTR — audio time always advances left→right, as in every
/// messenger, RTL locales included.
class _VoiceWavePainter extends CustomPainter {
  const _VoiceWavePainter({
    required this.heights,
    required this.progress,
    required this.playedColor,
    required this.idleColor,
    required this.dotColor,
    required this.barWidth,
    required this.gap,
  });

  final List<double> heights;
  final double progress;
  final Color playedColor;
  final Color idleColor;
  final Color dotColor;
  final double barWidth;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    if (heights.isEmpty) return;
    final slot = barWidth + gap;
    final usable = size.width;
    final count = math.min(heights.length, (usable / slot).floor());
    if (count <= 0) return;
    final midY = size.height / 2;
    const maxH = 26.0;
    final playedPaint = Paint()
      ..color = playedColor
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.round;
    final idlePaint = Paint()
      ..color = idleColor
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.round;
    final dotX = (progress * (count - 1)) * slot + barWidth / 2;

    for (var i = 0; i < count; i++) {
      final x = i * slot + barWidth / 2;
      final h = math.max(3.0, heights[i] * maxH);
      final paint = x <= dotX && progress > 0 ? playedPaint : idlePaint;
      canvas.drawLine(
          Offset(x, midY - h / 2), Offset(x, midY + h / 2), paint);
    }

    // Scrubber dot: only while playing/seeked. At rest it sat pinned at the
    // far-left edge, printed ON TOP of the first bars — which read as "the dot
    // and the waves overlap" and hid part of the waveform (QA #8/#64). Drawing
    // it only once playback has moved keeps the idle waveform clean.
    if (progress > 0) {
      final dot = Paint()..color = dotColor;
      canvas.drawCircle(Offset(dotX.clamp(5.0, usable - 5.0), midY), 5.5, dot);
    }
  }

  @override
  bool shouldRepaint(_VoiceWavePainter old) =>
      old.progress != progress ||
      old.playedColor != playedColor ||
      old.idleColor != idleColor ||
      old.dotColor != dotColor ||
      old.heights.length != heights.length;
}
