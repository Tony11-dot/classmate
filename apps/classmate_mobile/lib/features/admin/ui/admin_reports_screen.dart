import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../data/admin_repository.dart';

/// Triage queue for user-filed reports on chat messages. Required by
/// Google Play policy for any app with user-to-user messaging — admins
/// see each report, decide whether the content violates rules, and mark
/// it Resolved (action taken) or Dismissed (no action needed).
final _reportsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, status) {
  return ref.watch(adminRepositoryProvider).listReports(status: status);
});

class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  ConsumerState<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen> {
  String _filter = 'OPEN';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final async = ref.watch(_reportsProvider(_filter));

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'OPEN', label: Text(AppLocalizations.of(context)!.adminReportsOpenTab)),
                  ButtonSegment(value: 'RESOLVED', label: Text(AppLocalizations.of(context)!.adminReportsResolvedTab)),
                  ButtonSegment(value: 'DISMISSED', label: Text(AppLocalizations.of(context)!.adminReportsDismissedTab)),
                ],
                selected: {_filter},
                onSelectionChanged: (s) => setState(() => _filter = s.first),
              ),
            ),
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (reports) {
                  if (reports.isEmpty) {
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                      children: [
                        const SizedBox(height: 60),
                        Icon(Icons.inbox_outlined,
                            size: 64, color: cs.outlineVariant),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            _filter == 'OPEN'
                                ? AppLocalizations.of(context)!.adminReportsNoOpen
                                : AppLocalizations.of(context)!.adminReportsNoInView,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(_reportsProvider(_filter));
                      await ref.read(_reportsProvider(_filter).future);
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                      itemCount: reports.length,
                      itemBuilder: (ctx, i) =>
                          _ReportCard(report: reports[i], filter: _filter),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends ConsumerWidget {
  const _ReportCard({required this.report, required this.filter});

  final Map<String, dynamic> report;
  final String filter;

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
    final isOpen = filter == 'OPEN';

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
              Text(
                '${reporter['name'] ?? 'Someone'} reported ${sender['name'] ?? 'a user'}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
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
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            'Reported ${report['createdAt']?.toString().split('T').first ?? ''}',
            style: theme.textTheme.bodySmall?.copyWith(color: cs.outline),
          ),
          if (isOpen) ...[
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
      ref.invalidate(_reportsProvider(filter));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }
}
