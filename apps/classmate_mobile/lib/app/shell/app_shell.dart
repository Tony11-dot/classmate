import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../core/auth/auth_session.dart';
import '../../core/realtime/realtime_listener.dart';
import '../../features/lifedoc/assignments_screen.dart';
import '../../features/lifedoc/data/exams_repository.dart';
import '../../features/lifedoc/diplomas_screen.dart';
import '../../features/lifedoc/meetings_screen.dart';
import '../../features/lifedoc/notifications_provider.dart';
import '../../features/parent/data/parent_models.dart';
import '../../features/parent/data/parent_repository.dart';
import '../../features/lifedoc/student_materials_screen.dart';
import '../../features/messages/providers/messages_repository_provider.dart';
import '../../features/teacher_mobile/data/teacher_mobile_repository.dart';
import '../../features/teacher_mobile/ui/teacher_forms_screen.dart';
import '../../ui/glass/native_glass_view.dart';
import '../../ui/nav/main_drawer.dart';
import '../../ui/widgets/liquid_glass_dropdown.dart';
import '../../ui/widgets/classmate_logo.dart';
import '../../ui/widgets/in_app_notification_banner.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets/cm_loading.dart';

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
      l.startsWith('/teacher/student/') ||
      l.startsWith('/assignments/') ||
      l.startsWith('/exams/') ||
      l.startsWith('/forms/') ||
      l.startsWith('/meetings/') ||
      l.startsWith('/solutions/') ||
      (l.startsWith('/classrooms/') && l != '/classrooms') ||
      l.startsWith('/admin/cohorts/') ||
      l.startsWith('/secretary/cohorts/');
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

  int _adminIndexFor(String loc, bool isAdmin) {
    if (!isAdmin) {
      // Secretary: Announcements | Students | Messages
      if (loc.startsWith('/secretary/')) return 1;
      if (loc.startsWith('/messages')) return 2;
      return 0; // announcements
    }
    // Admin: Dashboard | People | Cohorts | Schedule | Messages
    if (loc.startsWith('/admin/people')) return 1;
    if (loc.startsWith('/admin/cohorts')) return 2;
    if (loc.startsWith('/admin/schedule')) return 3;
    if (loc.startsWith('/messages')) return 4;
    return 0;
  }

  String _adminLocFor(int index, bool isAdmin) {
    if (!isAdmin) {
      // Secretary
      return switch (index) {
        0 => '/announcements',
        1 => '/secretary/students',
        2 => '/messages',
        _ => '/announcements',
      };
    }
    // Admin
    return switch (index) {
      0 => '/admin/dashboard',
      1 => '/admin/people',
      2 => '/admin/cohorts',
      3 => '/admin/schedule',
      4 => '/messages',
      _ => '/admin/dashboard',
    };
  }

  // Ordered most-specific prefix first (teacher/student/ before teacher/students)
  static const _teacherPrefixes = <String>[
    '/teacher/student/',     // must precede /teacher/students
    '/teacher/schedule',
    '/teacher/insights',
    '/teacher/attendance',
    '/teacher/classrooms',
    '/teacher/grades',
    '/teacher/exams',
    '/teacher/forms',
    '/teacher/meetings',
    '/teacher/assignments',
    '/teacher/materials',
    '/teacher/students',
    '/teacher/home',
    '/exams',
    '/forms',
    '/diplomas',
    '/solutions',
    '/tutor',
    '/announcements',
    '/notifications',
    '/messages',
    '/profile',
    '/settings',
    '/about',
    '/support',
  ];

  static const _adminPrefixes = <String>[
    '/admin/dashboard',
    '/admin/people',
    '/admin/cohorts',
    '/admin/schedule',
    '/admin/school',
    '/admin/bell-schedule',
    '/admin/settings',
    '/admin/periods',
    '/admin/export',
    '/admin/',
    '/secretary/students',
    '/secretary/',
    '/messages',
    '/tutor',
    '/announcements',
    '/notifications',
    '/profile',
    '/settings',
    '/about',
    '/support',
  ];

  static const _studentPrefixes = <String>[
    '/classrooms',
    '/messages',
    '/practice',
    '/insights',
    '/tutor',
    '/solutions',
    '/exams',
    '/forms',
    '/diplomas',
    '/grades',
    '/attendance',
    '/meetings',
    '/announcements',
    '/notifications',
    '/assignments',
    '/materials',
    '/saved-questions',
    '/profile',
    '/settings',
    '/about',
    '/support',
  ];

  String _adminTitle(AppLocalizations l, String prefix) => switch (prefix) {
    '/admin/dashboard' => l.navDashboard,
    '/admin/people' => l.navPeople,
    '/admin/cohorts' => l.navCohorts,
    '/admin/schedule' => l.adminScheduleTitle,
    '/admin/school' => l.adminSchoolSettingsTitle,
    '/admin/bell-schedule' => l.adminSettingsBellSchedule,
    '/admin/settings' => l.adminSettingsTitle,
    '/admin/periods' => l.adminSettingsPeriodDefaults,
    '/admin/export' => 'Export Data',
    '/admin/' => l.roleAdmin,
    '/secretary/students' => l.adminStudents,
    '/secretary/' => l.roleSecretary,
    '/messages' => l.titleMessages,
    '/tutor' => l.titleNova,
    '/announcements' => l.navAnnouncements,
    '/notifications' => l.navNotifications,
    '/profile' => l.navProfile,
    '/settings' => l.navSettings,
    '/about' => 'About',
    '/support' => 'Support',
    _ => l.roleSecretary,
  };

  String _teacherTitle(AppLocalizations l, String prefix) => switch (prefix) {
    '/teacher/student/' => l.teacherStudentsLabel,
    '/teacher/schedule' => l.navSchedule,
    '/teacher/insights' => l.navInsights,
    '/teacher/attendance' => l.navAttendance,
    '/teacher/classrooms' => l.navClassrooms,
    '/teacher/grades' => l.navGrades,
    '/teacher/exams' => l.teacherExamsTitle,
    '/teacher/forms' => l.teacherFormsTitle,
    '/teacher/meetings' => l.navMeetings,
    '/teacher/assignments' => l.navAssignments,
    '/teacher/materials' => l.teacherMaterialsTitle,
    '/teacher/students' => l.teacherStudentsLabel,
    '/teacher/home' => l.navTeacherWorkspace,
    '/exams' => l.titleExams,
    '/forms' => l.navForms,
    '/diplomas' => l.diplomasTitle,
    '/solutions' => l.titleSolutions,
    '/tutor' => l.titleNova,
    '/announcements' => l.navAnnouncements,
    '/notifications' => l.navNotifications,
    '/messages' => l.titleMessages,
    '/profile' => l.navProfile,
    '/settings' => l.navSettings,
    '/about' => 'About',
    '/support' => 'Support',
    _ => l.navTeacherWorkspace,
  };

  String _studentTitle(AppLocalizations l, String prefix) => switch (prefix) {
    '/classrooms' => l.titleClasses,
    '/messages' => l.titleMessages,
    '/practice' => l.titlePractice,
    '/insights' => l.titleInsights,
    '/tutor' => l.titleNova,
    '/solutions' => l.titleSolutions,
    '/exams' => l.titleExams,
    '/forms' => l.navForms,
    '/diplomas' => l.navDiplomas,
    '/grades' => l.navGrades,
    '/attendance' => l.navAttendance,
    '/meetings' => l.navMeetings,
    '/announcements' => l.navAnnouncements,
    '/notifications' => l.navNotifications,
    '/assignments' => l.navAssignments,
    '/materials' => 'Materials',
    '/saved-questions' => l.navSavedQuestions,
    '/profile' => l.navProfile,
    '/settings' => l.navSettings,
    '/about' => 'About',
    '/support' => 'Support',
    _ => l.titleSchedule,
  };

  String _pageTitle(BuildContext context, String loc, bool isTeacherLike, bool isAdminLike) {
    final l = AppLocalizations.of(context)!;
    if (isAdminLike) {
      for (final p in _adminPrefixes) {
        if (loc.startsWith(p)) return _adminTitle(l, p);
      }
      return 'Admin';
    }
    final prefixes = isTeacherLike ? _teacherPrefixes : _studentPrefixes;
    for (final p in prefixes) {
      if (loc.startsWith(p)) {
        return isTeacherLike ? _teacherTitle(l, p) : _studentTitle(l, p);
      }
    }
    return isTeacherLike ? l.navTeacherWorkspace : l.titleSchedule;
  }

  bool _hideBottomNav(String loc, bool isTeacherLike, bool isAdminLike, bool isAdmin) {
    // Admin and Secretary navigate entirely via the drawer — no bottom pill nav.
    if (isAdminLike) return true;
    final path = _routePathOnly(loc);
    final allowed = isTeacherLike ? _teacherBottomNavPaths : _coreBottomNavPaths;
    return !allowed.contains(path);
  }

  Widget? _buildFab(BuildContext context, WidgetRef ref, String loc, bool isTeacherLike, {bool isAdminLike = false}) {
    final cs = Theme.of(context).colorScheme;
    // Secretary can post announcements — allow isAdminLike to reach the FAB logic too
    if (!isTeacherLike && !isAdminLike) return null;
    if (loc == '/announcements') {
      return FloatingActionButton(
        heroTag: 'fab_announce',
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        onPressed: () => context.push('/teacher/announcements/new'),
        child: const Icon(Icons.add_rounded),
      );
    }
    if (loc == '/teacher/exams') {
      return FloatingActionButton(
        heroTag: 'fab_exams',
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        onPressed: () => context.push('/teacher/exams/create'),
        child: const Icon(Icons.add_rounded),
      );
    }
    if (loc.startsWith('/teacher/grades')) {
      return FloatingActionButton(
        heroTag: 'fab_grades_add',
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        onPressed: () => context.push('/teacher/grades/add'),
        child: const Icon(Icons.add_rounded),
      );
    }
    if (loc == '/teacher/forms') {
      return FloatingActionButton(
        heroTag: 'fab_forms',
        backgroundColor: cs.secondaryContainer,
        foregroundColor: cs.onSecondaryContainer,
        onPressed: () {
          ref.read(teacherFormsCreateTriggerProvider.notifier).increment();
        },
        child: const Icon(Icons.add_rounded),
      );
    }
    if (loc == '/diplomas') {
      return FloatingActionButton(
        heroTag: 'fab_diplomas',
        backgroundColor: cs.tertiaryContainer,
        foregroundColor: cs.onTertiaryContainer,
        onPressed: () {
          ref.read(diplomasCreateTriggerProvider.notifier).increment();
        },
        child: const Icon(Icons.workspace_premium_rounded),
      );
    }
    if (loc == '/teacher/meetings') {
      return FloatingActionButton(
        heroTag: 'fab_meetings',
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        onPressed: () => context.push('/teacher/meetings/add'),
        child: const Icon(Icons.add_rounded),
      );
    }
    if (loc == '/teacher/assignments') {
      return FloatingActionButton(
        heroTag: 'fab_assignments',
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        onPressed: () => context.push('/teacher/assignments/add'),
        child: const Icon(Icons.add_rounded),
      );
    }
    if (loc == '/teacher/materials') {
      return FloatingActionButton(
        heroTag: 'fab_materials',
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        onPressed: () => context.push('/teacher/materials/add'),
        child: const Icon(Icons.add_rounded),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);
    final isTeacherLike = session.isTeacherLike;
    final primaryRole = session.primaryRole;
    final isAdminLike = primaryRole == 'ADMIN' || primaryRole == 'SECRETARY';
    final isAdmin = primaryRole == 'ADMIN';
    final loc = GoRouterState.of(context).matchedLocation;
    final unreadMessages = ref.watch(unreadMessagesCountProvider);
    final idx = isAdminLike
        ? _adminIndexFor(loc, isAdmin)
        : isTeacherLike
            ? _teacherIndexFor(loc)
            : _studentIndexFor(loc);
    final hideBottomNav = _hideBottomNav(loc, isTeacherLike, isAdminLike, isAdmin);
    final hideTopBar = _hideTopBarForRoute(loc);

    final pageTitle = _pageTitle(context, loc, isTeacherLike, isAdminLike);

    // Global real-time event handler — invalidates providers when SSE events arrive
    ref.listen(realtimeEventProvider, (_, event) {
      if (event == null) return;
      switch (event.type) {
        case 'grade_updated':
          ref.invalidate(examsLiveProvider);
          break;
        case 'assignment_created':
          ref.invalidate(assignmentsFeedProvider);
          break;
        case 'material_created':
          ref.invalidate(studentMaterialsProvider);
          break;
        case 'meeting_created':
          ref.invalidate(meetingsFeedProvider);
          break;
        case 'notification':
          ref.invalidate(notificationInboxProvider);
          ref.invalidate(unreadNotificationsCountProvider);
          break;
        case 'schedule_updated':
          // Student's schedule was updated by admin — invalidate schedule cache
          // The schedule screen uses _teacherWeekProvider (teacher) or weekScheduleProvider (student)
          // Both are FutureProvider.autoDispose so they refetch on next render automatically
          break;
        case 'classroom_message':
        case 'dm_message':
          // Messages handle their own invalidation in messages screens
          break;
        default:
          break;
      }
    });

    // Dismiss keyboard on USER-initiated scrolls only (drag/fling). We used
    // to listen to ScrollStartNotification which fires on programmatic
    // scrolls too — including the automatic scroll Flutter does to keep a
    // freshly-focused TextField visible above the keyboard. That instantly
    // unfocused the field, making fields "open and close" the moment you
    // tapped them in forms inside a scroll view (Add User, etc.).
    return NotificationListener<UserScrollNotification>(
      onNotification: (n) {
        if (n.direction != ScrollDirection.idle) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
        return false;
      },
      child: InAppNotificationOverlay(
      child: _AppShellScaffold(
        l: l,
        pageTitle: pageTitle,
        loc: loc,
        idx: idx,
        isTeacherLike: isTeacherLike,
        isAdminLike: isAdminLike,
        isAdmin: isAdmin,
        hideBottomNav: hideBottomNav,
        hideTopBar: hideTopBar,
        unreadMessages: unreadMessages,
        child: child,
        buildFab: (ctx) => _buildFab(ctx, ref, loc, isTeacherLike, isAdminLike: isAdminLike),
        onTap: (i) {
          final String next;
          if (isAdminLike) {
            next = _adminLocFor(i, isAdmin);
          } else if (isTeacherLike) {
            next = _teacherLocFor(i);
          } else {
            next = _studentLocFor(i);
          }
          if (next == loc) return;
          context.go(next);
        },
      ),
      ),
    );
  }
}

class _AppShellScaffold extends ConsumerStatefulWidget {
  const _AppShellScaffold({
    required this.l,
    required this.pageTitle,
    required this.loc,
    required this.idx,
    required this.isTeacherLike,
    required this.isAdminLike,
    required this.isAdmin,
    required this.hideBottomNav,
    required this.hideTopBar,
    required this.unreadMessages,
    required this.child,
    required this.buildFab,
    required this.onTap,
  });

  final AppLocalizations l;
  final String pageTitle;
  final String loc;
  final int idx;
  final bool isTeacherLike;
  final bool isAdminLike;
  final bool isAdmin;
  final bool hideBottomNav;
  final bool hideTopBar;
  final int unreadMessages;
  final Widget child;
  final Widget? Function(BuildContext) buildFab;
  final ValueChanged<int> onTap;

  @override
  ConsumerState<_AppShellScaffold> createState() => _AppShellScaffoldState();
}

class _AppShellScaffoldState extends ConsumerState<_AppShellScaffold> {
  @override
  void initState() {
    super.initState();
    // Kick off a notification sync once the shell is live so banners can fire.
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncNotifications());
  }

  Future<void> _syncNotifications() async {
    try {
      final newItems = await ref
          .read(notificationSyncServiceProvider)
          .sync(baselineIfEmpty: true);
      if (!mounted || newItems.isEmpty) return;
      final overlay = InAppNotificationOverlay.of(context);
      if (overlay == null) return;
      for (final item in newItems.take(3)) {
        overlay.enqueue(
          item,
          onTap: (n) => context.push(notificationRoute(n)),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    final loc = GoRouterState.of(context).matchedLocation;
    // Parents see a thin "viewing as {child}" banner on every parent
    // route except /parent/home (home already shows the child picker
    // prominently). The banner lets them swap children without
    // navigating back to home.
    final session = ref.watch(authSessionProvider);
    final isParent = session.primaryRole == 'PARENT';
    final showChildBanner = isParent
        && loc.startsWith('/parent/')
        && loc != '/parent/home';
    return Scaffold(
      extendBody: true,
      drawerEnableOpenDragGesture: !widget.hideTopBar,
      drawer: widget.hideTopBar ? null : const MainDrawer(),
      appBar: widget.hideTopBar ? null : _TopBar(title: widget.pageTitle),
      body: showChildBanner
          ? Column(children: [
              const _ParentChildSwitcherBar(),
              Expanded(child: widget.child),
            ])
          : widget.child,
      floatingActionButton: widget.buildFab(context),
      bottomNavigationBar: widget.hideBottomNav
          ? null
          : _PlatformCoreBottomNav(
              items: widget.isAdminLike
                  ? widget.isAdmin
                      ? <_NavItem>[
                          _NavItem(Icons.dashboard_outlined, Icons.dashboard_rounded, l.navDashboard),
                          _NavItem(Icons.people_outline_rounded, Icons.people_rounded, l.navPeople),
                          _NavItem(Icons.groups_outlined, Icons.groups_rounded, l.navCohorts),
                          _NavItem(Icons.manage_history_outlined, Icons.manage_history_rounded, l.adminScheduleTitle),
                          _NavItem(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, l.navMessages, badge: widget.unreadMessages),
                        ]
                      : <_NavItem>[
                          // Secretary: Announcements | Students | Messages
                          _NavItem(Icons.campaign_outlined, Icons.campaign_rounded, l.navAnnouncements),
                          _NavItem(Icons.school_outlined, Icons.school_rounded, l.adminStudents),
                          _NavItem(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, l.navMessages, badge: widget.unreadMessages),
                        ]
                  : widget.isTeacherLike
                      ? <_NavItem>[
                          _NavItem(Icons.event_note_outlined, Icons.event_note_rounded, l.navSchedule),
                          _NavItem(Icons.groups_outlined, Icons.groups_rounded, l.navClassrooms),
                          _NavItem(Icons.psychology_outlined, Icons.psychology_rounded, l.navNova),
                          _NavItem(Icons.insights_outlined, Icons.insights_rounded, l.navInsights),
                          _NavItem(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, l.navMessages, badge: widget.unreadMessages),
                        ]
                      : <_NavItem>[
                          _NavItem(Icons.event_note_outlined, Icons.event_note_rounded, l.navSchedule),
                          _NavItem(Icons.groups_outlined, Icons.groups_rounded, l.navClassrooms),
                          _NavItem(Icons.auto_awesome_outlined, Icons.auto_awesome_rounded, l.navPractice),
                          _NavItem(Icons.insights_outlined, Icons.insights_rounded, l.navInsights),
                          _NavItem(Icons.psychology_outlined, Icons.psychology_rounded, l.navNova),
                        ],
              index: widget.idx,
              onTap: widget.onTap,
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
    final pillTint = cs.surface;

    // ── Android Material-3 fallback ──────────────────────────────────────
    // The iOS 26 liquid-glass aesthetic is platform-specific; on Android
    // it'd feel out of place against the rest of the M3 system chrome.
    // Render Flutter's NavigationBar instead — themed automatically, gets
    // ripple + indicator for free.
    if (!Platform.isIOS && !Platform.isMacOS) {
      return NavigationBar(
        selectedIndex: widget.index,
        onDestinationSelected: (i) {
          HapticFeedback.lightImpact();
          widget.onTap(i);
        },
        destinations: [
          for (final item in widget.items)
            NavigationDestination(
              icon: _BadgedIcon(icon: item.icon, badge: item.badge),
              selectedIcon: _BadgedIcon(icon: item.selectedIcon, badge: item.badge),
              label: item.label,
            ),
        ],
      );
    }

    // ── iOS / macOS liquid-glass floating pill ───────────────────────────
    return SafeArea(
      top: false, left: false, right: false, bottom: true,
      child: Padding(
        // Bigger margin all around for the "floating island" look —
        // detached from the screen edges instead of flush against them.
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: LayoutBuilder(builder: (context, box) {
          final width = box.maxWidth;
          return Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (e) => _onPointerDown(e, width),
            onPointerMove: (e) => _onPointerMove(e, width),
            onPointerUp: (e) => _onPointerUp(e, width),
            onPointerCancel: _onPointerCancel,
            // Soft outer shadow for depth — the glass already has a subtle
            // highlight on the top edge via the native UIVisualEffectView.
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.12),
                    blurRadius: 22,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: NativeGlassView(
                  // Pill-style — half the bar height for a true capsule.
                  borderRadius: 34,
                  style: NativeGlassStyle.regular,
                  fallbackColor: pillTint,
                  child: SizedBox(
                    height: 58,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _SelectionCapsule(
                          itemCount: widget.items.length,
                          selectedIndex: _hoveredIndex ?? widget.index,
                          isDark: isDark,
                          totalWidth: width,
                          dragDx: _dragDx,
                          dragDy: _dragDy,
                          isRtl: _isRtl,
                        ),
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

/// Wraps a tab icon with a small red dot in the corner when the item has
/// unread items (used by the Messages tab). Lives in module scope so the
/// M3 NavigationBar branch above can also share it.
class _BadgedIcon extends StatelessWidget {
  const _BadgedIcon({required this.icon, required this.badge});
  final IconData icon;
  final int badge;

  @override
  Widget build(BuildContext context) {
    if (badge <= 0) return Icon(icon);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        Positioned(
          right: -4, top: -2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(8),
            ),
            constraints: const BoxConstraints(minWidth: 14),
            child: Text(
              badge > 99 ? '99+' : '$badge',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onError,
                fontSize: 9, fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
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
    required this.dragDy,
    required this.isRtl,
  });
  final int itemCount;
  final int selectedIndex;
  final bool isDark;
  final double totalWidth;
  final double dragDx;
  final double dragDy;
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final slotW = totalWidth / itemCount;
    final baseW = slotW - 8;
    // More dramatic stretch — up to 55% wider (matches parent sx)
    final stretch = (dragDx.abs() / 120).clamp(0.0, 0.55);
    final capsuleW = baseW * (1 + stretch);
    final offset = (capsuleW - baseW) / 2;
    final edge = slotW * selectedIndex + 4 - offset;

    // Vertical grow when dragged up/down (pill can exceed bar height)
    final sy = 1.0 + (dragDy.abs() / 120).clamp(0.0, 0.40);

    // Pill scales with both dx and dy for the dramatic iOS 26 feel
    final child = Transform(
      alignment: Alignment.center,
      transform: Matrix4.diagonal3Values(1.0 + stretch * 0.2, sy, 1.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.22)
              : cs.onSurface.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(22),
        ),
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

/// Single tab icon + label. The bouncy spring pulse when a tab becomes
/// selected is the "alive" feel from the iOS 26 spec — the press itself is
/// detected by the parent Listener (which already handles drag physics), but
/// we mirror the selection change with a per-tab scale spring so the user
/// gets the visual "boop" they expect.
class _TabLabel extends StatefulWidget {
  const _TabLabel({
    required this.item,
    required this.selected,
    required this.hovered,
    required this.activeColor,
  });
  final _NavItem item;
  final bool selected;
  final bool hovered;
  final Color activeColor;

  @override
  State<_TabLabel> createState() => _TabLabelState();
}

class _TabLabelState extends State<_TabLabel> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  static const _spring = SpringDescription(mass: 1, stiffness: 320, damping: 14);

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController.unbounded(vsync: this, value: 1);
  }

  @override
  void didUpdateWidget(covariant _TabLabel old) {
    super.didUpdateWidget(old);
    // Fresh selection → squish-then-bounce. Skipping the case where the tab
    // was already selected avoids a pulse on rebuild for unrelated reasons.
    if (widget.selected && !old.selected) {
      _pulse.stop();
      _pulse.value = 0.82;
      _pulse.animateWith(SpringSimulation(_spring, 0.82, 1.0, 0));
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inactiveColor = CupertinoColors.inactiveGray.resolveFrom(context);
    final color = (widget.selected || widget.hovered) ? widget.activeColor : inactiveColor;
    final iconData = widget.selected ? widget.item.selectedIcon : widget.item.icon;
    final hasBadge = widget.item.badge > 0;

    return SizedBox.expand(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, child) => Transform.scale(scale: _pulse.value, child: child),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 140),
                  child: Icon(iconData, key: ValueKey('${widget.item.label}_${widget.selected}'), size: 22, color: color),
                ),
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
                      widget.item.badge > 99 ? '99+' : '${widget.item.badge}',
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
              fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w400,
              color: color,
              height: 1.0,
              letterSpacing: -0.1,
            ),
            child: Text(widget.item.label, maxLines: 1, overflow: TextOverflow.ellipsis),
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
          backgroundColor: cs.primaryContainer,
          foregroundColor: cs.onPrimaryContainer,
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
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color),
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
  Size get preferredSize => const Size.fromHeight(88);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final logoW = (MediaQuery.sizeOf(context).width - 52 - 120).clamp(120.0, 300.0);

    return AppBar(
      toolbarHeight: 88,
      titleSpacing: 0,
      centerTitle: true,
      leadingWidth: 52,
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Builder(
        builder: (ctx) => Padding(
          padding: const EdgeInsets.only(left: 4),
          child: IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      title: ClassMateLogo(width: logoW),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Text(
                title,
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.2),
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
        cohortId: courseId,
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
        color: cs.surfaceContainerLow,
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
              const Center(child: CmLoading())
            else
              LiquidGlassDropdown<String>(
                label: widget.l.teacherGradesFieldCourse,
                value: _selectedCourseId ?? '',
                items: _courses.map((c) => LiquidGlassDropdownItem(value: c.id, label: c.name)).toList(),
                onChanged: (v) => setState(() => _selectedCourseId = v.isEmpty ? null : v),
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

/// Thin sticky bar shown to parents at the top of every /parent/* route
/// (except /parent/home). Renders the currently-selected child + a
/// dropdown to switch between siblings, so the parent never has to back
/// out to the home screen just to look at a different child's data.
class _ParentChildSwitcherBar extends ConsumerWidget {
  const _ParentChildSwitcherBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final childrenAsync = ref.watch(parentChildrenProvider);
    final selectedId = ref.watch(selectedChildProvider);

    return childrenAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (children) {
        if (children.isEmpty) return const SizedBox.shrink();
        final selected = children.firstWhere(
          (c) => c.studentId == selectedId,
          orElse: () => children.first,
        );
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            border: Border(bottom: BorderSide(color: cs.outlineVariant, width: 0.5)),
          ),
          child: Row(
            children: [
              Icon(Icons.visibility_rounded, size: 16, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'Viewing as ',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: children.length <= 1
                      ? null
                      : () => _openSwitcher(context, ref, children, selected.studentId),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          selected.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (selected.gradeLabel.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          '· ${selected.gradeLabel}',
                          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                        ),
                      ],
                      if (children.length > 1) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.expand_more_rounded, size: 18, color: cs.onSurfaceVariant),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openSwitcher(
    BuildContext context,
    WidgetRef ref,
    List<ParentChild> children,
    String currentId,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Text(
                  'Switch child',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              for (final c in children)
                RadioListTile<String>(
                  value: c.studentId,
                  groupValue: currentId,
                  onChanged: (v) {
                    if (v != null) {
                      ref.read(selectedChildProvider.notifier).select(v);
                    }
                    Navigator.of(ctx).pop();
                  },
                  title: Text(c.name),
                  subtitle: c.gradeLabel.isNotEmpty ? Text(c.gradeLabel) : null,
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
