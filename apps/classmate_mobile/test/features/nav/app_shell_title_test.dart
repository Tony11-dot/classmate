import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:classmate_mobile/app/shell/app_shell.dart';
import 'package:classmate_mobile/l10n/app_localizations.dart';
import 'package:classmate_mobile/ui/nav/drawer_tools_order.dart';

/// The title pill in the top-right names the tab you're on. It's driven by
/// [AppShell.titleForLocation], and a route that appears in a role's prefix list
/// but has no case in that role's title switch silently falls through to the
/// role default — which is how the whole ClassNotes tab showed "Schedule".
///
/// So: every drawer destination must produce its OWN title.
void main() {
  Future<AppLocalizations> localizations(WidgetTester tester) async {
    late AppLocalizations l;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            l = AppLocalizations.of(context)!;
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    return l;
  }

  Future<String> titleFor(
    WidgetTester tester,
    String location, {
    bool isTeacherLike = false,
    bool isAdminLike = false,
    bool isParent = false,
  }) async {
    late String title;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            title = AppShell.titleForLocation(
              context,
              location,
              isTeacherLike: isTeacherLike,
              isAdminLike: isAdminLike,
              isParent: isParent,
            );
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    return title;
  }

  testWidgets('ClassNotes gets its own title for every role that has it',
      (tester) async {
    expect(await titleFor(tester, '/classnotes'), 'ClassNotes');
    expect(
      await titleFor(tester, '/classnotes', isTeacherLike: true),
      'ClassNotes',
    );
    expect(await titleFor(tester, '/classnotes', isParent: true), 'ClassNotes');
  });

  testWidgets('a notebook opened inside the tab keeps the ClassNotes title',
      (tester) async {
    expect(await titleFor(tester, '/classnotes/abc-123'), 'ClassNotes');
  });

  testWidgets('every drawer tool has a distinct title', (tester) async {
    final l = await localizations(tester);
    // A role whose tools all resolve to the same fallback would leave the pill
    // meaningless — check each tool's title differs from the role default.
    for (final entry in {
      'student': (false, false, false),
      'teacher': (true, false, false),
      'parent': (false, false, true),
      'admin': (false, true, false),
      'secretary': (false, true, false),
    }.entries) {
      final (isTeacherLike, isAdminLike, isParent) = entry.value;
      final fallback = await titleFor(
        tester,
        '/definitely-not-a-route',
        isTeacherLike: isTeacherLike,
        isAdminLike: isAdminLike,
        isParent: isParent,
      );
      for (final tool in defaultDrawerTools(entry.key, l)) {
        // The teacher workspace IS the teacher default title — the only route
        // that's allowed to match its role's fallback.
        if (tool.route == '/teacher/home') continue;
        final title = await titleFor(
          tester,
          tool.route,
          isTeacherLike: isTeacherLike,
          isAdminLike: isAdminLike,
          isParent: isParent,
        );
        expect(
          title,
          isNot(fallback),
          reason:
              '${entry.key}: ${tool.route} falls through to the role default '
              '("$fallback") instead of naming itself',
        );
      }
    }
  });
}
