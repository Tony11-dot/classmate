// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/phone_field.dart';
import '../../../ui/widgets/liquid_glass_dropdown.dart';
import '../data/admin_repository.dart';
import 'admin_edit_user_screen.dart';
import 'admin_import_users_screen.dart';

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

  List<String> _roleLabels(AppLocalizations l) => [
        l.adminStudents,
        l.adminTeachers,
        l.adminParents,
        l.adminSecretaries,
        l.adminAdmins,
      ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _roles.length, vsync: this);
    // Re-render Scaffold when tab changes so the FAB label can show
    // "Add student" / "Add teacher" / etc based on the active tab.
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) setState(() {});
    });
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
    final session = ref.watch(authSessionProvider);
    final isAdmin = session.primaryRole == 'ADMIN';

    // Button copy + pre-selected role come from the currently-active tab:
    // on Students tab → "Add student" + STUDENT role; same for the rest.
    final l = AppLocalizations.of(context)!;
    final activeRole = _roles[_tabs.index < _roles.length ? _tabs.index : 0];
    final addLabel = switch (activeRole) {
      'STUDENT'   => l.adminAddStudent,
      'TEACHER'   => l.adminAddTeacher,
      'PARENT'    => l.adminAddParent,
      'SECRETARY' => l.adminAddSecretary,
      'ADMIN'     => l.adminAddAdmin,
      _           => l.adminAddUser,
    };

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: isAdmin
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Bulk entry — paste/fill a whole list at once, link parents.
                FloatingActionButton.small(
                  heroTag: 'fab_add_many',
                  tooltip: l.adminPeopleAddMany,
                  onPressed: () => _openAddMany(context),
                  child: const Icon(Icons.group_add_rounded),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.extended(
                  heroTag: 'fab_add_user',
                  onPressed: () => _showAddUserSheet(context, initialRole: activeRole),
                  icon: const Icon(Icons.person_add_rounded),
                  label: Text(addLabel),
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          // Tab bar sits flush under the shell's top bar — same as teacher screens
          TabBar(
            controller: _tabs,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: _roleLabels(l).map((label) => Tab(text: label)).toList(),
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

  Future<void> _openAddMany(BuildContext context) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const AdminImportUsersScreen()),
    );
    // Bulk add may have created users across every role — refresh all tabs.
    for (final role in _roles) {
      ref.invalidate(_usersProvider(role));
    }
  }

  Future<void> _showAddUserSheet(BuildContext context, {String initialRole = 'STUDENT'}) async {
    // rootNavigator: true pushes onto the navigator above the shell so the
    // shell's AppBar + bottom nav are fully covered. Without this the stale
    // "Dashboard"/"People" title from the underlying tab kept showing.
    final createdRole = await Navigator.of(context, rootNavigator: true).push<String>(
      MaterialPageRoute(builder: (_) => AdminAddUserScreen(
        repo: ref.read(adminRepositoryProvider),
        initialRole: initialRole,
      )),
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
      error: (e, _) => Center(child: Text(AppLocalizations.of(context)!.commonErrorWith(e))),
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
                  search.isEmpty
                      ? AppLocalizations.of(context)!.adminNoRoleYet(role.toLowerCase())
                      : AppLocalizations.of(context)!.commonNoResultsForQuery(search),
                  style: theme.textTheme.titleSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (ctx, i) => _UserTile(
            user: filtered[i],
            isAdmin: isAdmin,
            onDelete: () => _confirmDelete(ctx, ref, filtered[i]),
            onEdit: () async {
              // Root navigator so the shell's AppBar/bottom-nav are covered
              // — same reasoning as AddUser above.
              final updated = await Navigator.of(ctx, rootNavigator: true).push<bool>(
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
          user.email.isNotEmpty ? user.email : AppLocalizations.of(context)!.adminNoEmailPlaceholder,
          style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert_rounded),
          onPressed: () => _openUserActions(context, isAdmin: isAdmin, onEdit: onEdit, onDelete: onDelete),
        ),
      ),
    );
  }
}

/// LiquidGlass-styled action sheet replacing Material's PopupMenuButton —
/// matches the rest of the picker UI (rounded surface, drag handle, bold
/// option rows) so the per-row actions feel consistent with the cohort /
/// schedule / subject pickers.
Future<void> _openUserActions(
  BuildContext context, {
  required bool isAdmin,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) async {
  final cs = Theme.of(context).colorScheme;
  final theme = Theme.of(context);
  final l = AppLocalizations.of(context)!;
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: cs.surface,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sCtx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            _GlassAction(
              icon: Icons.edit_rounded,
              label: l.adminEditUser,
              onTap: () { Navigator.pop(sCtx); onEdit(); },
            ),
            if (isAdmin) ...[
              const SizedBox(height: 6),
              _GlassAction(
                icon: Icons.delete_outline_rounded,
                label: l.adminDeleteUser,
                destructive: true,
                onTap: () { Navigator.pop(sCtx); onDelete(); },
              ),
            ],
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(sCtx),
              style: TextButton.styleFrom(foregroundColor: cs.onSurfaceVariant),
              child: Text(l.adminCancel),
            ),
          ],
        ),
      ),
    ),
  );
  // Suppress unused-variable warning when caller's theme isn't read here.
  // (Kept the local for symmetry with the picker helpers.)
  // ignore: unnecessary_statements
  theme;
}

class _GlassAction extends StatelessWidget {
  const _GlassAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = destructive ? cs.error : cs.onSurface;
    final bg = destructive
        ? cs.errorContainer.withValues(alpha: 0.4)
        : cs.surfaceContainerHigh;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: (destructive ? cs.error : cs.outlineVariant).withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: fg),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontWeight: FontWeight.w700, color: fg),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: fg.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}

// ── Add user — full-screen ─────────────────────────────────────────────────────

class AdminAddUserScreen extends ConsumerStatefulWidget {
  const AdminAddUserScreen({super.key, required this.repo, this.initialRole = 'STUDENT'});
  final AdminRepository repo;
  final String initialRole;

  @override
  ConsumerState<AdminAddUserScreen> createState() => _AdminAddUserScreenState();
}

class _AdminAddUserScreenState extends ConsumerState<AdminAddUserScreen> {
  final _nameEnCtrl    = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _usernameCtrl  = TextEditingController();
  final _phoneCtrl     = TextEditingController();
  // Optional admin-set password. Blank = server auto-generates (existing
  // behavior); filled = used as-is so admins can hand the user a known one.
  final _passwordCtrl  = TextEditingController();
  // Optional national ID — stored on User and auto-filled into certificates.
  final _nationalIdCtrl = TextEditingController();
  // Default to Israel since that's where this school is. User can change it.
  String _dialCode     = '+972';
  late String _role = widget.initialRole;
  int?   _grade;
  bool   _saving = false;
  // Principal (ADMIN role only). Grade ranges mirror the school grade range,
  // e.g. [[4,6],[9,12]]. Empty = principal over all grades.
  bool   _isPrincipal = false;
  final List<List<int>> _principalRanges = <List<int>>[];

  /// Expand [lo,hi] ranges into a sorted unique grade list.
  static List<int> _rangesToGrades(List<List<int>> ranges) {
    final set = <int>{};
    for (final r in ranges) {
      var lo = r[0];
      var hi = r[1];
      if (lo > hi) { final t = lo; lo = hi; hi = t; }
      for (int g = lo; g <= hi; g++) {
        set.add(g);
      }
    }
    return set.toList()..sort();
  }

  // ── Live username availability + suggestions ──────────────────────────────
  Timer? _uDebounce;
  bool _uChecking = false;
  bool _uValid = true;      // format ok
  bool? _uAvailable;        // null = not checked yet
  List<String> _uSuggestions = const [];
  // True while we programmatically set the username (tap-to-fill) so the
  // controller listener doesn't fight the user / loop.
  bool _settingUsername = false;

  static const _roles      = ['STUDENT', 'TEACHER', 'SECRETARY', 'PARENT', 'ADMIN'];

  List<String> _roleLabels(AppLocalizations l) => [
        l.roleStudent,
        l.roleTeacher,
        l.roleSecretary,
        l.roleParent,
        l.roleAdmin,
      ];

  String _roleTitleOf(AppLocalizations l) => switch (_role) {
    'TEACHER'   => l.adminAddTeacher,
    'PARENT'    => l.adminAddParent,
    'SECRETARY' => l.adminAddSecretary,
    'ADMIN'     => l.adminAddAdmin,
    _           => l.adminAddStudent,
  };

  @override
  void initState() {
    super.initState();
    _usernameCtrl.addListener(_onUsernameChanged);
    // Suggestions follow the name too, so a typed name surfaces ideas even
    // before a username is entered.
    _nameEnCtrl.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _uDebounce?.cancel();
    for (final c in [_nameEnCtrl, _emailCtrl, _usernameCtrl, _phoneCtrl, _passwordCtrl, _nationalIdCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _onUsernameChanged() {
    if (_settingUsername) return;
    _uDebounce?.cancel();
    final value = _usernameCtrl.text.trim().toLowerCase();
    setState(() {
      _uChecking = value.isNotEmpty;
      _uAvailable = null;
    });
    _uDebounce = Timer(const Duration(milliseconds: 450), _runUsernameCheck);
  }

  Future<void> _runUsernameCheck() async {
    final value = _usernameCtrl.text.trim().toLowerCase();
    final name = _nameEnCtrl.text.trim();
    // Nothing to check and no name to base ideas on — clear state.
    if (value.isEmpty && name.isEmpty) {
      if (mounted) {
        setState(() {
          _uChecking = false;
          _uAvailable = null;
          _uValid = true;
          _uSuggestions = const [];
        });
      }
      return;
    }
    try {
      final res = await widget.repo.checkUsername(value, name: name);
      if (!mounted) return;
      // Drop stale responses if the field moved on while in flight.
      if (_usernameCtrl.text.trim().toLowerCase() != value) return;
      setState(() {
        _uChecking = false;
        _uValid = value.isEmpty ? true : res.valid;
        _uAvailable = value.isEmpty ? null : res.available;
        _uSuggestions = res.suggestions;
      });
    } catch (_) {
      if (mounted) setState(() => _uChecking = false);
    }
  }

  void _applySuggestion(String username) {
    _settingUsername = true;
    _usernameCtrl.value = TextEditingValue(
      text: username,
      selection: TextSelection.collapsed(offset: username.length),
    );
    _settingUsername = false;
    setState(() {
      _uChecking = false;
      _uValid = true;
      _uAvailable = true;   // suggestions are server-verified as available
      _uSuggestions = const [];
    });
  }

  Widget? _usernameSuffixIcon(ColorScheme cs) {
    if (_uChecking) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (_usernameCtrl.text.trim().isEmpty) return null;
    if (_uAvailable == true) {
      return Icon(Icons.check_circle_rounded, color: cs.primary, size: 20);
    }
    if (_uAvailable == false || !_uValid) {
      return Icon(Icons.error_outline_rounded, color: cs.error, size: 20);
    }
    return null;
  }

  Widget _usernameSuggestions(AppLocalizations l, ColorScheme cs) {
    if (_uSuggestions.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.adminUsernameSuggestionsLabel,
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in _uSuggestions)
                ActionChip(
                  avatar: Icon(Icons.add_rounded, size: 16, color: cs.primary),
                  label: Text(s),
                  onPressed: () => _applySuggestion(s),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final nameEn   = _nameEnCtrl.text.trim();
    final email    = _emailCtrl.text.trim();
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text; // intentionally NOT trimmed
    final l = AppLocalizations.of(context)!;
    if (nameEn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.adminNameEnglishRequired)));
      return;
    }
    // Username is now mandatory — it's the universal login identifier.
    // Email stays optional (some students don't have one yet).
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.adminUsernameRequired)));
      return;
    }
    if (password.isNotEmpty && password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.adminPasswordMinLength)));
      return;
    }
    // Students must have a grade level so cohort/grade-scoped features
    // (exams, assignments, grade lists) place them correctly from day 1.
    if (_role == 'STUDENT' && _grade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.adminPeopleGradeLevelRequired)),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      // Normalize whatever the user typed (national `0525488441`, bare
      // digits, or already-prefixed `+972...`) into a clean E.164.
      final phoneE164 = joinE164(_dialCode, _phoneCtrl.text);
      final nationalId = _nationalIdCtrl.text.trim();
      final isPrincipal = _role == 'ADMIN' && _isPrincipal;
      final result = await widget.repo.createUser(
        name: nameEn,
        email: email.isEmpty ? null : email,
        username: username,
        phone: phoneE164,
        password: password.isEmpty ? null : password,
        role: _role,
        grade: _grade,
        nationalId: nationalId.isEmpty ? null : nationalId,
        isPrincipal: isPrincipal ? true : null,
        principalGrades: isPrincipal ? _rangesToGrades(_principalRanges) : null,
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
                Text(dl.adminUserCreatedMsg(result.user.name)),
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
                      _CredRow(label: dl.adminCredsUsername, value: createdUsername),
                      if (email.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _CredRow(label: dl.adminCredsEmail, value: email),
                      ],
                      const SizedBox(height: 6),
                      _CredRow(label: dl.adminCredsPassword, value: result.tempPassword, mono: true),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(dl.adminShareCredsHint, style: Theme.of(dCtx).textTheme.bodySmall?.copyWith(color: cs2.onSurfaceVariant)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final text = 'Username: $createdUsername\n${email.isNotEmpty ? 'Email: $email\n' : ''}Password: ${result.tempPassword}';
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(dCtx).showSnackBar(SnackBar(content: Text(dl.adminCopied)));
                },
                child: Text(dl.adminCopyCredsButton),
              ),
              FilledButton(onPressed: () => Navigator.pop(dCtx), child: Text(dl.commonDone)),
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

  Widget _langField(TextEditingController ctrl, String langLabel, {bool required = false, bool autofocus = false}) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        autofocus: autofocus,
        textInputAction: TextInputAction.next,
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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_add_user_screen',
        onPressed: _saving ? null : _save,
        icon: _saving
            ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.check_rounded),
        label: Text(l.adminCreateUser),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                children: [
                  // ── Back chevron + title — no AppBar, so this header is
                  // the only visual entry point back to the previous screen.
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                        onPressed: () => Navigator.maybePop(context),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                      ),
                  const SizedBox(width: 4),
                      Text(
                        _roleTitleOf(l),
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // ── Login credentials ──────────────────────────────────────
                  TextField(
                    controller: _usernameCtrl,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.adminEditUserUsernameRequired,
                      prefixIcon: const Icon(Icons.alternate_email_rounded, size: 18),
                      suffixIcon: _usernameSuffixIcon(cs),
                      errorText: (!_uValid && _usernameCtrl.text.trim().isNotEmpty)
                          ? l.adminUsernameInvalidFormat
                          : (_uAvailable == false
                              ? l.adminAddManyUsernameTaken
                              : null),
                      helperText: _uAvailable == true ? l.adminUsernameAvailable : null,
                      helperStyle: TextStyle(color: cs.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  _usernameSuggestions(l, cs),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.commonEmail,
                      prefixIcon: const Icon(Icons.email_rounded, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // ── Phone with country dial-code picker ───────────────────
                  PhoneField(
                    controller: _phoneCtrl,
                    dialCode: _dialCode,
                    onDialCodeChanged: (v) => setState(() => _dialCode = v),
                  ),
                  const SizedBox(height: 10),
                  // ── Optional password ─────────────────────────────────────
                  TextField(
                    controller: _passwordCtrl,
                    autocorrect: false,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.commonPassword,
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // ── Optional national ID (auto-fills into certificates) ────
                  TextField(
                    controller: _nationalIdCtrl,
                    autocorrect: false,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.adminEditUserNationalId,
                      prefixIcon: const Icon(Icons.badge_rounded, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ── Name ───────────────────────────────────────────────────
                  _langField(_nameEnCtrl, 'Full name *', required: true, autofocus: true),
                  const SizedBox(height: 16),
                  // ── Role ───────────────────────────────────────────────────
                  Text(l.adminRoleLabel, style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_roles.length, (i) => ChoiceChip(
                      label: Text(_roleLabels(l)[i]),
                      selected: _role == _roles[i],
                      onSelected: (_) => setState(() { _role = _roles[i]; if (_role != 'STUDENT') _grade = null; }),
                    )),
                  ),
                  // ── Principal (admins only) ────────────────────────────────
                  if (_role == 'ADMIN') ...[
                    const SizedBox(height: 20),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _isPrincipal,
                      title: Text(l.adminPrincipalLabel),
                      subtitle: Text(l.adminPrincipalHint,
                          style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                      onChanged: (v) => setState(() => _isPrincipal = v),
                    ),
                    if (_isPrincipal) ...[
                      const SizedBox(height: 6),
                      Text(l.adminPrincipalGrades, style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      Builder(builder: (context) {
                        final grades = ref.watch(authSessionProvider).schoolGrades;
                        final gmin = grades.isNotEmpty ? grades.first : 1;
                        final gmax = grades.isNotEmpty ? grades.last : 12;
                        List<LiquidGlassDropdownItem<int>> items() => [
                              for (final g in grades)
                                LiquidGlassDropdownItem(value: g, label: l.adminCohortGradeFormat('$g')),
                            ];
                        return Column(
                          children: [
                            for (int i = 0; i < _principalRanges.length; i++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: LiquidGlassSelectField<int>(
                                        label: l.adminPrincipalRangeFrom,
                                        value: _principalRanges[i][0].clamp(gmin, gmax),
                                        items: items(),
                                        onChanged: (v) => setState(() => _principalRanges[i][0] = v),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: LiquidGlassSelectField<int>(
                                        label: l.adminPrincipalRangeTo,
                                        value: _principalRanges[i][1].clamp(gmin, gmax),
                                        items: items(),
                                        onChanged: (v) => setState(() => _principalRanges[i][1] = v),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.remove_circle_outline_rounded, color: cs.error),
                                      onPressed: () => setState(() => _principalRanges.removeAt(i)),
                                    ),
                                  ],
                                ),
                              ),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: TextButton.icon(
                                onPressed: () => setState(() => _principalRanges.add([gmin, gmax])),
                                icon: const Icon(Icons.add, size: 18),
                                label: Text(l.adminPrincipalAddRange),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ],
                  // ── Grade (students only) ──────────────────────────────────
                  if (_role == 'STUDENT') ...[
                    const SizedBox(height: 16),
                    Text(AppLocalizations.of(context)!.adminPeopleGrade, style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: ref.watch(authSessionProvider).schoolGrades.map((g) => ChoiceChip(
                        label: Text(AppLocalizations.of(context)!.adminCohortGradeFormat(g.toString())),
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
