import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'cm_loading.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  CmRefreshIndicator — branded pull-to-refresh.
//
//  Drop-in replacement for [RefreshIndicator]: same `onRefresh` + `child`
//  constructor shape, so a call site only changes the class name.
//
//  Instead of a Material spinner, pulling down lifts the content and reveals a
//  little classroom scene painted behind it (sky, rolling hills, a schoolhouse
//  with a flag, a tree and a stack of books) with light parallax — the further
//  you pull, the more of the scene rises into view. The CM monogram (the app's
//  own [CmLoading] mark) rides in the middle of the strip and spins while the
//  refresh is in flight.
//
//  Theming rules honoured here:
//   • EVERY scene colour is derived from `Theme.of(context).colorScheme`, so
//     the scene reads correctly across all nine curated themes (Coffee, Nord,
//     Midnight, Forest, …) — there is no hardcoded sky-blue or grass-green.
//   • The monogram is [CmLoading], which picks its asset from
//     `Theme.of(context).brightness` ONLY. Nothing here changes that.
//   • No text anywhere in the scene → nothing to localize.
//   • No new package dependencies — the scene is a single [CustomPainter].
// ─────────────────────────────────────────────────────────────────────────────

/// Pull-to-refresh with the ClassMate scene + spinning monogram.
class CmRefreshIndicator extends StatefulWidget {
  const CmRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.edgeOffset = 0.0,
    this.color,
    this.enabled = true,
  });

  /// Called when the user has pulled far enough to arm a refresh.
  final RefreshCallback onRefresh;

  /// The scrollable this indicator wraps.
  final Widget child;

  /// Which [ScrollNotification]s to react to (nested scroll views).
  final ScrollNotificationPredicate notificationPredicate;

  /// Distance from the top of the widget at which the scene strip begins —
  /// use it when the scrollable sits under a pinned header.
  final double edgeOffset;

  /// Optional tint for the monogram. Defaults to the brand mark's own colours.
  final Color? color;

  /// When false the gesture is ignored and [child] is passed straight through.
  final bool enabled;

  @override
  State<CmRefreshIndicator> createState() => _CmRefreshIndicatorState();
}

enum _CmRefreshPhase { idle, dragging, armed, refreshing, retracting }

class _CmRefreshIndicatorState extends State<CmRefreshIndicator>
    with TickerProviderStateMixin {
  /// Pull distance that arms a refresh.
  static const double _kTrigger = 104.0;

  /// Hard stop for the pull (rubber-banded well before this).
  static const double _kMaxDrag = 168.0;

  /// Strip height held open while the refresh runs.
  static const double _kHold = 92.0;

  static const double _kMonogram = 34.0;

  late final AnimationController _settle;
  late final AnimationController _spin;
  Animation<double>? _settleTween;

  double _offset = 0.0;
  _CmRefreshPhase _phase = _CmRefreshPhase.idle;

  @override
  void initState() {
    super.initState();
    _settle = AnimationController(vsync: this, duration: Duration.zero)
      ..addListener(() {
        final tween = _settleTween;
        if (tween == null) return;
        setState(() => _offset = tween.value);
      });
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void dispose() {
    _settle.dispose();
    _spin.dispose();
    super.dispose();
  }

  void _animateTo(
    double target, {
    Duration duration = const Duration(milliseconds: 280),
    Curve curve = Curves.easeOutCubic,
  }) {
    if (!mounted) return;
    _settleTween = Tween<double>(
      begin: _offset,
      end: target,
    ).animate(CurvedAnimation(parent: _settle, curve: curve));
    _settle
      ..duration = duration
      ..value = 0.0
      ..forward();
  }

  void _setOffset(double value) {
    final next = value.clamp(0.0, _kMaxDrag);
    if (next == _offset) return;
    if (_settle.isAnimating) {
      _settle.stop();
      _settleTween = null;
    }
    setState(() => _offset = next);
  }

  /// Rubber-band: each extra pixel of pull counts for less the further we go.
  double _resist(double delta) {
    final t = (_offset / _kMaxDrag).clamp(0.0, 1.0);
    return delta * (1.0 - t) * 0.62;
  }

  bool _handleNotification(ScrollNotification notification) {
    if (!widget.enabled) return false;
    if (!widget.notificationPredicate(notification)) return false;
    if (_phase == _CmRefreshPhase.refreshing ||
        _phase == _CmRefreshPhase.retracting) {
      return false;
    }

    if (notification is OverscrollNotification) {
      // Negative overscroll == dragging past the leading (top) edge.
      if (notification.dragDetails != null && notification.overscroll < 0) {
        _setOffset(_offset + _resist(-notification.overscroll));
        if (_offset > 0 && _phase == _CmRefreshPhase.idle) {
          _phase = _CmRefreshPhase.dragging;
        }
        if (_offset >= _kTrigger) {
          _phase = _CmRefreshPhase.armed;
        } else if (_phase == _CmRefreshPhase.armed) {
          _phase = _CmRefreshPhase.dragging;
        }
      }
      return false;
    }

    if (notification is ScrollUpdateNotification) {
      // Scrolling the content back up closes the strip again.
      final delta = notification.scrollDelta;
      if (_offset > 0 && delta != null && delta > 0) {
        _setOffset(_offset - delta);
        if (_offset < _kTrigger && _phase == _CmRefreshPhase.armed) {
          _phase = _CmRefreshPhase.dragging;
        }
      }
      return false;
    }

    if (notification is ScrollEndNotification ||
        (notification is UserScrollNotification &&
            notification.direction == ScrollDirection.idle)) {
      _release();
    }
    return false;
  }

  void _release() {
    if (_offset <= 0) {
      _phase = _CmRefreshPhase.idle;
      return;
    }
    if (_phase == _CmRefreshPhase.armed) {
      _startRefresh();
    } else {
      _retract();
    }
  }

  void _retract() {
    _phase = _CmRefreshPhase.retracting;
    _spin.stop();
    _animateTo(0.0, duration: const Duration(milliseconds: 300));
    Future<void>.delayed(const Duration(milliseconds: 310), () {
      if (!mounted) return;
      if (_phase == _CmRefreshPhase.retracting) {
        setState(() => _phase = _CmRefreshPhase.idle);
      }
    });
  }

  Future<void> _startRefresh() async {
    setState(() => _phase = _CmRefreshPhase.refreshing);
    _spin.repeat();
    _animateTo(_kHold, duration: const Duration(milliseconds: 200));
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        _retract();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final cs = Theme.of(context).colorScheme;
    final progress = (_offset / _kHold).clamp(0.0, 1.0);
    final refreshing = _phase == _CmRefreshPhase.refreshing;

    // While the strip is open, suppress the platform overscroll glow/stretch so
    // the scene is the only feedback the user sees.
    final Widget listener = NotificationListener<ScrollNotification>(
      onNotification: _handleNotification,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (n) {
          if (n.depth == 0 && _offset > 0) n.disallowIndicator();
          return false;
        },
        child: widget.child,
      ),
    );

    // Idle: hand the child straight through — identical layout to no wrapper
    // at all, exactly like Material's RefreshIndicator does.
    if (_offset <= 0.5) return listener;

    return Stack(
      children: [
        Positioned(
          top: widget.edgeOffset,
          left: 0,
          right: 0,
          height: _offset,
          child: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: _CmSchoolScenePainter(
                    progress: progress,
                    scheme: cs,
                  ),
                ),
                Center(
                  child: Opacity(
                    opacity: Curves.easeIn.transform(
                      (progress * 1.6).clamp(0.0, 1.0),
                    ),
                    child: AnimatedBuilder(
                      animation: _spin,
                      builder: (context, child) {
                        final angle = refreshing
                            ? _spin.value * 2 * math.pi
                            : progress * math.pi * 1.1;
                        return Transform.rotate(angle: angle, child: child);
                      },
                      child: SizedBox(
                        width: _kMonogram,
                        height: _kMonogram,
                        child: CmLoading(size: _kMonogram, color: widget.color),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Transform.translate(offset: Offset(0, _offset), child: listener),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  The scene
// ─────────────────────────────────────────────────────────────────────────────

/// Paints a small schoolyard: sky, sun, clouds, rolling hills, a schoolhouse
/// with a flag, a tree, and a stack of books — all tinted from the active
/// [ColorScheme] so it reads correctly in every curated theme.
class _CmSchoolScenePainter extends CustomPainter {
  const _CmSchoolScenePainter({required this.progress, required this.scheme});

  final double progress;
  final ColorScheme scheme;

  Color _mix(Color a, Color b, double t) => Color.lerp(a, b, t)!;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.height <= 1 || size.width <= 1) return;
    final w = size.width;
    final h = size.height;
    final p = progress.clamp(0.0, 1.0);

    // Scene scale — keeps the props sensible whatever the strip height is.
    final u = (h / 92.0).clamp(0.35, 1.35);

    // ── Sky ────────────────────────────────────────────────────────────────
    final skyTop = _mix(scheme.surface, scheme.primaryContainer, 0.55);
    final skyBottom = _mix(scheme.surface, scheme.secondaryContainer, 0.35);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [skyTop, skyBottom],
        ).createShader(Offset.zero & size),
    );

    final groundTop = h - math.max(h * 0.34, 16.0 * u);

    // ── Sun / moon (slowest parallax layer) ────────────────────────────────
    final sunR = 9.0 * u;
    final sunC = Offset(w * 0.84, groundTop * 0.46 + (1 - p) * 10 * u);
    canvas.drawCircle(
      sunC,
      sunR * 1.9,
      Paint()
        ..color = _mix(
          scheme.tertiary,
          scheme.surface,
          0.78,
        ).withValues(alpha: 0.35 * p),
    );
    canvas.drawCircle(
      sunC,
      sunR,
      Paint()
        ..color = _mix(
          scheme.tertiary,
          scheme.surface,
          0.25,
        ).withValues(alpha: 0.85 * p),
    );

    // ── Clouds ─────────────────────────────────────────────────────────────
    final cloudPaint = Paint()
      ..color = _mix(
        scheme.surface,
        scheme.onSurface,
        0.06,
      ).withValues(alpha: 0.75 * p);
    _cloud(
      canvas,
      Offset(w * 0.18, groundTop * 0.36 + (1 - p) * 14 * u),
      11.0 * u,
      cloudPaint,
    );
    _cloud(
      canvas,
      Offset(w * 0.58, groundTop * 0.24 + (1 - p) * 18 * u),
      7.5 * u,
      cloudPaint,
    );

    // ── Far hills ──────────────────────────────────────────────────────────
    final farHill = _mix(
      scheme.primary,
      scheme.surface,
      0.66,
    ).withValues(alpha: 0.9 * p);
    final hillLift = (1 - p) * 16 * u;
    canvas.drawPath(
      _hill(w, groundTop + hillLift, w * 0.30, 26 * u, -w * 0.05, h),
      Paint()..color = farHill,
    );
    canvas.drawPath(
      _hill(w, groundTop + hillLift * 0.7, w * 0.34, 20 * u, w * 0.55, h),
      Paint()
        ..color = _mix(
          scheme.primary,
          scheme.surface,
          0.52,
        ).withValues(alpha: 0.9 * p),
    );

    // ── Ground ─────────────────────────────────────────────────────────────
    final groundLift = (1 - p) * 6 * u;
    final groundRect = Rect.fromLTRB(0, groundTop + groundLift, w, h);
    canvas.drawRect(
      groundRect,
      Paint()..color = _mix(scheme.primary, scheme.surface, 0.34),
    );
    // A soft crest on the ground line.
    canvas.drawPath(
      Path()
        ..moveTo(0, groundTop + groundLift)
        ..quadraticBezierTo(
          w * 0.5,
          groundTop + groundLift - 5 * u,
          w,
          groundTop + groundLift,
        )
        ..lineTo(w, groundTop + groundLift + 3)
        ..lineTo(0, groundTop + groundLift + 3)
        ..close(),
      Paint()..color = _mix(scheme.primary, scheme.surface, 0.34),
    );

    final baseY = groundTop + groundLift + 1;

    // Props rise from below the horizon as the pull deepens (parallax).
    final propLift = (1 - p) * 26 * u;
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, w, h));
    canvas.translate(0, propLift);

    _schoolhouse(canvas, Offset(w * 0.22, baseY), u, p);
    _books(canvas, Offset(w * 0.70, baseY), u, p);
    _tree(canvas, Offset(w * 0.87, baseY), u, p);

    canvas.restore();
  }

  void _cloud(Canvas canvas, Offset c, double r, Paint paint) {
    canvas.drawCircle(c, r, paint);
    canvas.drawCircle(c.translate(r * 0.85, r * 0.2), r * 0.72, paint);
    canvas.drawCircle(c.translate(-r * 0.85, r * 0.25), r * 0.62, paint);
  }

  Path _hill(
    double w,
    double baseY,
    double radiusX,
    double height,
    double cx,
    double h,
  ) {
    return Path()
      ..moveTo(cx - radiusX, baseY)
      ..quadraticBezierTo(cx, baseY - height, cx + radiusX, baseY)
      ..lineTo(cx + radiusX, h)
      ..lineTo(cx - radiusX, h)
      ..close();
  }

  void _schoolhouse(Canvas canvas, Offset base, double u, double p) {
    final bodyW = 40.0 * u;
    final bodyH = 26.0 * u;
    final left = base.dx - bodyW / 2;
    final top = base.dy - bodyH;

    final wall = _mix(scheme.surface, scheme.onSurface, 0.04);
    final roof = scheme.primary;
    final trim = scheme.tertiary;

    final a = (0.35 + 0.65 * p).clamp(0.0, 1.0);

    // Body
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(left, top, bodyW, bodyH),
        topLeft: Radius.circular(1.5 * u),
        topRight: Radius.circular(1.5 * u),
      ),
      Paint()..color = wall.withValues(alpha: a),
    );

    // Roof
    canvas.drawPath(
      Path()
        ..moveTo(left - 3.5 * u, top)
        ..lineTo(base.dx, top - 12.0 * u)
        ..lineTo(left + bodyW + 3.5 * u, top)
        ..close(),
      Paint()..color = roof.withValues(alpha: a),
    );

    // Bell tower + flag
    final towerW = 6.0 * u;
    final towerH = 9.0 * u;
    canvas.drawRect(
      Rect.fromLTWH(
        base.dx - towerW / 2,
        top - 12.0 * u - towerH,
        towerW,
        towerH + 2 * u,
      ),
      Paint()..color = roof.withValues(alpha: a),
    );
    final poleTop = top - 12.0 * u - towerH - 9.0 * u;
    canvas.drawLine(
      Offset(base.dx, top - 12.0 * u - towerH),
      Offset(base.dx, poleTop),
      Paint()
        ..color = scheme.onSurfaceVariant.withValues(alpha: 0.75 * a)
        ..strokeWidth = 1.2 * u,
    );
    canvas.drawPath(
      Path()
        ..moveTo(base.dx, poleTop)
        ..lineTo(base.dx + 8.0 * u, poleTop + 2.6 * u)
        ..lineTo(base.dx, poleTop + 5.2 * u)
        ..close(),
      Paint()..color = trim.withValues(alpha: a),
    );

    // Door
    final doorW = 8.0 * u;
    final doorH = 13.0 * u;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(base.dx - doorW / 2, base.dy - doorH, doorW, doorH),
        topLeft: Radius.circular(doorW / 2),
        topRight: Radius.circular(doorW / 2),
      ),
      Paint()..color = trim.withValues(alpha: 0.9 * a),
    );

    // Windows
    final winPaint = Paint()
      ..color = _mix(
        scheme.secondary,
        scheme.surface,
        0.25,
      ).withValues(alpha: 0.9 * a);
    final winW = 7.0 * u;
    final winH = 7.0 * u;
    final winY = top + bodyH * 0.28;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + 5.0 * u, winY, winW, winH),
        Radius.circular(1.2 * u),
      ),
      winPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + bodyW - 5.0 * u - winW, winY, winW, winH),
        Radius.circular(1.2 * u),
      ),
      winPaint,
    );
  }

  void _books(Canvas canvas, Offset base, double u, double p) {
    final a = (0.25 + 0.75 * p).clamp(0.0, 1.0);
    final spines = <Color>[scheme.tertiary, scheme.secondary, scheme.primary];
    final widths = <double>[20.0 * u, 16.0 * u, 18.0 * u];
    final bookH = 4.5 * u;
    var y = base.dy;
    for (var i = 0; i < spines.length; i++) {
      y -= bookH + 1.0 * u;
      final bw = widths[i];
      final dx = base.dx - bw / 2 + (i.isEven ? 1.2 * u : -1.2 * u);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(dx, y, bw, bookH),
          Radius.circular(1.2 * u),
        ),
        Paint()..color = spines[i].withValues(alpha: a),
      );
      canvas.drawLine(
        Offset(dx + 2.5 * u, y + bookH / 2),
        Offset(dx + bw - 2.5 * u, y + bookH / 2),
        Paint()
          ..color = scheme.surface.withValues(alpha: 0.45 * a)
          ..strokeWidth = 0.9 * u,
      );
    }
  }

  void _tree(Canvas canvas, Offset base, double u, double p) {
    final a = (0.3 + 0.7 * p).clamp(0.0, 1.0);
    final trunkH = 14.0 * u;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(base.dx - 1.6 * u, base.dy - trunkH, 3.2 * u, trunkH),
        Radius.circular(1.2 * u),
      ),
      Paint()
        ..color = _mix(
          scheme.tertiary,
          scheme.onSurface,
          0.35,
        ).withValues(alpha: a),
    );
    final canopy = _mix(scheme.primary, scheme.surface, 0.18);
    final cy = base.dy - trunkH - 6.0 * u;
    canvas.drawCircle(
      Offset(base.dx, cy),
      9.0 * u,
      Paint()..color = canopy.withValues(alpha: a),
    );
    canvas.drawCircle(
      Offset(base.dx - 7.0 * u, cy + 4.0 * u),
      6.0 * u,
      Paint()..color = canopy.withValues(alpha: a),
    );
    canvas.drawCircle(
      Offset(base.dx + 7.0 * u, cy + 4.5 * u),
      5.5 * u,
      Paint()..color = canopy.withValues(alpha: a),
    );
  }

  @override
  bool shouldRepaint(_CmSchoolScenePainter old) =>
      old.progress != progress || old.scheme != scheme;
}
