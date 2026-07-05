import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/lifedoc/notifications_models.dart';
import '../../l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Route helper — maps notification source → app route
// ─────────────────────────────────────────────────────────────────────────────

String notificationRoute(StudentNotificationItem item) {
  final src = item.source.trim().toLowerCase();
  return switch (src) {
    'grades' => '/grades',
    'attendance' => '/attendance',
    'practice' => '/practice',
    'solutions' => '/solutions',
    'messages' || 'chat' => '/messages',
    'classrooms' || 'classroom' => '/classrooms',
    'assignments' || 'assignment' => '/assignments',
    'meetings' || 'meeting' => '/meetings',
    'announcements' || 'announcement' => '/announcements',
    'nova' || 'tutor' => '/tutor',
    _ => '/notifications',
  };
}

// ─────────────────────────────────────────────────────────────────────────────
//  Banner entry — one notification shown in the overlay
// ─────────────────────────────────────────────────────────────────────────────

class InAppNotificationBanner extends StatefulWidget {
  const InAppNotificationBanner({
    super.key,
    required this.item,
    required this.onDismiss,
    required this.onTap,
  });

  final StudentNotificationItem item;
  final VoidCallback onDismiss;
  final ValueChanged<StudentNotificationItem> onTap;

  @override
  State<InAppNotificationBanner> createState() =>
      _InAppNotificationBannerState();
}

class _InAppNotificationBannerState extends State<InAppNotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  Timer? _autoTimer;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
    _autoTimer = Timer(const Duration(seconds: 4), _dismiss);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _autoTimer?.cancel();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_dismissed) return;
    _dismissed = true;
    _autoTimer?.cancel();
    await _ctrl.reverse();
    widget.onDismiss();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    _autoTimer?.cancel();
    widget.onTap(widget.item);
    _dismiss();
  }

  IconData _iconForSource(String source) {
    return switch (source.trim().toLowerCase()) {
      'grades' => Icons.grade_rounded,
      'attendance' => Icons.fact_check_rounded,
      'practice' => Icons.auto_awesome_rounded,
      'solutions' => Icons.lightbulb_rounded,
      'messages' || 'chat' => Icons.chat_bubble_rounded,
      'classrooms' || 'classroom' => Icons.groups_rounded,
      'assignments' || 'assignment' => Icons.assignment_rounded,
      'meetings' || 'meeting' => Icons.video_call_rounded,
      'announcements' || 'announcement' => Icons.campaign_rounded,
      'nova' || 'tutor' => Icons.psychology_rounded,
      _ => Icons.notifications_rounded,
    };
  }

  Color _accentForSeverity(
    ColorScheme cs,
    StudentNotificationSeverity severity,
  ) {
    return switch (severity) {
      StudentNotificationSeverity.critical => cs.error,
      StudentNotificationSeverity.warning => const Color(0xFFE88B00),
      StudentNotificationSeverity.info => cs.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _accentForSeverity(cs, widget.item.severity);
    final icon = _iconForSource(widget.item.source);
    final l = AppLocalizations.of(context)!;

    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: GestureDetector(
          onTap: _handleTap,
          onHorizontalDragEnd: (d) {
            if ((d.primaryVelocity ?? 0).abs() > 200) _dismiss();
          },
          child: Container(
            margin: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + 8,
              left: 12,
              right: 12,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? cs.surfaceContainerHigh
                  : cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: accent.withValues(alpha: 0.28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 22, color: accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        if (widget.item.body.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.item.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Semantics(
                    button: true,
                    label: l.a11yClose,
                    child: GestureDetector(
                      onTap: _dismiss,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Banner queue overlay — shows one banner at a time, auto-advances
// ─────────────────────────────────────────────────────────────────────────────

class InAppNotificationOverlay extends StatefulWidget {
  const InAppNotificationOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<InAppNotificationOverlay> createState() =>
      InAppNotificationOverlayState();

  static InAppNotificationOverlayState? of(BuildContext context) =>
      context.findAncestorStateOfType<InAppNotificationOverlayState>();
}

class InAppNotificationOverlayState
    extends State<InAppNotificationOverlay> {
  final List<StudentNotificationItem> _queue = [];
  StudentNotificationItem? _current;
  void Function(StudentNotificationItem)? _onTap;

  void enqueue(
    StudentNotificationItem item, {
    required void Function(StudentNotificationItem) onTap,
  }) {
    if (_queue.any((q) => q.id == item.id) || _current?.id == item.id) return;
    _onTap = onTap;
    setState(() {
      if (_current == null) {
        _current = item;
      } else {
        _queue.add(item);
      }
    });
  }

  void _advance() {
    setState(() {
      if (_queue.isEmpty) {
        _current = null;
      } else {
        _current = _queue.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_current != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: InAppNotificationBanner(
                key: ValueKey(_current!.id),
                item: _current!,
                onDismiss: _advance,
                onTap: _onTap ?? (_) {},
              ),
            ),
          ),
      ],
    );
  }
}
