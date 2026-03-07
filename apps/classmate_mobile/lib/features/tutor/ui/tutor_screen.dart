import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'nova_chat_screen.dart';
import 'tutor_home_screen.dart';

class TutorScreen extends ConsumerWidget {
  const TutorScreen({
    super.key,
    this.initialPrompt,
    this.initialSubject,
    this.initialTitle,
  });

  final String? initialPrompt;
  final String? initialSubject;
  final String? initialTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prompt = (initialPrompt ?? '').trim();
    final title = (initialTitle ?? '').trim();

    if (prompt.isNotEmpty) {
      return NovaChatScreen(
        initialPrompt: prompt,
        initialTitle: title.isEmpty ? 'NOVA Explain' : title,
      );
    }

    return TutorHomeScreen(
      initialPrompt: initialPrompt,
      initialSubject: initialSubject,
      initialTitle: initialTitle,
    );
  }
}
