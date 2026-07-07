import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences key for the "user finished the first-launch walkthrough"
/// flag. Bump the suffix if the onboarding is ever redesigned enough to
/// warrant showing it again.
const String kOnboardingSeenKey = 'onboarding_seen_v1';

/// Mirror of [kOnboardingSeenKey], seeded at app boot in `main()` (before the
/// first frame) and kept in sync when the walkthrough is completed. The
/// router's redirect is synchronous, so it can't await SharedPreferences — it
/// reads [onboardingSeenProvider], whose initial value comes from here.
bool onboardingSeenAtBoot = false;

/// Whether the first-launch walkthrough has already been shown/completed.
/// Built from [onboardingSeenAtBoot] so the value is correct on the very
/// first frame (and after an account-switch app restart).
final onboardingSeenProvider =
    NotifierProvider<OnboardingSeenController, bool>(OnboardingSeenController.new);

class OnboardingSeenController extends Notifier<bool> {
  @override
  bool build() => onboardingSeenAtBoot;

  void markSeen() => state = true;
}

/// Marks onboarding complete — in memory (so the router stops sending the user
/// back to it), persisted, and via [onboardingSeenAtBoot] so a later app
/// restart doesn't resurrect it.
Future<void> markOnboardingSeen(WidgetRef ref) async {
  onboardingSeenAtBoot = true;
  ref.read(onboardingSeenProvider.notifier).markSeen();
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kOnboardingSeenKey, true);
  } catch (_) {
    // Non-fatal: worst case the walkthrough shows once more next launch.
  }
}
