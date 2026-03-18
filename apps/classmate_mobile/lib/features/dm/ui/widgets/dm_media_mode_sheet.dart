import 'package:flutter/material.dart';
import '../../domain/dm_models.dart';

class DmMediaModeSheet extends StatelessWidget {
  const DmMediaModeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    Widget tile(DmMediaMode mode, String title, String subtitle) {
      return ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: () => Navigator.of(context).pop(mode),
      );
    }

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          tile(DmMediaMode.once, 'View once', 'Opens once, then expires'),
          tile(DmMediaMode.replay, 'Allow replay', 'Can be replayed again'),
          tile(DmMediaMode.keep, 'Keep in chat', 'Stays in the conversation'),
        ],
      ),
    );
  }
}
