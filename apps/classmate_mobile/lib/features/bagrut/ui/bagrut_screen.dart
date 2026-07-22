import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
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
    final cs = Theme.of(context).colorScheme;

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
              child: TextField(
                decoration: InputDecoration(
                  hintText: l.bagrutSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
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
                return Material(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    // Root navigator → full-screen (covers the shell top bar);
                    // Cupertino route → back chevron + edge-swipe to leave.
                    onTap: () => Navigator.of(context, rootNavigator: true).push(
                      CupertinoPageRoute<void>(
                        builder: (_) => BagrutExamsScreen(subjectKey: s.key),
                      ),
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
                          Text(
                            s.title(locale),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
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
