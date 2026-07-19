import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/layout_breakpoints.dart' show DesktopChromeScope, isDesktopWide;
import '../../app/shell/app_shell.dart';
import '../../core/auth/auth_session.dart';
import 'main_drawer.dart';

/// Pins the router's content subtree to one element across the chrome flipping
/// on/off (login↔home, opening add-account / password-reset over a wrapped
/// route). Without it, moving [child] between "bare" and "inside the sidebar
/// Row" tree depths would remount the whole app navigator and drop page state.
/// One chrome exists app-wide, so a single module-level key is safe.
final GlobalKey _chromeContentKey =
    GlobalKey(debugLabel: 'desktop_chrome_content');

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
    final session = ref.watch(authSessionProvider);
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        if (!session.ready || !session.isLoggedIn || session.isManager) {
          return content;
        }

        final isAdminLike = session.primaryRole == 'ADMIN' ||
            session.primaryRole == 'SECRETARY';
        final isParent = session.primaryRole == 'PARENT';
        final cs = Theme.of(context).colorScheme;

        // Rebuild the chrome (title pill + active nav item) whenever the
        // location changes. Listening to the router's own provider — not
        // GoRouterState.of, which isn't available above the navigator.
        return ValueListenableBuilder<RouteInformation>(
          valueListenable: router.routeInformationProvider,
          builder: (context, info, _) {
            final loc = info.uri.path.isEmpty ? '/' : info.uri.path;
            // Login / password-reset / manager routes never get school chrome.
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
      },
    );
  }
}
