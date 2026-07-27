import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:classmate_mobile/features/onboarding/onboarding_screen.dart';
import 'package:classmate_mobile/l10n/app_localizations.dart';

/// The first-run tour is the only place most users ever read about what the app
/// does, so it has to render for every role, in every language, and actually
/// reach the end.
void main() {
  const roles = ['STUDENT', 'TEACHER', 'PARENT', 'ADMIN', 'SECRETARY'];

  Future<int> pumpTour(
    WidgetTester tester, {
    required String role,
    required List<String> finished,
    Locale locale = const Locale('en'),
    String firstName = 'Joseph',
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: OnboardingTour(
          role: role,
          firstName: firstName,
          onDone: () async => finished.add(role),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // The dot strip has one dot per slide.
    return tester
        .widgetList(find.byType(PageView))
        .map((w) => (w as PageView).childrenDelegate.estimatedChildCount ?? 0)
        .first;
  }

  group('renders and completes', () {
    for (final role in roles) {
      testWidgets('$role tour walks to the end and finishes', (tester) async {
        tester.view.physicalSize = const Size(1200, 2000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final finished = <String>[];
        final count = await pumpTour(tester, role: role, finished: finished);

        expect(count, greaterThanOrEqualTo(3),
            reason: '$role should get a real tour, not one slide');
        expect(find.byType(ErrorWidget), findsNothing);
        // Step counter starts at 1 of N.
        expect(find.text('1 of $count'), findsOneWidget);
        // No way back from the first slide.
        expect(find.text('Back'), findsNothing);

        for (var step = 1; step < count; step++) {
          await tester.tap(find.text('Next'));
          await tester.pumpAndSettle();
          expect(find.text('${step + 1} of $count'), findsOneWidget);
          expect(find.text('Back'), findsOneWidget,
              reason: 'every slide after the first can go back');
          expect(tester.takeException(), isNull);
        }

        // The last slide offers the finish action rather than Next.
        expect(find.text('Next'), findsNothing);
        await tester.tap(find.text('Get started'));
        // Finishing shows a spinner, so the tree never goes idle — pump a couple
        // of fixed frames instead of settling.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(finished, [role]);
      });
    }
  });

  testWidgets('the welcome slide greets the user by first name', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpTour(tester, role: 'STUDENT', finished: [], firstName: 'Joseph');
    expect(find.text('Welcome, Joseph!'), findsOneWidget);
  });

  testWidgets('Back returns to the previous slide', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final count = await pumpTour(tester, role: 'STUDENT', finished: []);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('2 of $count'), findsOneWidget);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('1 of $count'), findsOneWidget);
  });

  testWidgets('Skip finishes the tour immediately', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final finished = <String>[];
    await pumpTour(tester, role: 'STUDENT', finished: finished);
    await tester.tap(find.text('Skip'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(finished, ['STUDENT']);
  });

  testWidgets('each slide names the screens it covers', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpTour(tester, role: 'STUDENT', finished: []);
    // Slide 2 is NOVA: its chips should name the real screens it maps to, using
    // the same labels as the drawer.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('NOVA'), findsWidgets);
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('What you can do'.toUpperCase()), findsOneWidget);
  });

  group('every locale', () {
    for (final locale in AppLocalizations.supportedLocales) {
      testWidgets('renders the ${locale.languageCode} tour', (tester) async {
        tester.view.physicalSize = const Size(1200, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await pumpTour(
          tester,
          role: 'STUDENT',
          finished: [],
          locale: locale,
        );
        expect(find.byType(ErrorWidget), findsNothing);
        expect(find.byType(PageView), findsOneWidget);
        final thrown = tester.takeException();
        if (thrown != null) {
          // Only Flutter's own "locale not supported by all delegates" notice is
          // acceptable here — anything else is a real failure.
          expect(
            thrown.toString(),
            contains('is not supported by all of its localization delegates'),
          );
        }
      });
    }
  });

  testWidgets('a long slide scrolls instead of overflowing a short window',
      (tester) async {
    // A cramped web window with large accessibility text — the case that used
    // to clip the copy off the bottom.
    tester.view.physicalSize = const Size(1000, 620);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
          child: OnboardingTour(
            role: 'STUDENT',
            firstName: 'Joseph',
            onDone: () async {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsWidgets);
  });
}
