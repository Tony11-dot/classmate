# Golden Commands (Classmate)

## API (services/api)
- Start dev: `pnpm -C services/api dev`
- Typecheck: `pnpm -C services/api -s exec pnpm exec pnpm dlx typescript.9.3 tsc -p tsconfig.json`
- Lint: `pnpm -C services/api -s lint`
- Format: `pnpm -C services/api -s format`
- Prisma generate: `pnpm -C services/api -s prisma generate`
- Prisma migrate dev: `pnpm -C services/api -s prisma migrate dev`
- Prisma studio: `pnpm -C services/api -s prisma studio`
- Seed (E2E): `curl -sS -X POST http://127.0.0.1:3001/api/test/seed/admin-web >/dev/null`
- Ready: `curl -sS http://127.0.0.1:3001/api/ready | python3 -m json.tool`

## Tokens
- Login:
  ```bash
  BASE="http://127.0.0.1:3001"
  token_from_login () {
    local email="$1"
    local pass="$2"
    curl -sS -X POST "$BASE/api/auth/login" \
      -H 'Content-Type: application/json' \
      -d "{\"email\":\"${email}\",\"password\":\"${pass}\"}" \
    | python3 -c 'import json,sys; j=json.load(sys.stdin); print(j.get("token",""))'
  }
