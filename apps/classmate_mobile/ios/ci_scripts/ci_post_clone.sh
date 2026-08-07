#!/bin/sh

# Xcode Cloud post-clone step for the ClassMate Flutter app.
#
# Why this exists: Xcode Cloud builds on Apple's *release* macOS fleet, which is
# how it dodges the ITMS-90111 "build on beta macOS" rejection that blocks
# uploads from Tony's beta-macOS 27 (Tahoe) MacBook. See the memory note
# appstore_itms90111_beta_macos.md. TestFlight tolerates the beta-macOS stamp;
# the PUBLIC App Store does not — so the public release must be built here.
#
# Two things this script must do before Xcode Cloud runs `pod install` + archive:
#   1. Install Flutter (the runners are bare Xcode — no Flutter).
#   2. Generate ios/Flutter/Generated.xcconfig, baking in the PROD API URL via
#      --dart-define. Without the define, env.dart's iOS default is
#      http://Tonys-MacBook-Air.local:3001 (the dev laptop) and the shipped app
#      would be dead for real users. CocoaPods for a Flutter app also *requires*
#      Generated.xcconfig to already exist, so this must run pre-pod-install.

set -e

PROD_API_BASE_URL="https://pacific-enchantment-production-7a80.up.railway.app"
FLUTTER_CHANNEL="stable"

echo "▸ Installing Flutter ($FLUTTER_CHANNEL)…"
git clone --depth 1 -b "$FLUTTER_CHANNEL" https://github.com/flutter/flutter.git "$HOME/flutter"
export PATH="$PATH:$HOME/flutter/bin"

flutter --version
flutter precache --ios

echo "▸ Resolving Dart packages…"
cd "$CI_PRIMARY_REPOSITORY_PATH/apps/classmate_mobile"
flutter pub get

echo "▸ Generating iOS build config (PROD API baked in)…"
# --config-only writes ios/Flutter/Generated.xcconfig (incl. the DART_DEFINES
# blob) and does NOT compile Dart — the archive step Xcode Cloud runs next does
# the real Dart→AOT build using this config. Obfuscation flags are carried the
# same way.
flutter build ios \
  --config-only \
  --release \
  --obfuscate \
  --split-debug-info=build/symbols \
  --dart-define=CM_API_BASE_URL="$PROD_API_BASE_URL"

echo "✅ Post-clone setup complete."
