// ignore_for_file: use_build_context_synchronously
import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_session.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../domain/message_thread_models.dart';
import '../providers/messages_repository_provider.dart';
import 'new_group_screen.dart';
import '../../../common/widgets/role_badge.dart';
import '../../../ui/widgets/cm_error_state.dart';
import '../../../ui/widgets/cm_loading.dart';

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
      CupertinoPageRoute<String>(builder: (_) => NewGroupScreen(people: people)),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.messagesStartChatError(e.toString()))));
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  bool _matchesFilter(MessageDirectoryPerson p) {
    if (_filter == 'all') return true;
    final role = p.role.toLowerCase();
    if (_filter == 'students') return role == 'student';
    if (_filter == 'parents') return role == 'parent';
    if (_filter == 'teachers') return role == 'teacher' || role == 'secretary';
    if (_filter == 'admins') return role == 'admin';
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
    final isParent = session.primaryRole == 'PARENT';
    final isSecretary = session.primaryRole == 'SECRETARY';
    final isAdmin = session.primaryRole == 'ADMIN';
    final showRoleChips = isTeacher || isParent || isSecretary || isAdmin;
    final peopleValue = ref.watch(sameSchoolPeopleProvider);
    final q = _searchCtl.text.trim().toLowerCase();

    return PopScope(
      canPop: true,
      child: Scaffold(
      extendBodyBehindAppBar: true,
      body: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.fromLTRB(4, MediaQuery.of(context).padding.top + 4, 16, 0),
              decoration: const BoxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: l.a11yBack,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        style: IconButton.styleFrom(padding: const EdgeInsets.all(8)),
                      ),
                      const SizedBox(width: 4),
                      Text(l.tutorNewChat, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: cs.outlineVariant),
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
                  // Filter chips — shown for every role with a mixed
                  // recipient list (teachers, secretaries, admins, parents).
                  // Students see no chips; the server already filters
                  // their picker to peers + own parents + staff.
                  if (showRoleChips) ...[
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
                          const SizedBox(width: 8),
                          _FilterChip(label: l.messagesFilterAdmins, selected: _filter == 'admins', onTap: () => setState(() => _filter = 'admins')),
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
                loading: () => const Center(child: CmLoading()),
                error: (e, _) => CmErrorState.fromError(
                  e,
                  onRetry: () => ref.invalidate(sameSchoolPeopleProvider),
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
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                    children: [
                      // New Group option
                      InkWell(
                        onTap: _creating ? null : () => _openGroupFlow(people),
                        borderRadius: BorderRadius.circular(18),
                        child: LiquidGlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: cs.outlineVariant),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(14)),
                                child: Icon(Icons.group_add_rounded, color: cs.onPrimary, size: 22),
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
                                Icon(Icons.person_search_rounded, size: 48, color: cs.onSurfaceVariant),
                                const SizedBox(height: 16),
                                Text(q.isNotEmpty ? l.messagesNoPeopleMatch(q) : l.messagesNoPeopleFound, style: TextStyle(color: cs.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        Text(
                          l.messagesPeopleCount(filtered.length),
                          style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                        ),
                        const SizedBox(height: 10),
                        ...filtered.map((person) {

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () => _startDm(person),
                              borderRadius: BorderRadius.circular(18),
                              child: LiquidGlassCard(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                borderRadius: BorderRadius.circular(18),
                                color: cs.surfaceContainerLow,
                                border: Border.all(color: cs.outlineVariant),
                                child: Row(
                                  children: [
                                    // Avatar — previously had no background
                                    // colour, so the white initials rendered
                                    // invisibly on white card in light mode.
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: cs.primary,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Center(
                                        child: Text(
                                          person.initials.trim().isNotEmpty ? person.initials.trim() : _initials(person.displayName),
                                          style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.w800, fontSize: 15),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  person.displayName,
                                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (person.role.trim().isNotEmpty) ...[
                                                const SizedBox(width: 6),
                                                RoleBadge(role: person.role, compact: true),
                                              ],
                                            ],
                                          ),
                                          if (person.gradeLabel.isNotEmpty)
                                            Text(person.gradeLabel, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                                        ],
                                      ),
                                    ),
                                    if (_creating)
                                      const CmLoading(size: 20)
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
    ),  // PopScope
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
          color: selected ? cs.primaryContainer : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? cs.primary : cs.outlineVariant, width: selected ? 1.5 : 1),
        ),
        child: Text(
          label,
          style: TextStyle(fontWeight: selected ? FontWeight.w800 : FontWeight.w500, fontSize: 13, color: selected ? cs.onPrimaryContainer : cs.onSurface),
        ),
      ),
    );
  }
}
