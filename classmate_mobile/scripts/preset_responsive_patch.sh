#!/usr/bin/env bash
set -euo pipefail

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing $1"; exit 1; }; }
need perl
need find

pick_first() {
  local pattern="$1"
  find lib -type f -name "*.dart" -path "*features*" | grep -i "$pattern" | head -n 1 || true
}

patch_file() {
  local f="$1"
  [[ -n "$f" && -f "$f" ]] || { echo "Skip (not found) $f"; return 0; }

  echo "==> Patching $f"

  # Ensure imports exist (Riverpod already in these screens typically; we only add Adaptive)
  perl -i -pe 'BEGIN{$added=0} if(!$added && /^import /){$added=1; $_="import \"package:flutter/material.dart\";\nimport \"package:flutter_riverpod/flutter_riverpod.dart\";\nimport \"../../ui/adaptive.dart\";\n".$_ if $_ !~ /adaptive\.dart/}' "$f" || true

  # Replace common Card(...) blocks with AdaptiveCard(...)
  perl -i -pe 's/\bCard\s*\(/AdaptiveCard(/g' "$f"

  # Replace simple ListTile(...) in common “cards list” screens with AdaptiveTile(...)
  perl -i -pe 's/\bListTile\s*\(/AdaptiveTile(/g' "$f"

  # If there are section headers "Text('X'..." we keep; but we prefer AdaptiveSection
  # Simple heuristic: if the file contains a Column with a header + body, we don't rewrite aggressively.
}

schedule="$(pick_first "schedule")"
tutor="$(pick_first "tutor")"
insights="$(pick_first "insight")"

echo "Detected:"
echo "  schedule: ${schedule:-NONE}"
echo "  tutor:    ${tutor:-NONE}"
echo "  insights: ${insights:-NONE}"

patch_file "$schedule"
patch_file "$tutor"
patch_file "$insights"

echo "==> Done. If a file wasn't found, tell me its exact path and I'll patch it."
