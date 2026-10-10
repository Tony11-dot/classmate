// ignore_for_file: use_build_context_synchronously
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/util/friendly_date.dart';
import '../../../core/theme/cm_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/cm_surfaces.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../data/teacher_mobile_repository.dart';

import '../../../ui/widgets/cm_sub_bar.dart';
class TeacherClassroomAddAssignmentScreen extends ConsumerStatefulWidget {
  const TeacherClassroomAddAssignmentScreen({
    super.key,
    required this.courseId,
    this.courseName = '',
  });

  final String courseId;
  final String courseName;

  @override
  ConsumerState<TeacherClassroomAddAssignmentScreen> createState() =>
      _TeacherClassroomAddAssignmentScreenState();
}

class _TeacherClassroomAddAssignmentScreenState
    extends ConsumerState<TeacherClassroomAddAssignmentScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final List<Map<String, dynamic>> _attachments = [];
  DateTime? _dueDate;
  bool _notify = true;
  bool _saving = false;
  bool _uploading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: true);
    if (result == null || result.files.isEmpty) return;
    setState(() => _uploading = true);
    final repo = ref.read(teacherMobileRepositoryProvider);
    for (final file in result.files) {
      final path = file.path ?? '';
      if (path.isEmpty) continue;
      try {
        final uploaded = await repo.uploadAttachmentFile(path, file.name);
        final url = (uploaded['url'] ?? uploaded['fileUrl'] ?? '').toString().trim();
        if (url.isNotEmpty) setState(() => _attachments.add({'name': file.name, 'url': url, 'type': 'file'}));
      } catch (_) {}
    }
    if (mounted) setState(() => _uploading = false);
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.commonTitleRequired)));
      return;
    }
    setState(() => _saving = true);
    try {
      final dateIso = _dueDate?.toIso8601String();
      await ref.read(teacherMobileRepositoryProvider).createClassroomAssignment(
        courseId: widget.courseId,
        title: title,
        body: _bodyCtrl.text.trim().isEmpty ? null : _bodyCtrl.text.trim(),
        dueAt: dateIso,
        attachments: _attachments,
      );
      if (context.mounted) context.pop(true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final title = widget.courseName.isNotEmpty
        ? widget.courseName
        : l.teacherClassroomAddAssignmentScreenTitle;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: CmSubBar(
        onBack: () => context.pop(),
        title: title,
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const CmLoading(size: 16)
                  : const Icon(Icons.check_rounded, size: 18),
              label: Text(AppLocalizations.of(context)!.teacherCreateAssignment),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Assignment Details ─────────────────────────────────────────
            CmCard(
              radius: CmTokens.radiusXl,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CmFormSectionHeader(
                    icon: Icons.edit_note_rounded,
                    title: l.teacherClassroomAddAssignmentScreenDetails,
                  ),
                  const SizedBox(height: 14),

                  // Title
                  TextFormField(
                    controller: _titleCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.teacherAssignmentTitleField,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Instructions
                  TextFormField(
                    controller: _bodyCtrl,
                    minLines: 3,
                    maxLines: 8,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.teacherAssignmentInstructions,
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Due date picker
                  InkWell(
                    borderRadius: BorderRadius.circular(CmTokens.radiusMd),
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _dueDate ?? now,
                        firstDate: now,
                        lastDate: now.add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => _dueDate = picked);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.teacherAssignmentDueDate,
                        prefixIcon: Icon(
                          Icons.calendar_today_rounded,
                          color: cs.primary,
                        ),
                        suffixIcon: _dueDate != null
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                tooltip: AppLocalizations.of(context)!.teacherAssignmentClearDueDate,
                                onPressed: () =>
                                    setState(() => _dueDate = null),
                              )
                            : null,
                      ),
                      child: Text(
                        _dueDate != null
                            ? FriendlyDate.date(_dueDate!)
                            : '—',
                        style: TextStyle(
                          color: _dueDate != null
                              ? cs.onSurface
                              : cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Notify toggle
                  SwitchListTile(
                    value: _notify,
                    onChanged: (v) => setState(() => _notify = v),
                    title: Text(
                      l.teacherClassroomAddAssignmentScreenNotifyStudents,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),

                  // Attachments
                  for (var i = 0; i < _attachments.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: CmFileRow(
                        name: (_attachments[i]['name'] ?? '').toString(),
                        removeTooltip: l.a11yRemove,
                        onRemove: () => setState(() => _attachments.removeAt(i)),
                      ),
                    ),
                  if (_attachments.isNotEmpty) const SizedBox(height: 2),
                  OutlinedButton.icon(
                    onPressed: _uploading ? null : _pickFiles,
                    icon: _uploading
                        ? const CmLoading(size: 16)
                        : const Icon(Icons.attach_file_rounded, size: 18),
                    label: Text(_uploading
                        ? l.teacherClassroomAddAssignmentScreenUploading
                        : _attachments.isEmpty
                            ? l.teacherClassroomAddAssignmentScreenAttachFiles
                            : l.teacherClassroomAddAssignmentScreenAddMoreFiles),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
