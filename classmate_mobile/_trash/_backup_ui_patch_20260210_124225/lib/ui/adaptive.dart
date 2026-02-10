import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_controller.dart';

class AdaptiveSection extends ConsumerWidget {
  final String title;
  final Widget child;
  final EdgeInsetsGeometry padding;
  const AdaptiveSection({
    super.key,
    required this.title,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 10, 16, 16),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preset = ref.watch(themeControllerProvider).preset;

    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: preset == ThemePreset.sharpContrast
          ? FontWeight.w900
          : FontWeight.w800,
      letterSpacing: preset == ThemePreset.sharpContrast ? -0.2 : 0,
    );

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class AdaptiveCard extends ConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  const AdaptiveCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin = const EdgeInsets.symmetric(vertical: 6),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(themeControllerProvider);
    final preset = s.preset;
    final cs = Theme.of(context).colorScheme;

    final radius = (14 + (s.radius - 14)).clamp(6, 22).toDouble();

    if (preset == ThemePreset.minimal) {
      return Container(
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
        ),
        child: child,
      );
    }

    if (preset == ThemePreset.sharpContrast) {
      return Container(
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.55)),
        ),
        child: child,
      );
    }

    return Card(
      margin: margin,
      child: Padding(padding: padding, child: child),
    );
  }
}

class AdaptiveTile extends ConsumerWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final bool isThreeLine;
  final VoidCallback? onTap;

  const AdaptiveTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.isThreeLine = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preset = ref.watch(themeControllerProvider).preset;

    final tile = ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      isThreeLine: isThreeLine,
      onTap: onTap,
    );

    if (preset == ThemePreset.minimal) return tile;

    return AdaptiveCard(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: tile,
    );
  }
}
