import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/widgets/cm_loading.dart';
import '../data/manager_api.dart';
import 'manager_shell.dart';
import 'manager_school_form_screen.dart';

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
    setState(() => _future = ref.read(managerApiProvider).listSchools());
  }

  ManagerApi get _api => ref.read(managerApiProvider);

  Future<void> _openCreate() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const ManagerSchoolFormScreen()),
    );
    if (created == true) _reload();
  }

  Future<void> _view(String id) async {
    showDialog<void>(
      context: context,
      builder: (ctx) => FutureBuilder<Map<String, dynamic>>(
        future: _api.getSchool(id),
        builder: (context, snap) {
          final s = snap.data;
          return AlertDialog(
            title: Text(s?['name']?.toString() ?? 'School'),
            content: snap.connectionState != ConnectionState.done
                ? const SizedBox(height: 80, child: Center(child: CmLoading()))
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _kv('Grades', '${s?['minGrade'] ?? '?'}–${s?['maxGrade'] ?? '?'}'),
                        _kv('Cohorts', '${s?['cohortCount'] ?? 0}'),
                        _kv('Classrooms', '${s?['classroomCount'] ?? 0}'),
                        const SizedBox(height: 8),
                        const Text('Users', style: TextStyle(fontWeight: FontWeight.w700)),
                        ..._userCounts(s?['userCounts']),
                      ],
                    ),
                  ),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
          );
        },
      ),
    );
  }

  List<Widget> _userCounts(dynamic counts) {
    if (counts is! Map) return const [Text('—')];
    final entries = counts.entries.toList();
    if (entries.isEmpty) return const [Text('—')];
    return entries.map((e) => _kv(e.key.toString(), '${e.value}')).toList();
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
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit school'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Name')),
            Row(children: [
              Expanded(child: TextField(controller: minCtl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Min grade'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: maxCtl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Max grade'))),
            ]),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _api.updateSchool(school['id'].toString(), {
        'name': nameCtl.text.trim(),
        if (int.tryParse(minCtl.text.trim()) != null) 'minGrade': int.parse(minCtl.text.trim()),
        if (int.tryParse(maxCtl.text.trim()) != null) 'maxGrade': int.parse(maxCtl.text.trim()),
      });
      _reload();
    } catch (e) {
      _snack('$e');
    }
  }

  Future<void> _delete(Map<String, dynamic> school) async {
    final name = school['name']?.toString() ?? '';
    final ctl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Delete school'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('This permanently deletes "$name" and every user, cohort, classroom, and record in it. This cannot be undone.'),
              const SizedBox(height: 12),
              TextField(
                controller: ctl,
                decoration: InputDecoration(labelText: 'Type "$name" to confirm'),
                onChanged: (_) => setSt(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: ctl.text.trim() == name ? () => Navigator.pop(ctx, true) : null,
              child: const Text('Delete forever'),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      await _api.deleteSchool(school['id'].toString());
      _reload();
    } catch (e) {
      _snack('$e');
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schools'),
        actions: const [ManagerLogoutAction()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New school'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CmLoading());
            }
            if (snap.hasError) {
              return ListView(children: [Padding(padding: const EdgeInsets.all(24), child: Text('${snap.error}'))]);
            }
            final schools = snap.data ?? const [];
            if (schools.isEmpty) {
              return ListView(children: const [
                Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(child: Text('No schools yet. Tap "New school" to create one.')),
                ),
              ]);
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: schools.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final s = schools[i];
                final counts = s['userCounts'];
                final totalUsers = counts is Map
                    ? counts.values.fold<int>(0, (a, b) => a + (b is int ? b : 0))
                    : 0;
                return Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(child: Icon(Icons.school_rounded)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s['name']?.toString() ?? '—',
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                  Text('Grades ${s['minGrade'] ?? '?'}–${s['maxGrade'] ?? '?'} · $totalUsers users · ${s['cohortCount'] ?? 0} cohorts',
                                      style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(onPressed: () => _view(s['id'].toString()), child: const Text('View')),
                            TextButton(onPressed: () => _edit(s), child: const Text('Edit')),
                            TextButton(
                              onPressed: () => _delete(s),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
