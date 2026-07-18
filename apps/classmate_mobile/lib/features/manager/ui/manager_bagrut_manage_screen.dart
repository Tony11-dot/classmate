import 'package:flutter/material.dart';

import '../../bagrut/domain/bagrut_subjects.dart';
import 'manager_bagrut_exams_screen.dart';

/// Manager Bagrut tab — pick a subject to manage its past exams.
class ManagerBagrutManageScreen extends StatelessWidget {
  const ManagerBagrutManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Bagrut')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          mainAxisExtent: 120,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: kBagrutSubjects.length,
        itemBuilder: (context, i) {
          final s = kBagrutSubjects[i];
          return Material(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => ManagerBagrutExamsScreen(subjectKey: s.key)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: cs.primaryContainer,
                      child: Icon(s.icon, color: cs.onPrimaryContainer),
                    ),
                    Text(s.title(locale),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
