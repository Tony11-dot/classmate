#!/usr/bin/env bash
set -euo pipefail
( cd services/pilot_api && ./scripts/smoke.sh )
