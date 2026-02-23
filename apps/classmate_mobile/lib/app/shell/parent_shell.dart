import '../../core/i18n/locale_controller.dart';
import 'package:classmate_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../features/account/customization_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/parent/parent_controller.dart';
import '../../core/parent/parent_models.dart';

class ParentShell extends ConsumerStatefulWidget {
  const ParentShell({super.key});

  @override
  ConsumerState<ParentShell> createState() => _ParentShellState();
}

class _ParentShellState extends ConsumerState<ParentShell> {
  int idx = 1; // default to Overview
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!_loaded) {
      _loaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(parentControllerProvider.notifier).load();
      });
    }

    final pages = <Widget>[
      _CenterText(l10n.schedule),
      _ParentOverviewBody(),
      _CenterText(l10n.aiTutor),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          idx == 0
              ? l10n.schedule
              : idx == 1
              ? l10n.overview
              : l10n.aiTutor,
        ),
      ),
      drawer: const _ParentDrawer(),
      body: SafeArea(child: pages[idx]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => setState(() => idx = i),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            label: l10n.schedule,
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: l10n.overview,
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
            label: l10n.aiTutor,
          ),
        ],
      ),
    );
  }
}

class _ParentDrawer extends ConsumerWidget {
  const _ParentDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final s = ref.watch(parentControllerProvider);
    final selected = _findSelected(s.children, s.selectedChildId);

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // __LANG_PICKER__
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                final loc = ref.watch(localeControllerProvider);
                String label(Locale? x) {
                  final code = x?.languageCode;
                  if (code == 'ar') return l10n.arabic;
                  if (code == 'he') return l10n.hebrew;
                  return l10n.english;
                }

                return ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n.language),
                  subtitle: Text(label(loc)),
                  onTap: () async {
                    final chosen = await showModalBottomSheet<String>(
                      context: context,
                      showDragHandle: true,
                      builder: (ctx) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: Text(l10n.english),
                              onTap: () => Navigator.pop(ctx, 'en'),
                            ),
                            ListTile(
                              title: Text(l10n.arabic),
                              onTap: () => Navigator.pop(ctx, 'ar'),
                            ),
                            ListTile(
                              title: Text(l10n.hebrew),
                              onTap: () => Navigator.pop(ctx, 'he'),
                            ),
                          ],
                        ),
                      ),
                    );
                    if (chosen == null) return;
                    await ref
                        .read(localeControllerProvider.notifier)
                        .setLocale(Locale(chosen));
                    if (context.mounted) Navigator.pop(context);
                  },
                );
              },
            ),
            DrawerHeader(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ClassMate',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selected == null
                        ? l10n.noChildSelected
                        : '${l10n.childPrefix}: ${selected.fullName}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () =>
                        ref.read(parentControllerProvider.notifier).load(),
                    icon: Icon(Icons.refresh),
                    label: Text(l10n.refreshData),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(l10n.tools),
            ),

            ListTile(
              leading: const Icon(Icons.event_available_outlined),
              title: Text(l10n.attendance),
              onTap: () {
                Navigator.pop(context);
                _snack(context, 'TODO: Attendance screen');
              },
            ),
            ListTile(
              leading: const Icon(Icons.grade_outlined),
              title: Text(l10n.grades),
              onTap: () {
                Navigator.pop(context);
                _snack(context, 'TODO: Grades screen');
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_none),
              title: Text(l10n.notifications),
              onTap: () {
                Navigator.pop(context);
                _snack(context, 'TODO: Notifications screen');
              },
            ),
            ListTile(
              leading: const Icon(Icons.play_circle_outline),
              title: Text(l10n.myChildSolutions),
              onTap: () {
                Navigator.pop(context);
                _snack(context, 'TODO: My child solutions screen');
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(l10n.settingsCustomization),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CustomizationScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  ParentChild? _findSelected(List<ParentChild> kids, String? id) {
    if (kids.isEmpty) return null;
    if (id == null) return kids.first;
    for (final c in kids) {
      if (c.id == id) return c;
    }
    return kids.first;
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _ParentOverviewBody extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(parentControllerProvider);

    if (s.loading && s.children.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (s.children.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No children yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Backend needs to return linked children for this parent.',
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () =>
                  ref.read(parentControllerProvider.notifier).load(),
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    final selected =
        _findSelected(s.children, s.selectedChildId) ?? s.children.first;
    final k = s.overview;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selected.id,
                items: s.children
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.fullName),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  ref.read(parentControllerProvider.notifier).selectChild(v);
                },
                decoration: const InputDecoration(
                  labelText: 'Child',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              tooltip: 'Refresh',
              onPressed: () =>
                  ref.read(parentControllerProvider.notifier).load(),
              icon: Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _KpiGrid(
          items: [
            _Kpi(
              title: 'Attendance',
              value: k?.attendancePct == null
                  ? '—'
                  : '${k!.attendancePct!.toStringAsFixed(0)}%',
              icon: Icons.event_available_outlined,
            ),
            _Kpi(
              title: 'Avg grade',
              value: k?.avgGrade == null
                  ? '—'
                  : k!.avgGrade!.toStringAsFixed(1),
              icon: Icons.grade_outlined,
            ),
            _Kpi(
              title: 'Missing',
              value: k?.missingAssignments?.toString() ?? '—',
              icon: Icons.assignment_late_outlined,
            ),
            _Kpi(
              title: 'Alerts',
              value: k?.alerts?.toString() ?? '—',
              icon: Icons.notifications_none,
            ),
          ],
        ),

        const SizedBox(height: 18),
        const _Section(
          title: 'This is a SUMMARY',
          child: Text(
            'Full Attendance / Grades / Notifications / My Child Solutions are in the drawer.\n'
            'Overview is just the quick snapshot for parents.',
          ),
        ),
      ],
    );
  }

  ParentChild? _findSelected(List<ParentChild> kids, String? id) {
    if (id == null) return null;
    for (final c in kids) {
      if (c.id == id) return c;
    }
    return null;
  }
}

class _CenterText extends StatelessWidget {
  _CenterText(this.text);
  final String text;
  @override
  Widget build(BuildContext context) =>
      Center(child: Text(text, style: Theme.of(context).textTheme.titleMedium));
}

class _Kpi {
  const _Kpi({required this.title, required this.value, required this.icon});
  final String title;
  final String value;
  final IconData icon;
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.items});
  final List<_Kpi> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 700 ? 4 : 2;
        final w = (c.maxWidth - (12 * (cols - 1))) / cols;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items
              .map(
                (k) => SizedBox(
                  width: w,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(k.icon),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  k.title,
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  k.value,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
