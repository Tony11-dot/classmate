import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../core/auth/auth_session.dart';
import '../../features/lifedoc/diplomas_screen.dart';
import '../../features/messages/providers/messages_repository_provider.dart';
import '../../features/teacher_mobile/data/teacher_mobile_repository.dart';
import '../../features/teacher_mobile/ui/teacher_forms_screen.dart';
import '../../ui/glass/native_glass_view.dart';
import '../../ui/nav/main_drawer.dart';
import '../../l10n/app_localizations.dart';

const _coreBottomNavPaths = <String>{
  '/schedule',
  '/classrooms',
  '/practice',
  '/insights',
  '/tutor',
};

const _teacherBottomNavPaths = <String>{
  '/teacher/schedule',
  '/teacher/classrooms',
  '/tutor',
  '/teacher/insights',
  '/messages',
};

String _routePathOnly(String loc) {
  final uri = Uri.tryParse(loc);
  return (uri?.path ?? loc).toLowerCase();
}

bool _hideTopBarForRoute(String loc) {
  final l = _routePathOnly(loc);
  return l.startsWith('/messages/') ||
      l.startsWith('/messages/request/') ||
      l.startsWith('/tutor/chat/') ||
      l.startsWith('/nova/chat/') ||
      l.startsWith('/teacher/classroom/') ||
      l.startsWith('/teacher/announcements/') ||
      l.startsWith('/teacher/schedule/week') ||
      l.startsWith('/teacher/student/') ||
      l.startsWith('/assignments/') ||
      l.startsWith('/exams/') ||
      l.startsWith('/forms/') ||
      l.startsWith('/meetings/') ||
      l.startsWith('/solutions/') ||
      (l.startsWith('/classrooms/') && l != '/classrooms');
}

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  int _studentIndexFor(String loc) {
    if (loc.startsWith('/classrooms')) return 1;
    if (loc.startsWith('/practice')) return 2;
    if (loc.startsWith('/insights')) return 3;
    if (loc.startsWith('/tutor')) return 4;
    return 0;
  }

  String _studentLocFor(int index) => switch (index) {
    0 => '/schedule',
    1 => '/classrooms',
    2 => '/practice',
    3 => '/insights',
    4 => '/tutor',
    _ => '/schedule',
  };

  int _teacherIndexFor(String loc) {
    if (loc.startsWith('/teacher/classrooms') || loc.startsWith('/teacher/classroom/')) return 1;
    if (loc.startsWith('/tutor')) return 2;
    if (loc.startsWith('/teacher/insights')) return 3;
    if (loc.startsWith('/messages')) return 4;
    return 0; // /teacher/schedule
  }

  String _teacherLocFor(int index) => switch (index) {
    0 => '/teacher/schedule',
    1 => '/teacher/classrooms',
    2 => '/tutor',
    3 => '/teacher/insights',
    4 => '/messages',
    _ => '/teacher/schedule',
  };

  String _pageTitle(BuildContext context, String loc, bool isTeacherLike) {
    final l = AppLocalizations.of(context)!;
    if (isTeacherLike) {
      if (loc.startsWith('/teacher/schedule')) return l.navSchedule;
      if (loc.startsWith('/teacher/insights')) return l.navInsights;
      if (loc.startsWith('/teacher/attendance')) return l.navAttendance;
      if (loc.startsWith('/teacher/classrooms')) return l.navClassrooms;
      if (loc.startsWith('/teacher/grades')) return l.navTeacherAssessments;
      if (loc.startsWith('/teacher/exams')) return l.teacherExamsTitle;
      if (loc.startsWith('/teacher/forms')) return l.teacherFormsTitle;
      if (loc.startsWith('/exams')) return l.titleExams;
      if (loc.startsWith('/forms')) return l.navForms;
      if (loc.startsWith('/diplomas')) return l.diplomasTitle;
      if (loc.startsWith('/tutor')) return l.titleNova;
      if (loc.startsWith('/announcements')) return l.navAnnouncements;
      if (loc.startsWith('/notifications')) return l.navNotifications;
      if (loc.startsWith('/messages')) return l.titleMessages;
      if (loc.startsWith('/profile')) return l.navProfile;
      if (loc.startsWith('/settings')) return l.navSettings;
      return l.navTeacherWorkspace;
    }
    if (loc.startsWith('/classrooms')) return l.titleClasses;
    if (loc.startsWith('/messages')) return l.titleMessages;
    if (loc.startsWith('/practice')) return l.titlePractice;
    if (loc.startsWith('/insights')) return l.titleInsights;
    if (loc.startsWith('/tutor')) return l.titleNova;
    if (loc.startsWith('/solutions')) return l.titleSolutions;
    if (loc.startsWith('/exams')) return l.titleExams;
    if (loc.startsWith('/forms')) return l.navForms;
    if (loc.startsWith('/diplomas')) return l.navDiplomas;
    return l.titleSchedule;
  }

  bool _hideBottomNav(String loc, bool isTeacherLike) {
    final path = _routePathOnly(loc);
    final allowed = isTeacherLike ? _teacherBottomNavPaths : _coreBottomNavPaths;
    return !allowed.contains(path);
  }

  Widget? _buildFab(BuildContext context, WidgetRef ref, String loc, bool isTeacherLike) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    if (!isTeacherLike) return null;
    if (loc.startsWith('/teacher/schedule') ||
        loc.startsWith('/teacher/classrooms') ||
        loc.startsWith('/teacher/classroom/')) {
      return const _TeacherFab();
    }
    if (loc == '/announcements') {
      return FloatingActionButton(
        heroTag: 'fab_announce',
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        onPressed: () => context.push('/teacher/announcements/new'),
        child: const Icon(Icons.add_rounded),
      );
    }
    if (loc == '/teacher/exams' || loc.startsWith('/teacher/grades')) {
      return FloatingActionButton(
        heroTag: 'fab_exams',
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        onPressed: () => _showCreateExamSheet(context, ref, l),
        child: const Icon(Icons.add_rounded),
      );
    }
    if (loc == '/teacher/forms') {
      return FloatingActionButton(
        heroTag: 'fab_forms',
        backgroundColor: cs.secondary,
        foregroundColor: cs.onSecondary,
        onPressed: () {
          ref.read(teacherFormsCreateTriggerProvider.notifier).increment();
        },
        child: const Icon(Icons.add_rounded),
      );
    }
    if (loc == '/diplomas') {
      return FloatingActionButton(
        heroTag: 'fab_diplomas',
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white,
        onPressed: () {
          ref.read(diplomasCreateTriggerProvider.notifier).increment();
        },
        child: const Icon(Icons.workspace_premium_rounded),
      );
    }
    return null;
  }

  void _showCreateExamSheet(BuildContext context, WidgetRef ref, AppLocalizations l) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateExamSheet(ref: ref, l: l),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);
    final isTeacherLike = session.isTeacherLike;
    final loc = GoRouterState.of(context).matchedLocation;
    final unreadMessages = ref.watch(unreadMessagesCountProvider);
    final idx = isTeacherLike ? _teacherIndexFor(loc) : _studentIndexFor(loc);
    final hideBottomNav = _hideBottomNav(loc, isTeacherLike);
    final hideTopBar = _hideTopBarForRoute(loc);

    return Scaffold(
      extendBody: true,
      drawerEnableOpenDragGesture: !hideTopBar,
      drawer: hideTopBar ? null : const MainDrawer(),
      appBar: hideTopBar ? null : _TopBar(title: _pageTitle(context, loc, isTeacherLike)),
      body: child,
      floatingActionButton: _buildFab(context, ref, loc, isTeacherLike),
      bottomNavigationBar: hideBottomNav
          ? null
          : _PlatformCoreBottomNav(
              items: isTeacherLike
                  ? <_NavItem>[
                      _NavItem(Icons.event_note_outlined, Icons.event_note_rounded, l.navSchedule),
                      _NavItem(Icons.groups_outlined, Icons.groups_rounded, l.navClassrooms),
                      _NavItem(Icons.psychology_outlined, Icons.psychology_rounded, l.navNova),
                      _NavItem(Icons.insights_outlined, Icons.insights_rounded, l.navInsights),
                      _NavItem(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, l.navMessages, badge: unreadMessages),
                    ]
                  : <_NavItem>[
                      _NavItem(Icons.event_note_outlined, Icons.event_note_rounded, l.navSchedule),
                      _NavItem(Icons.groups_outlined, Icons.groups_rounded, l.navClassrooms),
                      _NavItem(Icons.auto_awesome_outlined, Icons.auto_awesome_rounded, l.navPractice),
                      _NavItem(Icons.insights_outlined, Icons.insights_rounded, l.navInsights),
                      _NavItem(Icons.psychology_outlined, Icons.psychology_rounded, l.navNova),
                    ],
              index: idx,
              onTap: (i) {
                final next = isTeacherLike ? _teacherLocFor(i) : _studentLocFor(i);
                if (next == loc) return;
                context.go(next);
              },
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Liquid-glass floating pill nav — Apple Music iOS 26 style
//  • Slide finger across → switches tabs with haptics
//  • Hold + drag any direction → pill stretches with rubber-band physics
//  • Release → spring snaps back
// ─────────────────────────────────────────────────────────────────────────────

class _PlatformCoreBottomNav extends StatefulWidget {
  const _PlatformCoreBottomNav({required this.items, required this.index, required this.onTap});

  final List<_NavItem> items;
  final int index;
  final ValueChanged<int> onTap;

  @override
  State<_PlatformCoreBottomNav> createState() => _PlatformCoreBottomNavState();
}

class _PlatformCoreBottomNavState extends State<_PlatformCoreBottomNav>
    with TickerProviderStateMixin {
  // Raw drag offset (drives stretch transform)
  double _dragDx = 0;
  double _dragDy = 0;

  bool _pressing = false;
  Offset? _pressOrigin;
  int? _hoveredIndex; // index currently under finger during drag
  int? _lastHapticIndex;

  // Cached RTL state — updated every build so event handlers stay in sync
  bool _isRtl = false;

  // Spring animation for release snap-back
  late final AnimationController _snapCtrl;

  @override
  void initState() {
    super.initState();
    _snapCtrl = AnimationController.unbounded(vsync: this)
      ..addListener(() {
        if (!_pressing) {
          setState(() {
            _dragDx = _snapCtrl.value;
          });
        }
      });
  }

  @override
  void dispose() {
    _snapCtrl.dispose();
    super.dispose();
  }

  // Apple rubber-band: resistance increases as you drag further
  static double _rubberBand(double x) {
    if (x.abs() < 0.5) return 0;
    const c = 120.0;
    final sign = x < 0 ? -1.0 : 1.0;
    return sign * (1 - 1 / (x.abs() / c + 1)) * c;
  }

  // In RTL the Row reverses tab order, so physical dx maps to the mirror index.
  int _indexForLocalDx(double localDx, double totalWidth) {
    if (widget.items.isEmpty) return 0;
    final slot = totalWidth / widget.items.length;
    final raw = (localDx / slot).floor().clamp(0, widget.items.length - 1);
    return _isRtl ? (widget.items.length - 1 - raw) : raw;
  }

  void _onPointerDown(PointerDownEvent e, double width) {
    _snapCtrl.stop();
    _pressing = true;
    _pressOrigin = e.localPosition;
    _dragDx = 0;
    _dragDy = 0;
    _hoveredIndex = _indexForLocalDx(e.localPosition.dx, width);
    _lastHapticIndex = _hoveredIndex;
    HapticFeedback.selectionClick();
    setState(() {});
  }

  void _onPointerMove(PointerMoveEvent e, double width) {
    if (!_pressing || _pressOrigin == null) return;
    final dx = e.localPosition.dx - _pressOrigin!.dx;
    final dy = e.localPosition.dy - _pressOrigin!.dy;
    final newHovered = _indexForLocalDx(e.localPosition.dx, width);

    setState(() {
      _dragDx = _rubberBand(dx);
      _dragDy = _rubberBand(dy);
      _hoveredIndex = newHovered;
    });

    if (newHovered != _lastHapticIndex) {
      HapticFeedback.selectionClick();
      _lastHapticIndex = newHovered;
    }
  }

  void _onPointerUp(PointerUpEvent e, double width) {
    if (!_pressing) return;
    final tappedIndex = _indexForLocalDx(e.localPosition.dx, width);
    _pressing = false;

    if (tappedIndex != widget.index) {
      widget.onTap(tappedIndex);
      HapticFeedback.selectionClick();
    }

    // Spring snap-back: stiffness=500, damping=30 → fast crisp rebound
    const spring = SpringDescription(mass: 1, stiffness: 500, damping: 30);
    _snapCtrl.animateWith(SpringSimulation(spring, _dragDx, 0, 0));

    setState(() {
      _dragDy = 0;
      _hoveredIndex = null;
      _pressOrigin = null;
    });
  }

  void _onPointerCancel(PointerCancelEvent e) {
    _pressing = false;
    const spring = SpringDescription(mass: 1, stiffness: 500, damping: 30);
    _snapCtrl.animateWith(SpringSimulation(spring, _dragDx, 0, 0));
    setState(() { _dragDy = 0; _hoveredIndex = null; _pressOrigin = null; });
  }

  @override
  Widget build(BuildContext context) {
    _isRtl = Directionality.of(context) == TextDirection.rtl;
    final brightness = Theme.of(context).brightness;
    final cs = Theme.of(context).colorScheme;
    final isDark = brightness == Brightness.dark;
    // Transparent on iOS — UIVisualEffectView is the only visual layer.
    // Android needs a slight tint so BackdropFilter has visible depth.
    final pillTint = Platform.isIOS
        ? Colors.transparent
        : (isDark
            ? Colors.black.withValues(alpha: 0.45)
            : Colors.white.withValues(alpha: 0.65));

    // Stretch factors: rubber-band units → visual scale delta
    final sx = 1.0 + (_dragDx.abs() / 400).clamp(0.0, 0.08);
    final sy = 1.0 + (_dragDy.abs() / 300).clamp(0.0, 0.06);

    return SafeArea(
      top: false, left: false, right: false, bottom: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: LayoutBuilder(builder: (context, box) {
          final width = box.maxWidth;
          return Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (e) => _onPointerDown(e, width),
            onPointerMove: (e) => _onPointerMove(e, width),
            onPointerUp: (e) => _onPointerUp(e, width),
            onPointerCancel: _onPointerCancel,
            child: Transform(
              alignment: Alignment.center,
              // Translate pill horizontally with drag; scale in drag direction
              transform: (Matrix4.translationValues(_dragDx * 0.18, _dragDy * 0.12, 0.0)
                ..setEntry(0, 0, sx)
                ..setEntry(1, 1, sy)),
              child: NativeGlassView(
                borderRadius: 28,
                style: NativeGlassStyle.thin,
                fallbackColor: pillTint,
                child: SizedBox(
                  height: 54,
                  child: Stack(
                    children: [
                      // ── Animated selection capsule ────────────────────────
                      // totalWidth passed from the outer LayoutBuilder so the
                      // capsule computes slot positions without a nested
                      // LayoutBuilder (Positioned must be a direct Stack child).
                      _SelectionCapsule(
                        itemCount: widget.items.length,
                        selectedIndex: _hoveredIndex ?? widget.index,
                        isDark: isDark,
                        totalWidth: width,
                        dragDx: _dragDx,
                        isRtl: _isRtl,
                      ),
                      // ── Tab icons + labels ────────────────────────────────
                      Row(
                        children: [
                          for (var i = 0; i < widget.items.length; i++)
                            Expanded(
                              child: _TabLabel(
                                item: widget.items[i],
                                selected: i == widget.index,
                                hovered: i == (_hoveredIndex ?? widget.index),
                                activeColor: cs.primary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// Animated capsule — direct child of Stack (no LayoutBuilder inside).
// Receives totalWidth from parent LayoutBuilder so it can compute slot positions.
// Also stretches horizontally with the current dragDx for a liquid feel.
class _SelectionCapsule extends StatelessWidget {
  const _SelectionCapsule({
    required this.itemCount,
    required this.selectedIndex,
    required this.isDark,
    required this.totalWidth,
    required this.dragDx,
    required this.isRtl,
  });
  final int itemCount;
  final int selectedIndex;
  final bool isDark;
  final double totalWidth;
  final double dragDx; // rubber-band horizontal offset
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    final slotW = totalWidth / itemCount;
    final baseW = slotW - 8;
    final stretch = (dragDx.abs() / 300).clamp(0.0, 0.12);
    final capsuleW = baseW * (1 + stretch);
    // Keep capsule centred in its slot as it widens.
    final offset = (capsuleW - baseW) / 2;
    // In RTL the Row renders item 0 on the right, so we position from the
    // right edge — symmetrically matching the visual tab order.
    final edge = slotW * selectedIndex + 4 - offset;

    final child = DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    return isRtl
        ? AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            right: edge,
            top: 5,
            bottom: 5,
            width: capsuleW,
            child: child,
          )
        : AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            left: edge,
            top: 5,
            bottom: 5,
            width: capsuleW,
            child: child,
          );
  }
}

// Single tab icon + label (no press animations — handled by parent Listener)
class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.item,
    required this.selected,
    required this.hovered,
    required this.activeColor,
  });
  final _NavItem item;
  final bool selected;
  final bool hovered; // finger is currently over this tab
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final inactiveColor = CupertinoColors.inactiveGray.resolveFrom(context);
    final color = (selected || hovered) ? activeColor : inactiveColor;
    final iconData = selected ? item.selectedIcon : item.icon;
    final hasBadge = item.badge > 0;

    return SizedBox.expand(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 140),
                child: Icon(iconData, key: ValueKey('${item.label}_$selected'), size: 22, color: color),
              ),
              if (hasBadge)
                Positioned(
                  right: -6,
                  top: -4,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      item.badge > 99 ? '99+' : '${item.badge}',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 140),
            style: TextStyle(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: color,
              height: 1.0,
              letterSpacing: -0.1,
            ),
            child: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.selectedIcon, this.label, {this.badge = 0});

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int badge;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Teacher FAB — expandable speed-dial
// ─────────────────────────────────────────────────────────────────────────────

class _TeacherFab extends StatefulWidget {
  const _TeacherFab();
  @override
  State<_TeacherFab> createState() => _TeacherFabState();
}

class _TeacherFabState extends State<_TeacherFab> with SingleTickerProviderStateMixin {
  bool _open = false;

  void _toggle() => setState(() => _open = !_open);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_open) ...[
          _FabAction(icon: Icons.campaign_rounded, label: l.navAnnouncements, color: cs.tertiary,
              onTap: () { _toggle(); context.push('/teacher/announcements/new'); }),
          const SizedBox(height: 10),
          _FabAction(icon: Icons.assignment_rounded, label: l.navAssignments, color: cs.secondary,
              onTap: () { _toggle(); context.go('/teacher/classrooms'); }),
          const SizedBox(height: 10),
          _FabAction(icon: Icons.fact_check_rounded, label: l.navAttendance, color: cs.primary,
              onTap: () { _toggle(); context.go('/teacher/attendance'); }),
          const SizedBox(height: 10),
          _FabAction(icon: Icons.grade_rounded, label: l.navGrades, color: cs.secondary,
              onTap: () { _toggle(); context.go('/teacher/grades'); }),
          const SizedBox(height: 12),
        ],
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 6,
          child: AnimatedRotation(
            turns: _open ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add_rounded, size: 28),
          ),
        ),
        const SizedBox(height: 80), // clear bottom nav pill
      ],
    );
  }
}

class _FabAction extends StatelessWidget {
  const _FabAction({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget implements PreferredSizeWidget {
  const _TopBar({required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(74);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppBar(
      toolbarHeight: 74,
      titleSpacing: 0,
      centerTitle: true,
      leadingWidth: 64,
      leading: Builder(
        builder: (ctx) => Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      title: Text(
        'ClassMate',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: -0.4,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.60),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.28),
                ),
              ),
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Create Exam / Assessment sheet
// ─────────────────────────────────────────────────────────────────────────────

class _CreateExamSheet extends ConsumerStatefulWidget {
  const _CreateExamSheet({required this.ref, required this.l});
  final WidgetRef ref;
  final AppLocalizations l;

  @override
  ConsumerState<_CreateExamSheet> createState() => _CreateExamSheetState();
}

class _CreateExamSheetState extends ConsumerState<_CreateExamSheet> {
  final _titleCtrl = TextEditingController();
  final _maxGradeCtrl = TextEditingController();
  String? _selectedCourseId;
  DateTime? _selectedDate;
  List<TeacherCourse> _courses = [];
  bool _loadingCourses = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadCourses);
  }

  Future<void> _loadCourses() async {
    try {
      final bundle = await widget.ref.read(teacherMobileRepositoryProvider).fetchAssessments();
      if (!mounted) return;
      setState(() {
        _courses = bundle.courses;
        _selectedCourseId = bundle.courses.isNotEmpty ? bundle.courses.first.id : null;
        _loadingCourses = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingCourses = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _maxGradeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final courseId = _selectedCourseId;
    if (title.isEmpty || courseId == null) return;
    setState(() => _saving = true);
    try {
      final dateStr = _selectedDate != null
          ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
          : '';
      await widget.ref.read(teacherMobileRepositoryProvider).createAssessment(
        courseId: courseId,
        title: title,
        date: dateStr,
        maxGrade: int.tryParse(_maxGradeCtrl.text.trim()),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assessment created')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.l.teacherGradesCreateAssessmentTitle, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            if (_loadingCourses)
              const Center(child: CircularProgressIndicator())
            else
              DropdownButtonFormField<String>(
                initialValue: _selectedCourseId,
                decoration: InputDecoration(labelText: widget.l.teacherGradesFieldCourse, border: const OutlineInputBorder()),
                items: _courses
                    .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCourseId = v),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(labelText: '${widget.l.teacherGradesFieldTitle} *', border: const OutlineInputBorder()),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: cs.outlineVariant),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 18, color: cs.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? widget.l.teacherGradesFieldDate
                            : DateFormat.yMMMd(locale).format(_selectedDate!),
                        style: TextStyle(color: _selectedDate == null ? cs.onSurfaceVariant : cs.onSurface),
                      ),
                    ),
                    if (_selectedDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _selectedDate = null),
                        child: Icon(Icons.close_rounded, size: 16, color: cs.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _maxGradeCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: widget.l.teacherGradesFieldMaxGrade, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.add_rounded),
                label: Text(widget.l.teacherGradesCreateAction),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
