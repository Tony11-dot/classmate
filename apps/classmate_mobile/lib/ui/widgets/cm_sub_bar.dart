import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../glass/liquid_glass_card.dart';
import 'cm_surfaces.dart';

/// The one bar for sub-screens — details, editors, pickers: anything a person
/// enters from another screen. No shell, no logo, no pill. A 44 pt glass back
/// button, a bold title (optionally a subtitle), the screen's actions and an
/// optional bottom strip (segments / tabs). It is the bar assignment,
/// announcement and meeting detail introduced, shared so every sub-screen
/// reads the same way.
///
/// Drop-in for `Scaffold.appBar`: transparent, no elevation, honours the top
/// safe area itself (as `AppBar` does).
class CmSubBar extends StatelessWidget implements PreferredSizeWidget {
  const CmSubBar({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.actions = const <Widget>[],
    this.onBack,
    this.showBack = true,
    this.backIcon,
    this.bottom,
  });

  /// Plain-text title, set in titleLarge · w900 and ellipsised on one line.
  final String? title;

  /// Custom title widget (a search field, a two-line header…). Wins over [title].
  final Widget? titleWidget;

  /// One line under the title in bodySmall · onSurfaceVariant.
  final String? subtitle;

  /// Trailing controls — IconButtons / TextButtons / FilledButtons as-is.
  final List<Widget> actions;

  /// Defaults to popping the current route.
  final VoidCallback? onBack;

  /// Hide the back button on root-like screens.
  final bool showBack;

  /// Replace the arrow — e.g. `Icons.close_rounded` for modal editors.
  final IconData? backIcon;

  /// Optional strip under the bar (a `TabBar`, a segmented control).
  final PreferredSizeWidget? bottom;

  static const double barHeight = 64;

  @override
  Size get preferredSize =>
      Size.fromHeight(barHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = AppLocalizations.of(context)!;
    final titleStyle = theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900);

    Widget? heading = titleWidget;
    if (heading == null && title != null) {
      // Long titles beside two actions shrink (down to 64 %) before they
      // ellipsise — "New assignment" stays whole next to Save draft · Publish.
      heading = CmBarTitle(title!, style: titleStyle);
    }
    if (heading != null && subtitle != null) {
      heading = Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading,
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      );
    }

    // Own Material, like AppBar — the ink of the back button and the actions
    // must not depend on whatever the screen wraps its Scaffold in.
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
      bottom: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: barHeight,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 8, 10),
              child: Row(
                children: [
                  if (showBack) ...[
                    Semantics(
                      button: true,
                      label: l.a11yBack,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: onBack ?? () => Navigator.of(context).maybePop(),
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: LiquidGlassCard(
                            padding: EdgeInsets.zero,
                            borderRadius: BorderRadius.circular(16),
                            color: cs.surfaceContainerLow,
                            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                            child: Center(
                              child: Icon(backIcon ?? Icons.arrow_back_rounded, size: 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: heading == null
                        ? const SizedBox.shrink()
                        : Semantics(
                            header: true,
                            child: DefaultTextStyle.merge(style: titleStyle, child: heading),
                          ),
                  ),
                  ...actions,
                ],
              ),
            ),
          ),
          ?bottom,
        ],
      ),
      ),
    );
  }
}
