import 'package:flutter/material.dart';

/// Animated scroll-to-bottom FAB used across DM, classroom, and NOVA.
///
/// Shows a downward-chevron pill that slides in from the bottom when there
/// are messages below the viewport. When [hasUnreadBelow] is true, a pulsing
/// dot badge appears on the top-right corner.
class ChatScrollToBottomFab extends StatefulWidget {
  const ChatScrollToBottomFab({
    super.key,
    required this.show,
    required this.hasUnreadBelow,
    required this.bottomInset,
    required this.onPressed,
    required this.heroTag,
    this.unreadCount = 0,
  });

  final bool show;
  final bool hasUnreadBelow;
  final double bottomInset;
  final VoidCallback onPressed;
  final String heroTag;
  /// Optional unread count shown on the badge (capped at 9+).
  final int unreadCount;

  @override
  State<ChatScrollToBottomFab> createState() => _ChatScrollToBottomFabState();
}

class _ChatScrollToBottomFabState extends State<ChatScrollToBottomFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _slide = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    if (widget.show) _ctrl.forward();
  }

  @override
  void didUpdateWidget(ChatScrollToBottomFab old) {
    super.didUpdateWidget(old);
    if (widget.show && !old.show) {
      _ctrl.forward();
    } else if (!widget.show && old.show) {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Extra bottom padding: rises above the composer + keyboard
    final extraBottom = widget.bottomInset > 0 ? 96.0 : 78.0;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        if (_ctrl.value == 0 && !widget.show) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(bottom: extraBottom),
          child: FadeTransition(
            opacity: _fade,
            child: Transform.translate(
              offset: Offset(0, _slide.value),
              child: GestureDetector(
                onTap: widget.onPressed,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // ── Main pill ───────────────────────────────────
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: cs.onSurface,
                        size: 24,
                      ),
                    ),
                    // ── Unread badge ────────────────────────────────
                    if (widget.hasUnreadBelow)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: _UnreadBadge(
                          count: widget.unreadCount,
                          color: cs.primary,
                          surface: cs.surfaceContainerHighest,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _UnreadBadge extends StatefulWidget {
  const _UnreadBadge({
    required this.count,
    required this.color,
    required this.surface,
  });

  final int count;
  final Color color;
  final Color surface;

  @override
  State<_UnreadBadge> createState() => _UnreadBadgeState();
}

class _UnreadBadgeState extends State<_UnreadBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.count > 9 ? '9+' : (widget.count > 0 ? '${widget.count}' : '');
    final hasCount = label.isNotEmpty;

    return ScaleTransition(
      scale: _scale,
      child: Container(
        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
        padding: hasCount
            ? const EdgeInsets.symmetric(horizontal: 4, vertical: 1)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: widget.surface, width: 1.5),
        ),
        child: hasCount
            ? Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              )
            : const SizedBox(width: 8, height: 8),
      ),
    );
  }
}
