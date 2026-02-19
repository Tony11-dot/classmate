#!/usr/bin/env bash
set -euo pipefail
tail -n "${1:-200}" /tmp/cm_backend_dev.log
