import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_session.dart';
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
  '/exams',
  '/messages',
  '/tutor',
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
    if (loc.startsWith('/teacher/classrooms')) return 1;
    if (loc.startsWith('/exams')) return 2;
    if (loc.startsWith('/messages')) return 3;
    if (loc.startsWith('/tutor')) return 4;
    return 0;
  }

  String _teacherLocFor(int index) => switch (index) {
    0 => '/teacher/home',
    1 => '/teacher/classrooms',
    2 => '/exams',
    3 => '/messages',
    4 => '/tutor',
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
    final idx = isTeacherLike ? _teacherIndexFor(loc) : _studentIndexFor(loc);
    final hideBottomNav = _hideBottomNav(loc, isTeacherLike);
    final hideTopBar = _hideTopBarForRoute(loc);
    final l = AppLocalizations.of(context)!;

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
                      _NavItem(Icons.dashboard_outlined, Icons.dashboard_rounded, l.navHome),
                      _NavItem(Icons.groups_outlined, Icons.groups_rounded, l.navClassrooms),
                      _NavItem(Icons.event_note_outlined, Icons.event_note_rounded, l.navExams),
                      _NavItem(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, l.navMessages),
                      _NavItem(Icons.psychology_outlined, Icons.psychology_rounded, l.navNova),
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

class _PlatformCoreBottomNav extends StatefulWidget {
  const _PlatformCoreBottomNav({required this.items, required this.index, required this.onTap});

  final List<_NavItem> items;
  final int index;
  final ValueChanged<int> onTap;

  @override
  State<_PlatformCoreBottomNav> createState() => _PlatformCoreBottomNavState();
}

class _PlatformCoreBottomNavState extends State<_PlatformCoreBottomNav> {
  int? _gestureIndex;
  bool _pointerActive = false;
  int? _lastTriggeredIndex;

  int _indexForDx(
    double dx,
    double width,
    int itemCount,
    TextDirection textDirection,
  ) {
    if (itemCount <= 0) return 0;
    final slot = width / itemCount;
    if (slot <= 0) return 0;
    final visualIndex = (dx / slot).floor().clamp(0, itemCount - 1);
    if (textDirection == TextDirection.rtl) {
      return itemCount - 1 - visualIndex;
    }
    return visualIndex;
  }

  void _updateInteraction({
    required double localDx,
    required double width,
    required int itemCount,
    required TextDirection textDirection,
    required bool triggerNavigation,
  }) {
    final nextIndex = _indexForDx(localDx, width, itemCount, textDirection);
    if (!mounted) return;

    if (_gestureIndex != nextIndex) {
      setState(() => _gestureIndex = nextIndex);
    }

    if (!triggerNavigation || nextIndex == widget.index) return;
    if (_lastTriggeredIndex == nextIndex) return;
    _lastTriggeredIndex = nextIndex;
    HapticFeedback.selectionClick();
    widget.onTap(nextIndex);
  }

  void _endInteraction() {
    if (!_pointerActive && _gestureIndex == null) return;
    if (!mounted) return;
    setState(() {
      _pointerActive = false;
      _gestureIndex = null;
      _lastTriggeredIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brightness = theme.brightness;
    final textDirection = Directionality.of(context);

    final items = widget.items;

    const barHeight = 64.0;
    final displayIndex = _gestureIndex ?? widget.index;
    final visualDisplayIndex = textDirection == TextDirection.rtl
      ? items.length - 1 - displayIndex
      : displayIndex;

    // Apple liquid-glass tints: very transparent so blurred content shows through.
    final pillTint =
        brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.07)
            : Colors.white.withValues(alpha: 0.55);
    final pillBorder =
        brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.14)
            : Colors.white.withValues(alpha: 0.50);

    return SafeArea(
      top: false,
      left: false,
      right: false,
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final compact = width < 390;
            final tiny = width < 350;
            final segmentWidth = width / items.length;
            final indicatorWidth = (segmentWidth - (compact ? 8 : 10)).clamp(
              tiny ? 48.0 : 54.0,
              compact ? 90.0 : 104.0,
            );
            final indicatorLeft =
                (segmentWidth * visualDisplayIndex) +
                ((segmentWidth - indicatorWidth) / 2);

            return Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (event) {
                if (!mounted) return;
                setState(() {
                  _pointerActive = true;
                  _lastTriggeredIndex = null;
                });
                _updateInteraction(
                  localDx: event.localPosition.dx,
                  width: width,
                  itemCount: items.length,
                  textDirection: textDirection,
                  triggerNavigation: false,
                );
              },
              onPointerMove: (event) {
                if (!_pointerActive) return;
                _updateInteraction(
                  localDx: event.localPosition.dx,
                  width: width,
                  itemCount: items.length,
                  textDirection: textDirection,
                  triggerNavigation: true,
                );
              },
              onPointerUp: (_) => _endInteraction(),
              onPointerCancel: (_) => _endInteraction(),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: pillBorder, width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 32,
                      spreadRadius: -6,
                      offset: const Offset(0, 12),
                      color: Colors.black.withValues(alpha: 0.22),
                    ),
                  ],
                ),
                child: NativeGlassView(
                  borderRadius: 28,
                  style: NativeGlassStyle.thin,
                  fallbackColor: pillTint,
                  child: SizedBox(
                    height: compact ? barHeight - 2 : barHeight,
                    child: Stack(
                      children: [
                        // Specular highlight at top edge (liquid glass refraction)
                        Positioned(
                          top: 0, left: 6, right: 6,
                          height: 1.5,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0),
                                  Colors.white.withValues(alpha: brightness == Brightness.dark ? 0.22 : 0.60),
                                  Colors.white.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          left: indicatorLeft,
                          top: 7,
                          width: indicatorWidth,
                          height: barHeight - 18,
                          child: IgnorePointer(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        cs.primary.withValues(alpha: brightness == Brightness.dark ? 0.28 : 0.22),
                                        cs.primaryContainer.withValues(alpha: brightness == Brightness.dark ? 0.38 : 0.28),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: cs.primary.withValues(alpha: brightness == Brightness.dark ? 0.28 : 0.20),
                                      width: 0.8,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 18,
                                        spreadRadius: -6,
                                        offset: const Offset(0, 6),
                                        color: cs.primary.withValues(alpha: 0.28),
                                      ),
                                    ],
                                  ),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(22),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.white.withValues(alpha: 0.24),
                                          Colors.white.withValues(alpha: 0.02),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            for (var i = 0; i < items.length; i++)
                              Expanded(
                                child: _TelegramGlassNavButton(
                                  item: items[i],
                                  selected: i == widget.index,
                                  active: i == displayIndex,
                                  pressed: _pointerActive && i == _gestureIndex,
                                  compact: compact,
                                  tiny: tiny,
                                  onTap: () {
                                    if (i == widget.index) return;
                                    HapticFeedback.selectionClick();
                                    widget.onTap(i);
                                  },
                                  activeColor: cs.primary,
                                  inactiveColor: cs.onSurfaceVariant,
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
          },
        ),
      ),
    );
  }
}

class _TelegramGlassNavButton extends StatelessWidget {
  const _TelegramGlassNavButton({
    required this.item,
    required this.selected,
    required this.active,
    required this.pressed,
    required this.compact,
    required this.tiny,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
  });

  final _NavItem item;
  final bool selected;
  final bool active;
  final bool pressed;
  final bool compact;
  final bool tiny;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final resolvedColor = active ? activeColor : inactiveColor;
    final labelWeight = active ? FontWeight.w800 : FontWeight.w600;
    final targetScale = pressed ? 0.92 : active ? 1.0 : 0.965;
    final targetY = pressed ? 1.0 : 0.0;
    final iconSize = tiny ? (active ? 20.5 : 18.5) : compact ? (active ? 21.5 : 19.5) : (active ? 22.5 : 20.5);
    final iconData = selected ? item.selectedIcon : item.icon;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tiny ? 1 : 4, vertical: 2),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: targetScale),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        builder: (context, scale, child) {
          return AnimatedSlide(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            offset: Offset(0, targetY / 42),
            child: Transform.scale(scale: scale, child: child),
          );
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: tiny ? 2 : 4,
                vertical: compact ? 6 : 7,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (active && brightness == Brightness.dark)
                    BoxShadow(
                      blurRadius: 18,
                      spreadRadius: -8,
                      offset: const Offset(0, 8),
                      color: activeColor.withValues(alpha: 0.18),
                    ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 170),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeOutCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      );
                    },
                    child: Icon(
                      iconData,
                      key: ValueKey('${item.label}_${selected}_$active'),
                      size: iconSize,
                      color: resolvedColor,
                    ),
                  ),
                  SizedBox(height: compact ? 2 : 3),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 170),
                    curve: Curves.easeOutCubic,
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      fontSize: tiny ? 8 : compact ? 8.5 : 9,
                      height: 1.05,
                      fontWeight: labelWeight,
                      color: resolvedColor,
                      letterSpacing: -0.1,
                    ),
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

class _NavItem {
  const _NavItem(this.icon, this.selectedIcon, this.label);

  final IconData icon;
  final IconData selectedIcon;
  final String label;
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
