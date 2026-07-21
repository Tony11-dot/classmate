import 'package:flutter/material.dart';

/// The little pointer that joins a chat bubble to its sender — the single
/// most recognisable part of the WhatsApp bubble, and the thing whose absence
/// made every message here read as a generic rounded card.
///
/// Only the FIRST bubble of a run from the same sender gets one; the rest of
/// the run stays tailless and tucks in close, which is what visually groups
/// them. Draw it beside the bubble (not inside), so it never eats padding or
/// clips content.
class ChatBubbleTail extends StatelessWidget {
  const ChatBubbleTail({
    super.key,
    required this.color,
    required this.pointRight,
    this.width = 8,
    this.height = 13,
  });

  final Color color;

  /// Which physical side the tail hangs off. Not derivable from "is this mine"
  /// alone: in RTL locales own bubbles sit on the LEFT, so the tail has to
  /// mirror with them or it points away from the wrong edge.
  final bool pointRight;

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _TailPainter(color: color, pointRight: pointRight),
        ),
      );
}

class _TailPainter extends CustomPainter {
  const _TailPainter({required this.color, required this.pointRight});

  final Color color;
  final bool pointRight;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..isAntiAlias = true;

    final path = Path();
    if (pointRight) {
      // Flows out of the bubble's top-right corner and curls back under.
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.30,
        0,
        size.height,
      );
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(0, 0);
      path.quadraticBezierTo(
        size.width * 0.55,
        size.height * 0.30,
        size.width,
        size.height,
      );
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TailPainter old) =>
      old.color != color || old.pointRight != pointRight;
}
