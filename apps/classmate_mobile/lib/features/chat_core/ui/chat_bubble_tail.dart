import 'package:flutter/material.dart';

/// The little pointer that marks a chat bubble's sender.
///
/// Deliberately drawn as its OWN piece: a small curved flick that floats just
/// off the bubble's top corner with a hairline of background between them, so
/// the pair reads as two clean shapes — bubble + tail — rather than one blob
/// with a growth. (An earlier iteration welded the tail into the bubble
/// silhouette; the detached look is the requested design.)
///
/// Only the FIRST bubble of a run from the same sender gets one; the rest of
/// the run stays tailless and tucks in close, which is what visually groups
/// them.
class ChatBubbleTail extends StatelessWidget {
  const ChatBubbleTail({
    super.key,
    required this.color,
    required this.pointRight,
    this.width = 10,
    this.height = 13,
  });

  final Color color;

  /// Which physical side the tail hangs off. Not derivable from "is this mine"
  /// alone: in RTL locales own bubbles sit on the LEFT, so the tail has to
  /// mirror with them or it points away from the wrong edge.
  final bool pointRight;

  final double width;
  final double height;

  /// The visible breathing space between the bubble edge and the tail's base,
  /// kept inside this widget's own box so bubble rows don't need to manage it.
  static const double gap = 2.5;

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

    const g = ChatBubbleTail.gap;
    final w = size.width;
    final h = size.height;

    // A small comma: flat-ish rounded base on the bubble side (inset by the
    // gap), sweeping out to a soft tip and curling back under. Drawn for the
    // point-right case; mirrored below for point-left.
    final path = Path()
      ..moveTo(g, 1.0)
      ..quadraticBezierTo(w * 0.72, -0.4, w - 0.6, 1.6)
      ..quadraticBezierTo(w * 0.46, h * 0.34, g, h * 0.86)
      ..quadraticBezierTo(g - 1.2, h * 0.45, g, 1.0)
      ..close();

    if (!pointRight) {
      // Mirror horizontally about the box's centre.
      canvas.save();
      canvas.translate(w, 0);
      canvas.scale(-1, 1);
      canvas.drawPath(path, paint);
      canvas.restore();
      return;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TailPainter old) =>
      old.color != color || old.pointRight != pointRight;
}
