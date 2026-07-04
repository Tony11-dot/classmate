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
      // Glassy top-left sheen + a hairline ring so the orb reads as a lit
      // sphere instead of a flat gradient disc — sharper at avatar sizes.
      foregroundDecoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.45, -0.55),
          radius: 1.1,
          colors: [
            Colors.white.withValues(alpha: 0.32),
            Colors.white.withValues(alpha: 0.06),
            Colors.transparent,
          ],
          stops: const [0.0, 0.38, 0.72],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: (size * 0.028).clamp(0.8, 1.6),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Faint echo behind the sparkle gives it a soft glow without a blur.
          Icon(
            Icons.auto_awesome_rounded,
            size: size * 0.62,
            color: Colors.white.withValues(alpha: 0.22),
          ),
          Icon(
            Icons.auto_awesome_rounded,
            size: size * 0.5,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
