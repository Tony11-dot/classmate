// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../data/messages_repository.dart';

import '../../../l10n/app_localizations.dart';
import '../../chat_core/controllers/dm_chat_thread_controller.dart';
import '../../chat_core/domain/chat_request_state.dart';
import '../../chat_core/policies/chat_action_policy.dart';
import '../../chat_core/ui/chat_thread_view.dart';
import '../domain/message_thread_models.dart';
import '../providers/messages_repository_provider.dart';

class MessageThreadScreen extends ConsumerStatefulWidget {
  const MessageThreadScreen({super.key, required this.threadId});

  final String threadId;

  @override
  ConsumerState<MessageThreadScreen> createState() =>
      _MessageThreadScreenState();
}

class _MessageThreadScreenState extends ConsumerState<MessageThreadScreen> {
  late final DmChatThreadController _chatController;

  @override
  void initState() {
    super.initState();
    _chatController = DmChatThreadController(
      ref: ref,
      threadId: widget.threadId,
      currentUserId: '',
    );
  }

  Future<void> _blockDirectThread() async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.messagesThreadBlockPersonTitle),
        content: Text(l.messagesThreadBlockPersonBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.classroomDetailCancelTooltip),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.messagesBlockAction),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;
    await ref
        .read(messagesRepositoryProvider)
        .blockDirectThread(threadId: widget.threadId);
    ref.invalidate(messagesInboxProvider);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _leaveGroup() async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.messagesThreadLeaveGroupTitle),
        content: Text(l.messagesThreadLeaveGroupBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.classroomDetailCancelTooltip),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.classroomDetailLeaveAction),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;
    await ref
        .read(messagesRepositoryProvider)
        .leaveGroup(threadId: widget.threadId);
    ref.invalidate(messagesInboxProvider);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  String _avatarText(MessageThreadDetail detail) {
    final title = detail.title.trim();
    if (title.isEmpty) return '?';
    final parts =
        title.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.length >= 2
          ? parts.first.substring(0, 2).toUpperCase()
          : parts.first.toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Future<void> _openThreadInfo(MessageThreadDetail detail) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (ctx) => _ThreadInfoSheet(
        threadId: widget.threadId,
        detail: detail,
        repo: ref.read(messagesRepositoryProvider),
        onRefresh: () {
          ref.invalidate(messageThreadProvider(widget.threadId));
          ref.invalidate(messagesInboxProvider);
        },
      ),
    );
  }

  Future<void> _approveRequest(MessageThreadDetail detail) async {
    try {
      await ref
          .read(messagesRepositoryProvider)
          .approveRequest(threadId: widget.threadId);
      ref.invalidate(messageThreadProvider(widget.threadId));
      ref.invalidate(messagesInboxProvider);
    } catch (_) {
      ref.invalidate(messageThreadProvider(widget.threadId));
      ref.invalidate(messagesInboxProvider);
    }
  }

  Widget _incomingRequestBanner(MessageThreadDetail detail) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final title = detail.isGroup
        ? l.messagesThreadLeaveGroupTitle.replaceFirst('?', '').trim() + '?'
        : l.messagesRequestBannerIncoming;
    final subtitle = detail.isGroup
        ? 'You were invited to join this group.'
        : l.messagesRequestUnlockHint;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.primary.withValues(alpha: 0.20)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(radius: 28, child: Text(_avatarText(detail))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => _approveRequest(detail),
                    child: Text(l.messagesApproveAction),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.invalidate(messagesInboxProvider);
                      if (!mounted) return;
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      detail.isGroup
                          ? l.classroomDetailLeaveAction
                          : l.messagesBlockAction,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pendingBanner(MessageThreadDetail detail) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final title = detail.requestState == ChatRequestState.pendingOutgoing
        ? l.messagesRequestBannerOutgoing
        : l.messagesThreadProfileInfoUnavailable;
    final text = detail.requestState == ChatRequestState.pendingOutgoing
        ? l.messagesThreadWaitingForApproval
        : (detail.requestState == ChatRequestState.blocked
            ? 'You blocked this chat. Unblock from the blocked people list to chat again.'
            : 'You cannot send messages in this chat right now.');

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: scheme.outlineVariant.withValues(alpha: 0.20)),
        ),
        child: Row(
          children: [
            Icon(Icons.schedule_rounded, color: scheme.onSurfaceVariant),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    text,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
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

  @override
  Widget build(BuildContext context) {
    final thread = ref.watch(messageThreadProvider(widget.threadId));

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: thread.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
              child: Text(
                AppLocalizations.of(context)!.messagesRequestLoadFailed(error),
              ),
            ),
          data: (detail) {
            final banners = <Widget>[];
            if (detail.requestState == ChatRequestState.pendingIncoming) {
              banners.add(_incomingRequestBanner(detail));
            }
            if (!detail.canSend ||
                detail.requestState == ChatRequestState.pendingOutgoing) {
              banners.add(_pendingBanner(detail));
            }

            return Column(
              children: [
                AppBar(
                  automaticallyImplyLeading: false,
                  titleSpacing: 0,
                  title: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _openThreadInfo(detail),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                CircleAvatar(child: Text(_avatarText(detail))),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        detail.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w700),
                                      ),
                                      if (detail.subtitle.trim().isNotEmpty)
                                        Text(
                                          detail.subtitle.trim(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        )
                                      else if (detail.isGroup)
                                        Text(
                                          'Tap for group info',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                                              ),
                                        ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    if (!detail.isGroup)
                      IconButton(
                        tooltip: AppLocalizations.of(context)!.messagesThreadBlockPersonTitle,
                        onPressed: _blockDirectThread,
                        icon: const Icon(Icons.block_rounded),
                      ),
                    if (detail.isGroup)
                      IconButton(
                        tooltip: AppLocalizations.of(context)!.messagesThreadLeaveGroupTitle,
                        onPressed: _leaveGroup,
                        icon: const Icon(Icons.logout_rounded),
                      ),
                  ],
                ),
                Expanded(
                  child: ChatThreadView(
                    controller: _chatController,
                    policy: ChatActionPolicy.messages(),
                    canSend: detail.canSend,
                    bannerSlot: banners.isEmpty
                        ? null
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: banners,
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


// ── Thread Info Sheet ────────────────────────────────────────────────────────

class _ThreadInfoSheet extends StatefulWidget {
  const _ThreadInfoSheet({
    required this.threadId,
    required this.detail,
    required this.repo,
    required this.onRefresh,
  });
  final String threadId;
  final MessageThreadDetail detail;
  final MessagesRepository repo;
  final VoidCallback onRefresh;

  @override
  State<_ThreadInfoSheet> createState() => _ThreadInfoSheetState();
}

class _ThreadInfoSheetState extends State<_ThreadInfoSheet> {
  Map<String, dynamic>? _info;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final info = await (widget.repo as ApiMessagesRepository).fetchThreadInfo(threadId: widget.threadId);
      if (!mounted) return;
      setState(() { _info = info; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Future<void> _toggleMute() async {
    try {
      final muted = await (widget.repo as ApiMessagesRepository).toggleMuteThread(threadId: widget.threadId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(muted ? 'Muted' : 'Unmuted')));
      _load();
      widget.onRefresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _renameGroup() async {
    final ctrl = TextEditingController(text: widget.detail.title);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename group', style: TextStyle(fontWeight: FontWeight.w800)),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Group name', border: OutlineInputBorder()), autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await (widget.repo as ApiMessagesRepository).updateGroupTitle(threadId: widget.threadId, title: ctrl.text.trim());
      widget.onRefresh();
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _addMember() async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add member', style: TextStyle(fontWeight: FontWeight.w800)),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Email or user ID', border: OutlineInputBorder()), autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final identifier = ctrl.text.trim();
    if (identifier.isEmpty) return;
    try {
      await (widget.repo as ApiMessagesRepository).addGroupMember(
        threadId: widget.threadId,
        email: identifier.contains('@') ? identifier : null,
        userId: identifier.contains('@') ? null : identifier,
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _kickMember(String userId, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove $name?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error), onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await (widget.repo as ApiMessagesRepository).removeGroupMember(threadId: widget.threadId, userId: userId);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _toggleAdmin(String userId, String name, bool isAdmin) async {
    try {
      await (widget.repo as ApiMessagesRepository).updateMemberRole(
        threadId: widget.threadId,
        userId: userId,
        role: isAdmin ? 'MEMBER' : 'ADMIN',
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final threadInfo = _info?['thread'] is Map ? Map<String, dynamic>.from(_info!['thread'] as Map) : <String, dynamic>{};
    final myRole = (threadInfo['myRole'] ?? 'MEMBER').toString();
    final isAdmin = myRole == 'ADMIN';
    final isMuted = threadInfo['isMuted'] == true;
    final isGroup = widget.detail.isGroup;
    final members = threadInfo['members'] is List ? (threadInfo['members'] as List).map((m) => Map<String, dynamic>.from(m is Map ? m : {})).toList() : <Map<String, dynamic>>[];

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      minChildSize: 0.3,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(width: 36, height: 4, decoration: BoxDecoration(color: cs.outlineVariant.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            // Avatar + name
            CircleAvatar(
              radius: 36,
              backgroundColor: cs.primaryContainer,
              child: Text(
                _initials(widget.detail.title),
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: cs.onPrimaryContainer),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.detail.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                if (isGroup && isAdmin)
                  IconButton(onPressed: _renameGroup, icon: const Icon(Icons.edit_rounded, size: 18)),
              ],
            ),
            if (isGroup)
              Text('${members.length} members', style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: 8),
            // Action pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionPill(icon: isMuted ? Icons.volume_up_rounded : Icons.volume_off_rounded, label: isMuted ? 'Unmute' : 'Mute', onTap: _toggleMute),
                  if (isGroup && isAdmin)
                    _ActionPill(icon: Icons.person_add_rounded, label: 'Add', onTap: _addMember),
                  if (isGroup)
                    _ActionPill(icon: Icons.logout_rounded, label: 'Leave', color: cs.error, onTap: () {
                      Navigator.of(context).pop();
                      // Let the parent handle leave
                    }),
                ],
              ),
            ),
            const Divider(),
            // Members list (for groups)
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!, style: TextStyle(color: cs.error)))
                      : isGroup
                          ? ListView.builder(
                              controller: scrollCtrl,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: members.length,
                              itemBuilder: (ctx2, i) {
                                final m = members[i];
                                final mId = (m['userId'] ?? '').toString();
                                final mName = (m['name'] ?? '').toString();
                                final mRole = (m['role'] ?? 'MEMBER').toString();
                                final mIsAdmin = mRole == 'ADMIN';

                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: cs.primaryContainer,
                                    child: Text(_initials(mName), style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.w700)),
                                  ),
                                  title: Text(mName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: mIsAdmin ? Text('Admin', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700, fontSize: 11)) : null,
                                  trailing: isAdmin ? PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'promote') _toggleAdmin(mId, mName, mIsAdmin);
                                      if (value == 'kick') _kickMember(mId, mName);
                                    },
                                    itemBuilder: (_) => [
                                      PopupMenuItem(value: 'promote', child: Text(mIsAdmin ? 'Demote' : 'Make Admin')),
                                      const PopupMenuItem(value: 'kick', child: Text('Remove from group')),
                                    ],
                                  ) : null,
                                );
                              },
                            )
                          : ListView(
                              controller: scrollCtrl,
                              padding: const EdgeInsets.all(16),
                              children: [
                                LiquidGlassCard(
                                  padding: const EdgeInsets.all(16),
                                  borderRadius: BorderRadius.circular(16),
                                  blurSigma: 10,
                                  color: cs.surface.withValues(alpha: 0.8),
                                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
                                  child: Column(
                                    children: [
                                      for (final p in widget.detail.participants)
                                        ListTile(
                                          leading: CircleAvatar(child: Text(_initials(p.displayName))),
                                          title: Text(p.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                          subtitle: p.isAdmin ? Text('Admin', style: TextStyle(color: cs.primary, fontSize: 11, fontWeight: FontWeight.w700)) : null,
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
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({required this.icon, required this.label, required this.onTap, this.color});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tint = color ?? cs.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: tint.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tint.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: tint, size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: tint, fontWeight: FontWeight.w700, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
