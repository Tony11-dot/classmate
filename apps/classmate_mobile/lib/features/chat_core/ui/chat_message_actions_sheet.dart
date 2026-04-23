import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'chat_emoji_picker_sheet.dart';
import '../../messages/ui/components/message_reaction_bar.dart';

class ChatMessageActionsSheet extends StatelessWidget {
  const ChatMessageActionsSheet({
    super.key,
    required this.canEdit,
    required this.canDelete,
    required this.canViewInfo,
    required this.canPin,
    this.pinLabel,
    required this.canForward,
    required this.canCopy,
    required this.pickerAllowedEmojis,
  });

  final bool canEdit;
  final bool canDelete;
  final bool canViewInfo;
  final bool canPin;
  final String? pinLabel;
  final bool canForward;
  final bool canCopy;
  final List<String>? pickerAllowedEmojis;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final maxHeight = MediaQuery.of(context).size.height * 0.72;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: MessageReactionBar(
                      onReact: (emoji) =>
                          Navigator.of(context).pop('react:$emoji'),
                      onOpenPicker: () async {
                        final picked = await ChatEmojiPickerSheet.show(
                          context,
                          allowedEmojis: null,
                        );
                        if (!context.mounted) return;
                        if ((picked ?? '').trim().isEmpty) return;
                        Navigator.of(context).pop('react:${picked!.trim()}');
                      },
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.reply_rounded),
                title: Text(l.chatComposerReplyFallback),
                onTap: () => Navigator.of(context).pop('reply'),
              ),
              if (canCopy)
                ListTile(
                  leading: const Icon(Icons.copy_rounded),
                  title: Text(l.tutorCopy),
                  onTap: () => Navigator.of(context).pop('copy'),
                ),
              if (canForward)
                ListTile(
                  leading: const Icon(Icons.forward_rounded),
                  title: Text(l.classroomsForwardAction),
                  onTap: () => Navigator.of(context).pop('forward'),
                ),
              if (canPin)
                ListTile(
                  leading: const Icon(Icons.push_pin_outlined),
                  title: Text(pinLabel ?? l.classroomDetailPinAction),
                  onTap: () => Navigator.of(context).pop('pin'),
                ),
              if (canViewInfo)
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: Text(l.classroomDetailMessageInfoTitle),
                  onTap: () => Navigator.of(context).pop('info'),
                ),
              if (canEdit)
                ListTile(
                  leading: const Icon(Icons.edit_rounded),
                  title: Text(l.classroomDetailEditMessageTitle),
                  onTap: () => Navigator.of(context).pop('edit'),
                ),
              if (canDelete)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded),
                  title: Text(l.chatContextDelete),
                  onTap: () => Navigator.of(context).pop('delete'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
