import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_session.dart';
import '../../../l10n/app_localizations.dart';
import '../data/parent_models.dart';
import '../data/parent_repository.dart';
import 'widgets/child_picker.dart';

/// Parent's main landing. Two regions:
///   • Top: child picker (chip-list of approved children). The selected
///     id is broadcast through `selectedChildProvider` so every parent
///     screen reads the same child.
///   • Below: tile grid of the parent's tools — schedule, grades,
///     attendance, notifications.
class ParentHomeScreen extends ConsumerWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final session = ref.watch(authSessionProvider);
    final children = ref.watch(parentChildrenProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(parentChildrenProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const SizedBox(height: 4),
            Text(
              'Hi ${session.displayName.isNotEmpty ? session.displayName : 'there'} 👋',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              session.schoolName.isNotEmpty
                  ? 'Parent · ${session.schoolName}'
                  : 'Parent',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),

            // Child picker
            children.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 22),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => _ErrorTile(
                message: 'Could not load your children: $e',
                onRetry: () => ref.invalidate(parentChildrenProvider),
              ),
              data: (list) => _ChildrenSection(children: list),
            ),

            const SizedBox(height: 22),

            Text(
              'Your tools',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            _ToolsGrid(
              hasChild: children.maybeWhen(data: (l) => l.isNotEmpty, orElse: () => false),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildrenSection extends ConsumerWidget {
  const _ChildrenSection({required this.children});
  final List<ParentChild> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    if (children.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: cs.onSurfaceVariant),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'No approved children yet. Ask your school to link your account.',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ),
          ],
        ),
      );
    }
    return ChildPicker(children: children);
  }
}

class _ToolsGrid extends ConsumerWidget {
  const _ToolsGrid({required this.hasChild});
  final bool hasChild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final selected = ref.watch(selectedChildProvider);
    final disabledMsg = !hasChild
        ? 'No child linked yet'
        : selected == null
            ? 'Pick a child first'
            : null;

    final tiles = <_ToolDef>[
      _ToolDef(
        icon: Icons.event_note_rounded,
        label: l.navSchedule,
        route: '/parent/schedule',
      ),
      _ToolDef(
        icon: Icons.grade_rounded,
        label: l.navGrades,
        route: '/parent/grades',
      ),
      _ToolDef(
        icon: Icons.how_to_reg_rounded,
        label: l.navAttendance,
        route: '/parent/attendance',
      ),
      _ToolDef(
        icon: Icons.notifications_rounded,
        label: l.navNotifications,
        route: '/parent/notifications',
        ignoreSelection: true, // notifications aggregate across children
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: tiles.length,
      itemBuilder: (ctx, i) {
        final t = tiles[i];
        final blocked = !t.ignoreSelection && disabledMsg != null;
        return _ToolTile(
          icon: t.icon,
          label: t.label,
          disabledNote: blocked ? disabledMsg : null,
          onTap: blocked ? null : () => context.push(t.route),
        );
      },
    );
  }
}

class _ToolDef {
  final IconData icon;
  final String label;
  final String route;
  final bool ignoreSelection;
  const _ToolDef({
    required this.icon,
    required this.label,
    required this.route,
    this.ignoreSelection = false,
  });
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({required this.icon, required this.label, this.onTap, this.disabledNote});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final String? disabledNote;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: enabled ? cs.primaryContainer : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 26, color: enabled ? cs.onPrimaryContainer : cs.onSurfaceVariant),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: enabled ? cs.onPrimaryContainer : cs.onSurface,
                    ),
                  ),
                  if (disabledNote != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        disabledNote!,
                        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: cs.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: TextStyle(color: cs.onErrorContainer))),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
