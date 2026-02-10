import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../ui/adaptive.dart";
import 'package:flutter/material.dart';
import '../../demo/demo_store.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final insights = DemoStore.generateInsights();
    final u = DemoStore.user;
    final done = DemoStore.assignments.where((a) => a.submitted).length;

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text(
          'AI Insights',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        AdaptiveCard(
          child: ListTile(
            leading: const Icon(Icons.person_outline_rounded),
            title: Text(
              '${u.name} • Grade ${u.grade}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text(
              'Points: ${u.points} • Tasks done: $done/${DemoStore.assignments.length}',
            ),
          ),
        ),
        const SizedBox(height: 10),
        for (final i in insights)
          AdaptiveCard(
            child: ListTile(
              leading: Icon(_icon(i.level)),
              title: Text(
                i.title,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(i.body),
            ),
          ),
        const SizedBox(height: 10),
        AdaptiveCard(
          child: ListTile(
            leading: const Icon(Icons.checklist_rounded),
            title: const Text(
              'Recommended next step',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: const Text(
              'Tap “Solutions” to see guided tasks with rewards.',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).pushNamed('/solutions'),
          ),
        ),
      ],
    );
  }

  IconData _icon(String level) {
    switch (level) {
      case 'risk':
        return Icons.error_outline_rounded;
      case 'warn':
        return Icons.warning_amber_rounded;
      default:
        return Icons.verified_outlined;
    }
  }
}
