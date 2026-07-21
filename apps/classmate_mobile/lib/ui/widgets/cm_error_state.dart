import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/http/cm_api.dart';
import '../../l10n/app_localizations.dart';

/// The family of "something isn't right" situations the app can land in.
///
/// Each case gets its own little character + placard so the state is
/// recognisable at a glance, the way Claude's offline screen is.
enum CmErrorKind {
  /// No connectivity / the host could not be reached at all.
  offline,

  /// The backend answered, but with a 5xx.
  serverError,

  /// 404 — the thing being opened is gone.
  notFound,

  /// 401/403 — signed in, but not allowed (or the session lapsed).
  forbidden,

  /// The request took too long, or the server asked us to slow down (429).
  timeout,

  /// Nothing failed — there simply is no content yet.
  empty,

  /// Anything we could not classify.
  generic,
}

/// Classifies a caught error into a [CmErrorKind].
///
/// Deliberately dependency-free: offline detection is done from the exception
/// type name and message, never from a connectivity plugin, so this stays
/// valid on web (no `dart:io` import) as well as on mobile.
CmErrorKind cmErrorKindOf(Object? error) {
  if (error == null) return CmErrorKind.generic;

  if (error is CMApiException) {
    final code = error.statusCode;
    if (code == 401 || code == 403) return CmErrorKind.forbidden;
    if (code == 404) return CmErrorKind.notFound;
    if (code == 408 || code == 429) return CmErrorKind.timeout;
    if (code >= 500) return CmErrorKind.serverError;
    // 0 / -1 style sentinels mean "never reached the server".
    if (code <= 0) return CmErrorKind.offline;
    return CmErrorKind.generic;
  }

  if (error is TimeoutException) return CmErrorKind.timeout;

  final typeName = error.runtimeType.toString().toLowerCase();
  final text = error.toString().toLowerCase();

  bool has(String needle) => typeName.contains(needle) || text.contains(needle);

  if (has('socketexception') ||
      has('clientexception') ||
      has('handshakeexception') ||
      has('failed host lookup') ||
      has('network is unreachable') ||
      has('no address associated') ||
      has('connection refused') ||
      has('connection closed') ||
      has('connection reset') ||
      has('xmlhttprequest') ||
      has('err_internet_disconnected') ||
      has('offline')) {
    return CmErrorKind.offline;
  }

  if (has('timeout') || has('timed out') || has('deadline')) {
    return CmErrorKind.timeout;
  }

  if (has('not found')) return CmErrorKind.notFound;
  if (has('forbidden') || has('permission') || has('unauthor')) {
    return CmErrorKind.forbidden;
  }

  return CmErrorKind.generic;
}

/// A friendly, illustrated error / empty state.
///
/// Every colour is derived from [ColorScheme], so it reads correctly across
/// all nine curated themes; the illustration is drawn with a [CustomPainter]
/// so there are no new assets or packages.
class CmErrorState extends StatelessWidget {
  const CmErrorState({
    super.key,
    required this.kind,
    this.title,
    this.message,
    this.onRetry,
    this.retryLabel,
    this.compact = false,
    this.padding,
  });

  /// Builds the state straight from a caught error, picking the case for you.
  CmErrorState.fromError(
    Object? error, {
    super.key,
    this.title,
    this.message,
    this.onRetry,
    this.retryLabel,
    this.compact = false,
    this.padding,
  }) : kind = cmErrorKindOf(error);

  final CmErrorKind kind;

  /// Optional override for the localized headline.
  final String? title;

  /// Optional override for the localized body copy.
  final String? message;

  /// When non-null a retry button is shown.
  final FutureOr<void> Function()? onRetry;

  /// Optional override for the retry button label.
  final String? retryLabel;

  /// Tighter illustration + spacing, for use inside cards or sheets.
  final bool compact;

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final copy = _copyFor(l, kind);
    final art = _artFor(kind, cs);
    final artWidth = compact ? 132.0 : 176.0;

    return Center(
      child: SingleChildScrollView(
        padding: padding ??
            EdgeInsets.symmetric(horizontal: 28, vertical: compact ? 18 : 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: copy.title,
              image: true,
              child: ExcludeSemantics(
                child: SizedBox(
                  width: artWidth,
                  height: artWidth * (_kArtHeight / _kArtWidth),
                  child: CustomPaint(
                    painter: _CmCharacterPainter(art),
                  ),
                ),
              ),
            ),
            SizedBox(height: compact ? 14 : 20),
            Text(
              title ?? copy.title,
              textAlign: TextAlign.center,
              style: (compact
                      ? theme.textTheme.titleSmall
                      : theme.textTheme.titleMedium)
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Text(
                message ?? copy.body,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: compact ? 14 : 20),
              FilledButton.icon(
                onPressed: () => onRetry!(),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(retryLabel ?? l.commonRetry),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _CmErrorCopy _copyFor(AppLocalizations l, CmErrorKind kind) {
    return switch (kind) {
      CmErrorKind.offline =>
        _CmErrorCopy(l.errStateOfflineTitle, l.errStateOfflineBody),
      CmErrorKind.serverError =>
        _CmErrorCopy(l.errStateServerTitle, l.errStateServerBody),
      CmErrorKind.notFound =>
        _CmErrorCopy(l.errStateNotFoundTitle, l.errStateNotFoundBody),
      CmErrorKind.forbidden =>
        _CmErrorCopy(l.errStateForbiddenTitle, l.errStateForbiddenBody),
      CmErrorKind.timeout =>
        _CmErrorCopy(l.errStateTimeoutTitle, l.errStateTimeoutBody),
      CmErrorKind.empty =>
        _CmErrorCopy(l.errStateEmptyTitle, l.errStateEmptyBody),
      CmErrorKind.generic =>
        _CmErrorCopy(l.errStateGenericTitle, l.errStateGenericBody),
    };
  }
}

class _CmErrorCopy {
  const _CmErrorCopy(this.title, this.body);
  final String title;
  final String body;
}

/// Mouth shapes give each character its personality.
enum _Mood { smile, flat, worried, surprised, sleepy }

/// Everything the painter needs — all colours already resolved from the theme.
class _CmArt {
  const _CmArt({
    required this.body,
    required this.onBody,
    required this.sign,
    required this.signBorder,
    required this.glyphColor,
    required this.shadow,
    required this.glyph,
    required this.mood,
    required this.tilt,
    required this.armsUp,
  });

  final Color body;
  final Color onBody;
  final Color sign;
  final Color signBorder;
  final Color glyphColor;
  final Color shadow;
  final IconData glyph;
  final _Mood mood;

  /// Placard tilt in radians — a little wonkiness reads as hand-held.
  final double tilt;

  /// Both arms raised (holding the sign overhead) vs one arm.
  final bool armsUp;
}

_CmArt _artFor(CmErrorKind kind, ColorScheme cs) {
  final (Color accent, IconData glyph, _Mood mood, double tilt, bool armsUp) =
      switch (kind) {
    CmErrorKind.offline => (
        cs.secondary,
        Icons.wifi_off_rounded,
        _Mood.worried,
        -0.07,
        true,
      ),
    CmErrorKind.serverError => (
        cs.error,
        Icons.cloud_off_rounded,
        _Mood.surprised,
        0.08,
        true,
      ),
    CmErrorKind.notFound => (
        cs.tertiary,
        Icons.travel_explore_rounded,
        _Mood.flat,
        -0.05,
        false,
      ),
    CmErrorKind.forbidden => (
        cs.error,
        Icons.lock_rounded,
        _Mood.flat,
        0.0,
        true,
      ),
    CmErrorKind.timeout => (
        cs.secondary,
        Icons.hourglass_bottom_rounded,
        _Mood.sleepy,
        0.05,
        false,
      ),
    CmErrorKind.empty => (
        cs.primary,
        Icons.auto_awesome_rounded,
        _Mood.smile,
        -0.04,
        true,
      ),
    CmErrorKind.generic => (
        cs.primary,
        Icons.help_outline_rounded,
        _Mood.worried,
        0.06,
        true,
      ),
  };

  // Blend the accent onto the surface so pastel light themes (Rosé, Matcha)
  // and inky dark ones (Midnight, Nord) both keep a readable character.
  final body = Color.alphaBlend(accent.withValues(alpha: 0.88), cs.surface);
  final onBody =
      ThemeData.estimateBrightnessForColor(body) == Brightness.dark
          ? cs.surface
          : cs.onSurface;

  return _CmArt(
    body: body,
    onBody: onBody,
    sign: cs.surfaceContainerHighest,
    signBorder: cs.outlineVariant,
    glyphColor: cs.onSurfaceVariant,
    shadow: cs.shadow.withValues(alpha: 0.10),
    glyph: glyph,
    mood: mood,
    tilt: tilt,
    armsUp: armsUp,
  );
}

// Design canvas the painter is authored against; it scales to any box.
const double _kArtWidth = 176;
const double _kArtHeight = 168;

class _CmCharacterPainter extends CustomPainter {
  _CmCharacterPainter(this.art);

  final _CmArt art;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / _kArtWidth, size.height / _kArtHeight);
    canvas.save();
    canvas.translate(
      (size.width - _kArtWidth * scale) / 2,
      (size.height - _kArtHeight * scale) / 2,
    );
    canvas.scale(scale);

    _paintShadow(canvas);
    _paintArms(canvas);
    _paintBody(canvas);
    _paintFace(canvas);
    _paintSign(canvas);

    canvas.restore();
  }

  void _paintShadow(Canvas canvas) {
    canvas.drawOval(
      Rect.fromCenter(
          center: const Offset(88, 158), width: 86, height: 13),
      Paint()..color = art.shadow,
    );
  }

  // Two stubby arms reaching up to the placard.
  void _paintArms(Canvas canvas) {
    final paint = Paint()
      ..color = art.body
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      Path()
        ..moveTo(62, 116)
        ..quadraticBezierTo(44, 104, art.armsUp ? 46 : 40, art.armsUp ? 74 : 100),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(114, 116)
        ..quadraticBezierTo(132, 104, 130, art.armsUp ? 74 : 96),
      paint,
    );
  }

  void _paintBody(Canvas canvas) {
    final bodyPaint = Paint()..color = art.body;

    // Rounded blob torso.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: const Offset(88, 122), width: 76, height: 72),
        const Radius.circular(30),
      ),
      bodyPaint,
    );

    // Little feet.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(72, 156), width: 24, height: 13),
      bodyPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(104, 156), width: 24, height: 13),
      bodyPaint,
    );

    // A soft highlight so the body doesn't read as a flat rectangle.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(70, 104), width: 26, height: 16),
      Paint()..color = art.onBody.withValues(alpha: 0.10),
    );
  }

  void _paintFace(Canvas canvas) {
    final ink = Paint()..color = art.onBody;
    final stroke = Paint()
      ..color = art.onBody
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round;

    const leftEye = Offset(75, 118);
    const rightEye = Offset(101, 118);

    switch (art.mood) {
      case _Mood.sleepy:
        // Closed, contented arcs.
        for (final eye in const [leftEye, rightEye]) {
          canvas.drawArc(
            Rect.fromCenter(center: eye, width: 15, height: 12),
            math.pi,
            math.pi,
            false,
            stroke,
          );
        }
      case _Mood.surprised:
        canvas.drawCircle(leftEye, 5.4, ink);
        canvas.drawCircle(rightEye, 5.4, ink);
      default:
        canvas.drawCircle(leftEye, 4.2, ink);
        canvas.drawCircle(rightEye, 4.2, ink);
    }

    switch (art.mood) {
      case _Mood.smile:
        canvas.drawArc(
          Rect.fromCenter(
              center: const Offset(88, 130), width: 26, height: 20),
          0.15,
          math.pi - 0.3,
          false,
          stroke,
        );
      case _Mood.worried:
        canvas.drawArc(
          Rect.fromCenter(
              center: const Offset(88, 141), width: 24, height: 18),
          math.pi + 0.2,
          math.pi - 0.4,
          false,
          stroke,
        );
      case _Mood.surprised:
        canvas.drawOval(
          Rect.fromCenter(
              center: const Offset(88, 134), width: 13, height: 15),
          stroke,
        );
      case _Mood.sleepy:
        canvas.drawArc(
          Rect.fromCenter(
              center: const Offset(88, 131), width: 18, height: 14),
          0.2,
          math.pi - 0.4,
          false,
          stroke,
        );
      case _Mood.flat:
        canvas.drawLine(
            const Offset(80, 134), const Offset(96, 134), stroke);
    }
  }

  // The placard: a stick, a board, and a per-case glyph painted from the
  // Material icon font (no asset needed).
  void _paintSign(Canvas canvas) {
    canvas.save();
    canvas.translate(88, 52);
    canvas.rotate(art.tilt);
    canvas.translate(-88, -52);

    // Handle.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(88, 80), width: 8, height: 36),
        const Radius.circular(4),
      ),
      Paint()..color = art.signBorder,
    );

    final board = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(88, 48), width: 108, height: 62),
      const Radius.circular(16),
    );
    canvas.drawRRect(board, Paint()..color = art.sign);
    canvas.drawRRect(
      board,
      Paint()
        ..color = art.signBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );

    _paintGlyph(canvas, const Offset(88, 48), 34);
    canvas.restore();
  }

  void _paintGlyph(Canvas canvas, Offset center, double fontSize) {
    final painter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(art.glyph.codePoint),
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: art.glyph.fontFamily,
          package: art.glyph.fontPackage,
          color: art.glyphColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _CmCharacterPainter oldDelegate) =>
      oldDelegate.art.body != art.body ||
      oldDelegate.art.sign != art.sign ||
      oldDelegate.art.glyph != art.glyph ||
      oldDelegate.art.mood != art.mood ||
      oldDelegate.art.tilt != art.tilt ||
      oldDelegate.art.armsUp != art.armsUp ||
      oldDelegate.art.glyphColor != art.glyphColor;
}
