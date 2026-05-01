import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../data/teacher_mobile_repository.dart';

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
        content: Text('Delete "$title"?'),
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
    final l = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ResponsesSheet(formId: formId, title: title, l: l),
    );
  }

  void showCreateSheet() {
    final l = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateFormSheet(
        onCreated: _load,
        l: l,
        ref: ref,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Listen for FAB trigger
    ref.listen<int>(teacherFormsCreateTriggerProvider, (prev, next) {
      if ((next) > (prev ?? 0)) showCreateSheet();
    });

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          // Hero banner
          LiquidGlassCard(
            borderRadius: BorderRadius.circular(28),
            blurSigma: 20,
            gradient: LinearGradient(
              colors: [
                cs.secondaryContainer.withValues(alpha: 0.92),
                cs.surfaceContainerHigh.withValues(alpha: 0.82),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: cs.secondary.withValues(alpha: 0.2)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.teacherFormsTitle, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.1)),
                      const SizedBox(height: 4),
                      Text('${_forms.length} forms', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(color: cs.secondary.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
                  child: Icon(Icons.assignment_turned_in_rounded, size: 24, color: cs.secondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LiquidGlassCard(
                color: cs.errorContainer.withValues(alpha: 0.72),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: cs.error),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_error!, style: TextStyle(color: cs.onErrorContainer))),
                    TextButton(onPressed: _load, child: const Text('Retry')),
                  ],
                ),
              ),
            ),

          if (_loading && _forms.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else if (_forms.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.assignment_turned_in_outlined, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                    const SizedBox(height: 16),
                    Text(l.teacherFormsEmpty, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            )
          else
            ...(_forms.map((form) {
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
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: cs.errorContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(Icons.delete_rounded, color: cs.onErrorContainer),
                  ),
                  confirmDismiss: (_) async {
                    await _delete(id, title);
                    return false; // We refresh manually
                  },
                  child: LiquidGlassCard(
                    gradient: LinearGradient(
                      colors: [cs.surface.withValues(alpha: 0.88), cs.surfaceContainerHigh.withValues(alpha: 0.66)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.18)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (published ? cs.primary : cs.outline).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                published ? l.teacherFormsPublished : l.teacherFormsDraft,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: published ? cs.primary : cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (subject.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(subject, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.people_outline_rounded, size: 14, color: cs.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              l.teacherFormsResponses(responsesCount),
                              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () => _viewResponses(id, title),
                              icon: const Icon(Icons.visibility_outlined, size: 16),
                              label: Text(l.teacherFormsViewResponses, style: const TextStyle(fontSize: 12)),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            })),
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
        color: cs.surface,
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
            const Center(child: CircularProgressIndicator())
          else if (_responses.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(widget.l.teacherFormsNoResponses, style: TextStyle(color: cs.onSurfaceVariant)),
              ),
            )
          else
            ...(_responses.take(20).map((r) {
              final name = r['studentName'] as String? ?? 'Student';
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

// ── Create Form bottom sheet ────────────────────────────────────────────────

class _CreateFormSheet extends ConsumerStatefulWidget {
  const _CreateFormSheet({required this.onCreated, required this.l, required this.ref});
  final VoidCallback onCreated;
  final AppLocalizations l;
  final WidgetRef ref;

  @override
  ConsumerState<_CreateFormSheet> createState() => _CreateFormSheetState();
}

class _CreateFormSheetState extends ConsumerState<_CreateFormSheet> {
  final _titleCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final List<Map<String, dynamic>> _questions = [];
  bool _acceptingResponses = true;
  bool _published = false;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _addQuestion() {
    if (_questions.length >= 10) return;
    setState(() {
      _questions.add({'text': '', 'type': 'short'});
    });
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    setState(() => _saving = true);
    try {
      await widget.ref.read(teacherMobileRepositoryProvider).createForm({
        'title': title,
        'subject': _subjectCtrl.text.trim().isEmpty ? null : _subjectCtrl.text.trim(),
        'description': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        'acceptingResponses': _acceptingResponses,
        'published': _published,
        'questions': _questions.where((q) => (q['text'] as String).isNotEmpty).toList(),
      });
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onCreated();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.teacherFormsCreateTitle, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(labelText: 'Title *', border: const OutlineInputBorder()),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subjectCtrl,
              decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Accepting responses'),
              value: _acceptingResponses,
              onChanged: (v) => setState(() => _acceptingResponses = v),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: Text(l.teacherFormsPublished),
              value: _published,
              onChanged: (v) => setState(() => _published = v),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(height: 24),
            Text('Questions', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...(_questions.asMap().entries.map((entry) {
              final i = entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: '${l.teacherFormsQuestionHint} ${i + 1}',
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (v) => _questions[i]['text'] = v,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => setState(() => _questions.removeAt(i)),
                      icon: Icon(Icons.remove_circle_outline_rounded, color: cs.error),
                    ),
                  ],
                ),
              );
            })),
            if (_questions.length < 10)
              TextButton.icon(
                onPressed: _addQuestion,
                icon: const Icon(Icons.add_rounded),
                label: Text(l.teacherFormsAddQuestion),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(l.teacherFormsCreateTitle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
