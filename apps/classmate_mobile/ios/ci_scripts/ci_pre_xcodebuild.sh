#!/bin/sh

# Xcode Cloud pre-xcodebuild step for the ClassMate Flutter app.
#
# Why this exists: Xcode Cloud stamps CFBundleVersion with its own run counter
# (CI_BUILD_NUMBER: 1, 2, 3 …), OVERRIDING Flutter's $(FLUTTER_BUILD_NUMBER)
# that ci_post_clone bakes in from pubspec. Proof is in run #3's export log:
#   "buildNumber":"3", "manageAppVersionAndBuildNumber":false
# The App Store already has build 258, so a "3" is rejected by altool/ASC:
#   "The bundle version must be higher than the previously uploaded version: 258"
#
# Fix: write a LITERAL build number into Runner/Info.plist here — after Xcode
# Cloud's setup, immediately before `xcodebuild archive`. A literal (not the
# $(FLUTTER_BUILD_NUMBER) variable) can't be re-expanded to the run counter, and
# the export runs with manageAppVersionAndBuildNumber:false so it keeps it.
#
# The number is CI_BUILD_NUMBER + BASE so it stays monotonic across runs and
# always clears the current App Store ceiling. Bump BASE only if a locally-built
# TestFlight upload ever catches up to these numbers.

set -e

BASE=258
NEW_BUILD=$(( ${CI_BUILD_NUMBER:-0} + BASE ))

INFO_PLIST="$CI_PRIMARY_REPOSITORY_PATH/apps/classmate_mobile/ios/Runner/Info.plist"

echo "▸ Forcing CFBundleVersion = $NEW_BUILD (CI_BUILD_NUMBER=${CI_BUILD_NUMBER:-?} + BASE=$BASE)"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEW_BUILD" "$INFO_PLIST"
echo "▸ CFBundleVersion is now: $(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$INFO_PLIST")"

echo "✅ Pre-xcodebuild build-number override complete."
