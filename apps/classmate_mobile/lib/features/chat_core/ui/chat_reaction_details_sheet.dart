import 'package:flutter/material.dart';

import 'chat_emoji_picker_sheet.dart';

class ChatReactionDetailsSheet extends StatelessWidget {
  const ChatReactionDetailsSheet({
    super.key,
    this.myReaction,
    required this.reactionUsers,
    this.pickerAllowedEmojis,
  });

  final String? myReaction;
  final Map<String, List<String>> reactionUsers;
  final List<String>? pickerAllowedEmojis;

  static Future<String?> show(
    BuildContext context, {
    String? myReaction,
    Map<String, List<String>> reactionUsers = const <String, List<String>>{},
    List<String>? pickerAllowedEmojis,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ChatReactionDetailsSheet(
        myReaction: myReaction,
        reactionUsers: reactionUsers,
        pickerAllowedEmojis: pickerAllowedEmojis,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = <({String emoji, bool isMine, int count})>[];
    final seen = <String>{};

    final mine = (myReaction ?? '').trim();
    if (mine.isNotEmpty) {
      final count = (reactionUsers[mine] ?? const <String>[]).length;
      rows.add((
        emoji: mine,
        isMine: true,
        count: count > 0 ? count : 1,
      ));
      seen.add(mine);
    }

    for (final entry in reactionUsers.entries) {
      final emoji = entry.key.trim();
      if (emoji.isEmpty || seen.contains(emoji)) continue;
      rows.add((
        emoji: emoji,
        isMine: false,
        count: entry.value.length,
      ));
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Reactions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                IconButton(
                  tooltip: 'Add reaction',
                  onPressed: () async {
                    final picked = await ChatEmojiPickerSheet.show(
                      context,
                      allowedEmojis: pickerAllowedEmojis,
                    );
                    if (!context.mounted) return;
                    if ((picked ?? '').trim().isEmpty) return;
                    Navigator.of(context).pop(picked!.trim());
                  },
                  icon: const Icon(Icons.add_reaction_outlined),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (rows.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No reactions yet')),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: rows.length,
                  separatorBuilder: (_, value) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final row = rows[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: row.isMine
                          ? () => Navigator.of(context).pop('__remove__')
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: row.isMine
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.10)
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.50),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: row.isMine
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.22)
                                : Theme.of(context)
                                    .colorScheme
                                    .outlineVariant
                                    .withValues(alpha: 0.16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(row.emoji, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                row.isMine
                                    ? 'You${row.count > 1 ? ' · ${row.count}' : ''}'
                                    : row.count > 1
                                        ? '${row.count} reactions'
                                        : 'Reaction',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            if (row.isMine)
                              Text(
                                'Tap to remove',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                          ],
                        ),
                      ),
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
