import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/solutions_api.dart';
import '../../data/solutions_live_mapper.dart';
import '../widgets/solution_asset_preview_sheet.dart';

/// Admin-only review queue for reported solutions. Shows the full solution
/// (caption + attachments), who posted it (name/grade/school) and who reported
/// it, then lets the admin APPROVE (keep) or REMOVE (delete) it.
class SolutionsReportsAdminScreen extends ConsumerStatefulWidget {
  const SolutionsReportsAdminScreen({super.key});

  @override
  ConsumerState<SolutionsReportsAdminScreen> createState() => _SolutionsReportsAdminScreenState();
}

class _SolutionsReportsAdminScreenState extends ConsumerState<SolutionsReportsAdminScreen> {
  bool _loading = false;
  List<Map<String, dynamic>> _reports = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ref.read(solutionsApiProvider).fetchReports();
      final list = res['items'];
      _reports = list is List
          ? list.whereType<Map>().map((e) => e.map((k, v) => MapEntry('$k', v))).toList()
          : const [];
    } catch (_) {
      _reports = const [];
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resolve(String id, String action) async {
    final l = AppLocalizations.of(context)!;
    try {
      await ref.read(solutionsApiProvider).resolveReport(id: id, action: action);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(action == 'remove' ? l.solutionsReportRemoved : l.solutionsReportApproved)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.solutionsBookSaveFailed('$e'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.solutionsReportsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_user_rounded, size: 52, color: cs.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text(l.solutionsReportsEmpty,
                            textAlign: TextAlign.center, style: TextStyle(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    itemCount: _reports.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _ReportCard(
                      report: _reports[i],
                      onApprove: () => _resolve('${_reports[i]['id']}', 'approve'),
                      onRemove: () => _resolve('${_reports[i]['id']}', 'remove'),
                    ),
                  ),
                ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report, required this.onApprove, required this.onRemove});

  final Map<String, dynamic> report;
  final VoidCallback onApprove;
  final VoidCallback onRemove;

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
    return sub.isEmpty ? (name.isEmpty ? l.commonUnknown : name) : '${parts.join()} • ${sub.join(' • ')}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final status = '${report['status'] ?? 'PENDING'}';
    final isPending = status == 'PENDING';
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
        border: Border.all(color: isPending ? cs.tertiary.withValues(alpha: 0.5) : cs.outlineVariant),
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
          if (isPending) ...[
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
