# DevX (Local dev & tests)

## Fresh clone
- `pnpm i`
- `pnpm -s devx:up` (creates DB container if missing, migrates, runs tests)


## Golden commands
- `pnpm -s devx:up` — start postgres (docker), run prisma migrate deploy, start API, run e2e + parent-web tests
- `pnpm -s devx:test` — start API + run tests (assumes DB already reachable)
- `pnpm -s devx:doctor` — diagnostics (env/db/ports/logs)
- `pnpm -s devx:stop` — kill API port listener
- `pnpm -s devx:ps` — show processes + port listener
- `pnpm -s devx:logs` — tail API log

## Common issues
### DB not reachable
- Ensure docker container is running: `docker ps | rg classmate-postgres`
- Default DB port is `5433` (container -> 5432).

### Missing env
- API reads `services/api/.env` (auto-created from `services/api/.env.example` when using `devx:up`).

### Port 3000 already in use
- Run `pnpm -s devx:stop` then `pnpm -s devx:up`.

## Prisma config
- `services/api/prisma.config.ts` is used by Prisma CLI.
- Prisma will say it "skips environment variable loading" — that’s OK because the config imports `dotenv/config`.
- If `DATABASE_URL` is missing, create `services/api/.env` (or run `pnpm -s devx:up` which auto-creates it from `.env.example`).
