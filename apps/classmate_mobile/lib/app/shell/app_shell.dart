import 'package:flutter/cupertino.dart';
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

class _PlatformCoreBottomNav extends StatelessWidget {
  const _PlatformCoreBottomNav({required this.items, required this.index, required this.onTap});

  final List<_NavItem> items;
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final cs = Theme.of(context).colorScheme;
    final isDark = brightness == Brightness.dark;

    // Apple Music iOS 26: floating frosted-glass pill with per-tab inner capsule.
    final pillTint = isDark
        ? Colors.black.withValues(alpha: 0.45)
        : Colors.white.withValues(alpha: 0.65);

    return SafeArea(
      top: false,
      left: false,
      right: false,
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: NativeGlassView(
          borderRadius: 28,
          style: NativeGlassStyle.thin,
          fallbackColor: pillTint,
          child: SizedBox(
            height: 54,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _IOSTabButton(
                      item: items[i],
                      selected: i == index,
                      activeColor: cs.primary,
                      isDark: isDark,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onTap(i);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Apple Music iOS 26 tab button: selected tab gets an inner frosted-glass
/// capsule; unselected tabs show icon + gray label with no background.
class _IOSTabButton extends StatefulWidget {
  const _IOSTabButton({
    required this.item,
    required this.selected,
    required this.activeColor,
    required this.isDark,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final Color activeColor;
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_IOSTabButton> createState() => _IOSTabButtonState();
}

class _IOSTabButtonState extends State<_IOSTabButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use native CupertinoColors so it respects the system's dark/light mode
    // exactly like UITabBar does on iOS.
    final activeColor = widget.activeColor;
    final inactiveColor =
        CupertinoColors.inactiveGray.resolveFrom(context);
    final color = widget.selected ? activeColor : inactiveColor;
    final iconData = widget.selected ? widget.item.selectedIcon : widget.item.icon;

    // Inner capsule background for selected tab (matches Apple Music iOS 26).
    final capsuleColor = widget.selected
        ? (widget.isDark
            ? Colors.white.withValues(alpha: 0.14)
            : Colors.white.withValues(alpha: 0.78))
        : Colors.transparent;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: capsuleColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  switchInCurve: Curves.easeOut,
                  child: Icon(
                    iconData,
                    key: ValueKey(iconData),
                    size: 22,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        widget.selected ? FontWeight.w600 : FontWeight.w400,
                    color: color,
                    height: 1.0,
                    letterSpacing: -0.1,
                  ),
                  child: Text(
                    widget.item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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
