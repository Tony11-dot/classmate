import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_session.dart';
import '../../features/messages/providers/messages_repository_provider.dart';
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
  '/teacher/home',
  '/teacher/classrooms',
  '/teacher/grades',
  '/teacher/attendance',
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
    if (loc.startsWith('/teacher/grades')) return 2;
    if (loc.startsWith('/teacher/attendance')) return 3;
    if (loc.startsWith('/messages')) return 4;
    return 0;
  }

  String _teacherLocFor(int index) => switch (index) {
    0 => '/teacher/home',
    1 => '/teacher/classrooms',
    2 => '/teacher/grades',
    3 => '/teacher/attendance',
    4 => '/messages',
    _ => '/teacher/home',
  };

  String _pageTitle(BuildContext context, String loc, bool isTeacherLike) {
    final l = AppLocalizations.of(context)!;
    if (isTeacherLike) {
      if (loc.startsWith('/teacher/attendance')) return l.navAttendance;
      if (loc.startsWith('/teacher/classrooms')) return l.navClassrooms;
      if (loc.startsWith('/teacher/grades')) return l.navTeacherAssessments;
      if (loc.startsWith('/exams')) return l.titleExams;
      if (loc.startsWith('/forms')) return l.navForms;
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
    return l.titleSchedule;
  }

  bool _hideBottomNav(String loc, bool isTeacherLike) {
    final path = _routePathOnly(loc);
    final allowed = isTeacherLike ? _teacherBottomNavPaths : _coreBottomNavPaths;
    return !allowed.contains(path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      bottomNavigationBar: hideBottomNav
          ? null
          : _PlatformCoreBottomNav(
              items: isTeacherLike
                  ? <_NavItem>[
                      const _NavItem(Icons.dashboard_outlined, Icons.dashboard_rounded, 'Home'),
                      const _NavItem(Icons.groups_outlined, Icons.groups_rounded, 'Classrooms'),
                      const _NavItem(Icons.grade_outlined, Icons.grade_rounded, 'Grades'),
                      const _NavItem(Icons.fact_check_outlined, Icons.fact_check_rounded, 'Attendance'),
                      _NavItem(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Messages', badge: unreadMessages),
                    ]
                  : <_NavItem>[
                      const _NavItem(Icons.event_note_outlined, Icons.event_note_rounded, 'Schedule'),
                      const _NavItem(Icons.groups_outlined, Icons.groups_rounded, 'Classrooms'),
                      const _NavItem(Icons.auto_awesome_outlined, Icons.auto_awesome_rounded, 'Practice'),
                      const _NavItem(Icons.insights_outlined, Icons.insights_rounded, 'Insights'),
                      const _NavItem(Icons.psychology_outlined, Icons.psychology_rounded, 'NOVA'),
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

  int _indexForLocalDx(double localDx, double totalWidth) {
    if (widget.items.isEmpty) return 0;
    final slot = totalWidth / widget.items.length;
    return (localDx / slot).floor().clamp(0, widget.items.length - 1);
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
  });
  final int itemCount;
  final int selectedIndex;
  final bool isDark;
  final double totalWidth;
  final double dragDx; // rubber-band horizontal offset

  @override
  Widget build(BuildContext context) {
    final slotW = totalWidth / itemCount;
    final baseW = slotW - 8;
    // Capsule widens slightly in the drag direction (same feel as the pill).
    final stretch = (dragDx.abs() / 300).clamp(0.0, 0.12);
    final capsuleW = baseW * (1 + stretch);
    // Shift left so the capsule stays centred in its slot while wider.
    final offset = (capsuleW - baseW) / 2;
    final left = slotW * selectedIndex + 4 - offset;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      left: left,
      top: 5,
      bottom: 5,
      width: capsuleW,
      child: DecoratedBox(
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
      ),
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
