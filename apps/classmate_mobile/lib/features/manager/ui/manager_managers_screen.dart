import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/widgets/cm_loading.dart';
import '../data/manager_api.dart';
import '../../../ui/widgets/cm_refresh_indicator.dart';

class ManagerManagersScreen extends ConsumerStatefulWidget {
  const ManagerManagersScreen({super.key});

  @override
  ConsumerState<ManagerManagersScreen> createState() => _ManagerManagersScreenState();
}

class _ManagerManagersScreenState extends ConsumerState<ManagerManagersScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() => _future = ref.read(managerApiProvider).listManagers());
  }

  ManagerApi get _api => ref.read(managerApiProvider);

  void _snack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _add() async {
    final name = TextEditingController();
    final email = TextEditingController();
    final username = TextEditingController();
    final password = TextEditingController();
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Add manager'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Grant manager access to an existing account by email or username, '
                  'or fill everything to create a brand-new manager.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 12),
                TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
                TextField(controller: username, decoration: const InputDecoration(labelText: 'Username')),
                const Divider(height: 24),
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Full name (new account)')),
                TextField(controller: password, decoration: const InputDecoration(labelText: 'Password (new account)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add')),
          ],
        ),
      );
      if (ok != true) return;
      final res = await _api.addManager(
        name: name.text,
        email: email.text,
        username: username.text,
        password: password.text,
      );
      if (res['ok'] == true) {
        _snack(res['created'] == true ? 'Manager created.' : 'Manager access granted.');
        _reload();
      } else {
        _snack('Failed: ${res['message'] ?? res}');
      }
    } catch (e) {
      _snack('$e');
    } finally {
      name.dispose();
      email.dispose();
      username.dispose();
      password.dispose();
    }
  }

  Future<void> _revoke(Map<String, dynamic> m) async {
    final label = m['name']?.toString() ?? m['email']?.toString() ?? m['username']?.toString() ?? 'this manager';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove manager'),
        content: Text('Remove manager access from $label?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _api.revokeManager(m['id'].toString());
      _reload();
    } catch (e) {
      _snack('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Managers')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add manager'),
      ),
      body: CmRefreshIndicator(
        onRefresh: () async => _reload(),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CmLoading());
            }
            final managers = snap.data ?? const [];
            if (managers.isEmpty) {
              return ListView(children: const [
                Padding(padding: EdgeInsets.all(48), child: Center(child: Text('No managers.'))),
              ]);
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: managers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final m = managers[i];
                final isOwner = m['isOwner'] == true;
                return Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(isOwner ? Icons.star_rounded : Icons.person_rounded)),
                    title: Text(m['name']?.toString() ?? '—', style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text([
                      if ((m['email'] ?? '').toString().isNotEmpty) m['email'],
                      if ((m['username'] ?? '').toString().isNotEmpty) '@${m['username']}',
                      if (isOwner) 'Owner',
                    ].join(' · ')),
                    trailing: isOwner
                        ? const Chip(label: Text('Owner'))
                        : IconButton(
                            icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.red),
                            onPressed: () => _revoke(m),
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
