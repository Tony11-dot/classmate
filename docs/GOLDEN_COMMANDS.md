# Golden Commands

## Local dev
pnpm -w install
docker compose up -d --build
curl -fsS --noproxy "*" http://127.0.0.1:3000/api/health

## API
pnpm -w --filter @classmate/api lint
pnpm -w --filter @classmate/api test

## Full workspace build
pnpm -w -r run build

## Logs
docker compose logs -f --tail=200 api
