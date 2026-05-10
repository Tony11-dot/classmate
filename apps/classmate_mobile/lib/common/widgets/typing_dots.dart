import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Animated three-dot typing indicator (TikTok / iMessage style).
///
/// Usage:
///   TypingDots()                     — default (14px dots, white)
///   TypingDots(color: Colors.black)
///   TypingDots.row(label: 'NOVA is thinking')  — with a label
class TypingDots extends StatefulWidget {
  const TypingDots({
    super.key,
    this.color,
    this.dotSize = 7.0,
    this.gap = 5.0,
    this.label,
    this.labelStyle,
  });

  final Color? color;
  final double dotSize;
  final double gap;
  final String? label;
  final TextStyle? labelStyle;

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.color ?? Colors.white;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, child) => Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(3, (i) {
              // staggered sine wave: each dot offset by 120°
              final phase = (i * math.pi * 2) / 3;
              final t = (_ctrl.value * math.pi * 2) + phase;
              final bounce = (math.sin(t) + 1) / 2; // 0..1
              final translateY = -bounce * (widget.dotSize * 0.85);
              return Padding(
                padding: EdgeInsets.only(
                  right: i < 2 ? widget.gap : 0,
                ),
                child: Transform.translate(
                  offset: Offset(0, translateY),
                  child: Container(
                    width: widget.dotSize,
                    height: widget.dotSize,
                    decoration: BoxDecoration(
                      color: color.withValues(
                        alpha: color.a * (0.55 + bounce * 0.45),
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        if (widget.label != null) ...[
          SizedBox(width: widget.gap + 2),
          Text(
            widget.label!,
            style: widget.labelStyle ??
                TextStyle(
                  color: color.withValues(alpha: color.a * 0.80),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ],
    );
  }
}

/// A full-width "X is typing" row shown above the composer.
class TypingIndicatorRow extends StatelessWidget {
  const TypingIndicatorRow({
    super.key,
    this.label = 'typing',
    this.dotColor,
  });

  final String label;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = dotColor ?? cs.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 2),
      child: Row(
        children: [
          TypingDots(color: color, dotSize: 6, gap: 4),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// A compact left-aligned typing bubble for use inside the message list.
class TypingBubble extends StatelessWidget {
  const TypingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 4, 64, 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF0A1730)
              : const Color(0xFF2D4A7A),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const TypingDots(dotSize: 7, gap: 5),
      ),
    );
  }
}

/// Voice recording HUD shown above the composer during active recording.
///
/// Design: frosted glass pill — pulsing red dot · timer · animated waveform
/// · optional lock / paused state.
class VoiceRecordingHud extends StatefulWidget {
  const VoiceRecordingHud({
    super.key,
    required this.elapsed,
    required this.isLocked,
    required this.isPaused,
    this.dotColor,
  });

  final Duration elapsed;
  final bool isLocked;
  final bool isPaused;
  final Color? dotColor;

  @override
  State<VoiceRecordingHud> createState() => _VoiceRecordingHudState();
}

class _VoiceRecordingHudState extends State<VoiceRecordingHud>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveCtrl;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    if (!widget.isPaused) _waveCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(VoiceRecordingHud old) {
    super.didUpdateWidget(old);
    if (widget.isPaused && _waveCtrl.isAnimating) {
      _waveCtrl.stop();
    } else if (!widget.isPaused && !_waveCtrl.isAnimating) {
      _waveCtrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final total = d.inSeconds.clamp(0, 3599);
    final mm = (total ~/ 60).toString().padLeft(2, '0');
    final ss = (total % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final recColor = widget.dotColor ?? cs.error;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white
              : Colors.black,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white
                : Colors.black,
          ),
        ),
        child: Row(
          children: [
            // Pulsing red dot
            _PulsingDot(color: recColor, paused: widget.isPaused),
            const SizedBox(width: 10),
            // Timer
            Text(
              _fmt(widget.elapsed),
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 14),
            // Animated waveform bars
            if (!widget.isPaused)
              Expanded(
                child: _WaveformBars(controller: _waveCtrl, color: recColor),
              )
            else
              Expanded(
                child: Text(
                  'Paused',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            // Lock indicator
            if (widget.isLocked)
              Icon(Icons.lock_rounded, size: 14, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

/// Animated waveform bar group that pulses while recording.
class _WaveformBars extends StatelessWidget {
  const _WaveformBars({required this.controller, required this.color});

  final AnimationController controller;
  final Color color;

  static const _phases = [0.0, 0.33, 0.66, 0.20, 0.50, 0.80, 0.10, 0.45];
  static const _barCount = 8;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(_barCount, (i) {
            final phase = _phases[i % _phases.length];
            final t = ((controller.value + phase) % 1.0);
            // sine-based height: 3..16
            final height = 3.0 + (math.sin(t * math.pi) * 13.0);
            return Container(
              width: 3,
              height: height,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.7 + 0.3 * math.sin(t * math.pi)),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color, required this.paused});

  final Color color;
  final bool paused;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_PulsingDot old) {
    super.didUpdateWidget(old);
    if (widget.paused) {
      _ctrl.stop();
    } else if (!_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: widget.paused
              ? widget.color
              : widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
