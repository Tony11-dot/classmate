import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/glass/liquid_glass_card.dart';
import '../teacher_mobile/data/teacher_mobile_repository.dart';

// Public trigger so AppShell can open the create sheet
class _DiplomasTrigger extends Notifier<int> {
  @override
  int build() => 0;
  void increment() => state++;
}

final diplomasCreateTriggerProvider = NotifierProvider<_DiplomasTrigger, int>(_DiplomasTrigger.new);

class DiplomasScreen extends ConsumerStatefulWidget {
  const DiplomasScreen({super.key});

  @override
  ConsumerState<DiplomasScreen> createState() => _DiplomasScreenState();
}

class _DiplomasScreenState extends ConsumerState<DiplomasScreen> {
  List<Map<String, dynamic>> _diplomas = [];
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
      final diplomas = await ref.read(teacherMobileRepositoryProvider).listDiplomas();
      if (!mounted) return;
      setState(() {
        _diplomas = diplomas;
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

  Future<void> _delete(String id, String studentName) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete certificate?'),
        content: Text('Remove certificate for "$studentName"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.classroomsForwardCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.teacherGradesDeleteAction)),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(teacherMobileRepositoryProvider).deleteDiploma(id);
    await _load();
  }

  void _showCreateSheet() {
    final l = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateDiplomaSheet(onCreated: _load, l: l, ref: ref),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final locale = Localizations.localeOf(context).toString();

    // Listen for FAB trigger from AppShell
    ref.listen<int>(diplomasCreateTriggerProvider, (prev, next) {
      if ((next) > (prev ?? 0)) _showCreateSheet();
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
                const Color(0xFFFFF8E1).withValues(alpha: 0.92),
                cs.surfaceContainerHigh.withValues(alpha: 0.82),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.diplomasTitle, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.1)),
                      const SizedBox(height: 4),
                      Text('${_diplomas.length} certificates issued', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.workspace_premium_rounded, size: 26, color: Colors.amber),
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

          if (_loading && _diplomas.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else if (_diplomas.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.workspace_premium_outlined, size: 56, color: Colors.amber.withValues(alpha: 0.4)),
                    const SizedBox(height: 16),
                    Text(l.diplomasEmpty, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            )
          else
            ...(_diplomas.map((d) {
              final id = d['id'] as String? ?? '';
              final studentName = d['studentName'] as String? ?? '';
              final title = d['title'] as String? ?? '';
              final subject = d['subject'] as String? ?? '';
              final grade = d['grade'] as String? ?? '';
              final distinction = d['distinction'] as String? ?? '';
              final issuedAt = d['issuedAt'] as String? ?? '';
              final dateStr = () {
                final dt = DateTime.tryParse(issuedAt);
                if (dt == null) return issuedAt.split('T').first;
                return DateFormat.yMMMd(locale).format(dt);
              }();

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Dismissible(
                  key: Key('diploma_$id'),
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
                    await _delete(id, studentName);
                    return false;
                  },
                  child: LiquidGlassCard(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFFF8E1).withValues(alpha: 0.72),
                        cs.surfaceContainerHigh.withValues(alpha: 0.66),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.22)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.workspace_premium_rounded, size: 26, color: Colors.amber),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(studentName, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                              const SizedBox(height: 2),
                              Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  if (subject.isNotEmpty)
                                    _DiplomaChip(label: subject, color: cs.primary),
                                  if (grade.isNotEmpty)
                                    _DiplomaChip(label: grade, color: cs.tertiary),
                                  if (distinction.isNotEmpty)
                                    _DiplomaChip(label: distinction, color: Colors.amber),
                                  _DiplomaChip(
                                    label: l.diplomasIssuedOn(dateStr),
                                    color: cs.secondary,
                                  ),
                                ],
                              ),
                            ],
                          ),
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

class _DiplomaChip extends StatelessWidget {
  const _DiplomaChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

// ── Create Diploma bottom sheet ─────────────────────────────────────────────

class _CreateDiplomaSheet extends ConsumerStatefulWidget {
  const _CreateDiplomaSheet({required this.onCreated, required this.l, required this.ref});
  final VoidCallback onCreated;
  final AppLocalizations l;
  final WidgetRef ref;

  @override
  ConsumerState<_CreateDiplomaSheet> createState() => _CreateDiplomaSheetState();
}

class _CreateDiplomaSheetState extends ConsumerState<_CreateDiplomaSheet> {
  final _nameCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _gradeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _titleType = 'Certificate of Achievement';
  bool _saving = false;

  static const _titleOptions = [
    'Certificate of Achievement',
    'Certificate of Excellence',
    'Diploma',
    'Merit Award',
    'Honor Roll',
    'Special Recognition',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _subjectCtrl.dispose();
    _gradeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    try {
      await widget.ref.read(teacherMobileRepositoryProvider).createDiploma({
        'studentName': name,
        'title': _titleType,
        'subject': _subjectCtrl.text.trim().isEmpty ? null : _subjectCtrl.text.trim(),
        'grade': _gradeCtrl.text.trim().isEmpty ? null : _gradeCtrl.text.trim(),
        'notes': _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
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
            Text(l.diplomasIssueDiploma, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: '${l.diplomasStudentName} *', border: const OutlineInputBorder()),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _titleType,
              decoration: InputDecoration(labelText: l.diplomasCertificateType, border: const OutlineInputBorder()),
              items: _titleOptions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _titleType = v ?? _titleType),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subjectCtrl,
              decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _gradeCtrl,
              decoration: const InputDecoration(labelText: 'Grade / Score', hintText: 'e.g. 95/100, Distinction', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.workspace_premium_rounded),
                label: Text(l.diplomasIssueDiploma),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
