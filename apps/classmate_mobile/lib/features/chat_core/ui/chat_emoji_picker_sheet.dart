import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class ChatEmojiPickerSheet extends StatefulWidget {
  const ChatEmojiPickerSheet({
    super.key,
    this.allowedEmojis,
  });

  final List<String>? allowedEmojis;

  static Future<String?> show(
    BuildContext context, {
    List<String>? allowedEmojis,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ChatEmojiPickerSheet(allowedEmojis: allowedEmojis),
    );
  }

  @override
  State<ChatEmojiPickerSheet> createState() => _ChatEmojiPickerSheetState();
}

class _ChatEmojiPickerSheetState extends State<ChatEmojiPickerSheet> {
  static const List<String> _allEmojis = <String>[
    // core reactions
    '❤️', '👍', '😂', '😮', '😢', '🙏', '🔥', '🎉',
    '👏', '😍', '🤔', '✅', '👀', '😁', '😎', '🤝',
    '💯', '🙌', '😅', '😡', '🥲', '🤯', '🙂', '🤍',
    // hearts & colors
    '💙', '💚', '💛', '🧡', '💜', '🖤', '🤎', '❤️‍🔥',
    // hands & people
    '🫶', '👌', '🤌', '🫡', '🤙', '☝️', '🤞', '🫰',
    '✌️', '🤟', '🤘', '👋', '🙏', '🤲', '👐', '🫴',
    // faces
    '😀', '😃', '😄', '🥳', '🥰', '😘', '😗', '😙',
    '🤩', '😏', '🥸', '😶', '🫠', '😬', '🙄', '😳',
    '🥹', '😤', '😠', '🤬', '😈', '👿', '😱', '😨',
    // nature & objects
    '🚀', '⭐', '🌟', '💫', '✨', '💥', '🎯', '🏆',
    '💡', '🎵', '🎶', '📚', '💻', '📱', '🔑', '💎',
    // symbols
    '✔️', '❌', '❓', '❗', '💬', '💭', '👁️', '🔔',
  ];

  final TextEditingController _searchCtl = TextEditingController();

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final allowed = widget.allowedEmojis;
    final pool = allowed == null || allowed.isEmpty
        ? _allEmojis
        : _allEmojis.where((emoji) => allowed.contains(emoji)).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            final q = _searchCtl.text.trim();
            final filtered = q.isEmpty
                ? pool
                : pool.where((emoji) => emoji.contains(q)).toList();

            return SizedBox(
              height: 420,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.chatEmojiPickerTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchCtl,
                    onChanged: (_) => setSheetState(() {}),
                    decoration: InputDecoration(
                      hintText: l.chatEmojiPickerSearchHint,
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchCtl.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: l.a11yClear,
                              onPressed: () {
                                _searchCtl.clear();
                                setSheetState(() {});
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(child: Text(l.chatEmojiPickerEmptyState))
                        : GridView.builder(
                            itemCount: filtered.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 1.12,
                            ),
                            itemBuilder: (context, index) {
                              final emoji = filtered[index];
                              return InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => Navigator.of(context).pop(emoji),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest
                                        .withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant
                                          .withValues(alpha: 0.18),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
