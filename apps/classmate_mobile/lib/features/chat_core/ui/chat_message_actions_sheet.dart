import 'package:flutter/material.dart';

class ChatMessageActionsSheet extends StatelessWidget {
  const ChatMessageActionsSheet({
    super.key,
    required this.canEdit,
    required this.canDelete,
    this.canViewInfo = false,
    this.canPin = false,
    this.canForward = true,
  });

  final bool canEdit;
  final bool canDelete;
  final bool canViewInfo;
  final bool canPin;
  final bool canForward;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.reply_rounded),
            title: const Text('Reply'),
            onTap: () => Navigator.of(context).pop('reply'),
          ),
          ListTile(
            leading: const Icon(Icons.emoji_emotions_outlined),
            title: const Text('React'),
            onTap: () => Navigator.of(context).pop('react'),
          ),
          if (canForward)
            ListTile(
              leading: const Icon(Icons.forward_rounded),
              title: const Text('Forward'),
              onTap: () => Navigator.of(context).pop('forward'),
            ),
          if (canPin)
            ListTile(
              leading: const Icon(Icons.push_pin_outlined),
              title: const Text('Pin'),
              onTap: () => Navigator.of(context).pop('pin'),
            ),
          if (canViewInfo)
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('Message info'),
              onTap: () => Navigator.of(context).pop('info'),
            ),
          if (canEdit)
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Edit'),
              onTap: () => Navigator.of(context).pop('edit'),
            ),
          if (canDelete)
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: const Text('Delete'),
              onTap: () => Navigator.of(context).pop('delete'),
            ),
        ],
      ),
    );
  }
}
