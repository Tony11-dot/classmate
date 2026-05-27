#!/usr/bin/env bash
# Builds the Flutter web app and copies it into apps/admin-web/public/app/
# so Next.js (deployed on Vercel) serves the marketing site at /
# and the Flutter web build at /app/* from a single host.
#
# Run from repo root: ./scripts/sync-flutter-web.sh
# CI uses this same script before `next build`.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FLUTTER_DIR="$REPO_ROOT/apps/classmate_mobile"
TARGET_DIR="$REPO_ROOT/apps/admin-web/public/app"

echo "[sync-flutter-web] Building Flutter web (--base-href=/app/)..."
( cd "$FLUTTER_DIR" && flutter build web --release --base-href "/app/" )

echo "[sync-flutter-web] Replacing $TARGET_DIR ..."
rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"
cp -R "$FLUTTER_DIR/build/web/." "$TARGET_DIR/"

echo "[sync-flutter-web] Done. Files staged at apps/admin-web/public/app/"
