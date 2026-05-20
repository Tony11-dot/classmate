// ignore_for_file: use_build_context_synchronously
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../ui/widgets/attachment_pill.dart';
import '../data/teacher_mobile_repository.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title required')));
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final title =
        widget.courseName.isNotEmpty ? widget.courseName : 'Add Assignment';

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded, size: 18),
              label: const Text('Create'),
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
            Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: cs.outlineVariant),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assignment Details',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  TextFormField(
                    controller: _titleCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Instructions
                  TextFormField(
                    controller: _bodyCtrl,
                    minLines: 3,
                    maxLines: 8,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Instructions (optional)',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Due date picker
                  InkWell(
                    borderRadius: BorderRadius.circular(4),
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
                        labelText: 'Due date (optional)',
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.calendar_today_rounded,
                          color: cs.primary,
                        ),
                        suffixIcon: _dueDate != null
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                tooltip: 'Clear due date',
                                onPressed: () =>
                                    setState(() => _dueDate = null),
                              )
                            : null,
                      ),
                      child: Text(
                        _dueDate != null
                            ? DateFormat.yMMMd(locale).format(_dueDate!)
                            : 'Due date (optional)',
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
                    title: const Text(
                      'Notify students',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),

                  // Attachments
                  if (_attachments.isNotEmpty) ...[
                    AttachmentPills(attachments: _attachments),
                    const SizedBox(height: 8),
                  ],
                  OutlinedButton.icon(
                    onPressed: _uploading ? null : _pickFiles,
                    icon: _uploading
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.attach_file_rounded, size: 18),
                    label: Text(_uploading
                        ? 'Uploading…'
                        : _attachments.isEmpty
                            ? 'Attach files'
                            : 'Add more files'),
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
