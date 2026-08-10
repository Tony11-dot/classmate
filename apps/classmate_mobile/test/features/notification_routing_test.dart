import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Tapping a notification must not crash the app.
///
/// The regression: the widget that receives notification taps lives inside
/// `MaterialApp.router`'s `builder`, which runs ABOVE the router's own
/// Navigator. `InheritedGoRouter` is installed BELOW that, by the router
/// delegate — so `context.push` from the builder throws
/// "No GoRouter found in context" and takes the app down with it. It reached
/// production because the crashing line only runs for someone who actually
/// taps a notification; every other session skips it entirely.
///
/// These tests pin the shape of the bug rather than the app's own widget tree,
/// which needs the whole provider graph to build.
void main() {
  testWidgets(
    'context.push from MaterialApp.router builder cannot find the router',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, _) => const Text('home')),
          GoRoute(path: '/inbox', builder: (_, _) => const Text('inbox')),
        ],
      );
      addTearDown(router.dispose);

      late BuildContext builderContext;
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          builder: (context, child) {
            builderContext = context;
            return child ?? const SizedBox.shrink();
          },
        ),
      );

      // This is exactly what the old `_openNotificationsInbox` did.
      expect(
        () => builderContext.push('/inbox'),
        throwsA(
          isA<AssertionError>().having(
            (e) => e.toString(),
            'message',
            contains('No GoRouter found in context'),
          ),
        ),
      );
    },
  );

  testWidgets(
    'pushing on the router instance navigates from that same context',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, _) => const Text('home')),
          GoRoute(path: '/inbox', builder: (_, _) => const Text('inbox')),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          builder: (context, child) => child ?? const SizedBox.shrink(),
        ),
      );
      expect(find.text('home'), findsOneWidget);

      // The fix: go through the GoRouter the provider already holds, which
      // needs no inherited widget to be found.
      router.push('/inbox');
      await tester.pumpAndSettle();

      expect(find.text('inbox'), findsOneWidget);
    },
  );
}
