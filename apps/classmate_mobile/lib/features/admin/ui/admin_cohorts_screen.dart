// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../data/admin_repository.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final _cohortsProvider = FutureProvider.autoDispose<List<AdminCohort>>((ref) {
  return ref.watch(adminRepositoryProvider).listCohorts();
});

final _rosterProvider = FutureProvider.autoDispose.family<List<AdminUser>, String>((ref, cohortId) {
  return ref.watch(adminRepositoryProvider).getCohortRoster(cohortId);
});

// ── Cohorts list screen ────────────────────────────────────────────────────────

class AdminCohortsScreen extends ConsumerWidget {
  const AdminCohortsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final session = ref.watch(authSessionProvider);
    final isAdmin = session.primaryRole == 'ADMIN';
    final cohortsAsync = ref.watch(_cohortsProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              heroTag: 'fab_add_cohort',
              onPressed: () => _showCreateCohortSheet(context, ref),
              icon: const Icon(Icons.add_rounded),
              label: Text(AppLocalizations.of(context)!.adminAddCohort),
            )
          : null,
      body: cohortsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (cohorts) {
          if (cohorts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.groups_outlined, size: 64, color: cs.outlineVariant),
                  const SizedBox(height: 12),
                  Text(AppLocalizations.of(context)!.adminNoCohortsYet, style: theme.textTheme.titleMedium?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  if (isAdmin) Text(AppLocalizations.of(context)!.adminScheduleNoSlotsHint, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            );
          }

          // Group by grade
          final byGrade = <int, List<AdminCohort>>{};
          for (final c in cohorts) {
            byGrade.putIfAbsent(c.grade, () => []).add(c);
          }
          final grades = byGrade.keys.toList()..sort();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              for (final grade in grades) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                  child: Text(
                    'Grade $grade',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                for (final cohort in byGrade[grade]!)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _CohortCard(
                      cohort: cohort,
                      isAdmin: isAdmin,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminCohortDetailScreen(cohort: cohort),
                        ),
                      ).then((_) => ref.invalidate(_cohortsProvider)),
                      onDelete: () => _confirmDelete(context, ref, cohort),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _showCreateCohortSheet(BuildContext context, WidgetRef ref) async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _CreateCohortSheet(repo: ref.read(adminRepositoryProvider)),
    );
    if (created == true) ref.invalidate(_cohortsProvider);
  }

  Future<void> _confirmDelete(BuildContext ctx, WidgetRef ref, AdminCohort cohort) async {
    final confirm = await showDialog<bool>(
      context: ctx,
      builder: (dCtx) {
        final dl = AppLocalizations.of(dCtx)!;
        return AlertDialog(
          title: Text(dl.adminDeleteCohort),
          content: Text(dl.adminDeleteCohortConfirm(cohort.name)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dCtx, false), child: Text(dl.adminDeleteConfirmCancel)),
            FilledButton(
              onPressed: () => Navigator.pop(dCtx, true),
              style: FilledButton.styleFrom(backgroundColor: Theme.of(dCtx).colorScheme.error),
              child: Text(dl.adminDeleteConfirmDelete),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;
    try {
      await ref.read(adminRepositoryProvider).deleteCohort(cohort.id);
      ref.invalidate(_cohortsProvider);
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

// ── Cohort card ────────────────────────────────────────────────────────────────

class _CohortCard extends StatelessWidget {
  const _CohortCard({
    required this.cohort,
    required this.isAdmin,
    required this.onTap,
    required this.onDelete,
  });

  final AdminCohort cohort;
  final bool isAdmin;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'G${cohort.grade}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cohort.name,
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${cohort.studentCount} students',
                    style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
            if (isAdmin)
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: cs.error, size: 20),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Cohort detail screen ───────────────────────────────────────────────────────

class AdminCohortDetailScreen extends ConsumerStatefulWidget {
  const AdminCohortDetailScreen({super.key, required this.cohort});
  final AdminCohort cohort;

  @override
  ConsumerState<AdminCohortDetailScreen> createState() =>
      _AdminCohortDetailScreenState();
}

class _AdminCohortDetailScreenState extends ConsumerState<AdminCohortDetailScreen> {
  late AdminCohort _cohort;

  @override
  void initState() {
    super.initState();
    _cohort = widget.cohort;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final session = ref.watch(authSessionProvider);
    final isAdmin = session.primaryRole == 'ADMIN';
    final rosterAsync = ref.watch(_rosterProvider(_cohort.id));

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(_cohort.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        actions: [
          // Generate join code — students use this to self-enroll
          IconButton(
            icon: const Icon(Icons.qr_code_rounded),
            tooltip: 'Generate join code',
            onPressed: () => _generateJoinCode(context),
          ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => _showRenameSheet(context),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_add_student_cohort',
        onPressed: () => _showAddStudentsSheet(context),
        icon: const Icon(Icons.person_add_rounded),
        label: Text(AppLocalizations.of(context)!.adminAddStudents),
      ),
      body: rosterAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (students) {
          if (students.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_outline_rounded, size: 64, color: cs.outlineVariant),
                  const SizedBox(height: 12),
                  Text(AppLocalizations.of(context)!.adminNoStudentsInCohort, style: theme.textTheme.titleSmall?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  Text(AppLocalizations.of(context)!.adminAddStudents, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.groups_rounded, size: 18, color: cs.primary),
                    const SizedBox(width: 8),
                    Text(
                      '${students.length} student${students.length == 1 ? '' : 's'}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...students.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _RosterTile(
                    user: s,
                    onRemove: () => _removeStudent(context, s),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _removeStudent(BuildContext ctx, AdminUser student) async {
    final confirm = await showDialog<bool>(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        title: Text(AppLocalizations.of(dCtx)!.adminRemoveStudent),
        content: Text(AppLocalizations.of(dCtx)!.adminRemoveStudentConfirm(student.name, _cohort.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dCtx, false), child: Text(AppLocalizations.of(dCtx)!.adminDeleteConfirmCancel)),
          FilledButton(
            onPressed: () => Navigator.pop(dCtx, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(dCtx).colorScheme.error),
            child: Text(AppLocalizations.of(dCtx)!.adminDeleteConfirmDelete),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ref.read(adminRepositoryProvider).removeStudentFromCohort(_cohort.id, student.id);
      ref.invalidate(_rosterProvider(_cohort.id));
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _showRenameSheet(BuildContext ctx) async {
    final nameCtrl = TextEditingController(text: _cohort.name);
    final cs = Theme.of(ctx).colorScheme;
    final updated = await showModalBottomSheet<bool>(
      context: ctx,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: cs.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (bCtx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(bCtx).viewInsets.bottom + 24,
          left: 20, right: 20, top: 0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(bCtx)!.adminRenameCohort, style: Theme.of(bCtx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(bCtx)!.adminCohortName,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  try {
                    await ref.read(adminRepositoryProvider).updateCohort(_cohort.id, name: nameCtrl.text.trim());
                    Navigator.pop(bCtx, true);
                  } catch (e) {
                    ScaffoldMessenger.of(bCtx).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
    // Capture text BEFORE dispose — reading after dispose is undefined behaviour
    final newName = nameCtrl.text.trim();
    nameCtrl.dispose();
    if (updated == true && newName.isNotEmpty) {
      setState(() => _cohort = AdminCohort(
        id: _cohort.id,
        name: newName,
        grade: _cohort.grade,
        studentCount: _cohort.studentCount,
      ));
    }
  }

  Future<void> _generateJoinCode(BuildContext ctx) async {
    try {
      final code = await ref.read(adminRepositoryProvider).generateJoinCode(_cohort.id);
      if (!mounted || code.isEmpty) return;
      showDialog(
        context: ctx,
        builder: (dCtx) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.qr_code_rounded, color: Theme.of(dCtx).colorScheme.primary),
              const SizedBox(width: 10),
              Text('Join Code — ${_cohort.name}'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share this code with students. Valid for 7 days.',
                style: Theme.of(dCtx).textTheme.bodySmall?.copyWith(
                  color: Theme.of(dCtx).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(dCtx).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Theme.of(dCtx).colorScheme.primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  code,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                    letterSpacing: 6,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Students enter this code in their ClassMate app under Cohort → Join.',
                style: Theme.of(dCtx).textTheme.bodySmall?.copyWith(
                  color: Theme.of(dCtx).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Copy'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(dCtx).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(dCtx)!.adminCopied)),
                );
              },
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dCtx),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _showAddStudentsSheet(BuildContext ctx) async {
    final added = await showModalBottomSheet<bool>(
      context: ctx,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(ctx).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (bCtx) => _AddStudentsSheet(
        repo: ref.read(adminRepositoryProvider),
        cohortId: _cohort.id,
        cohortName: _cohort.name,
      ),
    );
    if (added == true) {
      ref.invalidate(_rosterProvider(_cohort.id));
      // Also refresh the cohort list so student count updates on the card
      ref.invalidate(_cohortsProvider);
    }
  }
}

// ── Roster tile ────────────────────────────────────────────────────────────────

class _RosterTile extends StatelessWidget {
  const _RosterTile({required this.user, required this.onRemove});
  final AdminUser user;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final initials = _initials(user.name);

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: cs.onPrimaryContainer),
            ),
          ),
        ),
        title: Text(user.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(user.email, style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
        trailing: IconButton(
          icon: Icon(Icons.remove_circle_outline_rounded, color: cs.error, size: 20),
          onPressed: onRemove,
        ),
      ),
    );
  }
}

// ── Add students sheet ─────────────────────────────────────────────────────────

class _AddStudentsSheet extends StatefulWidget {
  const _AddStudentsSheet({
    required this.repo,
    required this.cohortId,
    required this.cohortName,
  });

  final AdminRepository repo;
  final String cohortId;
  final String cohortName;

  @override
  State<_AddStudentsSheet> createState() => _AddStudentsSheetState();
}

class _AddStudentsSheetState extends State<_AddStudentsSheet> {
  List<Map<String, dynamic>> _allStudents = [];
  final Set<String> _selected = {};
  String _search = '';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final students = await widget.repo.getDdlStudents();
      if (mounted) setState(() { _allStudents = students; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_selected.isEmpty) return;
    setState(() => _saving = true);
    try {
      await widget.repo.addStudentsToCohort(widget.cohortId, _selected.toList());
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = Theme.of(context).colorScheme;
    final q = _search.toLowerCase();
    final filtered = _allStudents.where((s) =>
      q.isEmpty || (s['name']?.toString() ?? '').toLowerCase().contains(q)).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _loading
          ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Add to ${widget.cohortName}',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (_selected.isNotEmpty)
                        FilledButton.icon(
                          onPressed: _saving ? null : _save,
                          icon: _saving
                              ? const SizedBox.square(dimension: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.check_rounded, size: 16),
                          label: Text('Add ${_selected.length}'),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    decoration: InputDecoration(
                      hintText: 'Search students…',
                      prefixIcon: const Icon(Icons.search_rounded, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      isDense: true,
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.45),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final s = filtered[i];
                      final id = s['id']?.toString() ?? '';
                      final name = s['name']?.toString() ?? '';
                      final cohortName = s['cohortName']?.toString() ?? '';
                      final selected = _selected.contains(id);
                      return CheckboxListTile(
                        dense: true,
                        value: selected,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (_) => setState(() =>
                          selected ? _selected.remove(id) : _selected.add(id)),
                        title: Text(name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        subtitle: cohortName.isNotEmpty
                            ? Text(cohortName, style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant))
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Create cohort sheet ────────────────────────────────────────────────────────

class _CreateCohortSheet extends StatefulWidget {
  const _CreateCohortSheet({required this.repo});
  final AdminRepository repo;

  @override
  State<_CreateCohortSheet> createState() => _CreateCohortSheetState();
}

class _CreateCohortSheetState extends State<_CreateCohortSheet> {
  final _nameCtrl = TextEditingController();
  int _grade = 9;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    try {
      await widget.repo.createCohort(name: name, grade: _grade);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 20, right: 20, top: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(AppLocalizations.of(context)!.adminNewCohort, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox.square(dimension: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_rounded, size: 16),
                label: Text(AppLocalizations.of(context)!.adminCreateUser),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            decoration: InputDecoration(
              labelText: '${AppLocalizations.of(context)!.adminCohortName} *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.adminCohortGrade, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(8, (i) => i + 5).map((g) => ChoiceChip(
              label: Text('G$g'),
              selected: _grade == g,
              onSelected: (_) => setState(() => _grade = g),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _initials(String name) {
  if (name.isEmpty) return 'CM';
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  final word = parts[0];
  if (word.length >= 2) return '${word[0]}${word[1]}'.toUpperCase();
  return word[0].toUpperCase();
}
