import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../providers/messages_repository_provider.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../ui/widgets/cm_refresh_indicator.dart';

class BlockedPeopleScreen extends ConsumerStatefulWidget {
  const BlockedPeopleScreen({super.key});

  @override
  ConsumerState<BlockedPeopleScreen> createState() => _BlockedPeopleScreenState();
}

class _BlockedPeopleScreenState extends ConsumerState<BlockedPeopleScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(messagesRepositoryProvider).listBlockedPeople();
  }

  Future<void> _reload() async {
    setState(() {
      _future = ref.read(messagesRepositoryProvider).listBlockedPeople();
    });
  }

  Future<void> _unblock(Map<String, dynamic> item) async {
    final l = AppLocalizations.of(context)!;
    final threadId = (item['threadId'] ?? '').toString().trim();
    final name = (item['displayName'] ?? l.messagesBlockedPersonFallback)
        .toString()
        .trim();
    if (threadId.isEmpty) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.messagesUnblockPersonTitle),
        content: Text(l.messagesUnblockPersonBody(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.classroomDetailCancelTooltip),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.messagesUnblockAction),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    await ref.read(messagesRepositoryProvider).unblockDirectThread(
      threadId: threadId,
    );

    if (!mounted) return;
    // Refresh the inbox too — the thread was filtered out while blocked, so
    // without this it stays missing until an app restart (QA #2).
    ref.invalidate(messagesInboxProvider);
    await _reload();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.messagesUnblockedToast(name))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      // Full-screen — no AppBar. A small floating back chevron + heading sits
      // inside SafeArea; the screen is pushed as a CupertinoPage so the
      // left-edge swipe-back works too. The GestureDetector adds a
      // swipe-from-anywhere "swipe to leave": a rightward fling pops the
      // page (the list only scrolls vertically, so there's no conflict).
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: (details) {
          final v = details.primaryVelocity ?? 0;
          if (v > 250) Navigator.of(context).maybePop();
        },
        child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    tooltip: l.a11yBack,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      l.messagesBlockedPeopleTitle,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CmLoading());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l.messagesBlockedPeopleLoadFailed(snapshot.error.toString()),
                ),
              ),
            );
          }

          final items = snapshot.data ?? const <Map<String, dynamic>>[];
          if (items.isEmpty) {
            return Center(child: Text(l.messagesNoBlockedPeople));
          }

          return CmRefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                final name = (item['displayName'] ?? l.messagesUnknownUser)
                    .toString()
                    .trim();
                final initials = (item['initials'] ?? '?').toString().trim().replaceAll(',', '');

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(initials.isEmpty ? '?' : initials)),
                    title: Text(name.isEmpty ? l.messagesUnknownUser : name),
                    trailing: FilledButton(
                      onPressed: () => _unblock(item),
                      child: Text(l.messagesUnblockAction),
                    ),
                  ),
                );
              },
            ),
          );
        },
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
