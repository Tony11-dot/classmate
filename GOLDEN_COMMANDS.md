cd services/api
pnpm i
pnpm db:reseed
pnpm test:src
pnpm dev

## Notes
- db:reseed is destructive (resets DB then seeds).
- Optional admin seed:
  - SEED_ADMIN_EMAIL
  - SEED_ADMIN_PASSWORD
  - SEED_ADMIN_NAME
