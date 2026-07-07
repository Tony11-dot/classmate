import 'package:flutter/material.dart';

import '../glass/cm_glass.dart';

/// The app-standard back button: a glass capsule with a chevron and native
/// press physics. Replaces the ~30 hand-rolled back chevrons (both the
/// AppBar-leading pattern and the headerless "Row + chevron" pattern).
///
/// - Pops via [Navigator.maybePop] so PopScope guards still run.
/// - The chevron flips automatically in RTL (the icon is direction-aware).
/// - 44pt hit target; announced as a button with the localized back label.
class GlassBackButton extends StatelessWidget {
  const GlassBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final label = MaterialLocalizations.of(context).backButtonTooltip;
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        child: GlassPressable(
          onTap: onPressed ?? () => Navigator.maybePop(context),
          child: CMGlass(
            capsule: true,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
          ),
        ),
      ),
    );
  }
}

/// Headerless detail-screen top row: [GlassBackButton] + title. Replaces the
/// duplicated "Row(back chevron, Text(title))" pattern (lifedoc
/// _DetailTopBar, admin/teacher headerless forms).
class GlassDetailHeader extends StatelessWidget {
  const GlassDetailHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onBack,
  });

  final String title;
  final Widget? trailing;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        GlassBackButton(onPressed: onBack),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        ?trailing,
      ],
    );
  }
}
