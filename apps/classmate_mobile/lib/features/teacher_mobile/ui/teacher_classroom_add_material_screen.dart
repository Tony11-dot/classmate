// ignore_for_file: use_build_context_synchronously
import 'package:classmate_mobile/core/theme/cm_tokens.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/cm_surfaces.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../data/teacher_mobile_repository.dart';

import '../../../ui/widgets/cm_sub_bar.dart';
class TeacherClassroomAddMaterialScreen extends ConsumerStatefulWidget {
  const TeacherClassroomAddMaterialScreen({
    super.key,
    required this.courseId,
    this.courseName = '',
  });

  final String courseId;
  final String courseName;

  @override
  ConsumerState<TeacherClassroomAddMaterialScreen> createState() =>
      _TeacherClassroomAddMaterialScreenState();
}

class _TeacherClassroomAddMaterialScreenState
    extends ConsumerState<TeacherClassroomAddMaterialScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  String? _url;
  PlatformFile? _pickedFile;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _pickedFile = file;
          _url = file.path ?? file.name;
          _urlCtrl.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.teacherFilePickError(e.toString()))),
        );
      }
    }
  }


  /// Guess MIME type from file extension.
  String? _guessMime(String name) {
    final ext = name.split('.').last.toLowerCase();
    const map = {
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'ppt': 'application/vnd.ms-powerpoint',
      'pptx':
          'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'xls': 'application/vnd.ms-excel',
      'xlsx':
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'txt': 'text/plain',
      'png': 'image/png',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'gif': 'image/gif',
      'mp4': 'video/mp4',
      'mp3': 'audio/mpeg',
      'zip': 'application/zip',
    };
    return map[ext];
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.commonTitleRequired)),
      );
      return;
    }
    final typedUrl = _urlCtrl.text.trim();
    if ((_url == null || _url!.trim().isEmpty) && typedUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.teacherMaterialContentRequired)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      // If only a URL was typed (no file picked), use it directly.
      String resolvedUrl = _pickedFile != null ? (_url ?? '').trim() : typedUrl;
      if (_pickedFile != null && (_pickedFile!.path?.isNotEmpty == true)) {
        final result = await ref.read(teacherMobileRepositoryProvider)
            .uploadAttachmentFile(_pickedFile!.path!, _pickedFile!.name);
        final uploadedUrl = (result['url'] ?? result['fileUrl'] ?? '').toString().trim();
        if (uploadedUrl.isNotEmpty) resolvedUrl = uploadedUrl;
      }

      final mime = _pickedFile != null ? _guessMime(_pickedFile!.name) : null;
      await ref.read(teacherMobileRepositoryProvider).createClassroomMaterial(
            courseId: widget.courseId,
            title: title,
            url: resolvedUrl,
            description: _descCtrl.text.trim().isEmpty
                ? null
                : _descCtrl.text.trim(),
            mime: mime,
          );
      if (context.mounted) context.pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;


    return Scaffold(
      backgroundColor: cs.surface,
      appBar: CmSubBar(
        onBack: () => context.pop(),
        title: AppLocalizations.of(context)!.teacherShareMaterialTitle,
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const CmLoading(size: 16)
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(AppLocalizations.of(context)!.teacherShareButton),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Material Details ───────────────────────────────────────────
            CmCard(
              radius: CmTokens.radiusXl,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CmFormSectionHeader(
                    icon: Icons.edit_note_rounded,
                    title: AppLocalizations.of(context)!.teacherMaterialDetails,
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _titleCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.teacherMaterialTitleLabel,
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.teacherMaterialDescriptionLabel,
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── File / Link ────────────────────────────────────────────────
            CmCard(
              radius: CmTokens.radiusXl,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CmFormSectionHeader(
                    icon: Icons.attach_file_rounded,
                    title: AppLocalizations.of(context)!.teacherMaterialContentSection,
                  ),
                  const SizedBox(height: 14),

                  // Attached file row
                  if (_pickedFile != null) ...[
                    CmFileRow(
                      name: _pickedFile!.name,
                      removeTooltip: l.a11yRemove,
                      onRemove: () => setState(() { _pickedFile = null; _url = null; }),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // URL input (shown when no file is attached)
                  if (_pickedFile == null) ...[
                    TextField(
                      controller: _urlCtrl,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.teacherMaterialLinkUrlOptional,
                        hintText: 'https://...',
                        prefixIcon: const Icon(Icons.link_rounded),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  OutlinedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.file_upload_outlined, size: 18),
                    label: Text(_pickedFile != null
                        ? AppLocalizations.of(context)!.commonReplaceFile
                        : AppLocalizations.of(context)!.commonAttachFile),
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
