import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/cm_tokens.dart';
import '../../l10n/app_localizations.dart';
import 'cm_press.dart';

/// The redesign's standard card: low surface, hairline border, soft shadow.
/// Pass [onTap] to get spring press feedback.
class CmCard extends StatelessWidget {
  const CmCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(14),
    this.radius = CmTokens.radiusLg,
    this.tint,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;

  /// Optional hero wash: gradient from [tint] down to the card surface.
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = cs.brightness == Brightness.dark;
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: tint == null ? cs.surfaceContainerLow : null,
        gradient: tint == null
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tint!.withValues(alpha: dark ? 0.22 : 0.12),
                  cs.surfaceContainerLow,
                ],
              ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.35),
          width: 0.8,
        ),
        boxShadow: CmTokens.of(context).shadowSm,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return CmPress(onTap: onTap, child: card);
  }
}

/// Rounded square tile with a tinted fill and an icon in the same tone.
class CmIconTile extends StatelessWidget {
  const CmIconTile({
    super.key,
    required this.icon,
    this.color,
    this.size = 44,
    this.filled = false,
  });

  final IconData icon;
  final Color? color;
  final double size;

  /// Solid fill with an on-colour icon instead of the soft wash.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tone = color ?? cs.primary;
    final dark = cs.brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: filled ? tone : tone.withValues(alpha: dark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: filled
            ? (ThemeData.estimateBrightnessForColor(tone) == Brightness.dark
                  ? Colors.white
                  : Colors.black87)
            : tone,
      ),
    );
  }
}

/// Small rounded label, optionally with a leading icon, tinted by [color].
class CmPill extends StatelessWidget {
  const CmPill({super.key, required this.label, this.icon, this.color});

  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tone = color ?? cs.onSurfaceVariant;
    final dark = cs.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color == null
            ? cs.surfaceContainerHigh
            : tone.withValues(alpha: dark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: tone),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: tone,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Centered icon circle + title + optional message, for empty lists.
class CmEmptyState extends StatelessWidget {
  const CmEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
  });

  final IconData icon;
  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 56),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: cs.primary.withValues(
                alpha: cs.brightness == Brightness.dark ? 0.2 : 0.1,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 34, color: cs.primary),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

/// Row for drag-to-reorder lists: leading [lead] (icon tile or number),
/// title/subtitle and a drag-handle glyph.
class CmReorderTile extends StatelessWidget {
  const CmReorderTile({
    super.key,
    required this.lead,
    required this.title,
    this.subtitle,
  });

  final Widget lead;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: CmCard(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 14, 10),
        child: Row(
          children: [
            lead,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                ],
              ),
            ),
            Icon(Icons.drag_indicator_rounded, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

/// `proxyDecorator` for ReorderableListView: the dragged row lifts slightly.
Widget cmReorderProxy(Widget child, int index, Animation<double> animation) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      final v = Curves.easeOut.transform(animation.value);
      return Transform.scale(
        scale: 1 + 0.03 * v,
        child: Material(
          type: MaterialType.transparency,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(CmTokens.radiusLg),
              boxShadow: v > 0.01 ? CmTokens.of(context).shadowLg : null,
            ),
            child: child,
          ),
        ),
      );
    },
    child: child,
  );
}

/// Calendar-page badge: weekday, day number and month, tinted by [color].
class CmDateStub extends StatelessWidget {
  const CmDateStub({super.key, required this.date, required this.color});

  final DateTime? date;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = cs.brightness == Brightness.dark;
    final t = Theme.of(context).textTheme;
    final d = date;
    // Weekday/month in the app's language (falls back to English when intl
    // has no date data for the locale).
    final tag = Localizations.localeOf(context).toLanguageTag();
    final loc = DateFormat.localeExists(tag)
        ? tag
        : (DateFormat.localeExists(tag.split('-').first) ? tag.split('-').first : 'en');
    return Container(
      width: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: dark ? 0.22 : 0.14),
        borderRadius: BorderRadius.circular(CmTokens.radiusSm),
      ),
      child: Column(
        children: [
          Text(
            d == null ? '—' : DateFormat('EEE', loc).format(d).toUpperCase(),
            style: t.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            d == null ? '' : '${d.day}',
            style: t.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            d == null ? '' : DateFormat('MMM', loc).format(d),
            style: t.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Compact icon action for card footers, with a full 40px hit area.
class CmIconAction extends StatelessWidget {
  const CmIconAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: color),
      style: IconButton.styleFrom(
        minimumSize: const Size(40, 40),
        fixedSize: const Size(40, 40),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

/// Inline "couldn't load" notice for screens that stay usable around the
/// failure (a form whose picker didn't load, a list header). Full-screen
/// failures use [CmErrorState] instead.
class CmErrorBanner extends StatelessWidget {
  const CmErrorBanner({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(14, 8, onRetry == null ? 14 : 8, 8),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(CmTokens.radiusLg),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: cs.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: TextStyle(color: cs.onErrorContainer))),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context)!.commonRetry),
            ),
        ],
      ),
    );
  }
}

/// True when an app bar can't show [title] (even at 72 %) next to text
/// actions with these [labels] — Russian "Черновик" + "Опубликовать" left
/// "Нов…". The screen then shows its secondary action as an icon button.
bool cmBarIsTight(
  BuildContext context, {
  required String title,
  required List<String> labels,
  /// The last label is a filled button; does it carry a leading icon?
  bool primaryHasIcon = true,
}) {
  final theme = Theme.of(context);
  final scaler = MediaQuery.textScalerOf(context);
  final direction = Directionality.of(context);
  double measure(String s, TextStyle? style) {
    final p = TextPainter(
      text: TextSpan(text: s, style: style),
      maxLines: 1,
      textDirection: direction,
      textScaler: scaler,
    )..layout();
    final w = p.width;
    p.dispose();
    return w;
  }

  final titleW = measure(
        title,
        theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ) *
      CmBarTitle._minScale;
  var actionsW = 0.0;
  for (var i = 0; i < labels.length; i++) {
    final isPrimary = i == labels.length - 1;
    // Label + the button's own padding (M3: text 12+12; filled 24+24, or
    // 16 + icon 18 + gap 8 + 24 with a leading icon).
    actionsW += measure(labels[i], theme.textTheme.labelLarge) +
        (isPrimary ? (primaryHasIcon ? 66 : 48) : 24);
  }
  // Back button, title spacing, the gap between actions, end padding.
  const leadingAndGaps = 56 + 16 + 6 + 12;
  return leadingAndGaps + titleW + actionsW > MediaQuery.sizeOf(context).width;
}

/// App-bar title that shrinks a little instead of ending in "…" when the
/// actions take most of the bar ("Save draft" + "Publish" left "New Assi…").
/// Shrinks at most to 64% — past that it ellipsizes, so a long French
/// label can't squeeze the title into an unreadable sliver.
class CmBarTitle extends StatelessWidget {
  const CmBarTitle(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  static const _minScale = 0.64;

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    return LayoutBuilder(builder: (context, c) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: base),
        maxLines: 1,
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      final natural = painter.width;
      painter.dispose();
      final scale = natural <= c.maxWidth
          ? 1.0
          : (c.maxWidth / natural).clamp(_minScale, 1.0);
      final fontSize = base.fontSize ?? 20;
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: base.copyWith(fontSize: fontSize * scale),
      );
    });
  }
}

/// Section label with an optional count pill and a hairline that runs to
/// the end of the row.
class CmSectionHeader extends StatelessWidget {
  const CmSectionHeader({
    super.key,
    required this.label,
    this.icon,
    this.count,
    this.color,
  });

  final String label;
  final IconData? icon;
  final int? count;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tone = color ?? cs.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 17, color: tone),
            const SizedBox(width: 6),
          ],
          Semantics(header: true, child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: tone,
              letterSpacing: 0.3,
            ),
          )),
          if (count != null) ...[
            const SizedBox(width: 8),
            CmPill(label: '$count', color: tone),
          ],
          const SizedBox(width: 10),
          Expanded(
            child: Divider(
              height: 1,
              color: cs.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Initials avatar tinted with one of the theme's accents, picked stably from
/// the name so the same person always gets the same colour.
class CmMonogram extends StatelessWidget {
  const CmMonogram({
    super.key,
    required this.name,
    this.initials,
    this.radius = 22,
  });

  final String name;

  /// Pre-computed initials (e.g. from the server); derived from [name] if empty.
  final String? initials;
  final double radius;

  static String initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  static Color toneFor(String name, ColorScheme cs) {
    final tones = [cs.primary, cs.secondary, cs.tertiary];
    return tones[name.hashCode.abs() % tones.length];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tone = toneFor(name, cs);
    final text = (initials ?? '').replaceAll(',', '').trim();
    return CircleAvatar(
      radius: radius,
      backgroundColor: tone.withValues(alpha: cs.brightness == Brightness.dark ? 0.24 : 0.14),
      child: Text(
        text.isNotEmpty ? text : initialsOf(name),
        style: TextStyle(
          color: tone,
          fontWeight: FontWeight.w900,
          fontSize: radius * 0.68,
        ),
      ),
    );
  }
}

/// Header row for a form section: tinted icon tile + bold title, with an
/// optional trailing widget (count pill, action button).
class CmFormSectionHeader extends StatelessWidget {
  const CmFormSectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
  });

  final String title;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          CmIconTile(icon: icon!, size: 34),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Semantics(header: true, child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          )),
        ),
        ?trailing,
      ],
    );
  }
}

/// A form section: card with a [CmFormSectionHeader] above [child].
class CmFormSection extends StatelessWidget {
  const CmFormSection({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.trailing,
  });

  final String title;
  final Widget child;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return CmCard(
      radius: CmTokens.radiusXl,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CmFormSectionHeader(title: title, icon: icon, trailing: trailing),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

/// One attached file in a form: type tile, name, and a remove action.
class CmFileRow extends StatelessWidget {
  const CmFileRow({
    super.key,
    required this.name,
    required this.onRemove,
    required this.removeTooltip,
    this.icon,
  });

  final String name;
  final VoidCallback onRemove;
  final String removeTooltip;

  /// Defaults to a type icon guessed from [name]'s extension.
  final IconData? icon;

  static IconData iconFor(String name) {
    final n = name.toLowerCase();
    if (n.endsWith('.pdf')) return Icons.picture_as_pdf_rounded;
    for (final ext in ['.png', '.jpg', '.jpeg', '.webp', '.heic', '.gif']) {
      if (n.endsWith(ext)) return Icons.image_rounded;
    }
    for (final ext in ['.mp4', '.mov', '.webm']) {
      if (n.endsWith(ext)) return Icons.movie_rounded;
    }
    if (n.startsWith('http')) return Icons.link_rounded;
    return Icons.insert_drive_file_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 6, 2, 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(CmTokens.radiusMd),
      ),
      child: Row(
        children: [
          CmIconTile(icon: icon ?? iconFor(name), size: 36, color: cs.tertiary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          CmIconAction(
            icon: Icons.close_rounded,
            tooltip: removeTooltip,
            onPressed: onRemove,
            color: cs.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

/// Tappable form row that opens a picker: icon tile, label, the current
/// selection (if any) on the trailing side, and a chevron.
class CmPickerRow extends StatelessWidget {
  const CmPickerRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.summary,
    this.trailingIcon = Icons.chevron_right_rounded,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Current selection; null shows the row in its empty state.
  final String? summary;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final hasValue = summary != null && summary!.isNotEmpty;
    return CmPress(
      onTap: onTap,
      child: AnimatedContainer(
        duration: CmTokens.fast,
        padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 10, 8),
        decoration: BoxDecoration(
          color: hasValue
              ? cs.primary.withValues(alpha: cs.brightness == Brightness.dark ? 0.18 : 0.08)
              : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(CmTokens.radiusMd),
        ),
        child: Row(
          children: [
            CmIconTile(icon: icon, size: 36, filled: hasValue),
            const SizedBox(width: 12),
            // Empty state: the label is the whole prompt ("Tap to select
            // students…") — let it take the row and wrap, instead of pushing
            // the chevron off the edge in French/Russian or at large text.
            // With a value the label is a short noun and the value gets the
            // rest of the row.
            if (!hasValue)
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else ...[
              Text(
                label,
                style: t.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  summary!,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.bodyMedium?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(trailingIcon, size: 22, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
