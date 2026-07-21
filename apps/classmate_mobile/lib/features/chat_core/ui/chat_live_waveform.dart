import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Live scrolling voice waveform, Instagram-style.
///
/// Bars enter at the right edge as amplitude samples arrive and the whole
/// trace drifts left *continuously* between samples, so it reads as tape
/// moving under a stylus rather than bars twitching in place. The drift phase
/// is driven by a ticker (not by sample arrival), which is what makes it feel
/// smooth even though samples only land every ~70 ms.
///
/// Always painted left-to-right regardless of ambient directionality — a
/// waveform is a time axis, and both WhatsApp and Instagram keep it physical
/// in RTL locales.
class ChatLiveWaveform extends StatefulWidget {
  const ChatLiveWaveform({
    super.key,
    required this.levels,
    required this.color,
    this.height = 22,
    this.barWidth = 2.6,
    this.gap = 2.6,
  });

  /// Amplitude samples 0..1, newest last. Empty → calm idle baseline.
  final List<double> levels;
  final Color color;
  final double height;
  final double barWidth;
  final double gap;

  @override
  State<ChatLiveWaveform> createState() => _ChatLiveWaveformState();
}

class _ChatLiveWaveformState extends State<ChatLiveWaveform>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  // Painter repaint driver — bumped every frame; no setState, no rebuilds.
  final ValueNotifier<double> _clockMs = ValueNotifier<double>(0);

  double _lastSampleMs = 0;
  double _intervalMs = 80;
  int _lastLen = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      final ms = elapsed.inMicroseconds / 1000.0;
      final len = widget.levels.length;
      if (len != _lastLen) {
        // New sample landed — measure the real cadence (EMA) so the scroll
        // speed matches however fast the platform actually reports amplitude.
        if (_lastLen > 0) {
          final gapMs = ms - _lastSampleMs;
          if (gapMs > 15 && gapMs < 400) {
            _intervalMs = _intervalMs * 0.7 + gapMs * 0.3;
          }
        }
        _lastLen = len;
        _lastSampleMs = ms;
      }
      _clockMs.value = ms;
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clockMs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: ClipRect(
        child: CustomPaint(
          painter: _WavePainter(state: this),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({required this.state}) : super(repaint: state._clockMs);

  final _ChatLiveWaveformState state;

  @override
  void paint(Canvas canvas, Size size) {
    final w = state.widget;
    final levels = w.levels;
    final slot = w.barWidth + w.gap;
    if (size.width <= slot) return;

    // 0..1 progress toward the next sample — this is the continuous drift.
    final sinceMs = state._clockMs.value - state._lastSampleMs;
    final t = state._intervalMs <= 0
        ? 0.0
        : (sinceMs / state._intervalMs).clamp(0.0, 1.0);
    final phase = t * slot;

    final midY = size.height / 2;
    const minH = 2.6;
    final maxH = size.height;
    final n = (size.width / slot).floor() + 1;

    final paint = Paint()
      ..strokeWidth = w.barWidth
      ..strokeCap = StrokeCap.round;

    for (var k = 0; k < n; k++) {
      // k = 0 is the newest sample, pinned to the right edge at the moment it
      // arrives, then drifting left by `phase` until the next one lands —
      // at which point it re-indexes to k = 1 exactly one slot further left,
      // so the motion never jumps.
      final x = size.width - w.barWidth / 2 - k * slot - phase;
      if (x < w.barWidth / 2 - slot) break;
      final idx = levels.length - 1 - k;
      final level = (idx >= 0 && idx < levels.length) ? levels[idx] : 0.06;
      var h = minH + (maxH - minH) * level.clamp(0.0, 1.0);
      // The entering bar grows in rather than popping to full height.
      if (k == 0) h *= Curves.easeOut.transform(t);
      if (h < minH) h = minH;
      // Older bars fade — gives the trace its sense of direction.
      final age = (k / n).clamp(0.0, 1.0);
      paint.color = w.color.withValues(alpha: 1.0 - age * 0.6);
      canvas.drawLine(
        Offset(x, midY - h / 2),
        Offset(x, midY + h / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => true;
}
