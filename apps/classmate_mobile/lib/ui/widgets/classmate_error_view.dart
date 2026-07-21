import 'dart:async' show TimeoutException;

import 'package:flutter/material.dart';

import '../../core/http/cm_api.dart';
import '../../l10n/app_localizations.dart';

/// The category of a failure, used to pick the mascot's mood, the sign it
/// holds, and the copy shown to the user.
enum CmErrorKind { offline, timeout, server, notFound, busy, generic }

/// Classifies any thrown error into a [CmErrorKind] so the UI can show a
/// friendly, specific character instead of a raw stack trace. Keys off
/// [CMApiException.statusCode] first, then well-known exception types, then a
/// last-resort string sniff.
CmErrorKind cmErrorKindOf(Object? error) {
  if (error == null) return CmErrorKind.generic;
  // Note: SocketException (dart:io) is intentionally matched via the string
  // sniff below rather than a typed `is` check, so this widget stays safe to
  // compile on the web target where dart:io is unavailable.
  if (error is TimeoutException) return CmErrorKind.timeout;
  if (error is CMApiException) {
    final sc = error.statusCode;
    if (sc == 404) return CmErrorKind.notFound;
    if (sc == 429) return CmErrorKind.busy;
    if (sc >= 500) return CmErrorKind.server;
    if (sc == 0) return CmErrorKind.offline; // no response reached the server
  }
  final s = error.toString().toLowerCase();
  if (s.contains('socketexception') ||
      s.contains('failed host lookup') ||
      s.contains('network is unreachable') ||
      s.contains('no address associated') ||
      s.contains('connection refused') ||
      s.contains('connection closed')) {
    return CmErrorKind.offline;
  }
  if (s.contains('timeout') || s.contains('timed out')) {
    return CmErrorKind.timeout;
  }
  if (s.contains(' 429') || s.contains('too many requests')) {
    return CmErrorKind.busy;
  }
  if (s.contains(' 500') || s.contains(' 502') || s.contains(' 503')) {
    return CmErrorKind.server;
  }
  return CmErrorKind.generic;
}

/// A friendly, brand-drawn error/empty state: a little ClassMate mascot whose
/// mood + held sign change with the kind of failure (offline, timeout, server,
/// busy, not-found, generic) — the same idea as Claude's offline character. No
/// image assets; everything is painted so it themes automatically.
class ClassMateErrorView extends StatelessWidget {
  const ClassMateErrorView({
    super.key,
    this.error,
    this.kind,
    this.title,
    this.message,
    this.onRetry,
    this.compact = false,
  });

  /// The thrown error to classify (ignored if [kind] is given).
  final Object? error;

  /// Force a specific kind (e.g. for an empty state) instead of classifying.
  final CmErrorKind? kind;

  /// Optional overrides for the auto-selected copy.
  final String? title;
  final String? message;

  /// Retry callback — when null, no retry button is shown.
  final VoidCallback? onRetry;

  /// Tighter layout for inline/banner contexts.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final k = kind ?? cmErrorKindOf(error);
    final spec = _specFor(k, l, cs);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 16 : 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Mascot(mood: spec.mood, tint: spec.tint, sign: spec.icon),
            SizedBox(height: compact ? 10 : 16),
            Text(
              title ?? spec.title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              message ?? spec.body,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
            if (onRetry != null) ...[
              SizedBox(height: compact ? 12 : 18),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l.commonRetry),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _ErrorSpec _specFor(CmErrorKind k, AppLocalizations l, ColorScheme cs) {
    switch (k) {
      case CmErrorKind.offline:
        return _ErrorSpec(
          mood: _Mood.sad,
          tint: cs.primary,
          icon: Icons.wifi_off_rounded,
          title: l.errorOfflineTitle,
          body: l.loginConnectionError,
        );
      case CmErrorKind.timeout:
        return _ErrorSpec(
          mood: _Mood.sleepy,
          tint: cs.tertiary,
          icon: Icons.hourglass_bottom_rounded,
          title: l.errorTimeoutTitle,
          body: l.loginTimeoutError,
        );
      case CmErrorKind.server:
        return _ErrorSpec(
          mood: _Mood.worried,
          tint: cs.error,
          icon: Icons.build_rounded,
          title: l.errorServerTitle,
          body: l.errorServerBody,
        );
      case CmErrorKind.busy:
        return _ErrorSpec(
          mood: _Mood.happy,
          tint: cs.tertiary,
          icon: Icons.hourglass_top_rounded,
          title: l.errorBusyTitle,
          body: l.chatThreadLoadFailedBusy,
        );
      case CmErrorKind.notFound:
        return _ErrorSpec(
          mood: _Mood.confused,
          tint: cs.secondary,
          icon: Icons.search_off_rounded,
          title: l.errorNotFoundTitle,
          body: l.errorNotFoundBody,
        );
      case CmErrorKind.generic:
        return _ErrorSpec(
          mood: _Mood.neutral,
          tint: cs.primary,
          icon: Icons.sentiment_dissatisfied_rounded,
          title: l.commonError,
          body: l.chatThreadLoadFailedBody,
        );
    }
  }
}

enum _Mood { neutral, sad, worried, sleepy, happy, confused }

class _ErrorSpec {
  const _ErrorSpec({
    required this.mood,
    required this.tint,
    required this.icon,
    required this.title,
    required this.body,
  });

  final _Mood mood;
  final Color tint;
  final IconData icon;
  final String title;
  final String body;
}

class _Mascot extends StatelessWidget {
  const _Mascot({required this.mood, required this.tint, required this.sign});

  final _Mood mood;
  final Color tint;
  final IconData sign;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 132,
      height: 116,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(96, 96),
            painter: _MascotPainter(
              mood: mood,
              tint: tint,
              surface: cs.surface,
              onTint: cs.onPrimary,
            ),
          ),
          // The little sign the mascot holds — a rounded card with an icon,
          // tilted like it's being held up.
          Positioned(
            right: 2,
            bottom: 6,
            child: Transform.rotate(
              angle: 0.18,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: tint.withValues(alpha: 0.55), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(sign, size: 20, color: tint),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MascotPainter extends CustomPainter {
  _MascotPainter({
    required this.mood,
    required this.tint,
    required this.surface,
    required this.onTint,
  });

  final _Mood mood;
  final Color tint;
  final Color surface;
  final Color onTint;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Rounded-square head — the ClassMate monogram silhouette.
    final headRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.14, h * 0.12, w * 0.72, h * 0.72),
      Radius.circular(w * 0.26),
    );
    final headPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [tint, Color.lerp(tint, Colors.black, 0.18) ?? tint],
      ).createShader(headRect.outerRect);
    canvas.drawRRect(headRect, headPaint);

    // Little antenna dot.
    final antennaPaint = Paint()..color = tint;
    canvas.drawLine(
      Offset(w * 0.5, h * 0.12),
      Offset(w * 0.5, h * 0.03),
      antennaPaint..strokeWidth = 2.4..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(w * 0.5, h * 0.02), 3.2, Paint()..color = tint);

    // Eyes.
    final eyeWhite = Paint()..color = surface;
    final pupil = Paint()..color = Color.lerp(tint, Colors.black, 0.55) ?? tint;
    final eyeY = h * 0.40;
    final lx = w * 0.37, rx = w * 0.63;
    final eyeR = w * 0.09;

    if (mood == _Mood.sleepy) {
      // Closed, sleepy eyes — two soft arcs.
      final lidPaint = Paint()
        ..color = surface
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round;
      for (final cx in [lx, rx]) {
        final p = Path()
          ..moveTo(cx - eyeR, eyeY)
          ..quadraticBezierTo(cx, eyeY + eyeR * 0.9, cx + eyeR, eyeY);
        canvas.drawPath(p, lidPaint);
      }
    } else if (mood == _Mood.happy) {
      // Happy: one normal eye + a wink arc.
      canvas.drawCircle(Offset(lx, eyeY), eyeR, eyeWhite);
      canvas.drawCircle(Offset(lx, eyeY), eyeR * 0.5, pupil);
      final wink = Paint()
        ..color = surface
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round;
      final p = Path()
        ..moveTo(rx - eyeR, eyeY)
        ..quadraticBezierTo(rx, eyeY - eyeR * 0.9, rx + eyeR, eyeY);
      canvas.drawPath(p, wink);
    } else {
      // Open eyes; pupils shift with mood.
      final dx = mood == _Mood.confused ? eyeR * 0.35 : 0.0;
      final dy = mood == _Mood.sad ? eyeR * 0.30 : 0.0;
      for (final cx in [lx, rx]) {
        canvas.drawCircle(Offset(cx, eyeY), eyeR, eyeWhite);
        canvas.drawCircle(Offset(cx + dx, eyeY + dy), eyeR * 0.5, pupil);
      }
      if (mood == _Mood.worried) {
        // Angled brows.
        final brow = Paint()
          ..color = surface
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(lx - eyeR, eyeY - eyeR * 1.5),
            Offset(lx + eyeR, eyeY - eyeR * 0.9), brow);
        canvas.drawLine(Offset(rx + eyeR, eyeY - eyeR * 1.5),
            Offset(rx - eyeR, eyeY - eyeR * 0.9), brow);
      }
    }

    // Mouth — curvature per mood.
    final mouth = Paint()
      ..color = surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    final my = h * 0.62;
    final mw = w * 0.16;
    final path = Path()..moveTo(w * 0.5 - mw, my);
    switch (mood) {
      case _Mood.happy:
        path.quadraticBezierTo(w * 0.5, my + mw * 0.9, w * 0.5 + mw, my);
        break;
      case _Mood.sad:
      case _Mood.worried:
        path.quadraticBezierTo(w * 0.5, my - mw * 0.8, w * 0.5 + mw, my);
        break;
      case _Mood.confused:
        // Wavy, unsure mouth.
        path
          ..quadraticBezierTo(w * 0.5 - mw * 0.3, my + mw * 0.5, w * 0.5, my)
          ..quadraticBezierTo(
              w * 0.5 + mw * 0.3, my - mw * 0.5, w * 0.5 + mw, my);
        break;
      case _Mood.sleepy:
        // Small "o".
        canvas.drawCircle(Offset(w * 0.5, my + 2), mw * 0.3, mouth);
        return;
      case _Mood.neutral:
        path.lineTo(w * 0.5 + mw, my);
        break;
    }
    canvas.drawPath(path, mouth);
  }

  @override
  bool shouldRepaint(covariant _MascotPainter old) =>
      old.mood != mood || old.tint != tint || old.surface != surface;
}
