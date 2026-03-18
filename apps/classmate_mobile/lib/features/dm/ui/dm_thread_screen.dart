import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  final input = TextEditingController();

  Future<void> _pickImageMode() async {
    await showModalBottomSheet<DmMediaMode>(
      context: context,
      showDragHandle: true,
      builder: (_) => const DmMediaModeSheet(),
    );
  }

  Future<void> _pickVoiceMode() async {
    await showModalBottomSheet<DmMediaMode>(
      context: context,
      showDragHandle: true,
      builder: (_) => const DmMediaModeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(dmMessagesProvider(widget.threadId));
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            onPressed: () => context.push('/profile'),
            icon: const Icon(Icons.person_rounded),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.block_rounded)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(error.toString())),
              data: (messages) => ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
                itemCount: messages.length,
                itemBuilder: (_, i) => _Bubble(message: messages[i]),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(
                top: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.22),
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _pickImageMode,
                  icon: const Icon(Icons.photo_rounded),
                ),
                IconButton(
                  onPressed: _pickVoiceMode,
                  icon: const Icon(Icons.mic_rounded),
                ),
                Expanded(
                  child: TextField(
                    controller: input,
                    decoration: const InputDecoration(
                      hintText: 'Message...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {},
                  child: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});
  final DmMessage message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final align = message.isMine ? Alignment.centerRight : Alignment.centerLeft;
    final bg = message.isMine
        ? cs.primaryContainer.withValues(alpha: 0.92)
        : cs.surfaceContainerHighest.withValues(alpha: 0.92);

    String mediaLabel() {
      if (message.mediaMode == DmMediaMode.once) return 'VIEW ONCE';
      if (message.mediaMode == DmMediaMode.replay) return 'ALLOW REPLAY';
      if (message.mediaMode == DmMediaMode.keep) return 'KEEP IN CHAT';
      return '';
    }

    Widget content;
    switch (message.kind) {
      case DmMessageKind.image:
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              width: 180,
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.image_rounded, size: 42),
            ),
            const SizedBox(height: 8),
            Text(
              mediaLabel(),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
            if (message.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(message.text),
            ],
          ],
        );
        break;
      case DmMessageKind.voice:
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_arrow_rounded),
            const SizedBox(width: 6),
            Text('${message.voiceDuration?.inSeconds ?? 0}s'),
            const SizedBox(width: 10),
            Text(
              mediaLabel(),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ],
        );
        break;
      default:
        content = Text(message.text);
    }

    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: const BoxConstraints(maxWidth: 290),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isMine)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  message.senderName,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
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
                          color: cs.surface.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(999),
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
              children: const [
                _ReactionButton('👍'),
                _ReactionButton('❤️'),
                _ReactionButton('🔥'),
                _ReactionButton('😂'),
                _ReactionButton('😮'),
                _ReactionButton('✅'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  const _ReactionButton(this.emoji);
  final String emoji;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(emoji),
    );
  }
}
