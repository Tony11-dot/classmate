#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

./pilot-stop.sh

nohup ./pilot-supervise.sh > .pilot.log 2>&1 &
echo $! > .pilot.pid

echo "Waiting for health..."
for i in {1..30}; do
  if curl -fsS "http://localhost:3000/api/health" >/dev/null 2>&1; then
    echo "✅ up"
    ./pilot-status.sh
    exit 0
  fi
  sleep 1
done

echo "❌ did not become healthy in 30s"
./pilot-status.sh
echo "Last 50 log lines:"
tail -n 50 .pilot.log || true
exit 1
