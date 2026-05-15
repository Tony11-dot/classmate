// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/http/cm_api.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/config/env.dart';
import '../data/admin_repository.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final _schoolProvider2 = FutureProvider.autoDispose<AdminSchool?>((ref) {
  return ref.watch(adminRepositoryProvider).getMySchool();
});

// ── Screen ────────────────────────────────────────────────────────────────────

class AdminSchoolSettingsScreen extends ConsumerStatefulWidget {
  const AdminSchoolSettingsScreen({super.key});

  @override
  ConsumerState<AdminSchoolSettingsScreen> createState() =>
      _AdminSchoolSettingsScreenState();
}

class _AdminSchoolSettingsScreenState
    extends ConsumerState<AdminSchoolSettingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          TabBar(
            controller: _tabs,
            tabs: [
              Tab(text: l.navSchool),
              Tab(text: l.adminSubjectsTitle),
              const Tab(text: 'Bell Schedule'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: const [
                _SchoolInfoTab(),
                _SubjectsTab(),
                _BellScheduleTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── School Info Tab ───────────────────────────────────────────────────────────

class _SchoolInfoTab extends ConsumerStatefulWidget {
  const _SchoolInfoTab();

  @override
  ConsumerState<_SchoolInfoTab> createState() => _SchoolInfoTabState();
}

class _SchoolInfoTabState extends ConsumerState<_SchoolInfoTab> {
  final _nameCtrl = TextEditingController();
  bool _initialized = false;
  bool _dirty = false;
  bool _saving = false;
  bool _uploading = false;

  // School logo stored as a URL (from server) — updated after upload
  String? _logoUrl;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xFile == null || !mounted) return;

    setState(() => _uploading = true);
    try {
      final session = ref.read(authSessionProvider);
      // No global prefix in main.ts — upload is at /uploads/dm-media directly
      final base = Env.stripApiSuffix(Env.apiBaseUrl).replaceAll(RegExp(r'/+$'), '');
      final api = CMApi(token: session.token ?? '');
      final uri = Uri.parse('$base/uploads/dm-media');
      final result = await api.multipartUpload(uri, xFile.path, mimeType: 'image/jpeg');
      final fileMap = result['file'];
      final url = (fileMap is Map ? fileMap['url'] : null)?.toString() ?? '';
      api.dispose();

      if (url.isEmpty) throw Exception('Upload did not return a URL');

      // Save the logo URL to the school record
      await ref.read(adminRepositoryProvider).updateMySchool(logoUrl: url);
      await session.setSchoolLogoUrl(url);

      if (!mounted) return;
      setState(() {
        _logoUrl = url;
        _dirty = false;
      });
      ref.invalidate(_schoolProvider2);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.adminSchoolSaved)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _removeLogo() async {
    setState(() => _saving = true);
    try {
      await ref.read(adminRepositoryProvider).updateMySchool(logoUrl: '');
      await ref.read(authSessionProvider).setSchoolLogoUrl(null);
      if (!mounted) return;
      setState(() { _logoUrl = null; _initialized = false; });
      ref.invalidate(_schoolProvider2);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    try {
      await ref.read(adminRepositoryProvider).updateMySchool(name: name, logoUrl: _logoUrl ?? '');
      final session = ref.read(authSessionProvider);
      await session.setSchoolName(name);
      await session.setSchoolLogoUrl(_logoUrl);
      ref.invalidate(_schoolProvider2);
      if (!mounted) return;
      setState(() { _dirty = false; _initialized = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.adminSchoolSaved)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final schoolAsync = ref.watch(_schoolProvider2);

    return schoolAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (school) {
        if (!_initialized && school != null) {
          _initialized = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _nameCtrl.text = school.name;
            _logoUrl = school.logoUrl;
            setState(() {});
          });
        }

        final hasLogo = (_logoUrl ?? '').isNotEmpty;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
          children: [
            // ── Logo section ───────────────────────────────────────────────
            _FieldCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel(label: 'School Logo'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Logo preview or placeholder
                      GestureDetector(
                        onTap: _uploading ? null : _pickLogo,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: cs.primary.withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                          child: _uploading
                              ? const Center(child: SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2)))
                              : hasLogo
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(
                                        _logoUrl!,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => Icon(Icons.school_rounded, size: 32, color: cs.onPrimaryContainer),
                                      ),
                                    )
                                  : Icon(Icons.add_photo_alternate_rounded, size: 32, color: cs.onPrimaryContainer),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasLogo ? 'Logo uploaded' : 'No logo yet',
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Appears next to your school name in the app drawer.',
                              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant, height: 1.4),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                FilledButton.tonal(
                                  onPressed: _uploading ? null : _pickLogo,
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(hasLogo ? 'Change' : 'Upload'),
                                ),
                                if (hasLogo) ...[
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: _saving ? null : _removeLogo,
                                    style: TextButton.styleFrom(
                                      foregroundColor: cs.error,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text('Remove'),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Name section ───────────────────────────────────────────────
            _FieldCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel(label: l.adminSchoolName),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) => setState(() => _dirty = true),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      hintText: l.adminSchoolName,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: (_dirty && !_saving) ? _save : null,
                icon: _saving
                    ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_rounded),
                label: Text(l.adminSave),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Subjects Tab — flat school-wide list ──────────────────────────────────────

class _SubjectsTab extends ConsumerStatefulWidget {
  const _SubjectsTab();

  @override
  ConsumerState<_SubjectsTab> createState() => _SubjectsTabState();
}

class _SubjectsTabState extends ConsumerState<_SubjectsTab> {
  List<String> _subjects = [];
  final _addCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  @override
  void dispose() {
    _addCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    final session = ref.read(authSessionProvider);
    final api = CMApi(token: session.token ?? '');
    try {
      // Use grade=0 as school-wide subjects key
      final raw = await api.getJson('/admin/subjects/defaults',
          query: {'schoolId': session.schoolId, 'grade': '0'});
      final rawDefaults = raw is Map ? raw['defaults'] : null;
      final subjects = rawDefaults is Map ? rawDefaults['subjects'] : null;
      if (subjects is List) {
        _subjects = List<String>.from(subjects.map((s) => s.toString()));
      } else {
        _subjects = [];
      }
    } catch (_) {
      _subjects = [];
    } finally {
      api.dispose();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    final session = ref.read(authSessionProvider);
    final api = CMApi(token: session.token ?? '');
    setState(() => _saving = true);
    try {
      await api.postJson('/admin/subjects/defaults', body: {
        'schoolId': session.schoolId,
        'grade': 0,
        'subjects': _subjects,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.adminSchoolSaved)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      api.dispose();
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addSubject() {
    final text = _addCtrl.text.trim();
    if (text.isEmpty || _subjects.contains(text)) return;
    setState(() { _subjects = [..._subjects, text]; });
    _addCtrl.clear();
  }

  void _removeSubject(int index) {
    setState(() {
      final list = List<String>.from(_subjects);
      list.removeAt(index);
      _subjects = list;
    });
  }

  void _moveSubject(int from, int to) {
    setState(() {
      final list = List<String>.from(_subjects);
      final item = list.removeAt(from);
      list.insert(to, item);
      _subjects = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    if (_loading) return const Center(child: CircularProgressIndicator());

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // ── Header + add row ───────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'School Subjects',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Available to all teachers when creating assignments.',
                    style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox.square(dimension: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save_rounded, size: 16),
              label: Text(l.adminSave),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Add field ──────────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _addCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: l.adminSubjectsAddHint,
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                ),
                onSubmitted: (_) => _addSubject(),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _addSubject,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text(l.adminSubjectsAdd),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                minimumSize: Size.zero,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Subject list — each subject as a section row ───────────────────
        if (_subjects.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(l.adminSubjectsNoSubjects,
                  style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
            ),
          )
        else
          ...(_subjects.asMap().entries.map((e) => _SubjectSection(
            subject: e.value,
            index: e.key,
            total: _subjects.length,
            onDelete: () => _removeSubject(e.key),
            onMoveUp: e.key > 0 ? () => _moveSubject(e.key, e.key - 1) : null,
            onMoveDown: e.key < _subjects.length - 1 ? () => _moveSubject(e.key, e.key + 1) : null,
          ))),
      ],
    );
  }
}

// ── Subject section row ───────────────────────────────────────────────────────

class _SubjectSection extends StatelessWidget {
  const _SubjectSection({
    required this.subject,
    required this.index,
    required this.total,
    required this.onDelete,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  final String subject;
  final int index;
  final int total;
  final VoidCallback onDelete;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.only(left: 16, right: 4),
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: cs.onPrimaryContainer),
              ),
            ),
          ),
          title: Text(subject, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_upward_rounded, size: 18, color: onMoveUp != null ? cs.onSurfaceVariant : cs.outlineVariant),
                onPressed: onMoveUp,
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                icon: Icon(Icons.arrow_downward_rounded, size: 18, color: onMoveDown != null ? cs.onSurfaceVariant : cs.outlineVariant),
                onPressed: onMoveDown,
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, size: 18, color: cs.error),
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bell Schedule Tab (P1–P9 time pickers) ────────────────────────────────────

class _BellScheduleTab extends ConsumerStatefulWidget {
  const _BellScheduleTab();

  @override
  ConsumerState<_BellScheduleTab> createState() => _BellScheduleTabState();
}

class _BellScheduleTabState extends ConsumerState<_BellScheduleTab> {
  final Map<int, _PeriodTime> _times = {};
  // Dynamic list of period numbers (sorted)
  final List<int> _periods = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final defaults = await ref.read(adminRepositoryProvider).getPeriodDefaults();
      final map = <int, _PeriodTime>{};
      for (final d in defaults) {
        final p = (d['period'] as num?)?.toInt();
        if (p == null) continue;
        map[p] = _PeriodTime(start: d['startTime']?.toString() ?? '', end: d['endTime']?.toString() ?? '');
      }
      // If no saved data, seed P1–P9
      if (map.isEmpty) {
        for (var i = 1; i <= 9; i++) {
          map[i] = _PeriodTime(start: '', end: '');
        }
      }
      final periods = map.keys.toList()..sort();
      if (mounted) setState(() {
        _times..clear()..addAll(map);
        _periods..clear()..addAll(periods);
      });
    } catch (_) {
      for (var i = 1; i <= 9; i++) {
        _times.putIfAbsent(i, () => _PeriodTime(start: '', end: ''));
        if (!_periods.contains(i)) _periods.add(i);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _addPeriod() {
    final next = (_periods.isEmpty ? 0 : _periods.last) + 1;
    setState(() {
      _periods.add(next);
      _times[next] = _PeriodTime(start: '', end: '');
    });
  }

  void _deletePeriod(int period) {
    setState(() {
      _periods.remove(period);
      _times.remove(period);
    });
  }

  Future<void> _save() async {
    final toSave = _periods
        .map((i) => _times[i])
        .whereType<_PeriodTime>()
        .toList();
    // Pair with period numbers
    final payload = <Map<String, dynamic>>[];
    for (final p in _periods) {
      final t = _times[p];
      if (t == null || t.start.isEmpty || t.end.isEmpty) continue;
      payload.add({'period': p, 'startTime': t.start, 'endTime': t.end});
    }
    if (payload.isEmpty) return;
    setState(() => _saving = true);
    try {
      await ref.read(adminRepositoryProvider).setPeriodDefaults(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.adminSchoolSaved)),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickTime(int period, bool isStart) async {
    final current = _times[period] ?? _PeriodTime(start: '', end: '');
    final initial = _parseTime(isStart ? current.start : current.end);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null || !mounted) return;
    final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() {
      final existing = _times[period] ?? _PeriodTime(start: '', end: '');
      _times[period] = isStart
          ? _PeriodTime(start: formatted, end: existing.end)
          : _PeriodTime(start: existing.start, end: formatted);
    });
  }

  TimeOfDay _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts.isNotEmpty ? parts[0] : '8') ?? 8,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    if (_loading) return const Center(child: CircularProgressIndicator());

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: cs.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Set start and end times for each period. Add or remove periods as needed.',
                  style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final p in _periods) ...[
          _BellPeriodRow(
            period: p,
            times: _times[p] ?? _PeriodTime(start: '', end: ''),
            onPickStart: () => _pickTime(p, true),
            onPickEnd: () => _pickTime(p, false),
            onDelete: _periods.length > 1 ? () => _deletePeriod(p) : null,
          ),
          const SizedBox(height: 8),
        ],
        // Add period button
        TextButton.icon(
          onPressed: _addPeriod,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text('Add Period (P${(_periods.isEmpty ? 0 : _periods.last) + 1})'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: (_saving || _loading) ? null : _save,
            icon: _saving
                ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save_rounded),
            label: Text(l.adminSave),
          ),
        ),
      ],
    );
  }
}

class _BellPeriodRow extends StatelessWidget {
  const _BellPeriodRow({required this.period, required this.times, required this.onPickStart, required this.onPickEnd, this.onDelete});
  final int period;
  final _PeriodTime times;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final hasTime = times.start.isNotEmpty && times.end.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hasTime ? cs.outlineVariant.withValues(alpha: 0.5) : cs.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: hasTime ? cs.primaryContainer : cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text('P$period', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: hasTime ? cs.onPrimaryContainer : cs.onSurfaceVariant)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: _BellTimePicker(label: 'Start', time: times.start, onTap: onPickStart)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('→', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant)),
          ),
          Expanded(child: _BellTimePicker(label: 'End', time: times.end, onTap: onPickEnd)),
          if (hasTime) ...[
            const SizedBox(width: 8),
            Text(_duration(times.start, times.end),
                style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
          ],
          if (onDelete != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onDelete,
              child: Icon(Icons.remove_circle_outline_rounded, size: 18, color: cs.error),
            ),
          ],
        ],
      ),
    );
  }

  String _duration(String start, String end) {
    try {
      final sp = start.split(':'); final ep = end.split(':');
      final s = TimeOfDay(hour: int.parse(sp[0]), minute: int.parse(sp[1]));
      final e = TimeOfDay(hour: int.parse(ep[0]), minute: int.parse(ep[1]));
      final mins = (e.hour * 60 + e.minute) - (s.hour * 60 + s.minute);
      if (mins <= 0) return '';
      return '${mins}m';
    } catch (_) { return ''; }
  }
}

class _BellTimePicker extends StatelessWidget {
  const _BellTimePicker({required this.label, required this.time, required this.onTap});
  final String label;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final hasTime = time.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: hasTime ? cs.outlineVariant : cs.error.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(10),
          color: hasTime ? cs.surface : cs.errorContainer.withValues(alpha: 0.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(label, style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 10)),
            Text(hasTime ? time : '--:--',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: hasTime ? cs.onSurface : cs.error)),
          ],
        ),
      ),
    );
  }
}

class _PeriodTime {
  _PeriodTime({required this.start, required this.end});
  final String start;
  final String end;
}

// ── Shared widgets ─────────────────────────────────────────────────────────────

class _FieldCard extends StatelessWidget {
  const _FieldCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurfaceVariant),
    );
  }
}
