// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/liquid_glass_dropdown.dart';
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

  String? _role;
  int?    _grade;
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
  static const _grades     = [5, 6, 7, 8, 9, 10, 11, 12];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    for (final c in [_nameEnCtrl, _nameArCtrl, _nameHeCtrl, _nameFrCtrl, _nameRuCtrl, _emailCtrl, _usernameCtrl]) {
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
      final roles = m['roles'];
      _role  = (roles is List && roles.isNotEmpty) ? roles.first.toString() : null;
      _grade = m['grade'] is num ? (m['grade'] as num).toInt() : null;
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
    final nameEn = _nameEnCtrl.text.trim();
    if (nameEn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('English name required')));
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
        role: _role,
        grade: _grade,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _resetPassword() async {
    setState(() => _resetting = true);
    try {
      final temp = await widget.repo.resetUserPassword(widget.userId);
      if (!mounted) return;
      final l = AppLocalizations.of(context)!;
      await showDialog(
        context: context,
        builder: (d) => AlertDialog(
          title: Text(l.adminPasswordReset),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New temporary password for ${_nameEnCtrl.text}:'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(d).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(temp, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () { Clipboard.setData(ClipboardData(text: temp)); ScaffoldMessenger.of(d).showSnackBar(SnackBar(content: Text(l.adminCopied))); },
              child: const Text('Copy'),
            ),
            FilledButton(onPressed: () => Navigator.pop(d), child: const Text('Done')),
          ],
        ),
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
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                children: [
                  // ── Login credentials ──────────────────────────────────────
                  Text('Login', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _usernameCtrl,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: 'Username',
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
                  const SizedBox(height: 8),
                  // Reset password
                  OutlinedButton.icon(
                    onPressed: _resetting ? null : _resetPassword,
                    icon: _resetting ? const SizedBox.square(dimension: 14, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.lock_reset_rounded, size: 16),
                    label: Text(l.adminResetPassword),
                    style: OutlinedButton.styleFrom(foregroundColor: cs.error, side: BorderSide(color: cs.error.withValues(alpha: 0.5))),
                  ),
                  const SizedBox(height: 20),

                  // ── Name fields ────────────────────────────────────────────
                  Text('Name', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
                  const SizedBox(height: 4),
                  Text('At least English required.', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 12),
                  _langField(_nameEnCtrl, 'Name in English', req: true),
                  _langField(_nameArCtrl, 'Name in Arabic (اسم)'),
                  _langField(_nameHeCtrl, 'Name in Hebrew (שם)'),
                  _langField(_nameFrCtrl, 'Name in French'),
                  _langField(_nameRuCtrl, 'Name in Russian'),
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

                  // ── Parent: children linking ───────────────────────────────
                  if (isParent) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: Text('Linked Children', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.primary))),
                        TextButton.icon(
                          onPressed: () => setState(() => _showAddChild = !_showAddChild),
                          icon: Icon(_showAddChild ? Icons.close_rounded : Icons.add_rounded, size: 16),
                          label: Text(_showAddChild ? 'Cancel' : 'Link Child'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (_showAddChild) ...[
                      LiquidGlassDropdown<String>(
                        label: 'Select student to link',
                        value: _linkStudentId ?? '',
                        searchHint: 'Search students…',
                        items: [
                          const LiquidGlassDropdownItem(value: '', label: '— Choose student —'),
                          ..._allStudents.map((s) => LiquidGlassDropdownItem(
                            value: s['id']?.toString() ?? '',
                            label: '${s['name']?.toString() ?? ''} (${s['cohortName']?.toString() ?? 'no cohort'})',
                          )),
                        ],
                        onChanged: (v) => setState(() => _linkStudentId = v.isEmpty ? null : v),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: _linkStudentId != null ? _addChild : null,
                        icon: const Icon(Icons.link_rounded, size: 16),
                        label: const Text('Link'),
                      ),
                      const SizedBox(height: 10),
                    ],

                    _loadingChildren
                        ? const Center(child: CircularProgressIndicator())
                        : _children.isEmpty
                            ? Text('No children linked yet.', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant))
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
