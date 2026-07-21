import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../l10n/app_localizations.dart';
import 'manager_schools_screen.dart';
import 'manager_managers_screen.dart';
import 'manager_bagrut_manage_screen.dart';

/// Self-contained platform-owner console. Deliberately NOT wired into the
/// shared AppShell (whose per-role tab switches are index-aligned) — this keeps
/// the manager surface isolated. Three tabs: Schools · Managers · Bagrut.
class ManagerShell extends ConsumerStatefulWidget {
  const ManagerShell({super.key});

  @override
  ConsumerState<ManagerShell> createState() => _ManagerShellState();
}

class _ManagerShellState extends ConsumerState<ManagerShell> {
  int _index = 0;

  static const _pages = <Widget>[
    ManagerSchoolsScreen(),
    ManagerManagersScreen(),
    ManagerBagrutManageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.school_rounded), label: l.navSchools),
          NavigationDestination(
              icon: const Icon(Icons.admin_panel_settings_rounded),
              label: l.navManagers),
          NavigationDestination(
              icon: const Icon(Icons.history_edu_rounded), label: l.navBagrut),
        ],
      ),
    );
  }
}

/// Small shared app-bar action to sign out of the owner console.
class ManagerLogoutAction extends ConsumerWidget {
  const ManagerLogoutAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: 'Sign out',
      icon: const Icon(Icons.logout_rounded),
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Sign out?'),
            content: const Text('You will return to the login screen.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sign out')),
            ],
          ),
        );
        if (confirm == true) {
          await ref.read(authSessionProvider).logout();
        }
      },
    );
  }
}
