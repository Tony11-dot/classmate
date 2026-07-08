import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_session.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../solutions/data/solutions_api.dart';
import '../../solutions/data/solutions_live_mapper.dart';
import '../../solutions/ui/widgets/solution_asset_preview_sheet.dart';
import '../data/admin_repository.dart';

/// Unified moderation queue. Two kinds of user reports now live here behind a
/// single segmented control instead of two separate drawer destinations:
///   • Messages  — user-filed reports on chat messages (Google Play policy)
///   • Solutions — reports on community solution uploads
///   • Resolved  — everything already actioned, from BOTH sources (read-only)
final _messageReportsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, status) {
  return ref.watch(adminRepositoryProvider).listReports(status: status);
});

/// Handled message reports — resolved AND dismissed, merged for the
/// "Resolved" tab.
final _resolvedMessageReportsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  final resolved = await repo.listReports(status: 'RESOLVED');
  final dismissed = await repo.listReports(status: 'DISMISSED');
  return [...resolved, ...dismissed];
});

/// All solution reports (pending + handled) — the screen splits them by
/// status into the Solutions and Resolved tabs.
final _solutionReportsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final res = await ref.watch(solutionsApiProvider).fetchReports();
  final list = res['items'];
  return list is List
      ? list
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry('$k', v)))
          .toList()
      : const <Map<String, dynamic>>[];
});

enum _ReportsTab { messages, solutions, resolved }

class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  ConsumerState<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen> {
  _ReportsTab _tab = _ReportsTab.messages;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: SegmentedButton<_ReportsTab>(
                segments: [
                  ButtonSegment(
                    value: _ReportsTab.messages,
                    label: Text(l.titleMessages,
                        maxLines: 1, softWrap: false, overflow: TextOverflow.fade),
                  ),
                  ButtonSegment(
                    value: _ReportsTab.solutions,
                    label: Text(l.titleSolutions,
                        maxLines: 1, softWrap: false, overflow: TextOverflow.fade),
                  ),
                  ButtonSegment(
                    value: _ReportsTab.resolved,
                    label: Text(l.adminReportsResolvedTab,
                        maxLines: 1, softWrap: false, overflow: TextOverflow.fade),
                  ),
                ],
                selected: {_tab},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _tab = s.first),
              ),
            ),
            Expanded(child: _body(context)),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    switch (_tab) {
      case _ReportsTab.messages:
        return _MessagesTab();
      case _ReportsTab.solutions:
        return _SolutionsTab();
      case _ReportsTab.resolved:
        return _ResolvedTab();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  Messages tab — open chat-message reports, actionable
// ─────────────────────────────────────────────────────────────────────────
class _MessagesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final async = ref.watch(_messageReportsProvider('OPEN'));

    return async.when(
      loading: () => const Center(child: CmLoading()),
      error: (e, _) => Center(child: Text(l.commonErrorWith(e))),
      data: (reports) {
        if (reports.isEmpty) {
          return _EmptyState(icon: Icons.inbox_outlined, label: l.adminReportsNoOpen);
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(_messageReportsProvider('OPEN'));
            await ref.read(_messageReportsProvider('OPEN').future);
          },
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            itemCount: reports.length,
            itemBuilder: (ctx, i) =>
                _MessageReportCard(report: reports[i], actionable: true),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  Solutions tab — pending solution reports, actionable (admin only)
// ─────────────────────────────────────────────────────────────────────────
class _SolutionsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final isAdmin = ref.watch(authSessionProvider).primaryRole == 'ADMIN';
    final async = ref.watch(_solutionReportsProvider);

    return async.when(
      loading: () => const Center(child: CmLoading()),
      error: (e, _) => Center(child: Text(l.commonErrorWith(e))),
      data: (all) {
        final pending = all
            .where((r) => '${r['status'] ?? 'PENDING'}' == 'PENDING')
            .toList();
        if (pending.isEmpty) {
          return _EmptyState(
              icon: Icons.verified_user_rounded, label: l.solutionsReportsEmpty);
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(_solutionReportsProvider);
            await ref.read(_solutionReportsProvider.future);
          },
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            itemCount: pending.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _SolutionReportCard(
              report: pending[i],
              onApprove: isAdmin
                  ? () => _resolveSolution(context, ref, '${pending[i]['id']}', 'approve')
                  : null,
              onRemove: isAdmin
                  ? () => _resolveSolution(context, ref, '${pending[i]['id']}', 'remove')
                  : null,
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  Resolved tab — handled items from BOTH sources, read-only
// ─────────────────────────────────────────────────────────────────────────
class _ResolvedTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final msgAsync = ref.watch(_resolvedMessageReportsProvider);
    final solAsync = ref.watch(_solutionReportsProvider);

    if (msgAsync.isLoading || solAsync.isLoading) {
      return const Center(child: CmLoading());
    }
    if (msgAsync.hasError) {
      return Center(child: Text(l.commonErrorWith(msgAsync.error!)));
    }
    if (solAsync.hasError) {
      return Center(child: Text(l.commonErrorWith(solAsync.error!)));
    }

    final messages = msgAsync.value ?? const [];
    final solutions = (solAsync.value ?? const [])
        .where((r) => '${r['status'] ?? 'PENDING'}' != 'PENDING')
        .toList();

    if (messages.isEmpty && solutions.isEmpty) {
      return _EmptyState(
          icon: Icons.inbox_outlined, label: l.adminReportsNoInView);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(_resolvedMessageReportsProvider);
        ref.invalidate(_solutionReportsProvider);
        await Future.wait([
          ref.read(_resolvedMessageReportsProvider.future),
          ref.read(_solutionReportsProvider.future),
        ]);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          for (final r in solutions) ...[
            _SolutionReportCard(report: r, onApprove: null, onRemove: null),
            const SizedBox(height: 12),
          ],
          for (final r in messages)
            _MessageReportCard(report: r, actionable: false),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        const SizedBox(height: 60),
        Icon(icon, size: 64, color: cs.outlineVariant),
        const SizedBox(height: 12),
        Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  Message-report card
// ─────────────────────────────────────────────────────────────────────────
class _MessageReportCard extends ConsumerWidget {
  const _MessageReportCard({required this.report, required this.actionable});

  final Map<String, dynamic> report;
  final bool actionable;

  Map<String, dynamic> _m(dynamic v) =>
      v is Map<String, dynamic> ? v : const <String, dynamic>{};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final reporter = _m(report['reporter']);
    final message = _m(report['message']);
    final sender = _m(message['sender']);
    final reason = (report['reason'] ?? '').toString().trim();
    final text = (message['text'] ?? '').toString().trim();
    final mediaUrl = (message['mediaUrl'] ?? '').toString().trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag_rounded, size: 18, color: cs.error),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${reporter['name'] ?? 'Someone'} reported ${sender['name'] ?? 'a user'}',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (text.isNotEmpty)
                  Text(text, style: theme.textTheme.bodyMedium),
                if (mediaUrl.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: text.isEmpty ? 0 : 6),
                    child: Text(
                      AppLocalizations.of(context)!.adminReportsMediaAttachment,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ),
                if (text.isEmpty && mediaUrl.isEmpty)
                  Text(
                    AppLocalizations.of(context)!.adminReportsEmptyMessage,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          if (reason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.adminReportsReason(reason),
              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            'Reported ${report['createdAt']?.toString().split('T').first ?? ''}',
            style: theme.textTheme.bodySmall?.copyWith(color: cs.outline),
          ),
          if (actionable) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: Text(AppLocalizations.of(context)!.adminReportsDismiss),
                    onPressed: () => _act(context, ref, 'dismiss'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: Text(AppLocalizations.of(context)!.adminReportsResolve),
                    onPressed: () => _act(context, ref, 'resolve'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _act(BuildContext context, WidgetRef ref, String action) async {
    final id = (report['id'] ?? '').toString();
    if (id.isEmpty) return;
    final repo = ref.read(adminRepositoryProvider);
    try {
      if (action == 'resolve') {
        await repo.resolveReport(id);
      } else {
        await repo.dismissReport(id);
      }
      ref.invalidate(_messageReportsProvider('OPEN'));
      ref.invalidate(_resolvedMessageReportsProvider);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.commonFailedWith(e))),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  Solution-report card (moved here from the old standalone screen)
// ─────────────────────────────────────────────────────────────────────────
Future<void> _resolveSolution(
    BuildContext context, WidgetRef ref, String id, String action) async {
  final l = AppLocalizations.of(context)!;
  try {
    await ref.read(solutionsApiProvider).resolveReport(id: id, action: action);
    ref.invalidate(_solutionReportsProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              action == 'remove' ? l.solutionsReportRemoved : l.solutionsReportApproved)),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.solutionsBookSaveFailed('$e'))),
    );
  }
}

class _SolutionReportCard extends StatelessWidget {
  const _SolutionReportCard({
    required this.report,
    required this.onApprove,
    required this.onRemove,
  });

  final Map<String, dynamic> report;
  final VoidCallback? onApprove;
  final VoidCallback? onRemove;

  String _meta(AppLocalizations l, Map? person) {
    if (person == null) return l.commonUnknown;
    final parts = <String>[];
    final name = '${person['name'] ?? ''}'.trim();
    if (name.isNotEmpty) parts.add(name);
    final gradeRaw = person['grade'];
    final grade = gradeRaw is int ? gradeRaw : int.tryParse('${gradeRaw ?? ''}');
    final school = '${person['schoolName'] ?? ''}'.trim();
    final sub = <String>[];
    if (grade != null) sub.add(l.solutionsGradeLabel(grade));
    if (school.isNotEmpty) sub.add(school);
    return sub.isEmpty
        ? (name.isEmpty ? l.commonUnknown : name)
        : '${parts.join()} • ${sub.join(' • ')}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final status = '${report['status'] ?? 'PENDING'}';
    final isPending = status == 'PENDING';
    final showActions = isPending && onApprove != null && onRemove != null;
    final uploadRaw = report['upload'];
    final card = uploadRaw is Map
        ? SolutionsLiveMapper.mapUpload(uploadRaw.map((k, v) => MapEntry('$k', v)))
        : null;
    final reason = '${report['reason'] ?? ''}'.trim();

    Color statusColor() {
      switch (status) {
        case 'REMOVED':
          return cs.error;
        case 'APPROVED':
          return Colors.green;
        default:
          return cs.tertiary;
      }
    }

    String statusLabel() {
      switch (status) {
        case 'REMOVED':
          return l.solutionsReportStatusRemoved;
        case 'APPROVED':
          return l.solutionsReportStatusApproved;
        default:
          return l.solutionsReportStatusPending;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isPending ? cs.tertiary.withValues(alpha: 0.5) : cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag_rounded, size: 18, color: statusColor()),
              const SizedBox(width: 6),
              Text(statusLabel(),
                  style: TextStyle(fontWeight: FontWeight.w800, color: statusColor())),
            ],
          ),
          const SizedBox(height: 12),
          _row(context, l.solutionsReportPostedBy, _meta(l, report['poster'] as Map?)),
          const SizedBox(height: 4),
          _row(context, l.solutionsReportReportedBy, _meta(l, report['reporter'] as Map?)),
          if (reason.isNotEmpty) ...[
            const SizedBox(height: 4),
            _row(context, l.solutionsReportReasonLabel, reason),
          ],
          const Divider(height: 24),
          if (card != null) ...[
            if (card.caption.trim().isNotEmpty)
              Text(card.caption, style: const TextStyle(height: 1.35)),
            const SizedBox(height: 4),
            Text(
              l.solutionsPageQuestionSummary(card.pageNumber, card.questionNumber),
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12.5),
            ),
            const SizedBox(height: 10),
            if (card.assets.isNotEmpty) SolutionMediaStrip(assets: card.assets),
          ],
          if (showActions) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_rounded),
                    label: Text(l.solutionsReportKeepAction),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: cs.error),
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: Text(l.solutionsReportRemoveAction),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(text: '$label  ', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
          TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
