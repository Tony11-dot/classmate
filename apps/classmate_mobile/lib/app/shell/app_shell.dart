import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ui/nav/main_drawer.dart';

const _coreBottomNavPaths = <String>{
  '/schedule',
  '/classrooms',
  '/practice',
  '/insights',
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

  int _indexFor(String loc) {
    if (loc.startsWith('/classrooms')) return 1;
    if (loc.startsWith('/practice')) return 2;
    if (loc.startsWith('/insights')) return 3;
    if (loc.startsWith('/tutor')) return 4;
    return 0;
  }

  String _locFor(int index) => switch (index) {
    0 => '/schedule',
    1 => '/classrooms',
    2 => '/practice',
    3 => '/insights',
    4 => '/tutor',
    _ => '/schedule',
  };

  String _pageTitle(String loc) {
    if (loc.startsWith('/classrooms')) return 'Classes';
    if (loc.startsWith('/messages')) return 'Messages';
    if (loc.startsWith('/practice')) return 'Practice';
    if (loc.startsWith('/insights')) return 'Insights';
    if (loc.startsWith('/tutor')) return 'NOVA';
    if (loc.startsWith('/solutions')) return 'Solutions';
    if (loc.startsWith('/exams')) return 'Exams';
    return 'Schedule';
  }

  bool _hideBottomNav(String loc) {
    final path = _routePathOnly(loc);
    return !_coreBottomNavPaths.contains(path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = GoRouterState.of(context).matchedLocation;
    final idx = _indexFor(loc);
    final hideBottomNav = _hideBottomNav(loc);
    final hideTopBar = _hideTopBarForRoute(loc);

    return Scaffold(
      extendBody: true,
      drawerEnableOpenDragGesture: !hideTopBar,
      drawer: hideTopBar ? null : const MainDrawer(),
      appBar: hideTopBar ? null : _TopBar(title: _pageTitle(loc)),
      body: child,
      bottomNavigationBar: hideBottomNav
          ? null
          : _PlatformCoreBottomNav(
              index: idx,
              onTap: (i) {
                final next = _locFor(i);
                if (next == loc) return;
                context.go(next);
              },
            ),
    );
  }
}

class _PlatformCoreBottomNav extends StatefulWidget {
  const _PlatformCoreBottomNav({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  @override
  State<_PlatformCoreBottomNav> createState() => _PlatformCoreBottomNavState();
}

class _PlatformCoreBottomNavState extends State<_PlatformCoreBottomNav> {
  int? _pressedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brightness = theme.brightness;

    final items = const <_NavItem>[
      _NavItem(Icons.event_note_outlined, Icons.event_note_rounded, 'Schedule'),
      _NavItem(Icons.groups_outlined, Icons.groups_rounded, 'Classes'),
      _NavItem(Icons.auto_awesome_outlined, Icons.auto_awesome_rounded, 'Practice'),
      _NavItem(Icons.insights_outlined, Icons.insights_rounded, 'Insights'),
      _NavItem(Icons.psychology_outlined, Icons.psychology_rounded, 'NOVA'),
    ];

    final bottomInset = MediaQuery.of(context).padding.bottom;
    final barHeight = 64.0 + bottomInset.clamp(0.0, 20.0);

    final surface =
        brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.10)
            : Colors.white.withValues(alpha: 0.72);

    final border =
        brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.34);

    return SafeArea(
      top: false,
      left: false,
      right: false,
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              height: barHeight,
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 24,
                    spreadRadius: -8,
                    offset: const Offset(0, 10),
                    color: Colors.black.withValues(alpha: 0.18),
                  ),
                ],
              ),
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: _TelegramGlassNavButton(
                        item: items[i],
                        selected: i == widget.index,
                        pressed: i == _pressedIndex,
                        onTap: () => widget.onTap(i),
                        onPressStart: () {
                          if (!mounted) return;
                          setState(() => _pressedIndex = i);
                        },
                        onPressEnd: () {
                          if (!mounted) return;
                          setState(() {
                            if (_pressedIndex == i) _pressedIndex = null;
                          });
                        },
                        activeColor: cs.primary,
                        inactiveColor: cs.onSurfaceVariant,
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

class _TelegramGlassNavButton extends StatefulWidget {
  const _TelegramGlassNavButton({
    required this.item,
    required this.selected,
    required this.pressed,
    required this.onTap,
    required this.onPressStart,
    required this.onPressEnd,
    required this.activeColor,
    required this.inactiveColor,
  });

  final _NavItem item;
  final bool selected;
  final bool pressed;
  final VoidCallback onTap;
  final VoidCallback onPressStart;
  final VoidCallback onPressEnd;
  final Color activeColor;
  final Color inactiveColor;

  @override
  State<_TelegramGlassNavButton> createState() => _TelegramGlassNavButtonState();
}

class _TelegramGlassNavButtonState extends State<_TelegramGlassNavButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtl;
  bool _holding = false;

  static const _spring = SpringDescription(
    mass: 0.9,
    stiffness: 520,
    damping: 30,
  );

  @override
  void initState() {
    super.initState();
    _pressCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 240),
      lowerBound: 0,
      upperBound: 1,
      value: 0,
    );
  }

  @override
  void dispose() {
    _pressCtl.dispose();
    super.dispose();
  }

  void _pressIn() {
    if (_holding) return;
    _holding = true;
    widget.onPressStart();
    _pressCtl.animateTo(
      1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOutCubic,
    );
  }

  void _release() {
    if (!_holding) return;
    _holding = false;
    widget.onPressEnd();
    final sim = SpringSimulation(_spring, _pressCtl.value, 0, -2.2);
    _pressCtl.animateWith(sim);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    final selectedFill =
        brightness == Brightness.dark
            ? widget.activeColor.withValues(alpha: 0.22)
            : widget.activeColor.withValues(alpha: 0.14);

    final selectedBorder =
        brightness == Brightness.dark
            ? widget.activeColor.withValues(alpha: 0.22)
            : widget.activeColor.withValues(alpha: 0.18);

    final iconColor = widget.selected ? widget.activeColor : widget.inactiveColor;
    final labelColor = widget.selected ? widget.activeColor : widget.inactiveColor;

    return AnimatedBuilder(
      animation: _pressCtl,
      builder: (context, _) {
        final t = _pressCtl.value;
        final scale = 1.0 - (0.075 * t);
        final translateY = 2.6 * t;
        final glowAlpha = widget.selected ? (0.18 - (0.06 * t)) : 0.0;
        final fillAlphaMul = widget.selected ? (1.0 - (0.18 * t)) : 1.0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Transform.translate(
            offset: Offset(0, translateY),
            child: Transform.scale(
              scale: scale,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    if (widget.selected)
                      BoxShadow(
                        blurRadius: 18,
                        spreadRadius: -6,
                        offset: const Offset(0, 8),
                        color: widget.activeColor.withValues(alpha: glowAlpha),
                      ),
                  ],
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onLongPress: () {},
                  onLongPressDown: (_) => _pressIn(),
                  onLongPressEnd: (_) => _release(),
                  onLongPressCancel: _release,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      splashFactory: NoSplash.splashFactory,
                      highlightColor: Colors.transparent,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      onTap: widget.onTap,
                      onTapDown: (_) => _pressIn(),
                      onTapUp: (_) => _release(),
                      onTapCancel: _release,
                      child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: widget.selected
                            ? selectedFill.withValues(
                                alpha: selectedFill.a * fillAlphaMul,
                              )
                            : Colors.transparent,
                        border: Border.all(
                          color: widget.selected ? selectedBorder : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.scale(
                            scale: 1.0 - (0.05 * t),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 160),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeOutCubic,
                              transitionBuilder: (child, animation) {
                                return ScaleTransition(scale: animation, child: child);
                              },
                              child: Icon(
                                widget.selected
                                    ? widget.item.selectedIcon
                                    : widget.item.icon,
                                key: ValueKey('${widget.item.label}_${widget.selected}'),
                                size: widget.selected ? 24 : 23,
                                color: iconColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: widget.selected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: labelColor,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              ),
            ),
          ),
        );
      },
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
