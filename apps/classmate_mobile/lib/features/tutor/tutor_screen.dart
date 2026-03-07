import 'package:flutter/material.dart';
import 'ui/tutor_home_screen.dart';

class TutorScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return TutorHomeScreen(
      initialPrompt: initialPrompt,
      initialSubject: initialSubject,
      initialTitle: initialTitle,
    );
  }
}
