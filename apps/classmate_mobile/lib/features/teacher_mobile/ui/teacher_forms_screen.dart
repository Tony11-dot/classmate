import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/semester/school_semester.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/cm_tokens.dart';
import '../../../ui/widgets/semester_filter_bar.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../ui/widgets/cm_refresh_indicator.dart';

// Public trigger so AppShell can open the create sheet
class _FormsTrigger extends Notifier<int> {
  @override
  int build() => 0;
  void increment() => state++;
}

final teacherFormsCreateTriggerProvider = NotifierProvider<_FormsTrigger, int>(_FormsTrigger.new);

class TeacherFormsScreen extends ConsumerStatefulWidget {
  const TeacherFormsScreen({super.key});

  @override
  ConsumerState<TeacherFormsScreen> createState() => _TeacherFormsScreenState();
}

class _TeacherFormsScreenState extends ConsumerState<TeacherFormsScreen> {
  List<Map<String, dynamic>> _forms = [];
  bool _loading = true;
  String? _error;
  bool _showingPrevious = false;
  SemesterWindow? _selectedPast;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final forms = await ref.read(teacherMobileRepositoryProvider).listForms();
      if (!mounted) return;
      setState(() {
        _forms = forms;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _delete(String id, String title) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.teacherGradesDeleteAssessmentTitle),
        content: Text(l.teacherDeleteItemConfirm(title)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.classroomsForwardCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.teacherGradesDeleteAction)),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(teacherMobileRepositoryProvider).deleteForm(id);
    await _load();
  }

  Future<void> _viewResponses(String formId, String title) async {
    context.push('/teacher/forms/$formId/responses', extra: title);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    ref.listen<int>(teacherFormsCreateTriggerProvider, (prev, next) {
      if ((next) > (prev ?? 0)) {
        context.push<bool>('/teacher/forms/create').then((_) {
          if (mounted) _load();
        });
      }
    });

    // Semester split (by created date) — pills only show when the school
    // configured semesters.
    final semWindow = ref.watch(currentSemesterWindowProvider);
    final visible = visibleForSemester<Map<String, dynamic>>(
      _forms,
      (f) => DateTime.tryParse(f['createdAt'] as String? ?? ''),
      semWindow,
      _showingPrevious,
      _selectedPast,
    );

    return CmRefreshIndicator(
      onRefresh: _load,
      child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          // Hero banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(CmTokens.radiusXl),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  cs.secondary.withValues(alpha: cs.brightness == Brightness.dark ? 0.22 : 0.12),
                  cs.surfaceContainerLow,
                ],
              ),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35), width: 0.8),
              boxShadow: CmTokens.of(context).shadowSm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.teacherFormsTitle, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.1)),
                      const SizedBox(height: 4),
                      Text(l.teacherFormsCount(_forms.length), style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(color: cs.secondary, borderRadius: BorderRadius.circular(CmTokens.radiusSm)),
                  child: Icon(Icons.assignment_turned_in_rounded, size: 24, color: cs.onSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SemesterFilterBar(
            visible: semWindow != null,
            showingPrevious: _showingPrevious,
            selectedPast: _selectedPast,
            onPastChanged: (w) => setState(() => _selectedPast = w),
            onChanged: (v) => setState(() { _showingPrevious = v; if (!v) _selectedPast = null; }),
          ),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsetsDirectional.fromSTEB(14, 6, 6, 6),
                decoration: BoxDecoration(
                  color: cs.errorContainer,
                  borderRadius: BorderRadius.circular(CmTokens.radiusMd),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: cs.onErrorContainer),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_error!, style: TextStyle(color: cs.onErrorContainer))),
                    TextButton(onPressed: _load, child: Text(l.commonRetry)),
                  ],
                ),
              ),
            ),

          if (_loading && _forms.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CmLoading()))
          else if (visible.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.assignment_turned_in_outlined, size: 48, color: cs.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text(l.teacherFormsEmpty, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            )
          else
            ...(visible.map((form) {
              final id = form['id'] as String? ?? '';
              final title = form['title'] as String? ?? '';
              final subject = form['subject'] as String? ?? '';
              final published = form['published'] as bool? ?? false;
              final responsesCount = form['responsesCount'] as int? ?? 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Dismissible(
                  key: Key('form_$id'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: AlignmentDirectional.centerEnd,
                    padding: const EdgeInsetsDirectional.only(end: 20),
                    decoration: BoxDecoration(
                      color: cs.errorContainer,
                      borderRadius: BorderRadius.circular(CmTokens.radiusLg),
                    ),
                    child: Icon(Icons.delete_rounded, color: cs.onErrorContainer),
                  ),
                  confirmDismiss: (_) async {
                    await _delete(id, title);
                    return false; // We refresh manually
                  },
                  child: _FormCard(
                    title: title,
                    subject: subject,
                    published: published,
                    responsesCount: responsesCount,
                    onViewResponses: () => _viewResponses(id, title),
                  ),
                ),
              );
            })),
        ],
      ),
    );
  }
}

/// One form row: icon tile, title + subject, status pill, responses count and
/// the "View responses" action.
class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.title,
    required this.subject,
    required this.published,
    required this.responsesCount,
    required this.onViewResponses,
  });

  final String title;
  final String subject;
  final bool published;
  final int responsesCount;
  final VoidCallback onViewResponses;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dark = cs.brightness == Brightness.dark;
    final good = CmTokens.of(context).good;

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 10, 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(CmTokens.radiusLg),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35), width: 0.8),
        boxShadow: CmTokens.of(context).shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.secondary.withValues(alpha: dark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(CmTokens.radiusSm),
                ),
                child: Icon(Icons.assignment_rounded, size: 20, color: cs.secondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                    if (subject.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(subject, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: published
                      ? good.withValues(alpha: dark ? 0.20 : 0.12)
                      : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      published ? Icons.circle : Icons.edit_outlined,
                      size: published ? 7 : 12,
                      color: published ? good : cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      published ? l.teacherFormsPublished : l.teacherFormsDraft,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Count on the left, button on the right; when the two don't fit
          // on one line (large text) the button drops under the count.
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 52),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_outline_rounded, size: 15, color: cs.onSurfaceVariant),
                    const SizedBox(width: 5),
                    Text(
                      l.teacherFormsResponses(responsesCount),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                FilledButton.tonalIcon(
                  onPressed: onViewResponses,
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: Text(l.teacherFormsViewResponses, style: const TextStyle(fontSize: 12.5)),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(0, 36),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Responses bottom sheet ──────────────────────────────────────────────────

class _ResponsesSheet extends ConsumerStatefulWidget {
  const _ResponsesSheet({required this.formId, required this.title, required this.l});
  final String formId;
  final String title;
  final AppLocalizations l;

  @override
  ConsumerState<_ResponsesSheet> createState() => _ResponsesSheetState();
}

class _ResponsesSheetState extends ConsumerState<_ResponsesSheet> {
  List<Map<String, dynamic>> _responses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    final responses = await ref.read(teacherMobileRepositoryProvider).formResponses(widget.formId);
    if (!mounted) return;
    setState(() {
      _responses = responses;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(widget.l.teacherFormsViewResponses, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: CmLoading())
          else if (_responses.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(widget.l.teacherFormsNoResponses, style: TextStyle(color: cs.onSurfaceVariant)),
              ),
            )
          else
            ...(_responses.take(20).map((r) {
              final name = r['studentName'] as String? ?? widget.l.teacherFormResponsesScreenStudentFallback;
              final sub = r['submittedAt'] as String? ?? '';
              final dateStr = sub.isNotEmpty ? sub.split('T').first : '';
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: cs.primaryContainer,
                  child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'S',
                    style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.w700)),
                ),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(dateStr),
                contentPadding: EdgeInsets.zero,
              );
            })),
        ],
      ),
    );
  }
}

