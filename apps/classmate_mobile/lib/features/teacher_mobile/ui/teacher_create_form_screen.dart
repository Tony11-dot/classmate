// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  String _targetType = 'EVERYONE';
  final Set<String> _selectedCohortIds = {};
  final Set<String> _selectedStudentIds = {};

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

  String _targetSummary() {
    if (_targetType == 'EVERYONE') return 'Everyone';
    if (_targetType == 'COHORT') {
      if (_selectedCohortIds.isEmpty) return 'No cohorts selected';
      return _cohorts.where((c) => _selectedCohortIds.contains(c.id)).map((c) => c.name).join(', ');
    }
    if (_selectedStudentIds.isEmpty) return 'No students selected';
    return '${_selectedStudentIds.length} student${_selectedStudentIds.length == 1 ? '' : 's'}';
  }

  void _addQuestion() {
    setState(() => _questions.add(_FormQuestion()));
  }

  Future<void> _save({required bool published}) async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a form title.')));
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

  Future<void> _openStudentPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PersonPickerSheet(
        items: _allStudents.map((s) => _PickerItem(
          id: s.studentId, label: s.name,
          subtitle: s.gradeLevel != null ? 'Grade ${s.gradeLevel}' : s.cohortName)).toList(),
        selected: Set.from(_selectedStudentIds),
        onToggle: (id) => setState(() {
          if (_selectedStudentIds.contains(id)) { _selectedStudentIds.remove(id); }
          else { _selectedStudentIds.add(id); }
        }),
      ),
    );
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
        title: Text('Create Form', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        actions: [
          TextButton(onPressed: _saving ? null : () => _save(published: false), child: const Text('Save Draft')),
          const SizedBox(width: 6),
          Padding(padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: _saving ? null : () => _save(published: true),
              child: _saving ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Publish'))),
        ],
      ),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          // ── 1. Audience ─────────────────────────────────────────────────────
          _GlassCard(
            title: 'Audience',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (_subjects.isNotEmpty) ...[
                LiquidGlassDropdown<String?>(
                  label: 'Subject (optional)',
                  value: _selectedSubject,
                  items: [
                    const LiquidGlassDropdownItem(value: null, label: 'No subject', icon: Icons.subject_rounded),
                    ..._subjects.map((s) => LiquidGlassDropdownItem(value: s, label: s, icon: Icons.menu_book_rounded)),
                    const LiquidGlassDropdownItem(value: 'Other', label: 'Other', icon: Icons.category_rounded),
                  ],
                  onChanged: (v) => setState(() => _selectedSubject = v),
                  searchHint: 'Search subjects...'),
                const SizedBox(height: 12),
              ],
              AudienceSection(
                cohorts: _cohorts,
                allStudents: _allStudents,
                selectedCohortIds: _selectedCohortIds,
                selectedStudentIds: _selectedStudentIds,
                repo: ref.read(teacherMobileRepositoryProvider),
                onChanged: () => setState(() {}),
              ),
            ])),
          const SizedBox(height: 12),

          // ── 2. Form title + description ─────────────────────────────────────
          _GlassCard(
            title: 'Form',
            child: Column(children: [
              TextField(
                controller: _titleCtrl,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Form title *')),
              const Divider(height: 1),
              const SizedBox(height: 8),
              TextField(
                controller: _descCtrl, maxLines: 3, minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Description (optional)')),
            ])),
          const SizedBox(height: 12),

          // ── 3. Settings ──────────────────────────────────────────────────────
          _GlassCard(
            title: 'Settings',
            child: Column(
              children: [
                SwitchListTile(
                  value: _acceptingResponses,
                  onChanged: (v) => setState(() => _acceptingResponses = v),
                  title: const Text('Accepting responses'),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  value: _allowMultipleResponses,
                  onChanged: (v) =>
                      setState(() => _allowMultipleResponses = v),
                  title: const Text('Allow multiple responses'),
                  subtitle: const Text('Off = once per student (default)'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── 4. Questions ─────────────────────────────────────────────────────
          Row(children: [
            Text('Questions', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
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
            label: const Text('Add question'),
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
              searchHint: 'Search question types...',
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
          decoration: InputDecoration(border: InputBorder.none, hintText: 'Question ${widget.index + 1}', isDense: true, contentPadding: EdgeInsets.zero),
          onChanged: (v) { q.text = v; widget.onChanged(); }),
        const SizedBox(height: 8),
        _buildTypeUI(context, cs, theme, q),
        const Divider(height: 20),
        Row(children: [
          Text('Required', style: theme.textTheme.bodySmall),
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
            icon: const Icon(Icons.add, size: 16), label: const Text('Add option'),
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4), visualDensity: VisualDensity.compact)),
        ]);
      case 'linearScale':
        final minCtrl = TextEditingController(text: '${q.scaleMin}')
          ..selection = TextSelection.collapsed(offset: '${q.scaleMin}'.length);
        final maxCtrl = TextEditingController(text: '${q.scaleMax}')
          ..selection = TextSelection.collapsed(offset: '${q.scaleMax}'.length);
        return Row(children: [
          SizedBox(width: 56, child: TextField(controller: minCtrl,
            decoration: const InputDecoration(labelText: 'Min', isDense: true, border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            onChanged: (v) => q.scaleMin = int.tryParse(v) ?? q.scaleMin)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('to')),
          SizedBox(width: 56, child: TextField(controller: maxCtrl,
            decoration: const InputDecoration(labelText: 'Max', isDense: true, border: OutlineInputBorder()),
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

class _PickerItem {
  const _PickerItem({required this.id, required this.label, this.subtitle = ''});
  final String id;
  final String label;
  final String subtitle;
}

class _PersonPickerSheet extends StatefulWidget {
  const _PersonPickerSheet({required this.items, required this.selected, required this.onToggle});
  final List<_PickerItem> items;
  final Set<String> selected;
  final void Function(String) onToggle;

  @override
  State<_PersonPickerSheet> createState() => _PersonPickerSheetState();
}

class _PersonPickerSheetState extends State<_PersonPickerSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  List<_PickerItem> get _filtered {
    if (_query.trim().isEmpty) return widget.items;
    final q = _query.toLowerCase();
    return widget.items.where((i) => i.label.toLowerCase().contains(q) || i.subtitle.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.7, minChildSize: 0.4, maxChildSize: 0.95, expand: false,
      builder: (ctx, scroll) => Container(
        decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(children: [
          Container(margin: const EdgeInsets.symmetric(vertical: 10), width: 36, height: 4,
            decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2))),
          Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text('Select students', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
          Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(controller: _searchCtrl, onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(hintText: 'Search students or grade...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), isDense: true))),
          Expanded(child: ListView.builder(controller: scroll, itemCount: _filtered.length,
            itemBuilder: (ctx, i) {
              final item = _filtered[i]; final sel = widget.selected.contains(item.id);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: sel ? cs.primaryContainer : cs.surfaceContainerHigh,
                  child: Text(item.label.isNotEmpty ? item.label[0].toUpperCase() : '?',
                    style: TextStyle(fontWeight: FontWeight.w700, color: sel ? cs.onPrimaryContainer : cs.onSurface))),
                title: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: item.subtitle.isNotEmpty ? Text(item.subtitle) : null,
                trailing: sel ? Icon(Icons.check_circle_rounded, color: cs.primary) : Icon(Icons.radio_button_unchecked, color: cs.outlineVariant),
                onTap: () => widget.onToggle(item.id));
            })),
          Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(width: double.infinity,
              child: FilledButton(onPressed: () => Navigator.of(context).pop(),
                child: Text('Done (${widget.selected.length} selected)')))),
        ]),
      ),
    );
  }
}
