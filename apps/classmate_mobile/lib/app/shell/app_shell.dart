import 'dart:ui';

import 'package:flutter/material.dart';
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
  final l = loc.toLowerCase();
  return l.startsWith('/messages/') ||
      l.startsWith('/tutor/chat/') ||
      l.startsWith('/nova/chat/') ||
      (l.startsWith('/classrooms/') && !l.endsWith('/classrooms'));
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
    final loc = GoRouterState.of(context).uri.toString();
    final idx = _indexFor(loc);
    final hideBottomNav = _hideBottomNav(loc);
    final hideTopBar = _hideTopBarForRoute(loc);

    return Scaffold(
      extendBody: true,
      drawerEnableOpenDragGesture: true,
      drawer: hideTopBar ? null : const MainDrawer(),
      appBar: hideTopBar ? null : _TopBar(title: _pageTitle(loc)),
      body: child,
      bottomNavigationBar: hideBottomNav
          ? null
          : _LiquidTelegramNav(
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

class _LiquidTelegramNav extends StatelessWidget {
  const _LiquidTelegramNav({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = const [
      _NavItem(Icons.event_note_outlined, Icons.event_note, 'Schedule'),
      _NavItem(Icons.groups_outlined, Icons.groups, 'Classes'),
      _NavItem(Icons.auto_awesome_outlined, Icons.auto_awesome, 'Practice'),
      _NavItem(Icons.insights_outlined, Icons.insights, 'Insights'),
      _NavItem(Icons.psychology_outlined, Icons.psychology, 'NOVA'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            height: 78,
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.22),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                  color: Colors.black.withValues(alpha: 0.10),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final segment = constraints.maxWidth / items.length;
                final blobWidth = segment - 20;
                final horizontalInset = (segment - blobWidth) / 2;
                final left = (segment * index) + horizontalInset;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 380),
                      curve: Curves.easeOutExpo,
                      left: left,
                      top: 7,
                      width: blobWidth,
                      height: 60,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                cs.primary.withValues(alpha: 0.26),
                                cs.primary.withValues(alpha: 0.10),
                              ],
                            ),
                            border: Border.all(
                              color: cs.primary.withValues(alpha: 0.24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 30,
                                spreadRadius: -2,
                                offset: const Offset(0, 8),
                                color: cs.primary.withValues(alpha: 0.20),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < items.length; i++)
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () => onTap(i),
                              child: SizedBox(
                                height: 78,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedScale(
                                      duration: const Duration(
                                        milliseconds: 220,
                                      ),
                                      scale: i == index ? 1.04 : 1.0,
                                      child: Icon(
                                        i == index
                                            ? items[i].selectedIcon
                                            : items[i].icon,
                                        color: i == index
                                            ? cs.primary
                                            : cs.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 0),
                                    Text(
                                      items[i].label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            fontWeight: i == index
                                                ? FontWeight.w700
                                                : FontWeight.w600,
                                            color: i == index
                                                ? cs.primary
                                                : cs.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
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
