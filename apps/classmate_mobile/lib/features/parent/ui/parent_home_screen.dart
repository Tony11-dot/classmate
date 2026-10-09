import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/theme/cm_tokens.dart';
import '../../../ui/widgets/cm_press.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../data/parent_models.dart';
import '../data/parent_repository.dart';
import 'widgets/child_picker.dart';
import '../../../ui/widgets/cm_refresh_indicator.dart';

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
    final l = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);
    final children = ref.watch(parentChildrenProvider);
    final greetingName = session.displayName.isNotEmpty ? session.displayName : l.parentHomeScreenGreetingFallback;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CmRefreshIndicator(
        onRefresh: () async {
          ref.invalidate(parentChildrenProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: cs.primaryContainer,
                  foregroundColor: cs.onPrimaryContainer,
                  child: Text(
                    greetingName.characters.isEmpty
                        ? '?'
                        : greetingName.characters.first.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.parentHomeGreeting(greetingName),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        session.schoolName.isNotEmpty
                            ? '${l.roleParent} · ${session.schoolName}'
                            : l.roleParent,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Child picker
            children.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CmLoading()),
              ),
              error: (e, _) => _ErrorTile(
                message: l.parentHomeScreenChildrenLoadError(e.toString()),
                onRetry: () => ref.invalidate(parentChildrenProvider),
              ),
              data: (list) => _ChildrenSection(children: list),
            ),

            const SizedBox(height: 14),

            Text(
              l.parentYourTools,
              style: theme.textTheme.titleLarge?.copyWith(
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
          borderRadius: BorderRadius.circular(CmTokens.radiusLg),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: cs.onSurfaceVariant),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.parentNoApprovedChildren,
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
        ? l.parentNoChildLinked
        : selected == null
            ? l.parentPickChildFirst
            : null;

    final tiles = <_ToolDef>[
      _ToolDef(
        icon: Icons.insights_rounded,
        label: l.navInsights,
        route: '/parent/overview',
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
        icon: Icons.assignment_outlined,
        label: l.navAssignments,
        route: '/parent/assignments',
      ),
      _ToolDef(
        icon: Icons.fact_check_outlined,
        label: l.navExams,
        route: '/parent/exams',
      ),
      _ToolDef(
        icon: Icons.workspace_premium_outlined,
        label: l.navDiplomas,
        route: '/parent/certificates',
      ),
      _ToolDef(
        icon: Icons.folder_outlined,
        label: l.parentHomeScreenMaterials,
        route: '/parent/materials',
      ),
      _ToolDef(
        icon: Icons.event_available_outlined,
        label: l.navMeetings,
        route: '/parent/meetings',
      ),
      _ToolDef(
        icon: Icons.campaign_outlined,
        label: l.navAnnouncements,
        route: '/announcements',
        ignoreSelection: true, // announcements are school-wide
      ),
      _ToolDef(
        icon: Icons.notifications_rounded,
        label: l.navNotifications,
        route: '/parent/notifications',
        ignoreSelection: true, // notifications aggregate across children
      ),
    ];

    // Same 1.75 shape as before, but never shorter than the content: with the
    // "pick a child" note under the label the fixed ratio clipped every tile
    // on a standard iPhone (and with larger system text).
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final minHeight = 26 + 40 + 8 + 38 * scale;
    return LayoutBuilder(builder: (context, c) {
      final tileW = (c.maxWidth - 12) / 2;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: math.max(tileW / 1.75, minHeight),
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
    });
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
    final tokens = CmTokens.of(context);
    return CmPress(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: CmTokens.fast,
        opacity: enabled ? 1 : 0.6,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(CmTokens.radiusLg),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.35),
              width: 0.8,
            ),
            boxShadow: enabled ? tokens.shadowSm : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: enabled ? cs.primaryContainer : cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(CmTokens.radiusSm),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: enabled ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: cs.onSurface,
                    ),
                  ),
                  if (disabledNote != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        disabledNote!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
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
        borderRadius: BorderRadius.circular(CmTokens.radiusMd),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: cs.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: TextStyle(color: cs.onErrorContainer))),
          TextButton(onPressed: onRetry, child: Text(AppLocalizations.of(context)!.commonRetry)),
        ],
      ),
    );
  }
}
