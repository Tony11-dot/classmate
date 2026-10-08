import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';

import '../../../ui/widgets/cm_search_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/util/subject_color.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/cm_surfaces.dart';
import '../domain/bagrut_subjects.dart';
import 'bagrut_exams_screen.dart';

/// Browse entry point — the subject grid. Shown to students & teachers via the
/// "School Tools" drawer, mirroring the Solutions library.
class BagrutScreen extends ConsumerStatefulWidget {
  const BagrutScreen({super.key});

  @override
  ConsumerState<BagrutScreen> createState() => _BagrutScreenState();
}

class _BagrutScreenState extends ConsumerState<BagrutScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    final subjects = kBagrutSubjects.where((s) {
      final q = _query.trim().toLowerCase();
      if (q.isEmpty) return true;
      return s.en.toLowerCase().contains(q) || s.he.contains(_query.trim());
    }).toList();

    // No AppBar here — this screen lives inside the AppShell, whose top bar
    // (hamburger / logo / title pill) stays visible, mirroring Solutions.
    // The search field is a sliver INSIDE the scroll view, so it rides up
    // and away with the subject grid instead of staying pinned.
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: CmSearchField(
                hint: l.bagrutSearchHint,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
          ),
          if (subjects.isEmpty)
            SliverToBoxAdapter(
              child: CmEmptyState(icon: Icons.search_off_rounded, title: l.bagrutSearchHint),
            ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisExtent: 120,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                childCount: subjects.length,
                (context, i) {
                final s = subjects[i];
                final tone = subjectColorOrFallback(null, s.en);
                return CmCard(
                  tint: tone,
                  padding: const EdgeInsets.all(14),
                  // Root navigator → full-screen (covers the shell top bar);
                  // Cupertino route → back chevron + edge-swipe to leave.
                  onTap: () => Navigator.of(context, rootNavigator: true).push(
                    CupertinoPageRoute<void>(
                      builder: (_) => BagrutExamsScreen(subjectKey: s.key),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CmIconTile(icon: s.icon, color: tone, size: 44, filled: true),
                      Text(
                        s.title(locale),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                      ),
                    ],
                  ),
                );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
