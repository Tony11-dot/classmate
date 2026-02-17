import 'package:flutter/material.dart';

class MascotMood {
  final bool lookAway;
  final bool excited;
  final double focus; // 0=email, 1=password, 0.5=none
  const MascotMood({
    required this.lookAway,
    required this.excited,
    required this.focus,
  });
}

class AnimatedMascot extends StatelessWidget {
  final MascotMood mood;
  const AnimatedMascot({super.key, required this.mood});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    // pupils: move based on focus; lookAway forces them to the side
    final fx = mood.lookAway ? 0.9 : (mood.focus - 0.5) * 1.2; // [-0.6..0.6]
    final bounce = mood.excited ? 1.0 : 0.0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: bounce),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (context, v, _) {
        final y = -6 * v;
        return Transform.translate(
          offset: Offset(0, y),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                _Face(pupilX: fx, lookAway: mood.lookAway),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    mood.excited
                        ? 'Let’s go 👀'
                        : (mood.lookAway
                              ? 'I’m not looking 🙈'
                              : 'Type… I’m watching'),
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Face extends StatelessWidget {
  final double pupilX;
  final bool lookAway;
  const _Face({required this.pupilX, required this.lookAway});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: 72,
      height: 56,
      child: Stack(
        children: [
          // head
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: cs.outlineVariant),
              ),
            ),
          ),
          // eyes
          Positioned(
            left: 14,
            top: 16,
            child: _Eye(pupilX: pupilX, closed: false),
          ),
          Positioned(
            right: 14,
            top: 16,
            child: _Eye(pupilX: pupilX, closed: false),
          ),
          // "hands" when lookAway
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            left: lookAway ? 18 : -30,
            top: lookAway ? 6 : 28,
            child: Transform.rotate(
              angle: lookAway ? -0.4 : 0.0,
              child: Container(
                width: 26,
                height: 10,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.30),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            right: lookAway ? 18 : -30,
            top: lookAway ? 6 : 28,
            child: Transform.rotate(
              angle: lookAway ? 0.4 : 0.0,
              child: Container(
                width: 26,
                height: 10,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.30),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
          // mouth
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Center(
              child: Container(
                width: 18,
                height: 6,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Eye extends StatelessWidget {
  final double pupilX;
  final bool closed;
  const _Eye({required this.pupilX, required this.closed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final px = (pupilX).clamp(-1.0, 1.0);

    return Container(
      width: 18,
      height: 12,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Align(
        alignment: Alignment(px, 0),
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: cs.onSurface,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ),
    );
  }
}
