import 'package:flutter/material.dart';

import '../../core/theme/cm_tokens.dart';
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
        padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
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
