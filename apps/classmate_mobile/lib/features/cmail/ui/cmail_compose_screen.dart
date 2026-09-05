// ignore_for_file: use_build_context_synchronously
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../ui/widgets/cm_loading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/liquid_glass_dropdown.dart';
import '../../../ui/widgets/student_multi_select_sheet.dart';
import '../data/cmail_api.dart';
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
        final uploaded = await api.uploadAttachment(
          f.path,
          fileName: f.name,
          bytes: f.path == null ? f.bytes : null,
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
      appBar: AppBar(
        title: Text(l.cmailCompose,
            style: const TextStyle(fontWeight: FontWeight.w800)),
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
                    icon: switch (a) {
                      'SCHOOL' => Icons.school_rounded,
                      'STUDENTS' => Icons.backpack_rounded,
                      'TEACHERS' => Icons.co_present_rounded,
                      'PARENTS' => Icons.family_restroom_rounded,
                      'STAFF' => Icons.badge_rounded,
                      'GRADES' => Icons.grade_rounded,
                      'COHORTS' => Icons.groups_rounded,
                      _ => Icons.person_search_rounded,
                    },
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
              InkWell(
                onTap: ddl == null
                    ? null
                    : () => _pickSubAudience(_audience!, ddl),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: cs.surfaceContainerLow,
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.tune_rounded,
                          size: 18, color: cs.onSurfaceVariant),
                      const SizedBox(width: 8),
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
                            color: summary.isEmpty
                                ? cs.onSurfaceVariant
                                : cs.onSurface,
                            fontWeight: summary.isEmpty
                                ? FontWeight.w500
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                      Icon(Icons.expand_more_rounded,
                          color: cs.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            TextField(
              controller: _subjectCtl,
              textInputAction: TextInputAction.next,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
              decoration: InputDecoration(
                hintText: l.cmailSubject,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bodyCtl,
              minLines: 8,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: l.cmailBodyHint,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _uploading ? null : _attach,
                  icon: _uploading
                      ? const CmLoading(size: 16)
                      : const Icon(Icons.attach_file_rounded, size: 18),
                  label: Text(l.cmailAttach),
                ),
              ],
            ),
            if (_attachments.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < _attachments.length; i++)
                    InputChip(
                      avatar: const Icon(Icons.insert_drive_file_rounded,
                          size: 16),
                      label: Text(
                        _attachments[i].fileName?.isNotEmpty == true
                            ? _attachments[i].fileName!
                            : l.cmailAttachments,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onDeleted: () =>
                          setState(() => _attachments.removeAt(i)),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
