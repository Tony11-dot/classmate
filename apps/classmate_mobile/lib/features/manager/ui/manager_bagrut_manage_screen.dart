import 'package:flutter/material.dart';

import '../../../core/theme/cm_tokens.dart';
import '../../../ui/widgets/cm_surfaces.dart';
import '../../bagrut/domain/bagrut_subjects.dart';
import 'manager_bagrut_exams_screen.dart';

/// Manager Bagrut tab — pick a subject to manage its past exams.
class ManagerBagrutManageScreen extends StatelessWidget {
  const ManagerBagrutManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
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
          return CmCard(
            radius: CmTokens.radiusLg,
            padding: const EdgeInsets.all(16),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => ManagerBagrutExamsScreen(subjectKey: s.key)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CmIconTile(icon: s.icon, size: 46),
                Text(
                  s.title(locale),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
