import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_session.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/glass/liquid_glass_card.dart';
import 'profile_controller.dart';

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
    final schoolInfo = session.schoolId.isNotEmpty ? session.schoolId : l.profileNotAvailable;
    final cohortInfo = session.cohortId.isNotEmpty ? session.cohortId : l.profileNotAvailable;
    final resolvedEmail = profile.email.isNotEmpty ? profile.email : session.email;

    final displayName = session.displayName.isNotEmpty
        ? session.displayName
        : roleLabel;
    final initials = displayName
        .trim()
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return CustomScrollView(
      slivers: [
        // ── Avatar header ────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: LiquidGlassCard(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              borderRadius: BorderRadius.circular(24),
              blurSigma: 18,
              gradient: LinearGradient(
                colors: [cs.primaryContainer, cs.surfaceContainerHigh],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.22)),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: cs.primary.withValues(alpha: 0.18),
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: cs.primary,
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
                        if (profile.username.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            '@${profile.username}',
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
                            if (session.schoolId.isNotEmpty)
                              _Badge(label: session.schoolId, icon: Icons.location_city_rounded),
                            if (session.cohortId.isNotEmpty)
                              _Badge(label: session.cohortId, icon: Icons.groups_rounded),
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
                  const _Divider(),
                  _InfoRow(
                    icon: Icons.groups_rounded,
                    label: l.profileCohortId,
                    value: cohortInfo,
                    locked: true,
                  ),
                ],
              ),
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
                    value: profile.username.isEmpty ? l.profileEmptyValue : '@${profile.username}',
                    onEdit: () => _editField(
                      context: context,
                      title: l.profileUsername,
                      icon: Icons.alternate_email_rounded,
                      hint: l.profileUsernameHint,
                      initial: profile.username,
                      onSave: pc.setUsername,
                    ),
                  ),
                  const _Divider(),
                  _InfoRow(
                    icon: Icons.email_outlined,
                    label: l.profileContactEmail,
                    value: resolvedEmail.isEmpty ? l.profileEmptyValue : resolvedEmail,
                    onEdit: () => _editField(
                      context: context,
                      title: l.profileEmailAddress,
                      icon: Icons.email_outlined,
                      hint: l.profileEmailHint,
                      initial: resolvedEmail,
                      keyboardType: TextInputType.emailAddress,
                      onSave: pc.setEmail,
                    ),
                  ),
                  const _Divider(),
                  _InfoRow(
                    icon: Icons.cake_rounded,
                    label: l.profileBirthday,
                    value: _formatBirthday(context, profile.birthday),
                    onEdit: () => _pickBirthday(context, profile.birthday, pc),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Security ──────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
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
      ],
    );
  }

  // ── Edit helpers ───────────────────────────────────────────────────────────

  String _formatBirthday(BuildContext context, String? raw) {
    if (raw == null || raw.isEmpty) return AppLocalizations.of(context)!.profileEmptyValue;
    try {
      final d = DateTime.parse(raw);
      return MaterialLocalizations.of(context).formatMediumDate(d);
    } catch (_) {
      return raw;
    }
  }

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
    if (result != null && context.mounted) await onSave(result);
  }

  Future<void> _pickBirthday(
    BuildContext context,
    String? current,
    ProfileController pc,
  ) async {
    final initial = current != null
        ? DateTime.tryParse(current) ?? DateTime(2005)
        : DateTime(2005);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
      helpText: AppLocalizations.of(context)!.profileSelectBirthday,
    );
    if (picked != null) {
      await pc.setBirthday(
        '${picked.year.toString().padLeft(4, '0')}-'
        '${picked.month.toString().padLeft(2, '0')}-'
        '${picked.day.toString().padLeft(2, '0')}',
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
        _error = switch (err) {
          profilePasswordErrorNotAuthenticated => l.profilePasswordNotAuthenticated,
          profilePasswordErrorWrongPassword => l.profilePasswordIncorrect,
          _ => l.profilePasswordGenericError,
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
              blurSigma: 10,
              color: cs.errorContainer.withValues(alpha: 0.5),
              border: Border.all(color: cs.error.withValues(alpha: 0.14)),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withValues(alpha: 0.2),
            cs.surface.withValues(alpha: 0.52),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary.withValues(alpha: 0.14)),
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
      blurSigma: 14,
      color: cs.surfaceContainerLow.withValues(alpha: 0.78),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
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
      ).colorScheme.outlineVariant.withValues(alpha: 0.4),
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
                blurSigma: 8,
                color: (locked
                        ? cs.surfaceContainerHigh
                        : cs.primary.withValues(alpha: 0.1))
                    .withValues(alpha: 0.86),
                child: Center(
                  child: Icon(
                    icon,
                    size: 18,
                    color: locked ? cs.onSurfaceVariant : cs.primary,
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

