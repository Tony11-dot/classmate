// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/http/cm_api.dart';
import '../../../core/auth/auth_controller.dart';
import '../data/admin_repository.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final _schoolProvider2 = FutureProvider.autoDispose<AdminSchool?>((ref) {
  return ref.watch(adminRepositoryProvider).getMySchool();
});

// ── Screen ────────────────────────────────────────────────────────────────────

class AdminSchoolSettingsScreen extends ConsumerStatefulWidget {
  const AdminSchoolSettingsScreen({super.key});

  @override
  ConsumerState<AdminSchoolSettingsScreen> createState() =>
      _AdminSchoolSettingsScreenState();
}

class _AdminSchoolSettingsScreenState
    extends ConsumerState<AdminSchoolSettingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          // Tab bar under the shell's top bar — no inner AppBar
          TabBar(
            controller: _tabs,
            tabs: [
              Tab(text: l.navSchool),
              Tab(text: l.adminSubjectsTitle),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: const [
                _SchoolInfoTab(),
                _SubjectsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── School Info Tab ───────────────────────────────────────────────────────────

class _SchoolInfoTab extends ConsumerStatefulWidget {
  const _SchoolInfoTab();

  @override
  ConsumerState<_SchoolInfoTab> createState() => _SchoolInfoTabState();
}

class _SchoolInfoTabState extends ConsumerState<_SchoolInfoTab> {
  final _nameCtrl = TextEditingController();
  final _logoCtrl = TextEditingController();
  bool _initialized = false;
  bool _dirty = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _logoCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    try {
      await ref.read(adminRepositoryProvider).updateMySchool(
        name: name,
        logoUrl: _logoCtrl.text.trim(), // empty string clears logo on server
      );
      ref.invalidate(_schoolProvider2);
      if (!mounted) return;
      setState(() { _dirty = false; _initialized = false; }); // allow reseed with server values
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.adminSchoolSaved)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final schoolAsync = ref.watch(_schoolProvider2);

    return schoolAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (school) {
        // Seed fields exactly once — never overwrite while user is editing
        if (!_initialized && school != null) {
          _initialized = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _nameCtrl.text = school.name;
            _logoCtrl.text = school.logoUrl ?? '';
          });
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
          children: [
            // Logo preview
            if (school?.logoUrl != null && (school!.logoUrl!.isNotEmpty))
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      school.logoUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(Icons.school_rounded,
                          size: 40, color: cs.onPrimaryContainer),
                    ),
                  ),
                ),
              ),
            _FieldCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel(label: l.adminSchoolName),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) => setState(() => _dirty = true),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      hintText: l.adminSchoolName,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel(label: l.adminSchoolLogoUrl),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _logoCtrl,
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    onChanged: (_) => setState(() => _dirty = true),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      hintText: l.adminSchoolLogoHint,
                      prefixIcon: const Icon(Icons.image_rounded),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: (_dirty && !_saving) ? _save : null,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_rounded),
                label: Text(l.adminSave),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Subjects Tab ──────────────────────────────────────────────────────────────

class _SubjectsTab extends ConsumerStatefulWidget {
  const _SubjectsTab();

  @override
  ConsumerState<_SubjectsTab> createState() => _SubjectsTabState();
}

class _SubjectsTabState extends ConsumerState<_SubjectsTab> {
  final Map<int, List<String>> _subjectsByGrade = {};
  final Map<int, TextEditingController> _addCtrls = {};
  bool _loading = true;
  bool _saving = false;

  static const _grades = [5, 6, 7, 8, 9, 10, 11, 12];

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  @override
  void dispose() {
    for (final c in _addCtrls.values) c.dispose();
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    final session = ref.read(authSessionProvider);
    final api = CMApi(token: session.token ?? '');
    try {
      for (final grade in _grades) {
        try {
          final raw = await api.getJson('/admin/subjects/defaults',
              query: {'schoolId': session.schoolId, 'grade': '$grade'});
          final rawDefaults = raw is Map ? raw['defaults'] : null;
          final subjects = rawDefaults is Map ? rawDefaults['subjects'] : null;
          if (subjects is List) {
            _subjectsByGrade[grade] = List<String>.from(subjects.map((s) => s.toString()));
          } else {
            _subjectsByGrade[grade] = [];
          }
        } catch (_) {
          _subjectsByGrade[grade] = [];
        }
      }
    } finally {
      api.dispose();
    }
    for (final g in _grades) {
      _addCtrls[g] = TextEditingController();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveGrade(int grade) async {
    final session = ref.read(authSessionProvider);
    final api = CMApi(token: session.token ?? '');
    setState(() => _saving = true);
    try {
      await api.postJson('/admin/subjects/defaults', body: {
        'schoolId': session.schoolId,
        'grade': grade,
        'subjects': _subjectsByGrade[grade] ?? [],
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.adminSchoolSaved)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      api.dispose();
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addSubject(int grade) {
    final ctrl = _addCtrls[grade];
    if (ctrl == null) return;
    final text = ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _subjectsByGrade[grade] = [...(_subjectsByGrade[grade] ?? []), text];
    });
    ctrl.clear();
  }

  void _removeSubject(int grade, int index) {
    setState(() {
      final list = List<String>.from(_subjectsByGrade[grade] ?? []);
      list.removeAt(index);
      _subjectsByGrade[grade] = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    if (_loading) return const Center(child: CircularProgressIndicator());

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: _grades.length,
      itemBuilder: (ctx, i) {
        final grade = _grades[i];
        final subjects = _subjectsByGrade[grade] ?? [];
        final ctrl = _addCtrls[grade]!;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _FieldCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.adminSubjectsGrade(grade),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.primary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _saving ? null : () => _saveGrade(grade),
                      child: Text(l.adminSave),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (subjects.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(l.adminSubjectsNoSubjects,
                        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  )
                else
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: subjects.asMap().entries.map((e) => Chip(
                      label: Text(e.value, style: const TextStyle(fontSize: 13)),
                      deleteIcon: const Icon(Icons.close_rounded, size: 14),
                      onDeleted: () => _removeSubject(grade, e.key),
                      visualDensity: VisualDensity.compact,
                    )).toList(),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ctrl,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: l.adminSubjectsAddHint,
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                        onSubmitted: (_) => _addSubject(grade),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => _addSubject(grade),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        minimumSize: Size.zero,
                      ),
                      child: Text(l.adminSubjectsAdd),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────────

class _FieldCard extends StatelessWidget {
  const _FieldCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: cs.onSurfaceVariant,
      ),
    );
  }
}
