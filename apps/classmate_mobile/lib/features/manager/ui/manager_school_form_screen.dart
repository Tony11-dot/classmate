import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/cm_tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/widgets/cm_loading.dart';
import '../../../core/http/server_messages.dart';
import '../../../l10n/app_localizations.dart';
import '../data/manager_api.dart';

import '../../../ui/widgets/cm_sub_bar.dart';
/// Create-school form — the in-app replacement for the old /cms "Create" tab.
class ManagerSchoolFormScreen extends ConsumerStatefulWidget {
  const ManagerSchoolFormScreen({super.key});

  @override
  ConsumerState<ManagerSchoolFormScreen> createState() =>
      _ManagerSchoolFormScreenState();
}

class _ManagerSchoolFormScreenState
    extends ConsumerState<ManagerSchoolFormScreen> {
  final _name = TextEditingController();
  final _gradeRanges = TextEditingController(text: '7-12');
  final _semesters = TextEditingController();
  final _subjectInput = TextEditingController();
  final _adminName = TextEditingController();
  final _adminUsername = TextEditingController();
  final _adminEmail = TextEditingController();
  final _adminPassword = TextEditingController();

  final List<String> _subjects = [];
  String? _logoUrl;
  bool _uploadingLogo = false;
  bool _submitting = false;
  bool _showPassword = false;

  @override
  void dispose() {
    for (final c in [
      _name,
      _gradeRanges,
      _semesters,
      _subjectInput,
      _adminName,
      _adminUsername,
      _adminEmail,
      _adminPassword,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  ManagerApi get _api => ref.read(managerApiProvider);

  void _snack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _pickLogo() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    final f = (res != null && res.files.isNotEmpty) ? res.files.first : null;
    if (f == null || f.bytes == null) return;
    setState(() => _uploadingLogo = true);
    try {
      final url = await _api.uploadLogoBytes(f.bytes!, f.name);
      setState(() => _logoUrl = url);
    } catch (e) {
      if (mounted) _snack(AppLocalizations.of(context)!.managerLogoUploadFailed('$e'));
    } finally {
      if (mounted) setState(() => _uploadingLogo = false);
    }
  }

  void _addSubject() {
    final v = _subjectInput.text.trim();
    if (v.isEmpty) return;
    setState(() {
      _subjects.add(v);
      _subjectInput.clear();
    });
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context)!;
    if (_name.text.trim().isEmpty) return _snack(l.managerSchoolNameRequired);
    if (_adminName.text.trim().isEmpty) {
      return _snack(l.managerAdminNameRequired);
    }
    if (_adminEmail.text.trim().isEmpty && _adminUsername.text.trim().isEmpty) {
      return _snack(l.managerAdminContactRequired);
    }
    if (_adminPassword.text.trim().length < 6) {
      return _snack(l.managerPasswordTooShort);
    }

    setState(() => _submitting = true);
    try {
      final body = <String, dynamic>{
        'schoolName': _name.text.trim(),
        if (_logoUrl != null) 'logoUrl': _logoUrl,
        'gradeRanges': _gradeRanges.text.trim(),
        if (_semesters.text.trim().isNotEmpty)
          'semesters': _semesters.text.trim(),
        if (_subjects.isNotEmpty)
          'subjects': _subjects.map((s) => {'nameEn': s}).toList(),
        'adminName': _adminName.text.trim(),
        if (_adminEmail.text.trim().isNotEmpty)
          'adminEmail': _adminEmail.text.trim(),
        if (_adminUsername.text.trim().isNotEmpty)
          'adminUsername': _adminUsername.text.trim(),
        'adminPassword': _adminPassword.text.trim(),
      };
      final res = await _api.createSchool(body);
      if (res['ok'] == true) {
        if (!mounted) return;
        // Toast first: the root messenger keeps it visible on the list after the pop.
        _snack(l.managerSchoolCreated(_name.text.trim()));
        Navigator.pop(context, true);
      } else {
        _snack(l.commonFailedWith(
            localizeServerMessage('${res['message'] ?? ''}', l) ?? '${res['message'] ?? res}'));
      }
    } catch (e) {
      _snack('$e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CmSubBar(title: l.managerNewSchool),
      body: AbsorbPointer(
        absorbing: _submitting,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _card(
              context,
              title: l.navSchool,
              icon: Icons.apartment_rounded,
              children: [
                TextField(
                  controller: _name,
                  decoration: InputDecoration(labelText: '${l.managerSchoolName} *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _gradeRanges,
                  decoration: InputDecoration(
                    labelText: '${l.managerGradeRanges} *',
                    helperText: l.managerGradeRangesHelper,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _semesters,
                  decoration: InputDecoration(
                    labelText: l.managerSemestersOptional,
                    helperText: l.managerSemestersHelper,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _uploadingLogo ? null : _pickLogo,
                      icon: _uploadingLogo
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CmLoading(size: 16),
                            )
                          : Icon(_logoUrl == null ? Icons.image_rounded : Icons.check_rounded),
                      label: Text(
                        _logoUrl == null ? l.managerUploadLogo : l.managerLogoUploaded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            _card(
              context,
              title: l.managerSubjectsOptional,
              icon: Icons.menu_book_rounded,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _subjectInput,
                        decoration: InputDecoration(
                          labelText: l.managerSubjectEnglish,
                        ),
                        onSubmitted: (_) => _addSubject(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      tooltip: l.commonAdd,
                      onPressed: _addSubject,
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
                if (_subjects.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _subjects
                          .map(
                            (s) => Chip(
                              label: Text(s),
                              onDeleted: () =>
                                  setState(() => _subjects.remove(s)),
                            ),
                          )
                          .toList(),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            _card(
              context,
              title: l.managerAdminAccount,
              icon: Icons.admin_panel_settings_rounded,
              children: [
                TextField(
                  controller: _adminName,
                  decoration: InputDecoration(labelText: '${l.adminFullNameLabel} *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _adminUsername,
                  decoration: InputDecoration(labelText: l.profileUsername),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _adminEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: l.commonEmail),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _adminPassword,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: '${l.commonPassword} *',
                    helperText: l.managerPasswordHelper,
                    suffixIcon: IconButton(
                      tooltip: _showPassword ? l.commonHidePassword : l.commonShowPassword,
                      icon: Icon(
                        _showPassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                      ),
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CmLoading(size: 20, color: Colors.white),
                    )
                  : Text(l.managerCreateSchool),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(CmTokens.radiusXl),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.35),
          width: 0.8,
        ),
        boxShadow: CmTokens.of(context).shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(
                    alpha: cs.brightness == Brightness.dark ? 0.22 : 0.12,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 17, color: cs.primary),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
