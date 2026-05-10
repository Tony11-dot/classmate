// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../../messages/domain/message_thread_models.dart';
import '../../messages/providers/messages_repository_provider.dart';
import '../../../ui/widgets/cm_loading.dart';

class TeacherStudentsScreen extends ConsumerStatefulWidget {
  const TeacherStudentsScreen({super.key});

  @override
  ConsumerState<TeacherStudentsScreen> createState() => _TeacherStudentsScreenState();
}

class _TeacherStudentsScreenState extends ConsumerState<TeacherStudentsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<MessageDirectoryPerson> _students = const [];
  List<MessageDirectoryPerson> _filtered = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearch);
    Future.microtask(_load);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final all = await ref.read(messagesRepositoryProvider).fetchSameSchoolPeople();
      final students = all.where((p) => p.role.toLowerCase() == 'student').toList();
      if (!mounted) return;
      setState(() {
        _students = students;
        _filtered = _applyQuery(students, _searchCtrl.text);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<MessageDirectoryPerson> _applyQuery(List<MessageDirectoryPerson> list, String q) {
    final query = q.trim().toLowerCase();
    if (query.isEmpty) return list;
    return list.where((p) {
      if (p.displayName.toLowerCase().contains(query)) return true;
      if (p.gradeLabel.toLowerCase().contains(query)) return true;
      return false;
    }).toList();
  }

  void _onSearch() {
    setState(() => _filtered = _applyQuery(_students, _searchCtrl.text));
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 8),
          // ── Search ────────────────────────────────────────────────────
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: l.teacherSearchStudents,
                  prefixIcon: Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            // ── Content ───────────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(child: const CmLoading())
                  : _error != null
                      ? Center(child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.error_outline_rounded, size: 40, color: cs.error),
                            const SizedBox(height: 12),
                            Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: cs.onSurfaceVariant)),
                            const SizedBox(height: 12),
                            FilledButton(onPressed: _load, child: Text(l.teacherRetry)),
                          ]),
                        ))
                      : _filtered.isEmpty
                          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.person_search_rounded, size: 48, color: cs.onSurfaceVariant),
                              const SizedBox(height: 16),
                              Text(
                                _searchCtrl.text.trim().isEmpty ? l.teacherNoStudentsLoaded : l.teacherStudentsNoMatch,
                                style: TextStyle(color: cs.onSurfaceVariant),
                              ),
                            ]))
                          : RefreshIndicator(
                              onRefresh: _load,
                              child: ListView.separated(
                                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                                itemCount: _filtered.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 8),
                                itemBuilder: (context, i) {
                                  final p = _filtered[i];
                                  final grade = p.gradeLabel.trim();
                                  return InkWell(
                                    onTap: () => context.push('/teacher/student/${p.userId}', extra: <String, dynamic>{'name': p.displayName}),
                                    borderRadius: BorderRadius.circular(16),
                                    child: LiquidGlassCard(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      borderRadius: BorderRadius.circular(16),
                                      color: cs.surfaceContainerLow,
                                      border: Border.all(color: cs.outlineVariant),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: cs.primaryContainer,
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            child: Center(child: Text(
                                              _initials(p.displayName),
                                              style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.w800, fontSize: 15),
                                            )),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(p.displayName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                                if (grade.isNotEmpty)
                                                  Text(grade, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                                              ],
                                            ),
                                          ),
                                          Icon(Icons.chevron_right_rounded, size: 18, color: cs.onSurfaceVariant),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
    );
  }
}
