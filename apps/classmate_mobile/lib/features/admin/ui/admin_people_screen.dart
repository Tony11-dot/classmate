// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../data/admin_repository.dart';
import 'admin_edit_user_screen.dart';

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

  static const _roles = ['STUDENT', 'TEACHER', 'PARENT', 'SECRETARY', 'ADMIN'];
  static const _roleLabels = ['Students', 'Teachers', 'Parents', 'Secretaries', 'Admins'];

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
    final createdRole = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => AdminAddUserScreen(repo: ref.read(adminRepositoryProvider))),
    );
    if (createdRole != null && createdRole.isNotEmpty) {
      for (final role in _roles) {
        ref.invalidate(_usersProvider(role));
      }
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
            onEdit: () async {
              final updated = await Navigator.push<bool>(
                ctx,
                MaterialPageRoute(builder: (_) => AdminEditUserScreen(
                  userId: filtered[i].id,
                  repo: ref.read(adminRepositoryProvider),
                )),
              );
              if (updated == true) onRefresh();
            },
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

}

// ── User tile ──────────────────────────────────────────────────────────────────

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.isAdmin,
    required this.onDelete,
    required this.onEdit,
  });

  final AdminUser user;
  final bool isAdmin;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

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
          width: 42, height: 42,
          decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(initials, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: cs.onPrimaryContainer))),
        ),
        title: Text(user.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
        subtitle: Text(
          user.email.isNotEmpty ? user.email : '(no email)',
          style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          onSelected: (v) {
            if (v == 'edit') onEdit();
            if (v == 'delete') onDelete();
          },
          itemBuilder: (ctx) {
            final l = AppLocalizations.of(ctx)!;
            return [
              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_rounded, size: 16), SizedBox(width: 10), Text('Edit')])),
              PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline_rounded, size: 16, color: Theme.of(ctx).colorScheme.error), SizedBox(width: 10), Text(l.adminDeleteUser, style: TextStyle(color: Theme.of(ctx).colorScheme.error))])),
            ];
          },
        ),
      ),
    );
  }
}

// ── Add user — full-screen ─────────────────────────────────────────────────────

class AdminAddUserScreen extends StatefulWidget {
  const AdminAddUserScreen({super.key, required this.repo});
  final AdminRepository repo;

  @override
  State<AdminAddUserScreen> createState() => _AdminAddUserScreenState();
}

class _AdminAddUserScreenState extends State<AdminAddUserScreen> {
  final _nameEnCtrl   = TextEditingController();
  final _nameArCtrl   = TextEditingController();
  final _nameHeCtrl   = TextEditingController();
  final _nameFrCtrl   = TextEditingController();
  final _nameRuCtrl   = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _usernameCtrl = TextEditingController();
  String _role  = 'STUDENT';
  int?   _grade;
  bool   _saving = false;

  static const _roles      = ['STUDENT', 'TEACHER', 'SECRETARY', 'PARENT', 'ADMIN'];
  static const _roleLabels = ['Student', 'Teacher', 'Secretary', 'Parent', 'Admin'];
  static const _grades     = [5, 6, 7, 8, 9, 10, 11, 12];

  @override
  void dispose() {
    for (final c in [_nameEnCtrl, _nameArCtrl, _nameHeCtrl, _nameFrCtrl, _nameRuCtrl, _emailCtrl, _usernameCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final nameEn   = _nameEnCtrl.text.trim();
    final email    = _emailCtrl.text.trim();
    final username = _usernameCtrl.text.trim();
    if (nameEn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('English name is required')));
      return;
    }
    if (email.isEmpty && username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('At least a username or email is required')));
      return;
    }
    setState(() => _saving = true);
    try {
      final result = await widget.repo.createUser(
        nameEn: nameEn,
        nameAr: _nameArCtrl.text.trim().isEmpty ? null : _nameArCtrl.text.trim(),
        nameHe: _nameHeCtrl.text.trim().isEmpty ? null : _nameHeCtrl.text.trim(),
        nameFr: _nameFrCtrl.text.trim().isEmpty ? null : _nameFrCtrl.text.trim(),
        nameRu: _nameRuCtrl.text.trim().isEmpty ? null : _nameRuCtrl.text.trim(),
        email: email.isEmpty ? null : email,
        username: username.isEmpty ? null : username,
        role: _role,
        grade: _grade,
      );
      if (!mounted) return;
      final createdUsername = result.username ?? username;
      await showDialog(
        context: context,
        builder: (dCtx) {
          final dl = AppLocalizations.of(dCtx)!;
          final cs2 = Theme.of(dCtx).colorScheme;
          return AlertDialog(
            title: Text(dl.adminUserCreated),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${result.user.name} created.'),
                const SizedBox(height: 12),
                // Login credentials card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs2.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CredRow(label: 'Username', value: createdUsername),
                      if (email.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _CredRow(label: 'Email', value: email),
                      ],
                      const SizedBox(height: 6),
                      _CredRow(label: 'Password', value: result.tempPassword, mono: true),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text('Share these credentials with the student.', style: Theme.of(dCtx).textTheme.bodySmall?.copyWith(color: cs2.onSurfaceVariant)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final text = 'Username: $createdUsername\n${email.isNotEmpty ? 'Email: $email\n' : ''}Password: ${result.tempPassword}';
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(dCtx).showSnackBar(SnackBar(content: Text(dl.adminCopied)));
                },
                child: const Text('Copy All'),
              ),
              FilledButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Done')),
            ],
          );
        },
      );
      if (!mounted) return;
      Navigator.of(context).pop(_role);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _langField(TextEditingController ctrl, String langLabel, {bool required = false}) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: required ? '$langLabel *' : langLabel,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              langLabel.split(' ').last,
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant, fontWeight: FontWeight.w700),
            ),
          ),
          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l   = AppLocalizations.of(context)!;
    final cs  = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context)),
                  Expanded(child: Text(l.adminAddUser, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox.square(dimension: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check_rounded, size: 16),
                    label: Text(l.adminCreateUser),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                children: [
                  // ── Login credentials ──────────────────────────────────────
                  Text('Login', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
                  const SizedBox(height: 4),
                  Text('At least username or email required. Password is auto-generated.',
                      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _usernameCtrl,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: 'Username (e.g. john.doe)',
                      prefixIcon: const Icon(Icons.alternate_email_rounded, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: 'Email (optional)',
                      prefixIcon: const Icon(Icons.email_rounded, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ── Name fields ────────────────────────────────────────────
                  Text('Name', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
                  const SizedBox(height: 4),
                  Text('At least English is required. Other languages are optional.',
                      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 12),
                  _langField(_nameEnCtrl, 'Name in English', required: true),
                  _langField(_nameArCtrl, 'Name in Arabic (اسم)'),
                  _langField(_nameHeCtrl, 'Name in Hebrew (שם)'),
                  _langField(_nameFrCtrl, 'Name in French'),
                  _langField(_nameRuCtrl, 'Name in Russian'),
                  const SizedBox(height: 20),
                  // ── Role ───────────────────────────────────────────────────
                  Text(l.adminRoleLabel, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_roles.length, (i) => ChoiceChip(
                      label: Text(_roleLabels[i]),
                      selected: _role == _roles[i],
                      onSelected: (_) => setState(() { _role = _roles[i]; if (_role != 'STUDENT') _grade = null; }),
                    )),
                  ),
                  // ── Grade (students only) ──────────────────────────────────
                  if (_role == 'STUDENT') ...[
                    const SizedBox(height: 20),
                    Text('Grade', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _grades.map((g) => ChoiceChip(
                        label: Text('Grade $g'),
                        selected: _grade == g,
                        onSelected: (_) => setState(() => _grade = g),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _CredRow extends StatelessWidget {
  const _CredRow({required this.label, required this.value, this.mono = false});
  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: mono ? 13 : 12,
              fontWeight: FontWeight.w700,
              fontFamily: mono ? 'monospace' : null,
              color: mono ? const Color(0xFF7C3AED) : cs.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

String _initials(String name) {
  if (name.isEmpty) return 'CM';
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  final word = parts[0];
  if (word.length >= 2) return '${word[0]}${word[1]}'.toUpperCase();
  return word[0].toUpperCase();
}
