import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Ambient background "life" — floating educational symbols (treble note,
/// calculator, `</>`, a laptop, ∫ π √ Σ …), stars, curved lines, rings, dots
/// and soft gradient blobs, all in the current theme's colours and each with
/// its own gentle animation (float, drift, sway, pulse, shimmer).
///
/// One painter, one repaint ticker — cheap enough to sit behind a whole
/// screen. Used on the launch splash, the login page and the NOVA thread.
///
/// Honors reduce-motion: pass [animate] false and the field renders as a
/// static composition (same layout, no movement).
class AmbientSymbols extends StatefulWidget {
  const AmbientSymbols({
    super.key,
    this.scheme,
    this.animate = true,
    this.seed = 7,
    this.density = 1.0,
    this.opacity = 1.0,
    this.blobs = true,
  });

  /// Explicit palette for surfaces that render before the MaterialApp exists
  /// (the splash). Defaults to the ambient theme.
  final ColorScheme? scheme;

  /// False → static composition (reduce-motion).
  final bool animate;

  /// Different seeds → different scatter layouts, so screens don't all look
  /// like the same wallpaper.
  final int seed;

  /// Scales how many symbols are placed (1.0 ≈ 22 items on a phone).
  final double density;

  /// Master opacity multiplier — drop below 1 on busy screens (chat).
  final double opacity;

  /// Whether to paint the large corner gradient blobs under the symbols.
  final bool blobs;

  @override
  State<AmbientSymbols> createState() => _AmbientSymbolsState();
}

class _AmbientSymbolsState extends State<AmbientSymbols>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    // One slow master loop; every item derives its own motion from it via a
    // personal phase + speed, so nothing ever visibly "restarts".
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    );
    if (widget.animate) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(AmbientSymbols old) {
    super.didUpdateWidget(old);
    if (widget.animate && !_ctrl.isAnimating) {
      _ctrl.repeat();
    } else if (!widget.animate && _ctrl.isAnimating) {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = widget.scheme ?? Theme.of(context).colorScheme;
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _AmbientPainter(
            repaint: _ctrl,
            scheme: scheme,
            seed: widget.seed,
            density: widget.density,
            opacity: widget.opacity,
            blobs: widget.blobs,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Painter
// ─────────────────────────────────────────────────────────────────────────────

enum _Kind { icon, glyph, ring, dot, star, curve }

enum _Motion { floaty, drift, sway, pulse, shimmer }

class _Item {
  _Item({
    required this.kind,
    required this.motion,
    required this.fx,
    required this.fy,
    required this.size,
    required this.colorSlot,
    required this.alpha,
    required this.phase,
    required this.speed,
    required this.tilt,
    this.icon,
    this.glyph,
  });

  final _Kind kind;
  final _Motion motion;
  final double fx, fy; // fractional position
  final double size;
  final int colorSlot; // 0 primary · 1 secondary · 2 tertiary
  final double alpha;
  final double phase; // 0..1
  final double speed; // motion cycles per master loop
  final double tilt; // resting rotation, radians
  final IconData? icon;
  final String? glyph;
}

class _AmbientPainter extends CustomPainter {
  _AmbientPainter({
    required Listenable repaint,
    required this.scheme,
    required this.seed,
    required this.density,
    required this.opacity,
    required this.blobs,
  })  : _t = repaint is Animation<double> ? repaint : null,
        super(repaint: repaint);

  final ColorScheme scheme;
  final int seed;
  final double density;
  final double opacity;
  final bool blobs;
  final Animation<double>? _t;

  // The classroom universe: music, math, code, science, reading, ideas.
  static const _icons = <IconData>[
    Icons.music_note_rounded,
    Icons.calculate_rounded,
    Icons.code_rounded,
    Icons.laptop_mac_rounded,
    Icons.functions_rounded,
    Icons.science_rounded,
    Icons.school_rounded,
    Icons.auto_stories_rounded,
    Icons.lightbulb_rounded,
    Icons.public_rounded,
    Icons.psychology_rounded,
    Icons.rocket_launch_rounded,
    Icons.edit_rounded,
    Icons.piano_rounded,
  ];

  // Unicode picks that render reliably in the platform fallback fonts.
  static const _glyphs = <String>['∫', 'π', '√', 'Σ', '♪', '♫', '÷', 'x²', '∞', 'αβ'];

  List<_Item>? _items;
  Size _builtFor = Size.zero;

  List<_Item> _buildItems(Size size) {
    if (_items != null && _builtFor == size) return _items!;
    final rnd = math.Random(seed * 1000003 + size.width.round());
    final count = (22 * density).round();
    final items = <_Item>[];
    for (var i = 0; i < count; i++) {
      // Round-robin through the kinds so every screen gets the full mix.
      final kind = switch (i % 6) {
        0 || 1 => _Kind.icon, // icons get double weight
        2 => _Kind.glyph,
        3 => _Kind.star,
        4 => rnd.nextBool() ? _Kind.ring : _Kind.dot,
        _ => _Kind.curve,
      };
      items.add(_Item(
        kind: kind,
        motion: _Motion.values[rnd.nextInt(_Motion.values.length)],
        fx: 0.04 + rnd.nextDouble() * 0.92,
        fy: 0.03 + rnd.nextDouble() * 0.94,
        size: switch (kind) {
          _Kind.icon => 16.0 + rnd.nextDouble() * 14,
          _Kind.glyph => 15.0 + rnd.nextDouble() * 12,
          _Kind.star => 8.0 + rnd.nextDouble() * 9,
          _Kind.ring => 18.0 + rnd.nextDouble() * 34,
          _Kind.dot => 4.0 + rnd.nextDouble() * 6,
          _Kind.curve => 46.0 + rnd.nextDouble() * 60,
        },
        colorSlot: rnd.nextInt(3),
        alpha: 0.10 + rnd.nextDouble() * 0.12,
        phase: rnd.nextDouble(),
        speed: 2.0 + rnd.nextDouble() * 3.0,
        tilt: (rnd.nextDouble() - 0.5) * 0.7,
        icon: kind == _Kind.icon ? _icons[i % _icons.length] : null,
        glyph: kind == _Kind.glyph
            ? _glyphs[rnd.nextInt(_glyphs.length)]
            : null,
      ));
    }
    _items = items;
    _builtFor = size;
    return items;
  }

  Color _slot(int slot) => switch (slot) {
        0 => scheme.primary,
        1 => scheme.secondary,
        _ => scheme.tertiary,
      };

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final t = _t?.value ?? 0.0;

    if (blobs) _paintBlobs(canvas, size, t);

    for (final item in _buildItems(size)) {
      final cycle = (t * item.speed + item.phase) % 1.0;
      final wave = math.sin(cycle * 2 * math.pi);
      final wave2 = math.cos(cycle * 2 * math.pi);

      var dx = 0.0, dy = 0.0, scale = 1.0, rot = item.tilt;
      var alpha = item.alpha;
      switch (item.motion) {
        case _Motion.floaty:
          dy = wave * 9;
        case _Motion.drift:
          dx = wave * 11;
          dy = wave2 * 6;
        case _Motion.sway:
          rot += wave * 0.22;
          dy = wave2 * 4;
        case _Motion.pulse:
          scale = 1.0 + wave * 0.12;
        case _Motion.shimmer:
          alpha = item.alpha * (0.55 + 0.45 * (wave * 0.5 + 0.5));
      }
      alpha = (alpha * opacity).clamp(0.0, 1.0);
      if (alpha <= 0.005) continue;

      final color = _slot(item.colorSlot).withValues(alpha: alpha);
      final cx = item.fx * size.width + dx;
      final cy = item.fy * size.height + dy;

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(rot);
      canvas.scale(scale);
      switch (item.kind) {
        case _Kind.icon:
          _paintGlyph(
            canvas,
            String.fromCharCode(item.icon!.codePoint),
            item.size,
            color,
            fontFamily: item.icon!.fontFamily,
            package: item.icon!.fontPackage,
          );
        case _Kind.glyph:
          _paintGlyph(canvas, item.glyph!, item.size, color);
        case _Kind.ring:
          canvas.drawCircle(
            Offset.zero,
            item.size / 2,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.6
              ..color = color,
          );
        case _Kind.dot:
          canvas.drawCircle(Offset.zero, item.size / 2, Paint()..color = color);
        case _Kind.star:
          _paintStar(canvas, item.size, color);
        case _Kind.curve:
          _paintCurve(canvas, item.size, color);
      }
      canvas.restore();
    }
  }

  void _paintBlobs(Canvas canvas, Size size, double t) {
    final pulse = 1.0 + 0.05 * math.sin(t * 2 * math.pi);
    void blob(Offset c, double r, Color color, double a) {
      canvas.drawCircle(
        c,
        r * pulse,
        Paint()
          ..shader = RadialGradient(
            colors: [color.withValues(alpha: a * opacity), color.withValues(alpha: 0)],
          ).createShader(Rect.fromCircle(center: c, radius: r * pulse)),
      );
    }

    blob(Offset(size.width * 0.06, size.height * 0.04), size.width * 0.46,
        scheme.primary, 0.30);
    blob(Offset(size.width * 0.98, size.height * 0.92), size.width * 0.52,
        scheme.tertiary, 0.28);
    blob(Offset(size.width * 1.02, size.height * 0.26), size.width * 0.26,
        scheme.secondary, 0.24);
  }

  void _paintGlyph(
    Canvas canvas,
    String text,
    double fontSize,
    Color color, {
    String? fontFamily,
    String? package,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: FontWeight.w600,
          fontFamily: package == null ? fontFamily : 'packages/$package/$fontFamily',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
  }

  void _paintStar(Canvas canvas, double size, Color color) {
    final r = size / 2, inner = r * 0.42;
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final radius = i.isEven ? r : inner;
      final a = -math.pi / 2 + i * math.pi / 5;
      final p = Offset(math.cos(a) * radius, math.sin(a) * radius);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _paintCurve(Canvas canvas, double size, Color color) {
    // A relaxed S-curve — reads as a hand-drawn swash between the symbols.
    final w = size, h = size * 0.4;
    final path = Path()
      ..moveTo(-w / 2, h / 4)
      ..cubicTo(-w / 6, -h / 2, w / 6, h / 2, w / 2, -h / 4);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_AmbientPainter old) =>
      old.scheme != scheme ||
      old.seed != seed ||
      old.density != density ||
      old.opacity != opacity ||
      old.blobs != blobs;
}
