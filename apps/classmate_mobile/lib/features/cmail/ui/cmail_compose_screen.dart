// ignore_for_file: use_build_context_synchronously
import 'package:classmate_mobile/ui/widgets/cm_press.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../../ui/widgets/cm_loading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/cm_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/cm_surfaces.dart';
import '../../../ui/widgets/liquid_glass_dropdown.dart';
import '../../../ui/widgets/student_multi_select_sheet.dart';
import '../data/cmail_api.dart';
import '../../../ui/widgets/cm_sub_bar.dart';
import 'cmail_screen.dart' show cmailAudienceLabel;

/// Compose a CMail: liquid-glass audience DDL (+ glass multi-select sheets
/// for grades / classes / people), subject, body, and file attachments.
class CMailComposeScreen extends ConsumerStatefulWidget {
  const CMailComposeScreen({super.key});

  @override
  ConsumerState<CMailComposeScreen> createState() =>
      _CMailComposeScreenState();
}

class _CMailComposeScreenState extends ConsumerState<CMailComposeScreen> {
  final TextEditingController _subjectCtl = TextEditingController();
  final TextEditingController _bodyCtl = TextEditingController();

  String? _audience;
  final Set<int> _grades = {};
  final Set<String> _cohortIds = {};
  final Set<String> _userIds = {};
  final List<CMailAttachment> _attachments = [];
  bool _uploading = false;
  bool _sending = false;

  @override
  void dispose() {
    _subjectCtl.dispose();
    _bodyCtl.dispose();
    super.dispose();
  }

  Future<void> _pickSubAudience(String audience, CMailDdl ddl) async {
    final l = AppLocalizations.of(context)!;
    switch (audience) {
      case 'GRADES':
        final picked = await showStudentMultiSelectSheet(
          context: context,
          title: l.cmailPickGrades,
          items: [
            for (final g in ddl.grades)
              MultiSelectItem(id: '$g', name: l.solutionsGradeLabel(g)),
          ],
          initiallySelected: _grades.map((g) => '$g').toSet(),
          requireSelection: true,
        );
        if (picked != null) {
          setState(() {
            _grades
              ..clear()
              ..addAll(picked.map(int.parse));
          });
        }
        break;
      case 'COHORTS':
        final picked = await showStudentMultiSelectSheet(
          context: context,
          title: l.cmailPickCohorts,
          items: [
            for (final c in ddl.cohorts)
              MultiSelectItem(
                id: c.id,
                name: c.name,
                subtitle:
                    c.grade != null ? l.solutionsGradeLabel(c.grade!) : null,
              ),
          ],
          initiallySelected: _cohortIds,
          requireSelection: true,
        );
        if (picked != null) {
          setState(() {
            _cohortIds
              ..clear()
              ..addAll(picked);
          });
        }
        break;
      case 'USERS':
        final picked = await showStudentMultiSelectSheet(
          context: context,
          title: l.cmailPickPeople,
          items: [
            for (final p in ddl.people)
              MultiSelectItem(
                id: p.id,
                name: p.name,
                subtitle: p.grade != null
                    ? '${p.role} · ${l.solutionsGradeLabel(p.grade!)}'
                    : p.role,
              ),
          ],
          initiallySelected: _userIds,
          requireSelection: true,
        );
        if (picked != null) {
          setState(() {
            _userIds
              ..clear()
              ..addAll(picked);
          });
        }
        break;
    }
  }

  Future<void> _attach() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    setState(() => _uploading = true);
    final api = ref.read(cmailApiProvider);
    try {
      for (final f in result.files) {
        if (_attachments.length >= 10) break;
        // On web file_picker can hand back a non-null blob path that dart:io
        // can't open ("Unsupported operation", web QA #83) — so upload from
        // bytes on web and only use the path on mobile.
        final hasPath = !kIsWeb && (f.path ?? '').isNotEmpty;
        final uploaded = await api.uploadAttachment(
          hasPath ? f.path : null,
          fileName: f.name,
          bytes: hasPath ? null : f.bytes,
        );
        if (uploaded.url.isNotEmpty) {
          setState(() => _attachments.add(uploaded));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  String _selectionSummary(AppLocalizations l, CMailDdl? ddl) {
    switch (_audience) {
      case 'GRADES':
        return _grades.isEmpty
            ? ''
            : (_grades.toList()..sort())
                .map((g) => l.solutionsGradeLabel(g))
                .join(', ');
      case 'COHORTS':
        if (ddl == null || _cohortIds.isEmpty) return '';
        return ddl.cohorts
            .where((c) => _cohortIds.contains(c.id))
            .map((c) => c.name)
            .join(', ');
      case 'USERS':
        if (ddl == null || _userIds.isEmpty) return '';
        final names = ddl.people
            .where((p) => _userIds.contains(p.id))
            .map((p) => p.name)
            .toList();
        return names.length <= 3
            ? names.join(', ')
            : '${names.take(3).join(', ')} +${names.length - 3}';
      default:
        return '';
    }
  }

  bool _audienceReady() {
    return switch (_audience) {
      null => false,
      'GRADES' => _grades.isNotEmpty,
      'COHORTS' => _cohortIds.isNotEmpty,
      'USERS' => _userIds.isNotEmpty,
      _ => true,
    };
  }

  Future<void> _send() async {
    final l = AppLocalizations.of(context)!;
    if (_subjectCtl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.cmailSubjectRequired)));
      return;
    }
    if (!_audienceReady()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.cmailAudienceRequired)));
      return;
    }
    setState(() => _sending = true);
    try {
      await ref.read(cmailApiProvider).send(
            subject: _subjectCtl.text.trim(),
            body: _bodyCtl.text,
            audience: _audience!,
            grades: _grades.toList()..sort(),
            cohortIds: _cohortIds.toList(),
            userIds: _userIds.toList(),
            attachments: _attachments,
          );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.cmailSentOk)));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final ddlAsync = ref.watch(cmailDdlProvider);
    final ddl = ddlAsync.asData?.value;
    final needsSub = _audience == 'GRADES' ||
        _audience == 'COHORTS' ||
        _audience == 'USERS';
    final summary = _selectionSummary(l, ddl);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CmSubBar(
        title: l.cmailCompose,
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: FilledButton.icon(
              onPressed: (_sending || _uploading) ? null : _send,
              icon: _sending
                  ? const CmLoading(size: 16)
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(l.cmailSendAction),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          children: [
            // ── Recipients ──
            CmCard(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LiquidGlassSelectField<String>(
                    label: l.cmailAudience,
                    hint: l.cmailAudienceRequired,
                    value: _audience,
                    items: [
                      for (final a in const [
                        'SCHOOL',
                        'STUDENTS',
                        'TEACHERS',
                        'PARENTS',
                        'STAFF',
                        'GRADES',
                        'COHORTS',
                        'USERS',
                      ])
                        LiquidGlassDropdownItem(
                          value: a,
                          label: cmailAudienceLabel(l, a),
                          icon: _audienceIcon(a),
                        ),
                    ],
                    onChanged: (v) async {
                      setState(() => _audience = v);
                      if ((v == 'GRADES' || v == 'COHORTS' || v == 'USERS') &&
                          ddl != null) {
                        await _pickSubAudience(v, ddl);
                      }
                    },
                  ),
                  if (needsSub) ...[
                    const SizedBox(height: 8),
                    CmPress(
                      onTap: ddl == null
                          ? null
                          : () => _pickSubAudience(_audience!, ddl),
                      child: Container(
                        padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 10, 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(CmTokens.radiusSm),
                          color: summary.isEmpty
                              ? CmTokens.of(context).warn.withValues(alpha: cs.brightness == Brightness.dark ? 0.18 : 0.10)
                              : cs.primary.withValues(alpha: cs.brightness == Brightness.dark ? 0.18 : 0.08),
                        ),
                        child: Row(
                          children: [
                            CmIconTile(
                              icon: _audienceIcon(_audience!),
                              size: 34,
                              color: summary.isEmpty ? CmTokens.of(context).warn : cs.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                summary.isEmpty
                                    ? switch (_audience) {
                                        'GRADES' => l.cmailPickGrades,
                                        'COHORTS' => l.cmailPickCohorts,
                                        _ => l.cmailPickPeople,
                                      }
                                    : summary,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: summary.isEmpty ? cs.onSurfaceVariant : cs.onSurface,
                                  fontWeight: summary.isEmpty ? FontWeight.w600 : FontWeight.w700,
                                ),
                              ),
                            ),
                            Icon(Icons.tune_rounded, size: 20, color: cs.onSurfaceVariant),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Letter: subject, body, attachments ──
            CmCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _subjectCtl,
                    textInputAction: TextInputAction.next,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    decoration: InputDecoration(
                      hintText: l.cmailSubject,
                      filled: false,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                    ),
                  ),
                  Divider(height: 1, indent: 16, endIndent: 16, color: cs.outlineVariant.withValues(alpha: 0.5)),
                  TextField(
                    controller: _bodyCtl,
                    minLines: 9,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
                    decoration: InputDecoration(
                      hintText: l.cmailBodyHint,
                      filled: false,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    ),
                  ),
                  if (_attachments.isNotEmpty) ...[
                    Divider(height: 1, indent: 16, endIndent: 16, color: cs.outlineVariant.withValues(alpha: 0.5)),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 4, 0),
                      child: Column(
                        children: [
                          for (var i = 0; i < _attachments.length; i++)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                children: [
                                  CmIconTile(
                                    icon: _fileIcon(_attachments[i].fileName),
                                    size: 36,
                                    color: cs.tertiary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _attachments[i].fileName?.isNotEmpty == true
                                          ? _attachments[i].fileName!
                                          : l.cmailAttachments,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  CmIconAction(
                                    icon: Icons.close_rounded,
                                    tooltip: l.commonRemove,
                                    onPressed: () => setState(() => _attachments.removeAt(i)),
                                    color: cs.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                    child: Row(
                      children: [
                        TextButton.icon(
                          onPressed: _uploading ? null : _attach,
                          icon: _uploading
                              ? const CmLoading(size: 16)
                              : const Icon(Icons.attach_file_rounded, size: 20),
                          label: Text(l.cmailAttach),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _audienceIcon(String a) => switch (a) {
        'SCHOOL' => Icons.school_rounded,
        'STUDENTS' => Icons.backpack_rounded,
        'TEACHERS' => Icons.co_present_rounded,
        'PARENTS' => Icons.family_restroom_rounded,
        'STAFF' => Icons.badge_rounded,
        'GRADES' => Icons.grade_rounded,
        'COHORTS' => Icons.groups_rounded,
        _ => Icons.person_search_rounded,
      };

  static IconData _fileIcon(String? name) {
    final n = (name ?? '').toLowerCase();
    if (n.endsWith('.pdf')) return Icons.picture_as_pdf_rounded;
    if (n.endsWith('.png') || n.endsWith('.jpg') || n.endsWith('.jpeg') || n.endsWith('.webp') || n.endsWith('.heic')) {
      return Icons.image_rounded;
    }
    return Icons.insert_drive_file_rounded;
  }
}
