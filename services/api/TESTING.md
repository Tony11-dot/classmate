# Testing (services/api)

- Unit + e2e live under `src/**`
- Jest config: `jest.config.cjs`
- Match: `**/*.spec.ts`

Commands:
- `pnpm -s test`       # run all
- `pnpm -s test:list`  # list discovered tests
- `pnpm -s jest -c jest.config.cjs <path>`  # run one file

Seeds:
- `/api/test/seed/admin-web` => full system seed (teacher/cohort/etc)
- `/api/test/seed/parent-web` => parent-only bootstrap
