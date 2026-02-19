# Next-step-10 Ship Checklist

## API (must)
- [ ] /api/health (liveness) + /api/ready (readiness) endpoints
- [ ] readiness checks DB connectivity (simple SELECT 1)
- [ ] request-id already wired (done), ensure response header is set and propagated
- [ ] http logging: redact auth/cookies + avoid logging bodies by default
- [ ] env validation: fail fast on missing/invalid env
- [ ] error shape consistency (BadRequest/Forbidden/etc) - stable contract

## DX / CI (must)
- [ ] CI runs `cd services/api && NODE_ENV=test pnpm test -- src --runInBand`
- [ ] standard "golden commands" documented

## Later (nice)
- [ ] metrics (prometheus) + log levels
- [ ] docker compose local
- [ ] deploy checklist
