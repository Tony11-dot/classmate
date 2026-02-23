import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 18,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isDark = t.brightness == Brightness.dark;

    final bg = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.white.withOpacity(0.70);

    final border = isDark
        ? Colors.white.withOpacity(0.10)
        : Colors.black.withOpacity(0.06);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: border, width: 1),
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

class GlassBar extends StatelessWidget {
  const GlassBar({
    super.key,
    this.title,
    this.leading,
    this.trailing,
    this.actions,
    this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  });

  final String? title;
  final Widget? leading;
  final Widget? trailing;
  final List<Widget>? actions;
  final Widget? child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final content = child ??
        Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                title ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.titleMedium,
              ),
            ),
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(width: 10),
              ...actions!,
            ],
            if (trailing != null) ...[
              const SizedBox(width: 10),
              trailing!,
            ],
          ],
        );

    return GlassCard(
      padding: padding,
      radius: 20,
      child: content,
    );
  }
}
