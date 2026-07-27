import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:classmate_mobile/core/config/env.dart';
import 'package:classmate_mobile/features/certificates/data/certificates_repository.dart';
import 'package:classmate_mobile/l10n/app_localizations.dart';
import 'package:classmate_mobile/ui/nav/drawer_tools_order.dart';
import 'package:classmate_mobile/ui/nav/main_drawer.dart';

/// The drawer renders "School Tools" as a reorderable list. On web and iPad that
/// drawer is PERMANENT: `DesktopChromeShell` builds it inside
/// `MaterialApp.router`'s `builder`, which sits ABOVE the router's Navigator —
/// so there is no `Overlay` in scope.
///
/// `ReorderableListView` needs one (`Overlay.of` ends in `return result!`), and
/// in a release build the assert that would say "No Overlay widget found" is
/// stripped — so production showed the whole section replaced by
/// "Null check operator used on a null value".
///
/// [chromeShaped] reproduces that exact nesting, so the section can't regress.
void main() {
  setUpAll(Env.init);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  /// The production shape: the drawer built in `MaterialApp`'s `builder`, beside
  /// (not inside) the Navigator that `child` carries.
  Widget chromeShaped(GoRouter router) {
    return ProviderScope(
      overrides: [
        isHomeroomTeacherProvider.overrideWith((ref) async => false),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => Material(
          color: Colors.white,
          child: SafeArea(
            child: Row(
              children: [
                MainDrawer(
                  permanent: true,
                  navRouter: router,
                  currentLocation: '/home',
                ),
                const VerticalDivider(width: 1),
                Expanded(child: child ?? const SizedBox()),
              ],
            ),
          ),
        ),
        home: const SizedBox(),
      ),
    );
  }

  GoRouter throwawayRouter() => GoRouter(
        routes: [GoRoute(path: '/', builder: (_, __) => const SizedBox())],
      );

  testWidgets('permanent drawer renders School Tools with no Overlay above it',
      (tester) async {
    // A wide surface, like an iPad or a browser window.
    tester.view.physicalSize = const Size(1600, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final router = throwawayRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(chromeShaped(router));
    await tester.pumpAndSettle();

    expect(
      tester.takeException(),
      isNull,
      reason: 'the permanent drawer must build with no Overlay ancestor',
    );
    // The section rendered, rather than being replaced by Flutter's ErrorWidget.
    expect(find.byType(ErrorWidget), findsNothing);
    expect(find.byType(ReorderableListView), findsOneWidget);
    expect(find.byType(ReorderableDelayedDragStartListener), findsWidgets);
  });

  testWidgets('a School Tools item can be dragged in the permanent drawer',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final router = throwawayRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(chromeShaped(router));
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(ReorderableDelayedDragStartListener).first),
    );
    // Hold to pick the row up, then drag it past its neighbour and drop.
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveBy(const Offset(0, 80));
    await tester.pump(const Duration(milliseconds: 120));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('slide-out drawer still renders School Tools', (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // The phone drawer reads GoRouterState for the active route, so it has to
    // live under a real route — exactly as it does in the app shell.
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(drawer: MainDrawer(), body: SizedBox()),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isHomeroomTeacherProvider.overrideWith((ref) async => false),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(ErrorWidget), findsNothing);
    expect(find.byType(ReorderableListView), findsOneWidget);
  });

  group('applyDrawerToolsOrder', () {
    DrawerTool tool(String route) =>
        DrawerTool(route: route, icon: Icons.circle, label: route);

    test('keeps every tool exactly once, whatever the saved order says', () {
      final items = ['/a', '/b', '/c', '/d'].map(tool).toList();
      final out = applyDrawerToolsOrder(items, ['/c', '/a']);
      // Saved entries lead; anything the user never reordered slots back in at
      // its DEFAULT index, so a newly-shipped tool still lands where we put it.
      expect(out.map((t) => t.route), ['/c', '/b', '/a', '/d']);
      expect(out.length, items.length);
      expect(out.map((t) => t.route).toSet().length, items.length,
          reason: 'a duplicated key would break the reorderable list');
    });

    test('ignores routes in the saved order that no longer exist', () {
      final items = ['/a', '/b'].map(tool).toList();
      final out = applyDrawerToolsOrder(items, ['/gone', '/b', '/gone']);
      expect(out.map((t) => t.route), ['/a', '/b']);
      expect(out.length, 2);
    });

    test('an empty saved order leaves the shipped order alone', () {
      final items = ['/a', '/b'].map(tool).toList();
      expect(applyDrawerToolsOrder(items, const []), items);
    });
  });
}
