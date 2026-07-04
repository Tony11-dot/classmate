import 'package:flutter/material.dart';

/// NOVA's face everywhere in the app — a soft gradient orb with a sparkle,
/// instead of a plain letter. One widget so home header, chat bubbles and
/// typing indicator all share the same identity.
class NovaAvatar extends StatelessWidget {
  const NovaAvatar({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary, cs.tertiary],
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.35),
            blurRadius: size * 0.22,
            offset: Offset(0, size * 0.06),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.auto_awesome_rounded,
          size: size * 0.52,
          color: Colors.white,
        ),
      ),
    );
  }
}
