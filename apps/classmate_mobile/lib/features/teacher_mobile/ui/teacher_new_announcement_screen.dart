// ignore_for_file: use_build_context_synchronously
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../../lifedoc/announcements_provider.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../ui/nav/glass_back_button.dart';

// Role descriptor. The CODE (id) is stable and used in the API payload;
// the display label is resolved at build time via AppLocalizations so it
// translates.
class _Role {
  const _Role(this.id, this.icon);
  final String id;
  final IconData icon;
}

const _kRoles = [
  _Role('STUDENT', Icons.school_rounded),
  _Role('PARENT', Icons.family_restroom_rounded),
  _Role('TEACHER', Icons.person_rounded),
  _Role('ADMIN', Icons.admin_panel_settings_rounded),
  _Role('SECRETARY', Icons.support_agent_rounded),
];

/// Localized plural display label for a role CODE. Reuses the existing
/// admin role keys. Falls back to the raw code for unknown roles.
String _roleLabel(AppLocalizations l, String code) {
  switch (code) {
    case 'STUDENT':
      return l.adminStudents;
    case 'PARENT':
      return l.adminParents;
    case 'TEACHER':
      return l.adminTeachers;
    case 'ADMIN':
      return l.adminAdmins;
    case 'SECRETARY':
      return l.adminSecretaries;
    default:
      return code;
  }
}

enum _AudienceMode { roles, grades, cohorts, individuals }

class TeacherNewAnnouncementScreen extends ConsumerStatefulWidget {
  const TeacherNewAnnouncementScreen({super.key});

  @override
  ConsumerState<TeacherNewAnnouncementScreen> createState() =>
      _TeacherNewAnnouncementScreenState();
}

class _TeacherNewAnnouncementScreenState
    extends ConsumerState<TeacherNewAnnouncementScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool _saving = false;

  // ── Audience ──────────────────────────────────────────────────────────────
  final Set<String> _selectedRoles = {};        // e.g. {'STUDENT', 'PARENT'}
  final Set<String> _selectedStudentIds = {};   // individual userId targets
  final Set<String> _selectedParentIds = {};    // individual parent userId targets
  final Set<String> _selectedCohortIds = {};    // cohort targets
  final Set<int> _selectedGrades = {};          // grade-level targets

  /// Which audience category the picker is currently showing. The
  /// segmented button at the top of the audience card switches between
  /// these four; only one picker is visible at a time so the layout
  /// stays compact even when the teacher has selections across multiple
  /// categories. Selections from every category are submitted on save.
  _AudienceMode _audienceMode = _AudienceMode.roles;

  // loaded once
  List<TeacherStudentWithLevel> _allStudents = [];
  List<TeacherParent> _allParents = [];
  List<({String id, String name, int grade})> _cohorts = [];
  final Map<String, List<String>> _cohortMemberCache = {};
  bool _loadingPeople = false;

  // ── Attachments ───────────────────────────────────────────────────────────
  // Files pending upload (picked locally, uploaded on _publish) + already-
  // uploaded entries that go straight into the announcement payload.
  final List<PlatformFile> _pendingFiles = [];
  final List<Map<String, dynamic>> _uploadedAttachments = [];

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx',
        'jpg', 'jpeg', 'png', 'webp', 'gif',
        'mp4', 'mov', 'mp3', 'wav',
        'zip', 'txt',
      ],
      allowMultiple: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pendingFiles.addAll(result.files));
    }
  }

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadPeople);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPeople() async {
    setState(() => _loadingPeople = true);
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      final results = await Future.wait([
        repo.fetchAllStudents(),
        repo.fetchCohortsForPicker(),
        repo.fetchAllParents(),
      ]);
      if (!mounted) return;
      final cohortMaps = results[1] as List<Map<String, dynamic>>;
      setState(() {
        _allStudents = results[0] as List<TeacherStudentWithLevel>;
        _allParents = results[2] as List<TeacherParent>;
        _cohorts = cohortMaps.map((c) => (
          id: (c['id'] ?? '').toString(),
          name: (c['name'] ?? '').toString(),
          grade: c['grade'] is int ? c['grade'] as int : int.tryParse('${c['grade'] ?? ''}') ?? 0,
        )).where((c) => c.id.isNotEmpty).toList()
          ..sort((a, b) => a.grade.compareTo(b.grade));
        _loadingPeople = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingPeople = false);
    }
  }

  // Build the targets array for the API. Parents and students both end
  // up as `{userId: …}` entries — server doesn't care about the role
  // distinction here, it just delivers to the listed user IDs.
  List<Map<String, dynamic>> get _targets {
    final targets = <Map<String, dynamic>>[];
    for (final r in _selectedRoles) {
      targets.add({'role': r});
    }
    for (final g in _selectedGrades) {
      targets.add({'grade': g});
    }
    for (final uid in _selectedStudentIds) {
      targets.add({'userId': uid});
    }
    for (final pid in _selectedParentIds) {
      targets.add({'userId': pid});
    }
    for (final cid in _selectedCohortIds) {
      targets.add({'cohortId': cid});
    }
    return targets;
  }

  /// Unique grade levels available across this school. Three sources,
  /// in order of richness:
  ///   1. Student profiles (`gradeLevel`) — only reliable when the
  ///      teacher endpoint returned the grade field. The fallback
  ///      `/messages/people/same-school` returns null gradeLevel,
  ///      which leaves the dropdown empty for many teachers.
  ///   2. Cohort `grade` field — cohorts always carry the grade in
  ///      their metadata, so a school with cohorts always has at
  ///      least one grade here.
  ///   3. School-wide 1..12 fallback — last resort so the picker is
  ///      never empty even before the cohort fetch resolves.
  List<int> get _availableGrades {
    final s = <int>{...ref.read(authSessionProvider).schoolGrades};
    for (final st in _allStudents) {
      final g = st.gradeLevel;
      if (g != null && g > 0) s.add(g);
    }
    for (final c in _cohorts) {
      if (c.grade > 0) s.add(c.grade);
    }
    if (s.isEmpty) {
      for (var i = 1; i <= 12; i++) {
        s.add(i);
      }
    }
    return s.toList()..sort();
  }

  Future<void> _publish() async {
    final l = AppLocalizations.of(context)!;
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.teacherTitleAndMessageRequired)),
      );
      return;
    }
    // Confirm broadcast when no specific audience is selected
    final targetsNow = _targets;
    if (targetsNow.isEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (dCtx) {
          final dl = AppLocalizations.of(dCtx)!;
          return AlertDialog(
            title: Text(dl.teacherAnnounceBroadcastTitle),
            content: Text(
              dl.teacherNewAnnouncementScreenBroadcastBody,
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dCtx, false), child: Text(dl.commonCancel)),
              FilledButton(onPressed: () => Navigator.pop(dCtx, true), child: Text(dl.teacherAnnounceSendToEveryone)),
            ],
          );
        },
      );
      if (confirm != true || !mounted) return;
    }
    setState(() => _saving = true);
    try {
      // Upload any pending files first so the announcement payload
      // carries the resolved URLs (same shape AttachmentPills expects).
      final repo = ref.read(teacherMobileRepositoryProvider);
      final attachments = <Map<String, dynamic>>[..._uploadedAttachments];
      for (final f in _pendingFiles) {
        if (f.path == null || f.path!.isEmpty) continue;
        try {
          final res = await repo.uploadAttachmentFile(f.path!, f.name);
          final url = (res['url'] ?? res['fileUrl'] ?? '').toString().trim();
          if (url.isNotEmpty) {
            attachments.add({'type': 'file', 'url': url, 'name': f.name});
          }
        } catch (_) {
          // continue with the rest — surfaced as missing pills, not a hard fail
        }
      }
      await repo.createAnnouncement(
        title: title,
        body: body,
        targets: _targets,
        attachments: attachments,
      );
      ref.invalidate(publishedAnnouncementsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.teacherAnnouncementPublished)),
      );
      if (context.canPop()) context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.teacherFailedToPublish(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Student picker bottom sheet ───────────────────────────────────────────

  Future<void> _openStudentPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => _PersonPickerSheet(
        title: AppLocalizations.of(context)!.pickerSelectStudents,
        items: _allStudents
            .map((s) => _PickerItem(
                  id: s.studentId,
                  label: s.name,
                  subtitle: s.gradeLevel != null ? AppLocalizations.of(context)!.teacherNewAnnouncementScreenGradeLabel(s.gradeLevel!) : '',
                ))
            .toList(),
        selected: Set.from(_selectedStudentIds),
        onToggle: (id) => setState(() {
          if (_selectedStudentIds.contains(id)) {
            _selectedStudentIds.remove(id);
          } else {
            _selectedStudentIds.add(id);
          }
        }),
      ),
    );
  }

  List<String> get _previewCohortMembers {
    final seen = <String>{};
    final result = <String>[];
    for (final id in _selectedCohortIds) {
      for (final n in (_cohortMemberCache[id] ?? [])) {
        if (seen.add(n)) result.add(n);
      }
    }
    result.sort();
    return result;
  }

  Future<void> _fetchCohortMembers(String cohortId) async {
    if (_cohortMemberCache.containsKey(cohortId)) return;
    try {
      final students = await ref.read(teacherMobileRepositoryProvider).fetchCohortStudents(cohortId);
      if (mounted) setState(() => _cohortMemberCache[cohortId] = students.map((s) => s.name).toList());
    } catch (_) {}
  }

  Future<void> _openParentPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => _ParentPickerSheet(
        parents: _allParents,
        selected: Set.from(_selectedParentIds),
        onToggle: (id) => setState(() {
          if (_selectedParentIds.contains(id)) {
            _selectedParentIds.remove(id);
          } else {
            _selectedParentIds.add(id);
          }
        }),
      ),
    );
  }

  Future<void> _openCohortPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => _PersonPickerSheet(
        title: AppLocalizations.of(context)!.pickerSelectCohorts,
        items: _cohorts
            .map((c) => _PickerItem(
                  id: c.id,
                  label: c.name,
                  subtitle: c.grade > 0 ? AppLocalizations.of(context)!.teacherNewAnnouncementScreenGradeLabel(c.grade) : '',
                ))
            .toList(),
        selected: Set.from(_selectedCohortIds),
        onToggle: (id) {
          setState(() {
            if (_selectedCohortIds.contains(id)) {
              _selectedCohortIds.remove(id);
            } else {
              _selectedCohortIds.add(id);
              _fetchCohortMembers(id);
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    final hasAudience = _selectedRoles.isNotEmpty ||
        _selectedGrades.isNotEmpty ||
        _selectedStudentIds.isNotEmpty ||
        _selectedParentIds.isNotEmpty ||
        _selectedCohortIds.isNotEmpty;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsetsDirectional.only(start: 8),
          child: Center(
            child: GlassBackButton(
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/announcements'),
            ),
          ),
        ),
        title: Text(
          l.teacherNewAnnouncementAction,
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: FilledButton.icon(
              onPressed: _saving ? null : _publish,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(
                  _saving ? l.teacherPublishingAction : l.teacherPublishAction),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ── Content card ────────────────────────────────────────────
          LiquidGlassCard(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(20),
            color: cs.surfaceContainerLow,
            border:
                Border.all(color: cs.outlineVariant),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.teacherAnnouncementSectionTitle,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _titleCtrl,
                  decoration: InputDecoration(
                    labelText: l.teacherAnnounceTitleLabel,
                    hintText: l.teacherAnnounceTitleHint,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _bodyCtrl,
                  decoration: InputDecoration(
                    labelText: l.teacherAnnounceMessageLabel,
                    hintText: l.teacherAnnounceMessageHint,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                    alignLabelWithHint: true,
                  ),
                  minLines: 5,
                  maxLines: 10,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 14),
                // Attachment picker — files uploaded on publish.
                Row(
                  children: [
                    Text(l.commonAttachments,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _pickAttachment,
                      icon: const Icon(Icons.attach_file_rounded, size: 18),
                      label: Text(l.teacherMaterialAddFile),
                    ),
                  ],
                ),
                if (_pendingFiles.isEmpty)
                  Text(
                    l.teacherNewAnnouncementScreenNoFilesAttached,
                    style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  )
                else
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _pendingFiles.asMap().entries.map((entry) {
                      final i = entry.key;
                      final f = entry.value;
                      return InputChip(
                        avatar: const Icon(Icons.insert_drive_file_rounded, size: 16),
                        label: Text(f.name, overflow: TextOverflow.ellipsis),
                        onDeleted: () => setState(() => _pendingFiles.removeAt(i)),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Audience card ───────────────────────────────────────────
          LiquidGlassCard(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(20),
            color: cs.surfaceContainerLow,
            border:
                Border.all(color: cs.outlineVariant),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      l.teacherAudienceSectionTitle,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    if (hasAudience)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          l.teacherNewAnnouncementScreenSelectedCount(_selectedRoles.length + _selectedGrades.length + _selectedStudentIds.length + _selectedParentIds.length + _selectedCohortIds.length),
                          style: TextStyle(
                              color: cs.onPrimaryContainer,
                              fontSize: 11,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  l.teacherNewAnnouncementScreenAudienceHint,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 14),

                // ── Audience category selector ───────────────────────
                SegmentedButton<_AudienceMode>(
                  showSelectedIcon: false,
                  style: SegmentedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    textStyle: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  segments: [
                    ButtonSegment(
                      value: _AudienceMode.roles,
                      label: Text(AppLocalizations.of(context)!.adminRoleLabel, maxLines: 1, overflow: TextOverflow.fade, softWrap: false),
                    ),
                    ButtonSegment(
                      value: _AudienceMode.grades,
                      label: Text(AppLocalizations.of(context)!.adminGradeLabel, maxLines: 1, overflow: TextOverflow.fade, softWrap: false),
                    ),
                    ButtonSegment(
                      value: _AudienceMode.cohorts,
                      label: Text(AppLocalizations.of(context)!.commonCohort, maxLines: 1, overflow: TextOverflow.fade, softWrap: false),
                    ),
                    ButtonSegment(
                      value: _AudienceMode.individuals,
                      label: Text(AppLocalizations.of(context)!.classroomDetailTabPeople, maxLines: 1, overflow: TextOverflow.fade, softWrap: false),
                    ),
                  ],
                  selected: {_audienceMode},
                  onSelectionChanged: (set) =>
                      setState(() => _audienceMode = set.first),
                ),
                const SizedBox(height: 14),

                // ── Picker for the current category ──────────────────
                if (_audienceMode == _AudienceMode.roles)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _kRoles.map((r) {
                      final selected = _selectedRoles.contains(r.id);
                      return _AudienceChip(
                        label: _roleLabel(l, r.id),
                        icon: r.icon,
                        selected: selected,
                        onTap: () => setState(() {
                          if (selected) {
                            _selectedRoles.remove(r.id);
                          } else {
                            _selectedRoles.add(r.id);
                          }
                        }),
                      );
                    }).toList(),
                  )
                else if (_audienceMode == _AudienceMode.grades)
                  _availableGrades.isEmpty
                      ? Text(
                          _loadingPeople
                              ? l.teacherNewAnnouncementScreenLoadingStudents
                              : l.teacherNewAnnouncementScreenNoGradeLevels,
                          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _availableGrades.map((g) {
                            final selected = _selectedGrades.contains(g);
                            return _AudienceChip(
                              label: l.teacherNewAnnouncementScreenGradeLabel(g),
                              icon: Icons.school_outlined,
                              selected: selected,
                              onTap: () => setState(() {
                                if (selected) {
                                  _selectedGrades.remove(g);
                                } else {
                                  _selectedGrades.add(g);
                                }
                              }),
                            );
                          }).toList(),
                        )
                else if (_audienceMode == _AudienceMode.cohorts)
                  _cohorts.isEmpty
                      ? Text(AppLocalizations.of(context)!.teacherAnnounceNoCohorts,
                          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13))
                      : _PickerTrigger(
                          icon: Icons.groups_rounded,
                          label: _selectedCohortIds.isEmpty
                              ? l.teacherNewAnnouncementScreenTapSelectCohorts
                              : l.teacherNewAnnouncementScreenCohortsSelected(_selectedCohortIds.length),
                          hasSelection: _selectedCohortIds.isNotEmpty,
                          onTap: _openCohortPicker,
                        )
                else ...[
                  // Individuals: students AND parents — both via their
                  // own pickers so the teacher can blend "one student" +
                  // "one specific parent" in the same announcement.
                  _loadingPeople
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          _PickerTrigger(
                            icon: Icons.person_search_rounded,
                            label: _selectedStudentIds.isEmpty
                                ? l.teacherNewAnnouncementScreenTapSelectStudents
                                : l.teacherNewAnnouncementScreenStudentsSelected(_selectedStudentIds.length),
                            hasSelection: _selectedStudentIds.isNotEmpty,
                            onTap: _openStudentPicker,
                          ),
                          const SizedBox(height: 8),
                          _PickerTrigger(
                            icon: Icons.family_restroom_rounded,
                            label: _selectedParentIds.isEmpty
                                ? l.teacherNewAnnouncementScreenTapSelectParents
                                : l.teacherNewAnnouncementScreenParentsSelected(_selectedParentIds.length),
                            hasSelection: _selectedParentIds.isNotEmpty,
                            onTap: _openParentPicker,
                          ),
                        ]),
                ],

                // ── Cross-category summary of every active selection ─
                if (hasAudience) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.teacherNewAnnouncementScreenSelectedAudience,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final r in _selectedRoles)
                              _MiniChip(
                                label: _roleLabel(l, r),
                                onRemove: () =>
                                    setState(() => _selectedRoles.remove(r)),
                              ),
                            for (final g in _selectedGrades)
                              _MiniChip(
                                label: l.teacherNewAnnouncementScreenGradeLabel(g),
                                onRemove: () =>
                                    setState(() => _selectedGrades.remove(g)),
                              ),
                            for (final cid in _selectedCohortIds)
                              _MiniChip(
                                label: () {
                                  final match = _cohorts
                                      .where((c) => c.id == cid)
                                      .firstOrNull;
                                  return match?.name ?? cid;
                                }(),
                                onRemove: () => setState(
                                    () => _selectedCohortIds.remove(cid)),
                              ),
                            for (final s in _allStudents.where(
                                (s) => _selectedStudentIds.contains(s.studentId)))
                              _MiniChip(
                                label: s.name,
                                onRemove: () => setState(
                                    () => _selectedStudentIds.remove(s.studentId)),
                              ),
                            for (final p in _allParents.where(
                                (p) => _selectedParentIds.contains(p.parentId)))
                              _MiniChip(
                                label: p.children.isEmpty
                                    ? p.name
                                    : '${p.name} · ${p.children.length}',
                                onRemove: () => setState(
                                    () => _selectedParentIds.remove(p.parentId)),
                              ),
                          ],
                        ),
                        if (_selectedCohortIds.isNotEmpty &&
                            _previewCohortMembers.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            l.teacherNewAnnouncementScreenStudentsInCohorts(_previewCohortMembers.length),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared picker widgets
// ─────────────────────────────────────────────────────────────────────────────

class _PickerItem {
  const _PickerItem({required this.id, required this.label, this.subtitle = ''});
  final String id;
  final String label;
  final String subtitle;
}

class _PersonPickerSheet extends StatefulWidget {
  const _PersonPickerSheet({
    required this.title,
    required this.items,
    required this.selected,
    required this.onToggle,
  });
  final String title;
  final List<_PickerItem> items;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  State<_PersonPickerSheet> createState() => _PersonPickerSheetState();
}

class _PersonPickerSheetState extends State<_PersonPickerSheet> {
  String _query = '';
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selected);
  }

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
    widget.onToggle(id);
  }

  List<_PickerItem> get _filtered {
    if (_query.isEmpty) return widget.items;
    final q = _query.toLowerCase();
    return widget.items
        .where((i) =>
            i.label.toLowerCase().contains(q) ||
            i.subtitle.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final filtered = _filtered;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Text(widget.title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const Spacer(),
                if (_selected.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('${_selected.length} selected',
                        style: TextStyle(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.teacherMaterialSearchHint,
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(AppLocalizations.of(context)!.teacherAnnounceNothingFound,
                        style: TextStyle(color: cs.onSurfaceVariant)))
                : ListView.builder(
                    controller: scrollCtrl,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final item = filtered[i];
                      final isSelected =
                          _selected.contains(item.id);
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _toggle(item.id),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? cs.primaryContainer
                                        : cs.surfaceContainerHighest
                                            .withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      item.label.isNotEmpty
                                          ? item.label[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: isSelected
                                            ? cs.onPrimaryContainer
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
                                      Text(item.label,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: isSelected
                                                      ? cs.primary
                                                      : null)),
                                      if (item.subtitle.isNotEmpty)
                                        Text(item.subtitle,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                    color:
                                                        cs.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (_) => _toggle(item.id),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(6)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FilledButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Text(AppLocalizations.of(context)!.commonDone),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Parent picker — same modal pattern as _PersonPickerSheet but each
// parent row has an expandable subtitle showing their children (with
// grade). Lets the author target Maria (mother of Sarah) by tapping
// her row, OR expand to see who's in her family before deciding.
// ─────────────────────────────────────────────────────────────────────────────

class _ParentPickerSheet extends StatefulWidget {
  const _ParentPickerSheet({
    required this.parents,
    required this.selected,
    required this.onToggle,
  });

  final List<TeacherParent> parents;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  State<_ParentPickerSheet> createState() => _ParentPickerSheetState();
}

class _ParentPickerSheetState extends State<_ParentPickerSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.selected);
    _searchCtrl.addListener(() {
      final v = _searchCtrl.text.trim().toLowerCase();
      if (v != _query) setState(() => _query = v);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<TeacherParent> get _filtered {
    if (_query.isEmpty) return widget.parents;
    return widget.parents.where((p) {
      if (p.name.toLowerCase().contains(_query)) return true;
      if (p.email.toLowerCase().contains(_query)) return true;
      for (final c in p.children) {
        if (c.name.toLowerCase().contains(_query)) return true;
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scroll) => Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.teacherNewAnnouncementScreenSelectParents,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.commonDone),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.teacherSearchParentsOrChildren,
                prefixIcon: const Icon(Icons.search_rounded),
                isDense: true,
                filled: true,
                fillColor: cs.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.outlineVariant),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: widget.parents.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(AppLocalizations.of(context)!.teacherAnnounceNoParents),
                    ),
                  )
                : ListView.builder(
                    controller: scroll,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                    itemCount: _filtered.length,
                    itemBuilder: (ctx, i) {
                      final p = _filtered[i];
                      final isSelected = _selected.contains(p.parentId);
                      return _ParentTile(
                        parent: p,
                        selected: isSelected,
                        onToggle: () {
                          setState(() {
                            if (isSelected) {
                              _selected.remove(p.parentId);
                            } else {
                              _selected.add(p.parentId);
                            }
                          });
                          widget.onToggle(p.parentId);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ParentTile extends StatefulWidget {
  const _ParentTile({
    required this.parent,
    required this.selected,
    required this.onToggle,
  });

  final TeacherParent parent;
  final bool selected;
  final VoidCallback onToggle;

  @override
  State<_ParentTile> createState() => _ParentTileState();
}

class _ParentTileState extends State<_ParentTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final hasChildren = widget.parent.children.isNotEmpty;
    final childCount = widget.parent.children.length;
    final summary = hasChildren
        ? l.teacherNewAnnouncementScreenChildrenSummary(childCount, widget.parent.childrenSummary)
        : l.teacherNewAnnouncementScreenNoLinkedChildren;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.selected ? cs.primaryContainer : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.selected ? cs.primary : cs.outlineVariant,
          width: widget.selected ? 1.4 : 0.8,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: widget.onToggle,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
              child: Row(
                children: [
                  Checkbox(
                    value: widget.selected,
                    onChanged: (_) => widget.onToggle(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.parent.name.isEmpty
                              ? widget.parent.email
                              : widget.parent.name,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          summary,
                          maxLines: _expanded ? 99 : 1,
                          overflow: _expanded ? null : TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasChildren)
                    IconButton(
                      tooltip: _expanded ? l.a11yCollapse : l.a11yExpand,
                      icon: Icon(
                        _expanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                      ),
                      onPressed: () => setState(() => _expanded = !_expanded),
                    ),
                ],
              ),
            ),
          ),
          if (_expanded && hasChildren) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(54, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.parent.children
                    .map((c) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Icon(Icons.school_rounded, size: 14, color: cs.onSurfaceVariant),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  c.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              if (c.summary.isNotEmpty)
                                Text(
                                  c.summary,
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small reusable chips
// ─────────────────────────────────────────────────────────────────────────────

class _AudienceChip extends StatelessWidget {
  const _AudienceChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? cs.primaryContainer
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? cs.primary
                : cs.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15,
                color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight:
                    selected ? FontWeight.w800 : FontWeight.w500,
                fontSize: 13,
                color: selected ? cs.onPrimaryContainer : cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerTrigger extends StatelessWidget {
  const _PickerTrigger({
    required this.icon,
    required this.label,
    required this.hasSelection,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool hasSelection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: cs.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: hasSelection ? null : cs.onSurfaceVariant,
                  fontWeight: hasSelection
                      ? FontWeight.w600
                      : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.onPrimaryContainer)),
          const SizedBox(width: 4),
          Semantics(
            button: true,
            label: l.a11yRemove,
            child: GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close_rounded,
                  size: 14,
                  color: cs.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
