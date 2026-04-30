// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        onLeave: _leaveGroup,
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
    required this.onLeave,
  });
  final String threadId;
  final MessageThreadDetail detail;
  final MessagesRepository repo;
  final VoidCallback onRefresh;
  final VoidCallback onLeave;

  @override
  State<_ThreadInfoSheet> createState() => _ThreadInfoSheetState();
}

class _ThreadInfoSheetState extends State<_ThreadInfoSheet> {
  Map<String, dynamic>? _info;
  bool _loading = true;
  String? _error;
  String? _inviteCode;
  bool _generatingCode = false;

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
      final threadInfo = info['thread'] is Map ? Map<String, dynamic>.from(info['thread'] as Map) : <String, dynamic>{};
      setState(() {
        _info = info;
        _inviteCode = threadInfo['inviteCode']?.toString();
        _loading = false;
      });
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

  Set<String> get _memberIds {
    final threadInfo = _info?['thread'] is Map ? Map<String, dynamic>.from(_info!['thread'] as Map) : <String, dynamic>{};
    final members = threadInfo['members'] is List ? (threadInfo['members'] as List) : [];
    return members.map((m) => (m is Map ? m['userId'] : '').toString()).toSet();
  }

  Future<void> _toggleMute() async {
    try {
      final muted = await (widget.repo as ApiMessagesRepository).toggleMuteThread(threadId: widget.threadId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(muted ? 'Notifications muted' : 'Notifications unmuted')),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _blockDm() async {
    final cs = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Block this person?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('They won\'t be able to message you and you won\'t see their messages.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Block'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await widget.repo.blockDirectThread(threadId: widget.threadId);
      widget.onRefresh();
      if (!mounted) return;
      Navigator.of(context).pop();
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

  Future<void> _openAddParticipants() async {
    final added = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (ctx) => _AddParticipantsSheet(
        existingMemberIds: _memberIds,
        repo: widget.repo as ApiMessagesRepository,
      ),
    );
    if (!mounted || added == null || added.isEmpty) return;
    int successCount = 0;
    for (final uid in added) {
      try {
        await (widget.repo as ApiMessagesRepository).addGroupMember(threadId: widget.threadId, userId: uid);
        successCount++;
      } catch (_) {}
    }
    if (!mounted) return;
    if (successCount > 0) {
      _load();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$successCount participant${successCount == 1 ? '' : 's'} added')),
      );
    }
  }

  Future<void> _generateInviteCode() async {
    setState(() => _generatingCode = true);
    try {
      final code = await (widget.repo as ApiMessagesRepository).generateGroupInviteCode(threadId: widget.threadId);
      if (!mounted) return;
      setState(() { _inviteCode = code; _generatingCode = false; });
    } catch (e) {
      if (mounted) setState(() => _generatingCode = false);
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
        threadId: widget.threadId, userId: userId, role: isAdmin ? 'MEMBER' : 'ADMIN',
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
    final members = threadInfo['members'] is List
        ? (threadInfo['members'] as List).map((m) => Map<String, dynamic>.from(m is Map ? m : {})).toList()
        : <Map<String, dynamic>>[];

    return DraggableScrollableSheet(
      initialChildSize: isGroup ? 0.75 : 0.55,
      maxChildSize: 0.95,
      minChildSize: 0.35,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            const SizedBox(height: 8),
            Container(width: 36, height: 4, decoration: BoxDecoration(color: cs.outlineVariant.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            // Avatar + name
            CircleAvatar(
              radius: 36,
              backgroundColor: cs.primaryContainer,
              child: Text(_initials(widget.detail.title), style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: cs.onPrimaryContainer)),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(widget.detail.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800), textAlign: TextAlign.center),
                ),
                if (isGroup && isAdmin)
                  IconButton(onPressed: _renameGroup, icon: const Icon(Icons.edit_rounded, size: 18), visualDensity: VisualDensity.compact),
              ],
            ),
            if (isGroup)
              Text('${members.length} members', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
            const SizedBox(height: 12),

            // Action pills row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mute / Unmute
                  _ActionPill(
                    icon: isMuted ? Icons.notifications_off_rounded : Icons.notifications_rounded,
                    label: isMuted ? 'Unmute' : 'Mute',
                    onTap: _toggleMute,
                    active: isMuted,
                  ),
                  const SizedBox(width: 10),
                  // Block (DM only) or Block member
                  if (!isGroup)
                    _ActionPill(
                      icon: Icons.block_rounded,
                      label: 'Block',
                      onTap: _blockDm,
                      color: cs.error,
                    ),
                  if (isGroup) ...[
                    if (isAdmin) ...[
                      _ActionPill(
                        icon: Icons.person_add_rounded,
                        label: 'Add',
                        onTap: _openAddParticipants,
                      ),
                      const SizedBox(width: 10),
                    ],
                    _ActionPill(
                      icon: Icons.link_rounded,
                      label: _inviteCode != null ? 'Copy code' : 'Invite code',
                      onTap: _inviteCode != null
                          ? () {
                              Clipboard.setData(
                                ClipboardData(text: _inviteCode!),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Code copied: $_inviteCode')),
                              );
                            }
                          : (isAdmin ? _generateInviteCode : null),
                      loading: _generatingCode,
                    ),
                    const SizedBox(width: 10),
                    _ActionPill(
                      icon: Icons.logout_rounded,
                      label: 'Leave',
                      color: cs.error,
                      onTap: () {
                        Navigator.of(context).pop();
                        widget.onLeave();
                      },
                    ),
                  ],
                ],
              ),
            ),

            // Invite code display
            if (_inviteCode != null && isGroup)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.vpn_key_rounded, size: 16, color: cs.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _inviteCode!,
                          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 3, color: cs.primary, fontSize: 15),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _inviteCode!));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invite code copied')));
                        },
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 8),
            const Divider(height: 1),

            // Content: members or participants + people search for add
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(_error!, style: TextStyle(color: cs.error), textAlign: TextAlign.center),
                        ))
                      : isGroup
                          ? ListView(
                              controller: scrollCtrl,
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              children: [
                                // Member list
                                Text('${members.length} members', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, color: cs.onSurfaceVariant, letterSpacing: 0.8)),
                                const SizedBox(height: 6),
                                ...members.map((m) {
                                  final mId = (m['userId'] ?? '').toString();
                                  final mName = (m['name'] ?? '').toString();
                                  final mRole = (m['role'] ?? 'MEMBER').toString();
                                  final mIsAdmin = mRole == 'ADMIN';
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    leading: CircleAvatar(
                                      backgroundColor: mIsAdmin ? cs.primary : cs.primaryContainer,
                                      child: Text(_initials(mName), style: TextStyle(color: mIsAdmin ? cs.onPrimary : cs.onPrimaryContainer, fontWeight: FontWeight.w700, fontSize: 13)),
                                    ),
                                    title: Text(mName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    subtitle: mIsAdmin ? Text('Admin', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700, fontSize: 11)) : null,
                                    trailing: isAdmin ? PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert_rounded),
                                      onSelected: (value) {
                                        if (value == 'promote') _toggleAdmin(mId, mName, mIsAdmin);
                                        if (value == 'kick') _kickMember(mId, mName);
                                      },
                                      itemBuilder: (_) => [
                                        PopupMenuItem(value: 'promote', child: Text(mIsAdmin ? 'Remove admin' : 'Make admin')),
                                        const PopupMenuItem(value: 'kick', child: Text('Remove from group')),
                                      ],
                                    ) : null,
                                  );
                                }),
                              ],
                            )
                          : ListView(
                              controller: scrollCtrl,
                              padding: const EdgeInsets.all(16),
                              children: [
                                for (final p in widget.detail.participants) ...[
                                  ListTile(
                                    leading: CircleAvatar(child: Text(_initials(p.displayName))),
                                    title: Text(p.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    subtitle: p.isAdmin ? Text('Admin', style: TextStyle(color: cs.primary, fontSize: 11, fontWeight: FontWeight.w700)) : null,
                                  ),
                                ],
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
  const _ActionPill({required this.icon, required this.label, required this.onTap, this.color, this.active = false, this.loading = false});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final bool active;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tint = color ?? (active ? cs.primary : cs.onSurfaceVariant);
    final bg = active ? cs.primaryContainer.withValues(alpha: 0.5) : cs.surfaceContainerHighest.withValues(alpha: 0.5);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: tint.withValues(alpha: active ? 0.4 : 0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            loading
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: tint))
                : Icon(icon, color: tint, size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: tint, fontWeight: FontWeight.w700, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ── Add Participants Sheet ────────────────────────────────────────────────────
// Mirrors the forward-target picker style: searchable list, multi-select,
// confirm button that returns the selected user IDs.

class _AddParticipantsSheet extends StatefulWidget {
  const _AddParticipantsSheet({
    required this.existingMemberIds,
    required this.repo,
  });
  final Set<String> existingMemberIds;
  final ApiMessagesRepository repo;

  @override
  State<_AddParticipantsSheet> createState() => _AddParticipantsSheetState();
}

class _AddParticipantsSheetState extends State<_AddParticipantsSheet> {
  final TextEditingController _search = TextEditingController();
  List<MessageDirectoryPerson> _people = const [];
  final Set<String> _selected = {};
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final people = await widget.repo.fetchSameSchoolPeople();
      if (!mounted) return;
      setState(() {
        _people = people.where((p) => !widget.existingMemberIds.contains(p.userId)).toList();
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<MessageDirectoryPerson> get _filtered {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return _people;
    return _people.where((p) =>
      p.displayName.toLowerCase().contains(q) ||
      p.gradeLabel.toLowerCase().contains(q) ||
      p.schoolName.toLowerCase().contains(q),
    ).toList();
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  void _toggle(String userId) {
    setState(() {
      if (_selected.contains(userId)) {
        _selected.remove(userId);
      } else {
        _selected.add(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final filtered = _filtered;
    final n = _selected.length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle + header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: cs.outlineVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Add participants',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (n > 0)
                      FilledButton(
                        onPressed: _submitting ? null : () => Navigator.of(context).pop(_selected.toList()),
                        child: Text(_submitting ? 'Adding…' : 'Add $n'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Search bar
                TextField(
                  controller: _search,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search by name or grade…',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _search.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () => _search.clear(),
                          )
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.55),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const Divider(height: 1),
          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_search_rounded, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.35)),
                            const SizedBox(height: 12),
                            Text(
                              _search.text.isEmpty ? 'No people to add' : 'No results for "${_search.text}"',
                              style: TextStyle(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final p = filtered[i];
                          final selected = _selected.contains(p.userId);
                          final subtitle = [
                            if (p.gradeLabel.isNotEmpty) p.gradeLabel,
                            if (p.schoolName.isNotEmpty) p.schoolName,
                          ].join(' · ');

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _toggle(p.userId),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 120),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? cs.primary.withValues(alpha: 0.10)
                                      : cs.surfaceContainerHighest.withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: selected
                                        ? cs.primary.withValues(alpha: 0.30)
                                        : cs.outlineVariant.withValues(alpha: 0.18),
                                    width: selected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Avatar with gradient
                                    Container(
                                      width: 42, height: 42,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: selected
                                              ? [cs.primary, cs.tertiary]
                                              : [cs.primaryContainer, cs.secondaryContainer],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: Center(
                                        child: Text(
                                          p.initials.trim().isNotEmpty ? p.initials.trim() : _initials(p.displayName),
                                          style: TextStyle(
                                            color: selected ? cs.onPrimary : cs.onPrimaryContainer,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p.displayName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: selected ? cs.primary : cs.onSurface,
                                            ),
                                          ),
                                          if (subtitle.isNotEmpty)
                                            Text(
                                              subtitle,
                                              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                                            ),
                                        ],
                                      ),
                                    ),
                                    // Checkmark
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 150),
                                      child: selected
                                          ? Container(
                                              key: const ValueKey('check'),
                                              width: 28, height: 28,
                                              decoration: BoxDecoration(
                                                color: cs.primary,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(Icons.check_rounded, size: 16, color: cs.onPrimary),
                                            )
                                          : Container(
                                              key: const ValueKey('empty'),
                                              width: 28, height: 28,
                                              decoration: BoxDecoration(
                                                border: Border.all(color: cs.outlineVariant),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          // Bottom confirm bar when items selected
          if (n > 0)
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                decoration: BoxDecoration(
                  color: cs.surface,
                  border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.25))),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submitting ? null : () => Navigator.of(context).pop(_selected.toList()),
                    icon: _submitting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.person_add_rounded),
                    label: Text(_submitting ? 'Adding…' : 'Add $n participant${n == 1 ? '' : 's'}'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
