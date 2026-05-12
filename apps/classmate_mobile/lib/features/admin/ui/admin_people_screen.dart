// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../data/admin_repository.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final _usersProvider = FutureProvider.autoDispose.family<AdminUserList, String>((ref, role) {
  return ref.watch(adminRepositoryProvider).listUsers(role: role.isEmpty ? null : role);
});

// ── Screen ────────────────────────────────────────────────────────────────────

class AdminPeopleScreen extends ConsumerStatefulWidget {
  const AdminPeopleScreen({super.key});

  @override
  ConsumerState<AdminPeopleScreen> createState() => _AdminPeopleScreenState();
}

class _AdminPeopleScreenState extends ConsumerState<AdminPeopleScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _searchCtrl = TextEditingController();
  String _search = '';

  static const _roles = ['STUDENT', 'TEACHER', 'PARENT', 'SECRETARY'];
  static const _roleLabels = ['Students', 'Teachers', 'Parents', 'Secretaries'];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _roles.length, vsync: this);
    _searchCtrl.addListener(() {
      final v = _searchCtrl.text.trim();
      if (v != _search) setState(() => _search = v);
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final session = ref.watch(authSessionProvider);
    final isAdmin = session.primaryRole == 'ADMIN';

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              heroTag: 'fab_add_user',
              onPressed: () => _showAddUserSheet(context),
              icon: const Icon(Icons.person_add_rounded),
              label: Text(AppLocalizations.of(context)!.adminAddUser),
            )
          : null,
      body: Column(
        children: [
          // Tab bar sits flush under the shell's top bar — same as teacher screens
          TabBar(
            controller: _tabs,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: _roleLabels.map((l) => Tab(text: l)).toList(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.adminSearchPeople,
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                isDense: true,
                filled: true,
                fillColor: cs.surfaceContainerLow,
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: _roles.map((role) => _UserTab(
                role: role,
                search: _search,
                isAdmin: isAdmin,
                onRefresh: () => ref.invalidate(_usersProvider(role)),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddUserSheet(BuildContext context) async {
    final createdRole = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _AddUserSheet(repo: ref.read(adminRepositoryProvider)),
    );
    if (createdRole != null && createdRole.isNotEmpty) {
      for (final role in _roles) {
        ref.invalidate(_usersProvider(role));
      }
      // Auto-navigate to the tab matching the created user's role
      final tabIndex = _roles.indexOf(createdRole);
      if (tabIndex >= 0 && tabIndex < _tabs.length) {
        _tabs.animateTo(tabIndex);
      }
    }
  }
}

// ── Per-role tab ───────────────────────────────────────────────────────────────

class _UserTab extends ConsumerWidget {
  const _UserTab({
    required this.role,
    required this.search,
    required this.isAdmin,
    required this.onRefresh,
  });

  final String role;
  final String search;
  final bool isAdmin;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = Theme.of(context).colorScheme;
    final async = ref.watch(_usersProvider(role));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (list) {
        final filtered = search.isEmpty
            ? list.users
            : list.users.where((u) =>
                u.name.toLowerCase().contains(search.toLowerCase()) ||
                u.email.toLowerCase().contains(search.toLowerCase())).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people_outline_rounded, size: 56, color: cs.outlineVariant),
                const SizedBox(height: 12),
                Text(
                  search.isEmpty ? 'No ${role.toLowerCase()}s yet' : 'No results for "$search"',
                  style: theme.textTheme.titleSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (ctx, i) => _UserTile(
            user: filtered[i],
            isAdmin: isAdmin,
            onDelete: () => _confirmDelete(ctx, ref, filtered[i]),
            onResetPassword: () => _resetPassword(ctx, ref, filtered[i]),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext ctx, WidgetRef ref, AdminUser user) async {
    final l = AppLocalizations.of(ctx)!;
    final confirm = await showDialog<bool>(
      context: ctx,
      builder: (dCtx) {
        final dl = AppLocalizations.of(dCtx)!;
        return AlertDialog(
          title: Text(dl.adminDeleteUser),
          content: Text(dl.adminDeleteUserConfirm(user.name)),
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
      await ref.read(adminRepositoryProvider).deleteUser(user.id);
      onRefresh();
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(l.adminCancel)));
    }
  }

  Future<void> _resetPassword(BuildContext ctx, WidgetRef ref, AdminUser user) async {
    final l = AppLocalizations.of(ctx)!;
    try {
      final temp = await ref.read(adminRepositoryProvider).resetUserPassword(user.id);
      if (!ctx.mounted) return;
      showDialog(
        context: ctx,
        builder: (dCtx) {
          final dl = AppLocalizations.of(dCtx)!;
          return AlertDialog(
            title: Text(dl.adminPasswordReset),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dl.adminTempPasswordFor(user.name)),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(dCtx).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(
                    temp,
                    style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: temp));
                  ScaffoldMessenger.of(dCtx).showSnackBar(
                    SnackBar(content: Text(dl.adminCopied)),
                  );
                },
                child: const Text('Copy'),
              ),
              FilledButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Done')),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}

// ── User tile ──────────────────────────────────────────────────────────────────

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.isAdmin,
    required this.onDelete,
    required this.onResetPassword,
  });

  final AdminUser user;
  final bool isAdmin;
  final VoidCallback onDelete;
  final VoidCallback onResetPassword;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final initials = _initials(user.name);

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: cs.onPrimaryContainer,
              ),
            ),
          ),
        ),
        title: Text(
          user.name,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          user.email,
          style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        trailing: isAdmin
            ? PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (v) {
                  if (v == 'delete') onDelete();
                  if (v == 'reset') onResetPassword();
                },
                itemBuilder: (ctx) {
                  final l = AppLocalizations.of(ctx)!;
                  return [
                    PopupMenuItem(value: 'reset', child: Text(l.adminResetPassword)),
                    PopupMenuItem(value: 'delete', child: Text(l.adminDeleteUser)),
                  ];
                },
              )
            : null,
      ),
    );
  }
}

// ── Add user sheet ─────────────────────────────────────────────────────────────

class _AddUserSheet extends StatefulWidget {
  const _AddUserSheet({required this.repo});
  final AdminRepository repo;

  @override
  State<_AddUserSheet> createState() => _AddUserSheetState();
}

class _AddUserSheetState extends State<_AddUserSheet> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _role = 'STUDENT';
  bool _saving = false;

  static const _roles = ['STUDENT', 'TEACHER', 'SECRETARY', 'PARENT'];
  static const _roleLabels = ['Student', 'Teacher', 'Secretary', 'Parent'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    if (name.isEmpty || email.isEmpty) return;

    setState(() => _saving = true);
    try {
      final result = await widget.repo.createUser(
        name: name,
        email: email,
        role: _role,
      );
      if (!mounted) return;
      // Show temp password dialog BEFORE closing the sheet — after pop() the context is unmounted
      await showDialog(
        context: context,
        builder: (dCtx) {
          final dl = AppLocalizations.of(dCtx)!;
          return AlertDialog(
            title: Text(dl.adminUserCreated),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dl.adminTempPasswordFor(result.user.name)),
                const SizedBox(height: 12),
                Text(dl.adminTempPassword, style: Theme.of(dCtx).textTheme.labelMedium),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(dCtx).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(
                    result.tempPassword,
                    style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: result.tempPassword));
                  ScaffoldMessenger.of(dCtx)
                      .showSnackBar(SnackBar(content: Text(dl.adminCopied)));
                },
                child: const Text('Copy'),
              ),
              FilledButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Done')),
            ],
          );
        },
      );
      // Pop the sheet AFTER the dialog is dismissed, returning the created role
      if (!mounted) return;
      Navigator.of(context).pop(_role);
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
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.adminAddUser,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_rounded, size: 16),
                  label: Text(l.adminCreateUser),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: '${l.adminFullName} *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: '${l.adminEmailAddress} *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l.adminRoleLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(
                _roles.length,
                (i) => ChoiceChip(
                  label: Text(_roleLabels[i]),
                  selected: _role == _roles[i],
                  onSelected: (_) => setState(() => _role = _roles[i]),
                ),
              ),
            ),
          ],
        ),
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
