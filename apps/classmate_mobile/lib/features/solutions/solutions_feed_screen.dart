import 'package:flutter/material.dart';
import '../../core/ui/cm_scaffold.dart';

class SolutionsFeedScreen extends StatelessWidget {
  const SolutionsFeedScreen({super.key, required this.role});
  final String role;

  @override
  Widget build(BuildContext context) {
    return const CMEmpty(
      title: 'Solutions feed (next)',
      subtitle: 'We’ll wire real upload + feed once backend endpoints are added.',
    );
  }
}
