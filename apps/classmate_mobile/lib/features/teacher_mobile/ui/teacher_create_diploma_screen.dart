// ignore_for_file: use_build_context_synchronously
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../ui/widgets/cm_loading.dart';

class TeacherCreateDiplomaScreen extends ConsumerStatefulWidget {
  const TeacherCreateDiplomaScreen({super.key});

  @override
  ConsumerState<TeacherCreateDiplomaScreen> createState() =>
      _TeacherCreateDiplomaScreenState();
}

class _TeacherCreateDiplomaScreenState
    extends ConsumerState<TeacherCreateDiplomaScreen> {
  // ── Student selection ─────────────────────────────────────────────────────
  List<TeacherStudentWithLevel> _allStudents = [];
  TeacherStudentWithLevel? _selected;
  bool _loadingStudents = true;
  String _query = '';

  // ── Certificate fields ────────────────────────────────────────────────────
  final _titleCtrl = TextEditingController(text: 'Certificate of Achievement');

  // ── Attachments: each entry is {title, url, localPath} ───────────────────
  // localPath is the on-device path; url starts as the same but gets replaced
  // with the CDN URL after upload. We keep localPath so we can show the file
  // name without making another network call.
  final List<Map<String, dynamic>> _attachments = [];
  bool _uploading = false;

  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadStudents);
  }

  Future<void> _loadStudents() async {
    setState(() => _loadingStudents = true);
    try {
      final students =
          await ref.read(teacherMobileRepositoryProvider).fetchAllStudents();
      if (!mounted) return;
      setState(() {
        _allStudents = students;
        _loadingStudents = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingStudents = false);
    }
  }

  List<TeacherStudentWithLevel> get _filteredStudents {
    if (_query.isEmpty) return _allStudents;
    final q = _query.toLowerCase();
    return _allStudents.where((s) {
      if (s.name.toLowerCase().contains(q)) return true;
      if (s.gradeLevel != null && 'grade ${s.gradeLevel}'.contains(q)) {
        return true;
      }
      if (s.cohortName.toLowerCase().contains(q)) return true;
      return false;
    }).toList();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );
    if (result == null || !mounted) return;

    // Add picked files immediately (shown as pending), then upload each one.
    final newEntries = result.files
        .where((f) => (f.path ?? '').isNotEmpty)
        .map((f) => {'title': f.name, 'url': f.path!, 'localPath': f.path!})
        .toList();
    if (newEntries.isEmpty) return;
    setState(() { _attachments.addAll(newEntries); _uploading = true; });

    final repo = ref.read(teacherMobileRepositoryProvider);
    for (final entry in newEntries) {
      try {
        final res = await repo.uploadAttachmentFile(entry['localPath']!, entry['title']!);
        final cdnUrl = (res['url'] ?? res['fileUrl'] ?? '').toString().trim();
        if (cdnUrl.isNotEmpty && mounted) {
          setState(() {
            final idx = _attachments.indexOf(entry);
            if (idx >= 0) _attachments[idx] = {'title': entry['title']!, 'url': cdnUrl};
          });
        }
      } catch (_) {}
    }
    if (mounted) setState(() => _uploading = false);
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.teacherDiplomaSelectStudent)),
      );
      return;
    }
    if (_uploading) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.teacherDiplomaUploadingWait)),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      // Only send attachments with real (non-local) URLs
      final readyAttachments = _attachments
          .where((a) {
            final url = (a['url'] ?? '').toString();
            return url.isNotEmpty && !url.startsWith('/') && !url.startsWith('file:');
          })
          .map((a) => {'title': a['title'] ?? '', 'url': a['url'] ?? ''})
          .toList();
      await ref.read(teacherMobileRepositoryProvider).createDiploma({
        'studentId': _selected!.studentId,
        'studentName': _selected!.name,
        'title': _titleCtrl.text.trim().isEmpty ? 'Certificate of Achievement' : _titleCtrl.text.trim(),
        'attachments': readyAttachments,
      });
      if (!mounted) return;
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.teacherDiplomaIssueFailed(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final filtered = _filteredStudents;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Issue Certificate',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.workspace_premium_rounded, size: 18),
              label: Text(_saving ? AppLocalizations.of(context)!.teacherDiplomaIssuing : AppLocalizations.of(context)!.teacherDiplomaIssue),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Certificate fields ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                TextField(
                  controller: _titleCtrl,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.teacherDiplomaCertTitleLabel,
                    prefixIcon: const Icon(Icons.workspace_premium_rounded, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          // ── Search bar ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.teacherDiplomaSearchStudent,
                prefixIcon:
                    const Icon(Icons.search_rounded, size: 20),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 14),
              ),
            ),
          ),

          // ── Student list ─────────────────────────────────────────────
          Expanded(
            child: _loadingStudents
                ? const Center(child: CmLoading())
                : filtered.isEmpty
                    ? Center(
                        child: Text(AppLocalizations.of(context)!.teacherClassroomNoStudentsFound,
                            style: TextStyle(
                                color: cs.onSurfaceVariant)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) {
                          final s = filtered[i];
                          final isSelected =
                              _selected?.studentId == s.studentId;
                          final gradeLabel = s.gradeLevel != null
                              ? 'Grade ${s.gradeLevel}${s.cohortName.isNotEmpty ? " · ${s.cohortName}" : ""}'
                              : s.cohortName;
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () =>
                                  setState(() => _selected = s),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 2),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? cs.primaryContainer
                                          .withValues(alpha: 0.55)
                                      : Colors.transparent,
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  border: isSelected
                                      ? Border.all(
                                          color: cs.primary
                                              .withValues(alpha: 0.3))
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? cs.primary
                                            : cs.surfaceContainerHighest
                                                .withValues(alpha: 0.6),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          s.name.isNotEmpty
                                              ? s.name[0].toUpperCase()
                                              : '?',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                            color: isSelected
                                                ? cs.onPrimary
                                                : cs.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            s.name,
                                            style: theme
                                                .textTheme.bodyMedium
                                                ?.copyWith(
                                              fontWeight:
                                                  FontWeight.w700,
                                              color: isSelected
                                                  ? cs.primary
                                                  : null,
                                            ),
                                          ),
                                          if (gradeLabel.isNotEmpty)
                                            Text(gradeLabel,
                                                style: theme.textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                        color: cs
                                                            .onSurfaceVariant)),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(Icons.check_circle_rounded,
                                          color: cs.primary, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // ── Attachments panel ────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              border: Border(
                  top: BorderSide(
                      color: cs.outlineVariant)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_attachments.isNotEmpty) ...[
                  ...List.generate(_attachments.length, (i) {
                    final att = _attachments[i];
                    final url = (att['url'] ?? '').toString();
                    final isLocal = url.startsWith('/') || url.startsWith('file:');
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          if (isLocal)
                            SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
                            )
                          else
                            Icon(Icons.check_circle_rounded, size: 18, color: cs.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              (att['title'] ?? '').toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: isLocal ? cs.onSurfaceVariant : cs.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isLocal)
                            IconButton(
                              icon: Icon(Icons.close_rounded, size: 16, color: cs.error),
                              onPressed: () => setState(() => _attachments.removeAt(i)),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                            ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 4),
                ],
                OutlinedButton.icon(
                  onPressed: _uploading ? null : _pickFiles,
                  icon: const Icon(Icons.attach_file_rounded, size: 16),
                  label: Text(_attachments.isEmpty
                      ? 'Attach certificate file(s)'
                      : 'Add more files'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
