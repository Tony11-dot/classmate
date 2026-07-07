import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/widgets/classmate_logo.dart';
import 'onboarding_controller.dart';

/// First-launch walkthrough. Shown once to logged-out users who haven't seen
/// it (see the router redirect + [onboardingSeenProvider]). Introduces what
/// ClassMate is and its headline features, then hands off to /login.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_Slide> _slides(AppLocalizations l) => [
        _Slide(
          icon: Icons.school_rounded,
          title: l.onboardingSlide1Title,
          body: l.onboardingSlide1Body,
        ),
        _Slide(
          icon: Icons.psychology_rounded,
          title: l.onboardingSlide2Title,
          body: l.onboardingSlide2Body,
        ),
        _Slide(
          icon: Icons.event_note_rounded,
          title: l.onboardingSlide3Title,
          body: l.onboardingSlide3Body,
        ),
        _Slide(
          icon: Icons.forum_rounded,
          title: l.onboardingSlide4Title,
          body: l.onboardingSlide4Body,
        ),
      ];

  Future<void> _finish() async {
    await markOnboardingSeen(ref);
    if (!mounted) return;
    context.go('/login');
  }

  void _next(int count) {
    if (_page >= count - 1) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final slides = _slides(l);
    final isLast = _page >= slides.length - 1;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top row: logo + Skip.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Row(
                children: [
                  const ClassMateLogo(height: 30),
                  const Spacer(),
                  TextButton(
                    onPressed: _finish,
                    child: Text(l.onboardingSkip),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final s = slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                cs.primary.withValues(alpha: 0.18),
                                cs.primary.withValues(alpha: 0.06),
                              ],
                            ),
                          ),
                          child: Icon(s.icon, size: 60, color: cs.primary),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          s.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          s.body,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Page dots.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < slides.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page ? cs.primary : cs.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _next(slides.length),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isLast ? l.onboardingGetStarted : l.onboardingNext,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide {
  const _Slide({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;
}
