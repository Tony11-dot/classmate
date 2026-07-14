import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/widgets/cm_loading.dart';
import '../data/manager_api.dart';

/// Create-school form — the in-app replacement for the old /cms "Create" tab.
class ManagerSchoolFormScreen extends ConsumerStatefulWidget {
  const ManagerSchoolFormScreen({super.key});

  @override
  ConsumerState<ManagerSchoolFormScreen> createState() => _ManagerSchoolFormScreenState();
}

class _ManagerSchoolFormScreenState extends ConsumerState<ManagerSchoolFormScreen> {
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
    for (final c in [_name, _gradeRanges, _semesters, _subjectInput, _adminName, _adminUsername, _adminEmail, _adminPassword]) {
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
    final res = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    final f = (res != null && res.files.isNotEmpty) ? res.files.first : null;
    if (f == null || f.bytes == null) return;
    setState(() => _uploadingLogo = true);
    try {
      final url = await _api.uploadLogoBytes(f.bytes!, f.name);
      setState(() => _logoUrl = url);
    } catch (e) {
      _snack('Logo upload failed: $e');
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
    if (_name.text.trim().isEmpty) return _snack('School name is required.');
    if (_adminName.text.trim().isEmpty) return _snack('Admin full name is required.');
    if (_adminEmail.text.trim().isEmpty && _adminUsername.text.trim().isEmpty) {
      return _snack('Admin email or username is required.');
    }
    if (_adminPassword.text.trim().length < 6) return _snack('Password must be at least 6 characters.');

    setState(() => _submitting = true);
    try {
      final body = <String, dynamic>{
        'schoolName': _name.text.trim(),
        if (_logoUrl != null) 'logoUrl': _logoUrl,
        'gradeRanges': _gradeRanges.text.trim(),
        if (_semesters.text.trim().isNotEmpty) 'semesters': _semesters.text.trim(),
        if (_subjects.isNotEmpty) 'subjects': _subjects.map((s) => {'nameEn': s}).toList(),
        'adminName': _adminName.text.trim(),
        if (_adminEmail.text.trim().isNotEmpty) 'adminEmail': _adminEmail.text.trim(),
        if (_adminUsername.text.trim().isNotEmpty) 'adminUsername': _adminUsername.text.trim(),
        'adminPassword': _adminPassword.text.trim(),
      };
      final res = await _api.createSchool(body);
      if (res['ok'] == true) {
        if (!mounted) return;
        Navigator.pop(context, true);
        _snack('School "${_name.text.trim()}" created.');
      } else {
        _snack('Failed: ${res['message'] ?? res}');
      }
    } catch (e) {
      _snack('$e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New school')),
      body: AbsorbPointer(
        absorbing: _submitting,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section('School'),
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'School name *')),
            const SizedBox(height: 12),
            TextField(
              controller: _gradeRanges,
              decoration: const InputDecoration(
                labelText: 'Grade ranges *',
                helperText: 'e.g. 7-12, or 4-6,9-12 for gaps',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _semesters,
              decoration: const InputDecoration(
                labelText: 'Semesters (optional)',
                helperText: 'Start-end months, e.g. 9-1,2-6',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _uploadingLogo ? null : _pickLogo,
                  icon: _uploadingLogo
                      ? const SizedBox(width: 16, height: 16, child: CmLoading(size: 16))
                      : const Icon(Icons.image_rounded),
                  label: Text(_logoUrl == null ? 'Upload logo' : 'Logo uploaded ✓'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _section('Subjects (optional)'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subjectInput,
                    decoration: const InputDecoration(labelText: 'Subject (English)'),
                    onSubmitted: (_) => _addSubject(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(onPressed: _addSubject, icon: const Icon(Icons.add_rounded)),
              ],
            ),
            if (_subjects.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _subjects
                      .map((s) => Chip(
                            label: Text(s),
                            onDeleted: () => setState(() => _subjects.remove(s)),
                          ))
                      .toList(),
                ),
              ),
            const SizedBox(height: 20),
            _section('Admin account'),
            TextField(controller: _adminName, decoration: const InputDecoration(labelText: 'Full name *')),
            const SizedBox(height: 12),
            TextField(controller: _adminUsername, decoration: const InputDecoration(labelText: 'Username')),
            const SizedBox(height: 12),
            TextField(controller: _adminEmail, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(
              controller: _adminPassword,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: 'Password *',
                helperText: 'Min 6 characters',
                suffixIcon: IconButton(
                  icon: Icon(_showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(height: 20, width: 20, child: CmLoading(size: 20, color: Colors.white))
                  : const Text('Create school'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.4)),
      );
}
