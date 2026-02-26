#!/usr/bin/env bash
set -euo pipefail

SESSION="${1:-}"
if [[ -z "$SESSION" ]]; then
  echo "usage: $0 <0|1|2|...|15>"
  exit 1
fi

echo "==> Session $SESSION"
echo "==> Repo: $(git rev-parse --show-toplevel)"
echo "==> Branch: $(git branch --show-current)"
echo "==> Head: $(git rev-parse --short HEAD)"

case "$SESSION" in
  0)
    echo "==> Session 0: baseline + golden commands"

    # installs
    pnpm -s -w i

    # typecheck/lint (best effort; don't fail if scripts missing)
    pnpm -s -w -r run typecheck || true
    pnpm -s -w -r run lint || true

    # api health (assumes api running on 3002)
    node - <<'NODE'
(async () => {
  const base = (process.env.E2E_API_BASE_URL || 'http://127.0.0.1:3002').replace(/\/$/,'');
  const r = await fetch(base + '/api/health').catch(e => ({ status: 'ERR', text: async()=>String(e) }));
  console.log('API /health', r.status);
})();
NODE

    # admin-web e2e (with web wrapper if exists)
    if [[ -x scripts/e2e-with-web.sh ]]; then
      ./scripts/e2e-with-web.sh
    else
      echo "missing scripts/e2e-with-web.sh"
      exit 1
    fi

    echo "==> Session 0 done (manual: check docs/LAUNCH_PLAN.md boxes)"
    ;;
  1)
    echo "==> Session 1 placeholder"
    exit 2
    ;;
  2)
    echo "==> Session 2: auth/role resolution + role shells + dev override"

    echo "==> install"
    pnpm -s -w i

    echo "==> typecheck/lint (best effort)"
    pnpm -s -w -r run typecheck || true
    pnpm -s -w -r run lint || true

    echo "==> api health"
    curl -fsS "http://127.0.0.1:${API_PORT:-3002}/api/health" >/dev/null && echo "API /health 200"

    echo "==> golden (e2e)"
    ./scripts/golden.sh

    echo "==> Session 2 done (manual: check docs/LAUNCH_PLAN.md boxes)"
    ;;

  3)
    echo "==> Session 3 placeholder"
    exit 2
    ;;
  4)
    echo "==> Session 4 placeholder"
    exit 2
    ;;
  5)
    echo "==> Session 5 placeholder"
    exit 2
    ;;
  6|7|8|9|10|11|12|13|14|15)
    echo "==> Session $SESSION placeholder"
    exit 2
    ;;
  *)
    echo "invalid session: $SESSION"
    exit 1
    ;;
esac
