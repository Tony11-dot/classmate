import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;

import 'cm_loading.dart';

/// A branded pull-to-refresh that reveals a little ClassMate "scene" (a soft
/// sky, rolling hills, and the animated CM monogram) as you drag down — in the
/// spirit of Claude's pull-to-refresh — instead of the plain Material spinner.
///
/// Drop-in compatible with [RefreshIndicator] for the way it is used across the
/// app: it takes the same `onRefresh` + `child`, so a call site swaps 1:1. It
/// works on both bouncing (iOS) and clamping (Android) scroll physics by
/// reading absolute overscroll from [ScrollUpdateNotification] and accumulating
/// [OverscrollNotification] deltas respectively.
class ClassMateRefreshIndicator extends StatefulWidget {
  const ClassMateRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.triggerPull = 92.0,
  });

  /// Called when the user pulls past the trigger threshold and releases. The
  /// scene stays until the returned future completes.
  final RefreshCallback onRefresh;

  /// The scrollable to wrap (ListView, CustomScrollView, etc.).
  final Widget child;

  /// Distance (logical px) the user must pull before a release triggers a
  /// refresh.
  final double triggerPull;

  @override
  State<ClassMateRefreshIndicator> createState() =>
      _ClassMateRefreshIndicatorState();
}

class _ClassMateRefreshIndicatorState extends State<ClassMateRefreshIndicator>
    with SingleTickerProviderStateMixin {
  double _pull = 0;
  bool _refreshing = false;
  bool _dragging = false;

  late final AnimationController _settle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  double _settleFrom = 0;
  double _settleTo = 0;

  double get _revealMax => widget.triggerPull * 1.6;

  @override
  void initState() {
    super.initState();
    _settle.addListener(() {
      final v = lerpDouble(
        _settleFrom,
        _settleTo,
        Curves.easeOutCubic.transform(_settle.value),
      );
      if (v != null && mounted) setState(() => _pull = v);
    });
  }

  @override
  void dispose() {
    _settle.dispose();
    super.dispose();
  }

  void _animatePullTo(double target) {
    _settleFrom = _pull;
    _settleTo = target;
    _settle.forward(from: 0);
  }

  bool _onNotification(ScrollNotification n) {
    if (n.depth != 0 || n.metrics.axis != Axis.vertical) return false;
    if (_refreshing) return false;

    if (n is ScrollStartNotification) {
      _dragging = n.dragDetails != null;
      _settle.stop();
    } else if (n is OverscrollNotification) {
      // Clamping physics: pixels stay at 0 and the refused pull is reported as
      // a negative overscroll delta — accumulate it.
      if (_dragging && n.overscroll < 0 && n.metrics.extentBefore <= 0) {
        setState(
          () => _pull = (_pull - n.overscroll).clamp(0.0, _revealMax),
        );
      }
    } else if (n is ScrollUpdateNotification) {
      // Bouncing physics: the over-drag shows up as negative pixels — use it as
      // an absolute pull amount.
      final px = n.metrics.pixels;
      if (_dragging && px < 0) {
        setState(() => _pull = (-px).clamp(0.0, _revealMax));
      } else if (px > 0 && _pull != 0 && !_settle.isAnimating) {
        // Scrolled down into real content — abandon the pull.
        setState(() => _pull = 0);
      }
    } else if (n is UserScrollNotification) {
      if (n.direction == ScrollDirection.idle) {
        _dragging = false;
        _release();
      }
    } else if (n is ScrollEndNotification) {
      _dragging = false;
      _release();
    }
    return false;
  }

  void _release() {
    if (_refreshing) return;
    if (_pull >= widget.triggerPull) {
      _startRefresh();
    } else if (_pull > 0) {
      _animatePullTo(0);
    }
  }

  Future<void> _startRefresh() async {
    setState(() => _refreshing = true);
    _animatePullTo(widget.triggerPull);
    try {
      await widget.onRefresh();
    } catch (_) {
      // Swallow — refreshing must never surface an unhandled error here.
    }
    if (!mounted) return;
    setState(() => _refreshing = false);
    _animatePullTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reveal = _pull.clamp(0.0, _revealMax);
    final progress = (reveal / widget.triggerPull).clamp(0.0, 1.0);

    return NotificationListener<ScrollNotification>(
      onNotification: _onNotification,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          if (reveal > 0.5)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: reveal,
              child: ClipRect(
                child: OverflowBox(
                  minHeight: _revealMax,
                  maxHeight: _revealMax,
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: _revealMax,
                    child: _RefreshScene(
                      progress: progress,
                      refreshing: _refreshing,
                      scheme: scheme,
                    ),
                  ),
                ),
              ),
            ),
          Transform.translate(
            offset: Offset(0, reveal),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class _RefreshScene extends StatelessWidget {
  const _RefreshScene({
    required this.progress,
    required this.refreshing,
    required this.scheme,
  });

  final double progress;
  final bool refreshing;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final p = scheme.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.alphaBlend(p.withValues(alpha: 0.16), scheme.surface),
            Color.alphaBlend(p.withValues(alpha: 0.04), scheme.surface),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: const Size(double.infinity, 24),
              painter: _HillsPainter(p),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Opacity(
              opacity: refreshing ? 1.0 : progress,
              child: Transform.scale(
                scale: refreshing ? 1.0 : 0.62 + 0.38 * progress,
                child: CmLoading(size: 34, color: p),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HillsPainter extends CustomPainter {
  _HillsPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final back = Paint()..color = color.withValues(alpha: 0.16);
    final backPath = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.55)
      ..quadraticBezierTo(w * 0.28, -2, w * 0.52, h * 0.42)
      ..quadraticBezierTo(w * 0.76, h * 0.85, w, h * 0.32)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(backPath, back);

    final front = Paint()..color = color.withValues(alpha: 0.30);
    final frontPath = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.78)
      ..quadraticBezierTo(w * 0.34, h * 0.34, w * 0.6, h * 0.72)
      ..quadraticBezierTo(w * 0.82, h * 0.98, w, h * 0.6)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(frontPath, front);
  }

  @override
  bool shouldRepaint(covariant _HillsPainter oldDelegate) =>
      oldDelegate.color != color;
}
