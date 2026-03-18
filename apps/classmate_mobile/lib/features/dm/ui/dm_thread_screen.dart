import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/dm_repository.dart';
import '../domain/dm_models.dart';
import '../providers/dm_providers.dart';
import 'widgets/dm_media_mode_sheet.dart';

class DmThreadScreen extends ConsumerStatefulWidget {
  const DmThreadScreen({super.key, required this.threadId});
  final String threadId;

  @override
  ConsumerState<DmThreadScreen> createState() => _DmThreadScreenState();
}

class _DmThreadScreenState extends ConsumerState<DmThreadScreen> {
  final composer = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final threadsAsync = ref.watch(dmThreadsProvider);
    final messagesAsync = ref.watch(dmMessagesProvider(widget.threadId));
    final repo = ref.read(dmRepositoryProvider);
    final cs = Theme.of(context).colorScheme;

    return threadsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (threads) {
        final meta = threads.firstWhere(
          (e) => e.id == widget.threadId,
          orElse: () => threads.first,
        );

        if (meta.requestState == DmRequestState.pendingIncoming) {
          return Scaffold(
            appBar: AppBar(title: Text(meta.title)),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Message request',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${meta.title} wants to start a chat with you.',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/profile'),
                        icon: const Icon(Icons.person_outline_rounded),
                        label: const Text('Open profile'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await repo.blockUser(widget.threadId);
                                ref.invalidate(dmThreadsProvider);
                              },
                              icon: const Icon(Icons.block_rounded),
                              label: const Text('Block'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () async {
                                await repo.acceptRequest(widget.threadId);
                                ref.invalidate(dmThreadsProvider);
                              },
                              icon: const Icon(Icons.check_rounded),
                              label: const Text('Accept'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(meta.title),
            actions: [
              IconButton(
                onPressed: () async {
                  if (meta.isBlocked) {
                    await repo.unblockUser(widget.threadId);
                  } else {
                    await repo.blockUser(widget.threadId);
                  }
                  ref.invalidate(dmThreadsProvider);
                },
                icon: Icon(
                  meta.isBlocked
                      ? Icons.lock_open_rounded
                      : Icons.block_rounded,
                ),
              ),
              IconButton(
                onPressed: () => context.push('/profile'),
                icon: const Icon(Icons.person_outline_rounded),
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
                child: Wrap(
                  spacing: 8,
                  children: [
                    const _TopPill(label: 'Rich reactions'),
                    _TopPill(
                      label: meta.isGroup ? 'Group chat' : 'Direct chat',
                    ),
                    _TopPill(label: meta.isBlocked ? 'Blocked' : 'Live'),
                  ],
                ),
              ),
              Expanded(
                child: messagesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('$e')),
                  data: (messages) => ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final message = messages[i];
                      final content = switch (message.kind) {
                        DmMessageKind.image => _ImageBubble(message: message),
                        DmMessageKind.voice => _VoiceBubble(message: message),
                        _ => Text(message.text),
                      };

                      return Align(
                        alignment: message.isMine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 320),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: message.isMine
                                ? cs.primaryContainer.withValues(alpha: 0.9)
                                : cs.surfaceContainerHighest.withValues(
                                    alpha: 0.75,
                                  ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (message.text.isNotEmpty &&
                                  message.kind != DmMessageKind.text) ...[
                                Text(message.text),
                                const SizedBox(height: 8),
                              ],
                              content,
                              if (message.reactions.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  children: message.reactions
                                      .map(
                                        (e) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: cs.surface.withValues(
                                              alpha: 0.9,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Text(e),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                children: ['👍', '❤️', '🔥', '😂', '😮', '✅']
                                    .map((emoji) {
                                      return InkWell(
                                        onTap: () async {
                                          await repo.react(message.id, emoji);
                                          ref.invalidate(
                                            dmMessagesProvider(widget.threadId),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: cs.surface.withValues(
                                              alpha: 0.88,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Text(emoji),
                                        ),
                                      );
                                    })
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          final mode = await showModalBottomSheet<DmMediaMode>(
                            context: context,
                            showDragHandle: true,
                            builder: (_) => const DmMediaModeSheet(),
                          );
                          if (mode == null) return;
                          final picked = await FilePicker.platform.pickFiles(
                            type: FileType.image,
                          );
                          final path = picked?.files.single.path;
                          if (path == null || path.trim().isEmpty) return;
                          await repo.sendImage(widget.threadId, path, mode);
                          ref.invalidate(dmMessagesProvider(widget.threadId));
                          ref.invalidate(dmThreadsProvider);
                        },
                        icon: const Icon(Icons.image_outlined),
                      ),
                      IconButton(
                        onPressed: () async {
                          final mode = await showModalBottomSheet<DmMediaMode>(
                            context: context,
                            showDragHandle: true,
                            builder: (_) => const DmMediaModeSheet(),
                          );
                          if (mode == null) return;
                          final picked = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: const [
                              'm4a',
                              'aac',
                              'mp3',
                              'wav',
                            ],
                          );
                          final path = picked?.files.single.path;
                          if (path == null || path.trim().isEmpty) return;
                          await repo.sendVoice(widget.threadId, path, mode);
                          ref.invalidate(dmMessagesProvider(widget.threadId));
                          ref.invalidate(dmThreadsProvider);
                        },
                        icon: const Icon(Icons.mic_none_rounded),
                      ),
                      Expanded(
                        child: TextField(
                          controller: composer,
                          decoration: InputDecoration(
                            hintText: meta.isGroup
                                ? 'Message group'
                                : 'Message',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          final text = composer.text.trim();
                          if (text.isEmpty) return;
                          await repo.sendText(widget.threadId, text);
                          composer.clear();
                          ref.invalidate(dmMessagesProvider(widget.threadId));
                          ref.invalidate(dmThreadsProvider);
                        },
                        style: FilledButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(14),
                        ),
                        child: const Icon(Icons.send_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ImageBubble extends StatelessWidget {
  const _ImageBubble({required this.message});
  final DmMessage message;

  @override
  Widget build(BuildContext context) {
    final label = switch (message.mediaMode) {
      DmMediaMode.once => 'View once',
      DmMediaMode.replay => 'Replay allowed',
      DmMediaMode.keep => 'Kept in chat',
      null => 'Media',
    };

    return Container(
      width: 220,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Stack(
        children: [
          const Center(child: Icon(Icons.image_rounded, size: 48)),
          Positioned(
            right: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceBubble extends StatelessWidget {
  const _VoiceBubble({required this.message});
  final DmMessage message;

  @override
  Widget build(BuildContext context) {
    final mode = switch (message.mediaMode) {
      DmMediaMode.once => 'once',
      DmMediaMode.replay => 'replay',
      DmMediaMode.keep => 'keep',
      null => 'voice',
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.play_arrow_rounded),
          const SizedBox(width: 8),
          Text(
            message.voiceDuration == null
                ? 'Voice • --:--'
                : 'Voice • ${message.voiceDuration!.inSeconds}s',
          ),
          const SizedBox(width: 8),
          Text(
            mode,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopPill extends StatelessWidget {
  const _TopPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }
}
