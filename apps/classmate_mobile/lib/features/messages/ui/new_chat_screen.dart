// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_session.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../domain/message_thread_models.dart';
import '../providers/messages_repository_provider.dart';
import 'new_group_screen.dart';

final sameSchoolPeopleProvider =
    FutureProvider.autoDispose<List<MessageDirectoryPerson>>((ref) {
  return ref.read(messagesRepositoryProvider).fetchSameSchoolPeople();
});

class NewChatScreen extends ConsumerStatefulWidget {
  const NewChatScreen({super.key});

  @override
  ConsumerState<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends ConsumerState<NewChatScreen> {
  final TextEditingController _searchCtl = TextEditingController();
  bool _creating = false;
  String _filter = 'all'; // 'all' | 'students' | 'parents' | 'teachers'

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  Future<void> _openGroupFlow(List<MessageDirectoryPerson> people) async {
    final nav = Navigator.of(context);
    final threadId = await nav.push<String>(
      MaterialPageRoute<String>(builder: (_) => NewGroupScreen(people: people)),
    );
    if (!mounted || threadId == null || threadId.trim().isEmpty) return;
    nav.pop(threadId.trim());
  }

  Future<void> _startDm(MessageDirectoryPerson person) async {
    if (_creating) return;
    setState(() => _creating = true);
    try {
      final detail = await ref
          .read(messagesRepositoryProvider)
          .createDirectRequest(recipientUserId: person.userId, firstMessage: '');
      if (!mounted) return;
      ref.invalidate(messagesInboxProvider);
      Navigator.of(context).pop(detail.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not start chat: $e')));
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  bool _matchesFilter(MessageDirectoryPerson p) {
    if (_filter == 'all') return true;
    final grade = p.gradeLabel.toLowerCase();
    final school = p.schoolName.toLowerCase();
    if (_filter == 'students') return grade.contains('grade') || grade.contains('class') || grade.contains('year');
    if (_filter == 'parents') return grade.contains('parent') || school.contains('parent');
    if (_filter == 'teachers') return grade.contains('teacher') || school.contains('staff');
    return true;
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final session = ref.read(authSessionProvider);
    final isTeacher = session.isTeacherLike;
    final peopleValue = ref.watch(sameSchoolPeopleProvider);
    final q = _searchCtl.text.trim().toLowerCase();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.primaryContainer.withValues(alpha: 0.72),
                    cs.surfaceContainerHigh.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        style: IconButton.styleFrom(backgroundColor: cs.surface.withValues(alpha: 0.6), padding: const EdgeInsets.all(8)),
                      ),
                      const SizedBox(width: 10),
                      Text(l.tutorNewChat, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.25)),
                    ),
                    child: TextField(
                      controller: _searchCtl,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: l.messagesSearchPeopleHint,
                        prefixIcon: Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Filter chips (only for teachers who have multiple roles to filter)
                  if (isTeacher) ...[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(label: l.chatFilterAll, selected: _filter == 'all', onTap: () => setState(() => _filter = 'all')),
                          const SizedBox(width: 8),
                          _FilterChip(label: l.teacherStudentsLabel, selected: _filter == 'students', onTap: () => setState(() => _filter = 'students')),
                          const SizedBox(width: 8),
                          _FilterChip(label: l.teacherParentsLabel, selected: _filter == 'parents', onTap: () => setState(() => _filter = 'parents')),
                          const SizedBox(width: 8),
                          _FilterChip(label: l.teacherTeachersLabel, selected: _filter == 'teachers', onTap: () => setState(() => _filter = 'teachers')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),

            // Content
            Expanded(
              child: peopleValue.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 48, color: cs.error.withValues(alpha: 0.6)),
                        const SizedBox(height: 16),
                        Text(l.messagesPeopleLoadFailed(e.toString()), textAlign: TextAlign.center, style: TextStyle(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
                data: (people) {
                  final filtered = people.where((p) {
                    final matchesSearch = q.isEmpty ||
                        p.displayName.toLowerCase().contains(q) ||
                        p.gradeLabel.toLowerCase().contains(q) ||
                        p.schoolName.toLowerCase().contains(q);
                    return matchesSearch && _matchesFilter(p);
                  }).toList(growable: false);

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                    children: [
                      // New Group option
                      InkWell(
                        onTap: _creating ? null : () => _openGroupFlow(people),
                        borderRadius: BorderRadius.circular(18),
                        child: LiquidGlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          borderRadius: BorderRadius.circular(18),
                          blurSigma: 10,
                          gradient: LinearGradient(
                            colors: [cs.primaryContainer.withValues(alpha: 0.5), cs.surface.withValues(alpha: 0.7)],
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                          ),
                          border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
                                child: Icon(Icons.group_add_rounded, color: cs.primary, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l.messagesNewGroupTitle, style: const TextStyle(fontWeight: FontWeight.w800)),
                                    Text(l.messagesNewGroupSubtitle, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 32),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person_search_rounded, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                                const SizedBox(height: 16),
                                Text(q.isNotEmpty ? 'No people match "$q"' : 'No people found', style: TextStyle(color: cs.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        Text(
                          '${filtered.length} ${filtered.length == 1 ? 'person' : 'people'}',
                          style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                        ),
                        const SizedBox(height: 10),
                        ...filtered.map((person) {
                          final subtitle = [
                            if (person.gradeLabel.trim().isNotEmpty) person.gradeLabel.trim(),
                            if (person.schoolName.trim().isNotEmpty) person.schoolName.trim(),
                          ].join(' · ');

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () => _startDm(person),
                              borderRadius: BorderRadius.circular(18),
                              child: LiquidGlassCard(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                borderRadius: BorderRadius.circular(18),
                                blurSigma: 8,
                                color: cs.surface.withValues(alpha: 0.82),
                                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
                                child: Row(
                                  children: [
                                    // Avatar with gradient
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [cs.primary, cs.tertiary],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 2))],
                                      ),
                                      child: Center(
                                        child: Text(
                                          person.initials.trim().isNotEmpty ? person.initials.trim() : _initials(person.displayName),
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(person.displayName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                          if (subtitle.isNotEmpty)
                                            Text(subtitle, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                                        ],
                                      ),
                                    ),
                                    if (_creating)
                                      const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                    else
                                      Icon(Icons.arrow_forward_ios_rounded, size: 14, color: cs.onSurfaceVariant),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  final String label;
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? cs.primary.withValues(alpha: 0.4) : cs.outlineVariant.withValues(alpha: 0.25), width: selected ? 1.5 : 1),
        ),
        child: Text(
          label,
          style: TextStyle(fontWeight: selected ? FontWeight.w800 : FontWeight.w500, fontSize: 13, color: selected ? cs.primary : cs.onSurface),
        ),
      ),
    );
  }
}
