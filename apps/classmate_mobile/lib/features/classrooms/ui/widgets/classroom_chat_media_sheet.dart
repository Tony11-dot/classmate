import 'package:flutter/material.dart';

class ClassroomChatMediaSheet extends StatelessWidget {
  const ClassroomChatMediaSheet({super.key});

  @override
  Widget build(BuildContext context) {
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
            title: 'Send photo',
            subtitle: 'Share an image in the classroom chat',
          ),
          tile(
            icon: Icons.mic_rounded,
            title: 'Send voice message',
            subtitle: 'Record and send a voice note',
          ),
        ],
      ),
    );
  }
}
