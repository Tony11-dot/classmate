import 'package:flutter/widgets.dart';

/// The single source of truth for the phone-vs-desktop layout switch.
///
/// At/above this the app shows the persistent left nav sidebar (WhatsApp-web
/// style) on EVERY route — including full-screen chats and detail pages — and
/// drops the floating bottom-nav pill. Below it we stay in phone mode.
///
/// Wide when EITHER:
///  • the viewport is genuinely wide (>= 900 logical px — the same breakpoint
///    Instagram/Twitter web use to switch to a left rail), covering laptops,
///    desktops and browser windows; OR
///  • the device is a tablet in ANY orientation (shortestSide >= 600, Flutter's
///    canonical tablet cutoff) — this keeps the nav rail pinned on iPad even in
///    portrait, where the width alone (~810) sits just under 900.
bool isDesktopWide(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  return size.width >= 900 || size.shortestSide >= 600;
}
