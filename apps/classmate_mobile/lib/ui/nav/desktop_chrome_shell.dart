import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/layout_breakpoints.dart'
    show DesktopChromeScope, isDesktopWide;
import '../../app/shell/app_shell.dart';
import '../../core/auth/auth_session.dart';
import 'main_drawer.dart';

/// Pins the router's content subtree to one element across the chrome flipping
/// on/off (login↔home, opening add-account / password-reset over a wrapped
/// route). Without it, moving [child] between "bare" and "inside the sidebar
/// Row" tree depths would remount the whole app navigator and drop page state.
/// One chrome exists app-wide, so a single module-level key is safe.
final GlobalKey _chromeContentKey = GlobalKey(
  debugLabel: 'desktop_chrome_content',
);

/// The always-on desktop / tablet app chrome.
///
/// Mounted in [MaterialApp.builder], ABOVE the router's root navigator, so the
/// persistent left nav sidebar AND the top bar (logo + title pill) survive
/// EVERY navigation — including full-screen `rootNavigator: true` pushes
/// (classroom detail, chats, profile sheets, …) that would otherwise cover the
/// whole window and hide the nav. The router's navigator renders inside the
/// content pane, so anything it pushes stays to the right of the sidebar.
///
/// Phones / narrow windows get [child] returned untouched — zero mobile impact.
/// Pre-auth screens (login, password reset) and the manager console (its own
/// chrome) are also passed through bare.
class DesktopChromeShell extends ConsumerWidget {
  const DesktopChromeShell({
    super.key,
    required this.router,
    required this.child,
  });

  final GoRouter router;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep the app's content on one stable element whether or not the chrome
    // wraps it, so flipping chrome on/off never remounts the navigator.
    final content = KeyedSubtree(key: _chromeContentKey, child: child);

    if (!isDesktopWide(context)) return content;

    // authSessionProvider is a plain Provider (ref.watch won't fire on its
    // notifyListeners), so drive rebuilds off the ChangeNotifier itself — the
    // chrome must appear/disappear the moment the user logs in/out.
    //
    // The ROUTER signal is the delegate, NOT routeInformationProvider: the
    // latter's `routerReportsNewRouteInformation` (the path taken whenever the
    // Router reports a REDIRECT) updates its value WITHOUT calling
    // notifyListeners, so a listener there never hears about redirects. The
    // delegate's `_setCurrentConfiguration` always notifies, and it fires
    // outside the build phase, so it's both complete and safe to listen to.
    final session = ref.watch(authSessionProvider);
    return ListenableBuilder(
      listenable: Listenable.merge([session, router.routerDelegate]),
      builder: (context, _) {
        // Visibility is decided by the SESSION ALONE — never by the current
        // route. On a cold launch the app starts at `initialLocation: '/login'`
        // and only reaches the role home via a redirect; gating the whole
        // chrome on a route read could otherwise latch it off for the entire
        // session (the bug that left iPad landscape with a phone drawer and no
        // top bar). Logged out → the login screen renders bare; managers have
        // their own console chrome.
        if (!session.ready || !session.isLoggedIn || session.isManager) {
          return content;
        }

        final isAdminLike =
            session.primaryRole == 'ADMIN' ||
            session.primaryRole == 'SECRETARY';
        final isParent = session.primaryRole == 'PARENT';
        final cs = Theme.of(context).colorScheme;

        // The authoritative, POST-redirect location (GoRouterState.of isn't
        // available above the navigator, and routeInformationProvider.value
        // goes stale across redirects — see the listenable note above).
        final loc = _currentLocation(router);
        // Full-screen auth surfaces render bare. `/login` here can only be the
        // add-another-account push (a logged-out user already returned above);
        // the manager console brings its own chrome.
        if (loc == '/login' ||
            loc == '/forgot-password' ||
            loc.startsWith('/manager')) {
          return content;
        }

        final title = AppShell.titleForLocation(
          context,
          loc,
          isTeacherLike: session.isTeacherLike,
          isAdminLike: isAdminLike,
          isParent: isParent,
        );

        return Material(
          color: cs.surface,
          child: SafeArea(
            child: Row(
              children: [
                MainDrawer(
                  permanent: true,
                  navRouter: router,
                  currentLocation: loc,
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 60,
                        child: AppShellTopBar(
                          title: title,
                          showMenuButton: false,
                        ),
                      ),
                      const Divider(height: 1, thickness: 1),
                      // The router's root navigator lives here — every page
                      // it pushes (however it's pushed) stays in this pane.
                      // Mark the subtree as "inside desktop chrome" and
                      // override MediaQuery.size to the pane's real size so
                      // width-based layouts (chat bubbles, trimmers, …) fit
                      // the pane instead of the full window.
                      Expanded(
                        child: DesktopChromeScope(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final mq = MediaQuery.of(context);
                              return MediaQuery(
                                data: mq.copyWith(
                                  size: Size(
                                    constraints.maxWidth,
                                    constraints.maxHeight,
                                  ),
                                ),
                                child: content,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The router's authoritative current location, taken from the delegate's
/// post-redirect [RouteMatchList]. `routeInformationProvider.value` is NOT used
/// as the source of truth: on a router-reported change (i.e. a redirect) it is
/// updated without notifying, so it can report a location the app has already
/// left. Falls back to it only if the delegate has no configuration yet.
String _currentLocation(GoRouter router) {
  final configured = router.routerDelegate.currentConfiguration.uri.path;
  if (configured.isNotEmpty) return configured;
  final reported = router.routeInformationProvider.value.uri.path;
  return reported.isEmpty ? '/' : reported;
}
