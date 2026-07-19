import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_session.dart';
import 'main_drawer.dart';

/// Wraps a full-screen detail/chat page with the permanent left nav sidebar on
/// wide (desktop / tablet) layouts, so the primary navigation stays visible no
/// matter how deep the user drills — WhatsApp-web style: the sidebar is ALWAYS
/// there, even inside a chat. On phones this widget is never inserted (the
/// route keeps its native full-screen slide + swipe-back instead).
///
/// The sidebar is only shown for a signed-in, non-manager session; logged-out
/// screens (e.g. /forgot-password reached before login) and the manager
/// console — which brings its own chrome — render the bare page. It mirrors the
/// exact same `MainDrawer(permanent: true)` + hairline divider that
/// [AppShell]'s wide branch renders, so cross-fading between a shell tab and a
/// pushed detail page leaves the sidebar visually rock-steady.
class DesktopNavFrame extends ConsumerWidget {
  const DesktopNavFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    if (!session.ready || !session.isLoggedIn || session.isManager) {
      return child;
    }
    return SafeArea(
      child: Row(
        children: [
          const MainDrawer(permanent: true),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
