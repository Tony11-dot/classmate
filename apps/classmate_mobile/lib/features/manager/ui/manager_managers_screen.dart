import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/cm_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../ui/widgets/cm_surfaces.dart';
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
    setState(() { _future = ref.read(managerApiProvider).listManagers(); });
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
    final l = AppLocalizations.of(context)!;
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.managerAddManager),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l.managerAddManagerHint,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 12),
                TextField(controller: email, decoration: InputDecoration(labelText: l.commonEmail)),
                TextField(controller: username, decoration: InputDecoration(labelText: l.profileUsername)),
                const Divider(height: 24),
                TextField(controller: name, decoration: InputDecoration(labelText: l.managerFullNameNewAccount)),
                TextField(controller: password, decoration: InputDecoration(labelText: l.managerPasswordNewAccount)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.commonCancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.commonAdd)),
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
        _snack(res['created'] == true ? l.managerCreated : l.managerAccessGranted);
        _reload();
      } else {
        _snack(l.commonFailedWith('${res['message'] ?? res}'));
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
    final l = AppLocalizations.of(context)!;
    final label = m['name']?.toString() ?? m['email']?.toString() ?? m['username']?.toString() ?? l.managerThisManager;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.managerRemoveManager),
        content: Text(l.managerRemoveManagerConfirm(label)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.commonCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error, foregroundColor: Theme.of(ctx).colorScheme.onError),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.commonRemove),
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
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.navManagers)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.person_add_rounded),
        label: Text(l.managerAddManager),
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
              return ListView(children: [
                CmEmptyState(icon: Icons.manage_accounts_rounded, title: l.managerNoManagers),
              ]);
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: managers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final m = managers[i];
                final isOwner = m['isOwner'] == true;
                final cs = Theme.of(context).colorScheme;
                final meta = [
                  if ((m['email'] ?? '').toString().isNotEmpty) m['email'],
                  if ((m['username'] ?? '').toString().isNotEmpty) '@${m['username']}',
                ].join(' · ');
                return CmCard(
                  padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 8, 12),
                  child: Row(
                    children: [
                      CmIconTile(
                        icon: isOwner ? Icons.star_rounded : Icons.person_rounded,
                        color: isOwner ? CmTokens.of(context).warn : cs.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m['name']?.toString() ?? '—',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            if (meta.isNotEmpty)
                              Text(
                                meta,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                              ),
                          ],
                        ),
                      ),
                      if (isOwner)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 6),
                          child: CmPill(
                            icon: Icons.star_rounded,
                            label: l.managerOwner,
                            color: CmTokens.of(context).warn,
                          ),
                        )
                      else
                        IconButton(
                          tooltip: l.managerRemoveManager,
                          icon: Icon(Icons.remove_circle_outline_rounded, color: cs.error),
                          onPressed: () => _revoke(m),
                        ),
                    ],
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
