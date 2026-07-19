import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:classmate_mobile/core/auth/auth_controller.dart';
import 'package:classmate_mobile/core/auth/accounts_store.dart';
import 'package:classmate_mobile/features/certificates/data/certificates_repository.dart';
import 'package:classmate_mobile/features/parent/data/parent_repository.dart';
import 'package:classmate_mobile/l10n/app_localizations.dart';
import 'package:classmate_mobile/ui/dialogs/confirm_logout.dart';
import 'package:classmate_mobile/ui/widgets/classmate_logo.dart';
import 'package:classmate_mobile/ui/widgets/liquid_glass_dropdown.dart';
import 'package:classmate_mobile/ui/nav/drawer_tools_order.dart';

class MainDrawer extends ConsumerWidget {
  const MainDrawer({
    super.key,
    this.permanent = false,
    this.navRouter,
    this.currentLocation,
  });

  /// When true, render as a permanent left panel (desktop/web) instead of a
  /// slide-out Drawer — no rounded edge, no close button, and tapping an item
  /// navigates without popping a route.
  final bool permanent;

  /// When this drawer is rendered by the GLOBAL desktop chrome
  /// ([DesktopChromeShell]), it lives ABOVE the router's navigator, where
  /// `context.go` / `showDialog` / `showModalBottomSheet` have no
  /// InheritedGoRouter / Navigator ancestor. Passing the [GoRouter] lets us
  /// route + show modals via the ROOT navigator's context instead. Null in the
  /// normal phone-drawer / in-shell cases (plain `context` works there).
  final GoRouter? navRouter;

  /// Current location, supplied alongside [navRouter] because
  /// `GoRouterState.of(context)` would throw above the navigator. Falls back to
  /// GoRouterState when null.
  final String? currentLocation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    // In global-chrome mode use the root navigator's context (INSIDE
    // InheritedGoRouter + backed by an Overlay) for every navigation/modal;
    // otherwise plain `context` is already inside the navigator.
    final navContext =
        navRouter?.routerDelegate.navigatorKey.currentContext ?? context;
    void closeDrawer() { if (!permanent) Navigator.of(context).pop(); }
    final l = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);
    final isTeacherLike = session.isTeacherLike;
    final isSecretary = session.primaryRole == 'SECRETARY';
    final isPureAdmin = session.primaryRole == 'ADMIN';
    final isParent = session.primaryRole == 'PARENT';
    // NOVA (and its subscription Plans) is a students-only feature now —
    // teachers/parents/staff bring no NOVA revenue, so they don't get the
    // tutor in their nav or a plan to buy tokens they can't spend.
    final isStudent = session.primaryRole == 'STUDENT';
    // The Certificates tool is only for teachers who are a homeroom teacher.
    final isHomeroomTeacher = ref.watch(isHomeroomTeacherProvider).value ?? false;
    final displayName = session.displayName.trim();
    final initials = _initials(displayName);
    final schoolName = session.schoolName.trim();
    final schoolLogoUrl = session.schoolLogoUrl.trim();
    final loc = currentLocation ?? GoRouterState.of(context).matchedLocation;
    final roleLabel = switch (session.primaryRole) {
      'TEACHER' => l.roleTeacher,
      'ADMIN' => l.roleAdmin,
      'SECRETARY' => l.roleSecretary,
      'PARENT' => l.roleParent,
      _ => l.student,
    };

    // User-reorderable "School Tools" section (Core + Account stay fixed).
    final toolsRoleKey = drawerToolsRoleKey(
      primaryRole: session.primaryRole,
      isTeacherLike: isTeacherLike,
    );
    final toolsOrder = ref.watch(drawerToolsOrderProvider);
    final orderedTools =
        applyDrawerToolsOrder(defaultDrawerTools(toolsRoleKey, l), toolsOrder);

    // ── helpers ──────────────────────────────────────────────────────────

    Widget sectionHeader(String title) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 16, 6),
        child: Row(
          children: [
            Expanded(
              child: Divider(
                height: 1,
                color: cs.outlineVariant,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Divider(
                height: 1,
                color: cs.outlineVariant,
              ),
            ),
          ],
        ),
      );
    }

    Widget navItem({
      required IconData icon,
      required String label,
      required String route,
      bool danger = false,
    }) {
      final isActive = loc == route ||
          (route != '/schedule' && loc.startsWith(route));
      final tint = danger ? cs.error : cs.primary;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Material(
          color: isActive
              ? cs.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              closeDrawer();
              navContext.go(route);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isActive
                          ? tint
                          : cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: isActive
                          ? (danger ? cs.onError : cs.onPrimary)
                          : cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? tint : (danger ? tint : cs.onSurface),
                      ),
                    ),
                  ),
                  if (isActive)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: tint,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ── build ─────────────────────────────────────────────────────────────

    final inner = SafeArea(
        child: Column(
          children: [
            // ── School branding ─────────────────────────────────────────
            if (schoolName.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  border: Border(
                    bottom: BorderSide(
                      color: cs.outlineVariant,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // School logo via CachedNetworkImage so the bytes are
                    // pulled once and reused across every drawer open —
                    // Image.network's in-memory cache is per-widget, so
                    // each drawer open re-decoded the PNG and flashed
                    // empty space for a frame. The placeholder shows
                    // instantly on first load too.
                    if (schoolLogoUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: schoolLogoUrl,
                          width: 36,
                          height: 36,
                          fit: BoxFit.contain,
                          fadeInDuration: const Duration(milliseconds: 120),
                          fadeOutDuration: Duration.zero,
                          placeholder: (_, _) => _schoolLogoPlaceholder(cs),
                          errorWidget: (_, _, _) => _schoolLogoPlaceholder(cs),
                        ),
                      )
                    else
                      _schoolLogoPlaceholder(cs),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        schoolName,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            // ── User header ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              decoration: BoxDecoration(
              ),
              child: Row(
                children: [
                  // Avatar + name — tap to open the account switcher (add /
                  // switch / sign out this account). Instagram-style.
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _openAccountSwitcher(navContext, ref),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: TextStyle(
                                  color: cs.onPrimary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        displayName.isEmpty ? 'ClassMate' : displayName,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.unfold_more_rounded, size: 18, color: cs.onSurfaceVariant),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  roleLabel,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                ),
                                if (isParent) ...[
                                  const SizedBox(height: 8),
                                  _ParentChildDropdown(navRouter: navRouter),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Close button — always shows the CM mark. The school logo
                  // already appears in the dedicated branding row above, so
                  // mirroring it here just doubled the visual noise.
                  if (!permanent)
                    Semantics(
                      button: true,
                      label: l.a11yClose,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(child: ClassMateIcon(size: 32)),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Scrollable nav list ──────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 12),
                children: [
                  // ── Admin/Secretary drawer: 3 focused categories ──────────
                  if (isParent) ...[
                    sectionHeader(l.sectionCore),
                    navItem(icon: Icons.dashboard_rounded, label: l.navHome, route: '/parent/home'),
                    navItem(icon: Icons.event_note_rounded, label: l.navSchedule, route: '/parent/schedule'),
                    navItem(icon: Icons.insights_rounded, label: l.navInsights, route: '/parent/overview'),
                    navItem(icon: Icons.chat_bubble_rounded, label: l.navMessages, route: '/messages'),
                    navItem(icon: Icons.campaign_rounded, label: l.navAnnouncements, route: '/announcements'),
                    sectionHeader(l.sectionSchoolTools),
                    for (final t in orderedTools)
                      navItem(icon: t.icon, label: t.label, route: t.route),
                    sectionHeader(l.sectionAccount),
                  ] else if (isSecretary) ...[
                    sectionHeader(l.sectionSecretaryTools),
                    for (final t in orderedTools)
                      navItem(icon: t.icon, label: t.label, route: t.route),
                    sectionHeader(l.sectionAccount),
                  ] else if (isPureAdmin) ...[
                    sectionHeader(l.sectionSchoolToolsLabel),
                    navItem(icon: Icons.chat_bubble_rounded, label: l.navMessages, route: '/messages'),
                    navItem(icon: Icons.campaign_rounded, label: l.navAnnouncements, route: '/announcements'),
                    navItem(icon: Icons.notifications_rounded, label: l.navNotifications, route: '/notifications'),
                    sectionHeader(l.sectionAdminTools),
                    for (final t in orderedTools)
                      navItem(icon: t.icon, label: t.label, route: t.route),
                    sectionHeader(l.sectionAccount),
                  // ── Teacher drawer ────────────────────────────────────────
                  ] else if (isTeacherLike) ...[
                    // Core mirrors the teacher bottom nav (NOVA holds the last
                    // tab); Messages lives in School Tools below, first item.
                    sectionHeader(l.sectionCore),
                    navItem(icon: Icons.event_note_rounded, label: l.navSchedule, route: '/teacher/schedule'),
                    navItem(icon: Icons.groups_rounded, label: l.navClassrooms, route: '/teacher/classrooms'),
                    navItem(icon: Icons.campaign_rounded, label: l.navAnnouncements, route: '/announcements'),
                    navItem(icon: Icons.insights_rounded, label: l.navInsights, route: '/teacher/insights'),
                    navItem(icon: Icons.psychology_rounded, label: l.navNova, route: '/tutor'),
                    sectionHeader(l.sectionSchoolTools),
                    for (final t in orderedTools)
                      if (t.route != '/teacher/certificates' || isHomeroomTeacher)
                        navItem(icon: t.icon, label: t.label, route: t.route),
                    sectionHeader(l.sectionAccount),
                  // ── Student drawer ────────────────────────────────────────
                  ] else ...[
                    sectionHeader(l.sectionCore),
                    navItem(icon: Icons.calendar_month_rounded, label: l.navSchedule, route: '/schedule'),
                    navItem(icon: Icons.groups_rounded, label: l.navClassrooms, route: '/classrooms'),
                    navItem(icon: Icons.auto_awesome_rounded, label: l.navPractice, route: '/practice'),
                    navItem(icon: Icons.insights_rounded, label: l.navInsights, route: '/insights'),
                    navItem(icon: Icons.psychology_rounded, label: l.navNova, route: '/tutor'),
                    sectionHeader(l.sectionSchoolTools),
                    for (final t in orderedTools)
                      navItem(icon: t.icon, label: t.label, route: t.route),
                    sectionHeader(l.sectionAccount),
                  ],

                  navItem(
                    icon: Icons.person_rounded,
                    label: l.navProfile,
                    route: '/profile',
                  ),
                  // NOVA Plans — students only. NOVA is a students-only
                  // feature, so only they can buy token plans for it.
                  if (isStudent)
                    navItem(
                      icon: Icons.workspace_premium_rounded,
                      label: l.navPlans,
                      route: '/plans',
                    ),
                  navItem(
                    icon: Icons.settings_rounded,
                    label: l.navSettings,
                    route: '/settings',
                  ),
                  navItem(
                    icon: Icons.help_outline_rounded,
                    label: l.navSupport,
                    route: '/support',
                  ),
                  navItem(
                    icon: Icons.info_outline_rounded,
                    label: l.navAbout,
                    route: '/about',
                  ),
                  // ── Privacy Policy — a styled card (not a plain row) that
                  //    opens our legal site in the browser ──────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Material(
                      color: cs.primaryContainer.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(16),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () async {
                          closeDrawer();
                          // The legal landing (Privacy · Terms · Delete account).
                          final uri = Uri.parse('https://tony11-dot.github.io/classmate-legal/');
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: cs.primary,
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Icon(Icons.shield_rounded, size: 20, color: cs.onPrimary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l.navPrivacyPolicy,
                                        style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurface)),
                                    Text(l.privacyPolicySubtitle,
                                        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                              Icon(Icons.open_in_new_rounded, size: 16, color: cs.primary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Logout (danger style, separate tap handler)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () async {
                          if (!await confirmLogout(navContext)) return;
                          if (!navContext.mounted) return;
                          closeDrawer();
                          await ref.read(authControllerProvider).logout();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 11),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: cs.errorContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.logout_rounded,
                                  size: 18,
                                  color: cs.error,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l.navLogout,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: cs.error,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      );

    return permanent
        ? Material(color: cs.surface, child: SizedBox(width: 290, child: inner))
        : Drawer(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: inner,
          );
  }
}

String _initials(String name) {
  if (name.isEmpty) return 'CM';
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  // Single word: use first two characters
  final word = parts[0];
  if (word.length >= 2) return '${word[0]}${word[1]}'.toUpperCase();
  return word[0].toUpperCase();
}

/// Instagram-style account switcher — lists the accounts remembered on this
/// device, lets you switch instantly, add another, or sign the current one out.
Future<void> _openAccountSwitcher(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context)!;
  final controller = ref.read(authControllerProvider);
  // Make sure the currently-signed-in account is in the list (covers sessions
  // that predate the multi-account feature).
  await controller.rememberCurrentAccount();
  if (!context.mounted) return;
  final session = ref.read(authSessionProvider);
  final activeId = session.userId;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetCtx) {
      final cs = Theme.of(sheetCtx).colorScheme;
      final theme = Theme.of(sheetCtx);
      return Consumer(builder: (ctx, r, _) {
        final state = r.watch(accountsControllerProvider);
        final accounts = state.accounts;
        return Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(width: 40, height: 4, decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(l.accountSwitcherTitle,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  ),
                ),
                for (final acct in accounts)
                  ListTile(
                    leading: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(13)),
                      child: Center(child: Text(_initials(acct.displayName),
                          style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.w900))),
                    ),
                    title: Text(acct.displayName.isEmpty ? 'ClassMate' : acct.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text([
                      if (acct.roleLabel.isNotEmpty) _roleLabelFor(l, acct.roleLabel),
                      if (acct.schoolName != null && acct.schoolName!.isNotEmpty) acct.schoolName!,
                    ].join(' · ')),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (acct.userId == activeId)
                          Icon(Icons.check_circle_rounded, color: cs.primary),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded),
                          tooltip: l.accountActionsTooltip,
                          onSelected: (value) async {
                            if (value == 'switch') {
                              Navigator.of(sheetCtx).pop();
                              await controller.switchAccount(acct);
                            } else if (value == 'remove') {
                              final ok = await _confirmRemoveAccount(
                                  sheetCtx, l, acct.displayName);
                              if (ok != true) return;
                              if (acct.userId == activeId) {
                                // Removing the ACTIVE account: sign it out, which
                                // drops it from the store and switches to another
                                // remembered account (or /login if none remain).
                                Navigator.of(sheetCtx).pop();
                                await controller.signOutActiveAccount();
                              } else {
                                // Non-active: just forget it — no trace left in
                                // the switcher, no session change.
                                await ref
                                    .read(accountsStoreProvider)
                                    .remove(acct.userId);
                                await ref
                                    .read(accountsControllerProvider.notifier)
                                    .reload();
                              }
                            }
                          },
                          itemBuilder: (menuCtx) => [
                            if (acct.userId != activeId)
                              PopupMenuItem<String>(
                                value: 'switch',
                                child: Row(children: [
                                  Icon(Icons.swap_horiz_rounded,
                                      size: 20, color: cs.primary),
                                  const SizedBox(width: 12),
                                  Text(l.accountSwitchTo),
                                ]),
                              ),
                            PopupMenuItem<String>(
                              value: 'remove',
                              child: Row(children: [
                                Icon(Icons.delete_outline_rounded,
                                    size: 20, color: cs.error),
                                const SizedBox(width: 12),
                                Text(l.accountRemove,
                                    style: TextStyle(color: cs.error)),
                              ]),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: acct.userId == activeId
                        ? () => Navigator.of(sheetCtx).pop()
                        : () async {
                            Navigator.of(sheetCtx).pop();
                            await controller.switchAccount(acct);
                          },
                  ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.add_circle_outline_rounded, color: cs.primary),
                  title: Text(l.accountAddAccount, style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700)),
                  onTap: () {
                    Navigator.of(sheetCtx).pop();
                    // Close the drawer if one is actually open (on desktop the
                    // menu is a permanent sidebar — blindly popping would close
                    // whatever page is on top), then PUSH login in add-account
                    // mode so backing out returns to the current account.
                    final scaffold = Scaffold.maybeOf(context);
                    if (scaffold?.isDrawerOpen ?? false) Navigator.of(context).pop();
                    context.push('/login?add=1');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout_rounded, color: cs.error),
                  title: Text(l.accountSignOutThis, style: TextStyle(color: cs.error)),
                  onTap: () async {
                    Navigator.of(sheetCtx).pop();
                    await controller.signOutActiveAccount();
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      });
    },
  );
}

/// Confirmation before forgetting an account from this device's switcher.
Future<bool?> _confirmRemoveAccount(
    BuildContext context, AppLocalizations l, String name) {
  return showDialog<bool>(
    context: context,
    builder: (dCtx) => AlertDialog(
      title: Text(l.accountRemoveConfirmTitle),
      content: Text(l.accountRemoveConfirmBody(name.isEmpty ? 'ClassMate' : name)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dCtx).pop(false),
          child: Text(l.actionCancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dCtx).colorScheme.error),
          onPressed: () => Navigator.of(dCtx).pop(true),
          child: Text(l.accountRemove),
        ),
      ],
    ),
  );
}

/// Localize a stored primaryRole code for the switcher subtitle.
String _roleLabelFor(AppLocalizations l, String role) {
  switch (role.toUpperCase()) {
    case 'TEACHER':
      return l.roleTeacher;
    case 'ADMIN':
      return l.roleAdmin;
    case 'SECRETARY':
      return l.roleSecretary;
    case 'PARENT':
      return l.roleParent;
    default:
      return l.roleStudent;
  }
}

Widget _schoolLogoPlaceholder(ColorScheme cs) {
  return Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: cs.primaryContainer,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(
      Icons.school_rounded,
      size: 20,
      color: cs.onPrimaryContainer,
    ),
  );
}

/// Liquid-glass-styled child selector under the parent's name in the
/// drawer header. Tap → opens the shared bottom-sheet picker; selecting
/// writes to [selectedChildProvider] so every parent-scoped data
/// provider re-fetches against the new child.
class _ParentChildDropdown extends ConsumerWidget {
  const _ParentChildDropdown({this.navRouter});

  /// See [MainDrawer.navRouter] — non-null in the global desktop chrome so the
  /// child picker opens from the root navigator's context.
  final GoRouter? navRouter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final async = ref.watch(parentChildrenProvider);
    final selectedId = ref.watch(selectedChildProvider);
    final pickerContext =
        navRouter?.routerDelegate.navigatorKey.currentContext ?? context;

    return async.when(
      loading: () => _shell(cs, isDark,
          child: Text(AppLocalizations.of(context)!.drawerLoadingChildren,
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant))),
      error: (err, _) => _shell(cs, isDark,
          child: Text(AppLocalizations.of(context)!.drawerCouldNotLoadChildren,
              style: TextStyle(fontSize: 12, color: cs.error))),
      data: (children) {
        if (children.isEmpty) {
          return _shell(cs, isDark,
              child: Text(AppLocalizations.of(context)!.drawerNoChildrenLinked,
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)));
        }
        final selected = children.firstWhere(
          (c) => c.studentId == selectedId,
          orElse: () => children.first,
        );

        return InkWell(
          onTap: () async {
            final picked = await showLiquidGlassPicker<String>(
              context: pickerContext,
              title: AppLocalizations.of(context)!.drawerSwitchChild,
              currentValue: selected.studentId,
              items: [
                for (final c in children)
                  LiquidGlassDropdownItem(
                    value: c.studentId,
                    label: c.gradeLabel.isNotEmpty
                        ? '${c.name.isEmpty ? '—' : c.name} • ${c.gradeLabelLocalized(AppLocalizations.of(context)!)}'
                        : (c.name.isEmpty ? '—' : c.name),
                    icon: Icons.child_care_rounded,
                  ),
              ],
            );
            if (picked != null && picked != selected.studentId) {
              ref.read(selectedChildProvider.notifier).select(picked);
            }
          },
          borderRadius: BorderRadius.circular(14),
          child: _shell(
            cs,
            isDark,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 11,
                  backgroundColor: cs.primary,
                  child: Text(
                    _initials(selected.name),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: cs.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selected.name.isEmpty ? '—' : selected.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 18, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        );
      },
    );
  }

  /// The liquid-glass shell — same gradient + border style as
  /// [LiquidGlassDropdown] so the drawer trigger matches the rest of the
  /// app's pickers.
  Widget _shell(ColorScheme cs, bool isDark, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surface.withValues(alpha: isDark ? 0.76 : 0.88),
            cs.surfaceContainerHigh.withValues(alpha: isDark ? 0.56 : 0.66),
          ],
        ),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: child,
    );
  }
}

