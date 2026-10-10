import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/cm_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/cm_surfaces.dart';
import '../../bagrut/domain/bagrut_subjects.dart';
import 'manager_bagrut_exams_screen.dart';

/// Manager Bagrut tab — pick a subject to manage its past exams.
class ManagerBagrutManageScreen extends StatelessWidget {
  const ManagerBagrutManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    // Tiles grow with the system text size instead of clipping the subject
    // name (same rule as the student Bagrut grid).
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.navBagrut)),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          mainAxisExtent: math.max(120, 32 + 46 + 10 + 2 * 20 * scale),
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
