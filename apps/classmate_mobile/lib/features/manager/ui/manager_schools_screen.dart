import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/widgets/cm_loading.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/cm_error_state.dart';
import '../../../ui/widgets/cm_surfaces.dart';
import '../data/manager_api.dart';
import 'manager_shell.dart';
import 'manager_school_form_screen.dart';
import '../../../ui/widgets/cm_refresh_indicator.dart';

class ManagerSchoolsScreen extends ConsumerStatefulWidget {
  const ManagerSchoolsScreen({super.key});

  @override
  ConsumerState<ManagerSchoolsScreen> createState() => _ManagerSchoolsScreenState();
}

class _ManagerSchoolsScreenState extends ConsumerState<ManagerSchoolsScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    if (!mounted) return;
    setState(() { _future = ref.read(managerApiProvider).listSchools(); });
  }

  ManagerApi get _api => ref.read(managerApiProvider);

  Future<void> _openCreate() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const ManagerSchoolFormScreen()),
    );
    if (created == true) _reload();
  }

  Future<void> _view(String id) async {
    final l = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (ctx) => FutureBuilder<Map<String, dynamic>>(
        future: _api.getSchool(id),
        builder: (context, snap) {
          final s = snap.data;
          return AlertDialog(
            title: Text(s?['name']?.toString() ?? l.navSchool),
            content: snap.connectionState != ConnectionState.done
                ? const SizedBox(height: 80, child: Center(child: CmLoading()))
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _kv(l.managerGradesLabel, '${s?['minGrade'] ?? '?'}–${s?['maxGrade'] ?? '?'}'),
                        _kv(l.navCohorts, '${s?['cohortCount'] ?? 0}'),
                        _kv(l.navClassrooms, '${s?['classroomCount'] ?? 0}'),
                        const SizedBox(height: 8),
                        Text(l.navPeople, style: const TextStyle(fontWeight: FontWeight.w700)),
                        ..._userCounts(l, s?['userCounts']),
                      ],
                    ),
                  ),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.commonClose))],
          );
        },
      ),
    );
  }

  List<Widget> _userCounts(AppLocalizations l, dynamic counts) {
    if (counts is! Map) return const [Text('—')];
    final entries = counts.entries.toList();
    if (entries.isEmpty) return const [Text('—')];
    return entries.map((e) => _kv(_roleLabel(l, e.key.toString()), '${e.value}')).toList();
  }

  /// The API keys user counts by role code; show the role in the app's language.
  String _roleLabel(AppLocalizations l, String role) {
    switch (role.toUpperCase()) {
      case 'STUDENT':
        return l.roleStudent;
      case 'TEACHER':
        return l.roleTeacher;
      case 'ADMIN':
        return l.roleAdmin;
      case 'SECRETARY':
        return l.roleSecretary;
      case 'PARENT':
        return l.roleParent;
      case 'MANAGER':
        return l.navManagers;
      default:
        return role;
    }
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(k), Text(v, style: const TextStyle(fontWeight: FontWeight.w600))],
        ),
      );

  Future<void> _edit(Map<String, dynamic> school) async {
    final nameCtl = TextEditingController(text: school['name']?.toString() ?? '');
    final minCtl = TextEditingController(text: '${school['minGrade'] ?? ''}');
    final maxCtl = TextEditingController(text: '${school['maxGrade'] ?? ''}');
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.managerEditSchool),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtl, decoration: InputDecoration(labelText: l.managerSchoolName)),
            Row(children: [
              Expanded(child: TextField(controller: minCtl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l.managerMinGrade))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: maxCtl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l.managerMaxGrade))),
            ]),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.commonSave)),
        ],
      ),
    );
    try {
      if (ok != true) return;
      await _api.updateSchool(school['id'].toString(), {
        'name': nameCtl.text.trim(),
        if (int.tryParse(minCtl.text.trim()) != null) 'minGrade': int.parse(minCtl.text.trim()),
        if (int.tryParse(maxCtl.text.trim()) != null) 'maxGrade': int.parse(maxCtl.text.trim()),
      });
      _reload();
    } catch (e) {
      _snack('$e');
    } finally {
      nameCtl.dispose();
      minCtl.dispose();
      maxCtl.dispose();
    }
  }

  Future<void> _delete(Map<String, dynamic> school) async {
    final name = school['name']?.toString() ?? '';
    final ctl = TextEditingController();
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text(l.managerDeleteSchool),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.managerDeleteSchoolBody(name)),
              const SizedBox(height: 12),
              TextField(
                controller: ctl,
                decoration: InputDecoration(labelText: l.managerTypeToConfirm(name)),
                onChanged: (_) => setSt(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.commonCancel)),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error, foregroundColor: Theme.of(ctx).colorScheme.onError),
              onPressed: ctl.text.trim() == name ? () => Navigator.pop(ctx, true) : null,
              child: Text(l.managerDeleteForever),
            ),
          ],
        ),
      ),
    );
    try {
      if (ok != true) return;
      await _api.deleteSchool(school['id'].toString());
      _reload();
    } catch (e) {
      _snack('$e');
    } finally {
      ctl.dispose();
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.navSchools),
        actions: const [ManagerLogoutAction()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add_rounded),
        label: Text(l.managerNewSchool),
      ),
      body: CmRefreshIndicator(
        onRefresh: () async => _reload(),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CmLoading());
            }
            if (snap.hasError) {
              return CmErrorState.fromError(snap.error, onRetry: _reload);
            }
            final schools = snap.data ?? const [];
            if (schools.isEmpty) {
              return ListView(children: [
                CmEmptyState(
                  icon: Icons.apartment_rounded,
                  title: l.managerNoSchoolsTitle,
                  message: l.managerNoSchoolsBody,
                ),
              ]);
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: schools.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final s = schools[i];
                final counts = s['userCounts'];
                final totalUsers = counts is Map
                    ? counts.values.fold<int>(0, (a, b) => a + (b is int ? b : 0))
                    : 0;
                return _SchoolCard(
                  name: s['name']?.toString() ?? '—',
                  grades: '${s['minGrade'] ?? '?'}–${s['maxGrade'] ?? '?'}',
                  users: totalUsers,
                  cohorts: s['cohortCount'] ?? 0,
                  onView: () => _view(s['id'].toString()),
                  onEdit: () => _edit(s),
                  onDelete: () => _delete(s),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SchoolCard extends StatelessWidget {
  const _SchoolCard({
    required this.name,
    required this.grades,
    required this.users,
    required this.cohorts,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final String name;
  final String grades;
  final int users;
  final Object cohorts;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    final cohortCount = cohorts is int ? cohorts as int : int.tryParse('$cohorts') ?? 0;
    return CmCard(
      onTap: onView,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CmIconTile(icon: Icons.school_rounded, size: 48, filled: true),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              CmPill(icon: Icons.stairs_rounded, label: l.managerGradesRange(grades)),
              CmPill(icon: Icons.people_alt_rounded, label: l.managerUsersCount(users)),
              CmPill(icon: Icons.groups_rounded, label: l.managerCohortsCount(cohortCount)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: onView, child: Text(l.managerView)),
              TextButton(onPressed: onEdit, child: Text(l.commonEdit)),
              TextButton(
                onPressed: onDelete,
                style: TextButton.styleFrom(foregroundColor: cs.error),
                child: Text(l.commonDelete),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
