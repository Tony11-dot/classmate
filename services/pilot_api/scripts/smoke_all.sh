#!/usr/bin/env bash
set -euo pipefail
echo "== smoke_all =="

services/pilot_api/scripts/rule3_smoke.sh
services/pilot_api/scripts/notifications_smoke.sh
services/pilot_api/scripts/api_smoke.sh

echo "🎉 All smoke tests passed"
