import 'package:flutter/material.dart';
import '../../core/ui/cm_scaffold.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key, required this.role});
  final String role;

  @override
  Widget build(BuildContext context) {
    return const CMEmpty(
      title: 'Messages (next)',
      subtitle: 'We’ll wire inbox + send once backend endpoints are added.',
    );
  }
}
