#!/usr/bin/env bash
# Local preview of the Flutter web build at http://localhost:8765/
#
# Differences from scripts/sync-flutter-web.sh (the deploy build):
#   - base-href is "/" so the SPA loads from the server root
#   - service worker is disabled so reloads are immediate
#   - no-cache HTTP headers so Safari never serves a stale main.dart.js
#   - API points at production Railway by default — override with
#     CM_API_BASE_URL env var if you want to hit a local API instead
#
# Run from repo root: ./scripts/preview-web-local.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FLUTTER_DIR="$REPO_ROOT/apps/classmate_mobile"
PORT="${PORT:-8765}"
API_BASE_URL="${CM_API_BASE_URL:-https://pacific-enchantment-production-7a80.up.railway.app}"

echo "[preview-web-local] Building Flutter web (base-href=/, no PWA)..."
echo "[preview-web-local] CM_API_BASE_URL=$API_BASE_URL"
( cd "$FLUTTER_DIR" && flutter build web --release --pwa-strategy=none \
    --dart-define=CM_API_BASE_URL="$API_BASE_URL" )

echo "[preview-web-local] Serving http://localhost:$PORT/ (Ctrl+C to stop)"
cd "$FLUTTER_DIR/build/web"
exec python3 - "$PORT" <<'PY'
import sys
from http.server import HTTPServer, SimpleHTTPRequestHandler

class NoCacheHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        SimpleHTTPRequestHandler.end_headers(self)

port = int(sys.argv[1])
HTTPServer(('0.0.0.0', port), NoCacheHandler).serve_forever()
PY
