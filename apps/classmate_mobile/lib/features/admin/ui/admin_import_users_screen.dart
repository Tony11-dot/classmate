// ignore_for_file: use_build_context_synchronously
import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/liquid_glass_dropdown.dart';
import '../data/admin_repository.dart';

/// Bulk "Add many" — fast multi-user entry that feeds the SAME backend the
/// single Add User screen uses. Two ways in, one editable grid:
///  • Grid: paste a list of names or fill rows by hand (all 5 roles), set role
///    and grade in bulk, and link each student to a parent (existing OR a new
///    parent created right in the list).
///  • CSV: upload a file (headers in any language) → load parsed rows INTO the
///    grid → review / fix → create.
class AdminImportUsersScreen extends ConsumerStatefulWidget {
  const AdminImportUsersScreen({super.key});

  @override
  ConsumerState<AdminImportUsersScreen> createState() => _AdminImportUsersScreenState();
}

const _validRoles = {'STUDENT', 'TEACHER', 'PARENT', 'SECRETARY', 'ADMIN'};

List<LiquidGlassDropdownItem<String>> _roleItemsFor(AppLocalizations l) => [
  LiquidGlassDropdownItem(value: 'STUDENT', label: l.roleStudent),
  LiquidGlassDropdownItem(value: 'TEACHER', label: l.roleTeacher),
  LiquidGlassDropdownItem(value: 'PARENT', label: l.roleParent),
  LiquidGlassDropdownItem(value: 'SECRETARY', label: l.roleSecretary),
  LiquidGlassDropdownItem(value: 'ADMIN', label: l.roleAdmin),
];

enum _UStatus { idle, checking, available, taken, invalid, dupe }

class _Row {
  _Row(this.ref);
  final String ref; // stable client id, used for in-batch parent linking
  String role = 'STUDENT';
  final name = TextEditingController();
  final username = TextEditingController();
  int? grade;
  // Backs the free-text grade field used only when a school has no configured
  // grade list. Persistent (not rebuilt per frame) so the cursor/IME survive.
  final gradeCtrl = TextEditingController();

  // Parent links (students only). A student may be linked to MULTIPLE parents.
  // Each link is one of: an existing parent user id, another PARENT row in this
  // same batch (by its ref), or a CSV username.
  final List<_ParentLink> parents = [];

  List<String>? childUsernames; // carried through from CSV (parent rows)

  _UStatus uStatus = _UStatus.idle;
  Timer? debounce;

  factory _Row.fromPreview(String ref, Map<String, dynamic> m) {
    final r = _Row(ref);
    final role = '${m['role'] ?? 'STUDENT'}'.toUpperCase();
    r.role = _validRoles.contains(role) ? role : 'STUDENT';
    r.name.text = '${m['name'] ?? m['nameEn'] ?? ''}';
    r.username.text = '${m['username'] ?? ''}';
    final g = m['grade'];
    r.grade = g is int ? g : int.tryParse('${g ?? ''}');
    if (r.grade != null) r.gradeCtrl.text = '${r.grade}';
    // CSV still links by username text — keep it as a username link.
    final p = '${m['parentUsername'] ?? ''}'.trim();
    if (p.isNotEmpty) r.parents.add(_ParentLink(username: p, displayName: p));
    final cu = m['childUsernames'];
    if (cu is List && cu.isNotEmpty) r.childUsernames = cu.map((e) => '$e').toList();
    return r;
  }

  void clearParent() => parents.clear();

  bool get hasParent => parents.isNotEmpty;

  void dispose() {
    debounce?.cancel();
    name.dispose();
    username.dispose();
    gradeCtrl.dispose();
  }

  Map<String, dynamic>? toDto() {
    final n = name.text.trim();
    if (n.isEmpty) return null;
    final dto = <String, dynamic>{'ref': ref, 'role': role, 'name': n};
    final u = username.text.trim();
    if (u.isNotEmpty) dto['username'] = u;
    if (role == 'STUDENT') {
      if (grade != null) dto['grade'] = grade;
      final ids = <String>[];
      final refs = <String>[];
      final usernames = <String>[];
      for (final p in parents) {
        if (p.existingId != null) {
          ids.add(p.existingId!);
        } else if (p.rowRef != null) {
          refs.add(p.rowRef!);
        } else if (p.username != null) {
          usernames.add(p.username!);
        }
      }
      if (ids.isNotEmpty) dto['parentIds'] = ids;
      if (refs.isNotEmpty) dto['parentRefs'] = refs;
      if (usernames.isNotEmpty) dto['parentUsernames'] = usernames;
    }
    if (childUsernames != null && childUsernames!.isNotEmpty) dto['childUsernames'] = childUsernames;
    return dto;
  }
}

/// One parent link on a student row. Exactly one of [existingId] / [rowRef] /
/// [username] is set. [displayName] is the chip label (kept in sync from the
/// live PARENT row for in-batch links).
class _ParentLink {
  _ParentLink({this.existingId, this.rowRef, this.username, this.displayName});
  final String? existingId; // an existing parent user id (from the picker)
  final String? rowRef; // another PARENT row in this batch, by its ref
  final String? username; // CSV username link
  final String? displayName;

  // Stable identity for de-duplication.
  String get key => existingId != null
      ? 'id:$existingId'
      : rowRef != null
          ? 'ref:$rowRef'
          : 'un:${username ?? ''}';
}

class _AdminImportUsersScreenState extends ConsumerState<AdminImportUsersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  int _refSeq = 0;
  late final List<_Row> _rows = [for (var i = 0; i < 4; i++) _Row(_nextRef())];
  bool _saving = false;
  Map<String, dynamic>? _result;

  // Existing parents, loaded lazily the first time the picker opens.
  List<AdminUser>? _existingParents;

  String _nextRef() => 'r${_refSeq++}';

  @override
  void dispose() {
    _tabs.dispose();
    for (final r in _rows) { r.dispose(); }
    super.dispose();
  }

  void _addRow() => setState(() => _rows.add(_Row(_nextRef())));

  void _removeRow(int i) {
    final removed = _rows[i];
    // Detach any student rows that linked to this (in-batch parent) row.
    for (final r in _rows) {
      r.parents.removeWhere((p) => p.rowRef == removed.ref);
    }
    setState(() => _rows.removeAt(i).dispose());
  }

  /// Paste a block of text from the clipboard — one name per line becomes a row.
  Future<void> _pasteNames() async {
    final l = AppLocalizations.of(context)!;
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text ?? '';
    final names = text
        .split(RegExp(r'[\r\n]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (names.isEmpty) return;
    setState(() {
      // Drop leading blank rows so a fresh paste fills cleanly.
      _rows.removeWhere((r) => r.name.text.trim().isEmpty && !r.hasParent);
      for (final n in names) {
        final row = _Row(_nextRef());
        row.name.text = n;
        _rows.add(row);
      }
      if (_rows.isEmpty) _rows.add(_Row(_nextRef()));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.adminAddManyPastedRows(names.length))),
    );
  }

  void _applyRoleToAll(String role) {
    setState(() {
      for (final r in _rows) {
        r.role = role;
        if (role != 'STUDENT') { r.grade = null; r.clearParent(); }
      }
    });
  }

  void _applyGradeToAll(int grade) {
    setState(() {
      for (final r in _rows) {
        if (r.role == 'STUDENT') r.grade = grade;
      }
    });
  }

  /// Replace the grid with parsed CSV rows and jump to the Grid tab for review.
  void _loadFromPreview(List<dynamic> preview) {
    for (final r in _rows) { r.dispose(); }
    setState(() {
      _rows
        ..clear()
        ..addAll(preview.map((e) => _Row.fromPreview(_nextRef(), Map<String, dynamic>.from(e as Map))));
      if (_rows.isEmpty) _rows.add(_Row(_nextRef()));
      _result = null;
    });
    _tabs.animateTo(0);
    final l = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.adminImportUsersScreenLoadedRows(preview.length))),
    );
  }

  // ── Live username validation ────────────────────────────────────────────

  void _onUsernameChanged(_Row row) {
    row.debounce?.cancel();
    final value = row.username.text.trim().toLowerCase();
    if (value.isEmpty) { setState(() => row.uStatus = _UStatus.idle); return; }
    // Duplicate within the current list is an instant, local verdict.
    final dupeInBatch = _rows.any((r) =>
        !identical(r, row) && r.username.text.trim().toLowerCase() == value);
    if (dupeInBatch) { setState(() => row.uStatus = _UStatus.dupe); return; }
    setState(() => row.uStatus = _UStatus.checking);
    row.debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final res = await ref.read(adminRepositoryProvider).checkUsername(value);
        if (!mounted) return;
        // Guard against the field having changed while the request was in flight.
        if (row.username.text.trim().toLowerCase() != value) return;
        setState(() => row.uStatus = !res.valid
            ? _UStatus.invalid
            : (res.available ? _UStatus.available : _UStatus.taken));
      } catch (_) {
        if (mounted) setState(() => row.uStatus = _UStatus.idle);
      }
    });
  }

  // ── Parent picker ───────────────────────────────────────────────────────

  Future<void> _pickParent(_Row student) async {
    if (_existingParents == null) {
      try {
        final list = await ref.read(adminRepositoryProvider).listUsers(role: 'PARENT');
        _existingParents = list.users;
      } catch (_) {
        _existingParents = const [];
      }
    }
    if (!mounted) return;
    final result = await showModalBottomSheet<_ParentChoice>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ParentPickerSheet(
        existing: _existingParents ?? const [],
        // Other rows in this batch that can act as a parent.
        batchParents: [
          for (final r in _rows)
            if (!identical(r, student) &&
                r.role == 'PARENT' &&
                r.name.text.trim().isNotEmpty)
              (ref: r.ref, name: r.name.text.trim()),
        ],
      ),
    );
    if (result == null) return;
    setState(() {
      switch (result.kind) {
        case _ParentKind.none:
          // "No parent" clears ALL links on this student.
          student.parents.clear();
        case _ParentKind.existing:
          _addParentLink(
            student,
            _ParentLink(existingId: result.id, displayName: result.name),
          );
        case _ParentKind.batch:
          _addParentLink(
            student,
            _ParentLink(rowRef: result.ref, displayName: result.name),
          );
        case _ParentKind.create:
          // Spin up a new PARENT row and link this student to it by ref. The
          // new row exposes the same fields as any other parent row, so the
          // admin fills it in inline.
          final p = _Row(_nextRef())..role = 'PARENT';
          p.name.text = result.name ?? '';
          _rows.add(p);
          _addParentLink(
            student,
            _ParentLink(rowRef: p.ref, displayName: result.name),
          );
      }
    });
  }

  // Add a parent link, de-duplicating so the same parent can't be linked twice.
  void _addParentLink(_Row student, _ParentLink link) {
    if (student.parents.any((p) => p.key == link.key)) return;
    student.parents.add(link);
  }

  // Live label for a link's chip — for in-batch links it follows the current
  // name typed into the PARENT row.
  String _parentLinkLabel(_ParentLink p) {
    if (p.rowRef != null) {
      for (final r in _rows) {
        if (r.ref == p.rowRef) {
          final n = r.name.text.trim();
          return n.isEmpty ? '—' : n;
        }
      }
    }
    return (p.displayName ?? p.username ?? '—').trim().isEmpty
        ? '—'
        : (p.displayName ?? p.username ?? '—');
  }

  // ── Submit ──────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final l = AppLocalizations.of(context)!;
    final dtos = _rows.map((r) => r.toDto()).whereType<Map<String, dynamic>>().toList();
    if (dtos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.adminImportUsersScreenFillAtLeastOneName)));
      return;
    }
    setState(() { _saving = true; _result = null; });
    try {
      final r = await ref.read(adminRepositoryProvider).bulkCreateUsers(dtos);
      setState(() => _result = r);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.adminImportUsersScreenFailed('$e'))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.adminImportUsersScreenTitle),
        bottom: TabBar(controller: _tabs, tabs: [
          Tab(icon: const Icon(Icons.grid_on_rounded), text: l.adminImportUsersScreenTabGrid),
          Tab(icon: const Icon(Icons.upload_file_rounded), text: l.adminImportUsersScreenTabCsv),
        ]),
      ),
      body: TabBarView(controller: _tabs, children: [
        _grid(context),
        _CsvTab(onLoadToGrid: _loadFromPreview),
      ]),
    );
  }

  Widget _grid(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    if (_result != null) {
      return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 100), children: [
        _resultView(context, _result!),
        const SizedBox(height: 16),
        OutlinedButton(onPressed: () => setState(() => _result = null), child: Text(l.adminImportUsersScreenBackToGrid)),
      ]);
    }
    final filledCount = _rows.where((r) => r.name.text.trim().isNotEmpty).length;
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 760;
      // Toolbar (paste button etc.) + header scroll together with the rows —
      // nothing is pinned/sticky at the top.
      final headerCount = wide ? 2 : 1;
      return Column(children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(wide ? 16 : 12, 8, wide ? 16 : 12, 12),
            itemCount: _rows.length + headerCount,
            itemBuilder: (context, i) {
              if (i == 0) return _toolbar(context, wide);
              if (wide && i == 1) return _gridHeader(cs);
              final idx = i - headerCount;
              return wide ? _rowWide(idx, cs) : _rowCard(idx, cs);
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saving ? null : _addRow,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l.adminImportUsersScreenAddRow),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _saving ? null : _submit,
                  icon: _saving
                      ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.check_rounded),
                  label: Text(l.adminImportUsersScreenCreateCount(filledCount)),
                ),
              ),
            ]),
          ),
        ),
      ]);
    });
  }

  // ── Toolbar: paste + bulk role/grade ──────────────────────────────────────

  Widget _toolbar(BuildContext context, bool wide) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final grades = ref.watch(authSessionProvider).schoolGrades;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 2, 0, 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.adminImportUsersScreenGridIntro, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12.5)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          ActionChip(
            avatar: const Icon(Icons.content_paste_rounded, size: 18),
            label: Text(l.adminAddManyPasteNames),
            onPressed: _saving ? null : _pasteNames,
          ),
          // Set role for ALL rows.
          PopupMenuButton<String>(
            onSelected: _saving ? null : _applyRoleToAll,
            itemBuilder: (_) => [
              for (final it in _roleItemsFor(l)) PopupMenuItem(value: it.value, child: Text(it.label)),
            ],
            child: _toolChip(cs, Icons.badge_outlined, l.adminAddManyApplyRole),
          ),
          // Set grade for ALL student rows.
          if (grades.isNotEmpty)
            PopupMenuButton<int>(
              onSelected: _saving ? null : _applyGradeToAll,
              itemBuilder: (_) => [
                for (final g in grades) PopupMenuItem(value: g, child: Text(l.adminCohortGradeFormat('$g'))),
              ],
              child: _toolChip(cs, Icons.school_outlined, l.adminAddManyApplyGrade),
            ),
        ]),
      ]),
    );
  }

  Widget _toolChip(ColorScheme cs, IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: cs.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 18, color: cs.onSurfaceVariant),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      const Icon(Icons.arrow_drop_down_rounded, size: 18),
    ]),
  );

  // ── Wide (spreadsheet) layout ─────────────────────────────────────────────

  Widget _gridHeader(ColorScheme cs) {
    final l = AppLocalizations.of(context)!;
    Widget h(String t, int flex) => Expanded(flex: flex, child: Text(t.toUpperCase(),
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: cs.onSurfaceVariant, letterSpacing: .4)));
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: Row(children: [
        SizedBox(width: 150, child: Text(l.adminImportUsersScreenRole.toUpperCase(),
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: cs.onSurfaceVariant, letterSpacing: .4))),
        const SizedBox(width: 8),
        h(l.adminImportUsersScreenFullName, 5),
        const SizedBox(width: 8),
        h(l.adminImportUsersScreenUsername, 4),
        const SizedBox(width: 8),
        SizedBox(width: 70, child: Text(l.adminImportUsersScreenGrade.toUpperCase(),
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: cs.onSurfaceVariant, letterSpacing: .4))),
        const SizedBox(width: 8),
        h(l.adminAddManyParentLabel, 4),
        const SizedBox(width: 40),
      ]),
    );
  }

  Widget _rowWide(int i, ColorScheme cs) {
    final row = _rows[i];
    final isStudent = row.role == 'STUDENT';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(width: 150, child: LiquidGlassDropdown<String>(
          label: '',
          value: row.role,
          items: _roleItemsFor(AppLocalizations.of(context)!),
          onChanged: (v) => setState(() {
            row.role = v;
            if (v != 'STUDENT') { row.grade = null; row.clearParent(); }
          }),
        )),
        const SizedBox(width: 8),
        Expanded(flex: 5, child: _cellField(row.name, capitalize: true, onChanged: (_) => setState(() {}))),
        const SizedBox(width: 8),
        Expanded(flex: 4, child: _usernameField(row)),
        const SizedBox(width: 8),
        SizedBox(width: 70, child: isStudent ? _gradeField(row) : const SizedBox()),
        const SizedBox(width: 8),
        Expanded(flex: 4, child: isStudent ? _parentField(row) : const SizedBox()),
        SizedBox(
          width: 40,
          child: IconButton(
            icon: Icon(Icons.close_rounded, color: cs.onSurfaceVariant, size: 20),
            onPressed: _rows.length <= 1 ? null : () => _removeRow(i),
          ),
        ),
      ]),
    );
  }

  // ── Narrow (card) layout ──────────────────────────────────────────────────

  Widget _rowCard(int i, ColorScheme cs) {
    final l = AppLocalizations.of(context)!;
    final row = _rows[i];
    final isStudent = row.role == 'STUDENT';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: LiquidGlassDropdown<String>(
                label: l.adminImportUsersScreenRole,
                value: row.role,
                items: _roleItemsFor(l),
                onChanged: (v) => setState(() {
                  row.role = v;
                  if (v != 'STUDENT') { row.grade = null; row.clearParent(); }
                }),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close_rounded, color: cs.onSurfaceVariant),
              onPressed: _rows.length <= 1 ? null : () => _removeRow(i),
            ),
          ]),
          const SizedBox(height: 8),
          _cellField(row.name, capitalize: true, label: l.adminImportUsersScreenFullName, onChanged: (_) => setState(() {})),
          const SizedBox(height: 8),
          _usernameField(row, label: l.adminImportUsersScreenUsername, hint: l.adminImportUsersScreenUsernameHint),
          if (isStudent) ...[
            const SizedBox(height: 8),
            Row(children: [
              SizedBox(width: 90, child: _gradeField(row, label: l.adminImportUsersScreenGrade)),
              const SizedBox(width: 8),
              Expanded(child: _parentField(row, label: l.adminAddManyParentLabel)),
            ]),
          ],
        ]),
      ),
    );
  }

  // ── Shared field builders ─────────────────────────────────────────────────

  Widget _cellField(TextEditingController c, {String? label, bool capitalize = false, ValueChanged<String>? onChanged}) {
    return TextField(
      controller: c,
      textCapitalization: capitalize ? TextCapitalization.words : TextCapitalization.none,
      textInputAction: TextInputAction.next,
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label, isDense: true, border: const OutlineInputBorder()),
    );
  }

  Widget _usernameField(_Row row, {String? label, String? hint}) {
    return TextField(
      controller: row.username,
      autocorrect: false,
      textInputAction: TextInputAction.next,
      onChanged: (_) => _onUsernameChanged(row),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        border: const OutlineInputBorder(),
        suffixIcon: _statusIcon(row.uStatus),
        suffixIconConstraints: const BoxConstraints(minWidth: 34, minHeight: 0),
      ),
    );
  }

  Widget? _statusIcon(_UStatus s) {
    final cs = Theme.of(context).colorScheme;
    switch (s) {
      case _UStatus.idle:
        return null;
      case _UStatus.checking:
        return const Padding(
          padding: EdgeInsets.only(right: 8),
          child: SizedBox.square(dimension: 14, child: CircularProgressIndicator(strokeWidth: 2)),
        );
      case _UStatus.available:
        return Icon(Icons.check_circle_rounded, color: cs.tertiary, size: 18);
      case _UStatus.taken:
      case _UStatus.dupe:
      case _UStatus.invalid:
        return Tooltip(
          message: s == _UStatus.dupe
              ? AppLocalizations.of(context)!.adminAddManyUsernameDupe
              : AppLocalizations.of(context)!.adminAddManyUsernameTaken,
          child: Icon(Icons.error_rounded, color: cs.error, size: 18),
        );
    }
  }

  Widget _gradeField(_Row row, {String? label}) {
    final grades = ref.watch(authSessionProvider).schoolGrades;
    if (grades.isEmpty) {
      return TextField(
        controller: row.gradeCtrl,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        onChanged: (v) => row.grade = int.tryParse(v.trim()),
        decoration: InputDecoration(labelText: label, isDense: true, border: const OutlineInputBorder()),
      );
    }
    return DropdownButtonFormField<int>(
      initialValue: row.grade,
      isDense: true,
      decoration: InputDecoration(labelText: label, isDense: true, border: const OutlineInputBorder()),
      items: [for (final g in grades) DropdownMenuItem(value: g, child: Text('$g'))],
      onChanged: (v) => setState(() => row.grade = v),
    );
  }

  Widget _parentField(_Row row, {String? label}) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    final addLabel =
        row.parents.isEmpty ? l.adminAddManyParentNone : l.adminAddManyAddParent;
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final p in row.parents)
            InputChip(
              label: Text(
                _parentLinkLabel(p),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onDeleted: () => setState(() => row.parents.remove(p)),
            ),
          ActionChip(
            avatar: Icon(Icons.add_rounded, size: 16, color: cs.primary),
            label: Text(
              addLabel,
              style: TextStyle(
                fontSize: 12,
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: () => _pickParent(row),
          ),
        ],
      ),
    );
  }
}

// ── Parent picker sheet ────────────────────────────────────────────────────────

enum _ParentKind { none, existing, batch, create }

class _ParentChoice {
  const _ParentChoice(this.kind, {this.id, this.ref, this.name});
  final _ParentKind kind;
  final String? id;
  final String? ref;
  final String? name;
}

class _ParentPickerSheet extends StatefulWidget {
  const _ParentPickerSheet({required this.existing, required this.batchParents});
  final List<AdminUser> existing;
  final List<({String ref, String name})> batchParents;

  @override
  State<_ParentPickerSheet> createState() => _ParentPickerSheetState();
}

class _ParentPickerSheetState extends State<_ParentPickerSheet> {
  final _searchCtrl = TextEditingController();
  String _q = '';

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final q = _q.toLowerCase();
    final existing = q.isEmpty
        ? widget.existing
        : widget.existing.where((u) =>
            u.name.toLowerCase().contains(q) || u.email.toLowerCase().contains(q)).toList();
    final batch = q.isEmpty
        ? widget.batchParents
        : widget.batchParents.where((p) => p.name.toLowerCase().contains(q)).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollCtrl) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(children: [
          const SizedBox(height: 10),
          Container(width: 36, height: 4, decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              onChanged: (v) => setState(() => _q = v.trim()),
              decoration: InputDecoration(
                hintText: l.adminAddManySearchParents,
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: ListView(controller: scrollCtrl, padding: const EdgeInsets.fromLTRB(12, 0, 12, 16), children: [
              // Create-new-parent sits on TOP so a parent can be made on the
              // spot. Uses the typed search text as the name when present.
              ListTile(
                leading: Icon(Icons.person_add_rounded, color: cs.primary),
                title: Text(
                  _q.trim().isEmpty
                      ? l.adminAddManyCreateParentGeneric
                      : l.adminAddManyCreateParent(_q.trim()),
                  style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700),
                ),
                onTap: () => Navigator.pop(
                  context,
                  _ParentChoice(_ParentKind.create,
                      name: _q.trim().isEmpty ? null : _q.trim()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.link_off_rounded),
                title: Text(l.adminAddManyParentNone),
                onTap: () => Navigator.pop(context, const _ParentChoice(_ParentKind.none)),
              ),
              if (batch.isNotEmpty) ...[
                _sectionLabel(cs, l.adminAddManyParentInBatch),
                for (final p in batch)
                  ListTile(
                    leading: const Icon(Icons.how_to_reg_rounded),
                    title: Text(p.name),
                    onTap: () => Navigator.pop(context, _ParentChoice(_ParentKind.batch, ref: p.ref, name: p.name)),
                  ),
              ],
              _sectionLabel(cs, l.adminAddManyParentExisting),
              if (existing.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l.adminAddManyNoParentsYet, style: TextStyle(color: cs.onSurfaceVariant)),
                ),
              for (final u in existing)
                ListTile(
                  leading: const Icon(Icons.person_rounded),
                  title: Text(u.name),
                  subtitle: u.email.isEmpty ? null : Text(u.email),
                  onTap: () => Navigator.pop(context, _ParentChoice(_ParentKind.existing, id: u.id, name: u.name)),
                ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _sectionLabel(ColorScheme cs, String t) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 14, 8, 4),
    child: Text(t.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: cs.onSurfaceVariant, letterSpacing: .5)),
  );
}

// ── CSV tab ──────────────────────────────────────────────────────────────────

class _CsvTab extends ConsumerStatefulWidget {
  const _CsvTab({required this.onLoadToGrid});
  final void Function(List<dynamic> preview) onLoadToGrid;
  @override
  ConsumerState<_CsvTab> createState() => _CsvTabState();
}

class _CsvTabState extends ConsumerState<_CsvTab> {
  String? _fileName;
  String? _filePath;
  bool _loading = false;
  Map<String, dynamic>? _preview;
  String? _error;

  Future<void> _pick() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['csv'], allowMultiple: false,
    );
    if (res == null || res.files.isEmpty) return;
    final f = res.files.first;
    if (f.path == null) { setState(() => _error = AppLocalizations.of(context)!.adminImportUsersScreenCouldNotReadFile); return; }
    setState(() { _fileName = f.name; _filePath = f.path; _preview = null; _error = null; });
    await _runPreview();
  }

  Future<void> _runPreview() async {
    if (_filePath == null) return;
    setState(() { _loading = true; _error = null; });
    try {
      final r = await ref.read(adminRepositoryProvider).importCsv(_filePath!, dryRun: true);
      setState(() => _preview = r);
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        Text(
          l.adminImportUsersScreenCsvIntro,
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        _hintCard(cs),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _loading ? null : _pick,
          icon: const Icon(Icons.upload_file_rounded),
          label: Text(_fileName == null ? l.adminImportUsersScreenChooseCsv : l.adminImportUsersScreenChooseDifferentFile),
        ),
        if (_fileName != null) ...[
          const SizedBox(height: 8),
          Text(l.adminImportUsersScreenSelectedFile(_fileName!), style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
        ],
        if (_loading) ...[const SizedBox(height: 28), const Center(child: CircularProgressIndicator())],
        if (_error != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: cs.errorContainer, borderRadius: BorderRadius.circular(12)),
            child: Text(_error!, style: TextStyle(color: cs.onErrorContainer)),
          ),
        ],
        if (_preview != null) _previewBlock(cs),
      ],
    );
  }

  Widget _hintCard(ColorScheme cs) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.adminImportUsersScreenRecognisedColumns, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(
          l.adminImportUsersScreenRecognisedColumnsBody,
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12, height: 1.45),
        ),
      ]),
    );
  }

  Widget _previewBlock(ColorScheme cs) {
    final l = AppLocalizations.of(context)!;
    final p = _preview!;
    final fields = (p['detectedFields'] as List?)?.map((e) => '$e').toList() ?? const [];
    final rows = (p['preview'] as List?) ?? const [];
    final count = p['rowCount'] ?? rows.length;
    final truncated = p['truncated'] == true;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 22),
      Text(l.adminImportUsersScreenDetectedRows(count is int ? count : int.tryParse('$count') ?? rows.length), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      const SizedBox(height: 8),
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (final f in fields) Chip(label: Text(f), visualDensity: VisualDensity.compact),
      ]),
      if (fields.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(l.adminImportUsersScreenNoColumnsDetected, style: TextStyle(color: cs.error)),
        ),
      if (truncated)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(l.adminImportUsersScreenTruncatedNotice, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
        ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: (rows.isEmpty || fields.isEmpty) ? null : () => widget.onLoadToGrid(rows),
          icon: const Icon(Icons.edit_note_rounded),
          label: Text(l.adminImportUsersScreenReviewEditInGrid),
        ),
      ),
      const SizedBox(height: 6),
      Text(l.adminImportUsersScreenReviewEditHint,
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11.5)),
    ]);
  }
}

// ── Shared result view ───────────────────────────────────────────────────────

Widget _resultView(BuildContext context, Map<String, dynamic> r) {
  final l = AppLocalizations.of(context)!;
  final cs = Theme.of(context).colorScheme;
  final created = (r['created'] as List?) ?? const [];
  final createdCount = r['createdCount'] ?? created.length;
  final failed = r['failedCount'] ?? 0;
  final links = r['linksCreated'] ?? 0;
  final errors = (r['errors'] as List?) ?? const [];
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SizedBox(height: 12),
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(12)),
      child: Text(
        l.adminImportUsersScreenResultSummary(
          createdCount is int ? createdCount : int.tryParse('$createdCount') ?? 0,
          links is int ? links : int.tryParse('$links') ?? 0,
        ) + (failed != 0 ? l.adminImportUsersScreenResultFailedSuffix(failed is int ? failed : int.tryParse('$failed') ?? 0) : ''),
        style: TextStyle(fontWeight: FontWeight.w700, color: cs.onPrimaryContainer),
      ),
    ),
    if (errors.isNotEmpty) ...[
      const SizedBox(height: 12),
      Text(l.adminImportUsersScreenFailedRows, style: TextStyle(fontWeight: FontWeight.w700, color: cs.error)),
      const SizedBox(height: 4),
      ...errors.take(25).map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        return Text(l.adminImportUsersScreenFailedRow('${m['row']}', '${m['reason']}'), style: TextStyle(color: cs.error, fontSize: 12));
      }),
    ],
    if (created.isNotEmpty) ...[
      const SizedBox(height: 16),
      Text(l.adminImportUsersScreenCredentialsTitle, style: const TextStyle(fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      ...created.map((c) {
        final m = Map<String, dynamic>.from(c as Map);
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Expanded(child: Text('${m['name'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w600))),
            SelectableText('${m['username']}  ·  ${m['tempPassword']}',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          ]),
        );
      }),
    ],
  ]);
}
