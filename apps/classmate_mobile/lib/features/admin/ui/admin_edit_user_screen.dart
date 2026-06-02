// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/liquid_glass_dropdown.dart';
import '../../../ui/widgets/phone_field.dart';
import '../data/admin_repository.dart';

class AdminEditUserScreen extends ConsumerStatefulWidget {
  const AdminEditUserScreen({super.key, required this.userId, required this.repo});
  final String userId;
  final AdminRepository repo;

  @override
  ConsumerState<AdminEditUserScreen> createState() => _AdminEditUserScreenState();
}

class _AdminEditUserScreenState extends ConsumerState<AdminEditUserScreen> {
  // Name fields
  final _nameEnCtrl   = TextEditingController();
  final _nameArCtrl   = TextEditingController();
  final _nameHeCtrl   = TextEditingController();
  final _nameFrCtrl   = TextEditingController();
  final _nameRuCtrl   = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  String  _dialCode = kDefaultDialCode;

  String? _role;
  int?    _grade;
  /// Cohorts the student is currently a member of (by name + grade).
  /// Populated alongside _loadUser. Empty for non-student roles.
  List<Map<String, dynamic>> _cohorts = const [];
  bool    _loading = true;
  bool    _saving  = false;
  bool    _resetting = false;

  // Parent linking (PARENT role)
  List<Map<String, dynamic>> _children  = [];
  List<Map<String, dynamic>> _allStudents = [];
  bool _loadingChildren = false;
  bool _showAddChild = false;
  String? _linkStudentId;

  static const _roles      = ['STUDENT', 'TEACHER', 'SECRETARY', 'PARENT', 'ADMIN'];
  static const _roleLabels = ['Student', 'Teacher', 'Secretary', 'Parent', 'Admin'];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    for (final c in [_nameEnCtrl, _nameArCtrl, _nameHeCtrl, _nameFrCtrl, _nameRuCtrl, _emailCtrl, _usernameCtrl, _phoneCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadUser() async {
    try {
      final m = await widget.repo.getUserDetailRaw(widget.userId);
      _nameEnCtrl.text   = m['nameEn']?.toString() ?? m['name']?.toString() ?? '';
      _nameArCtrl.text   = m['nameAr']?.toString() ?? '';
      _nameHeCtrl.text   = m['nameHe']?.toString() ?? '';
      _nameFrCtrl.text   = m['nameFr']?.toString() ?? '';
      _nameRuCtrl.text   = m['nameRu']?.toString() ?? '';
      _emailCtrl.text    = m['email']?.toString() ?? '';
      _usernameCtrl.text = m['username']?.toString() ?? '';
      // Split the stored E.164 phone into dial-code + local digits so the
      // PhoneField shows the right country chip on first paint.
      final phoneRaw = m['phone']?.toString() ?? '';
      if (phoneRaw.isNotEmpty) {
        final split = splitE164(phoneRaw);
        _dialCode = split.dialCode;
        _phoneCtrl.text = split.localDigits;
      }
      final roles = m['roles'];
      _role  = (roles is List && roles.isNotEmpty) ? roles.first.toString() : null;
      _grade = m['grade'] is num ? (m['grade'] as num).toInt() : null;
      final cohorts = m['cohorts'];
      if (cohorts is List) {
        _cohorts = cohorts
            .whereType<Map>()
            .map((c) => Map<String, dynamic>.from(c))
            .toList();
      }
      if (mounted) setState(() => _loading = false);

      // If parent, load children
      if (_role == 'PARENT') _loadChildren();
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadChildren() async {
    setState(() => _loadingChildren = true);
    try {
      final children = await widget.repo.getUserChildren(widget.userId);
      final students  = await widget.repo.getDdlStudents();
      if (mounted) setState(() { _children = children; _allStudents = students; });
    } catch (_) {} finally {
      if (mounted) setState(() => _loadingChildren = false);
    }
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    final nameEn = _nameEnCtrl.text.trim();
    if (nameEn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.adminEditUserEnglishNameRequired)));
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.repo.updateUser(
        widget.userId,
        nameEn: nameEn,
        nameAr: _nameArCtrl.text.trim().isEmpty ? '' : _nameArCtrl.text.trim(),
        nameHe: _nameHeCtrl.text.trim().isEmpty ? '' : _nameHeCtrl.text.trim(),
        nameFr: _nameFrCtrl.text.trim().isEmpty ? '' : _nameFrCtrl.text.trim(),
        nameRu: _nameRuCtrl.text.trim().isEmpty ? '' : _nameRuCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? '' : _emailCtrl.text.trim(),
        username: _usernameCtrl.text.trim().isEmpty ? '' : _usernameCtrl.text.trim(),
        phone: joinE164(_dialCode, _phoneCtrl.text) ?? '',
        role: _role,
        grade: _grade,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.adminEditUserSaved)));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changePassword() async {
    final newPassword = await showDialog<String>(
      context: context,
      builder: (d) => const _SetPasswordDialog(),
    );
    if (newPassword == null) return;

    setState(() => _resetting = true);
    try {
      await widget.repo.setUserPassword(widget.userId, newPassword);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.adminEditUserPasswordChanged(_nameEnCtrl.text))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _resetting = false);
    }
  }

  Future<void> _addChild() async {
    if (_linkStudentId == null || _linkStudentId!.isEmpty) return;
    try {
      await widget.repo.linkParent(parentId: widget.userId, studentId: _linkStudentId!);
      if (!mounted) return;
      setState(() { _showAddChild = false; _linkStudentId = null; });
      await _loadChildren();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _removeChild(String childId) async {
    try {
      await widget.repo.unlinkChild(widget.userId, childId);
      if (!mounted) return;
      await _loadChildren();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget _langField(TextEditingController ctrl, String label, {bool req = false}) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: req ? '$label *' : label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(label.split(' ').last, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant, fontWeight: FontWeight.w700)),
          ),
          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l     = AppLocalizations.of(context)!;

    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final isParent = _role == 'PARENT';
    final isStudent = _role == 'STUDENT';

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_edit_user',
        onPressed: _saving ? null : _save,
        icon: _saving
            ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.check_rounded),
        label: Text(l.adminSave),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                children: [
                  // ── Back chevron + title — no AppBar, so this header is
                  // the only visual way back.
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
                      Expanded(
                        child: Text(
                          _nameEnCtrl.text.trim().isEmpty ? l.adminEditUser : _nameEnCtrl.text.trim(),
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // ── Login credentials ──────────────────────────────────────
                  Text(l.adminEditUserLoginSection, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _usernameCtrl,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: l.adminEditUserUsernameLabel,
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
                      labelText: l.adminEditUserEmailOptional,
                      prefixIcon: const Icon(Icons.email_rounded, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PhoneField(
                    controller: _phoneCtrl,
                    dialCode: _dialCode,
                    onDialCodeChanged: (v) => setState(() => _dialCode = v),
                  ),
                  const SizedBox(height: 8),
                  // Reset password
                  OutlinedButton.icon(
                    onPressed: _resetting ? null : _changePassword,
                    icon: _resetting ? const SizedBox.square(dimension: 14, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.lock_reset_rounded, size: 16),
                    label: Text(l.adminEditUserChangePassword),
                    style: OutlinedButton.styleFrom(foregroundColor: cs.error, side: BorderSide(color: cs.error.withValues(alpha: 0.5))),
                  ),
                  const SizedBox(height: 20),

                  // ── Name fields ────────────────────────────────────────────
                  Text(l.adminEditUserNameSection, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
                  const SizedBox(height: 4),
                  Text(l.adminEditUserAtLeastEnglish, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 12),
                  _langField(_nameEnCtrl, l.nameInEnglish, req: true),
                  _langField(_nameArCtrl, l.nameInArabic),
                  _langField(_nameHeCtrl, l.nameInHebrew),
                  _langField(_nameFrCtrl, l.nameInFrench),
                  _langField(_nameRuCtrl, l.nameInRussian),
                  const SizedBox(height: 20),

                  // ── Role ───────────────────────────────────────────────────
                  Text(l.adminRoleLabel, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: List.generate(_roles.length, (i) => ChoiceChip(
                      label: Text(_roleLabels[i]),
                      selected: _role == _roles[i],
                      onSelected: (_) => setState(() { _role = _roles[i]; if (_role != 'STUDENT') _grade = null; }),
                    )),
                  ),

                  // ── Grade (students) ───────────────────────────────────────
                  if (isStudent) ...[
                    const SizedBox(height: 20),
                    Text(l.adminEditUserGradeSection, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: ref.watch(authSessionProvider).schoolGrades.map((g) => ChoiceChip(
                        label: Text(l.adminCohortGradeFormat(g.toString())),
                        selected: _grade == g,
                        onSelected: (_) => setState(() => _grade = g),
                      )).toList(),
                    ),
                    const SizedBox(height: 20),
                    // ── Cohorts the student is in ───────────────────────────
                    Text(l.adminEditUserCohortsSection,
                        style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
                    const SizedBox(height: 4),
                    Text(
                      _cohorts.isEmpty
                          ? l.adminNotInAnyCohort
                          : 'Member of ${_cohorts.length} cohort${_cohorts.length == 1 ? '' : 's'}.',
                      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    if (_cohorts.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _cohorts.map((c) {
                          final name = c['name']?.toString() ?? '';
                          final grade = (c['grade'] as num?)?.toInt();
                          final gradesRaw = c['grades'];
                          final grades = gradesRaw is List
                              ? gradesRaw.map((e) => (e as num).toInt()).toList()
                              : (grade != null ? [grade] : const <int>[]);
                          final gradeLabel = grades.length <= 1
                              ? (grades.isEmpty ? '' : 'G${grades.first}')
                              : (() {
                                  final sorted = [...grades]..sort();
                                  final isRange = sorted.last - sorted.first == sorted.length - 1;
                                  return isRange ? 'G${sorted.first}-${sorted.last}' : 'G${sorted.join(',')}';
                                })();
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: cs.primaryContainer.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.groups_rounded, size: 14, color: cs.primary),
                                const SizedBox(width: 6),
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: cs.onPrimaryContainer,
                                    fontSize: 12,
                                  ),
                                ),
                                if (gradeLabel.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    '· $gradeLabel',
                                    style: TextStyle(
                                      color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],

                  // ── Parent: children linking ───────────────────────────────
                  if (isParent) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: Text(l.adminEditUserLinkedChildren, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.primary))),
                        TextButton.icon(
                          onPressed: () => setState(() => _showAddChild = !_showAddChild),
                          icon: Icon(_showAddChild ? Icons.close_rounded : Icons.add_rounded, size: 16),
                          label: Text(_showAddChild ? l.commonCancel : l.adminLinkChild),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (_showAddChild) ...[
                      LiquidGlassDropdown<String>(
                        label: l.adminSelectStudentToLink,
                        value: _linkStudentId ?? '',
                        searchHint: 'Search students…',
                        items: [
                          LiquidGlassDropdownItem(value: '', label: l.adminChooseStudentDash),
                          ..._allStudents.map((s) {
                            final name = s['name']?.toString() ?? '';
                            final grade = (s['grade'] as num?)?.toInt();
                            // Grade is more useful than cohort here — admin
                            // is picking a child to link to a parent, and
                            // grade is the meaningful disambiguator.
                            final suffix = grade != null ? ' (Grade $grade)' : '';
                            return LiquidGlassDropdownItem(
                              value: s['id']?.toString() ?? '',
                              label: '$name$suffix',
                            );
                          }),
                        ],
                        onChanged: (v) => setState(() => _linkStudentId = v.isEmpty ? null : v),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: _linkStudentId != null ? _addChild : null,
                        icon: const Icon(Icons.link_rounded, size: 16),
                        label: Text(l.adminEditUserLinkButton),
                      ),
                      const SizedBox(height: 10),
                    ],

                    _loadingChildren
                        ? const Center(child: CircularProgressIndicator())
                        : _children.isEmpty
                            ? Text(l.adminEditUserNoChildren, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant))
                            : Column(
                                children: _children.map((c) {
                                  final child = c['child'] as Map? ?? const {};
                                  final childId = child['id']?.toString() ?? '';
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: cs.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                                      ),
                                      child: ListTile(
                                        dense: true,
                                        leading: const Icon(Icons.person_rounded, size: 18),
                                        title: Text(child['name']?.toString() ?? child['nameEn']?.toString() ?? ''),
                                        subtitle: Text(child['email']?.toString() ?? child['username']?.toString() ?? ''),
                                        trailing: IconButton(
                                          icon: Icon(Icons.link_off_rounded, size: 18, color: cs.error),
                                          onPressed: () => _removeChild(childId),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
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

/// Modal that asks the admin to type a new password (with confirm). Returns
/// the typed password via Navigator.pop, or null if the admin cancels.
class _SetPasswordDialog extends StatefulWidget {
  const _SetPasswordDialog();

  @override
  State<_SetPasswordDialog> createState() => _SetPasswordDialogState();
}

class _SetPasswordDialogState extends State<_SetPasswordDialog> {
  final _pw1 = TextEditingController();
  final _pw2 = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _pw1.dispose();
    _pw2.dispose();
    super.dispose();
  }

  void _submit() {
    final l = AppLocalizations.of(context)!;
    final p1 = _pw1.text;
    final p2 = _pw2.text;
    if (p1.length < 8) {
      setState(() => _error = l.passwordMinChars);
      return;
    }
    if (p1 != p2) {
      setState(() => _error = l.passwordsDoNotMatch);
      return;
    }
    Navigator.pop(context, p1);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l.adminEditUserSetPasswordTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pw1,
            obscureText: _obscure,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l.adminEditUserNewPasswordLabel,
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pw2,
            obscureText: _obscure,
            decoration: InputDecoration(labelText: l.adminEditUserConfirmPasswordLabel),
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
          ],
          const SizedBox(height: 8),
          Text(
            l.adminPasswordChangeWarning,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.commonCancel)),
        FilledButton(onPressed: _submit, child: Text(l.adminEditUserSetPasswordButton)),
      ],
    );
  }
}

