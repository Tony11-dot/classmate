import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_session.dart';
import '../../core/auth/name_lang.dart';
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
    final schoolInfo = session.schoolName.isNotEmpty ? session.schoolName : (session.schoolId.isNotEmpty ? session.schoolId : l.profileNotAvailable);
    final cohortInfo = session.cohortName.isNotEmpty ? session.cohortName : (session.cohortId.isNotEmpty ? session.cohortId : l.profileNotAvailable);
    final resolvedEmail = profile.email.isNotEmpty ? profile.email : session.email;

    final displayName = session.displayName.isNotEmpty
        ? session.displayName
        : roleLabel;
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
                            if (session.schoolName.isNotEmpty)
                              _Badge(label: session.schoolName, icon: Icons.location_city_rounded),
                            if (session.cohortName.isNotEmpty)
                              _Badge(label: session.cohortName, icon: Icons.groups_rounded)
                            else if (session.cohortId.isNotEmpty)
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

        // ── Name in languages ─────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: _Section(
              title: l.profileNamesTitle,
              icon: Icons.translate_rounded,
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.text_fields_rounded,
                    label: 'English',
                    value: session.nameEn.isEmpty ? l.profileEmptyValue : session.nameEn,
                    onEdit: () => _editNameLang(context, session, 'en', 'English', session.nameEn),
                  ),
                  const _Divider(),
                  _InfoRow(
                    icon: Icons.text_fields_rounded,
                    label: 'عربي',
                    value: session.nameAr.isEmpty ? l.profileEmptyValue : session.nameAr,
                    onEdit: () => _editNameLang(context, session, 'ar', 'عربي', session.nameAr),
                  ),
                  const _Divider(),
                  _InfoRow(
                    icon: Icons.text_fields_rounded,
                    label: 'עברית',
                    value: session.nameHe.isEmpty ? l.profileEmptyValue : session.nameHe,
                    onEdit: () => _editNameLang(context, session, 'he', 'עברית', session.nameHe),
                  ),
                  const _Divider(),
                  _InfoRow(
                    icon: Icons.text_fields_rounded,
                    label: 'Français',
                    value: session.nameFr.isEmpty ? l.profileEmptyValue : session.nameFr,
                    onEdit: () => _editNameLang(context, session, 'fr', 'Français', session.nameFr),
                  ),
                  const _Divider(),
                  _InfoRow(
                    icon: Icons.text_fields_rounded,
                    label: 'Русский',
                    value: session.nameRu.isEmpty ? l.profileEmptyValue : session.nameRu,
                    onEdit: () => _editNameLang(context, session, 'ru', 'Русский', session.nameRu),
                  ),
                  const _Divider(),
                  // Display language preference
                  _InfoRow(
                    icon: Icons.language_rounded,
                    label: l.profileDisplayNameLang,
                    value: _langLabel(session.displayNameLang, l),
                    onEdit: () => _pickDisplayLang(context, session),
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

  // Static helper — no instance context needed
  static String _langLabel(String lang, AppLocalizations l) {
    return NameLang.fromCode(lang)?.nativeName ?? l.profileEmptyValue;
  }

  static Future<void> _editNameLang(BuildContext context, AuthSession session, String lang, String label, String current) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _EditSheet(
        title: 'Name in $label',
        icon: Icons.translate_rounded,
        hint: 'Full name in $label',
        initial: current,
      ),
    );
    if (result == null) return;
    switch (lang) {
      case 'en': await session.updateNameFields(nameEn: result);
      case 'ar': await session.updateNameFields(nameAr: result);
      case 'he': await session.updateNameFields(nameHe: result);
      case 'fr': await session.updateNameFields(nameFr: result);
      case 'ru': await session.updateNameFields(nameRu: result);
    }
  }

  static Future<void> _pickDisplayLang(BuildContext context, AuthSession session) async {
    final l = AppLocalizations.of(context)!;
    final langs = [
      (code: '', label: l.profileEmptyValue, icon: Icons.translate_rounded),
      ...NameLang.values.map((lang) => (code: lang.code, label: lang.nativeName, icon: Icons.language_rounded)),
    ];
    final cs = Theme.of(context).colorScheme;
    final picked = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 36, height: 4, decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text(l.profileDisplayNameLang, style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              ...langs.map((lang) => ListTile(
                leading: Icon(lang.icon),
                title: Text(lang.label),
                selected: session.displayNameLang == lang.code || (lang.code.isEmpty && session.displayNameLang.isEmpty),
                selectedColor: cs.primary,
                onTap: () => Navigator.of(ctx).pop(lang.code),
              )),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (picked == null) return;
    await session.updateNameFields(displayNameLang: picked);
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

