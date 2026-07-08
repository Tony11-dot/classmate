import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_session.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets/classmate_logo.dart';
import 'onboarding_controller.dart';

/// Gate that shows the first-run walkthrough as an overlay the first time an
/// account reaches the app after accepting consent. Wrap the shell content in
/// it (inside [ConsentGate], so consent takes priority):
///
///   ConsentGate(child: OnboardingGate(child: <shell>))
///
/// Because [AuthSession] is a ChangeNotifier we observe it via a
/// [ListenableBuilder] (a plain `ref.watch(...select)` wouldn't rebuild when
/// `acceptConsent()` flips the flag) — so the walkthrough appears the instant
/// the consent overlay clears.
class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final eligible = session.isLoggedIn &&
            !session.consentRequired &&
            session.userId.isNotEmpty;
        if (!eligible) return child;
        return Stack(
          children: [
            child,
            Consumer(
              builder: (ctx, r, __) {
                // `?? true` while loading → never flash the overlay before the
                // per-user "seen" flag has actually been read.
                final seen =
                    r.watch(onboardingSeenProvider(session.userId)).value ?? true;
                if (seen) return const SizedBox.shrink();
                return _OnboardingOverlay(
                  firstName: _firstName(session.displayName),
                  role: session.primaryRole,
                  onDone: () async {
                    await markOnboardingSeen(session.userId);
                    r.invalidate(onboardingSeenProvider(session.userId));
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  static String _firstName(String full) {
    final t = full.trim();
    if (t.isEmpty) return '';
    return t.split(RegExp(r'\s+')).first;
  }
}

/// The upgraded walkthrough itself — a full-screen animated carousel.
class _OnboardingOverlay extends StatefulWidget {
  const _OnboardingOverlay({
    required this.onDone,
    required this.firstName,
    required this.role,
  });

  final Future<void> Function() onDone;
  final String firstName;
  final String role;

  @override
  State<_OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<_OnboardingOverlay> {
  final _controller = PageController();
  int _page = 0;
  bool _finishing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Slide palettes (reused across roles).
  static const _cBlue = [Color(0xFF0EA5E9), Color(0xFF4F46E5)];
  static const _cViolet = [Color(0xFF7C3AED), Color(0xFFDB2777)];
  static const _cGreen = [Color(0xFF0D9488), Color(0xFF16A34A)];
  static const _cOrange = [Color(0xFFEA580C), Color(0xFFE11D48)];

  /// Role-tailored walkthrough. Slide 1 is the shared (personalized) welcome;
  /// the rest highlight the features that role actually uses.
  List<_Slide> _slides(AppLocalizations l) {
    final welcome = _Slide(
      icon: Icons.school_rounded,
      title: widget.firstName.isEmpty
          ? l.onboardingSlide1Title
          : l.onboardingWelcomeNamed(widget.firstName),
      body: l.onboardingSlide1Body,
      colors: _cBlue,
    );
    final connected = _Slide(
      icon: Icons.forum_rounded,
      title: l.onboardingSlide4Title,
      body: l.onboardingSlide4Body,
      colors: _cOrange,
    );

    switch (widget.role) {
      case 'TEACHER':
        return [
          welcome,
          _Slide(icon: Icons.groups_rounded, title: l.onbTeacher2Title, body: l.onbTeacher2Body, colors: _cViolet),
          _Slide(icon: Icons.fact_check_rounded, title: l.onbTeacher3Title, body: l.onbTeacher3Body, colors: _cGreen),
          _Slide(icon: Icons.campaign_rounded, title: l.onbTeacher4Title, body: l.onbTeacher4Body, colors: _cOrange),
        ];
      case 'ADMIN':
        return [
          welcome,
          _Slide(icon: Icons.dashboard_rounded, title: l.onbAdmin2Title, body: l.onbAdmin2Body, colors: _cViolet),
          _Slide(icon: Icons.person_add_alt_1_rounded, title: l.onbAdmin3Title, body: l.onbAdmin3Body, colors: _cGreen),
          _Slide(icon: Icons.campaign_rounded, title: l.onbAdmin4Title, body: l.onbAdmin4Body, colors: _cOrange),
        ];
      case 'SECRETARY':
        return [
          welcome,
          _Slide(icon: Icons.school_rounded, title: l.onbSecretary2Title, body: l.onbSecretary2Body, colors: _cViolet),
          _Slide(icon: Icons.campaign_rounded, title: l.onbSecretary3Title, body: l.onbSecretary3Body, colors: _cGreen),
          connected,
        ];
      case 'PARENT':
        return [
          welcome,
          _Slide(icon: Icons.favorite_rounded, title: l.onbParent2Title, body: l.onbParent2Body, colors: _cViolet),
          _Slide(icon: Icons.notifications_active_rounded, title: l.onbParent3Title, body: l.onbParent3Body, colors: _cGreen),
          connected,
        ];
      default: // STUDENT
        return [
          welcome,
          _Slide(icon: Icons.auto_awesome_rounded, title: l.onboardingSlide2Title, body: l.onboardingSlide2Body, colors: _cViolet),
          _Slide(icon: Icons.insights_rounded, title: l.onboardingSlide3Title, body: l.onboardingSlide3Body, colors: _cGreen),
          connected,
        ];
    }
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    HapticFeedback.mediumImpact();
    await widget.onDone();
  }

  void _next(int count) {
    if (_page >= count - 1) {
      _finish();
    } else {
      HapticFeedback.selectionClick();
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
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
    final accent = slides[_page].colors;

    // Opaque full-screen page (covers the shell + nav underneath) so it reads
    // as a dedicated intro, not a translucent sheet. PopScope keeps hardware
    // back from dropping the user into a half-onboarded app.
    return PopScope(
      canPop: false,
      child: Material(
        color: cs.surface,
        child: Stack(
          children: [
            // Soft ambient wash that shifts colour per slide.
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    accent.first.withValues(alpha: 0.14),
                    cs.surface.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
                    child: Row(
                      children: [
                        const ClassMateLogo(height: 30),
                        const Spacer(),
                        TextButton(
                          onPressed: _finishing ? null : _finish,
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
                      itemBuilder: (context, i) => _SlideView(slide: slides[i]),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < slides.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 260),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _page ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _page ? accent.first : cs.outlineVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        onPressed: _finishing ? null : () => _next(slides.length),
                        style: FilledButton.styleFrom(
                          backgroundColor: accent.first,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _finishing
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                isLast ? l.onboardingGetStarted : l.onboardingNext,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated gradient hero orb — scales/fades in on each build so
          // swiping between slides gives a subtle pop.
          TweenAnimationBuilder<double>(
            key: ValueKey(slide.icon.codePoint),
            tween: Tween(begin: 0.85, end: 1.0),
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: slide.colors,
                ),
                boxShadow: [
                  BoxShadow(
                    color: slide.colors.first.withValues(alpha: 0.35),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Icon(slide.icon, size: 66, color: Colors.white),
            ),
          ),
          const SizedBox(height: 44),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide {
  const _Slide({
    required this.icon,
    required this.title,
    required this.body,
    required this.colors,
  });
  final IconData icon;
  final String title;
  final String body;
  final List<Color> colors;
}
