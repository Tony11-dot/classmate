import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class ClassroomChatMediaSheet extends StatelessWidget {
  const ClassroomChatMediaSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    Widget tile({
      required IconData icon,
      required String title,
      required String subtitle,
    }) {
      return ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: () => Navigator.of(context).pop(),
      );
    }

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          tile(
            icon: Icons.photo_library_rounded,
            title: l.classroomChatMediaSendPhoto,
            subtitle: l.classroomChatMediaSendPhotoSubtitle,
          ),
          tile(
            icon: Icons.mic_rounded,
            title: l.classroomChatMediaSendVoiceMessage,
            subtitle: l.classroomChatMediaSendVoiceMessageSubtitle,
          ),
        ],
      ),
    );
  }
}
