import 'package:flutter/material.dart';

class MessageReactionBar extends StatelessWidget {
  final Function(String) onReact;

  const MessageReactionBar({super.key, required this.onReact});

  @override
  Widget build(BuildContext context) {
    final reactions = ["🔥", "😂", "👍", "❤️", "👏", "😭"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: reactions.map((r) {
        return GestureDetector(
          onTap: () => onReact(r),
          child: Text(r, style: const TextStyle(fontSize: 20)),
        );
      }).toList(),
    );
  }
}
