import 'package:flutter/material.dart';
import '../../core/ui/cm_scaffold.dart';

class TutorScreen extends StatelessWidget {
  const TutorScreen({super.key, required this.role});
  final String role;

  @override
  Widget build(BuildContext context) {
    return const CMEmpty(
      title: 'AI Tutor (next)',
      subtitle: 'We’ll wire sessions + chat once backend endpoints are added.',
    );
  }
}
