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
///   ConsentGate(child: OnboardingGate(child: shell))
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
              builder: (ctx, r, _) {
                // `?? true` while loading → never flash the overlay before the
                // per-user "seen" flag has actually been read.
                final seen =
                    r.watch(onboardingSeenProvider(session.userId)).value ?? true;
                if (seen) return const SizedBox.shrink();
                return OnboardingTour(
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

/// The first-run tour.
///
/// Each slide is a real feature briefing rather than a slogan: the promise, then
/// what you can actually do with it, then chips naming the exact screens it maps
/// to — so by the end the user knows where things live, not just that the app is
/// "smart". The tour is tailored per role, since a parent and an admin have
/// almost nothing in common.
///
/// The chips reuse the app's existing nav labels, so they're already translated
/// everywhere and can never drift from the names in the drawer.
class OnboardingTour extends StatefulWidget {
  const OnboardingTour({
    super.key,
    required this.onDone,
    required this.firstName,
    required this.role,
  });

  final Future<void> Function() onDone;
  final String firstName;
  final String role;

  @override
  State<OnboardingTour> createState() => _OnboardingTourState();
}

class _OnboardingTourState extends State<OnboardingTour> {
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

  /// Role-tailored tour. Slide 1 is the shared (personalized) welcome; the rest
  /// brief the features that role actually uses, in the order they'll meet them.
  List<_Slide> _slides(AppLocalizations l) {
    final welcome = _Slide(
      icon: Icons.school_rounded,
      title: widget.firstName.isEmpty
          ? l.onboardingSlide1Title
          : l.onboardingWelcomeNamed(widget.firstName),
      body: l.onboardingSlide1Body,
      detail: l.onbDeepWelcome,
      colors: _cBlue,
    );

    switch (widget.role) {
      case 'TEACHER':
        return [
          welcome,
          _Slide(
            icon: Icons.groups_rounded,
            title: l.onbTeacher2Title,
            body: l.onbTeacher2Body,
            detail: l.onbDeepTeacherClasses,
            features: [l.navClassrooms, l.navCohorts, l.navAttendance, l.navMaterials],
            colors: _cViolet,
          ),
          _Slide(
            icon: Icons.fact_check_rounded,
            title: l.onbTeacher3Title,
            body: l.onbTeacher3Body,
            detail: l.onbDeepTeacherGrading,
            features: [l.navGrades, l.navAssignments, l.navExams, l.navInsights],
            colors: _cGreen,
          ),
          _Slide(
            icon: Icons.campaign_rounded,
            title: l.onbTeacher4Title,
            body: l.onbTeacher4Body,
            detail: l.onbDeepTeacherComms,
            features: [l.navAnnouncements, l.navMessages, l.navMeetings, l.navForms],
            colors: _cOrange,
          ),
        ];
      case 'ADMIN':
        return [
          welcome,
          _Slide(
            icon: Icons.dashboard_rounded,
            title: l.onbAdmin2Title,
            body: l.onbAdmin2Body,
            detail: l.onbDeepAdminOps,
            features: [l.navDashboard, l.navSchedule, l.navGradeScales, l.navReports],
            colors: _cViolet,
          ),
          _Slide(
            icon: Icons.person_add_alt_1_rounded,
            title: l.onbAdmin3Title,
            body: l.onbAdmin3Body,
            detail: l.onbDeepAdminPeople,
            features: [l.navPeople, l.navCohorts, l.navCertificates, l.navExportData],
            colors: _cGreen,
          ),
          _Slide(
            icon: Icons.campaign_rounded,
            title: l.onbAdmin4Title,
            body: l.onbAdmin4Body,
            detail: l.onbDeepConnect,
            features: [l.navAnnouncements, l.navMessages, l.navNotifications, l.cmailTitle],
            colors: _cOrange,
          ),
        ];
      case 'SECRETARY':
        return [
          welcome,
          _Slide(
            icon: Icons.school_rounded,
            title: l.onbSecretary2Title,
            body: l.onbSecretary2Body,
            detail: l.onbDeepSecretary,
            features: [l.navSchedule, l.navPeople, l.navCohorts, l.navCertificates],
            colors: _cViolet,
          ),
          _Slide(
            icon: Icons.campaign_rounded,
            title: l.onbSecretary3Title,
            body: l.onbSecretary3Body,
            detail: l.onbDeepConnect,
            features: [l.navAnnouncements, l.navMessages, l.cmailTitle],
            colors: _cGreen,
          ),
        ];
      case 'PARENT':
        return [
          welcome,
          _Slide(
            icon: Icons.favorite_rounded,
            title: l.onbParent2Title,
            body: l.onbParent2Body,
            detail: l.onbDeepParentChild,
            features: [l.navSchedule, l.navGrades, l.navAttendance, l.navAssignments],
            colors: _cViolet,
          ),
          _Slide(
            icon: Icons.notifications_active_rounded,
            title: l.onbParent3Title,
            body: l.onbParent3Body,
            detail: l.onbDeepParentAlerts,
            features: [l.navNotifications, l.navMessages, l.navMeetings],
            colors: _cGreen,
          ),
          _Slide(
            icon: Icons.forum_rounded,
            title: l.onboardingSlide4Title,
            body: l.onboardingSlide4Body,
            detail: l.onbDeepConnect,
            features: [l.navMessages, l.navAnnouncements, l.cmailTitle],
            colors: _cOrange,
          ),
        ];
      default: // STUDENT
        return [
          welcome,
          _Slide(
            icon: Icons.auto_awesome_rounded,
            title: l.onboardingSlide2Title,
            body: l.onboardingSlide2Body,
            detail: l.onbDeepNova,
            features: [l.navNova, l.navPractice, l.navSavedQuestions, l.titleSolutions],
            colors: _cViolet,
          ),
          _Slide(
            icon: Icons.insights_rounded,
            title: l.onboardingSlide3Title,
            body: l.onboardingSlide3Body,
            detail: l.onbDeepTrack,
            features: [
              l.navSchedule,
              l.navGrades,
              l.navAttendance,
              l.navAssignments,
              l.navExams,
            ],
            colors: _cGreen,
          ),
          _Slide(
            icon: Icons.forum_rounded,
            title: l.onboardingSlide4Title,
            body: l.onboardingSlide4Body,
            detail: l.onbDeepConnect,
            features: [l.navMessages, l.navAnnouncements, l.navMeetings, l.cmailTitle],
            colors: _cOrange,
          ),
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

  void _previous() {
    if (_page == 0) return;
    HapticFeedback.selectionClick();
    _controller.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
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
              // On a web window or an iPad the tour would otherwise stretch a
              // 60-character line across 1400 px; hold it to a readable column.
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Column(
                    children: [
                      _header(l, accent.first, slides.length),
                      Expanded(
                        child: PageView.builder(
                          controller: _controller,
                          itemCount: slides.length,
                          onPageChanged: (i) => setState(() => _page = i),
                          itemBuilder: (context, i) => _SlideView(
                            slide: slides[i],
                            whatsInsideLabel: l.onbWhatsInside,
                          ),
                        ),
                      ),
                      _dots(slides.length, accent.first, cs),
                      _actions(l, accent.first, slides.length, isLast),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Logo, a live "2 of 5" step counter, and Skip.
  Widget _header(AppLocalizations l, Color accent, int count) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 8, 0),
      child: Row(
        children: [
          const ClassMateLogo(height: 30),
          const SizedBox(width: 12),
          // Knowing how long the tour is makes people finish it instead of
          // hunting for Skip.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              l.onbStepOf(_page + 1, count),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const Spacer(),
          if (_page > 0)
            TextButton(
              onPressed: _finishing ? null : _previous,
              child: Text(
                l.onbBack,
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ),
          TextButton(
            onPressed: _finishing ? null : _finish,
            child: Text(l.onboardingSkip),
          ),
        ],
      ),
    );
  }

  Widget _dots(int count, Color accent, ColorScheme cs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == _page ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == _page ? accent : cs.outlineVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }

  Widget _actions(AppLocalizations l, Color accent, int count, bool isLast) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              onPressed: _finishing ? null : () => _next(count),
              style: FilledButton.styleFrom(
                backgroundColor: accent,
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
          const SizedBox(height: 8),
          if (!isLast)
            Text(
              l.onbSwipeHint,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// One slide: hero, promise, the concrete "what you can do" paragraph, and chips
/// naming the screens it maps to. Scrollable, so a long translation or a large
/// accessibility text size can't clip it.
class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide, required this.whatsInsideLabel});

  final _Slide slide;
  final String whatsInsideLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Animated gradient hero orb — scales in on each slide so swiping
          // gives a subtle pop.
          TweenAnimationBuilder<double>(
            key: ValueKey(slide.icon.codePoint),
            tween: Tween(begin: 0.85, end: 1.0),
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Container(
              width: 108,
              height: 108,
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
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(slide.icon, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 26),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          if (slide.detail != null) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant, width: 0.6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: 16, color: slide.colors.first),
                      const SizedBox(width: 6),
                      Text(
                        whatsInsideLabel.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    slide.detail!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (slide.features.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final name in slide.features)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: slide.colors.first.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: slide.colors.first.withValues(alpha: 0.28),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      name,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ],
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
    this.detail,
    this.features = const [],
  });

  final IconData icon;
  final String title;

  /// The one-line promise.
  final String body;

  /// The concrete "what you can actually do" paragraph. Null on slides where the
  /// body already carries the detail (e.g. ClassNotes).
  final String? detail;

  /// Names of the screens this slide maps to, shown as chips. These reuse the
  /// app's nav labels, so they match the drawer exactly in every language.
  final List<String> features;

  final List<Color> colors;
}
