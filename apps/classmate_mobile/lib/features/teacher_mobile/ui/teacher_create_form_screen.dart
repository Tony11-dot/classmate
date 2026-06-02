// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../../../ui/widgets/liquid_glass_dropdown.dart';
import '../data/teacher_mobile_repository.dart';
import 'widgets/audience_section.dart';

class _FormQuestion {
  String text = '';
  String type = 'short';
  bool required = false;
  List<String> options = ['Option 1', 'Option 2'];
  int scaleMin = 1;
  int scaleMax = 5;
  String scaleMinLabel = '';
  String scaleMaxLabel = '';
}

class TeacherCreateFormScreen extends ConsumerStatefulWidget {
  const TeacherCreateFormScreen({super.key});

  @override
  ConsumerState<TeacherCreateFormScreen> createState() => _TeacherCreateFormScreenState();
}

class _TeacherCreateFormScreenState extends ConsumerState<TeacherCreateFormScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _acceptingResponses = true;
  bool _allowMultipleResponses = false;
  String? _selectedSubject;
  final List<_FormQuestion> _questions = [];
  List<TeacherCourse> _courses = [];
  List<({String id, String name, int grade})> _cohorts = [];
  List<TeacherStudentWithLevel> _allStudents = [];
  bool _saving = false;

  // Audience targeting
  final Set<String> _selectedCohortIds = {};
  final Set<String> _selectedStudentIds = {};
  final Set<int> _selectedGrades = {};

  /// Distinct grade values across the teacher's cohorts. Used as the
  /// option list for the Grades audience picker.
  List<int> get _availableGrades {
    final s = <int>{};
    for (final c in _cohorts) {
      if (c.grade > 0) s.add(c.grade);
    }
    final list = s.toList()..sort();
    return list;
  }

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      final results = await Future.wait([
        repo.fetchAssessments(),
        repo.fetchAllStudents(),
        repo.fetchCohortsForPicker(),
      ]);
      if (!mounted) return;
      final cohortMaps = results[2] as List<Map<String, dynamic>>;
      setState(() {
        _courses = (results[0] as TeacherAssessmentBundle).courses;
        _allStudents = results[1] as List<TeacherStudentWithLevel>;
        _cohorts = cohortMaps.map((c) => (id: (c['id'] ?? '').toString(), name: (c['name'] ?? '').toString().replaceFirst(RegExp(r'^\d+\s*-\s*'), ''), grade: c['grade'] is int ? c['grade'] as int : int.tryParse('${c['grade'] ?? ''}') ?? 0)).where((c) => c.id.isNotEmpty).toList()..sort((a, b) => a.grade.compareTo(b.grade));
      });
    } catch (_) {}
  }

  List<String> get _subjects =>
      _courses.map((c) => c.subject).where((s) => s.isNotEmpty).toSet().toList()..sort();

  void _addQuestion() {
    setState(() => _questions.add(_FormQuestion()));
  }

  Future<void> _save({required bool published}) async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.teacherFormEnterTitle)));
      return;
    }
    setState(() => _saving = true);
    try {
      final questions = _questions
          .where((q) => q.text.isNotEmpty)
          .map((q) => <String, dynamic>{
                'text': q.text,
                'type': q.type,
                'required': q.required,
                'options': q.options.where((o) => o.isNotEmpty).toList(),
                'scaleMin': q.scaleMin,
                'scaleMax': q.scaleMax,
                'scaleMinLabel': q.scaleMinLabel,
                'scaleMaxLabel': q.scaleMaxLabel,
              })
          .toList();

      await ref.read(teacherMobileRepositoryProvider).createForm(<String, dynamic>{
        'title': title,
        'description': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        'subject': _selectedSubject,
        'acceptingResponses': _acceptingResponses,
        'allowMultipleResponses': _allowMultipleResponses,
        'published': published,
        'targetType': _selectedCohortIds.isNotEmpty ? 'COHORT' : _selectedStudentIds.isNotEmpty ? 'STUDENTS' : 'EVERYONE',
        'targetCohortIds': _selectedCohortIds.toList(),
        'targetStudentIds': _selectedStudentIds.toList(),
        'targetGrades': _selectedGrades.toList(),
        'questions': questions,
      });

      if (!mounted) return;
      if (context.canPop()) context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _typeLabel(String t) {
    switch (t) {
      case 'short': return 'Short answer';
      case 'paragraph': return 'Paragraph';
      case 'multipleChoice': return 'Multiple choice';
      case 'checkboxes': return 'Checkboxes';
      case 'rating': return 'Rating (1–5)';
      case 'linearScale': return 'Linear scale';
      case 'dropdown': return 'Dropdown';
      case 'date': return 'Date';
      default: return t;
    }
  }

  IconData _typeIcon(String t) {
    switch (t) {
      case 'short': return Icons.short_text_rounded;
      case 'paragraph': return Icons.notes_rounded;
      case 'multipleChoice': return Icons.radio_button_checked_rounded;
      case 'checkboxes': return Icons.check_box_rounded;
      case 'rating': return Icons.star_rounded;
      case 'linearScale': return Icons.linear_scale_rounded;
      case 'dropdown': return Icons.arrow_drop_down_circle_rounded;
      case 'date': return Icons.calendar_today_rounded;
      default: return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0, scrolledUnderElevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () { if (context.canPop()) context.pop(); }),
        title: Text(AppLocalizations.of(context)!.teacherCreateFormTitle, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        actions: [
          TextButton(onPressed: _saving ? null : () => _save(published: false), child: Text(AppLocalizations.of(context)!.teacherFormSaveDraft)),
          const SizedBox(width: 6),
          Padding(padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: _saving ? null : () => _save(published: true),
              child: _saving ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(AppLocalizations.of(context)!.commonPublish))),
        ],
      ),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          // ── 1. Audience ─────────────────────────────────────────────────────
          _GlassCard(
            title: AppLocalizations.of(context)!.teacherAudienceSectionTitle,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (_subjects.isNotEmpty) ...[
                LiquidGlassDropdown<String?>(
                  label: AppLocalizations.of(context)!.commonSubjectOptional,
                  value: _selectedSubject,
                  items: [
                    LiquidGlassDropdownItem(value: null, label: AppLocalizations.of(context)!.teacherNoSubjectOption, icon: Icons.subject_rounded),
                    ..._subjects.map((s) => LiquidGlassDropdownItem(value: s, label: s, icon: Icons.menu_book_rounded)),
                    LiquidGlassDropdownItem(value: 'Other', label: AppLocalizations.of(context)!.teacherOtherSubjectOption, icon: Icons.category_rounded),
                  ],
                  onChanged: (v) => setState(() => _selectedSubject = v),
                  searchHint: AppLocalizations.of(context)!.teacherMaterialSubjectSearch),
                const SizedBox(height: 12),
              ],
              AudienceSection(
                cohorts: _cohorts,
                allStudents: _allStudents,
                selectedCohortIds: _selectedCohortIds,
                selectedStudentIds: _selectedStudentIds,
                selectedGrades: _selectedGrades,
                availableGrades: _availableGrades,
                repo: ref.read(teacherMobileRepositoryProvider),
                onChanged: () => setState(() {}),
              ),
            ])),
          const SizedBox(height: 12),

          // ── 2. Form title + description ─────────────────────────────────────
          _GlassCard(
            title: AppLocalizations.of(context)!.formTitle,
            child: Column(children: [
              TextField(
                controller: _titleCtrl,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(border: InputBorder.none, hintText: AppLocalizations.of(context)!.teacherFormTitleHint)),
              const Divider(height: 1),
              const SizedBox(height: 8),
              TextField(
                controller: _descCtrl, maxLines: 3, minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(border: InputBorder.none, hintText: AppLocalizations.of(context)!.teacherFormDescriptionHint)),
            ])),
          const SizedBox(height: 12),

          // ── 3. Settings ──────────────────────────────────────────────────────
          _GlassCard(
            title: AppLocalizations.of(context)!.settingsTitle,
            child: Column(
              children: [
                SwitchListTile(
                  value: _acceptingResponses,
                  onChanged: (v) => setState(() => _acceptingResponses = v),
                  title: Text(AppLocalizations.of(context)!.teacherFormAcceptingResponses),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  value: _allowMultipleResponses,
                  onChanged: (v) =>
                      setState(() => _allowMultipleResponses = v),
                  title: Text(AppLocalizations.of(context)!.teacherFormAllowMultiple),
                  subtitle: Text(AppLocalizations.of(context)!.teacherFormAllowMultipleSubtitle),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── 4. Questions ─────────────────────────────────────────────────────
          Row(children: [
            Text(AppLocalizations.of(context)!.teacherFormQuestionsSection, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            const Spacer(),
            Text('${_questions.length}', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          ]),
          const SizedBox(height: 8),

          if (_questions.isNotEmpty)
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _questions.removeAt(oldIndex);
                  _questions.insert(newIndex, item);
                });
              },
              children: [
                for (int i = 0; i < _questions.length; i++)
                  _QuestionCard(
                    key: ValueKey('q_$i'),
                    index: i,
                    question: _questions[i],
                    onDelete: () => setState(() => _questions.removeAt(i)),
                    onChanged: () => setState(() {}),
                    typeLabel: _typeLabel,
                    typeIcon: _typeIcon,
                  ),
              ],
            ),

          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addQuestion,
            icon: const Icon(Icons.add_rounded),
            label: Text(AppLocalizations.of(context)!.teacherFormAddQuestionButton),
            style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 44))),
        ],
      ),
    );
  }
}

// ── Glass card wrapper ─────────────────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(16), borderRadius: BorderRadius.circular(20),
      color: cs.surfaceContainerLow,
      border: Border.all(color: cs.outlineVariant),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        child,
      ]));
  }
}

// ── Question card (stateful for controllers) ────────────────────────────────────

class _QuestionCard extends StatefulWidget {
  const _QuestionCard({
    super.key,
    required this.index,
    required this.question,
    required this.onDelete,
    required this.onChanged,
    required this.typeLabel,
    required this.typeIcon,
  });

  final int index;
  final _FormQuestion question;
  final VoidCallback onDelete;
  final VoidCallback onChanged;
  final String Function(String) typeLabel;
  final IconData Function(String) typeIcon;

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  late TextEditingController _textCtrl;

  static const _types = ['short', 'paragraph', 'multipleChoice', 'checkboxes', 'rating', 'linearScale', 'dropdown', 'date'];

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(text: widget.question.text);
  }

  @override
  void dispose() { _textCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final q = widget.question;

    return LiquidGlassCard(
      padding: const EdgeInsets.all(14), borderRadius: BorderRadius.circular(18),
      color: cs.surfaceContainerLow,
      border: Border.all(color: cs.outlineVariant),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Q${widget.index + 1}',
            style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
          const SizedBox(width: 8),
          // Liquid searchable type DDL
          Expanded(
            child: LiquidGlassDropdown<String>(
              label: widget.typeLabel(q.type),
              value: q.type,
              items: _types.map((t) => LiquidGlassDropdownItem(
                value: t,
                label: widget.typeLabel(t),
                icon: widget.typeIcon(t),
              )).toList(),
              onChanged: (val) {
                setState(() {
                  q.type = val;
                  if (['multipleChoice', 'checkboxes', 'dropdown'].contains(val) && q.options.isEmpty) {
                    q.options = ['Option 1', 'Option 2'];
                  }
                });
                widget.onChanged();
              },
              searchHint: AppLocalizations.of(context)!.teacherSearchQuestionTypes,
            ),
          ),
          const Icon(Icons.drag_handle_rounded, size: 20),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: cs.error, size: 18),
            visualDensity: VisualDensity.compact,
            onPressed: widget.onDelete,
            padding: const EdgeInsets.all(4)),
        ]),
        const SizedBox(height: 8),
        TextField(
          controller: _textCtrl,
          decoration: InputDecoration(border: InputBorder.none, hintText: AppLocalizations.of(context)!.teacherFormQuestionPlaceholder((widget.index + 1).toString()), isDense: true, contentPadding: EdgeInsets.zero),
          onChanged: (v) { q.text = v; widget.onChanged(); }),
        const SizedBox(height: 8),
        _buildTypeUI(context, cs, theme, q),
        const Divider(height: 20),
        Row(children: [
          Text(AppLocalizations.of(context)!.teacherFormRequiredToggle, style: theme.textTheme.bodySmall),
          const Spacer(),
          Switch(value: q.required, onChanged: (v) => setState(() => q.required = v), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
        ]),
      ]),
    );
  }

  Widget _buildTypeUI(BuildContext context, ColorScheme cs, ThemeData theme, _FormQuestion q) {
    switch (q.type) {
      case 'short':
        return _PreviewLabel(icon: Icons.short_text_rounded, label: 'Short answer', cs: cs, theme: theme);
      case 'paragraph':
        return _PreviewLabel(icon: Icons.notes_rounded, label: 'Long answer', cs: cs, theme: theme);
      case 'date':
        return _PreviewLabel(icon: Icons.calendar_today_rounded, label: 'Date picker', cs: cs, theme: theme);
      case 'rating':
        return Row(children: List.generate(5, (i) => Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Icon(Icons.star_rounded, size: 28, color: i < 3 ? cs.primary : cs.outlineVariant))));
      case 'multipleChoice':
      case 'checkboxes':
      case 'dropdown':
        final isMC = q.type == 'multipleChoice';
        final isCB = q.type == 'checkboxes';
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ...q.options.asMap().entries.map((entry) {
            final oi = entry.key;
            final optCtrl = TextEditingController(text: entry.value)
              ..selection = TextSelection.collapsed(offset: entry.value.length);
            return Row(children: [
              if (isMC) Icon(Icons.radio_button_unchecked, size: 16, color: cs.onSurfaceVariant)
              else if (isCB) Icon(Icons.check_box_outline_blank, size: 16, color: cs.onSurfaceVariant)
              else Text('${oi + 1}.', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(width: 6),
              Expanded(child: TextField(
                controller: optCtrl,
                decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                onChanged: (v) => setState(() => q.options[oi] = v))),
              if (q.options.length > 1)
                IconButton(icon: const Icon(Icons.close, size: 14), visualDensity: VisualDensity.compact,
                  onPressed: () => setState(() => q.options.removeAt(oi)), padding: EdgeInsets.zero),
            ]);
          }),
          TextButton.icon(
            onPressed: () => setState(() => q.options.add('')),
            icon: const Icon(Icons.add, size: 16), label: Text(AppLocalizations.of(context)!.teacherFormAddOptionButton),
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4), visualDensity: VisualDensity.compact)),
        ]);
      case 'linearScale':
        final minCtrl = TextEditingController(text: '${q.scaleMin}')
          ..selection = TextSelection.collapsed(offset: '${q.scaleMin}'.length);
        final maxCtrl = TextEditingController(text: '${q.scaleMax}')
          ..selection = TextSelection.collapsed(offset: '${q.scaleMax}'.length);
        return Row(children: [
          SizedBox(width: 56, child: TextField(controller: minCtrl,
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.teacherFormMinLabel, isDense: true, border: const OutlineInputBorder()),
            keyboardType: TextInputType.number,
            onChanged: (v) => q.scaleMin = int.tryParse(v) ?? q.scaleMin)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('to')),
          SizedBox(width: 56, child: TextField(controller: maxCtrl,
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.teacherFormMaxLabel, isDense: true, border: const OutlineInputBorder()),
            keyboardType: TextInputType.number,
            onChanged: (v) => q.scaleMax = int.tryParse(v) ?? q.scaleMax)),
        ]);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _PreviewLabel extends StatelessWidget {
  const _PreviewLabel({required this.icon, required this.label, required this.cs, required this.theme});
  final IconData icon;
  final String label;
  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 16, color: cs.onSurfaceVariant), const SizedBox(width: 6),
    Text(label, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant, fontStyle: FontStyle.italic)),
  ]);
}

