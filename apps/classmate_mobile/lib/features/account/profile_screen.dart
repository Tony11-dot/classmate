import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/auth/auth_session.dart';
import '../../core/auth/biometric_service.dart';
import '../../core/http/cm_api.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/glass/liquid_glass_card.dart';
import '../../ui/widgets/phone_field.dart';
import 'profile_controller.dart';
import 'verify_controller.dart';

/// Fetches every cohort the calling student belongs to from
/// /student/cohorts. Only meaningful for the STUDENT role — other roles
/// get an empty list because the endpoint 403s for them and we treat
/// that as "no cohorts to show". autoDispose so it refetches whenever
/// the profile screen is reopened after a cohort change.
final studentMyCohortsProvider = FutureProvider.autoDispose<
    List<({String id, String name, int? grade})>>((ref) async {
  final session = ref.watch(authSessionProvider);
  final token = (session.token ?? '').trim();
  if (token.isEmpty || session.primaryRole != 'STUDENT') return const [];
  final api = CMApi(token: token);
  try {
    final raw = await api.getJson('/student/cohorts');
    if (raw is! Map) return const [];
    final list = (raw['cohorts'] as List?) ?? const [];
    return list.map((e) {
      final m = e as Map;
      return (
        id: (m['id'] ?? '').toString(),
        name: (m['name'] ?? '').toString(),
        grade: m['grade'] is int ? m['grade'] as int : null,
      );
    }).where((c) => c.name.isNotEmpty).toList();
  } catch (_) {
    return const [];
  } finally {
    api.dispose();
  }
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final profile = ref.watch(profileControllerProvider);
    final pc = ref.read(profileControllerProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;

    final roleLabel = switch (session.primaryRole) {
      'TEACHER' => l.roleTeacher,
      'ADMIN' => l.roleAdmin,
      'SECRETARY' => l.roleSecretary,
      'PARENT' => l.roleParent,
      _ => l.student,
    };
    final schoolInfo = session.schoolName.isNotEmpty ? session.schoolName : (session.schoolId.isNotEmpty ? session.schoolId : l.profileNotAvailable);
    final displayName = session.displayName.isNotEmpty
        ? session.displayName
        : roleLabel;
    // Profile state's username is only populated when the user explicitly
    // updates it through this screen — every other code path (registration,
    // admin Add User, onboarding) goes through the server only. Fall back
    // to the session's username (now hydrated from /auth/me) so accounts
    // that have a server-side username but never edited it locally still
    // see "@theirname" instead of "—".
    final username = profile.username.isNotEmpty
        ? profile.username
        : session.username;
    // Initials always from fullName (first+last) so we always get 2 letters
    final nameForInitials = session.fullName.isNotEmpty ? session.fullName : displayName;
    final initials = nameForInitials
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        // ── Avatar header ────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: LiquidGlassCard(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              borderRadius: BorderRadius.circular(24),
              color: cs.surfaceContainerLow,
              border: Border.all(color: cs.outlineVariant),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: cs.primaryContainer,
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        if (username.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            '@$username',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: cs.primary),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _Badge(label: roleLabel, icon: Icons.badge_rounded),
                            if (session.schoolName.isNotEmpty)
                              _Badge(label: session.schoolName, icon: Icons.location_city_rounded),
                            if (session.cohortName.isNotEmpty)
                              _Badge(label: session.cohortName, icon: Icons.groups_rounded),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Locked info ───────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: _Section(
              title: l.profileSchoolInfo,
              icon: Icons.school_outlined,
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.person_rounded,
                    label: l.profileFullName,
                    value: displayName,
                    locked: true,
                  ),
                  const _Divider(),
                  _InfoRow(
                    icon: Icons.badge_outlined,
                    label: l.profileRole,
                    value: roleLabel,
                    locked: true,
                  ),
                  const _Divider(),
                  _InfoRow(
                    icon: Icons.location_city_rounded,
                    label: l.profileSchoolId,
                    value: schoolInfo,
                    locked: true,
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── My cohorts (students only) ────────────────────────────────────
        if (session.primaryRole == 'STUDENT')
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: _Section(
                title: l.profileMyCohorts,
                icon: Icons.groups_outlined,
                child: Consumer(builder: (context, ref, _) {
                  final async = ref.watch(studentMyCohortsProvider);
                  return async.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (_, __) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        l.profileMyCohortsEmpty,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                      ),
                    ),
                    data: (cohorts) {
                      if (cohorts.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            l.profileMyCohortsEmpty,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                          ),
                        );
                      }
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final c in cohorts)
                            Chip(
                              avatar: Icon(
                                Icons.groups_rounded,
                                size: 16,
                                color: cs.primary,
                              ),
                              label: Text(
                                c.grade != null
                                    ? '${c.name} · G${c.grade}'
                                    : c.name,
                              ),
                              backgroundColor: cs.primaryContainer.withValues(alpha: 0.4),
                              side: BorderSide(color: cs.outlineVariant),
                            ),
                        ],
                      );
                    },
                  );
                }),
              ),
            ),
          ),

        // ── Editable info ─────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: _Section(
              title: l.profileAccountInfo,
              icon: Icons.manage_accounts_outlined,
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.alternate_email_rounded,
                    label: l.profileUsername,
                    value: username.isEmpty ? l.profileEmptyValue : '@$username',
                    onEdit: () => _editField(
                      context: context,
                      title: l.profileUsername,
                      icon: Icons.alternate_email_rounded,
                      hint: l.profileUsernameHint,
                      initial: username,
                      onSave: pc.setUsername,
                    ),
                  ),
                  const _Divider(),
                  const _VerifiableContactRows(),
                ],
              ),
            ),
          ),
        ),

        // ── Security ──────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: _Section(
              title: l.profileSecurity,
              icon: Icons.lock_outline_rounded,
              child: _InfoRow(
                icon: Icons.password_rounded,
                label: l.loginPasswordLabel,
                value: '••••••••',
                onEdit: () => _changePassword(context),
              ),
            ),
          ),
        ),

        // ── Biometric sign-in (only when the device has biometrics) ────────
        const SliverToBoxAdapter(child: _BiometricSection()),
      ],
    );
  }

  // ── Edit helpers ───────────────────────────────────────────────────────────

  Future<void> _editField({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String hint,
    required String initial,
    required Future<void> Function(String) onSave,
    TextInputType keyboardType = TextInputType.text,
  }) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _EditSheet(
        title: title,
        icon: icon,
        hint: hint,
        initial: initial,
        keyboardType: keyboardType,
      ),
    );
    if (result == null || !context.mounted) return;
    try {
      await onSave(result);
    } catch (e) {
      if (!context.mounted) return;
      // Surface server-side validation errors (e.g. username already in use)
      // instead of crashing on an uncaught exception.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_humanizeError(e))),
      );
    }
  }

  Future<void> _changePassword(BuildContext context) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _PasswordSheet(),
    );
    if (confirmed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.profilePasswordUpdated)),
      );
    }
  }
}

// ── Bottom-sheet widgets (own their controller lifecycle) ────────────────────

class _EditSheet extends StatefulWidget {
  const _EditSheet({
    required this.title,
    required this.icon,
    required this.hint,
    required this.initial,
    this.keyboardType = TextInputType.text,
  });
  final String title;
  final IconData icon;
  final String hint;
  final String initial;
  final TextInputType keyboardType;

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.icon, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            autofocus: true,
            keyboardType: widget.keyboardType,
            decoration: InputDecoration(
              hintText: widget.hint,
              filled: true,
              fillColor: cs.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(_ctrl.text),
              child: Text(l.profileSave),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordSheet extends ConsumerStatefulWidget {
  const _PasswordSheet();

  @override
  ConsumerState<_PasswordSheet> createState() => _PasswordSheetState();
}

class _PasswordSheetState extends ConsumerState<_PasswordSheet> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final current = _currentCtrl.text.trim();
    final next = _newCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();
    final l = AppLocalizations.of(context)!;

    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      setState(() => _error = l.profilePasswordAllFieldsRequired);
      return;
    }
    if (next.length < 8) {
      setState(() => _error = l.profilePasswordMinLength);
      return;
    }
    if (next != confirm) {
      setState(() => _error = l.profilePasswordMismatch);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final err = await ref
        .read(profileControllerProvider.notifier)
        .changePassword(current: current, next: next);

    if (!mounted) return;

    if (err != null) {
      setState(() {
        _loading = false;
        // Sentinels first (localized copy for known cases). Anything else
        // is the actual server error message — display it verbatim
        // instead of swallowing as the localized "Something went wrong",
        // which made the previous version useless for debugging.
        _error = switch (err) {
          profilePasswordErrorNotAuthenticated => l.profilePasswordNotAuthenticated,
          profilePasswordErrorWrongPassword => l.profilePasswordIncorrect,
          _ => err,
        };
      });
    } else {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      // Wrap in a scrollable so the sheet doesn't RenderFlex-overflow when
      // the keyboard opens (especially with the "Forgot password?" button
      // pushing total content past the available height).
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_rounded, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                l.profileChangePassword,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _PasswordField(controller: _currentCtrl, hint: l.profileCurrentPassword),
          const SizedBox(height: 10),
          _PasswordField(
            controller: _newCtrl,
            hint: l.profileNewPassword,
            autofocus: true,
          ),
          const SizedBox(height: 10),
          _PasswordField(
            controller: _confirmCtrl,
            hint: l.profileConfirmNewPassword,
          ),
          const SizedBox(height: 16),
          if (_error != null) ...[
            LiquidGlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              borderRadius: BorderRadius.circular(12),
              color: cs.errorContainer,
              border: Border.all(color: cs.error),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 16, color: cs.onErrorContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(
                          color: cs.onErrorContainer, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l.profileUpdatePassword),
            ),
          ),
          const SizedBox(height: 8),
          // "Forgot password?" — same destination as on the login screen, for
          // users who don't remember their current password and so can't fill
          // the field above.
          TextButton.icon(
            onPressed: _loading
                ? null
                : () {
                    // Capture the GoRouter BEFORE popping the sheet — once
                    // the modal pops, `context` here is stale and the push
                    // either no-ops or lands on the wrong navigator.
                    final router = GoRouter.of(context);
                    Navigator.of(context).pop();
                    router.push('/forgot-password');
                  },
            icon: const Icon(Icons.help_outline_rounded, size: 18),
            label: Text(AppLocalizations.of(context)!.loginForgotPasswordLink),
          ),
        ],
      ),
    );
  }
}

// ── Helper widgets ──────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: cs.primary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.child,
  });
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      borderRadius: BorderRadius.circular(20),
      color: cs.surfaceContainerLow,
      border: Border.all(color: cs.outlineVariant),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Divider(
      height: 1,
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant,
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.locked = false,
    this.onEdit,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool locked;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: locked ? null : onEdit,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: LiquidGlassCard(
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(10),
                color: locked ? cs.surfaceContainerHigh : cs.primaryContainer,
                child: Center(
                  child: Icon(
                    icon,
                    size: 18,
                    color: locked ? cs.onSurfaceVariant : cs.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (locked)
              Icon(Icons.lock_outline_rounded, size: 16, color: cs.outlineVariant)
            else
              Icon(Icons.edit_outlined, size: 16, color: cs.primary),
          ],
        ),
      ),
    );
  }
}

// ── Verifiable contact rows (email + phone with Verify state) ────────────────

class _VerifiableContactRows extends ConsumerStatefulWidget {
  const _VerifiableContactRows();

  @override
  ConsumerState<_VerifiableContactRows> createState() => _VerifiableContactRowsState();
}

class _VerifiableContactRowsState extends ConsumerState<_VerifiableContactRows> {
  @override
  void initState() {
    super.initState();
    // Pull fresh status on screen open so the badges aren't stale.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(verifyControllerProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final status = ref.watch(verifyControllerProvider);

    return Column(
      children: [
        _VerifiableRow(
          channel: 'email',
          icon: Icons.email_outlined,
          label: l.profileContactEmail,
          value: status.email ?? '',
          verified: status.emailVerified,
        ),
        const _Divider(),
        _VerifiableRow(
          channel: 'sms',
          icon: Icons.phone_rounded,
          label: l.supportPhoneLabel,
          value: status.phone ?? '',
          verified: status.phoneVerified,
        ),
      ],
    );
  }
}

class _VerifiableRow extends ConsumerWidget {
  const _VerifiableRow({
    required this.channel,
    required this.icon,
    required this.label,
    required this.value,
    required this.verified,
  });

  final String channel; // 'email' | 'sms'
  final IconData icon;
  final String label;
  final String value;
  final bool verified;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    final hasValue = value.trim().isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _editContact(context, ref, channel: channel, current: value, label: label),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: LiquidGlassCard(
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(10),
                color: cs.primaryContainer,
                child: Center(
                  child: Icon(icon, size: 18, color: cs.onPrimaryContainer),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(width: 6),
                      if (hasValue) _VerifyBadge(verified: verified),
                    ],
                  ),
                  Text(
                    hasValue ? value : l.profileEmptyValue,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (hasValue && !verified)
              TextButton(
                onPressed: () => _verifyCurrent(context, ref, channel: channel),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(AppLocalizations.of(context)!.accountVerifyButton),
              )
            else
              Icon(Icons.edit_outlined, size: 16, color: cs.primary),
          ],
        ),
      ),
    );
  }
}

class _VerifyBadge extends StatelessWidget {
  const _VerifyBadge({required this.verified});
  final bool verified;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = verified ? cs.tertiary : cs.error;
    final bg = (verified ? cs.tertiary : cs.error).withValues(alpha: 0.12);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(verified ? Icons.verified_rounded : Icons.priority_high_rounded, size: 11, color: fg),
          const SizedBox(width: 3),
          Text(
            verified ? AppLocalizations.of(context)!.profileVerifiedShort : AppLocalizations.of(context)!.profileUnverified,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: fg),
          ),
        ],
      ),
    );
  }
}

Future<void> _verifyCurrent(BuildContext context, WidgetRef ref, {required String channel}) async {
  final notifier = ref.read(verifyControllerProvider.notifier);
  try {
    final target = await notifier.startVerify(channel);
    if (!context.mounted) return;
    await _showCodeSheet(
      context,
      ref,
      channel: channel,
      target: target,
      newValue: null,
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_humanizeError(e))));
  }
}

Future<void> _editContact(
  BuildContext context,
  WidgetRef ref, {
  required String channel,
  required String current,
  required String label,
}) async {
  final cs = Theme.of(context).colorScheme;
  final newValue = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: cs.surface,
    builder: (sCtx) => _ChangeContactSheet(
      channel: channel,
      label: label,
      current: current,
    ),
  );
  if (newValue == null || newValue.isEmpty) return;
  if (newValue.toLowerCase() == current.trim().toLowerCase()) return;

  final notifier = ref.read(verifyControllerProvider.notifier);
  try {
    final target = await notifier.startVerify(channel, newValue: newValue);
    if (!context.mounted) return;
    await _showCodeSheet(
      context,
      ref,
      channel: channel,
      target: target,
      newValue: newValue,
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_humanizeError(e))));
  }
}

Future<void> _showCodeSheet(
  BuildContext context,
  WidgetRef ref, {
  required String channel,
  required String target,
  required String? newValue,
}) async {
  final cs = Theme.of(context).colorScheme;
  final l = AppLocalizations.of(context)!;
  final codeCtrl = TextEditingController();
  bool submitting = false;
  String? error;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: cs.surface,
    builder: (sCtx) {
      return StatefulBuilder(builder: (ctx, setSt) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.profileEnterCodeTitle,
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                target.isNotEmpty
                    ? l.profileCodeSentTo(target)
                    : l.profileCodeSent,
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: codeCtrl,
                autofocus: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 8),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••••',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: TextStyle(color: cs.error, fontSize: 12)),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          setSt(() { submitting = true; error = null; });
                          try {
                            final changed = await ref
                                .read(verifyControllerProvider.notifier)
                                .confirmVerify(channel, code: codeCtrl.text, newValue: newValue);
                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(changed ? AppLocalizations.of(context)!.profileUpdatedPendingVerification : AppLocalizations.of(context)!.profileVerified)),
                            );
                            // Pull /auth/me so AuthSession's cached email stays in sync.
                            if (changed) {
                              await ref.read(authSessionProvider).reloadFromMe();
                            }
                          } catch (e) {
                            setSt(() { submitting = false; error = _humanizeError(e); });
                          }
                        },
                  child: submitting
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(AppLocalizations.of(ctx)!.accountConfirmButton),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          setSt(() => error = null);
                          try {
                            await ref
                                .read(verifyControllerProvider.notifier)
                                .startVerify(channel, newValue: newValue);
                            if (!ctx.mounted) return;
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(ctx)!.accountCodeResent)),
                            );
                          } catch (e) {
                            setSt(() => error = _humanizeError(e));
                          }
                        },
                  child: Text(AppLocalizations.of(ctx)!.accountResendCode),
                ),
              ),
            ],
          ),
        );
      });
    },
  );
}

String _humanizeError(Object e) {
  final s = e.toString();
  // Pull the server's `message` out of common "Exception: 400: { ... }" wrappers.
  final m = RegExp(r'"message":"([^"]+)"').firstMatch(s);
  if (m != null) return m.group(1)!;
  return s.replaceFirst(RegExp(r'^Exception: '), '');
}

/// Change-email / change-phone sheet. Uses PhoneField (with dial-code
/// picker) when the channel is 'sms' so the user gets the same input ergonomics
/// the rest of the app uses; falls back to a plain TextField for 'email'.
class _ChangeContactSheet extends StatefulWidget {
  const _ChangeContactSheet({
    required this.channel,
    required this.label,
    required this.current,
  });
  final String channel;
  final String label;
  final String current;

  @override
  State<_ChangeContactSheet> createState() => _ChangeContactSheetState();
}

class _ChangeContactSheetState extends State<_ChangeContactSheet> {
  late final TextEditingController _ctrl;
  late String _dialCode;

  @override
  void initState() {
    super.initState();
    if (widget.channel == 'sms') {
      // Pre-fill the local digits, NOT the full E.164 — PhoneField shows
      // the country chip separately. Use splitE164 to extract.
      final split = splitE164(widget.current);
      _dialCode = split.dialCode;
      _ctrl = TextEditingController(text: split.localDigits);
    } else {
      _dialCode = kDefaultDialCode;
      _ctrl = TextEditingController(text: widget.current);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String? _resolveValue() {
    if (widget.channel == 'sms') {
      return joinE164(_dialCode, _ctrl.text);
    }
    final t = _ctrl.text.trim();
    return t.isEmpty ? null : t;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.profileChangeContact(widget.label),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            widget.current.isEmpty
                ? l.profileVerifyNewContactInfo
                : l.profileVerifyCurrentContactInfo(widget.label),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          if (widget.channel == 'sms')
            PhoneField(
              controller: _ctrl,
              dialCode: _dialCode,
              onDialCodeChanged: (v) => setState(() => _dialCode = v),
              labelText: AppLocalizations.of(context)!.profileNewPhone,
              helperText: null,
              autofocus: true,
            )
          else
            TextField(
              controller: _ctrl,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.profileNewEmail,
                hintText: 'name@example.com',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.commonCancel)),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  final v = _resolveValue();
                  if (v == null || v.isEmpty) return;
                  Navigator.pop(context, v);
                },
                child: Text(AppLocalizations.of(context)!.accountContinueButton),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Biometric sign-in section ────────────────────────────────────────────────

/// Lets the user turn Face ID / fingerprint sign-in on or off, the same way the
/// phone's own settings enroll each. Turning one on confirms the account
/// password (verified against the server) once, then stores the credentials in
/// the Keychain/Keystore behind a biometric challenge so the login screen can
/// reuse them. Hidden entirely on devices with no enrolled biometrics.
class _BiometricSection extends ConsumerStatefulWidget {
  const _BiometricSection();

  @override
  ConsumerState<_BiometricSection> createState() => _BiometricSectionState();
}

class _BiometricSectionState extends ConsumerState<_BiometricSection> {
  bool _supported = false;
  Set<BiometricMethod> _enabled = const {};
  bool _loaded = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bio = ref.read(biometricServiceProvider);
    final supported = await bio.deviceSupported();
    final enabled = await bio.enabledMethods();
    if (!mounted) return;
    setState(() {
      _supported = supported;
      _enabled = enabled;
      _loaded = true;
    });
  }

  Future<void> _toggle(BiometricMethod m, bool on) async {
    if (_busy) return;
    final l = AppLocalizations.of(context)!;
    final bio = ref.read(biometricServiceProvider);
    setState(() => _busy = true);
    try {
      if (!on) {
        await bio.disableMethod(m);
        await _load();
        return;
      }
      final session = ref.read(authSessionProvider);
      final identifier =
          session.email.isNotEmpty ? session.email : session.username;
      // Reuse stored credentials when another method is already on; otherwise
      // confirm the account password first.
      final existing = await bio.readCredentials();
      String id;
      String pw;
      if (existing != null) {
        id = existing.identifier;
        pw = existing.password;
      } else {
        if (!mounted) return;
        final entered = await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => _ConfirmPasswordSheet(identifier: identifier),
        );
        if (entered == null || !mounted) return;
        id = identifier;
        pw = entered;
      }
      // A live biometric challenge confirms the sensor works and it's them.
      final ok = await bio.authenticate(l.biometricEnableReason);
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.biometricEnrollFailed)),
          );
        }
        return;
      }
      await bio.enableMethod(m, identifier: id, password: pw);
      await _load();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show on any device that can do a biometric/device-credential challenge.
    // BOTH switches always appear (Face ID + Fingerprint) so the user can set
    // up either — the OS uses whichever sensor the device actually has.
    if (!_loaded || !_supported) return const SizedBox.shrink();
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      child: _Section(
        title: l.biometricSectionTitle,
        icon: Icons.fingerprint_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.biometricSectionSubtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(Icons.face_rounded, color: cs.primary),
              title: Text(l.biometricFaceId),
              subtitle: Text(l.biometricFaceIdDesc),
              value: _enabled.contains(BiometricMethod.face),
              onChanged: _busy ? null : (v) => _toggle(BiometricMethod.face, v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(Icons.fingerprint_rounded, color: cs.primary),
              title: Text(l.biometricFingerprint),
              subtitle: Text(l.biometricFingerprintDesc),
              value: _enabled.contains(BiometricMethod.fingerprint),
              onChanged:
                  _busy ? null : (v) => _toggle(BiometricMethod.fingerprint, v),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet that confirms the account password by signing in against the
/// server, returning the verified password to the caller (or null).
class _ConfirmPasswordSheet extends ConsumerStatefulWidget {
  const _ConfirmPasswordSheet({required this.identifier});
  final String identifier;

  @override
  ConsumerState<_ConfirmPasswordSheet> createState() =>
      _ConfirmPasswordSheetState();
}

class _ConfirmPasswordSheetState extends ConsumerState<_ConfirmPasswordSheet> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context)!;
    final pw = _ctrl.text.trim();
    if (pw.isEmpty) {
      setState(() => _error = l.biometricPasswordIncorrect);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final api = CMApi();
    try {
      final raw = await api.postJson('/auth/login',
          body: {'identifier': widget.identifier, 'password': pw});
      final token = (raw is Map ? raw['token'] : null)?.toString().trim() ?? '';
      if (!mounted) return;
      if (token.isEmpty) {
        setState(() {
          _loading = false;
          _error = l.biometricPasswordIncorrect;
        });
        return;
      }
      Navigator.of(context).pop(pw);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = l.biometricPasswordIncorrect;
      });
    } finally {
      api.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fingerprint_rounded, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                l.biometricConfirmPasswordTitle,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l.biometricConfirmPasswordBody,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          _PasswordField(controller: _ctrl, hint: l.loginPasswordLabel, autofocus: true),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: cs.error, fontSize: 12.5)),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(l.biometricEnrollYes),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.controller,
    required this.hint,
    this.autofocus = false,
  });
  final TextEditingController controller;
  final String hint;
  final bool autofocus;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: widget.controller,
      autofocus: widget.autofocus,
      obscureText: _obscure,
      decoration: InputDecoration(
        hintText: widget.hint,
        filled: true,
        fillColor: cs.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            size: 20,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}

