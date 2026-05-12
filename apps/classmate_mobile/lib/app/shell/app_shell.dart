import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
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
import '../../features/lifedoc/student_materials_screen.dart';
import '../../features/messages/providers/messages_repository_provider.dart';
import '../../features/teacher_mobile/data/teacher_mobile_repository.dart';
import '../../features/teacher_mobile/ui/teacher_forms_screen.dart';
import '../../ui/glass/native_glass_view.dart';
import '../../ui/nav/main_drawer.dart';
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

const _adminBottomNavPaths = <String>{
  '/admin/dashboard',
  '/admin/people',
  '/admin/cohorts',
  '/admin/schedule',
  '/messages',
};

const _secretaryBottomNavPaths = <String>{
  '/announcements',
  '/secretary/students',
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
    '/admin/',
    '/secretary/students',
    '/secretary/',
    '/messages',
    '/tutor',
    '/announcements',
    '/notifications',
    '/profile',
    '/settings',
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
    '/admin/' => l.roleAdmin,
    '/secretary/students' => l.adminStudents,
    '/secretary/' => l.roleSecretary,
    '/messages' => l.titleMessages,
    '/tutor' => l.titleNova,
    '/announcements' => l.navAnnouncements,
    '/notifications' => l.navNotifications,
    '/profile' => l.navProfile,
    '/settings' => l.navSettings,
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
    final path = _routePathOnly(loc);
    if (isAdminLike) {
      final allowed = isAdmin ? _adminBottomNavPaths : _secretaryBottomNavPaths;
      return !allowed.contains(path);
    }
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

    // Dismiss keyboard whenever any scroll view starts scrolling — applies
    // globally so every screen gets dismiss-on-drag without per-ListView changes.
    return NotificationListener<ScrollStartNotification>(
      onNotification: (n) {
        FocusManager.instance.primaryFocus?.unfocus();
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
    return Scaffold(
      extendBody: true,
      drawerEnableOpenDragGesture: !widget.hideTopBar,
      drawer: widget.hideTopBar ? null : const MainDrawer(),
      appBar: widget.hideTopBar ? null : _TopBar(title: widget.pageTitle),
      body: widget.child,
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
    // Match the app background exactly — solid, no blur, no tint.
    final pillTint = cs.surface;

    // Stretch factors — large enough to overflow the bar (dramatic iOS 26 feel)
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
            // Bar stays static — only the pill capsule reacts to drag
            child: NativeGlassView(
                borderRadius: 28,
                style: NativeGlassStyle.regular,
                fallbackColor: pillTint,
                child: SizedBox(
                  height: 54,
                  child: Stack(
                    clipBehavior: Clip.none,
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
                        dragDy: _dragDy,
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
              const Center(child: const CmLoading())
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
