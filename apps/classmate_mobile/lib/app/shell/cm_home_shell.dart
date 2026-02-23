import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/ui/cm_scaffold.dart';
import '../../core/ui/glass.dart';
import '../../features/messages/messages_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/schedule/schedule_screen.dart';
import '../../features/solutions/solutions_feed_screen.dart';
import '../../features/tutor/tutor_screen.dart';

class CMHomeShell extends ConsumerStatefulWidget {
  const CMHomeShell({super.key});

  @override
  ConsumerState<CMHomeShell> createState() => _CMHomeShellState();
}

class _CMHomeShellState extends ConsumerState<CMHomeShell> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final role = (auth.role ?? '').toLowerCase();

    final tabs = <({String title, IconData icon, Widget view})>[
      (title: 'Schedule', icon: Icons.calendar_month_rounded, view: ScheduleScreen(role: role)),
      (title: 'Solutions', icon: Icons.auto_awesome_mosaic_rounded, view: SolutionsFeedScreen(role: role)),
      (title: 'Tutor', icon: Icons.psychology_alt_rounded, view: TutorScreen(role: role)),
      (title: 'Messages', icon: Icons.chat_bubble_rounded, view: MessagesScreen(role: role)),
      (title: 'Profile', icon: Icons.person_rounded, view: ProfileScreen(role: role)),
    ];

    final cur = tabs[_i];

    return CMScaffold(
      title: cur.title,
      actions: [
        IconButton(
          onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Logout',
        ),
      ],
      body: cur.view,
      bottom: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: GlassCard(
          child: NavigationBar(
            selectedIndex: _i,
            onDestinationSelected: (v) => setState(() => _i = v),
            destinations: [
              for (final t in tabs)
                NavigationDestination(icon: Icon(t.icon), label: t.title),
            ],
          ),
        ),
      ),
    );
  }
}
