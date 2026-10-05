import 'package:flutter/material.dart';

/// Wraps a tappable surface with a subtle spring-scale on press — the tactile
/// "squish" that makes cards and buttons feel alive (Apple HIG scale-feedback).
///
/// Honours reduce-motion: when the platform/app disables animations the scale
/// is skipped and it behaves as a plain tap target. Hit testing stays opaque so
/// the whole child area is tappable. Use around cards, list tiles and custom
/// buttons; it does not draw any ink splash, so it composes with any surface.
class CmPress extends StatefulWidget {
  const CmPress({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = 0.97,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;
  final bool enabled;

  @override
  State<CmPress> createState() => _CmPressState();
}

class _CmPressState extends State<CmPress> {
  bool _down = false;

  bool get _interactive =>
      widget.enabled && (widget.onTap != null || widget.onLongPress != null);

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final target = (_down && _interactive && !reduceMotion) ? widget.scale : 1.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _interactive ? (_) => _set(true) : null,
      onTapUp: _interactive ? (_) => _set(false) : null,
      onTapCancel: _interactive ? () => _set(false) : null,
      onTap: widget.enabled ? widget.onTap : null,
      onLongPress: widget.enabled ? widget.onLongPress : null,
      child: AnimatedScale(
        scale: target,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
