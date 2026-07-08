import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Per-account "has completed the first-run walkthrough" flag.
///
/// The onboarding now shows as an in-shell overlay the first time an account
/// reaches the app AFTER accepting the Terms/Privacy consent gate — so it is
/// scoped per user (each account sees it once), not per device.
String _seenKey(String userId) =>
    'onboarding_seen_v2_${userId.isEmpty ? 'anon' : userId}';

/// Resolves whether [userId] has already seen the walkthrough. While loading
/// (or when there is no user yet) callers treat the absence of a `false` as
/// "don't show", so the overlay never flashes before the check completes.
final onboardingSeenProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, userId) async {
  if (userId.isEmpty) return true;
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_seenKey(userId)) ?? false;
  } catch (_) {
    return true; // fail safe: never trap a user behind a broken read
  }
});

/// Persist that [userId] finished (or skipped) the walkthrough.
Future<void> markOnboardingSeen(String userId) async {
  if (userId.isEmpty) return;
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenKey(userId), true);
  } catch (_) {
    // Non-fatal: worst case it shows once more next launch.
  }
}
