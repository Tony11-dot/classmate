import 'package:flutter/material.dart';

import '../../../ui/widgets/cm_search_field.dart';
import '../../../ui/widgets/cm_loading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/cm_tokens.dart';
import '../../../core/util/short_name.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/cm_press.dart';
import '../../../ui/widgets/cm_surfaces.dart';
import '../domain/message_thread_models.dart';
import '../providers/messages_repository_provider.dart';

class NewGroupScreen extends ConsumerStatefulWidget {
  const NewGroupScreen({super.key, required this.people});

  final List<MessageDirectoryPerson> people;

  @override
  ConsumerState<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends ConsumerState<NewGroupScreen> {
  final TextEditingController _searchCtl = TextEditingController();
  final TextEditingController _nameCtl = TextEditingController();
  final Set<String> _selected = <String>{};
  bool _submitting = false;

  @override
  void dispose() {
    _searchCtl.dispose();
    _nameCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final q = _searchCtl.text.trim().toLowerCase();
    final filtered = widget.people
        .where((p) {
          if (q.isEmpty) return true;
          return p.displayName.toLowerCase().contains(q) ||
              p.gradeLabel.toLowerCase().contains(q) ||
              p.schoolName.toLowerCase().contains(q);
        })
        .toList(growable: false);

    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final byId = {for (final p in widget.people) p.userId: p};
    final selectedPeople = [
      for (final id in _selected)
        if (byId[id] != null) byId[id]!,
    ];

    void toggle(String userId) {
      setState(() {
        if (!_selected.remove(userId)) _selected.add(userId);
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.messagesNewGroupTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: CmCard(
                tint: cs.primary,
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Row(
                  children: [
                    const CmIconTile(icon: Icons.group_rounded, filled: true),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _nameCtl,
                        textCapitalization: TextCapitalization.words,
                        maxLength: 50,
                        onChanged: (_) => setState(() {}),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        decoration: InputDecoration(
                          hintText: l.messagesGroupNameHint,
                          filled: false,
                          border: InputBorder.none,
                          isDense: true,
                          counterText: '', // hide the counter — keeps UI clean
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: CmSearchField(
                controller: _searchCtl,
                hint: l.messagesSearchPeopleHint,
                onChanged: (_) => setState(() {}),
              ),
            ),
            // Selected members — tap one to remove it.
            AnimatedSize(
              duration: CmTokens.medium,
              curve: CmTokens.easeOut,
              alignment: Alignment.topCenter,
              child: selectedPeople.isEmpty
                  ? const SizedBox(width: double.infinity)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                          child: Text(
                            l.classroomDetailSelectedCount(_selected.length),
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.primary,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: selectedPeople.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 6),
                            itemBuilder: (context, i) {
                              final p = selectedPeople[i];
                              return CmPress(
                                onTap: () => toggle(p.userId),
                                child: Container(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                    4,
                                    4,
                                    10,
                                    4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cs.primary.withValues(
                                      alpha: cs.brightness == Brightness.dark
                                          ? 0.18
                                          : 0.09,
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CmMonogram(
                                        name: p.displayName,
                                        initials: p.initials,
                                        radius: 15,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        shortName(p.displayName),
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.close_rounded,
                                        size: 16,
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
            ),
            Expanded(
              child: ListView.builder(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final person = filtered[index];
                  final selected = _selected.contains(person.userId);
                  final meta = [
                    if (person.gradeLabel.trim().isNotEmpty)
                      person.gradeLabel.trim(),
                    if (person.schoolName.trim().isNotEmpty)
                      person.schoolName.trim(),
                  ].join(' • ');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: CmPress(
                      onTap: () => toggle(person.userId),
                      child: AnimatedContainer(
                        duration: CmTokens.fast,
                        curve: CmTokens.easeOut,
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? Color.alphaBlend(
                                  cs.primary.withValues(
                                    alpha: cs.brightness == Brightness.dark
                                        ? 0.16
                                        : 0.07,
                                  ),
                                  cs.surfaceContainerLow,
                                )
                              : cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(
                            CmTokens.radiusLg,
                          ),
                          border: Border.all(
                            color: selected
                                ? cs.primary.withValues(alpha: 0.7)
                                : cs.outlineVariant.withValues(alpha: 0.35),
                            width: selected ? 1.4 : 0.8,
                          ),
                          boxShadow: CmTokens.of(context).shadowSm,
                        ),
                        child: Row(
                          children: [
                            CmMonogram(
                              name: person.displayName,
                              initials: person.initials,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    person.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  if (meta.isNotEmpty)
                                    Text(
                                      meta,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: cs.onSurfaceVariant,
                                          ),
                                    ),
                                ],
                              ),
                            ),
                            Checkbox(
                              value: selected,
                              shape: const CircleBorder(),
                              onChanged: (_) => toggle(person.userId),
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
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_selected.length < 2)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          l.messagesGroupMinMembers,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      // A group needs the creator + at least 2 others (1-on-1
                      // chats use the direct-message flow), matching the backend
                      // ArrayMinSize(2) on memberIds.
                      onPressed:
                          _submitting ||
                              _selected.length < 2 ||
                              _nameCtl.text.trim().isEmpty
                          ? null
                          : () async {
                              setState(() => _submitting = true);
                              final messenger = ScaffoldMessenger.of(context);
                              final nav = Navigator.of(context);
                              try {
                                final detail = await ref
                                    .read(messagesRepositoryProvider)
                                    .createGroup(
                                      title: _nameCtl.text.trim(),
                                      memberIds: _selected.toList(
                                        growable: false,
                                      ),
                                    );
                                if (!mounted) return;
                                ref.invalidate(messagesInboxProvider);
                                nav.pop(detail.id);
                              } catch (_) {
                                // Surface failures (e.g. validation, network) as a
                                // snackbar instead of an uncaught fatal error.
                                if (mounted) {
                                  messenger.showSnackBar(
                                    SnackBar(content: Text(l.commonError)),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() => _submitting = false);
                                }
                              }
                            },
                      icon: _submitting
                          ? const CmLoading(size: 18)
                          : const Icon(Icons.group_add_rounded),
                      label: Text(l.messagesCreateGroupAction),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
